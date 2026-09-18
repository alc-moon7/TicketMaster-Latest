// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'connection_probe.dart';

StartupConnectionProbe createStartupConnectionProbe() =>
    _WebStartupConnectionProbe();

class _WebStartupConnectionProbe implements StartupConnectionProbe {
  _WebStartupConnectionProbe() {
    _onlineSubscription = html.window.onOnline.listen((_) {
      _statusController.add(true);
    });
    _offlineSubscription = html.window.onOffline.listen((_) {
      _statusController.add(false);
    });
  }

  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();
  StreamSubscription<html.Event>? _onlineSubscription;
  StreamSubscription<html.Event>? _offlineSubscription;

  @override
  Stream<bool> get onStatusChanged => _statusController.stream;

  @override
  Future<bool> hasConnection() async => html.window.navigator.onLine ?? true;

  @override
  void dispose() {
    _onlineSubscription?.cancel();
    _offlineSubscription?.cancel();
    _statusController.close();
  }
}
