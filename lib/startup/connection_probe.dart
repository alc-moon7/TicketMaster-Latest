import 'dart:async';

abstract class StartupConnectionProbe {
  Future<bool> hasConnection();

  Stream<bool> get onStatusChanged;

  void dispose();
}
