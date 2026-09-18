import 'dart:async';

import 'connection_probe.dart';

StartupConnectionProbe createStartupConnectionProbe() =>
    _StubStartupConnectionProbe();

class _StubStartupConnectionProbe implements StartupConnectionProbe {
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  @override
  Stream<bool> get onStatusChanged => _statusController.stream;

  @override
  Future<bool> hasConnection() async => true;

  @override
  void dispose() {
    _statusController.close();
  }
}
