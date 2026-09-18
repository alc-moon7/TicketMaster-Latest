import 'package:firebase_core/firebase_core.dart';
// Firebase's test transport avoids live account, storage, and network access.
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketmaster/main.dart' as app;

class _FirebaseTestHost extends MockFirebaseApp {
  @override
  Future<List<CoreInitializeResponse>> initializeCore() async => [
        CoreInitializeResponse(
          name: '[DEFAULT]',
          options: CoreFirebaseOptions(
            apiKey: 'test',
            appId: 'test',
            messagingSenderId: 'test',
            projectId: 'ticket-ui-test',
            storageBucket: 'ticket-ui-test.appspot.com',
          ),
          pluginConstants: {},
        ),
      ];
}

Finder widgetNamed(String name) =>
    find.byWidgetPredicate((widget) => widget.runtimeType.toString() == name);

Future<void> initializeTicketTestFirebase() async {
  TestFirebaseCoreHostApi.setUp(_FirebaseTestHost());
  await Firebase.initializeApp();
}

Future<void> openTickets(WidgetTester tester, Size size,
    {double textScale = 1}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(fontFamily: 'Metropolis'),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: const Scaffold(body: app.MyTicketsScreen()),
  ));
  await tester.pumpAndSettle();
  final populatedTab = find.textContaining(RegExp(r'^(Upcoming|Past) \(1\)$'));
  await tester.tap(populatedTab);
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await initializeTicketTestFirebase();
    for (final family in ['Metropolis', 'Roboto']) {
      await (FontLoader(family)
            ..addFont(rootBundle
                .load('assets/fonts/metropolis/Metropolis-Regular.otf')))
          .load();
    }
  });

  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(412, 915),
    const Size(430, 932),
    const Size(640, 360),
  ]) {
    testWidgets('Ticket list and routes fit $size', (tester) async {
      await openTickets(tester, size);
      expect(widgetNamed('_TicketCard'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(widgetNamed('_V2TicketArtwork').first);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(widgetNamed('_MyTicketDetailsPage'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(NestedScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Extras'));
      await tester.pumpAndSettle();
      expect(DefaultTabController.of(tester.element(find.byType(TabBar))).index,
          1);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Tickets'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('View Ticket'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(widgetNamed('_ViewTicketPage'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.text('Ticket Details').last,
        200,
        scrollable: find
            .descendant(
              of: widgetNamed('_ViewTicketFrame'),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Ticket Details').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(widgetNamed('_TicketDetailsInfoPage'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Event Information'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('Hidden card controls, editable copy, and search survive',
      (tester) async {
    await openTickets(tester, const Size(360, 640));
    await tester.longPress(find.textContaining(RegExp(r'^Upcoming \(')));
    await tester.pumpAndSettle();
    expect(find.text('Create upcoming tickets'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final artwork = widgetNamed('_V2TicketArtwork').first;
    await tester.tap(artwork);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(artwork);
    await tester.pumpAndSettle();
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    await tester.tapAt(
        tester.getTopLeft(widgetNamed('_TicketCard')) + const Offset(25, 65));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    await tester.ensureVisible(widgetNamed('_TicketCountBadge'));
    await tester.longPress(widgetNamed('_TicketCountBadge'));
    await tester.pumpAndSettle();
    expect(find.text('Set ticket quantity'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final title = find.byKey(const ValueKey('ticket-1-title')).first;
    await tester.ensureVisible(title);
    await tester.longPress(title);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.longPress(find.textContaining(RegExp(r'^Past \(')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'no matching event');
    await tester.pumpAndSettle();
    expect(find.text('No matching tickets found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Transfer selection and back preserve selected tickets on short phone',
      (tester) async {
    await openTickets(tester, const Size(320, 568));
    await tester.tap(widgetNamed('_V2TicketArtwork').first);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Transfer  ↗'));
    await tester.tap(find.text('Transfer  ↗'));
    await tester.pumpAndSettle();
    expect(find.text('Select Tickets to Transfer'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Transfer To'));
    await tester.pumpAndSettle();
    expect(find.text('Select Tickets to Transfer'), findsOneWidget);
    await tester.tap(widgetNamed('_TransferSelectableTicketTile'));
    await tester.pumpAndSettle();
    expect(find.text('1 Selected'), findsOneWidget);
    await tester.tap(find.text('Transfer To'));
    await tester.pumpAndSettle();
    expect(find.text('SELECT FROM CONTACTS'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('MANUALLY ENTER A RECIPIENT'));
    await tester.pumpAndSettle();
    expect(find.text('First name *'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Test');
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Use Mobile Number Instead'), 120,
        scrollable: find
            .descendant(
                of: widgetNamed('_TransferRecipientForm'),
                matching: find.byType(Scrollable))
            .first);
    await tester.tap(find.text('Use Mobile Number Instead'));
    await tester.pumpAndSettle();
    expect(find.text('Mobile Number *'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('1 Selected'), findsOneWidget);
  });

  testWidgets('List fits larger system text', (tester) async {
    await openTickets(tester, const Size(320, 568), textScale: 1.5);
    expect(tester.takeException(), isNull);
  });
}
