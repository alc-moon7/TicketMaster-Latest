import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketmaster/main.dart';

import 'my_tickets_test.dart' show initializeTicketTestFirebase;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeTicketTestFirebase);

  testWidgets('Current bottom navigation opens My Tickets', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TicketmasterHomeShell()));
    await tester.pump();
    final bottomNav = find.byWidgetPredicate((widget) =>
        widget.runtimeType.toString() == '_ReferenceBottomNavigation');
    for (final label in ['Home', 'Watchlist', 'My Tickets', 'Account']) {
      expect(find.descendant(of: bottomNav, matching: find.text(label)),
          findsOneWidget);
    }
    await tester
        .tap(find.descendant(of: bottomNav, matching: find.text('My Tickets')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('my-events-title')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
