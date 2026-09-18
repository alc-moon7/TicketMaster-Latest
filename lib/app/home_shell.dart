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
              const Positioned(
                right: 0,
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

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF101010),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: const [
            _ReferenceDiscoverHeader(),
            SizedBox(height: 34),
            _ReferenceTrendingSection(),
            SizedBox(height: 63),
            _ReferenceCardSection(
              title: 'Top Picks',
              cards: _referenceTopPicks,
            ),
            SizedBox(height: 32),
            _ReferenceCardSection(
              title: 'City Guides',
              cards: _referenceCityGuides,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceDiscoverHeader extends StatelessWidget {
  const _ReferenceDiscoverHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 11, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 20,
                color: Color(0xFF69DED1),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Santa Eulalia del Río, Balearic Islands, ES',
                  key: ValueKey<String>('discover-location'),
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
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Color(0xFFF0F0F0),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _ReferenceDiscoverSearchPill(),
        ],
      ),
    );
  }
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

class _ReferenceTrendingSection extends StatelessWidget {
  const _ReferenceTrendingSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final groupWidth = (screenWidth - 60).clamp(330.0, 390.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 17),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Trending In Spain',
                  key: ValueKey<String>('discover-trending-title'),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: TmTypography.family,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.15,
                  ),
                ),
              ),
              Text(
                'View All',
                key: ValueKey<String>('discover-view-all'),
                style: TextStyle(
                  color: Color(0xFFF0F0F0),
                  fontFamily: TmTypography.family,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        SizedBox(
          height: 196,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 17, right: 17),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 2,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, groupIndex) {
              final start = groupIndex * 3;
              return SizedBox(
                width: groupWidth,
                child: Column(
                  children: [
                    for (var offset = 0; offset < 3; offset++) ...[
                      _ReferenceTrendingRow(
                        item: _referenceTrending[start + offset],
                      ),
                      if (offset != 2) const SizedBox(height: 9),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ReferenceTrendingRow extends StatelessWidget {
  const _ReferenceTrendingRow({required this.item});

  final _ReferenceTrendingItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 59,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          Positioned.fill(
            left: 25,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF292929), width: 1),
                color: const Color(0xFF101010),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: double.infinity,
                    child: _ReferenceCropImage(source: item.source),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          key: ValueKey<String>(
                            'discover-trending-${item.rank}-name',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: TmTypography.family,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const _TiltedMicIcon(),
                            const SizedBox(width: 5),
                            Text(
                              'Pop',
                              key: ValueKey<String>(
                                'discover-trending-${item.rank}-genre',
                              ),
                              style: TextStyle(
                                color: Color(0xFFC8C8CA),
                                fontFamily: TmTypography.family,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 13),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 27,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(left: 0, child: _OutlinedRank(value: item.rank)),
        ],
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

class _TiltedMicIcon extends StatelessWidget {
  const _TiltedMicIcon();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.65,
      child: const Icon(
        Icons.mic_none_rounded,
        size: 14,
        color: Color(0xFFC8C8CA),
      ),
    );
  }
}

class _ReferenceCardSection extends StatelessWidget {
  const _ReferenceCardSection({
    required this.title,
    required this.cards,
    this.compact = false,
  });

  final String title;
  final List<_ReferenceFeatureCardData> cards;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = compact
        ? (screenWidth * 0.31).clamp(118.0, 144.0).toDouble()
        : (screenWidth * 0.41).clamp(148.0, 178.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: Text(
            title,
            key: ValueKey<String>('discover-section-$title'),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: TmTypography.family,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.15,
            ),
          ),
        ),
        const SizedBox(height: 17),
        SizedBox(
          height: compact ? 132 : 151,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => SizedBox(
              width: cardWidth,
              child: _ReferenceFeatureCard(
                data: cards[index],
                compact: compact,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReferenceFeatureCard extends StatelessWidget {
  const _ReferenceFeatureCard({required this.data, required this.compact});

  final _ReferenceFeatureCardData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: _ReferenceCropImage(source: data.source),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            data.title,
            key: ValueKey<String>('discover-city-${data.title}-title'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: TmTypography.family,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: _ReferenceCropImage(source: data.source),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(7, 7, 6, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    key: ValueKey<String>(
                      'discover-card-${data.title}-title',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: TmTypography.family,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.subtitle,
                    key: ValueKey<String>(
                      'discover-card-${data.title}-subtitle',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFD1D1D3),
                      fontFamily: TmTypography.family,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
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

class _ReferenceCropImage extends StatelessWidget {
  const _ReferenceCropImage({
    required this.source,
    this.asset = TmAssets.discoverReference,
  });

  static const _fullWidth = 828.0;
  static const _fullHeight = 1792.0;
  final Rect source;
  final String asset;

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
                width: _fullWidth * scale,
                height: _fullHeight * scale,
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

class _ReferenceTrendingItem {
  const _ReferenceTrendingItem({
    required this.rank,
    required this.name,
    required this.source,
  });

  final String rank;
  final String name;
  final Rect source;
}

class _ReferenceFeatureCardData {
  const _ReferenceFeatureCardData({
    required this.title,
    required this.subtitle,
    required this.source,
  });

  final String title;
  final String subtitle;
  final Rect source;
}

const _referenceTrending = <_ReferenceTrendingItem>[
  _ReferenceTrendingItem(
    rank: '01',
    name: 'Shakira',
    source: Rect.fromLTWH(83, 458, 158, 114),
  ),
  _ReferenceTrendingItem(
    rank: '02',
    name: 'Morat',
    source: Rect.fromLTWH(83, 594, 158, 116),
  ),
  _ReferenceTrendingItem(
    rank: '03',
    name: 'Hombres G',
    source: Rect.fromLTWH(83, 730, 158, 116),
  ),
  _ReferenceTrendingItem(
    rank: '04',
    name: 'TINI',
    source: Rect.fromLTWH(34, 1054, 336, 200),
  ),
  _ReferenceTrendingItem(
    rank: '05',
    name: 'Gracie Abrams',
    source: Rect.fromLTWH(390, 1054, 336, 200),
  ),
  _ReferenceTrendingItem(
    rank: '06',
    name: 'Lola Índigo',
    source: Rect.fromLTWH(586, 1492, 240, 150),
  ),
];

const _referenceTopPicks = <_ReferenceFeatureCardData>[
  _ReferenceFeatureCardData(
    title: 'TINI',
    subtitle: '',
    source: Rect.fromLTWH(34, 1054, 336, 200),
  ),
  _ReferenceFeatureCardData(
    title: 'GRACIE ABRAMS',
    subtitle: 'The Look at My Life Tour',
    source: Rect.fromLTWH(390, 1054, 336, 200),
  ),
  _ReferenceFeatureCardData(
    title: 'SHAKIRA',
    subtitle: 'Las Mujeres Ya No Lloran',
    source: Rect.fromLTWH(83, 458, 158, 114),
  ),
];

const _referenceCityGuides = <_ReferenceFeatureCardData>[
  _ReferenceFeatureCardData(
    title: 'Barcelona',
    subtitle: '',
    source: Rect.fromLTWH(34, 1492, 256, 150),
  ),
  _ReferenceFeatureCardData(
    title: 'Madrid',
    subtitle: '',
    source: Rect.fromLTWH(309, 1492, 258, 150),
  ),
  _ReferenceFeatureCardData(
    title: 'Granada',
    subtitle: '',
    source: Rect.fromLTWH(586, 1492, 240, 150),
  ),
];

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
    return const SafeArea(child: _ForYouEmptyState());
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

  bool _isPastTicket(_TicketListEntry ticket) {
    final value = ticket.editableDateLabel.toUpperCase();
    const months = <String, int>{
      'JAN': 1,
      'FEB': 2,
      'MAR': 3,
      'APR': 4,
      'MAY': 5,
      'JUN': 6,
      'JUL': 7,
      'AUG': 8,
      'SEP': 9,
      'OCT': 10,
      'NOV': 11,
      'DEC': 12,
    };
    final monthFirst = RegExp(
      r'\b(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\s+(\d{1,2}),?\s+(\d{4})\b',
    ).firstMatch(value);
    final dayFirst = RegExp(
      r'\b(\d{1,2})\s+(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC),?\s+(\d{4})\b',
    ).firstMatch(value);
    final monthName = monthFirst?.group(1) ?? dayFirst?.group(2);
    final dayValue = monthFirst?.group(2) ?? dayFirst?.group(1);
    final yearValue = monthFirst?.group(3) ?? dayFirst?.group(3);
    final month = months[monthName];
    final day = int.tryParse(dayValue ?? '');
    final year = int.tryParse(yearValue ?? '');
    if (month == null || day == null || year == null) return false;
    final eventDay = DateTime(year, month, day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return eventDay.isBefore(today);
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
      final croppedSelection =
          await Navigator.of(context).push<TicketCardImageSelection>(
        MaterialPageRoute(
          builder: (context) => TicketCardImageCropPage(
            imageBytes: bytes,
            targetAspectRatio: ((MediaQuery.sizeOf(context).width - 28) / 180)
                .clamp(1.6, 2.4)
                .toDouble(),
          ),
        ),
      );
      if (!mounted || croppedSelection == null) {
        return;
      }
      setState(() {
        _upcomingTickets = _upcomingTickets.map((ticket) {
          if (ticket.id != ticketId) {
            return ticket;
          }
          return ticket.copyWith(imageSelection: croppedSelection);
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
    final filteredTickets = _visibleUpcomingTickets;
    final upcomingTickets = _upcomingTickets
        .where((ticket) => !_isPastTicket(ticket))
        .toList(growable: false);
    final pastTickets =
        _upcomingTickets.where(_isPastTicket).toList(growable: false);
    final visibleTickets = filteredTickets
        .where(
          (ticket) =>
              _showPastEvents ? _isPastTicket(ticket) : !_isPastTicket(ticket),
        )
        .toList(growable: false);
    final hasSearchQuery = _searchQuery.trim().isNotEmpty;

    return Container(
      color: _showPastEvents ? const Color(0xFF101010) : Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TicketsHeader(
              upcomingCount: upcomingTickets.length,
              pastCount: pastTickets.length,
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
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                      itemCount: visibleTickets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
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
                          eventLabel:
                              _showPastEvents ? 'PAST EVENT' : 'UPCOMING EVENT',
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
    );
  }
}

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: _SellLanding());
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
            const _AccountMenuGroup(
              rows: [
                _AccountMenuRowData(
                  icon: Icons.mail_outline_rounded,
                  label: 'My Inbox',
                  textKey: 'account-row-inbox',
                ),
                _AccountMenuRowData(
                  icon: Icons.favorite_border_rounded,
                  label: 'Favourites',
                  textKey: 'account-row-favourites',
                ),
                _AccountMenuRowData(
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
      color: const Color(0xFF101010),
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
                      const Text(
                        'My Events',
                        key: ValueKey<String>('my-events-title'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
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
            height: 59,
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
                            'UPCOMING ($upcomingCount)',
                            style: TextStyle(
                              color: showPastEvents
                                  ? const Color(0xFFB9B9BB)
                                  : Colors.white,
                              fontSize: 14.5,
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
                            'PAST ($pastCount)',
                            style: TextStyle(
                              color: showPastEvents
                                  ? Colors.white
                                  : const Color(0xFFB9B9BB),
                              fontSize: 14.5,
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
    final foreground = showPastEvents ? Colors.white : const Color(0xFF111111);
    final secondary =
        showPastEvents ? const Color(0xFFC7C7C7) : const Color(0xFF111111);
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
                color: Color(0xFF20242A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try another ticket name or keyword.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF707780),
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
