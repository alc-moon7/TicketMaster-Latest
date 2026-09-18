// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ticketmaster/main.dart';

void main() {
  testWidgets('Bottom navigation renders with Discover tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TicketmasterHomeShell()));

    final bottomNav = find.byType(BottomNavigationBar);
    expect(bottomNav, findsOneWidget);

    expect(find.text('Discover'), findsOneWidget);
    expect(
      find.descendant(of: bottomNav, matching: find.text('For You')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: bottomNav, matching: find.text('My Tickets')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: bottomNav, matching: find.text('Sell')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: bottomNav, matching: find.text('My Account')),
      findsOneWidget,
    );
  });
}
