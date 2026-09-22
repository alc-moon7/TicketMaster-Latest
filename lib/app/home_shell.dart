part of 'package:ticketmaster/main.dart';

class TicketmasterHomeShell extends StatefulWidget {
  const TicketmasterHomeShell({super.key});

  @override
  State<TicketmasterHomeShell> createState() => _TicketmasterHomeShellState();
}

class _TicketmasterHomeShellState extends State<TicketmasterHomeShell> {
  int _index = 0;
  int _previousIndex = 0;
  int _direction = 1;

  @override
  void initState() {
    super.initState();
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
    );
    SystemChrome.setSystemUIOverlayStyle(_ticketmasterSystemUiStyle);
  }

  void _onNavTap(int newIndex) {
    if (newIndex == _index) return;
    setState(() {
      _previousIndex = _index;
      _direction = newIndex > _index ? 1 : -1;
      _index = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const DiscoverScreen(),
      const ForYouScreen(),
      const MyTicketsScreen(),
      const AccountScreen(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _ticketmasterSystemUiStyle,
      child: Scaffold(
        body: Stack(
          children: List.generate(pages.length, (i) {
            final isActive = i == _index;
            final isOutgoing = i == _previousIndex && _previousIndex != _index;
            return _AnimatedTabView(
              isActive: isActive,
              isOutgoing: isOutgoing,
              direction: _direction,
              child: pages[i],
            );
          }),
        ),
        bottomNavigationBar: _ReferenceBottomNavigation(
          currentIndex: _index,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}

class _ReferenceBottomNavigation extends StatelessWidget {
  const _ReferenceBottomNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Watchlist', 'My Tickets', 'Account'];
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return ColoredBox(
      color: Colors.black,
      child: SizedBox(
        height: 50 + bottomInset,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Row(
            children: List.generate(labels.length, (index) {
              final selected = index == currentIndex;
              return Expanded(
                child: InkResponse(
                  onTap: () => onTap(index),
                  containedInkWell: true,
                  highlightShape: BoxShape.rectangle,
                  child: Semantics(
                    selected: selected,
                    button: true,
                    label: labels[index],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 32,
                          child: Center(
                            child: _ReferenceNavIcon(
                              index: index,
                              selected: selected,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        material.Text(
                          labels[index],
                          maxLines: 1,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF777777),
                            fontFamily: TmTypography.family,
                            fontSize: 10.5,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w400,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ReferenceNavIcon extends StatelessWidget {
  const _ReferenceNavIcon({required this.index, required this.selected});

  final int index;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final selectedColor = switch (index) {
      1 => const Color(0xFFB85BFA),
      _ => const Color(0xFF245AE5),
    };
    final color = selected ? selectedColor : Colors.white;
    switch (index) {
      case 0:
        return SizedBox(
          width: 31,
          height: 31,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 1,
                top: 2,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: selected ? selectedColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: selected
                        ? null
                        : Border.all(color: Colors.white, width: 1.4),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    TmAssets.loginMark,
                    width: 11,
                    height: 18,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
              if (selected)
                const Positioned(
                  right: 2,
                  top: 0,
                  child: Icon(Icons.star, size: 9, color: Colors.white),
                ),
            ],
          ),
        );
      case 1:
        return Icon(
          selected ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          size: 28,
          color: color,
        );
      case 2:
        return SizedBox(
          width: 34,
          height: 34,
          child: _ReferenceCropImage(
            asset: selected
                ? TmAssets.ticketsSelectedReference
                : TmAssets.discoverReference,
            source: const Rect.fromLTWH(486, 1634, 66, 62),
          ),
        );
      default:
        return Icon(Icons.account_circle_outlined, size: 30, color: color);
    }
  }
}

class _AnimatedTabView extends StatelessWidget {
  const _AnimatedTabView({
    required this.isActive,
    required this.isOutgoing,
    required this.direction,
    required this.child,
  });

  final bool isActive;
  final bool isOutgoing;
  final int direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final offset = isActive
        ? Offset.zero
        : Offset(isOutgoing ? -0.08 * direction : 0.08 * direction, 0);

    // Direction-aware fade + slide for bottom tab switching.
    return IgnorePointer(
      ignoring: !isActive,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.0,
        duration: TmDurations.tabSwitch,
        curve: TmCurves.easeOut,
        child: AnimatedSlide(
          offset: offset,
          duration: TmDurations.tabSwitch,
          curve: TmCurves.easeOut,
          child: child,
        ),
      ),
    );
  }
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static const _previousLocationLabel =
      'Santa Eulalia del Río, Balearic Islands, ES';
  _DiscoverLocation _location = _defaultDiscoverLocation;
  String? _savedLocationLabel;
  final List<_DiscoverLocation> _recentLocations = [
    _DiscoverLocation('New York', '', 'US', '🇺🇸'),
  ];

  @override
  void initState() {
    super.initState();
    final saved = _EditableTextStore.valueFor(
        'discover-location', _previousLocationLabel);
    if (saved != _previousLocationLabel) {
      _savedLocationLabel = saved;
      for (final city in _searchLocations) {
        if (city.header == saved) {
          _location = city;
          break;
        }
      }
    }
  }

  Future<void> _changeLocation() async {
    final selected = await showModalBottomSheet<_DiscoverLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => _DiscoverLocationSheet(recent: _recentLocations),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _location = selected;
      _savedLocationLabel = null;
      _recentLocations.removeWhere((city) => city == selected);
      _recentLocations.insert(0, selected);
      if (_recentLocations.length > 5) _recentLocations.removeLast();
    });
    unawaited(_EditableTextStore.save(
        'discover-location', _previousLocationLabel, selected.header));
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF101010),
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          _ReferenceDiscoverHeader(
            locationLabel: _savedLocationLabel ?? _location.header,
            onLocationTap: _changeLocation,
            showSearch: false,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 26),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 18, 14, 0),
                  child: _ReferenceDiscoverSearchPill(),
                ),
                const SizedBox(height: 32),
                const _HomeForYouSection(),
                const SizedBox(height: 32),
                const _HomeTrendingSection(),
                const SizedBox(height: 32),
                for (final section in _homeSections) ...[
                  _HomeCarouselSection(section: section),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ReferenceDiscoverHeader extends StatelessWidget {
  const _ReferenceDiscoverHeader(
      {required this.locationLabel,
      required this.onLocationTap,
      this.showSearch = true});

  final String locationLabel;
  final VoidCallback onLocationTap;
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 11, 16, 0),
      child: Column(
        children: [
          InkWell(
            onTap: onLocationTap,
            child: Row(
              children: [
                const Icon(
                  Icons.location_pin,
                  size: 20,
                  color: Color(0xFF69DED1),
                ),
                const SizedBox(width: 10),
                Flexible(
                  fit: FlexFit.loose,
                  child: material.Text(
                    locationLabel,
                    key: const ValueKey<String>('discover-location'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFF2F2F4),
                      fontFamily: TmTypography.family,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.15,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: Color(0xFFF0F0F0),
                ),
              ],
            ),
          ),
          if (showSearch) ...[
            const SizedBox(height: 18),
            const _ReferenceDiscoverSearchPill(),
          ],
        ],
      ),
    );
  }
}

class _DiscoverLocation {
  const _DiscoverLocation(this.name, this.region, this.country, this.flag);

  final String name;
  final String region;
  final String country;
  final String flag;

  String get header =>
      [name, if (region.isNotEmpty) region, country].join(', ');
  String get detail => region.isEmpty ? country : '$region, $country';
}

const _defaultDiscoverLocation =
    _DiscoverLocation('Los Angeles', 'California', 'US', '🇺🇸');

const _popularLocations = <_DiscoverLocation>[
  _DiscoverLocation('Vienna', 'Wien', 'AT', '🇦🇹'),
  _DiscoverLocation('Zürich', '', 'CH', '🇨🇭'),
  _DiscoverLocation('Dubai', 'Dubayy', 'AE', '🇦🇪'),
  _DiscoverLocation('Prague', 'Praha', 'CZ', '🇨🇿'),
  _DiscoverLocation('Toronto', 'Ontario', 'CA', '🇨🇦'),
  _DiscoverLocation('Warsaw', 'Mazowieckie', 'PL', '🇵🇱'),
  _DiscoverLocation('Madrid', '', 'ES', '🇪🇸'),
  _DiscoverLocation('New York', '', 'US', '🇺🇸'),
  _DiscoverLocation('Sydney', 'New South Wales', 'AU', '🇦🇺'),
  _DiscoverLocation('Mexico City', 'Ciudad de México', 'MX', '🇲🇽'),
  _DiscoverLocation('Copenhagen', 'Hovedstaden', 'DK', '🇩🇰'),
  _DiscoverLocation('London', '', 'UK', '🇬🇧'),
  _DiscoverLocation('Oslo', '', 'NO', '🇳🇴'),
  _DiscoverLocation('Brussels', '', 'BE', '🇧🇪'),
  _DiscoverLocation('Berlin', '', 'DE', '🇩🇪'),
  _DiscoverLocation('Auckland', '', 'NZ', '🇳🇿'),
  _DiscoverLocation('Stockholm', '', 'SE', '🇸🇪'),
  _DiscoverLocation('Seattle', 'Washington', 'US', '🇺🇸'),
  _DiscoverLocation('Helsinki', 'Uusimaa', 'FI', '🇫🇮'),
  _DiscoverLocation('Amsterdam', 'Noord-Holland', 'NL', '🇳🇱'),
  _DiscoverLocation('Dublin', '', 'IE', '🇮🇪'),
  _DiscoverLocation('Johannesburg', 'Gauteng', 'ZA', '🇿🇦'),
];

const _searchLocations = <_DiscoverLocation>[
  _defaultDiscoverLocation,
  ..._popularLocations,
  _DiscoverLocation('Long Beach', 'California', 'US', '🇺🇸'),
  _DiscoverLocation('London', 'Ontario', 'CA', '🇨🇦'),
  _DiscoverLocation('Longueuil', 'Quebec', 'CA', '🇨🇦'),
  _DiscoverLocation('Longview', 'Texas', 'US', '🇺🇸'),
  _DiscoverLocation('Longmont', 'Colorado', 'US', '🇺🇸'),
  _DiscoverLocation('Longview', 'Washington', 'US', '🇺🇸'),
  _DiscoverLocation('Long Eaton', 'Derbyshire', 'UK', '🇬🇧'),
  _DiscoverLocation('Long Beach', 'New York', 'US', '🇺🇸'),
  _DiscoverLocation('Long Branch', 'New Jersey', 'US', '🇺🇸'),
  _DiscoverLocation('Chicago', 'Illinois', 'US', '🇺🇸'),
  _DiscoverLocation('Paris', '', 'FR', '🇫🇷'),
  _DiscoverLocation('Boston', 'Massachusetts', 'US', '🇺🇸'),
];

class _DiscoverLocationSheet extends StatefulWidget {
  const _DiscoverLocationSheet({required this.recent});

  final List<_DiscoverLocation> recent;

  @override
  State<_DiscoverLocationSheet> createState() => _DiscoverLocationSheetState();
}

class _DiscoverLocationSheetState extends State<_DiscoverLocationSheet> {
  final _search = TextEditingController();
  final _focusNode = FocusNode();
  final _sheetController = DraggableScrollableController();
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_refreshFocus);
  }

  void _refreshFocus() => setState(() {});

  @override
  void dispose() {
    _search.dispose();
    _focusNode.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _expand() {
    if (_sheetController.isAttached) {
      _sheetController.animateTo(1,
          duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    }
  }

  void _searchCities() {
    _expand();
    _focusNode.requestFocus();
  }

  Future<void> _showLocationPermission() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF303030),
        icon: const Icon(Icons.location_on_outlined,
            size: 82, color: Color(0xFF2789FF)),
        title: const material.Text('Allow Location Services',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const material.Text(
            'To see events happening near you, please update your location settings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const material.Text('Maybe Later')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const material.Text('Sounds Good')),
        ],
      ),
    );
  }

  Widget _locationRow(_DiscoverLocation city) => InkWell(
        onTap: () => Navigator.of(context).pop(city),
        child: SizedBox(
          height: 38,
          child: Row(children: [
            Container(
              width: 25,
              height: 25,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF777777))),
              child: material.Text(city.flag,
                  style: const TextStyle(fontSize: 15)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: material.Text(city.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: TmTypography.family,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5)),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 138,
              child: material.Text(city.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Color(0xFFC4C4C7),
                      fontFamily: TmTypography.family,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ]),
        ),
      );

  Widget _sectionTitle(String title, {double top = 18}) => Padding(
        padding: EdgeInsets.only(top: top, bottom: 12),
        child: material.Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: TmTypography.family,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      );

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final results = query.length < 2
        ? <_DiscoverLocation>[]
        : _searchLocations
            .where((city) =>
                city.name.toLowerCase().contains(query) ||
                city.region.toLowerCase().contains(query) ||
                city.country.toLowerCase().contains(query))
            .toList()
      ..sort((a, b) {
        final aStarts = a.name.toLowerCase().startsWith(query);
        final bStarts = b.name.toLowerCase().startsWith(query);
        if (aStarts != bStarts) return aStarts ? -1 : 1;
        return a.name.compareTo(b.name);
      });
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final expanded = notification.extent > .9;
        if (expanded != _expanded) setState(() => _expanded = expanded);
        return false;
      },
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: 1,
        minChildSize: .35,
        maxChildSize: 1,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF252525),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(children: [
            GestureDetector(
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) < 0) {
                  _expand();
                } else if ((details.primaryVelocity ?? 0) > 0) {
                  Navigator.of(context).pop();
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                    top: _expanded
                        ? MediaQuery.paddingOf(context).top + 12
                        : 12),
                child: Column(children: [
                  Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                        color: const Color(0xFFA2A2A4),
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_pin, color: Colors.white, size: 23),
                        SizedBox(width: 8),
                        material.Text('Change Location',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: TmTypography.family,
                                fontSize: 17,
                                fontWeight: FontWeight.w700)),
                      ]),
                  const SizedBox(height: 21),
                ]),
              ),
            ),
            const Divider(height: 2, thickness: 2, color: Color(0xFF101010)),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(40)),
                child: Row(children: [
                  InkWell(
                    onTap: _searchCities,
                    child: Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF777777))),
                      child: const Icon(Icons.search,
                          color: Colors.white, size: 25),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _search,
                      focusNode: _focusNode,
                      onTap: _expand,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: TmTypography.family,
                          fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: _focusNode.hasFocus
                            ? 'Start Typing For Results'
                            : 'Search For Cities',
                        hintStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: TmTypography.family,
                            fontWeight: FontWeight.w700),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (query.isNotEmpty)
                    IconButton(
                      onPressed: () => setState(_search.clear),
                      icon: const Icon(Icons.close, color: Colors.white),
                    )
                  else
                    InkWell(
                      onTap: _showLocationPermission,
                      child: Container(
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                            color: Color(0xFF28E1DE), shape: BoxShape.circle),
                        child: Transform.rotate(
                          angle: math.pi / 4,
                          child: const Icon(Icons.navigation,
                              color: Colors.black),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                children: [
                  if (query.length >= 2) ...[
                    _sectionTitle('Results'),
                    if (results.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: material.Text('No locations found',
                            style: TextStyle(color: Colors.white70)),
                      ),
                    for (final city in results) _locationRow(city),
                  ] else if (query.isEmpty) ...[
                    if (widget.recent.isNotEmpty) ...[
                      _sectionTitle('Recent Locations', top: 30),
                      for (final city in widget.recent) _locationRow(city),
                    ],
                    _sectionTitle('Popular Locations'),
                    for (final city in _popularLocations) _locationRow(city),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: material.Text(
                        'Type at least 2 letters to search',
                        style: TextStyle(color: Color(0xFFC4C4C7)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _HomeArt {
  const _HomeArt(this.file, this.source);

  final String file;
  final Rect source;
}

class _HomeItem {
  const _HomeItem(this.title, this.subtitle, this.art,
      {this.date = '',
      this.detail = '',
      this.footer = '',
      this.titleKey,
      this.subtitleKey});

  final String title;
  final String subtitle;
  final _HomeArt? art;
  final String date;
  final String detail;
  final String footer;
  final String? titleKey;
  final String? subtitleKey;
}

enum _HomeSectionKind { event, presale, category, city }

class _HomeSectionData {
  const _HomeSectionData(this.title, this.kind, this.items,
      {this.viewAll = true});

  final String title;
  final _HomeSectionKind kind;
  final List<_HomeItem> items;
  final bool viewAll;
}

const _homeForYou = <_HomeItem>[
  _HomeItem('MEDIUM BUILD', 'Friday • 7:30 PM',
      _HomeArt('top.png', Rect.fromLTWH(28, 398, 450, 254)),
      date: 'OCT\n09',
      detail: 'New York, NY - Balcony Lounge',
      titleKey: 'discover-card-TINI-title',
      subtitleKey: 'discover-card-TINI-subtitle'),
  _HomeItem('WWE', 'Monday • 7:30 PM',
      _HomeArt('top.png', Rect.fromLTWH(495, 398, 225, 254)),
      date: 'NOV\n02',
      detail: 'Brooklyn, NY',
      titleKey: 'discover-card-GRACIE ABRAMS-title',
      subtitleKey: 'discover-card-GRACIE ABRAMS-subtitle'),
  _HomeItem('ROD WAVE', 'Tuesday • 8:00 PM',
      _HomeArt('for_you_next.png', Rect.fromLTWH(135, 398, 450, 254)),
      date: 'OCT\n27',
      detail: 'Brooklyn, NY - Barclays Center',
      titleKey: 'discover-card-SHAKIRA-title',
      subtitleKey: 'discover-card-SHAKIRA-subtitle'),
];

const _homeTrending = <_HomeItem>[
  _HomeItem('HARRY STYLES', 'Pop',
      _HomeArt('events.png', Rect.fromLTWH(72, 258, 135, 100))),
  _HomeItem('DON OMAR', 'Hip-Hop/Rap',
      _HomeArt('events.png', Rect.fromLTWH(72, 367, 135, 100))),
  _HomeItem('MONSTER JAM', 'Motorsports/Racing',
      _HomeArt('events.png', Rect.fromLTWH(72, 476, 135, 100))),
  _HomeItem('RUSH', 'Rock',
      _HomeArt('trending_next.png', Rect.fromLTWH(107, 876, 134, 100))),
  _HomeItem('JONAS BROTHERS', 'Pop',
      _HomeArt('trending_next.png', Rect.fromLTWH(107, 986, 134, 100))),
  _HomeItem('TEDDY SWIMS', 'Pop',
      _HomeArt('trending_next.png', Rect.fromLTWH(107, 1095, 134, 100))),
  _HomeItem('PHOEBE BRIDGERS', 'Rock',
      _HomeArt('trending_last.png', Rect.fromLTWH(140, 876, 134, 100))),
  _HomeItem('AESPA', 'Pop',
      _HomeArt('trending_last.png', Rect.fromLTWH(140, 986, 134, 100))),
  _HomeItem('MALCOLM TODD', 'Alternative',
      _HomeArt('trending_last.png', Rect.fromLTWH(140, 1095, 134, 100))),
  _HomeItem('WWE', 'Wrestling',
      _HomeArt('top.png', Rect.fromLTWH(495, 398, 225, 254))),
];

const _homeSections = <_HomeSectionData>[
  _HomeSectionData('Last Minute', _HomeSectionKind.event, [
    _HomeItem('LOVE SPELLS', '7:00 PM • Bowery Ballroom',
        _HomeArt('events.png', Rect.fromLTWH(28, 698, 297, 166)),
        date: 'Wed Sep 23'),
    _HomeItem('MADISON SQUARE GARDEN EXPERIENCE', 'Madison Square Garden',
        _HomeArt('events.png', Rect.fromLTWH(341, 698, 297, 166)),
        date: 'Mon Sep 21'),
    _HomeItem('GOVT MULE', '7:00 PM • New York, NY',
        _HomeArt('events.png', Rect.fromLTWH(654, 698, 66, 166)),
        date: 'Wed Sep 23'),
  ]),
  _HomeSectionData('Popular This Weekend', _HomeSectionKind.event, [
    _HomeItem('ALADDIN', '1:00 PM • New York, NY',
        _HomeArt('events.png', Rect.fromLTWH(28, 1083, 297, 166)),
        date: 'Sun Sep 20'),
    _HomeItem('SLAM FRANK', '2:00 PM • New York, NY',
        _HomeArt('events.png', Rect.fromLTWH(341, 1083, 297, 166)),
        date: 'Sun Sep 20'),
    _HomeItem('MAYBE HAPPY ENDING', '1:00 PM • New York, NY',
        _HomeArt('categories2.png', Rect.fromLTWH(341, 1131, 297, 166)),
        date: 'Sun Sep 20'),
  ]),
  _HomeSectionData('Just Announced', _HomeSectionKind.presale, [
    _HomeItem('THE MOTH STORYSLAM', '8:00 PM • Brooklyn, NY',
        _HomeArt('presales.png', Rect.fromLTWH(28, 428, 455, 250)),
        date: 'Tue Oct 13', footer: 'View Presales'),
    _HomeItem('GNARLS BARKLEY: TOUR', '7:00 PM • New York, NY',
        _HomeArt('presales.png', Rect.fromLTWH(498, 428, 222, 250)),
        date: 'Tue Nov 24', footer: 'View Presales'),
  ]),
  _HomeSectionData(
      'Sponsored Presales',
      _HomeSectionKind.presale,
      [
        _HomeItem('METALLICA M72 WORLD TOUR', '6:00 PM • Indianapolis • IN',
            _HomeArt('presales.png', Rect.fromLTWH(28, 967, 455, 250)),
            date: 'Sat Jun 5', footer: 'Tue, 22 Sep 2026, 10:00 AM'),
        _HomeItem('JERRY SEINFELD', '8:00 PM • Philadelphia',
            _HomeArt('presales.png', Rect.fromLTWH(498, 967, 222, 250)),
            date: 'Sat Nov 21', footer: 'Wed, 23 Sep 2026'),
      ],
      viewAll: false),
  _HomeSectionData('Concerts', _HomeSectionKind.category, [
    _HomeItem('HARRY STYLES', '18 events near you',
        _HomeArt('categories1.png', Rect.fromLTWH(28, 552, 297, 166))),
    _HomeItem('JONAS BROTHERS', '2 events near you',
        _HomeArt('categories1.png', Rect.fromLTWH(341, 552, 297, 166))),
    _HomeItem('AC/DC', '4 events near you',
        _HomeArt('bottom.png', Rect.fromLTWH(341, 952, 297, 166))),
    _HomeItem('ROD WAVE', '2 events near you',
        _HomeArt('for_you_next.png', Rect.fromLTWH(135, 398, 450, 254))),
  ]),
  _HomeSectionData('Sports', _HomeSectionKind.category, [
    _HomeItem('NEW YORK YANKEES', '273 events near you',
        _HomeArt('categories1.png', Rect.fromLTWH(28, 936, 297, 166))),
    _HomeItem('MONSTER JAM', '4 events near you',
        _HomeArt('categories1.png', Rect.fromLTWH(341, 936, 297, 166))),
    _HomeItem('LEAGUES CUP', '1 event near you', null),
  ]),
  _HomeSectionData('Arts, Theater & Comedy', _HomeSectionKind.category, [
    _HomeItem('DAVE CHAPPELLE', '2 events near you',
        _HomeArt('categories2.png', Rect.fromLTWH(28, 361, 297, 166))),
    _HomeItem('JO KOY', '1 event near you',
        _HomeArt('categories2.png', Rect.fromLTWH(341, 361, 297, 166))),
    _HomeItem('MATT RIFE', '1 event near you', null),
  ]),
  _HomeSectionData('Family', _HomeSectionKind.category, [
    _HomeItem('DISNEY ON ICE PRESENTS...', '9 events near you',
        _HomeArt('categories2.png', Rect.fromLTWH(28, 746, 297, 166))),
    _HomeItem("BLUEY'S BIG PLAY", '5 events near you',
        _HomeArt('categories2.png', Rect.fromLTWH(341, 746, 297, 166))),
    _HomeItem('DISNEY ALADDIN', '17 events near you',
        _HomeArt('categories2.png', Rect.fromLTWH(28, 1131, 297, 166))),
  ]),
  _HomeSectionData('Broadway', _HomeSectionKind.category, [
    _HomeItem('ALADDIN', '1 event near you',
        _HomeArt('categories2.png', Rect.fromLTWH(28, 1131, 297, 166))),
    _HomeItem('MAYBE HAPPY ENDING (NY)', '1 event near you',
        _HomeArt('categories2.png', Rect.fromLTWH(341, 1131, 297, 166))),
    _HomeItem('THE LION KING', '1 event near you', null),
  ]),
  _HomeSectionData('Festivals', _HomeSectionKind.category, [
    _HomeItem('GLOBAL CITIZEN FESTIVAL', '1 event near you',
        _HomeArt('bottom.png', Rect.fromLTWH(28, 566, 297, 166))),
    _HomeItem('DODGE POETRY FESTIVAL', '1 event near you',
        _HomeArt('bottom.png', Rect.fromLTWH(341, 566, 297, 166))),
    _HomeItem('UNIVERSAL FESTIVAL', '1 event near you', null),
  ]),
  _HomeSectionData(
      'Promoted In The United States',
      _HomeSectionKind.category,
      [
        _HomeItem('2 CONCERT TICKETS FOR ...', 'On Sale Now',
            _HomeArt('cityguides.png', Rect.fromLTWH(28, 608, 297, 166))),
        _HomeItem('AC/DC', 'Metal',
            _HomeArt('cityguides.png', Rect.fromLTWH(341, 608, 297, 166))),
        _HomeItem('GNARLS BARKLEY', 'Sign Up',
            _HomeArt('presales.png', Rect.fromLTWH(498, 428, 222, 250))),
      ],
      viewAll: false),
  _HomeSectionData(
      'City Guides',
      _HomeSectionKind.city,
      [
        _HomeItem('ATLANTA', '',
            _HomeArt('cityguides.png', Rect.fromLTWH(28, 994, 218, 414)),
            titleKey: 'discover-city-Barcelona-title'),
        _HomeItem('CHICAGO', '',
            _HomeArt('cityguides.png', Rect.fromLTWH(263, 994, 219, 414)),
            titleKey: 'discover-city-Madrid-title'),
        _HomeItem('DENVER', '',
            _HomeArt('cityguides.png', Rect.fromLTWH(498, 994, 219, 414)),
            titleKey: 'discover-city-Granada-title'),
        _HomeItem('LAS VEGAS', '', null),
        _HomeItem('LOS ANGELES', '', null),
        _HomeItem('MIAMI', '', null),
        _HomeItem('NASHVILLE', '', null),
        _HomeItem('NEW YORK CITY', '', null),
      ],
      viewAll: false),
];

const _homeLastMinuteAll = <_HomeItem>[
  _HomeItem('ALADDIN', 'Sun Sep 20 • New Amsterdam Theatre', null),
  _HomeItem('NEW YORK JETS V. GREEN BAY PACKERS',
      'Sun Sep 20 • MetLife Stadium', null),
  _HomeItem('NEW JERSEY DEVILS VS. NEW YORK ISLANDERS',
      'Sun Sep 20 • Prudential Center', null),
  _HomeItem('HAMILTON (NY)', 'Sun Sep 20 • Richard Rodgers Theatre', null),
  _HomeItem(
      'THE LION KING (NEW YORK, NY)', 'Sun Sep 20 • Minskoff Theatre', null),
  _HomeItem('NEW YORK METS VS. PHILADELPHIA PHILLIES',
      'Sun Sep 20 • Citi Field', null),
  _HomeItem('WICKED (NY)', 'Sun Sep 20 • Gershwin Theatre', null),
  _HomeItem('MJ', 'Sun Sep 20 • Neil Simon Theatre', null),
  _HomeItem(
      'DYING FETUS W/ SANGUISUGABOGG', 'Sun Sep 20 • Brooklyn Steel', null),
  _HomeItem('WHIRR', 'Sun Sep 20 • Brooklyn Paramount', null),
  _HomeItem('MADISON SQUARE GARDEN TOUR EXPERIENCE',
      'Mon Sep 21 • Madison Square Garden', null),
];

const _homeConcertsAll = <_HomeItem>[
  _HomeItem('HARRY STYLES', '18 events near you',
      _HomeArt('categories1.png', Rect.fromLTWH(28, 552, 297, 166))),
  _HomeItem('JONAS BROTHERS', '2 events near you',
      _HomeArt('categories1.png', Rect.fromLTWH(341, 552, 297, 166))),
  _HomeItem('AC/DC', '4 events near you',
      _HomeArt('bottom.png', Rect.fromLTWH(341, 952, 297, 166))),
  _HomeItem('THE WOMACK SISTERS', '1 event near you', null),
  _HomeItem('KENNY CHESNEY', '1 event near you', null),
  _HomeItem('DAVE MATTHEWS BAND', '2 events near you', null),
  _HomeItem('STEVE LACY', '1 event near you', null),
  _HomeItem('FOREIGNER', '1 event near you', null),
  _HomeItem('ROLE MODEL', '2 events near you', null),
  _HomeItem('OLIVIA RODRIGO', '10 events near you', null),
  _HomeItem('ZACH JOHN KING', '1 event near you', null),
];

Widget _homeArtwork(_HomeArt? art) {
  if (art == null) {
    return const ColoredBox(
      color: Color(0xFF171717),
      child:
          Center(child: Icon(Icons.bolt, size: 48, color: Color(0xFF1764E5))),
    );
  }
  return _ReferenceCropImage(
    asset: 'assets/reference/home/${art.file}',
    source: art.source,
    fullWidth: 720,
    fullHeight: 1640,
  );
}

void _openHomeViewAll(BuildContext context, String title, List<_HomeItem> items,
    {bool trending = false, bool events = false}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => _HomeViewAllPage(
        title: title, items: items, trending: trending, events: events),
  ));
}

class _HomeSectionHeading extends StatelessWidget {
  const _HomeSectionHeading(this.title,
      {this.onViewAll, this.textKey, this.viewAllTextKey});

  final String title;
  final VoidCallback? onViewAll;
  final String? textKey;
  final String? viewAllTextKey;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Expanded(
            child: Text(title,
                key: textKey == null ? null : ValueKey<String>(textKey!),
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: TmTypography.family,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
          ),
          if (onViewAll != null)
            InkWell(
              onTap: onViewAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('View All',
                    key: viewAllTextKey == null
                        ? null
                        : ValueKey<String>(viewAllTextKey!),
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: TmTypography.family,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ]),
      );
}

class _HomeForYouSection extends StatelessWidget {
  const _HomeForYouSection();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HomeSectionHeading('For You',
              textKey: 'discover-section-Top Picks'),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _homeForYou.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => SizedBox(
                width: 225,
                child: Column(children: [
                  Expanded(
                    child: Stack(fit: StackFit.expand, children: [
                      _homeArtwork(_homeForYou[index].art),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ColoredBox(
                          color: const Color(0xFF252525),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 5, 8, 3),
                            child: Text(_homeForYou[index].title,
                                key: _homeForYou[index].titleKey == null
                                    ? null
                                    : ValueKey<String>(
                                        _homeForYou[index].titleKey!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: TmTypography.family,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  Container(
                    height: 50,
                    color: const Color(0xFF252525),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(children: [
                      material.Text(_homeForYou[index].date,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: TmTypography.family,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              height: 1.15)),
                      const SizedBox(width: 15),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_homeForYou[index].subtitle,
                              key: _homeForYou[index].subtitleKey == null
                                  ? null
                                  : ValueKey<String>(
                                      _homeForYou[index].subtitleKey!),
                              maxLines: 1,
                              style: const TextStyle(
                                  color: Color(0xFFD0D0D0),
                                  fontSize: 11,
                                  fontFamily: TmTypography.family,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 3),
                          material.Text('📍 ${_homeForYou[index].detail}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: TmTypography.family,
                                  fontWeight: FontWeight.w700)),
                        ],
                      )),
                      const Icon(Icons.more_vert,
                          color: Colors.white, size: 16),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ],
      );
}

class _HomeTrendingSection extends StatelessWidget {
  const _HomeTrendingSection();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeSectionHeading('Trending In The United States',
              textKey: 'discover-trending-title',
              viewAllTextKey: 'discover-view-all',
              onViewAll: () => _openHomeViewAll(
                  context, 'TRENDING', _homeTrending,
                  trending: true)),
          const SizedBox(height: 16),
          SizedBox(
            height: 162,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: (_homeTrending.length / 3).ceil(),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, group) => SizedBox(
                width: 300,
                child: Column(children: [
                  for (var i = group * 3;
                      i < math.min(group * 3 + 3, _homeTrending.length);
                      i++) ...[
                    _HomeTrendingTile(index: i, item: _homeTrending[i]),
                    if (i < math.min(group * 3 + 2, _homeTrending.length - 1))
                      const SizedBox(height: 4),
                  ],
                ]),
              ),
            ),
          ),
        ],
      );
}

class _HomeTrendingTile extends StatelessWidget {
  const _HomeTrendingTile({required this.index, required this.item});

  final int index;
  final _HomeItem item;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 51,
        child: Stack(children: [
          Positioned.fill(
            left: 22,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF333333))),
              child: Row(children: [
                SizedBox(width: 67, child: _homeArtwork(item.art)),
                const SizedBox(width: 8),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        key: index < 6
                            ? ValueKey<String>(
                                'discover-trending-${(index + 1).toString().padLeft(2, '0')}-name')
                            : null,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: TmTypography.family,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('⚒ ${item.subtitle}',
                        key: index < 6
                            ? ValueKey<String>(
                                'discover-trending-${(index + 1).toString().padLeft(2, '0')}-genre')
                            : null,
                        maxLines: 1,
                        style: const TextStyle(
                            color: Color(0xFFD1D1D1),
                            fontSize: 11,
                            fontFamily: TmTypography.family,
                            fontWeight: FontWeight.w600)),
                  ],
                )),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 11),
                  child: Icon(Icons.favorite_border,
                      color: Colors.white, size: 20),
                ),
              ]),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: _OutlinedRank(value: (index + 1).toString().padLeft(2, '0')),
          ),
        ]),
      );
}

class _HomeCarouselSection extends StatelessWidget {
  const _HomeCarouselSection({required this.section});

  final _HomeSectionData section;

  @override
  Widget build(BuildContext context) {
    final kind = section.kind;
    final cardWidth = kind == _HomeSectionKind.presale
        ? 225.0
        : kind == _HomeSectionKind.city
            ? 110.0
            : 149.0;
    final cardHeight = kind == _HomeSectionKind.presale
        ? 208.0
        : kind == _HomeSectionKind.city
            ? 207.0
            : 136.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _HomeSectionHeading(section.title,
          textKey: section.title == 'City Guides'
              ? 'discover-section-City Guides'
              : null,
          onViewAll: section.viewAll
              ? () => _openHomeViewAll(
                  context,
                  section.title.toUpperCase(),
                  section.title == 'Last Minute'
                      ? _homeLastMinuteAll
                      : section.title == 'Concerts'
                          ? _homeConcertsAll
                          : section.items,
                  events: kind != _HomeSectionKind.category)
              : null),
      const SizedBox(height: 16),
      SizedBox(
        height: cardHeight,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          scrollDirection: Axis.horizontal,
          itemCount: section.items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) => SizedBox(
            width: cardWidth,
            child: _HomeCarouselCard(item: section.items[index], kind: kind),
          ),
        ),
      ),
    ]);
  }
}

class _HomeCarouselCard extends StatelessWidget {
  const _HomeCarouselCard({required this.item, required this.kind});

  final _HomeItem item;
  final _HomeSectionKind kind;

  @override
  Widget build(BuildContext context) {
    if (kind == _HomeSectionKind.city) {
      return Stack(fit: StackFit.expand, children: [
        item.art == null
            ? const ColoredBox(
                color: Color(0xFF181818),
                child: FittedBox(
                  child: material.Text('V',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 270)),
                ),
              )
            : _homeArtwork(item.art),
        Align(
          alignment: Alignment.bottomLeft,
          child: ColoredBox(
            color: const Color(0xFF101010),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(7, 6, 7, 5),
              child: Text(item.title,
                  key: item.titleKey == null
                      ? null
                      : ValueKey<String>(item.titleKey!),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: TmTypography.family,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ]);
    }
    final presale = kind == _HomeSectionKind.presale;
    final event = kind == _HomeSectionKind.event;
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: const Color(0xFF303030))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: presale ? 126 : 83,
          child: Stack(fit: StackFit.expand, children: [
            _homeArtwork(item.art),
            if (kind == _HomeSectionKind.category)
              const Align(
                alignment: Alignment.topRight,
                child: ColoredBox(
                  color: Color(0x99252525),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(Icons.favorite_border,
                        color: Colors.white, size: 19),
                  ),
                ),
              ),
            if (event || presale)
              Align(
                alignment: Alignment.bottomLeft,
                child: ColoredBox(
                  color: const Color(0xFF101010),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 4, 6, 2),
                    child: material.Text(item.date,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: TmTypography.family,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 7, 5, 4),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: material.Text(item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: TmTypography.family,
                            fontWeight: FontWeight.w800))),
                if (event || presale)
                  const Icon(Icons.more_vert, size: 16, color: Colors.white),
              ]),
              const SizedBox(height: 6),
              material.Text(item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFFC6C6C9),
                      fontSize: 10,
                      fontFamily: TmTypography.family,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
        if (presale)
          Container(
            height: 29,
            width: double.infinity,
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF303030)))),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            child: material.Text('${item.footer}   ❯',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: TmTypography.family,
                    fontWeight: FontWeight.w700)),
          ),
      ]),
    );
  }
}

class _HomeViewAllPage extends StatelessWidget {
  const _HomeViewAllPage(
      {required this.title,
      required this.items,
      required this.trending,
      required this.events});

  final String title;
  final List<_HomeItem> items;
  final bool trending;
  final bool events;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF101010),
        body: SafeArea(
            child: Column(children: [
          SizedBox(
            height: 70,
            child: Stack(alignment: Alignment.center, children: [
              Positioned(
                left: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF777777)),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                material.Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: TmTypography.family,
                        fontWeight: FontWeight.w800)),
                if (trending)
                  const material.Text('United States',
                      style: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 13,
                          fontFamily: TmTypography.family)),
              ]),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 25),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                if (trending) {
                  return SizedBox(
                      height: 52,
                      child: _HomeTrendingTile(index: index, item: item));
                }
                return Container(
                  height: 54,
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF333333))),
                  child: Row(children: [
                    SizedBox(width: 68, child: _homeArtwork(item.art)),
                    const SizedBox(width: 13),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        material.Text(item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: TmTypography.family,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        material.Text(
                            events && item.date.isNotEmpty
                                ? '${item.date} • ${item.subtitle}'
                                : item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0xFFBEBEC2),
                                fontSize: 11,
                                fontFamily: TmTypography.family,
                                fontWeight: FontWeight.w600)),
                      ],
                    )),
                    Icon(events ? Icons.more_vert : Icons.favorite_border,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ]),
                );
              },
            ),
          ),
        ])),
      );
}

class _ReferenceDiscoverSearchPill extends StatefulWidget {
  const _ReferenceDiscoverSearchPill();

  @override
  State<_ReferenceDiscoverSearchPill> createState() =>
      _ReferenceDiscoverSearchPillState();
}

class _ReferenceDiscoverSearchPillState
    extends State<_ReferenceDiscoverSearchPill> {
  static const _style = TextStyle(
    color: Color(0xFFC1C1C5),
    fontFamily: TmTypography.family,
    fontSize: 16.5,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
  );

  Timer? _timer;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showEvents = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() => _showEvents = !_showEvents);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focusNode.requestFocus,
      child: Container(
        height: 59,
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(32),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF1E55DF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 29,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    cursorColor: Colors.white,
                    style: _style.copyWith(color: Colors.white),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _focusNode.unfocus(),
                  ),
                  if (_controller.text.isEmpty)
                    IgnorePointer(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const material.Text('Search for ', style: _style),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 440),
                            reverseDuration: const Duration(milliseconds: 360),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  ...previousChildren,
                                  if (currentChild != null) currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              final isIncoming =
                                  child.key == ValueKey<bool>(_showEvents);
                              final offset = Tween<Offset>(
                                begin: Offset(0, isIncoming ? 0.7 : -0.7),
                                end: Offset.zero,
                              ).animate(animation);
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: offset,
                                  child: child,
                                ),
                              );
                            },
                            child: material.Text(
                              _showEvents ? 'Events' : 'Venues',
                              key: ValueKey<bool>(_showEvents),
                              style: _style,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlinedRank extends StatelessWidget {
  const _OutlinedRank({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontFamily: TmTypography.family,
      fontSize: 31,
      fontWeight: FontWeight.w400,
      letterSpacing: -2,
      height: 1,
    );
    return Stack(
      children: [
        material.Text(
          value,
          style: baseStyle.copyWith(color: const Color(0xFF101010)),
        ),
        material.Text(
          value,
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2
              ..color = const Color(0xFFFFFF27),
          ),
        ),
      ],
    );
  }
}

class _ReferenceCropImage extends StatelessWidget {
  const _ReferenceCropImage({
    required this.source,
    this.asset = TmAssets.discoverReference,
    this.fullWidth = 828,
    this.fullHeight = 1792,
  });

  final Rect source;
  final String asset;
  final double fullWidth;
  final double fullHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final scale = math.max(width / source.width, height / source.height);
        final scaledSourceWidth = source.width * scale;
        final scaledSourceHeight = source.height * scale;
        final left = -source.left * scale + (width - scaledSourceWidth) / 2;
        final top = -source.top * scale + (height - scaledSourceHeight) / 2;
        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: left,
                top: top,
                width: fullWidth * scale,
                height: fullHeight * scale,
                child: Image.asset(
                  asset,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

final List<_DiscoverFeedEntry> _discoverFeedEntries =
    _buildDiscoverFeedEntries();

class _DiscoverFeedEntry {
  const _DiscoverFeedEntry({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.dateLabel,
    required this.ctaLabel,
    required this.imageAsset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentIcon,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String location;
  final String dateLabel;
  final String ctaLabel;
  final String imageAsset;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData accentIcon;
}

List<_DiscoverFeedEntry> _buildDiscoverFeedEntries() {
  const eventNames = <String>[
    'Taylor Swift',
    'Coldplay',
    'Lakers vs Celtics',
    'Hamilton',
    'Nate Bargatze',
    'Bad Bunny',
    'SZA',
    'Billie Eilish',
    'The Lion King',
    'Kevin Hart',
    'Metallica',
    'Drake',
    'Shakira',
    'Arctic Monkeys',
    'UFC Fight Night',
    'New York Yankees vs Dodgers',
    'Wicked',
    'John Mulaney',
    'Bruno Mars',
    'Burna Boy',
  ];
  const eventTags = <String>[
    'Fan Presale',
    'Opening Weekend',
    'VIP Experience',
    'Late Night Show',
    'Final Stop',
  ];
  const categories = <String>[
    'CONCERTS',
    'SPORTS',
    'COMEDY',
    'THEATER',
    'FESTIVAL',
  ];
  const venues = <String>[
    'Madison Square Garden',
    'Crypto.com Arena',
    'Wrigley Field',
    'The Wiltern',
    'Red Rocks Amphitheatre',
    'Kia Forum',
    'United Center',
    'Fenway Park',
    'Beacon Theatre',
    'Paramount Theatre',
  ];
  const cities = <String>[
    'New York, NY',
    'Los Angeles, CA',
    'Chicago, IL',
    'Denver, CO',
    'Boston, MA',
    'Austin, TX',
    'Seattle, WA',
    'Atlanta, GA',
    'Miami, FL',
    'Nashville, TN',
  ];
  const blurbs = <String>[
    'Premium seats, verified resale, and last-minute drops.',
    'Trending now with strong fan demand and fresh inventory.',
    'New dates added for fans tracking popular weekend events.',
    'Great picks for friends planning a night out together.',
    'Top local shows with fast-selling upper bowl sections.',
    'Fresh recommendations based on popular Ticketmaster categories.',
  ];
  const ctas = <String>[
    'Find Tickets',
    'See Dates',
    'Unlock Presale',
    'View Event',
  ];
  const imageAssets = <String>[
    TmAssets.discoverHero,
    TmAssets.discoverPerson,
    TmAssets.sellHero,
    'assets/hero.jpg',
    'assets/talent.jpg',
    'assets/icon.jpg',
    'assets/icon_original.jpg',
    'assets/apk/images/rockies_cr.png',
    'assets/apk/images/icon_blue_white.png',
    'assets/apk/images/Landing_Icon.png',
    'assets/tm/ticket_resale.png',
    'assets/tm/tickets_resale_icon.png',
    'assets/tm/onboarding_favorite_icon.png',
    'assets/tm/tm_fanpass_account_icon.png',
  ];
  const palettes = <List<Color>>[
    <Color>[Color(0xFF0D1B2A), Color(0xFF1B263B)],
    <Color>[Color(0xFF3A0F23), Color(0xFF82204A)],
    <Color>[Color(0xFF0A2E36), Color(0xFF26798E)],
    <Color>[Color(0xFF2D1B0E), Color(0xFFD97706)],
    <Color>[Color(0xFF171717), Color(0xFF525252)],
    <Color>[Color(0xFF14213D), Color(0xFFFCA311)],
    <Color>[Color(0xFF1F2937), Color(0xFF2563EB)],
    <Color>[Color(0xFF172554), Color(0xFF7C3AED)],
    <Color>[Color(0xFF052E16), Color(0xFF16A34A)],
    <Color>[Color(0xFF3F0D12), Color(0xFFA71D31)],
  ];
  const icons = <IconData>[
    Icons.music_note_rounded,
    Icons.stadium_rounded,
    Icons.mic_rounded,
    Icons.theater_comedy_rounded,
    Icons.local_activity_rounded,
    Icons.celebration_rounded,
  ];
  const monthDays = <String>[
    'FRI, APR 11',
    'SAT, APR 19',
    'SUN, MAY 4',
    'THU, MAY 22',
    'FRI, JUN 6',
    'SAT, JUN 21',
    'SUN, JUL 13',
    'THU, AUG 7',
    'FRI, SEP 12',
    'SAT, OCT 18',
  ];

  return List<_DiscoverFeedEntry>.generate(102, (index) {
    final eventName = eventNames[index % eventNames.length];
    final eventTag = eventTags[(index ~/ eventNames.length) % eventTags.length];
    final location = cities[(index * 3) % cities.length];
    final venue = venues[(index * 5) % venues.length];
    final palette = palettes[index % palettes.length];
    return _DiscoverFeedEntry(
      eyebrow: categories[index % categories.length],
      title: '$eventName $eventTag',
      subtitle: blurbs[(index * 7) % blurbs.length],
      location: venue,
      dateLabel: '${monthDays[index % monthDays.length]} • $location',
      ctaLabel: ctas[index % ctas.length],
      imageAsset: imageAssets[index % imageAssets.length],
      primaryColor: palette[0],
      secondaryColor: palette[1],
      accentIcon: icons[index % icons.length],
    );
  });
}

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Column(
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _BrandRow(),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _FilterRow(),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _SearchBar(),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _CategoryRow(),
          ),
        ],
      ),
    );
  }
}

class ForYouScreen extends StatelessWidget {
  const ForYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF101010),
      child: SafeArea(child: _ForYouEmptyState()),
    );
  }
}

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _TicketListEntry {
  const _TicketListEntry({
    required this.id,
    required this.displayTitle,
    required this.displayVenue,
    required this.displayDateLabel,
    required this.searchKeywords,
    this.ticketCount = 1,
    this.imageSelection,
  });

  final int id;
  final String displayTitle;
  final String displayVenue;
  final String displayDateLabel;
  final String searchKeywords;
  final int ticketCount;
  final TicketCardImageSelection? imageSelection;

  String textKey(String field) => 'ticket-$id-$field';

  String ticketInstanceTextKey(int ticketIndex, String field) =>
      'ticket-$id-instance-${ticketIndex + 1}-$field';

  String get editableTitle =>
      _EditableTextStore.valueFor(textKey('title'), displayTitle);

  String get editableVenue =>
      _EditableTextStore.valueFor(textKey('venue'), displayVenue);

  String get editableDateLabel =>
      _EditableTextStore.valueFor(textKey('date'), displayDateLabel);

  String get singleLineTitle => editableTitle
      .replaceAll('\n', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String get primaryVenue => editableVenue.split('-').first.trim();

  String get detailsSubtitle => '$editableDateLabel • $primaryVenue';

  _TicketListEntry copyWith({
    TicketCardImageSelection? imageSelection,
    int? ticketCount,
  }) {
    return _TicketListEntry(
      id: id,
      displayTitle: displayTitle,
      displayVenue: displayVenue,
      displayDateLabel: displayDateLabel,
      searchKeywords: searchKeywords,
      ticketCount: ticketCount ?? this.ticketCount,
      imageSelection: imageSelection ?? this.imageSelection,
    );
  }
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  static const String _defaultTicketTitle =
      'COLORADO ROCKIES VS.\nSAN DIEGO PADRES';
  static const String _defaultTicketVenue = 'Coors Field - Denver, CO';
  static const String _defaultTicketDate = 'MON, SEP 14 2026, 6:40 PM';

  final TextEditingController _ticketSearchController = TextEditingController();
  final FocusNode _ticketSearchFocusNode = FocusNode();

  late List<_TicketListEntry> _upcomingTickets;
  int? _activeTicketOptionsTicketId;
  bool _showSearchBar = false;
  bool _showPastEvents = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _upcomingTickets = _TicketmasterCloudStore.instance.hasSavedTickets
        ? _TicketmasterCloudStore.instance.upcomingTickets
        : List<_TicketListEntry>.generate(
            1,
            (index) => _buildTicketEntry(index),
          );
  }

  @override
  void dispose() {
    _ticketSearchController.dispose();
    _ticketSearchFocusNode.dispose();
    super.dispose();
  }

  _TicketListEntry _buildTicketEntry(int index) {
    final ticketNumber = index + 1;
    return _TicketListEntry(
      id: ticketNumber,
      displayTitle: _defaultTicketTitle,
      displayVenue: _defaultTicketVenue,
      displayDateLabel: _defaultTicketDate,
      searchKeywords:
          'ticket $ticketNumber colorado rockies padres coors field denver sep 14 2026 mobile',
    );
  }

  List<_TicketListEntry> get _visibleUpcomingTickets {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _upcomingTickets;
    }
    return _upcomingTickets.where((ticket) {
      final haystack = [
        ticket.editableTitle,
        ticket.editableVenue,
        ticket.editableDateLabel,
        ticket.searchKeywords,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  void _showTicketOptionsSheet(int ticketId) {
    if (_activeTicketOptionsTicketId == ticketId) return;
    setState(() {
      _activeTicketOptionsTicketId = ticketId;
    });
  }

  void _hideTicketOptions() {
    if (_activeTicketOptionsTicketId == null) return;
    setState(() {
      _activeTicketOptionsTicketId = null;
    });
  }

  Future<void> _showUpcomingTicketCountDialog() async {
    _hideTicketOptions();
    final count = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return _UpcomingTicketCountDialog(
          initialCount: _upcomingTickets.length,
        );
      },
    );
    if (!mounted || count == null) {
      return;
    }
    setState(() {
      final nextTickets = List<_TicketListEntry>.generate(count, (index) {
        if (index < _upcomingTickets.length) {
          return _upcomingTickets[index];
        }
        return _buildTicketEntry(index);
      });
      _upcomingTickets = nextTickets;
    });
    await _TicketmasterCloudStore.instance.saveUpcomingTickets(
      _upcomingTickets,
    );
  }

  Future<void> _showTicketQuantityDialog(_TicketListEntry ticket) async {
    _hideTicketOptions();
    final count = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return _UpcomingTicketCountDialog(
          initialCount: ticket.ticketCount,
          title: 'Set ticket quantity',
          hintText: 'How many tickets inside this card?',
          confirmLabel: 'Save',
        );
      },
    );
    if (!mounted || count == null) {
      return;
    }
    setState(() {
      _upcomingTickets = _upcomingTickets.map((entry) {
        if (entry.id != ticket.id) {
          return entry;
        }
        return entry.copyWith(ticketCount: count);
      }).toList(growable: false);
    });
    await _TicketmasterCloudStore.instance.saveUpcomingTickets(
      _upcomingTickets,
    );
  }

  void _showPastSearch() {
    _hideTicketOptions();
    if (!_showSearchBar || !_showPastEvents) {
      setState(() {
        _showPastEvents = true;
        _showSearchBar = true;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _ticketSearchFocusNode.requestFocus();
    });
  }

  void _hidePastSearch() {
    _ticketSearchFocusNode.unfocus();
    setState(() {
      _showSearchBar = false;
      _searchQuery = '';
      _ticketSearchController.clear();
    });
  }

  Future<void> _pickTicketImage(TicketImageSource source, int ticketId) async {
    _hideTicketOptions();
    try {
      final bytes = await pickTicketImage(source);
      if (!mounted || bytes == null) {
        return;
      }
      final imageSelection = await createFullTicketCardImageSelection(bytes);
      if (!mounted) {
        return;
      }
      setState(() {
        _upcomingTickets = _upcomingTickets.map((ticket) {
          if (ticket.id != ticketId) {
            return ticket;
          }
          return ticket.copyWith(imageSelection: imageSelection);
        }).toList(growable: false);
      });
      await _TicketmasterCloudStore.instance.saveUpcomingTickets(
        _upcomingTickets,
      );
    } on PlatformException catch (error) {
      if (!mounted) return;
      final message = error.message ?? 'Unable to pick image right now.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on UnsupportedError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message ?? 'Unsupported')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image selection failed. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prototype tickets stay Upcoming; editable dates are display copy only.
    final visibleTickets =
        _showPastEvents ? const <_TicketListEntry>[] : _visibleUpcomingTickets;
    final hasSearchQuery = _searchQuery.trim().isNotEmpty;

    return _V2TicketTheme(
        fontFamily: 'SourceSans3',
        child: Container(
          color: const Color(0xFF101010),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TicketsHeader(
                  upcomingCount: _upcomingTickets.length,
                  pastCount: 0,
                  showPastEvents: _showPastEvents,
                  onUpcomingTap: () {
                    setState(() => _showPastEvents = false);
                  },
                  onPastTap: () {
                    setState(() => _showPastEvents = true);
                  },
                  onUpcomingDoubleTap: _showUpcomingTicketCountDialog,
                  onPastDoubleTap: _showPastSearch,
                ),
                if (_showSearchBar)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: _TicketSearchBar(
                      controller: _ticketSearchController,
                      focusNode: _ticketSearchFocusNode,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onClose: _hidePastSearch,
                    ),
                  ),
                Expanded(
                  child: visibleTickets.isEmpty
                      ? hasSearchQuery
                          ? const _TicketSearchEmptyState()
                          : _MyEventsEmptyState(
                              showPastEvents: _showPastEvents,
                              onRefresh: () => setState(() {}),
                            )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 18),
                          itemCount: visibleTickets.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final ticket = visibleTickets[index];
                            final isShowingOptions =
                                _activeTicketOptionsTicketId == ticket.id;
                            return _TicketCard(
                              uploadedImageSelection: ticket.imageSelection,
                              ticketCount: ticket.ticketCount,
                              title: ticket.editableTitle,
                              venue: ticket.editableVenue,
                              dateLabel: ticket.editableDateLabel,
                              titleTextKey: ticket.textKey('title'),
                              venueTextKey: ticket.textKey('venue'),
                              dateTextKey: ticket.textKey('date'),
                              eventLabel: _showPastEvents
                                  ? 'PAST EVENT'
                                  : 'UPCOMING EVENT',
                              showTicketOptions: isShowingOptions,
                              onDismissTicketOptions: _hideTicketOptions,
                              onSelectGallery: () {
                                _pickTicketImage(
                                  TicketImageSource.gallery,
                                  ticket.id,
                                );
                              },
                              onSelectCamera: () {
                                _pickTicketImage(
                                  TicketImageSource.camera,
                                  ticket.id,
                                );
                              },
                              onDoubleTap: () {
                                _showTicketOptionsSheet(ticket.id);
                              },
                              onLongPress: () {
                                _showTicketOptionsSheet(ticket.id);
                              },
                              onCountDoubleTap: () {
                                _showTicketQuantityDialog(ticket);
                              },
                              onTap: () {
                                if (isShowingOptions) {
                                  _hideTicketOptions();
                                  return;
                                }
                                Navigator.of(context).push(
                                  _MyTicketDetailsRoute(
                                    ticket: ticket,
                                    ticketCount: ticket.ticketCount,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ));
  }
}

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: _SellLanding());
  }
}

class _InboxSeat {
  const _InboxSeat(this.section, this.row, this.number);

  final String section;
  final String row;
  final String number;

  Map<String, String> toJson() => {
        'section': section,
        'row': row,
        'number': number,
      };

  factory _InboxSeat.fromJson(Map<String, dynamic> json) => _InboxSeat(
        json['section']?.toString() ?? '',
        json['row']?.toString() ?? '',
        json['number']?.toString() ?? '',
      );
}

class _InboxTransfer {
  const _InboxTransfer({
    required this.ticketId,
    required this.title,
    required this.venue,
    required this.date,
    required this.seats,
    required this.createdAt,
    this.imageSelection,
  });

  final int ticketId;
  final String title;
  final String venue;
  final String date;
  final List<_InboxSeat> seats;
  final DateTime createdAt;
  final TicketCardImageSelection? imageSelection;

  _InboxTransfer withImage(TicketCardImageSelection image) => _InboxTransfer(
        ticketId: ticketId,
        title: title,
        venue: venue,
        date: date,
        seats: seats,
        createdAt: createdAt,
        imageSelection: image,
      );

  Map<String, dynamic> toJson() => {
        'ticketId': ticketId,
        'title': title,
        'venue': venue,
        'date': date,
        'seats': seats.map((seat) => seat.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory _InboxTransfer.fromJson(Map<String, dynamic> json) {
    final ticketId = (json['ticketId'] as num?)?.toInt() ?? -1;
    TicketCardImageSelection? image;
    for (final ticket in _TicketmasterCloudStore.instance.upcomingTickets) {
      if (ticket.id == ticketId) {
        image = ticket.imageSelection;
        break;
      }
    }
    return _InboxTransfer(
      ticketId: ticketId,
      title: json['title']?.toString() ?? '',
      venue: json['venue']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      seats: (json['seats'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => _InboxSeat.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      imageSelection: image,
    );
  }
}

class _TransferInboxStore {
  static const _storageKey = 'inbox-latest-transfer';
  static final ValueNotifier<_InboxTransfer?> latest = ValueNotifier(null);

  static _InboxTransfer? get current {
    if (latest.value != null) return latest.value;
    final raw = _EditableTextStore.valueFor(_storageKey, '');
    if (raw.isEmpty) return null;
    try {
      return _InboxTransfer.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  static void clearInMemory() => latest.value = null;

  static void record(_TicketListEntry ticket, Iterable<int> selectedIndexes) {
    final indexes = selectedIndexes.toList()..sort();
    if (indexes.isEmpty) return;
    final seats = indexes.map((index) {
      String value(String field, String fallback) =>
          _EditableTextStore.valueFor(
              ticket.ticketInstanceTextKey(index, field), fallback);
      return _InboxSeat(
        value('section-value', '402'),
        value('row-value', '5'),
        value('seat-value', '${index + 1}'),
      );
    }).toList(growable: false);
    final transfer = _InboxTransfer(
      ticketId: ticket.id,
      title: ticket.singleLineTitle,
      venue: ticket.primaryVenue,
      date: ticket.editableDateLabel,
      seats: seats,
      createdAt: DateTime.now(),
      imageSelection: ticket.imageSelection,
    );
    latest.value = transfer;
    if (FirebaseAuth.instance.currentUser != null) {
      unawaited(_EditableTextStore.save(
          _storageKey, '', jsonEncode(transfer.toJson())));
    }
  }
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _locationContentEnabled = true;
  bool _notificationsEnabled = true;

  Future<void> _signOut() async {
    await _TicketmasterCloudStore.instance.clearAuthSession(
      releaseDeviceLock: true,
    );
    await FirebaseAuth.instance.signOut();
    _TicketmasterCloudStore.instance.resetLocalState();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushAndRemoveUntil(_TicketmasterLoginRoute(), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final displayName = currentUser?.displayName?.trim().isNotEmpty == true
        ? currentUser!.displayName!.trim()
        : 'Antonio Jem’s';
    final email = currentUser?.email ?? 'tickethube@gmail.com';

    return ColoredBox(
      color: const Color(0xFF101010),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 28),
          children: [
            Row(
              children: [
                Container(
                  width: 59,
                  height: 59,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF3F70E8),
                      width: 3,
                    ),
                  ),
                  child: material.Text(
                    _accountInitials(displayName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        key: const ValueKey<String>('account-profile-name'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      material.Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFC4C2C6),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _AccountSectionTitle(
              title: 'Personalization',
              textKey: 'account-section-personalization',
            ),
            const SizedBox(height: 13),
            _AccountMenuGroup(
              rows: [
                _AccountMenuRowData(
                  icon: Icons.mail_outline_rounded,
                  label: 'My Inbox',
                  textKey: 'account-row-inbox',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const _MyInboxPage(),
                    ),
                  ),
                ),
                const _AccountMenuRowData(
                  icon: Icons.favorite_border_rounded,
                  label: 'Favourites',
                  textKey: 'account-row-favourites',
                ),
                const _AccountMenuRowData(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  textKey: 'account-row-location',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _AccountSectionTitle(
              title: 'Permissions',
              textKey: 'account-section-permissions',
            ),
            const SizedBox(height: 13),
            _AccountMenuGroup(
              rows: [
                _AccountMenuRowData(
                  icon: Icons.near_me,
                  label: 'Location Content',
                  textKey: 'account-row-location-content',
                  trailing: _ReferenceSwitch(
                    value: _locationContentEnabled,
                    onChanged: (value) {
                      setState(() => _locationContentEnabled = value);
                    },
                  ),
                ),
                _AccountMenuRowData(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  textKey: 'account-row-notifications',
                  trailing: _ReferenceSwitch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _AccountSectionTitle(
              title: 'Account',
              textKey: 'account-section-account',
            ),
            const SizedBox(height: 13),
            const _AccountMenuGroup(
              rows: [
                _AccountMenuRowData(
                  icon: Icons.manage_accounts_outlined,
                  label: 'Edit Details',
                  textKey: 'account-row-edit-details',
                ),
                _AccountMenuRowData(
                  icon: Icons.verified_user_outlined,
                  label: 'Security',
                  textKey: 'account-row-security',
                ),
                _AccountMenuRowData(
                  icon: Icons.payment_outlined,
                  label: 'Saved Payment Methods',
                  textKey: 'account-row-payment-methods',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _AccountSectionTitle(
              title: 'Help & Guidance',
              textKey: 'account-section-help',
            ),
            const SizedBox(height: 13),
            const _AccountMenuGroup(
              rows: [
                _AccountMenuRowData(
                  icon: Icons.help_outline_rounded,
                  label: 'Need Help?',
                  textKey: 'account-row-help',
                ),
                _AccountMenuRowData(
                  icon: Icons.forum_outlined,
                  label: 'Give Us Feedback',
                  textKey: 'account-row-feedback',
                ),
                _AccountMenuRowData(
                  icon: Icons.remove_red_eye_outlined,
                  label: 'Privacy',
                  textKey: 'account-row-privacy',
                ),
                _AccountMenuRowData(
                  icon: Icons.text_snippet_outlined,
                  label: 'Legal',
                  textKey: 'account-row-legal',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _AccountMenuGroup(
              rows: [
                _AccountMenuRowData(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  textKey: 'account-row-sign-out',
                  onTap: currentUser == null ? null : _signOut,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _accountInitials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'TM';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _AccountSectionTitle extends StatelessWidget {
  const _AccountSectionTitle({required this.title, required this.textKey});

  final String title;
  final String textKey;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      key: ValueKey<String>(textKey),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _MyInboxPage extends StatelessWidget {
  const _MyInboxPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF15171D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF15171D),
          foregroundColor: Colors.white,
          title: const Text('My Inbox', key: ValueKey('inbox-page-title')),
        ),
        body: ValueListenableBuilder<_InboxTransfer?>(
          valueListenable: _TransferInboxStore.latest,
          builder: (context, latest, _) {
            final transfer = latest ?? _TransferInboxStore.current;
            if (transfer == null) {
              return const Center(
                child: material.Text('No messages yet',
                    style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 16)),
              );
            }
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _TransferConfirmationMail(transfer: transfer),
                ),
              ],
            );
          },
        ),
      );
}

class _TransferConfirmationMail extends StatefulWidget {
  const _TransferConfirmationMail({required this.transfer});

  final _InboxTransfer transfer;

  @override
  State<_TransferConfirmationMail> createState() =>
      _TransferConfirmationMailState();
}

class _TransferConfirmationMailState extends State<_TransferConfirmationMail> {
  _InboxTransfer get transfer => widget.transfer;

  Text _mailText(String field, String value,
          {TextStyle? style, int? maxLines, TextOverflow? overflow}) =>
      Text(value,
          key: ValueKey(
              'inbox-mail-${transfer.createdAt.microsecondsSinceEpoch}-$field'),
          style: style,
          maxLines: maxLines,
          overflow: overflow);

  Widget _smallText(String field, String value,
          {Color color = const Color(0xFFD6DCE4),
          FontWeight weight = FontWeight.w400,
          double size = 10}) =>
      _mailText(field, value,
          style: TextStyle(color: color, fontWeight: weight, fontSize: size));

  Future<void> _chooseImage() async {
    final source = await showModalBottomSheet<TicketImageSource>(
      context: context,
      builder: (context) => SafeArea(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const material.Text('Gallery'),
              onTap: () => Navigator.pop(context, TicketImageSource.gallery)),
          ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const material.Text('Camera'),
              onTap: () => Navigator.pop(context, TicketImageSource.camera)),
        ],
      )),
    );
    if (!mounted || source == null) return;
    try {
      final bytes = await pickTicketImage(source);
      if (!mounted || bytes == null) return;
      final image = await createFullTicketCardImageSelection(bytes);
      if (!mounted) return;
      final tickets = _TicketmasterCloudStore.instance.upcomingTickets
          .map((ticket) => ticket.id == transfer.ticketId
              ? ticket.copyWith(imageSelection: image)
              : ticket)
          .toList(growable: false);
      await _TicketmasterCloudStore.instance.saveUpcomingTickets(tickets);
      if (!mounted) return;
      _TransferInboxStore.latest.value = transfer.withImage(image);
    } on PlatformException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: material.Text(
                error.message ?? 'Unable to pick image right now.')));
    } on UnsupportedError catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: material.Text(error.message ?? 'Unsupported')));
    }
  }

  @override
  Widget build(BuildContext context) {
    _TicketListEntry? sourceTicket;
    for (final ticket in _TicketmasterCloudStore.instance.upcomingTickets) {
      if (ticket.id == transfer.ticketId) {
        sourceTicket = ticket;
        break;
      }
    }
    final seatsLabel = transfer.seats.map((seat) => seat.number).join(', ');
    final sectionLabel =
        transfer.seats.map((seat) => seat.section).toSet().join(', ');
    final rowLabel = transfer.seats.map((seat) => seat.row).toSet().join(', ');
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222931),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          height: 30,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            _mailText('logo', 'ticketmaster',
                style: TextStyle(
                    color: Color(0xFF064985),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 5),
            _mailText('logo-divider', '·',
                style: const TextStyle(color: Colors.black)),
            const SizedBox(width: 5),
            _mailText('logo-ballpark', '⚾ BALLPARK',
                style: TextStyle(
                    color: Color(0xFF263545),
                    fontSize: 9,
                    fontWeight: FontWeight.w800)),
            const Spacer(),
            const Icon(Icons.account_box_outlined,
                size: 12, color: Color(0xFF0E3965)),
            const SizedBox(width: 3),
            _mailText('account', 'My Account',
                style: TextStyle(color: Color(0xFF263545), fontSize: 8)),
          ]),
        ),
        Container(
          height: 126,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF074483),
                Color(0xFF075DDD),
                Color(0xFF008CEC),
                Color(0xFF06396C)
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _mailText('hero', 'You Got the Tickets',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            _mailText('order', 'Order #TM-${transfer.ticketId}',
                style: const TextStyle(color: Colors.white, fontSize: 10)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 32,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: Row(children: [
                Expanded(
                  child: _mailText(
                      'access', 'Access Your Tickets in the Ballpark App',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 5),
                _mailText('access-ballpark', '⚾ BALLPARK',
                    style: TextStyle(
                        color: Color(0xFF24364C),
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                key: const ValueKey('inbox-mail-image'),
                onLongPress: _chooseImage,
                onDoubleTap: _chooseImage,
                child: SizedBox(
                  width: 104,
                  height: 104,
                  child: _V2TicketArtwork(selection: transfer.imageSelection),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _smallText('ticket-title', transfer.title,
                      color: Colors.white, weight: FontWeight.w700, size: 11),
                  const SizedBox(height: 4),
                  _smallText('ticket-date', transfer.date),
                  const SizedBox(height: 4),
                  _smallText('ticket-venue', transfer.venue),
                  const SizedBox(height: 5),
                  _smallText(
                      'section-row', 'Section $sectionLabel / Row $rowLabel',
                      size: 9),
                  _smallText('seats', 'Seat $seatsLabel', size: 9),
                  const SizedBox(height: 7),
                  SizedBox(
                    height: 25,
                    child: FilledButton(
                      onPressed: sourceTicket == null
                          ? null
                          : () => Navigator.of(context).push(_ViewTicketRoute(
                                ticket: sourceTicket!,
                                ticketCount: sourceTicket.ticketCount,
                              )),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0879DE),
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: _mailText('view-button', 'View Mobile Ticket',
                          style: TextStyle(fontSize: 9)),
                    ),
                  ),
                ],
              )),
            ]),
            const SizedBox(height: 18),
            _smallText('info-title', 'Important Information',
                color: Colors.white, weight: FontWeight.w700, size: 11),
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFF1B3B58),
                border: Border.all(color: const Color(0xFF3288CC)),
              ),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info, size: 16, color: Colors.white),
                const SizedBox(width: 7),
                Expanded(
                    child: _smallText(
                        'info-body',
                        '${transfer.seats.length} ticket${transfer.seats.length == 1 ? '' : 's'} '
                            'for ${transfer.title}. Keep your mobile ticket ready for entry.',
                        color: Colors.white,
                        size: 9)),
              ]),
            ),
            const SizedBox(height: 17),
            Row(children: [
              Expanded(
                  child: _smallText('summary-title', 'Ticket Summary',
                      color: Colors.white, weight: FontWeight.w700, size: 11)),
              _smallText('summary-count',
                  '${transfer.seats.length} ticket${transfer.seats.length == 1 ? '' : 's'}',
                  color: Colors.white, size: 10),
            ]),
            const Divider(color: Color(0xFF4B535C)),
            for (var index = 0; index < transfer.seats.length; index++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: _smallText('seat-$index',
                    'Sec ${transfer.seats[index].section} • Row ${transfer.seats[index].row} • Seat ${transfer.seats[index].number}',
                    color: Colors.white, size: 10),
              ),
          ]),
        ),
        const Spacer(),
        Container(
          color: const Color(0xFF232A32),
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 88),
          child: Column(children: [
            _smallText('stay-connected', 'Stay Connected',
                color: Colors.white, size: 9),
            const SizedBox(height: 7),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.facebook, size: 15, color: Colors.white),
              SizedBox(width: 16),
              Icon(Icons.camera_alt_outlined, size: 15, color: Colors.white),
              SizedBox(width: 16),
              Icon(Icons.play_circle_outline, size: 15, color: Colors.white),
            ]),
            const SizedBox(height: 12),
            _smallText(
                'footer', 'Ticketmaster  |  About  |  Terms of Use  |  Privacy',
                color: Colors.white, size: 8),
          ]),
        ),
      ]),
    );
  }
}

class _AccountMenuRowData {
  const _AccountMenuRowData({
    required this.icon,
    required this.label,
    required this.textKey,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String textKey;
  final Widget? trailing;
  final VoidCallback? onTap;
}

class _AccountMenuGroup extends StatelessWidget {
  const _AccountMenuGroup({required this.rows});

  final List<_AccountMenuRowData> rows;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF242424),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _AccountMenuRow(data: rows[index]),
            if (index != rows.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFF111111),
              ),
          ],
        ],
      ),
    );
  }
}

class _AccountMenuRow extends StatelessWidget {
  const _AccountMenuRow({required this.data});

  final _AccountMenuRowData data;

  @override
  Widget build(BuildContext context) {
    final trailing = data.trailing;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap ?? (trailing == null ? () {} : null),
        child: SizedBox(
          height: 43,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Icon(data.icon, size: 19, color: Colors.white),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    data.label,
                    key: ValueKey<String>(data.textKey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF3F1F4),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                trailing ??
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferenceSwitch extends StatelessWidget {
  const _ReferenceSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 52,
        height: 27,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF245AE5) : const Color(0xFF626262),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: DecoratedBox(
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _ForYouEmptyState extends StatefulWidget {
  const _ForYouEmptyState();

  @override
  State<_ForYouEmptyState> createState() => _ForYouEmptyStateState();
}

class _ForYouEmptyStateState extends State<_ForYouEmptyState> {
  bool _eventsSelected = true;

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFFB85BFA);
    return ColoredBox(
      color: const Color(0xFF101010),
      child: Column(
        children: [
          const SizedBox(height: 6),
          const Text(
            'WATCHLIST',
            key: ValueKey<String>('watchlist-title'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Keep track of what’s important',
            key: ValueKey<String>('watchlist-subtitle'),
            style: TextStyle(
              color: Color(0xFFD0CDD1),
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 26),
          Container(
            height: 43,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF2C2C2E)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _WatchlistSegment(
                    selected: _eventsSelected,
                    icon: Icons.bookmark,
                    label: 'Events',
                    onTap: () => setState(() => _eventsSelected = true),
                  ),
                ),
                Expanded(
                  child: _WatchlistSegment(
                    selected: !_eventsSelected,
                    icon: Icons.favorite_border_rounded,
                    label: 'Favourites',
                    onTap: () => setState(() => _eventsSelected = false),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(33, 42, 26, 30),
              child: Column(
                children: [
                  Icon(
                    _eventsSelected ? Icons.bookmark : Icons.favorite_rounded,
                    size: 52,
                    color: purple,
                  ),
                  const SizedBox(height: 34),
                  const SizedBox(
                    width: 80,
                    height: 2,
                    child: ColoredBox(color: purple),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    _eventsSelected ? 'No Events Added' : 'No Favourites Added',
                    key: ValueKey<String>(
                      _eventsSelected
                          ? 'watchlist-empty-events'
                          : 'watchlist-empty-favourites',
                    ),
                    style: const TextStyle(
                      color: Color(0xFFB9B9BB),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 37),
                  const _WatchlistBenefit(
                    icon: Icons.stadium_outlined,
                    title: 'Save Events',
                    description:
                        'Easily jump back into events that you have an interest in going to',
                    titleKey: 'watchlist-save-title',
                    descriptionKey: 'watchlist-save-description',
                  ),
                  const SizedBox(height: 17),
                  const _WatchlistBenefit(
                    icon: Icons.notifications_none_rounded,
                    title: 'Never Miss A Presale',
                    description:
                        'Set alerts so you never miss out on those presale tickets',
                    titleKey: 'watchlist-presale-title',
                    descriptionKey: 'watchlist-presale-description',
                  ),
                  const SizedBox(height: 17),
                  const _WatchlistBenefit(
                    icon: Icons.info_outline_rounded,
                    title: 'Stay Informed',
                    description:
                        'Receive alerts and updates about key event information',
                    titleKey: 'watchlist-informed-title',
                    descriptionKey: 'watchlist-informed-description',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchlistSegment extends StatelessWidget {
  const _WatchlistSegment({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFB85BFA) : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19, color: selected ? Colors.black : Colors.white),
            const SizedBox(width: 9),
            material.Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : const Color(0xFFF2EFF3),
                fontSize: 14.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistBenefit extends StatelessWidget {
  const _WatchlistBenefit({
    required this.icon,
    required this.title,
    required this.description,
    required this.titleKey,
    required this.descriptionKey,
  });

  final IconData icon;
  final String title;
  final String description;
  final String titleKey;
  final String descriptionKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 37,
          child: Icon(icon, size: 21, color: const Color(0xFFB85BFA)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                key: ValueKey<String>(titleKey),
                style: const TextStyle(
                  color: Color(0xFFF7F4F8),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                key: ValueKey<String>(descriptionKey),
                style: const TextStyle(
                  color: Color(0xFFBEBCC0),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SellLanding extends StatelessWidget {
  const _SellLanding();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              _SellHero(),
              _SellListItem(
                iconAsset: 'assets/tm/tickets_icon_find.png',
                title: 'Tickets I’m Selling',
              ),
              _DividerLine(),
              _SellListItem(
                iconAsset: 'assets/tm/tickets_icon_voided_ticket.png',
                title: 'Sold Tickets',
              ),
              _DividerLine(),
              _SellListItem(
                iconAsset: 'assets/tm/tickets_icon_voided_tickets.png',
                title: 'Expired Tickets',
              ),
              _DividerLine(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SellHero extends StatelessWidget {
  const _SellHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          Image.asset(
            TmAssets.sellHero,
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            cacheWidth: 240,
            cacheHeight: 240,
          ),
          const SizedBox(height: 18),
          const Text(
            'SELL TICKETS FROM ANY SITE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get access to millions of fans, even if you\ndidn’t buy tickets on Ticketmaster.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: TmColors.brandBlue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Learn how it works'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: TmColors.brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Sell Your Tickets'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellListItem extends StatelessWidget {
  const _SellListItem({required this.iconAsset, required this.title});

  final String iconAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Image.asset(iconAsset, width: 24, height: 24),
          const SizedBox(width: 14),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5));
  }
}

class EmptyState extends StatefulWidget {
  const EmptyState({
    super.key,
    required this.illustration,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.secondaryButtonLabel,
  });

  final IconData illustration;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final String? secondaryButtonLabel;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> {
  bool _showIllustration = false;
  bool _showText = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    // Staggered entrance: illustration -> text -> buttons.
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() => _showIllustration = true);
    });
    Future.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      setState(() => _showText = true);
    });
    Future.delayed(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      setState(() => _showButton = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F2F2),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedOpacity(
            opacity: _showIllustration ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 280),
            curve: TmCurves.easeOut,
            child: AnimatedScale(
              scale: _showIllustration ? 1.0 : 0.95,
              duration: const Duration(milliseconds: 280),
              curve: TmCurves.easeOut,
              child: CircleAvatar(
                radius: 64,
                backgroundColor: Colors.white,
                child: Icon(
                  widget.illustration,
                  size: 64,
                  color: TmColors.brandBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: _showText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 260),
            curve: TmCurves.easeOut,
            child: AnimatedSlide(
              offset: _showText ? Offset.zero : const Offset(0, 0.06),
              duration: const Duration(milliseconds: 260),
              curve: TmCurves.easeOut,
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: _showButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 240),
            curve: TmCurves.easeOut,
            child: AnimatedSlide(
              offset: _showButton ? Offset.zero : const Offset(0, 0.08),
              duration: const Duration(milliseconds: 240),
              curve: TmCurves.easeOut,
              child: Column(
                children: [
                  if (widget.secondaryButtonLabel != null)
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.black54),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(widget.secondaryButtonLabel!),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TmColors.brandBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 14,
                      ),
                    ),
                    child: Text(widget.buttonLabel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  const AnimatedCard({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _visible = false;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    // Implicit list appearance to keep scrolling smooth at 60fps.
    _revealTimer = Timer(widget.delay, () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: TmDurations.listAppear,
      curve: TmCurves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        duration: TmDurations.listAppear,
        curve: TmCurves.easeOut,
        child: Material(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(8),
          child: widget.child,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TmColors.headerBlack,
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 10),
      alignment: Alignment.centerLeft,
      child: Text(title, style: TmTypography.header),
    );
  }
}

class _TicketsHeader extends StatelessWidget {
  const _TicketsHeader({
    required this.upcomingCount,
    required this.pastCount,
    required this.showPastEvents,
    required this.onUpcomingTap,
    required this.onPastTap,
    this.onUpcomingDoubleTap,
    this.onPastDoubleTap,
  });

  final int upcomingCount;
  final int pastCount;
  final bool showPastEvents;
  final VoidCallback onUpcomingTap;
  final VoidCallback onPastTap;
  final VoidCallback? onUpcomingDoubleTap;
  final VoidCallback? onPastDoubleTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF232323),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 11, 17, 8),
            child: Row(
              children: [
                const SizedBox(width: 54),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                        child: Text(
                          'My Tickets',
                          key: ValueKey<String>('my-events-title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white38, width: 1.3),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: Image.asset(
                            TmAssets.flag,
                            fit: BoxFit.cover,
                            cacheWidth: 50,
                            cacheHeight: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 54,
                  child: Text(
                    'Help',
                    key: ValueKey<String>('my-events-help'),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onUpcomingTap,
                        onDoubleTap: onUpcomingDoubleTap,
                        onLongPress: onUpcomingDoubleTap,
                        child: Center(
                          child: material.Text(
                            'Upcoming ($upcomingCount)',
                            style: TextStyle(
                              color: showPastEvents
                                  ? const Color(0xFFB9B9BB)
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: showPastEvents
                                  ? FontWeight.w400
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onPastTap,
                        onDoubleTap: onPastDoubleTap,
                        onLongPress: onPastDoubleTap,
                        child: Center(
                          child: material.Text(
                            'Past ($pastCount)',
                            style: TextStyle(
                              color: showPastEvents
                                  ? Colors.white
                                  : const Color(0xFFB9B9BB),
                              fontSize: 14,
                              fontWeight: showPastEvents
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: showPastEvents
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft,
                  child: const FractionallySizedBox(
                    widthFactor: 0.5,
                    child: SizedBox(
                      height: 2,
                      child: ColoredBox(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketSearchBar extends StatelessWidget {
  const _TicketSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8D8D8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF646C76), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search tickets by name or keyword',
                hintStyle: TextStyle(color: Color(0xFF9098A3), fontSize: 14),
              ),
              style: const TextStyle(
                color: Color(0xFF171A1F),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, color: Color(0xFF646C76), size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyEventsEmptyState extends StatelessWidget {
  const _MyEventsEmptyState({
    required this.showPastEvents,
    required this.onRefresh,
  });

  final bool showPastEvents;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    const foreground = Colors.white;
    const secondary = Color(0xFFC7C7C7);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                SizedBox(height: constraints.maxHeight * 0.25),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color:
                        showPastEvents ? const Color(0xFF242424) : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: _EmptyTicketsIcon(),
                  ),
                ),
                const SizedBox(height: 43),
                Text(
                  showPastEvents ? 'No past events' : 'No upcoming events',
                  key: ValueKey<String>(
                    showPastEvents
                        ? 'my-events-empty-past'
                        : 'my-events-empty-upcoming',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 42),
                  child: Text(
                    showPastEvents
                        ? 'Events you have attended will appear here'
                        : 'Tickets you buy will automatically\nappear here',
                    key: ValueKey<String>(
                      showPastEvents
                          ? 'my-events-empty-past-description'
                          : 'my-events-empty-upcoming-description',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondary,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      height: 1.15,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 31),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: onRefresh,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: foreground,
                        side: BorderSide(color: foreground, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      child: Text(
                        'Refresh',
                        key: const ValueKey<String>('my-events-refresh'),
                        style: TextStyle(
                          color: foreground,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyTicketsIcon extends StatelessWidget {
  const _EmptyTicketsIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(8, 3),
            child: Transform.rotate(
              angle: 0.15,
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          Transform.rotate(
            angle: -0.16,
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketSearchEmptyState extends StatelessWidget {
  const _TicketSearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off_rounded, size: 54, color: Color(0xFF8C939C)),
            SizedBox(height: 14),
            Text(
              'No matching tickets found',
              style: TextStyle(
                color: Color(0xFFF2F2F2),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try another ticket name or keyword.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFB9BFC7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingTicketCountDialog extends StatefulWidget {
  const _UpcomingTicketCountDialog({
    required this.initialCount,
    this.title = 'Create upcoming tickets',
    this.hintText = 'How many ticket cards?',
    this.confirmLabel = 'Create',
  });

  final int initialCount;
  final String title;
  final String hintText;
  final String confirmLabel;

  @override
  State<_UpcomingTicketCountDialog> createState() =>
      _UpcomingTicketCountDialogState();
}

class _UpcomingTicketCountDialogState
    extends State<_UpcomingTicketCountDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialCount}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final count = int.tryParse(_controller.text.trim());
    if (count == null || count < 1) {
      return;
    }
    Navigator.of(context).pop(count);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: material.Text(widget.title),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const material.Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: material.Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              TmAssets.brandLogo,
              height: 16,
              fit: BoxFit.contain,
              cacheHeight: 32,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 1.2),
              ),
              child: ClipOval(
                child: Image.asset(
                  TmAssets.flag,
                  fit: BoxFit.cover,
                  cacheWidth: 48,
                  cacheHeight: 48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _FilterTile(
            leadingAsset: TmAssets.locationIcon,
            label: 'LOCATION',
            value: 'Los Angeles',
            showClear: true,
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          height: 36,
          child: VerticalDivider(color: Colors.white24, thickness: 1),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _FilterTile(
            leadingAsset: TmAssets.dateIcon,
            label: 'DATES',
            value: 'All Dates',
            showDropdown: true,
          ),
        ),
      ],
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.leadingAsset,
    required this.label,
    required this.value,
    this.showDropdown = false,
    this.showClear = false,
  });

  final String leadingAsset;
  final String label;
  final String value;
  final bool showDropdown;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          leadingAsset,
          width: 18,
          height: 18,
          color: Colors.white70,
          cacheWidth: 36,
          cacheHeight: 36,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (showDropdown) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (showClear)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.white38, width: 1),
            ),
            child: const Icon(Icons.close, size: 12, color: Colors.white70),
          ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'SEARCH',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Artist, Event or Venue',
                  style: TextStyle(color: TmColors.hintGrey),
                ),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TmColors.brandBlue, width: 1.2),
            ),
            child: Image.asset(
              TmAssets.searchIcon,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              cacheWidth: 48,
              cacheHeight: 48,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context) {
    final items = ['Concerts', 'Sports', 'Arts, Theater & Comedy'];
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                items[i],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (i != items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.entry});

  final _DiscoverFeedEntry entry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [entry.primaryColor, entry.secondaryColor],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final dpr = MediaQuery.of(context).devicePixelRatio;
                final cacheWidth = (constraints.maxWidth * dpr).round();
                return Image.asset(
                  entry.imageAsset,
                  fit: BoxFit.cover,
                  cacheWidth: cacheWidth,
                  color: Colors.black.withValues(alpha: 0.14),
                  colorBlendMode: BlendMode.darken,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: entry.primaryColor,
                      child: const Center(
                        child: Text(
                          'Hero Image',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.68),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(entry.accentIcon, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          entry.eyebrow,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    entry.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.location,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: entry.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      entry.ctaLabel,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TalentCard extends StatelessWidget {
  const _TalentCard({required this.entry});

  final _DiscoverFeedEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 176,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [entry.primaryColor, entry.secondaryColor],
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final dpr = MediaQuery.of(context).devicePixelRatio;
                    final cacheWidth = (constraints.maxWidth * dpr).round();
                    return Image.asset(
                      entry.imageAsset,
                      height: 176,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      cacheWidth: cacheWidth,
                      color: Colors.black.withValues(alpha: 0.12),
                      colorBlendMode: BlendMode.darken,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 176,
                          color: entry.primaryColor,
                          alignment: Alignment.center,
                          child: const Text(
                            'Talent Image',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.34),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(entry.accentIcon, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.eyebrow,
                style: TextStyle(
                  letterSpacing: 1.1,
                  fontSize: 12,
                  color: entry.primaryColor.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.subtitle,
                style: const TextStyle(
                  color: Color(0xFF5A5F66),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.dateLabel,
                      style: const TextStyle(
                        color: Color(0xFF5A5F66),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: entry.primaryColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      entry.ctaLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
