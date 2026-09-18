part of 'package:ticketmaster/main.dart';

class _MyTicketDetailsPage extends StatefulWidget {
  const _MyTicketDetailsPage({required this.ticket, required this.ticketCount});

  final _TicketListEntry ticket;
  final int ticketCount;

  @override
  State<_MyTicketDetailsPage> createState() => _MyTicketDetailsPageState();
}

class _MyTicketDetailsPageState extends State<_MyTicketDetailsPage> {
  static const double _ticketPagerHeight = 174;

  final PageController _ticketPageController = PageController();
  int _activeTicketPage = 0;

  @override
  void dispose() {
    _ticketPageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int page) {
    if (_activeTicketPage == page) {
      return;
    }
    setState(() {
      _activeTicketPage = page;
    });
  }

  void _handleDotTap(int index) {
    if (_activeTicketPage == index) {
      return;
    }
    _ticketPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _V2TicketTheme(
        child: DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  _V2EventAppBar(
                      ticket: widget.ticket, ticketCount: widget.ticketCount),
                  const SliverPersistentHeader(
                      pinned: true, delegate: _V2EventTabsDelegate()),
                ],
                body: TabBarView(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 108),
                      children: [
                        const Text('Order #51-52844/ARZ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                        Text('x${widget.ticketCount} Ticket',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: _ticketPagerHeight *
                              MediaQuery.textScalerOf(context).scale(14) /
                              14,
                          child: PageView.builder(
                            controller: _ticketPageController,
                            itemCount: widget.ticketCount,
                            onPageChanged: _handlePageChanged,
                            itemBuilder: (context, index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: _MyTicketDetailsCard(
                                  ticket: widget.ticket,
                                  ticketCount: widget.ticketCount,
                                  ticketPageIndex: index),
                            ),
                          ),
                        ),
                        if (widget.ticketCount > 1) ...[
                          const SizedBox(height: 8),
                          _TicketPagerDots(
                              count: widget.ticketCount,
                              activeIndex: _activeTicketPage,
                              onDotTap: _handleDotTap),
                        ],
                        const SizedBox(height: 20),
                        const _DetailMapCard(),
                        const SizedBox(height: 12),
                        const _DarkActionButton(
                            label: 'Get Directions', height: 38, fontSize: 13),
                      ],
                    ),
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
                      children: [
                        Text('Get Ready For ${widget.ticket.singleLineTitle}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        const Text(
                            'Plan ahead and take advantage of these great offers.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 24),
                        const ListTile(
                            leading:
                                Icon(Icons.local_parking, color: Colors.white),
                            title: Text('COORS FIELD EVENT PARKING',
                                style: TextStyle(color: Colors.white)),
                            trailing:
                                Icon(Icons.chevron_right, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Center(
                  child: _V2EventActions(onTransfer: () {
                    Navigator.of(context).push(_TransferPageRoute(
                        ticket: widget.ticket,
                        ticketCount: widget.ticketCount));
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class _MyTicketDetailsHeader extends StatelessWidget {
  const _MyTicketDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Color(0xFF111111),
      child: TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        indicatorColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Color(0xFF454545),
        tabs: [
          Tab(
              child: Text('Tickets',
                  key: _V2LegacyTextKey('MY TICKETS'),
                  style: TextStyle(fontSize: 13))),
          Tab(
              child: Text('Extras',
                  key: _V2LegacyTextKey('ADD-ONS'),
                  style: TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _MyTicketDetailsCard extends StatelessWidget {
  const _MyTicketDetailsCard({
    required this.ticket,
    required this.ticketCount,
    required this.ticketPageIndex,
  });

  final _TicketListEntry ticket;
  final int ticketCount;
  final int ticketPageIndex;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF232323),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Standard Ticket',
                    key: ValueKey<String>(ticket.ticketInstanceTextKey(
                        ticketPageIndex, 'standard-ticket-label')),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const Divider(height: 1, color: Color(0xFF111111)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              child: Row(
                children: [
                  for (final stat in const [
                    ('SEC', '402', 'section'),
                    ('ROW', '5', 'row'),
                    ('SEAT', '1', 'seat')
                  ])
                    Expanded(
                        child: _TicketStatItem(
                      foreground: Colors.white,
                      label: stat.$1,
                      value: stat.$2,
                      labelTextKey: ticket.ticketInstanceTextKey(
                          ticketPageIndex, '${stat.$3}-label'),
                      valueTextKey: ticket.ticketInstanceTextKey(
                          ticketPageIndex, '${stat.$3}-value'),
                    )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                      child: Text('Mobile',
                          key: ValueKey<String>(ticket.ticketInstanceTextKey(
                              ticketPageIndex, 'mobile-label')),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white60))),
                  Flexible(child: _TicketDetailsLink(onTap: () {
                    Navigator.of(context).push(_TicketDetailsInfoRoute(
                        ticket: ticket, ticketPageIndex: ticketPageIndex));
                  })),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketStatItem extends StatelessWidget {
  const _TicketStatItem({
    required this.label,
    required this.value,
    this.labelTextKey,
    this.valueTextKey,
    this.foreground = const Color(0xFF252525),
  });

  final String label;
  final String value;
  final String? labelTextKey;
  final String? valueTextKey;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          key: labelTextKey == null ? null : ValueKey<String>(labelTextKey!),
          style: TextStyle(
            color: foreground,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          value,
          key: valueTextKey == null ? null : ValueKey<String>(valueTextKey!),
          style: TextStyle(
            color: foreground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _DarkActionButton extends StatelessWidget {
  const _DarkActionButton({
    required this.label,
    required this.height,
    this.icon,
    this.onPressed,
    this.fontSize = 14,
  });

  final String label;
  final double height;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF064DE0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 8),
            ],
            Flexible(
                child: Text(
              label,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
            )),
          ],
        ),
      ),
    );
  }
}

class _TicketDetailsLink extends StatelessWidget {
  const _TicketDetailsLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'Ticket Details',
          style: TextStyle(
            color: Color(0xFF2188FF),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TicketPagerDots extends StatelessWidget {
  const _TicketPagerDots({
    required this.count,
    required this.activeIndex,
    required this.onDotTap,
  });

  final int count;
  final int activeIndex;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 22,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(count, (index) {
                return Padding(
                  padding: EdgeInsets.only(right: index == count - 1 ? 0 : 10),
                  child: GestureDetector(
                    onTap: () => onDotTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: Center(
                        child: _PagerDot(active: index == activeIndex),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: 6),
          Text(
            '${activeIndex + 1} / $count',
            style: const TextStyle(
              color: Color(0xFF49515A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _PagerDot extends StatelessWidget {
  const _PagerDot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? const Color(0xFF444D57) : const Color(0xFFCED2D7),
      ),
    );
  }
}

class _ViewTicketPage extends StatefulWidget {
  const _ViewTicketPage({required this.ticket, required this.ticketCount});

  final _TicketListEntry ticket;
  final int ticketCount;

  @override
  State<_ViewTicketPage> createState() => _ViewTicketPageState();
}

class _ViewTicketPageState extends State<_ViewTicketPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanLineController;
  late final PageController _ticketPageController;
  late int _activeTicketPage;

  @override
  void initState() {
    super.initState();
    _activeTicketPage = widget.ticketCount - 1;
    _ticketPageController = PageController(initialPage: _activeTicketPage);
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  void _goToPreviousPage() {
    if (_activeTicketPage <= 0) {
      return;
    }
    _ticketPageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToNextPage() {
    if (_activeTicketPage >= widget.ticketCount - 1) {
      return;
    }
    _ticketPageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _ticketPageController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return _V2TicketTheme(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                color: const Color(0xFFFFFFFF),
                padding: EdgeInsets.only(top: topInset),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: const SizedBox(
                              width: 52,
                              child: Icon(
                                Icons.arrow_back,
                                color: Color(0xFF18212A),
                                size: 36 / 2,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.ticket.singleLineTitle,
                                  key: ValueKey<String>(
                                    widget.ticket.textKey('title'),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF18212A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.ticket.detailsSubtitle,
                                  key: ValueKey<String>(
                                    widget.ticket.textKey('subtitle'),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF697078),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Help',
                            style: TextStyle(
                              color: Color(0xFF18212A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: double.infinity,
                      height: 1,
                      child: ColoredBox(color: Color(0xFFF0F0F0)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _ticketPageController,
                        itemCount: widget.ticketCount,
                        onPageChanged: (index) {
                          setState(() {
                            _activeTicketPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return _ViewTicketFrame(
                            lineAnimation: _scanLineController,
                            ticket: widget.ticket,
                            ticketPageIndex: index,
                          );
                        },
                      ),
                    ),
                    _TicketPagerFooter(
                      currentPage: _activeTicketPage + 1,
                      totalPages: widget.ticketCount,
                      onPrevious:
                          _activeTicketPage > 0 ? _goToPreviousPage : null,
                      onNext: _activeTicketPage < widget.ticketCount - 1
                          ? _goToNextPage
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class _ViewTicketFrame extends StatelessWidget {
  const _ViewTicketFrame({
    required this.lineAnimation,
    required this.ticket,
    required this.ticketPageIndex,
  });

  final Animation<double> lineAnimation;
  final _TicketListEntry ticket;
  final int ticketPageIndex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      child: Column(
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: const Color(0xFF350575),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Text('ticketmaster',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700)),
                ),
                Container(
                  color: const Color(0xFF350575),
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                  child: _TicketBarcodeCard(lineAnimation: lineAnimation),
                ),
                AspectRatio(
                    aspectRatio: 2.15,
                    child: _V2TicketArtwork(selection: ticket.imageSelection)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Standard Ticket',
                          key: ValueKey<String>(ticket.ticketInstanceTextKey(
                              ticketPageIndex, 'standard-ticket-label')),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 5),
                      Text(ticket.singleLineTitle,
                          key: ValueKey<String>(ticket.textKey('title')),
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF555555))),
                      Text(ticket.editableDateLabel,
                          key: ValueKey<String>(ticket.textKey('date')),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF555555))),
                      Text(ticket.primaryVenue,
                          key: ValueKey<String>(ticket.textKey('venue-line')),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF555555))),
                      const Divider(height: 28, color: Color(0xFFE8E8E8)),
                      Row(children: [
                        Expanded(
                            child: _TicketStatItem(
                                label: 'SEC',
                                value: 'GA',
                                labelTextKey: ticket.ticketInstanceTextKey(
                                    ticketPageIndex, 'section-label'),
                                valueTextKey: ticket.ticketInstanceTextKey(
                                    ticketPageIndex, 'section-value'))),
                        Expanded(
                            child: _TicketStatItem(
                                label: 'ROW',
                                value: '5',
                                labelTextKey: ticket.ticketInstanceTextKey(
                                    ticketPageIndex, 'row-label'),
                                valueTextKey: ticket.ticketInstanceTextKey(
                                    ticketPageIndex, 'row-value'))),
                        Expanded(
                            child: _TicketStatItem(
                                label: 'SEAT',
                                value: '1',
                                labelTextKey: ticket.ticketInstanceTextKey(
                                    ticketPageIndex, 'seat-label'),
                                valueTextKey: ticket.ticketInstanceTextKey(
                                    ticketPageIndex, 'seat-value'))),
                      ]),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        color: const Color(0xFF303133),
                        padding: const EdgeInsets.all(12),
                        child: const Text('BOOKMARK',
                            key: _V2LegacyTextKey('Mobile'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF263A48),
                  backgroundColor: const Color(0xFFF5F6F8),
                  side: const BorderSide(color: Color(0xFFE9EAED)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
              icon: const Icon(Icons.account_balance_wallet,
                  color: Color(0xFF1684D5), size: 22),
              label: const Text('Add to Google Wallet',
                  key: _V2LegacyTextKey('Add to Apple Wallet'),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 8),
            Expanded(
                child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                  _TicketDetailsInfoRoute(
                      ticket: ticket, ticketPageIndex: ticketPageIndex)),
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF263A48),
                  backgroundColor: const Color(0xFFF5F6F8),
                  side: const BorderSide(color: Color(0xFFE9EAED)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
              icon: const Icon(Icons.info, size: 22),
              label:
                  const Text('Ticket Details', style: TextStyle(fontSize: 11)),
            )),
          ]),
          const SizedBox(height: 16),
          const _TicketEntranceStrip(),
        ],
      ),
    );
  }
}

class _TicketBarcodeCard extends StatelessWidget {
  const _TicketBarcodeCard({required this.lineAnimation});

  final Animation<double> lineAnimation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Scan for entry at gate',
                    key: _V2LegacyTextKey("Screenshots won't get you in."),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1E1F21),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.refresh, size: 32 / 2, color: Color(0xFF161718)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 66,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const CustomPaint(painter: _BarcodePainter()),
                    AnimatedBuilder(
                      animation: lineAnimation,
                      builder: (context, child) {
                        return Align(
                          alignment: Alignment(
                            -1 + (lineAnimation.value * 2),
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 4,
                        color: const Color(0xFF0B7DFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  const _BarcodePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    var x = 0.0;
    const widths = <double>[
      3,
      1,
      2,
      1,
      4,
      2,
      1,
      3,
      2,
      1,
      5,
      1,
      2,
      3,
      1,
      2,
      4,
      1,
      2,
      1,
      3,
      1,
      2,
      3,
      1,
      5,
      2,
      1,
      4,
      1,
      3,
      2,
      1,
      4,
      2,
      1,
      2,
      5,
      1,
      2,
      3,
      1,
      4,
      1,
      2,
      3,
      1,
      2,
      4,
      1,
    ];
    var i = 0;
    while (x < size.width) {
      final barWidth = widths[i % widths.length];
      canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), paint);
      x += barWidth + 1.2;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TicketEntranceStrip extends StatelessWidget {
  const _TicketEntranceStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F6F8),
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 12),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENTRANCE',
            style: TextStyle(
              color: Color(0xFF263A48),
              fontSize: 30 / 2,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 1),
          Text(
            'GENERAL ADMISSN',
            style: TextStyle(
              color: Color(0xFF697078),
              fontSize: 24 / 2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketPagerFooter extends StatelessWidget {
  const _TicketPagerFooter({
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onPrevious,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.chevron_left,
              color: onPrevious == null
                  ? const Color(0xFFCDD2D7)
                  : const Color(0xFF697078),
              size: 38 / 2,
            ),
          ),
          const SizedBox(width: 24),
          Text(
            '$currentPage of $totalPages',
            style: const TextStyle(
              color: Color(0xFF263A48),
              fontSize: 32 / 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: onNext,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.chevron_right,
              color: onNext == null
                  ? const Color(0xFFCDD2D7)
                  : const Color(0xFF697078),
              size: 38 / 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferPage extends StatefulWidget {
  const _TransferPage({required this.ticket, required this.ticketCount});

  final _TicketListEntry ticket;
  final int ticketCount;

  @override
  State<_TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<_TransferPage> {
  late final PageController _ticketPreviewController;
  int _activePreview = 0;

  @override
  void initState() {
    super.initState();
    _ticketPreviewController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _ticketPreviewController.dispose();
    super.dispose();
  }

  Future<void> _openTransferFlowSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (sheetContext) {
        return _TransferFlowSheet(ticketCount: widget.ticketCount);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _V2TicketTheme(
        child: Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        top: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _V2EventAppBar(
                ticket: widget.ticket, ticketCount: widget.ticketCount),
            const SliverToBoxAdapter(child: _TransferTabStrip()),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Column(
              children: [
                _TransferTicketActionsCard(
                  ticket: widget.ticket,
                  ticketCount: widget.ticketCount,
                  onTransferTap: _openTransferFlowSheet,
                ),
                const SizedBox(height: 10),
                const _TransferReadyInfoCard(),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD7D7D7)),
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 320,
                        child: PageView.builder(
                          controller: _ticketPreviewController,
                          itemCount: widget.ticketCount,
                          onPageChanged: (index) {
                            setState(() {
                              _activePreview = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: _TransferTicketPreviewCard(
                                ticket: widget.ticket,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 6),
                      _TransferPagerDots(
                        count: widget.ticketCount,
                        activeIndex: _activePreview,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const _TransferOrderCard(),
                const SizedBox(height: 12),
                const _TransferOfferCard(),
                const SizedBox(height: 12),
                _TransferHeader(ticket: widget.ticket),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class _TransferHeader extends StatelessWidget {
  const _TransferHeader({required this.ticket});

  final _TicketListEntry ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF232427),
      padding: const EdgeInsets.fromLTRB(6, 8, 8, 8),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 30,
                  child: Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.singleLineTitle,
                      key: ValueKey<String>(ticket.textKey('title')),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      ticket.detailsSubtitle,
                      key: ValueKey<String>(ticket.textKey('subtitle')),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xD9FFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: const Color(0xFF4B4B4B)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: const Row(
              children: [
                Expanded(
                    child: Text(
                  "Share You're Going",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                )),
                SizedBox(width: 8),
                _TransferSocialIcon(label: 'X'),
                SizedBox(width: 4),
                _TransferSocialIcon(label: 'f'),
                SizedBox(width: 4),
                _TransferSocialIcon(label: 'm'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferSocialIcon extends StatelessWidget {
  const _TransferSocialIcon({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E1F23),
        ),
      ),
    );
  }
}

class _TransferTabStrip extends StatelessWidget {
  const _TransferTabStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: TmColors.brandBlue,
      child: const Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Tickets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Event Info',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Venue Info',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferTicketActionsCard extends StatelessWidget {
  const _TransferTicketActionsCard({
    required this.ticket,
    required this.ticketCount,
    required this.onTransferTap,
  });

  final _TicketListEntry ticket;
  final int ticketCount;
  final VoidCallback onTransferTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7D7D7)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ticket.singleLineTitle,
            key: ValueKey<String>(ticket.textKey('title')),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1F2022),
              fontSize: 28 / 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.confirmation_num_outlined,
                size: 16,
                color: Color(0xFF646464),
              ),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(
                'x$ticketCount Mobile Tickets',
                style: const TextStyle(
                  color: Color(0xFF2A2A2A),
                  fontSize: 26 / 2,
                  fontWeight: FontWeight.w500,
                ),
              )),
              const SizedBox(width: 8),
              const Flexible(
                  child: Text(
                'View on Map',
                style: TextStyle(
                  color: Color(0xFF2A5CA9),
                  fontSize: 24 / 2,
                  decoration: TextDecoration.underline,
                ),
              )),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Sell',
                style: TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 26 / 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.refresh, color: Color(0xFFE05A84), size: 15),
            ],
          ),
          const SizedBox(height: 7),
          _DarkActionButton(
            label: 'Transfer  ↗',
            height: 34,
            fontSize: 15,
            onPressed: onTransferTap,
          ),
        ],
      ),
    );
  }
}

enum _TransferSheetStep { selectTickets, transferTo, recipientForm }

class _TransferFlowSheet extends StatefulWidget {
  const _TransferFlowSheet({required this.ticketCount});

  final int ticketCount;

  @override
  State<_TransferFlowSheet> createState() => _TransferFlowSheetState();
}

class _TransferFlowSheetState extends State<_TransferFlowSheet> {
  _TransferSheetStep _step = _TransferSheetStep.selectTickets;
  final Set<int> _selectedTicketIndexes = <int>{};

  int get _selectedCount => _selectedTicketIndexes.length;

  void _toggleTicket(int index) {
    setState(() {
      if (_selectedTicketIndexes.contains(index)) {
        _selectedTicketIndexes.remove(index);
      } else {
        _selectedTicketIndexes.add(index);
      }
    });
  }

  void _goToRecipientStep() {
    if (_selectedCount == 0) return;
    setState(() {
      _step = _TransferSheetStep.transferTo;
    });
  }

  void _goBackToSelection() {
    setState(() {
      _step = _TransferSheetStep.selectTickets;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          duration: media.viewInsets.bottom > 0
              ? Duration.zero
              : const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: (media.size.height * 0.58 + media.viewInsets.bottom)
              .clamp(0.0, media.size.height - media.padding.top - 48),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.zero,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _step == _TransferSheetStep.selectTickets
                ? _TransferTicketSelectionStep(
                    key: const ValueKey('ticket-selection'),
                    ticketCount: widget.ticketCount,
                    selectedCount: _selectedCount,
                    selectedIndexes: _selectedTicketIndexes,
                    onToggleTicket: _toggleTicket,
                    onContinue: _goToRecipientStep,
                  )
                : _step == _TransferSheetStep.recipientForm
                    ? _TransferRecipientForm(
                        key: const ValueKey('recipient-form'),
                        selectedCount: _selectedCount,
                        onBack: () => setState(
                            () => _step = _TransferSheetStep.transferTo),
                      )
                    : _TransferRecipientStep(
                        key: const ValueKey('recipient-step'),
                        selectedCount: _selectedCount,
                        bottomInset: media.padding.bottom,
                        onBack: _goBackToSelection,
                        onManual: () => setState(
                            () => _step = _TransferSheetStep.recipientForm),
                      ),
          ),
        ),
      ),
    );
  }
}

class _TransferTicketSelectionStep extends StatelessWidget {
  const _TransferTicketSelectionStep({
    super.key,
    required this.ticketCount,
    required this.selectedCount,
    required this.selectedIndexes,
    required this.onToggleTicket,
    required this.onContinue,
  });

  final int ticketCount;
  final int selectedCount;
  final Set<int> selectedIndexes;
  final ValueChanged<int> onToggleTicket;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final transferEnabled = selectedCount > 0;

    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
                child: Column(children: [
          const SizedBox(height: 24),
          const Text(
            'Select Tickets to Transfer',
            style: TextStyle(
              color: Color(0xFF363A40),
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Sec GA',
                  style: TextStyle(
                    color: Color(0xFF26292E),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.confirmation_num_outlined,
                  size: 16,
                  color: Color(0xFFB9C3CF),
                ),
                const SizedBox(width: 5),
                Text(
                  '$ticketCount tickets',
                  style: const TextStyle(
                    color: Color(0xFFB0BAC6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 84,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: ticketCount,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _TransferSelectableTicketTile(
                  label: 'TICKET ${index + 1}',
                  selected: selectedIndexes.contains(index),
                  onTap: () => onToggleTicket(index),
                );
              },
            ),
          ),
        ]))),
        const Divider(height: 1, color: Color(0xFFE3E4E7)),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomInset),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedCount == 0 ? '' : '$selectedCount Selected',
                  style: const TextStyle(
                    color: Color(0xFFB0BAC6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: transferEnabled ? onContinue : null,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      'Transfer To',
                      style: TextStyle(
                        color: transferEnabled
                            ? const Color(0xFF1472D0)
                            : const Color(0xFFB0BAC6),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: transferEnabled
                          ? const Color(0xFF1472D0)
                          : const Color(0xFFB0BAC6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransferSelectableTicketTile extends StatelessWidget {
  const _TransferSelectableTicketTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 78,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF064DE0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF1E80E5) : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF1E80E5)
                          : const Color(0xFF8C9198),
                      width: 1.6,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferRecipientStep extends StatelessWidget {
  const _TransferRecipientStep({
    super.key,
    required this.selectedCount,
    required this.bottomInset,
    required this.onBack,
    this.onManual,
  });

  final int selectedCount;
  final double bottomInset;
  final VoidCallback onBack;
  final VoidCallback? onManual;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
                child: Column(children: [
          const SizedBox(height: 26),
          const Text(
            'Transfer To',
            style: TextStyle(
              color: Color(0xFF363A40),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                const _TransferRecipientButton(
                  label: 'SELECT FROM CONTACTS',
                  icon: Icons.contacts_outlined,
                ),
                const SizedBox(height: 12),
                _TransferRecipientButton(
                  label: 'MANUALLY ENTER A RECIPIENT',
                  icon: Icons.add_circle_outline,
                  onPressed: onManual,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mail_outline,
              size: 34,
              color: Color(0xFF444444),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Transfer Tickets Via Email or Text Message',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF3D434A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 34),
            child: Text(
              'Select Email or mobile number to transfer tickets to your recipient.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF58606A),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ]))),
        const Divider(height: 1, color: Color(0xFFE3E4E7)),
        Padding(
          padding: EdgeInsets.fromLTRB(18, 14, 18, 14 + bottomInset),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: const Row(
                  children: [
                    Icon(
                      Icons.chevron_left,
                      color: Color(0xFF1472D0),
                      size: 24,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: Color(0xFF1472D0),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransferRecipientButton extends StatelessWidget {
  const _TransferRecipientButton(
      {required this.label, required this.icon, this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1472D0),
          side: const BorderSide(color: Color(0xFF1472D0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 5,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            Icon(icon, size: 24),
          ],
        ),
      ),
    );
  }
}

class _TransferReadyInfoCard extends StatelessWidget {
  const _TransferReadyInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7D7D7)),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: double.infinity,
            height: 4,
            child: ColoredBox(color: TmColors.brandBlue),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: TmColors.brandBlue,
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Your Tickets Are Ready',
                      style: TextStyle(
                        color: Color(0xFF2A2A2A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 24),
                  child: Text(
                    'Your phone is your ticket - display your tickets below\n'
                    'from your phone prior to the Ticketmaster App so they\n'
                    'can be scanned at the venue',
                    style: TextStyle(
                      color: Color(0xFF505050),
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Container(
                    height: 24,
                    width: 90,
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: const Text(
                      'Google Play',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
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

class _TransferTicketPreviewCard extends StatelessWidget {
  const _TransferTicketPreviewCard({required this.ticket});

  final _TicketListEntry ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD5D5D5)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 20,
            color: TmColors.brandBlue,
            alignment: Alignment.center,
            child: const Text(
              'ticketmaster',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  Text(
                    ticket.primaryVenue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.singleLineTitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF101010),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'REF: TKT-${ticket.id.toString().padLeft(3, '0')}-1',
                    style: const TextStyle(
                      color: Color(0xFF545454),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 62,
                    width: double.infinity,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFD4D4D4)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const CustomPaint(painter: _BarcodePainter()),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Screenshots won't get you in.",
                    style: TextStyle(color: Color(0xFF555555), fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 26,
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: Text(
                      ticket.primaryVenue.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 136,
                    height: 28,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.account_balance_wallet,
                        size: 14,
                        color: Color(0xFFFFB347),
                      ),
                      label: const Text(
                        'Add to Google Wallet',
                        style: TextStyle(
                          fontSize: 21 / 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Text(
                        '\$0.00',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '\$0.00',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferPagerDots extends StatelessWidget {
  const _TransferPagerDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 12,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(count, (index) {
                final active = index == activeIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 7 : 6,
                  height: active ? 7 : 6,
                  decoration: BoxDecoration(
                    color:
                        active ? TmColors.brandBlue : const Color(0xFFC4C9D0),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: 6),
          Text(
            '${activeIndex + 1} / $count',
            style: const TextStyle(
              color: Color(0xFF657180),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _TransferOrderCard extends StatelessWidget {
  const _TransferOrderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7D7D7)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Your Order',
            style: TextStyle(
              color: Color(0xFF232323),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.receipt_long, size: 16, color: Color(0xFF666666)),
              SizedBox(width: 6),
              Expanded(
                  child: Text(
                'Order #\n51-52844/ARZ',
                style: TextStyle(
                  color: Color(0xFF4B4B4B),
                  fontSize: 12,
                  height: 1.2,
                ),
              )),
              SizedBox(width: 8),
              Flexible(
                  child: Text(
                'View Order Receipt',
                style: TextStyle(
                  color: Color(0xFF2A5CA9),
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              )),
            ],
          ),
          SizedBox(height: 10),
          Divider(height: 1, color: Color(0xFFE2E2E2)),
          SizedBox(height: 9),
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: TmColors.brandBlue,
              ),
              SizedBox(width: 6),
              Text(
                'Chat With Us',
                style: TextStyle(
                  color: TmColors.brandBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Text(
            'To learn more about this order',
            style: TextStyle(color: Color(0xFF666666), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TransferOfferCard extends StatelessWidget {
  const _TransferOfferCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(2, 0, 2, 8),
          child: Text(
            "You've Unlocked These Offers",
            style: TextStyle(
              color: Color(0xFF222222),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD7D7D7)),
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE8F0FF), Color(0xFFFFFFFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Column(
                  children: [
                    Text(
                      'ticketmaster',
                      style: TextStyle(
                        color: Color(0xFF1572D6),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'HOTELS',
                      style: TextStyle(
                        color: Color(0xFF1572D6),
                        fontSize: 16,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: const Color(0xFFFFEB54),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: const Text(
                  'UP TO 57% OFF HOTELS',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Stay The Night For Prelude To A Twist: Jeremy Aye And Nancy Kamen.',
                style: TextStyle(
                  color: Color(0xFF161616),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find top rated hotels near your event, book fully refundable rooms, and enjoy up to 57% off.',
                style: TextStyle(
                  color: Color(0xFF646464),
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TmColors.brandBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  child: const Text(
                    'Unlock Hotel Deals',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Center(
            child: Text(
              'Powered by Roic | Privacy Policy',
              style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketDetailsInfoPage extends StatelessWidget {
  const _TicketDetailsInfoPage({
    required this.ticket,
    required this.ticketPageIndex,
  });

  static const _dividerColor = Color(0xFFD0D2D4);
  final _TicketListEntry ticket;
  final int ticketPageIndex;

  @override
  Widget build(BuildContext context) {
    return _V2TicketTheme(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _V2TicketInformationHeader(ticket: ticket),
                const TabBar(
                  labelColor: Color(0xFF17232E),
                  unselectedLabelColor: Color(0xFF777777),
                  indicatorColor: Color(0xFF064DE0),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(text: 'Ticket Details'),
                    Tab(text: 'Event Information')
                  ],
                ),
                Expanded(
                  child: TabBarView(children: [
                    ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('ORDER DETAILS',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700))),
                        const _TicketInfoRow(
                            title: 'Order Number', value: '51-52844/ARZ'),
                        const _TicketInfoRow(
                            title: 'Purchase Date', value: 'Sat, Feb 21 2026'),
                        const _TicketPriceSection(),
                        const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('TICKET INFORMATION',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700))),
                        const _TicketInfoRow(
                            title: 'Ticket Type', value: 'Mobile'),
                        _TicketDetailsTopSection(
                            ticket: ticket, ticketPageIndex: ticketPageIndex),
                        const _TicketInfoRow(
                            title: 'Entry Info', value: 'Mobile'),
                        const _TicketInfoRow(
                            title: 'Barcode Number',
                            value: '363016857385265158a'),
                        _TicketInfoRow(
                            title: 'Entrance',
                            value: ticket.primaryVenue.toUpperCase()),
                        const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('EVENT INFORMATION',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700))),
                        _TicketInfoRow(
                            title: ticket.singleLineTitle,
                            value:
                                '${ticket.editableDateLabel} · ${ticket.editableVenue}'),
                        _TicketInfoRow(
                            title: 'Venue', value: ticket.editableVenue),
                        const _TicketTermsSection(),
                      ],
                    ),
                    ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        _TicketInfoRow(
                            title: 'Event', value: ticket.singleLineTitle),
                        _TicketInfoRow(
                            title: 'Date & Time',
                            value: ticket.editableDateLabel),
                        _TicketInfoRow(
                            title: 'Venue', value: ticket.editableVenue),
                        const Padding(
                            padding: EdgeInsets.all(16),
                            child: _DetailMapCard()),
                        const _TicketTermsSection(),
                      ],
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class _TicketDetailsHeaderBar extends StatelessWidget {
  const _TicketDetailsHeaderBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF263A48))),
        const Expanded(
            child: Text('Ticket Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF263A48),
                    fontSize: 13,
                    fontWeight: FontWeight.w600))),
        const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Help',
                style: TextStyle(color: Color(0xFF263A48), fontSize: 12))),
      ],
    );
  }
}

class _TicketDetailsTopSection extends StatelessWidget {
  const _TicketDetailsTopSection({
    required this.ticket,
    required this.ticketPageIndex,
  });

  final _TicketListEntry ticket;
  final int ticketPageIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _TicketDetailsInfoPage._dividerColor,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEC',
                  key: ValueKey<String>(
                    ticket.ticketInstanceTextKey(
                      ticketPageIndex,
                      'section-label',
                    ),
                  ),
                  style: TextStyle(
                    color: Color(0xFF2A2C2F),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'GA',
                  key: ValueKey<String>(
                    ticket.ticketInstanceTextKey(
                      ticketPageIndex,
                      'section-value',
                    ),
                  ),
                  style: TextStyle(
                    color: Color(0xFF6D747C),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                ticket.primaryVenue,
                style: const TextStyle(
                  color: Color(0xFF2A2C2F),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketInfoRow extends StatelessWidget {
  const _TicketInfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 5,
              child: Text(title,
                  style: const TextStyle(
                      color: Color(0xFF7C8187), fontSize: 12, height: 1.35))),
          const SizedBox(width: 16),
          Expanded(
              flex: 6,
              child: Text(value,
                  style: const TextStyle(
                      color: Color(0xFF292E33), fontSize: 12, height: 1.35))),
        ],
      ),
    );
  }
}

class _TicketPriceSection extends StatelessWidget {
  const _TicketPriceSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _TicketDetailsInfoPage._dividerColor,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ticket Price',
                  style: TextStyle(
                    color: Color(0xFF2A2C2F),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Ticket Face Value',
                  style: TextStyle(
                    color: Color(0xFF6D747C),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Grand Total',
                  style: TextStyle(
                    color: Color(0xFF6D747C),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$0.00',
                  style: TextStyle(
                    color: Color(0xFF6D747C),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '\$0.00',
                  style: TextStyle(
                    color: Color(0xFF6D747C),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _TicketTermsSection extends StatelessWidget {
  const _TicketTermsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _TicketDetailsInfoPage._dividerColor,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms & Conditions',
            style: TextStyle(
              color: Color(0xFF2A2C2F),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                color: Color(0xFF5F666D),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.24,
              ),
              children: const [
                TextSpan(
                  text:
                      'Take care of your ticket, as it cannot be replaced if lost, stolen or destroyed, and is valid only for event and seat printed on ticket. This ticket is a revocable license to attend the event listed on the front of the ticket and is subject to the full terms found at ',
                ),
                TextSpan(
                  text: 'www.ticketmaster.com',
                  style: TextStyle(color: Color(0xFF1C78C8)),
                ),
                TextSpan(
                  text:
                      '. Such license may be revoked without refund for noncompliance with terms. Unlawful sale or attempted sale prohibited. Tickets obtained from unauthorized sources may be invalid, lost, stolen, or counterfeit and if so, are void. Maximum resale restrictions may apply. NY: if venue seats more than 5,000 persons, ticket may not be resold within 1,500 feet from the physical structure of this place of entertainment under penalty of law. IF an event is not played, ticket may be exchanged for same price seat for either: (a) rescheduled event, if any; or, if applicable, (b) any event designated by the place of entertainment, within 12 months of original event, if available. TIME, OPPONENT, ROSTERS AND DATE SUBJECT TO CHANGE. This ticket may not be used for advertising, promotion or other trade purposes without the written consent of issuer. Applicable taxes are included. Holder assumes all risks, hazards, and dangers occurring before, during or after event, including injury by any cause, or arising from or relating in any way to the risk of contracting a communicable disease or illness (including exposure to COVID-19, a bacteria, virus, or other pathogen capable of causing a communicable disease or illness), however caused or contracted against, the venue, league, participants, clubs, artists, promoters, Ticketmaster, and each of their respective representatives, affiliates and personnel.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailMapCard extends StatelessWidget {
  const _DetailMapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB9B9B9)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: const [
            Positioned.fill(child: CustomPaint(painter: _MapPreviewPainter())),
            Positioned(
              left: 112,
              top: 18,
              child: Icon(
                Icons.location_on,
                color: Color(0xFFE50A2A),
                size: 80,
              ),
            ),
            Positioned(
              right: 42,
              top: 44,
              child: Icon(
                Icons.location_on,
                color: Color(0xFFE50A2A),
                size: 44,
              ),
            ),
            Positioned(
              left: 32,
              bottom: 44,
              child: Icon(
                Icons.location_on,
                color: Color(0xFFE50A2A),
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPreviewPainter extends CustomPainter {
  const _MapPreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFDCDAC7);
    canvas.drawRect(Offset.zero & size, bg);

    final parkPaint = Paint()..color = const Color(0xFFA8D66B);
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.14),
      25,
      parkPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.87, size.height * 0.18),
      18,
      parkPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.79),
      16,
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.03, size.height * 0.68, 62, 22),
        const Radius.circular(7),
      ),
      parkPaint,
    );

    final roadWhite = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7
      ..color = const Color(0xFFECECEF);
    final roadYellow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2
      ..color = const Color(0xFFF2CB31);

    void drawRoad(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, roadWhite);
      canvas.drawPath(path, roadYellow);
    }

    drawRoad([
      Offset(0, size.height * 0.2),
      Offset(size.width * 0.2, size.height * 0.28),
      Offset(size.width * 0.44, size.height * 0.22),
      Offset(size.width * 0.73, size.height * 0.33),
      Offset(size.width, size.height * 0.24),
    ]);
    drawRoad([
      Offset(size.width * 0.08, 0),
      Offset(size.width * 0.18, size.height * 0.33),
      Offset(size.width * 0.34, size.height * 0.66),
      Offset(size.width * 0.42, size.height),
    ]);
    drawRoad([
      Offset(size.width * 0.95, 0),
      Offset(size.width * 0.77, size.height * 0.34),
      Offset(size.width * 0.71, size.height * 0.6),
      Offset(size.width * 0.6, size.height),
    ]);
    drawRoad([
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.24, size.height * 0.72),
      Offset(size.width * 0.5, size.height * 0.83),
      Offset(size.width, size.height * 0.7),
    ]);

    final localRoad = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = const Color(0xFFD0CFBC);
    for (double y = 14; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 10), localRoad);
    }
    for (double x = 10; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x + 18, size.height), localRoad);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    this.uploadedImageSelection,
    this.ticketCount = 1,
    this.title = 'COLORADO ROCKIES VS.\nSAN DIEGO PADRES',
    this.venue = 'Coors Field - Denver, CO',
    this.dateLabel = 'MON, SEP 14 2026, 6:40 PM',
    this.eventLabel = 'UPCOMING EVENT',
    this.showTicketOptions = false,
    this.titleTextKey,
    this.venueTextKey,
    this.dateTextKey,
    this.onDismissTicketOptions,
    this.onSelectGallery,
    this.onSelectCamera,
    this.onDoubleTap,
    this.onLongPress,
    this.onCountDoubleTap,
    this.onTap,
  });

  final TicketCardImageSelection? uploadedImageSelection;
  final int ticketCount;
  final String title;
  final String venue;
  final String dateLabel;
  final String eventLabel;
  final bool showTicketOptions;
  final String? titleTextKey;
  final String? venueTextKey;
  final String? dateTextKey;
  final VoidCallback? onDismissTicketOptions;
  final VoidCallback? onSelectGallery;
  final VoidCallback? onSelectCamera;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onCountDoubleTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final displayDateLabel = dateLabel == 'MON, SEP 14 2026, 6:40 PM'
        ? 'MON • 14 SEP, 2026 • 6:40 PM'
        : dateLabel;
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: const Color(0xFF2B1647),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _ticketTimingLabel(dateLabel, eventLabel),
                          key: ValueKey<String>(
                              '${titleTextKey ?? 'ticket'}-event-label'),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.event_available_outlined,
                          color: Colors.white, size: 25),
                    ],
                  ),
                  const SizedBox(height: 26),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (uploadedImageSelection != null)
                          _TicketCardHeaderImage(
                              selection: uploadedImageSelection!)
                        else
                          const _V2TicketArtwork(),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            color: const Color(0xFF111111),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Text(
                              displayDateLabel,
                              key: dateTextKey == null
                                  ? null
                                  : ValueKey<String>(dateTextKey!),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF111111),
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
                    child: _TicketCardBodyContent(
                      ticketCount: ticketCount,
                      title: title,
                      venue: venue,
                      titleTextKey: titleTextKey,
                      venueTextKey: venueTextKey,
                      onCountDoubleTap: onCountDoubleTap,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 44),
                    color: const Color(0xFF064DE0),
                    padding: const EdgeInsets.all(10),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                            child: Text('View Tickets',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700))),
                        SizedBox(width: 10),
                        Icon(Icons.open_in_new, size: 19, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              if (showTicketOptions)
                Positioned.fill(
                  child: _TicketCardOptionsOverlay(
                    onDismiss: onDismissTicketOptions,
                    onSelectGallery: onSelectGallery,
                    onSelectCamera: onSelectCamera,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketCardBodyContent extends StatelessWidget {
  const _TicketCardBodyContent({
    required this.ticketCount,
    required this.title,
    required this.venue,
    this.titleTextKey,
    this.venueTextKey,
    this.onCountDoubleTap,
  });

  final int ticketCount;
  final String title;
  final String venue;
  final String? titleTextKey;
  final String? venueTextKey;
  final VoidCallback? onCountDoubleTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          key: titleTextKey == null ? null : ValueKey<String>(titleTextKey!),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 18),
        const SizedBox(
          width: double.infinity,
          height: 3,
          child: ColoredBox(color: Color(0xFF064DE0)),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                venue,
                key: venueTextKey == null
                    ? null
                    : ValueKey<String>(venueTextKey!),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _TicketCountBadge(
              count: ticketCount,
              iconSize: 16,
              textSize: 13,
              iconColor: const Color(0xFFF4F4F4),
              textColor: Colors.white,
              onDoubleTap: onCountDoubleTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _TicketCardImageSlot extends StatelessWidget {
  const _TicketCardImageSlot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 164,
      height: 126,
      child: Center(
        child: _TicketCardImagePlaceholder(key: ValueKey('ticket-placeholder')),
      ),
    );
  }
}

class _TicketCardImagePlaceholder extends StatelessWidget {
  const _TicketCardImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 118,
      alignment: Alignment.center,
      child: const _RockiesMonogram(),
    );
  }
}

class _TicketCardHeaderImage extends StatelessWidget {
  const _TicketCardHeaderImage({required this.selection});

  final TicketCardImageSelection selection;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF161B23)),
      child: TicketCardImageViewport(selection: selection),
    );
  }
}

class _TicketCardOptionsOverlay extends StatefulWidget {
  const _TicketCardOptionsOverlay({
    this.onDismiss,
    this.onSelectGallery,
    this.onSelectCamera,
  });

  final VoidCallback? onDismiss;
  final VoidCallback? onSelectGallery;
  final VoidCallback? onSelectCamera;

  @override
  State<_TicketCardOptionsOverlay> createState() =>
      _TicketCardOptionsOverlayState();
}

class _TicketCardOptionsOverlayState extends State<_TicketCardOptionsOverlay> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight > 24
              ? constraints.maxHeight - 24
              : constraints.maxHeight;

          return InkWell(
            onTap: widget.onDismiss,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 220,
                  maxHeight: maxHeight,
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161A22).withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 18,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ticket Image',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.96),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Choose where to add the ticket image from.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _TicketCardActionButton(
                                  icon: Icons.photo_library_outlined,
                                  label: 'Gallery',
                                  onTap: widget.onSelectGallery,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _TicketCardActionButton(
                                  icon: Icons.photo_camera_outlined,
                                  label: 'Camera',
                                  onTap: widget.onSelectCamera,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TicketCountBadge extends StatelessWidget {
  const _TicketCountBadge({
    required this.count,
    required this.iconSize,
    required this.textSize,
    required this.iconColor,
    required this.textColor,
    this.onDoubleTap,
  });

  final int count;
  final double iconSize;
  final double textSize;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: onDoubleTap,
      onLongPress: onDoubleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: iconSize + 6,
            height: iconSize + 6,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 4,
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    size: iconSize,
                    color: iconColor.withValues(alpha: 0.72),
                  ),
                ),
                Positioned(
                  left: 5,
                  top: 0,
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    size: iconSize,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'x$count',
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCardActionButton extends StatelessWidget {
  const _TicketCardActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF242A35),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketCardHeaderBackground extends StatelessWidget {
  const _TicketCardHeaderBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TicketHeaderPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _TicketHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Keep diagonal stripes inside the ticket art bounds only.
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final basePaint = Paint()..color = const Color(0xFF3B047C);
    canvas.drawRect(Offset.zero & size, basePaint);

    final stripePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF4A0E90).withAlpha(166);
    const stripeHeight = 18.0;
    const gap = 24.0;

    for (double y = -size.height; y < size.height * 2; y += gap) {
      final stripe = Path()
        ..moveTo(0, y)
        ..lineTo(size.width, y - size.width * 0.27)
        ..lineTo(size.width, y - size.width * 0.27 + stripeHeight)
        ..lineTo(0, y + stripeHeight)
        ..close();
      canvas.drawPath(stripe, stripePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RockiesMonogram extends StatelessWidget {
  const _RockiesMonogram();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: Color(0xFFC9CEDD),
      fontSize: 108,
      fontWeight: FontWeight.w700,
      height: 0.86,
      letterSpacing: -1.1,
      fontFamily: 'Times New Roman',
      shadows: [
        Shadow(
          color: Colors.black26,
          blurRadius: 0.6,
          offset: Offset(0.2, 0.2),
        ),
      ],
    );

    return SizedBox(
      width: 148,
      height: 118,
      child: Stack(
        children: const [
          Positioned(left: 22, top: 2, child: Text('C', style: style)),
          Positioned(left: 66, top: 28, child: Text('R', style: style)),
        ],
      ),
    );
  }
}

// Presentation helpers for V2. Uploaded artwork still uses its saved crop.
class _V2TicketArtwork extends StatelessWidget {
  const _V2TicketArtwork({this.selection});
  final TicketCardImageSelection? selection;

  @override
  Widget build(BuildContext context) {
    if (selection != null) return _TicketCardHeaderImage(selection: selection!);
    return Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(painter: _V2TicketArtworkPainter()),
        Center(
          child: FractionallySizedBox(
            heightFactor: 0.66,
            widthFactor: 0.38,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0,
                0,
                0,
                0.788,
                0,
                0,
                0,
                0,
                0.808,
                0,
                0,
                0,
                0,
                0.866,
                0,
                -1.75,
                0,
                0,
                1.38,
                0,
              ]),
              child: Image.asset('assets/apk/images/rockies_cr.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Stack(fit: StackFit.expand, children: [
                        _TicketCardHeaderBackground(),
                        Center(child: _TicketCardImageSlot()),
                      ])),
            ),
          ),
        ),
      ],
    );
  }
}

class _V2TicketArtworkPainter extends CustomPainter {
  const _V2TicketArtworkPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF26045D));
    final paint = Paint()..color = const Color(0xFF350575);
    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.16 + i * 0.35);
      canvas.drawPath(
          Path()
            ..moveTo(0, y)
            ..lineTo(size.width, y - size.height * (0.5 + i * 0.12))
            ..lineTo(size.width, y - size.height * (0.34 + i * 0.12))
            ..lineTo(0, y + size.height * 0.16)
            ..close(),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _ticketTimingLabel(String date, String fallback) {
  if (fallback != 'UPCOMING EVENT') return fallback;
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC'
  ];
  final upper = date.toUpperCase();
  final monthFirst =
      RegExp(r'\b([A-Z]{3})\s+(\d{1,2}),?\s+(\d{4})\b').firstMatch(upper);
  final dayFirst =
      RegExp(r'\b(\d{1,2})\s+([A-Z]{3}),?\s+(\d{4})\b').firstMatch(upper);
  final month =
      months.indexOf(monthFirst?.group(1) ?? dayFirst?.group(2) ?? '');
  final day = int.tryParse(monthFirst?.group(2) ?? dayFirst?.group(1) ?? '');
  final year = int.tryParse(monthFirst?.group(3) ?? dayFirst?.group(3) ?? '');
  if (month < 0 || day == null || year == null) return fallback;
  final now = DateTime.now();
  final days = DateTime.utc(year, month + 1, day)
      .difference(DateTime.utc(now.year, now.month, now.day))
      .inDays;
  if (days < 0) return fallback;
  return days == 0
      ? 'Next Event: Today'
      : 'Next Event: $days ${days == 1 ? 'day' : 'days'}';
}

// Keeps the storage identity of previously unkeyed editable copy when its
// initial wording changes to match V2.
class _V2LegacyTextKey extends LocalKey {
  const _V2LegacyTextKey(this.original);
  final String original;
  @override
  String toString() => '::$original';
  @override
  bool operator ==(Object other) =>
      other is _V2LegacyTextKey && other.original == original;
  @override
  int get hashCode => original.hashCode;
}

class _V2EventAppBar extends StatelessWidget {
  const _V2EventAppBar({required this.ticket, required this.ticketCount});
  final _TicketListEntry ticket;
  final int ticketCount;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF26045D),
      foregroundColor: Colors.white,
      expandedHeight: (width * 0.54).clamp(170.0, 280.0) + 150,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop()),
      actions: [
        IconButton(
          tooltip: 'View Ticket',
          icon: const Icon(Icons.qr_code_scanner, size: 22),
          onPressed: () => Navigator.of(context).push(
            _ViewTicketRoute(ticket: ticket, ticketCount: ticketCount),
          ),
        ),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
                child: Text('Help',
                    style: TextStyle(color: Colors.white, fontSize: 13))))
      ],
      title: Builder(builder: (context) {
        final settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
        if (settings != null &&
            settings.currentExtent > settings.minExtent + 24) {
          return const SizedBox.shrink();
        }
        return Text(ticket.singleLineTitle,
            key: ValueKey<String>(ticket.textKey('title')),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.white));
      }),
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          children: [
            Expanded(child: _V2TicketArtwork(selection: ticket.imageSelection)),
            Container(
              color: const Color(0xFF111111),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket.editableDateLabel,
                        key: ValueKey<String>(ticket.textKey('date')),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(ticket.singleLineTitle,
                        key: ValueKey<String>(ticket.textKey('title')),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.1)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: Text(ticket.editableVenue,
                              key: ValueKey<String>(ticket.textKey('venue')),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12))),
                      _TicketCountBadge(
                          count: ticketCount,
                          iconSize: 13,
                          textSize: 11,
                          iconColor: Colors.white70,
                          textColor: Colors.white70),
                    ]),
                  ]),
            ),
            _DarkActionButton(
                label: 'View Ticket',
                height: 44,
                icon: Icons.qr_code_scanner,
                onPressed: () => Navigator.of(context).push(_ViewTicketRoute(
                    ticket: ticket, ticketCount: ticketCount))),
          ],
        ),
      ),
    );
  }
}

class _V2EventTabsDelegate extends SliverPersistentHeaderDelegate {
  const _V2EventTabsDelegate();
  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      const _MyTicketDetailsHeader();
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _V2EventActions extends StatelessWidget {
  const _V2EventActions({required this.onTransfer});
  final VoidCallback onTransfer;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.upgrade, color: Colors.black26, size: 22),
                Text('Upgrade',
                    style: TextStyle(fontSize: 10, color: Colors.black38))
              ])),
          TextButton(
              onPressed: onTransfer,
              child: const Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.north_east, size: 22),
                Text('Transfer', style: TextStyle(fontSize: 10))
              ])),
          TextButton(
              onPressed: () {},
              child: const Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.sell_outlined, size: 22),
                Text('Sell', style: TextStyle(fontSize: 10))
              ])),
        ]),
      ),
    );
  }
}

class _V2TicketInformationHeader extends StatelessWidget {
  const _V2TicketInformationHeader({required this.ticket});
  final _TicketListEntry ticket;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const _TicketDetailsHeaderBar(),
      Padding(
        padding: const EdgeInsets.fromLTRB(48, 0, 24, 12),
        child: Column(children: [
          Text(ticket.singleLineTitle,
              key: ValueKey<String>(ticket.textKey('title')),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(ticket.detailsSubtitle,
              key: ValueKey<String>(ticket.textKey('subtitle')),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF777777))),
        ]),
      ),
    ]);
  }
}

class _TransferRecipientForm extends StatefulWidget {
  const _TransferRecipientForm(
      {super.key, required this.selectedCount, required this.onBack});
  final int selectedCount;
  final VoidCallback onBack;
  @override
  State<_TransferRecipientForm> createState() => _TransferRecipientFormState();
}

class _TransferRecipientFormState extends State<_TransferRecipientForm> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();
  bool _usePhone = false;

  @override
  void dispose() {
    for (final controller in [_firstName, _lastName, _email, _phone, _note]) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _field(String label, TextEditingController controller,
      {TextInputType? keyboardType, int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        material.Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction:
              maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
          maxLines: maxLines,
          maxLength: maxLines > 1 ? 200 : null,
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
          decoration: InputDecoration(
            hintText: hint ?? label.replaceAll(' *', ''),
            hintStyle: const TextStyle(color: Color(0xFFBFC3C8), fontSize: 13),
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFFB7BABE))),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            isDense: true,
            suffixIcon: maxLines == 1
                ? IconButton(
                    tooltip: 'Clear ${label.replaceAll(' *', '')}',
                    onPressed: controller.clear,
                    icon: const Icon(Icons.cancel_outlined,
                        color: Color(0xFFBFC3C8), size: 18),
                  )
                : null,
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(children: [
        const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Transfer Tickets',
                style: TextStyle(color: Color(0xFF444444), fontSize: 15))),
        Expanded(
            child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            material.Text(
                '${widget.selectedCount} Ticket${widget.selectedCount == 1 ? '' : 's'} Selected',
                style: const TextStyle(
                    color: Color(0xFF69717A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const Divider(height: 30),
            _field('First name *', _firstName,
                keyboardType: TextInputType.name),
            _field('Last name *', _lastName, keyboardType: TextInputType.name),
            if (_usePhone)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                    padding: EdgeInsets.only(top: 36, right: 12),
                    child: material.Text('🇺🇸 +1',
                        style: TextStyle(fontSize: 13))),
                Expanded(
                    child: _field('Mobile Number *', _phone,
                        keyboardType: TextInputType.phone,
                        hint: '000 000 0000')),
              ])
            else
              _field('Email *', _email,
                  keyboardType: TextInputType.emailAddress),
            TextButton(
              onPressed: () => setState(() => _usePhone = !_usePhone),
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              child: material.Text(
                  _usePhone ? 'Use Email Instead' : 'Use Mobile Number Instead',
                  style: const TextStyle(fontSize: 13)),
            ),
            _field('Note', _note, maxLines: 3, hint: 'Max. 200 Characters'),
          ]),
        )),
        Container(
          color: const Color(0xFFF5F6F8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(children: [
            TextButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.chevron_left),
                label: const material.Text('Back')),
            const Spacer(),
            // The existing transfer flow has no sending backend.
            Flexible(
                child: FilledButton(
                    onPressed: null,
                    child: material.Text(
                        'Transfer ${widget.selectedCount} Ticket${widget.selectedCount == 1 ? '' : 's'}',
                        style: const TextStyle(fontSize: 12)))),
          ]),
        ),
      ]),
    );
  }
}

class _V2TicketTheme extends StatelessWidget {
  const _V2TicketTheme({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
          primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'Roboto')),
      child: DefaultTextStyle.merge(
          style: const TextStyle(fontFamily: 'Roboto'), child: child),
    );
  }
}
