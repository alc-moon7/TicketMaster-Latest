import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketmaster/main.dart' as app;

import 'my_tickets_test.dart' show initializeTicketTestFirebase;

Finder homeArtwork() => find.byWidgetPredicate(
    (widget) => widget.runtimeType.toString() == '_EditableHomeArtwork');

Future<void> openHome(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(
    home: Scaffold(body: app.DiscoverScreen()),
  ));
  await tester.pumpAndSettle();
}

Future<void> checkTextEditor(WidgetTester tester, Finder target) async {
  await tester.longPress(target);
  await tester.pumpAndSettle();
  expect(find.text('Edit text'), findsOneWidget);
  await tester.tap(find.text('Cancel'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await initializeTicketTestFirebase();
    await (FontLoader('Metropolis')
          ..addFont(rootBundle
              .load('assets/fonts/metropolis/Metropolis-Regular.otf')))
        .load();
  });

  for (final size in [const Size(360, 800), const Size(430, 932)]) {
    testWidgets('Home editing stays available from header to City Guides $size',
        (tester) async {
      await openHome(tester, size);
      for (final key in [
        'discover-location',
        'discover-search-prefix',
        'discover-section-Top Picks',
        'discover-card-TINI-title',
        'discover-item-MEDIUM BUILD-date',
        'discover-item-MEDIUM BUILD-detail',
        'discover-trending-1-rank',
        'discover-item-LOVE SPELLS-date',
        'discover-item-LOVE SPELLS-title',
        'discover-item-LOVE SPELLS-subtitle',
        'discover-item-ALADDIN-title',
        'discover-item-THE MOTH STORYSLAM-footer',
        'discover-item-METALLICA M72 WORLD TOUR-footer',
        'discover-item-HARRY STYLES-subtitle',
        'discover-item-NEW YORK YANKEES-title',
        'discover-item-DAVE CHAPPELLE-title',
        "discover-item-BLUEY'S BIG PLAY-title",
        'discover-item-GLOBAL CITIZEN FESTIVAL-title',
        'discover-item-2 CONCERT TICKETS FOR ...-title',
        'discover-city-Barcelona-title',
      ]) {
        final target = find.byKey(ValueKey<String>(key));
        if (target.hitTestable().evaluate().isEmpty) {
          await tester.scrollUntilVisible(target, 300,
              scrollable: find.byType(Scrollable).first);
          await tester.pumpAndSettle();
        }
        await checkTextEditor(tester, target);
        expect(tester.takeException(), isNull, reason: key);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('Scrolled carousel photos and text remain editable',
      (tester) async {
    await openHome(tester, const Size(430, 932));
    for (final title in [
      'For You',
      'Trending In The United States',
      'Last Minute',
      'Popular This Weekend',
      'Just Announced',
      'Sponsored Presales',
      'Concerts',
      'Sports',
      'Arts, Theater & Comedy',
      'Family',
      'Broadway',
      'Festivals',
      'Promoted In The United States',
      'City Guides',
    ]) {
      final heading = find.text(title);
      await tester.scrollUntilVisible(heading, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      final section = find.ancestor(
          of: heading,
          matching: find.byWidgetPredicate((widget) => [
                '_HomeForYouSection',
                '_HomeTrendingSection',
                '_HomeCarouselSection',
              ].contains(widget.runtimeType.toString())));
      final carousel = find.descendant(
          of: section,
          matching: find.byWidgetPredicate((widget) =>
              widget is ListView && widget.scrollDirection == Axis.horizontal));
      await tester.ensureVisible(carousel);
      await tester.pumpAndSettle();
      final scrollable =
          find.descendant(of: carousel, matching: find.byType(Scrollable));
      final position = tester.state<ScrollableState>(scrollable).position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();
      final photo =
          find.descendant(of: carousel, matching: homeArtwork()).hitTestable();
      expect(photo, findsWidgets, reason: title);
      await tester.longPress(photo.last);
      await tester.pumpAndSettle();
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Reset image'), findsOneWidget);
      expect(find.text('Camera'), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      final texts = find
          .descendant(of: carousel, matching: find.byType(app.Text))
          .hitTestable()
          .evaluate()
          .map((element) => element.widget)
          .toList();
      expect(texts, isNotEmpty, reason: title);
      for (final text in texts) {
        await checkTextEditor(tester, find.byWidget(text));
      }
      expect(tester.takeException(), isNull, reason: title);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Search placeholder can be edited without losing tap-to-type',
      (tester) async {
    await openHome(tester, const Size(430, 932));
    final placeholder = find.byKey(const ValueKey('discover-search-venues'));
    await tester.longPress(placeholder);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Edit text'), findsOneWidget);
    final input = find.descendant(
        of: find.byType(AlertDialog), matching: find.byType(TextField));
    await tester.enterText(input, 'Places');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Places'), findsOneWidget);
    await tester.longPress(placeholder);
    await tester.pumpAndSettle();
    await tester.enterText(input, 'Venues');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('discover-search-prefix')));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
        isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Home image picker handles cancellation and malformed images',
      (tester) async {
    const channel = MethodChannel('ticketmaster/ticket_image_picker');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    Object? response;
    final sources = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      sources.add((call.arguments as Map)['source'] as String);
      return response;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await openHome(tester, const Size(430, 932));
    await tester.longPress(homeArtwork().hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('Reset image'), findsOneWidget);
    expect(find.text('Camera'), findsNothing);
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);

    response = Uint8List.fromList([1, 2, 3]);
    await tester.longPress(homeArtwork().hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('Camera'), findsNothing);
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();
    expect(sources, ['gallery', 'gallery']);
    expect(
        find.text('Unable to update image. Please try again.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
