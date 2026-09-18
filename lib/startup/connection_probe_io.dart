import 'dart:async';
import 'dart:io';

import 'connection_probe.dart';

StartupConnectionProbe createStartupConnectionProbe() =>
    _IoStartupConnectionProbe();

class _IoStartupConnectionProbe implements StartupConnectionProbe {
  _IoStartupConnectionProbe() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_emitStatus());
    });
    unawaited(_emitStatus());
  }

  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();
  Timer? _pollTimer;
  bool? _lastStatus;

  @override
  Stream<bool> get onStatusChanged => _statusController.stream;

  @override
  Future<bool> hasConnection() async {
    try {
      final lookup = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 2));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  Future<void> _emitStatus() async {
    final isOnline = await hasConnection();
    if (_statusController.isClosed || _lastStatus == isOnline) {
      return;
    }
    _lastStatus = isOnline;
    _statusController.add(isOnline);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _statusController.close();
  }
}
