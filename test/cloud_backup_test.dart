import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
// Existing Firebase test transports keep this test off live accounts/services.
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:ticketmaster/main.dart' as app;

import 'my_tickets_test.dart' show initializeTicketTestFirebase, widgetNamed;

class _User extends Fake
    with MockPlatformInterfaceMixin
    implements UserPlatform {
  @override
  String get uid => 'backup-test-user';
  @override
  String get displayName => 'Backup Test';
  @override
  String get email => 'backup@example.test';
  @override
  Future<String?> getIdToken(bool forceRefresh) async => 'test-token';
}

class _Auth extends FirebaseAuthPlatform {
  _Auth() : super(appInstance: Firebase.app());
  @override
  UserPlatform? currentUser = _User();
  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) => this;
  @override
  FirebaseAuthPlatform setInitialValues({
    InternalUserDetails? currentUser,
    String? languageCode,
  }) =>
      this;
}

class _Headers extends Fake implements HttpHeaders {
  @override
  ContentType? contentType;
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _Response extends Stream<List<int>> implements HttpClientResponse {
  _Response(this.statusCode, this.bytes);
  @override
  final int statusCode;
  final List<int> bytes;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      Stream.value(bytes).listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transport extends HttpOverrides {
  bool fail = true;
  final List<(String, String, List<int>)> requests = [];
  Map<String, dynamic> texts = {};
  @override
  HttpClient createHttpClient(SecurityContext? context) => _Client(this);
}

class _Client extends Fake implements HttpClient {
  _Client(this.transport);
  final _Transport transport;
  @override
  Duration? connectionTimeout;
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _Request(transport, method, url.path);
}

class _Request extends Fake implements HttpClientRequest {
  _Request(this.transport, this.method, this.path);
  final _Transport transport;
  @override
  final String method;
  final String path;
  final List<int> bytes = [];
  @override
  final HttpHeaders headers = _Headers();
  @override
  int contentLength = 0;
  @override
  void add(List<int> data) => bytes.addAll(data);
  @override
  Future<HttpClientResponse> close() async {
    transport.requests.add((method, path, List.from(bytes)));
    if (transport.fail) {
      return _Response(503, utf8.encode('{"error":"offline"}'));
    }
    if (path.endsWith('/texts')) {
      transport.texts = jsonDecode(utf8.decode(bytes))['editedTexts'];
    }
    return _Response(200, utf8.encode('{"ok":true}'));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeTicketTestFirebase);

  testWidgets('Account settings survive failed backup and automatically retry',
      (tester) async {
    final transport = _Transport();
    await HttpOverrides.runWithHttpOverrides(() async {
      final auth = _Auth();
      FirebaseAuthPlatform.instance = auth;
      final directory = await tester
          .runAsync(() => Directory.systemTemp.createTemp('backup-test-'));
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const identity = MethodChannel('ticketmaster/device_identity');
      messenger.setMockMethodCallHandler(
          identity,
          (_) async => {
                'deviceKey': 'test-device',
                'deviceLabel': 'Test device',
                'storageDirectoryPath': directory!.path,
              });
      addTearDown(() async {
        auth.currentUser = null;
        messenger.setMockMethodCallHandler(identity, null);
        await directory!.delete(recursive: true);
      });

      Future<void> ioSettles() async {
        for (var i = 0; i < 16; i++) {
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 20)));
          await tester.pump();
        }
        await tester.pumpAndSettle();
      }

      Future<void> account() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
            const MaterialApp(home: Scaffold(body: app.AccountScreen())));
        await tester.pumpAndSettle();
      }

      await account();
      final switchFinder = widgetNamed('_ReferenceSwitch').first;
      await tester.ensureVisible(switchFinder);
      await tester.pumpAndSettle();
      await tester.tap(switchFinder);
      await tester.pump(const Duration(milliseconds: 350));
      await ioSettles();
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await tester.pumpAndSettle();
      expect(transport.requests, isNotEmpty);
      expect(find.textContaining('Backup will retry'), findsOneWidget);
      final local =
          File('${directory!.path}/ticketmaster_state/backup-test-user.json');
      final snapshot = await tester
          .runAsync(() async => jsonDecode(await local.readAsString()));
      expect(
          snapshot['editedTexts']['account-setting-location-content'], 'false');
      await account();
      final knob = find.descendant(
          of: switchFinder, matching: find.byType(AnimatedContainer));
      expect(tester.widget<AnimatedContainer>(knob).alignment,
          Alignment.centerLeft);

      transport.fail = false;
      await tester.pump(const Duration(seconds: 11));
      await ioSettles();
      expect(find.text('All changes saved'), findsOneWidget);
      expect(transport.texts['account-setting-location-content'], 'false');

      await tester.ensureVisible(switchFinder);
      await tester.pumpAndSettle();
      await tester.tap(switchFinder);
      await tester.pump(const Duration(milliseconds: 350));
      await ioSettles();
      expect(transport.texts['account-setting-location-content'], 'true');
      await account();
      expect(tester.widget<AnimatedContainer>(knob).alignment,
          Alignment.centerRight);

      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }, transport);
  });
}
