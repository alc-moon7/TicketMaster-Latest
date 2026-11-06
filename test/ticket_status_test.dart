import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketmaster/main.dart' as app;

import 'my_tickets_test.dart'
    show initializeTicketTestFirebase, openTickets, widgetNamed;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeTicketTestFirebase);

  testWidgets('Tickets move, retain IDs, and stay deleted when reopened',
      (tester) async {
    await openTickets(tester, const Size(320, 568), textScale: 1.5);

    Future<void> reopenTickets() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: app.MyTicketsScreen()),
      ));
      await tester.pumpAndSettle();
    }

    Future<void> chooseOption(String label) async {
      await tester.longPress(widgetNamed('_V2TicketArtwork').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await chooseOption('Move to past');
    expect(find.text('Upcoming (0)'), findsOneWidget);
    expect(find.text('Past (1)'), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-1-title-past-indicator')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-1-title')), findsOneWidget);

    await reopenTickets();
    expect(find.text('No upcoming events'), findsOneWidget);
    await tester.tap(find.text('Past (1)'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.longPress(widgetNamed('_V2TicketArtwork').first);
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Move to upcoming'), findsOneWidget);
    expect(find.text('Gallery'), findsNothing);
    await tester.tap(find.text('Move to upcoming'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming (1)'), findsOneWidget);
    expect(find.text('Past (0)'), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-1-title')), findsOneWidget);

    await reopenTickets();
    expect(find.text('Upcoming (1)'), findsOneWidget);
    await chooseOption('Move to past');

    // Creating Upcoming cards must preserve the Past card and its stored ID.
    await tester.longPress(find.text('Upcoming (0)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming (1)'), findsOneWidget);
    expect(find.text('Past (1)'), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-1-title')), findsOneWidget);

    await tester.longPress(find.text('Past (1)'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ticket-2-title')), findsNothing);
    const nameQuery = '  cOlOrAdO RoCkIeS vS. sAn DiEgO pAdReS  ';
    await tester.enterText(find.byType(TextField), nameQuery);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ticket-1-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-1-title-past-indicator')),
        findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('ticket-2-title')),
      200,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    final upcomingCard = find.ancestor(
      of: find.byKey(const ValueKey('ticket-2-title')),
      matching: widgetNamed('_TicketCard'),
    );
    final upcomingArtwork = find.descendant(
      of: upcomingCard,
      matching: widgetNamed('_V2TicketArtwork'),
    );
    await tester.ensureVisible(upcomingArtwork);
    await tester.pumpAndSettle();
    await tester.longPress(upcomingArtwork);
    await tester.pumpAndSettle();
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Move to past'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
    await tester.ensureVisible(find.text('Move to past'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to past'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming (0)'), findsOneWidget);
    expect(find.text('Past (2)'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('ticket-2-title')),
      200,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(upcomingArtwork);
    await tester.pumpAndSettle();
    await tester.longPress(upcomingArtwork);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Move to upcoming'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to upcoming'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.longPress(find.text('Past (1)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), nameQuery);
    await tester.pumpAndSettle();

    await chooseOption('Delete');
    expect(find.text('Past (0)'), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-1-title')), findsNothing);
    expect(find.byKey(const ValueKey('ticket-2-title')), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no matching event');
    await tester.pumpAndSettle();
    expect(find.text('No matching tickets found'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('No past events'), findsOneWidget);
    await reopenTickets();
    expect(find.text('Upcoming (1)'), findsOneWidget);
    expect(find.text('Past (0)'), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-2-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-1-title')), findsNothing);
    Future<void> setCardCount(int count) async {
      await tester.longPress(find.textContaining(RegExp(r'^Upcoming \(')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '$count');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
    }

    await setCardCount(2);
    await setCardCount(1);
    await reopenTickets();
    expect(find.text('Upcoming (1)'), findsOneWidget);
    await setCardCount(2);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('ticket-4-title')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const ValueKey('ticket-3-title')), findsNothing);

    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
