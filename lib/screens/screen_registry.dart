import '../theme/tm_tokens.dart';

class ScreenSpec {
  const ScreenSpec({
    required this.name,
    required this.widgetClass,
    required this.sourceFile,
    required this.referenceAssets,
    this.notes = '',
  });

  final String name;
  final String widgetClass;
  final String sourceFile;
  final List<String> referenceAssets;
  final String notes;
}

class ScreenRegistry {
  static const List<ScreenSpec> screens = [
    ScreenSpec(
      name: 'Splash',
      widgetClass: 'TicketmasterSplash',
      sourceFile: 'lib/app/app_core.dart',
      referenceAssets: [TmAssets.splashLogo],
      notes: 'No XML layouts in APK; Flutter splash is animated in Dart.',
    ),
    ScreenSpec(
      name: 'Discover',
      widgetClass: 'DiscoverScreen',
      sourceFile: 'lib/app/home_shell.dart',
      referenceAssets: [
        TmAssets.brandLogo,
        TmAssets.flag,
        TmAssets.locationIcon,
        TmAssets.dateIcon,
        TmAssets.searchIcon,
        TmAssets.discoverHero,
        TmAssets.discoverPerson,
        TmAssets.discoverReference,
      ],
      notes:
          'Dark Spain discovery layout; reference photos are locally cropped.',
    ),
    ScreenSpec(
      name: 'Watchlist',
      widgetClass: 'ForYouScreen',
      sourceFile: 'lib/app/home_shell.dart',
      referenceAssets: [TmAssets.forYouEmpty],
      notes: 'Reference Watchlist empty state with Events/Favourites segments.',
    ),
    ScreenSpec(
      name: 'My Tickets',
      widgetClass: 'MyTicketsScreen',
      sourceFile: 'lib/app/home_shell.dart',
      referenceAssets: [TmAssets.flag, TmAssets.ticketsSelectedReference],
      notes: 'Ticket cards and counts are server-driven.',
    ),
    ScreenSpec(
      name: 'Sell',
      widgetClass: 'SellScreen',
      sourceFile: 'lib/app/home_shell.dart',
      referenceAssets: [TmAssets.sellHero],
      notes:
          'Legacy screen retained in source but absent from bottom navigation.',
    ),
    ScreenSpec(
      name: 'Account',
      widgetClass: 'AccountScreen',
      sourceFile: 'lib/app/home_shell.dart',
      referenceAssets: [],
      notes: 'Reference profile/settings UI with Firebase identity and logout.',
    ),
  ];
}
