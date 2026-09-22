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

  testWidgets('Home carousel View All opens a full list', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TicketmasterHomeShell()));
    await tester.pump();
    expect(find.text('For You'), findsOneWidget);
    await tester.drag(find.text('MEDIUM BUILD'), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(find.text('ROD WAVE'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -350));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View All').first);
    await tester.pumpAndSettle();
    expect(find.text('TRENDING'), findsOneWidget);
    expect(find.text('HARRY STYLES'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Location search shows matching cities below the field',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TicketmasterHomeShell()));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('discover-location')));
    await tester.pumpAndSettle();

    expect(find.text('Change Location'), findsOneWidget);
    expect(find.text('Recent Locations'), findsOneWidget);
    expect(find.text('Popular Locations'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search For Cities'),
      'lon',
    );
    await tester.pumpAndSettle();

    expect(find.text('Results'), findsOneWidget);
    expect(find.text('London'), findsWidgets);
    expect(find.text('Long Beach'), findsWidgets);

    await tester.enterText(
      find.byType(TextField).last,
      'sea',
    );
    await tester.pumpAndSettle();
    expect(find.text('Seattle'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
