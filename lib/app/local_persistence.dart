part of 'package:ticketmaster/main.dart';

class _TicketmasterCloudStore {
  _TicketmasterCloudStore._();

  static final _TicketmasterCloudStore instance = _TicketmasterCloudStore._();
  static const Duration sessionDuration = Duration(days: 14);
  static const String _authorizedUsersCollection = 'authorized_users';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Map<String, String> _editedTexts = <String, String>{};
  List<_TicketListEntry> _upcomingTickets = <_TicketListEntry>[];
  TicketmasterDeviceInfo? _deviceInfo;
  DateTime? _sessionStartedAt;
  Future<void> _pendingWrite = Future<void>.value();

  List<_TicketListEntry> get upcomingTickets =>
      List<_TicketListEntry>.from(_upcomingTickets);

  bool get hasSavedTickets => _upcomingTickets.isNotEmpty;

  bool get isSessionExpired {
    final startedAt = _sessionStartedAt;
    if (startedAt == null) {
      return false;
    }
    return DateTime.now().difference(startedAt) >= sessionDuration;
  }

  Future<void> initialize() async {
    await _ensureDeviceInfo();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _resetInMemoryState();
      _EditableTextStore.hydrate(_editedTexts);
      return;
    }

    final access = await _checkDeviceAccessForUser(currentUser.uid);
    if (!access.isAllowed) {
      await FirebaseAuth.instance.signOut();
      _resetInMemoryState();
      _EditableTextStore.hydrate(_editedTexts);
      return;
    }
    await loadForCurrentUser();
  }

  Future<void> loadForCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _resetInMemoryState();
      _EditableTextStore.hydrate(_editedTexts);
      return;
    }

    final localSnapshot = await _loadLocalSnapshotForUser(currentUser.uid);
    if (localSnapshot != null) {
      _applySnapshot(localSnapshot);
    }

    var shouldRewriteLocalCache = false;
    try {
      final profileSnapshot = await _profileDocument(currentUser.uid).get();
      final profileData = profileSnapshot.data();
      final remoteEditedTexts = _readEditedTexts(profileData?['editedTexts']);
      final remoteSessionStartedAt = _readSessionStartedAt(
        profileData?['sessionStartedAt'],
      );
      final remoteUpdatedAt = _readSnapshotUpdatedAt(profileData?['updatedAt']);
      final remoteTickets = await _loadTicketsForUser(currentUser.uid);
      final remoteSnapshot = _LocalTicketmasterSnapshot(
        editedTexts: remoteEditedTexts,
        upcomingTickets: remoteTickets,
        sessionStartedAt: remoteSessionStartedAt,
        updatedAt: remoteUpdatedAt,
      );

      final resolvedSnapshot = _mergeSnapshots(
        localSnapshot: localSnapshot,
        remoteSnapshot: remoteSnapshot,
      );
      if (resolvedSnapshot != null) {
        _applySnapshot(resolvedSnapshot);
        shouldRewriteLocalCache = true;
      }
    } catch (_) {
      if (localSnapshot == null) {
        _resetInMemoryState();
      }
    }

    _EditableTextStore.hydrate(_editedTexts);
    if (shouldRewriteLocalCache) {
      unawaited(_persistLocalState());
    }
  }

  Future<void> ensureSessionForCurrentUser() async {
    if (FirebaseAuth.instance.currentUser == null ||
        _sessionStartedAt != null) {
      return;
    }
    _sessionStartedAt = DateTime.now();
    await _enqueueProfilePersist();
  }

  Future<bool> hasCurrentDeviceAccess() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return true;
    }
    final access = await _checkDeviceAccessForUser(currentUser.uid);
    return access.isAllowed;
  }

  /// Sign-in gate. Fails closed: returns false when the email is empty,
  /// missing from the `authorized_users` allowlist, marked inactive, or the
  /// check could not be completed. Use this after authentication to block
  /// accounts that an admin has not authorized.
  Future<bool> isEmailAuthorized(String? email) async {
    return await _authorizationStatus(email) == _AuthorizationStatus.authorized;
  }

  /// Launch gate. Denies only a confirmed removal from the allowlist; a
  /// transient read error is treated as authorized so a cold-start network
  /// hiccup does not sign everyone out. A revoked user is signed out on the
  /// next successful launch.
  Future<bool> isCurrentUserAuthorized() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    return await _authorizationStatus(currentUser?.email) !=
        _AuthorizationStatus.unauthorized;
  }

  Future<_AuthorizationStatus> _authorizationStatus(String? email) async {
    final normalized = (email ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return _AuthorizationStatus.unauthorized;
    }
    try {
      final snapshot = await _firestore
          .collection(_authorizedUsersCollection)
          .doc(normalized)
          .get();
      if (!snapshot.exists) {
        return _AuthorizationStatus.unauthorized;
      }
      return snapshot.data()?['active'] == false
          ? _AuthorizationStatus.unauthorized
          : _AuthorizationStatus.authorized;
    } catch (_) {
      return _AuthorizationStatus.unknown;
    }
  }

  /// Clears the in-memory session/state so a signed-out (or revoked) user's
  /// data is not shown to the next user.
  void resetLocalState() {
    _resetInMemoryState();
    _EditableTextStore.hydrate(_editedTexts);
  }

  Future<void> markLoginSucceeded() async {
    await _claimCurrentDeviceForCurrentUser();
    await loadForCurrentUser();
    await _enqueueProfilePersist();
  }

  Future<void> clearAuthSession({bool releaseDeviceLock = false}) async {
    _sessionStartedAt = null;
    await _enqueueProfilePersist(releaseDeviceLock: releaseDeviceLock);
  }

  Future<void> saveEditedTexts(Map<String, String> values) async {
    _editedTexts = Map<String, String>.from(values);
    await _persistLocalState();
    unawaited(_queueProfilePersist());
  }

  Future<void> saveUpcomingTickets(List<_TicketListEntry> tickets) async {
    _upcomingTickets = List<_TicketListEntry>.from(tickets);
    await _persistLocalState();
    unawaited(_queueTicketsPersist());
  }

  void _resetInMemoryState() {
    _TransferInboxStore.clearInMemory();
    _editedTexts = <String, String>{};
    _upcomingTickets = <_TicketListEntry>[];
    _sessionStartedAt = null;
  }

  void _applySnapshot(_LocalTicketmasterSnapshot snapshot) {
    _TransferInboxStore.clearInMemory();
    _editedTexts = Map<String, String>.from(snapshot.editedTexts);
    _upcomingTickets = List<_TicketListEntry>.from(snapshot.upcomingTickets);
    _sessionStartedAt = snapshot.sessionStartedAt;
  }

  Future<TicketmasterDeviceInfo> _ensureDeviceInfo() async {
    final cachedInfo = _deviceInfo;
    if (cachedInfo != null) {
      return cachedInfo;
    }

    final resolvedInfo = await TicketmasterDeviceIdentity.current();
    _deviceInfo = resolvedInfo;
    return resolvedInfo;
  }

  Future<_TicketmasterDeviceAccessCheck> _checkDeviceAccessForUser(
    String uid,
  ) async {
    final deviceInfo = await _ensureDeviceInfo();
    try {
      final snapshot = await _profileDocument(uid).get();
      final data = snapshot.data();
      final activeDeviceKey = data?['activeDeviceKey'];
      if (activeDeviceKey is! String || activeDeviceKey.isEmpty) {
        return const _TicketmasterDeviceAccessCheck.allowed();
      }
      if (activeDeviceKey == deviceInfo.deviceKey) {
        return const _TicketmasterDeviceAccessCheck.allowed();
      }

      final startedAt = _readSessionStartedAt(data?['sessionStartedAt']);
      if (startedAt == null ||
          DateTime.now().difference(startedAt) >= sessionDuration) {
        return const _TicketmasterDeviceAccessCheck.allowed();
      }

      final deviceLabel = data?['activeDeviceLabel'];
      return _TicketmasterDeviceAccessCheck.denied(
        deviceLabel: deviceLabel is String ? deviceLabel : null,
      );
    } catch (_) {
      return const _TicketmasterDeviceAccessCheck.allowed();
    }
  }

  Future<void> _claimCurrentDeviceForCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final deviceInfo = await _ensureDeviceInfo();
    final now = DateTime.now();
    final profileRef = _profileDocument(currentUser.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(profileRef);
      final data = snapshot.data();
      final activeDeviceKey = data?['activeDeviceKey'];
      final startedAt = _readSessionStartedAt(data?['sessionStartedAt']);
      final isLockedToOtherDevice =
          activeDeviceKey is String &&
          activeDeviceKey.isNotEmpty &&
          activeDeviceKey != deviceInfo.deviceKey &&
          startedAt != null &&
          now.difference(startedAt) < sessionDuration;

      if (isLockedToOtherDevice) {
        final deviceLabel = data?['activeDeviceLabel'];
        throw _TicketmasterSingleDeviceException(
          deviceLabel: deviceLabel is String ? deviceLabel : null,
        );
      }

      transaction.set(profileRef, <String, dynamic>{
        'activeDeviceKey': deviceInfo.deviceKey,
        'activeDeviceLabel': deviceInfo.deviceLabel,
        'sessionStartedAt': Timestamp.fromDate(now),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    _sessionStartedAt = now;
  }

  Future<void> _enqueueProfilePersist({bool releaseDeviceLock = false}) {
    return _persistLocalState().then((_) {
      return _queueProfilePersist(releaseDeviceLock: releaseDeviceLock);
    });
  }

  Future<void> _queueProfilePersist({bool releaseDeviceLock = false}) {
    _pendingWrite = _pendingWrite.catchError((_) {}).then((_) async {
      await _persistProfileState(releaseDeviceLock: releaseDeviceLock);
    });
    return _pendingWrite;
  }

  Future<void> _queueTicketsPersist() {
    _pendingWrite = _pendingWrite.catchError((_) {}).then((_) async {
      await _persistTicketsState();
    });
    return _pendingWrite;
  }

  _LocalTicketmasterSnapshot? _mergeSnapshots({
    required _LocalTicketmasterSnapshot? localSnapshot,
    required _LocalTicketmasterSnapshot remoteSnapshot,
  }) {
    if (localSnapshot == null) {
      return remoteSnapshot.hasMeaningfulData ? remoteSnapshot : null;
    }
    if (!remoteSnapshot.hasMeaningfulData) {
      return localSnapshot;
    }

    final preferRemote = _shouldApplyRemoteSnapshot(
      localSnapshot,
      remoteSnapshot,
    );
    final mergedEditedTexts = <String, String>{
      ...(preferRemote
          ? localSnapshot.editedTexts
          : remoteSnapshot.editedTexts),
      ...(preferRemote
          ? remoteSnapshot.editedTexts
          : localSnapshot.editedTexts),
    };

    return _LocalTicketmasterSnapshot(
      editedTexts: mergedEditedTexts,
      upcomingTickets: _mergeTickets(
        localTickets: localSnapshot.upcomingTickets,
        remoteTickets: remoteSnapshot.upcomingTickets,
        preferRemote: preferRemote,
      ),
      sessionStartedAt: preferRemote
          ? (remoteSnapshot.sessionStartedAt ?? localSnapshot.sessionStartedAt)
          : (localSnapshot.sessionStartedAt ?? remoteSnapshot.sessionStartedAt),
      updatedAt: _latestSnapshotTimestamp(
        localSnapshot.updatedAt,
        remoteSnapshot.updatedAt,
      ),
    );
  }

  List<_TicketListEntry> _mergeTickets({
    required List<_TicketListEntry> localTickets,
    required List<_TicketListEntry> remoteTickets,
    required bool preferRemote,
  }) {
    if (localTickets.isEmpty) {
      return List<_TicketListEntry>.from(remoteTickets);
    }
    if (remoteTickets.isEmpty) {
      return List<_TicketListEntry>.from(localTickets);
    }

    final localById = <int, _TicketListEntry>{
      for (final ticket in localTickets) ticket.id: ticket,
    };
    final remoteById = <int, _TicketListEntry>{
      for (final ticket in remoteTickets) ticket.id: ticket,
    };
    final allIds = <int>{...localById.keys, ...remoteById.keys}.toList()
      ..sort();

    return allIds
        .map((ticketId) {
          final localTicket = localById[ticketId];
          final remoteTicket = remoteById[ticketId];
          if (localTicket == null) {
            return remoteTicket!;
          }
          if (remoteTicket == null) {
            return localTicket;
          }

          final primaryTicket = preferRemote ? remoteTicket : localTicket;
          final secondaryTicket = preferRemote ? localTicket : remoteTicket;
          return _TicketListEntry(
            id: primaryTicket.id,
            displayTitle: primaryTicket.displayTitle,
            displayVenue: primaryTicket.displayVenue,
            displayDateLabel: primaryTicket.displayDateLabel,
            searchKeywords: primaryTicket.searchKeywords,
            ticketCount: primaryTicket.ticketCount,
            imageSelection:
                primaryTicket.imageSelection ?? secondaryTicket.imageSelection,
          );
        })
        .toList(growable: false);
  }

  DateTime? _latestSnapshotTimestamp(DateTime? left, DateTime? right) {
    if (left == null) {
      return right;
    }
    if (right == null) {
      return left;
    }
    return left.isAfter(right) ? left : right;
  }

  DocumentReference<Map<String, dynamic>> _profileDocument(String uid) {
    return _firestore.collection('ticketmaster_user_state').doc(uid);
  }

  CollectionReference<Map<String, dynamic>> _ticketsCollection(String uid) {
    return _profileDocument(uid).collection('tickets');
  }

  String _ticketImagePath(String uid, int ticketId) {
    return 'ticketmaster_user_state/$uid/tickets/ticket_$ticketId.bin';
  }

  Future<void> _persistProfileState({bool releaseDeviceLock = false}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    try {
      final deviceInfo = await _ensureDeviceInfo();
      final payload = <String, dynamic>{
        'editedTexts': _editedTexts,
        'sessionStartedAt': _sessionStartedAt == null
            ? null
            : Timestamp.fromDate(_sessionStartedAt!),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (releaseDeviceLock) {
        payload['activeDeviceKey'] = null;
        payload['activeDeviceLabel'] = null;
      } else if (_sessionStartedAt != null) {
        payload['activeDeviceKey'] = deviceInfo.deviceKey;
        payload['activeDeviceLabel'] = deviceInfo.deviceLabel;
      }

      await _profileDocument(
        currentUser.uid,
      ).set(payload, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _persistTicketsState() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final uid = currentUser.uid;
    final ticketsCollection = _ticketsCollection(uid);

    try {
      final existingSnapshot = await ticketsCollection.get();
      final existingIds = existingSnapshot.docs
          .map((doc) => int.tryParse(doc.id))
          .whereType<int>()
          .toSet();
      final nextIds = _upcomingTickets.map((ticket) => ticket.id).toSet();

      for (final ticket in _upcomingTickets) {
        final imagePath = _ticketImagePath(uid, ticket.id);
        final selection = ticket.imageSelection;

        if (selection != null) {
          await _storage
              .ref(imagePath)
              .putData(
                selection.imageBytes,
                SettableMetadata(contentType: 'application/octet-stream'),
              );
        } else {
          try {
            await _storage.ref(imagePath).delete();
          } catch (_) {}
        }

        await ticketsCollection.doc('${ticket.id}').set(<String, dynamic>{
          'id': ticket.id,
          'displayTitle': ticket.displayTitle,
          'displayVenue': ticket.displayVenue,
          'displayDateLabel': ticket.displayDateLabel,
          'searchKeywords': ticket.searchKeywords,
          'ticketCount': ticket.ticketCount,
          'imagePath': selection == null ? null : imagePath,
          'imageWidth': selection?.imageWidth,
          'imageHeight': selection?.imageHeight,
          'cropRect': selection == null
              ? null
              : <String, dynamic>{
                  'left': selection.cropRect.left,
                  'top': selection.cropRect.top,
                  'width': selection.cropRect.width,
                  'height': selection.cropRect.height,
                },
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      for (final removedId in existingIds.difference(nextIds)) {
        await ticketsCollection.doc('$removedId').delete();
        try {
          await _storage.ref(_ticketImagePath(uid, removedId)).delete();
        } catch (_) {}
      }

      await _profileDocument(uid).set(<String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<List<_TicketListEntry>> _loadTicketsForUser(String uid) async {
    try {
      final snapshot = await _ticketsCollection(uid).orderBy('id').get();
      final tickets = await Future.wait(
        snapshot.docs.map((doc) => _restoreTicket(uid, doc)),
      );
      return tickets;
    } catch (_) {
      return <_TicketListEntry>[];
    }
  }

  Future<_TicketListEntry> _restoreTicket(
    String uid,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();
    final rawId = data['id'];
    final rawImagePath = data['imagePath'];
    final rawCropRect = data['cropRect'];

    TicketCardImageSelection? imageSelection;
    if (rawImagePath is String && rawCropRect is Map) {
      imageSelection = await _restoreTicketImageSelection(
        uid: uid,
        ticketId: rawId is num ? rawId.toInt() : int.tryParse(doc.id) ?? 0,
        imagePath: rawImagePath,
        rawCropRect: rawCropRect,
        rawImageWidth: data['imageWidth'],
        rawImageHeight: data['imageHeight'],
      );
    }

    return _TicketListEntry(
      id: rawId is int ? rawId : (rawId is num ? rawId.toInt() : 1),
      displayTitle: data['displayTitle'] is String
          ? data['displayTitle'] as String
          : _MyTicketsScreenState._defaultTicketTitle,
      displayVenue: data['displayVenue'] is String
          ? data['displayVenue'] as String
          : _MyTicketsScreenState._defaultTicketVenue,
      displayDateLabel: data['displayDateLabel'] is String
          ? data['displayDateLabel'] as String
          : _MyTicketsScreenState._defaultTicketDate,
      searchKeywords: data['searchKeywords'] is String
          ? data['searchKeywords'] as String
          : 'ticket',
      ticketCount: data['ticketCount'] is int
          ? data['ticketCount'] as int
          : (data['ticketCount'] is num
                ? (data['ticketCount'] as num).toInt()
                : 1),
      imageSelection: imageSelection,
    );
  }

  Future<TicketCardImageSelection?> _restoreTicketImageSelection({
    required String uid,
    required int ticketId,
    required String imagePath,
    required Map rawCropRect,
    required Object? rawImageWidth,
    required Object? rawImageHeight,
  }) async {
    try {
      final bytes = await _storage.ref(imagePath).getData(6 * 1024 * 1024);
      if (bytes == null) {
        return null;
      }

      return TicketCardImageSelection(
        imageBytes: bytes,
        imageWidth: _toDouble(rawImageWidth, fallback: 1),
        imageHeight: _toDouble(rawImageHeight, fallback: 1),
        cropRect: Rect.fromLTWH(
          _toDouble(rawCropRect['left']),
          _toDouble(rawCropRect['top']),
          _toDouble(rawCropRect['width'], fallback: 1),
          _toDouble(rawCropRect['height'], fallback: 1),
        ),
      );
    } catch (_) {
      try {
        final fallbackBytes = await _storage
            .ref(_ticketImagePath(uid, ticketId))
            .getData(6 * 1024 * 1024);
        if (fallbackBytes == null) {
          return null;
        }
        return TicketCardImageSelection(
          imageBytes: fallbackBytes,
          imageWidth: _toDouble(rawImageWidth, fallback: 1),
          imageHeight: _toDouble(rawImageHeight, fallback: 1),
          cropRect: Rect.fromLTWH(
            _toDouble(rawCropRect['left']),
            _toDouble(rawCropRect['top']),
            _toDouble(rawCropRect['width'], fallback: 1),
            _toDouble(rawCropRect['height'], fallback: 1),
          ),
        );
      } catch (_) {
        return null;
      }
    }
  }

  Map<String, String> _readEditedTexts(Object? raw) {
    if (raw is! Map) {
      return <String, String>{};
    }

    final values = <String, String>{};
    raw.forEach((key, value) {
      if (key is String && value is String) {
        values[key] = value;
      }
    });
    return values;
  }

  DateTime? _readSessionStartedAt(Object? raw) {
    if (raw is Timestamp) {
      return raw.toDate();
    }
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  DateTime? _readSnapshotUpdatedAt(Object? raw) {
    if (raw is Timestamp) {
      return raw.toDate();
    }
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  bool _shouldApplyRemoteSnapshot(
    _LocalTicketmasterSnapshot? localSnapshot,
    _LocalTicketmasterSnapshot remoteSnapshot,
  ) {
    if (!remoteSnapshot.hasMeaningfulData) {
      return false;
    }
    if (localSnapshot == null || !localSnapshot.hasMeaningfulData) {
      return true;
    }

    final localUpdatedAt = localSnapshot.updatedAt;
    final remoteUpdatedAt = remoteSnapshot.updatedAt;
    if (localUpdatedAt == null) {
      return true;
    }
    if (remoteUpdatedAt == null) {
      return false;
    }
    return !localUpdatedAt.isAfter(remoteUpdatedAt);
  }

  Future<void> _persistLocalState() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final localFile = await _localStateFile(currentUser.uid);
    if (localFile == null) {
      return;
    }

    final snapshot = _LocalTicketmasterSnapshot(
      editedTexts: _editedTexts,
      upcomingTickets: _upcomingTickets,
      sessionStartedAt: _sessionStartedAt,
      updatedAt: DateTime.now(),
    );

    try {
      await localFile.parent.create(recursive: true);
      await localFile.writeAsString(jsonEncode(snapshot.toJson()));
    } catch (_) {}
  }

  Future<_LocalTicketmasterSnapshot?> _loadLocalSnapshotForUser(
    String uid,
  ) async {
    final localFile = await _localStateFile(uid);
    if (localFile == null || !await localFile.exists()) {
      return null;
    }

    try {
      final raw = await localFile.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return _LocalTicketmasterSnapshot.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<File?> _localStateFile(String uid) async {
    final deviceInfo = await _ensureDeviceInfo();
    final storageDirectoryPath = deviceInfo.storageDirectoryPath.trim();
    if (storageDirectoryPath.isEmpty) {
      return null;
    }

    final safeUserId = uid.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
    final directory = Directory(
      '$storageDirectoryPath${Platform.pathSeparator}ticketmaster_state',
    );
    return File('${directory.path}${Platform.pathSeparator}$safeUserId.json');
  }

  double _toDouble(Object? raw, {double fallback = 0}) {
    if (raw is num) {
      return raw.toDouble();
    }
    return fallback;
  }
}

class _LocalTicketmasterSnapshot {
  const _LocalTicketmasterSnapshot({
    required this.editedTexts,
    required this.upcomingTickets,
    this.sessionStartedAt,
    this.updatedAt,
  });

  final Map<String, String> editedTexts;
  final List<_TicketListEntry> upcomingTickets;
  final DateTime? sessionStartedAt;
  final DateTime? updatedAt;

  bool get hasMeaningfulData =>
      editedTexts.isNotEmpty ||
      upcomingTickets.isNotEmpty ||
      sessionStartedAt != null;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'editedTexts': editedTexts,
      'sessionStartedAt': sessionStartedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'upcomingTickets': upcomingTickets
          .map(
            (_TicketListEntry ticket) => <String, dynamic>{
              'id': ticket.id,
              'displayTitle': ticket.displayTitle,
              'displayVenue': ticket.displayVenue,
              'displayDateLabel': ticket.displayDateLabel,
              'searchKeywords': ticket.searchKeywords,
              'ticketCount': ticket.ticketCount,
              'imageSelection': ticket.imageSelection == null
                  ? null
                  : <String, dynamic>{
                      'imageBytes': base64Encode(
                        ticket.imageSelection!.imageBytes,
                      ),
                      'imageWidth': ticket.imageSelection!.imageWidth,
                      'imageHeight': ticket.imageSelection!.imageHeight,
                      'cropRect': <String, dynamic>{
                        'left': ticket.imageSelection!.cropRect.left,
                        'top': ticket.imageSelection!.cropRect.top,
                        'width': ticket.imageSelection!.cropRect.width,
                        'height': ticket.imageSelection!.cropRect.height,
                      },
                    },
            },
          )
          .toList(growable: false),
    };
  }

  static _LocalTicketmasterSnapshot fromJson(Map<String, dynamic> json) {
    final rawEditedTexts = json['editedTexts'];
    final rawTickets = json['upcomingTickets'];

    final editedTexts = <String, String>{};
    if (rawEditedTexts is Map) {
      rawEditedTexts.forEach((key, value) {
        if (key is String && value is String) {
          editedTexts[key] = value;
        }
      });
    }

    final upcomingTickets = <_TicketListEntry>[];
    if (rawTickets is List) {
      for (final rawTicket in rawTickets) {
        if (rawTicket is! Map) {
          continue;
        }
        final rawImageSelection = rawTicket['imageSelection'];
        TicketCardImageSelection? imageSelection;
        if (rawImageSelection is Map) {
          final rawCropRect = rawImageSelection['cropRect'];
          final rawImageBytes = rawImageSelection['imageBytes'];
          if (rawCropRect is Map && rawImageBytes is String) {
            try {
              imageSelection = TicketCardImageSelection(
                imageBytes: base64Decode(rawImageBytes),
                imageWidth: _readNumValue(
                  rawImageSelection['imageWidth'],
                  fallback: 1,
                ),
                imageHeight: _readNumValue(
                  rawImageSelection['imageHeight'],
                  fallback: 1,
                ),
                cropRect: Rect.fromLTWH(
                  _readNumValue(rawCropRect['left']),
                  _readNumValue(rawCropRect['top']),
                  _readNumValue(rawCropRect['width'], fallback: 1),
                  _readNumValue(rawCropRect['height'], fallback: 1),
                ),
              );
            } catch (_) {
              imageSelection = null;
            }
          }
        }

        final rawId = rawTicket['id'];
        upcomingTickets.add(
          _TicketListEntry(
            id: rawId is int ? rawId : (rawId is num ? rawId.toInt() : 1),
            displayTitle: rawTicket['displayTitle'] is String
                ? rawTicket['displayTitle'] as String
                : _MyTicketsScreenState._defaultTicketTitle,
            displayVenue: rawTicket['displayVenue'] is String
                ? rawTicket['displayVenue'] as String
                : _MyTicketsScreenState._defaultTicketVenue,
            displayDateLabel: rawTicket['displayDateLabel'] is String
                ? rawTicket['displayDateLabel'] as String
                : _MyTicketsScreenState._defaultTicketDate,
            searchKeywords: rawTicket['searchKeywords'] is String
                ? rawTicket['searchKeywords'] as String
                : 'ticket',
            ticketCount: rawTicket['ticketCount'] is int
                ? rawTicket['ticketCount'] as int
                : (rawTicket['ticketCount'] is num
                      ? (rawTicket['ticketCount'] as num).toInt()
                      : 1),
            imageSelection: imageSelection,
          ),
        );
      }
    }

    return _LocalTicketmasterSnapshot(
      editedTexts: editedTexts,
      upcomingTickets: upcomingTickets,
      sessionStartedAt: _readDateValue(json['sessionStartedAt']),
      updatedAt: _readDateValue(json['updatedAt']),
    );
  }

  static double _readNumValue(Object? raw, {double fallback = 0}) {
    if (raw is num) {
      return raw.toDouble();
    }
    return fallback;
  }

  static DateTime? _readDateValue(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}

enum _AuthorizationStatus { authorized, unauthorized, unknown }

class _TicketmasterDeviceAccessCheck {
  const _TicketmasterDeviceAccessCheck._({
    required this.isAllowed,
    this.deviceLabel,
  });

  const _TicketmasterDeviceAccessCheck.allowed() : this._(isAllowed: true);

  const _TicketmasterDeviceAccessCheck.denied({String? deviceLabel})
    : this._(isAllowed: false, deviceLabel: deviceLabel);

  final bool isAllowed;
  final String? deviceLabel;
}

class _TicketmasterSingleDeviceException implements Exception {
  const _TicketmasterSingleDeviceException({this.deviceLabel});

  final String? deviceLabel;

  String get message {
    final trimmedLabel = deviceLabel?.trim();
    if (trimmedLabel != null && trimmedLabel.isNotEmpty) {
      return 'This account is already active on $trimmedLabel.';
    }
    return 'This account is already active on another device.';
  }
}
