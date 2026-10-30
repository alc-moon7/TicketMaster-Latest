part of 'package:ticketmaster/main.dart';

class _CloudflareStateApi {
  _CloudflareStateApi._();

  static final _CloudflareStateApi instance = _CloudflareStateApi._();
  static const String _baseUrl = String.fromEnvironment(
    'TICKETMASTER_API_BASE_URL',
    defaultValue: 'https://ticketmaster-user-state.muntakim-16216.workers.dev',
  );
  static const int _maxJsonResponseBytes = 2 * 1024 * 1024;
  static const int _maxImageResponseBytes = 10 * 1024 * 1024;

  final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15);

  Future<_LocalTicketmasterSnapshot?> loadState() async {
    final response = await _request('GET', '/v1/state');
    final payload = _decodeJsonObject(response.bodyBytes);
    if (payload['exists'] != true) {
      return null;
    }

    final editedTexts = <String, String>{};
    final rawEditedTexts = payload['editedTexts'];
    if (rawEditedTexts is Map) {
      rawEditedTexts.forEach((key, value) {
        if (key is String && value is String) {
          editedTexts[key] = value;
        }
      });
    }

    final tickets = <_TicketListEntry>[];
    final rawTickets = payload['tickets'];
    if (rawTickets is List) {
      for (final rawTicket in rawTickets) {
        if (rawTicket is! Map) continue;
        final data = Map<String, dynamic>.from(rawTicket);
        final id = _readInt(data['id'], fallback: tickets.length + 1);
        TicketCardImageSelection? imageSelection;
        if (data['hasImage'] == true) {
          try {
            final imageResponse = await _request(
              'GET',
              '/v1/state/tickets/$id/image',
              maxResponseBytes: _maxImageResponseBytes,
            );
            final rawCropRect = data['cropRect'];
            if (rawCropRect is Map && imageResponse.bodyBytes.isNotEmpty) {
              imageSelection = TicketCardImageSelection(
                imageBytes: imageResponse.bodyBytes,
                imageWidth: _readDouble(data['imageWidth'], fallback: 1),
                imageHeight: _readDouble(data['imageHeight'], fallback: 1),
                cropRect: Rect.fromLTWH(
                  _readDouble(rawCropRect['left']),
                  _readDouble(rawCropRect['top']),
                  _readDouble(rawCropRect['width'], fallback: 1),
                  _readDouble(rawCropRect['height'], fallback: 1),
                ),
              );
            }
          } catch (_) {
            imageSelection = null;
          }
        }

        tickets.add(
          _TicketListEntry(
            id: id,
            displayTitle: _readString(
              data['displayTitle'],
              fallback: _MyTicketsScreenState._defaultTicketTitle,
            ),
            displayVenue: _readString(
              data['displayVenue'],
              fallback: _MyTicketsScreenState._defaultTicketVenue,
            ),
            displayDateLabel: _readString(
              data['displayDateLabel'],
              fallback: _MyTicketsScreenState._defaultTicketDate,
            ),
            searchKeywords: _readString(
              data['searchKeywords'],
              fallback: 'ticket',
            ),
            ticketCount: _readInt(data['ticketCount'], fallback: 1),
            imageSelection: imageSelection,
          ),
        );
      }
    }

    final rawUpdatedAt = payload['updatedAt'];
    return _LocalTicketmasterSnapshot(
      editedTexts: editedTexts,
      upcomingTickets: tickets,
      updatedAt: rawUpdatedAt is num
          ? DateTime.fromMillisecondsSinceEpoch(rawUpdatedAt.toInt(),
                  isUtc: true)
              .toLocal()
          : null,
    );
  }

  Future<void> saveEditedTexts(Map<String, String> editedTexts) async {
    await _request(
      'PUT',
      '/v1/state/texts',
      jsonBody: <String, dynamic>{'editedTexts': editedTexts},
    );
  }

  Future<void> saveTickets(List<_TicketListEntry> tickets) async {
    for (final ticket in tickets) {
      final image = ticket.imageSelection;
      if (image == null) continue;
      await _request(
        'PUT',
        '/v1/state/tickets/${ticket.id}/image',
        bodyBytes: image.imageBytes,
        contentType: 'application/octet-stream',
      );
    }

    await _request(
      'PUT',
      '/v1/state/tickets',
      jsonBody: <String, dynamic>{
        'tickets': tickets.map(_ticketToJson).toList(growable: false),
      },
    );
  }

  Map<String, dynamic> _ticketToJson(_TicketListEntry ticket) {
    final image = ticket.imageSelection;
    return <String, dynamic>{
      'id': ticket.id,
      'displayTitle': ticket.displayTitle,
      'displayVenue': ticket.displayVenue,
      'displayDateLabel': ticket.displayDateLabel,
      'searchKeywords': ticket.searchKeywords,
      'ticketCount': ticket.ticketCount,
      'hasImage': image != null,
      'imageWidth': image?.imageWidth,
      'imageHeight': image?.imageHeight,
      'cropRect': image == null
          ? null
          : <String, dynamic>{
              'left': image.cropRect.left,
              'top': image.cropRect.top,
              'width': image.cropRect.width,
              'height': image.cropRect.height,
            },
    };
  }

  Future<_CloudflareStateResponse> _request(
    String method,
    String path, {
    Map<String, dynamic>? jsonBody,
    Uint8List? bodyBytes,
    String? contentType,
    int maxResponseBytes = _maxJsonResponseBytes,
  }) async {
    final firstResponse = await _send(
      method,
      path,
      jsonBody: jsonBody,
      bodyBytes: bodyBytes,
      contentType: contentType,
      forceRefreshToken: false,
      maxResponseBytes: maxResponseBytes,
    );
    if (firstResponse.statusCode != HttpStatus.unauthorized) {
      firstResponse.throwIfFailed();
      return firstResponse;
    }

    final refreshedResponse = await _send(
      method,
      path,
      jsonBody: jsonBody,
      bodyBytes: bodyBytes,
      contentType: contentType,
      forceRefreshToken: true,
      maxResponseBytes: maxResponseBytes,
    );
    refreshedResponse.throwIfFailed();
    return refreshedResponse;
  }

  Future<_CloudflareStateResponse> _send(
    String method,
    String path, {
    required bool forceRefreshToken,
    required int maxResponseBytes,
    Map<String, dynamic>? jsonBody,
    Uint8List? bodyBytes,
    String? contentType,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const _CloudflareStateException('No authenticated user.');
    }
    final token = await user.getIdToken(forceRefreshToken);
    if (token == null || token.isEmpty) {
      throw const _CloudflareStateException('Unable to obtain an ID token.');
    }

    final request = await _httpClient.openUrl(
      method,
      Uri.parse('$_baseUrl$path'),
    );
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');

    if (jsonBody != null) {
      final encoded = utf8.encode(jsonEncode(jsonBody));
      request.headers.contentType = ContentType.json;
      request.contentLength = encoded.length;
      request.add(encoded);
    } else if (bodyBytes != null) {
      request.headers.contentType = ContentType.parse(
        contentType ?? 'application/octet-stream',
      );
      request.contentLength = bodyBytes.length;
      request.add(bodyBytes);
    }

    final response = await request.close().timeout(const Duration(seconds: 45));
    final bytes = await _readResponseBytes(response, maxResponseBytes);
    return _CloudflareStateResponse(response.statusCode, bytes);
  }

  Future<Uint8List> _readResponseBytes(
    HttpClientResponse response,
    int maxBytes,
  ) async {
    final builder = BytesBuilder(copy: false);
    var totalBytes = 0;
    await for (final chunk in response.timeout(const Duration(seconds: 45))) {
      totalBytes += chunk.length;
      if (totalBytes > maxBytes) {
        throw const _CloudflareStateException('Cloud response is too large.');
      }
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  Map<String, dynamic> _decodeJsonObject(Uint8List bytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    throw const _CloudflareStateException('Invalid cloud response.');
  }

  int _readInt(Object? value, {required int fallback}) {
    return value is num ? value.toInt() : fallback;
  }

  double _readDouble(Object? value, {double fallback = 0}) {
    return value is num ? value.toDouble() : fallback;
  }

  String _readString(Object? value, {required String fallback}) {
    return value is String ? value : fallback;
  }
}

class _CloudflareStateResponse {
  const _CloudflareStateResponse(this.statusCode, this.bodyBytes);

  final int statusCode;
  final Uint8List bodyBytes;

  void throwIfFailed() {
    if (statusCode >= 200 && statusCode < 300) return;
    String message = 'Cloud request failed ($statusCode).';
    try {
      final decoded = jsonDecode(utf8.decode(bodyBytes));
      if (decoded is Map && decoded['error'] is String) {
        message = decoded['error'] as String;
      }
    } catch (_) {}
    throw _CloudflareStateException(message);
  }
}

class _CloudflareStateException implements Exception {
  const _CloudflareStateException(this.message);

  final String message;

  @override
  String toString() => message;
}
