part of 'package:ticketmaster/main.dart';

class _MyTicketDetailsPage extends StatefulWidget {
  const _MyTicketDetailsPage({required this.ticket, required this.ticketCount});

  final _TicketListEntry ticket;
  final int ticketCount;

  @override
  State<_MyTicketDetailsPage> createState() => _MyTicketDetailsPageState();
}

class _MyTicketDetailsPageState extends State<_MyTicketDetailsPage> {
  static const double _ticketPagerHeight = 114;

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

  void _showOrderOptions() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Text('Order Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1, color: Color(0xFFE8E8E8)),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 22, 16, 22),
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: Text('Order Number',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700))),
                Text('51-52844/ARZ',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
              SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: Text('Purchase Date',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700))),
                Text('SAT, FEB 21 2026',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFE8E8E8)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _DarkActionButton(
                label: 'View Receipt',
                height: 48,
                icon: Icons.receipt_long_outlined),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(_TicketDetailsInfoRoute(
                    ticket: widget.ticket, ticketPageIndex: _activeTicketPage));
              },
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF686868)),
                  foregroundColor: const Color(0xFF171717),
                  minimumSize: const Size.fromHeight(44),
                  shape: const RoundedRectangleBorder()),
              child: const Text('View Order',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(children: [
              Expanded(
                  child: Text('Mobile',
                      key: ValueKey<String>(widget.ticket.ticketInstanceTextKey(
                          _activeTicketPage, 'mobile-label')),
                      style: const TextStyle(
                          color: Color(0xFF656565), fontSize: 12))),
              _TicketDetailsLink(onTap: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(_TicketDetailsInfoRoute(
                    ticket: widget.ticket, ticketPageIndex: _activeTicketPage));
              }),
            ]),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _V2TicketTheme(
        fontFamily: 'SourceSans3',
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              top: false,
              child: Stack(
                children: [
                  NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      _V2EventAppBar(
                          ticket: widget.ticket,
                          ticketCount: widget.ticketCount),
                      const SliverPersistentHeader(
                          pinned: true, delegate: _V2EventTabsDelegate()),
                    ],
                    body: TabBarView(
                      children: [
                        ListView(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 108),
                          children: [
                            Row(children: [
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Order #51-52844/ARZ',
                                      style: TextStyle(
                                          color: Color(0xFF171717),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text('x${widget.ticketCount} Ticket',
                                      style: const TextStyle(
                                          color: Color(0xFF656565),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ],
                              )),
                              IconButton(
                                  tooltip: 'Order options',
                                  onPressed: _showOrderOptions,
                                  icon: const Icon(Icons.more_vert,
                                      color: Color(0xFF232323))),
                            ]),
                            const SizedBox(height: 31),
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
                            const SizedBox(height: 28),
                            const AspectRatio(
                                aspectRatio: 16 / 9,
                                child: _DetailMapCard(referenceMap: true)),
                            const SizedBox(height: 14),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: _DarkActionButton(
                                  label: 'Get Directions',
                                  height: 38,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          children: [
                            Text(
                                'Get Ready For ${widget.ticket.singleLineTitle}',
                                style: const TextStyle(
                                    fontFamily: 'EventAverta',
                                    color: Color(0xFF171717),
                                    fontSize: 17,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            const Text(
                                'Plan ahead and take advantage of these great offers.',
                                style: TextStyle(
                                    fontFamily: 'EventAverta',
                                    color: Color(0xFF171717),
                                    fontSize: 12,
                                    height: 1.5)),
                            const SizedBox(height: 26),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFE7E7E7))),
                              child: Row(children: [
                                Container(
                                    width: 70,
                                    height: 40,
                                    color: const Color(0xFF69757D),
                                    child: const Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 30,
                                        color: Colors.white)),
                                const SizedBox(width: 16),
                                const Expanded(
                                    child: Text('COORS FIELD EVENT PARKING',
                                        style: TextStyle(
                                            fontFamily: 'EventAverta',
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600))),
                                const Icon(Icons.chevron_right,
                                    color: Color(0xFF656565)),
                              ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: Builder(builder: (context) {
                      final controller = DefaultTabController.of(context);
                      return AnimatedBuilder(
                        animation: controller,
                        builder: (context, child) => controller.index == 0
                            ? child!
                            : const SizedBox.shrink(),
                        child: Center(
                          child: _V2EventActions(onTransfer: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              barrierColor: Colors.black54,
                              builder: (context) => _TransferFlowSheet(
                                ticket: widget.ticket,
                                ticketCount: widget.ticketCount,
                              ),
                            );
                          }),
                        ),
                      );
                    }),
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
    return Material(
      color: Colors.white,
      child: TabBar(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelColor: const Color(0xFF171717),
        unselectedLabelColor: const Color(0xFF171717),
        indicatorColor: const Color(0xFF171717),
        indicatorWeight: 4,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: const Color(0xFF999999),
        tabs: const [
          Tab(
              child: Text('Tickets',
                  key: _V2LegacyTextKey('MY TICKETS'),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
          Tab(
              child: Text('Extras',
                  key: _V2LegacyTextKey('ADD-ONS'),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
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
      color: const Color(0xFFEBEBEB),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Standard Ticket',
                    key: ValueKey<String>(ticket.ticketInstanceTextKey(
                        ticketPageIndex, 'standard-ticket-label')),
                    style: const TextStyle(
                        color: Color(0xFF171717),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const Divider(height: 2, thickness: 2, color: Colors.white),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
              child: Row(
                children: [
                  for (final stat in const [
                    ('SEC', '402', 'section'),
                    ('ROW', '5', 'row'),
                    ('SEAT', '1', 'seat')
                  ])
                    Expanded(
                        child: _TicketStatItem(
                      alignment: stat.$3 == 'section'
                          ? CrossAxisAlignment.start
                          : stat.$3 == 'seat'
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.center,
                      foreground: const Color(0xFF171717),
                      label: stat.$3 == 'section' ? 'SECTION' : stat.$1,
                      value: stat.$3 == 'seat'
                          ? '${ticketPageIndex + 1}'
                          : stat.$2,
                      labelTextKey: ticket.ticketInstanceTextKey(
                          ticketPageIndex, '${stat.$3}-label'),
                      valueTextKey: ticket.ticketInstanceTextKey(
                          ticketPageIndex, '${stat.$3}-value'),
                    )),
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
    this.alignment = CrossAxisAlignment.center,
  });

  final String label;
  final String value;
  final String? labelTextKey;
  final String? valueTextKey;
  final Color foreground;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
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
    this.fontSize = 14,
  });

  final String label;
  final double height;
  final IconData? icon;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: () {},
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
    _activeTicketPage = 0;
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
                                value: '${ticketPageIndex + 1}',
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

enum _TransferSheetStep { selectTickets, transferTo, recipientForm }

class _TransferFlowSheet extends StatefulWidget {
  const _TransferFlowSheet({required this.ticket, required this.ticketCount});

  final _TicketListEntry ticket;
  final int ticketCount;

  @override
  State<_TransferFlowSheet> createState() => _TransferFlowSheetState();
}

class _TransferFlowSheetState extends State<_TransferFlowSheet> {
  _TransferSheetStep _step = _TransferSheetStep.selectTickets;
  final Set<int> _selectedTicketIndexes = <int>{0};

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
          height: (media.size.height * 0.53 + media.viewInsets.bottom)
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
                    ticket: widget.ticket,
                    selectedCount: _selectedCount,
                    selectedIndexes: _selectedTicketIndexes,
                    onToggleTicket: _toggleTicket,
                    onContinue: _goToRecipientStep,
                  )
                : _step == _TransferSheetStep.recipientForm
                    ? _TransferRecipientForm(
                        key: const ValueKey('recipient-form'),
                        ticket: widget.ticket,
                        selectedIndexes: _selectedTicketIndexes.toList()..sort(),
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
    required this.ticket,
    required this.ticketCount,
    required this.selectedCount,
    required this.selectedIndexes,
    required this.onToggleTicket,
    required this.onContinue,
  });

  final _TicketListEntry ticket;
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
                Expanded(
                  child: Text(
                    'Sec ${_EditableTextStore.valueFor(ticket.ticketInstanceTextKey(0, 'section-value'), '402')}, Row ${_EditableTextStore.valueFor(ticket.ticketInstanceTextKey(0, 'row-value'), '5')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF26292E),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
                  label:
                      'SEAT ${_EditableTextStore.valueFor(ticket.ticketInstanceTextKey(index, 'seat-value'), '${index + 1}')}',
                  selected: selectedIndexes.contains(index),
                  onTap: () => onToggleTicket(index),
                );
              },
            ),
          ),
        ]))),
        const Divider(height: 1, color: Color(0xFFE3E4E7)),
        ColoredBox(
          color: const Color(0xFFF8FAFD),
          child: Padding(
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
  const _DetailMapCard({this.referenceMap = false});
  final bool referenceMap;

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
        child: referenceMap
            ? const _ReferenceCropImage(
                asset: 'V2/Screenshot_20260918-201401.png',
                fullWidth: 1080,
                fullHeight: 2400,
                source: Rect.fromLTWH(42, 1110, 996, 560),
              )
            : Stack(
                children: const [
                  Positioned.fill(
                      child: CustomPaint(painter: _MapPreviewPainter())),
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
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
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
            fontFamily: 'SourceSans3',
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 18),
        const FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 3,
            child: ColoredBox(color: Color(0xFF064DE0)),
          ),
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
          material.Text(
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

  void _openTickets(BuildContext context) {
    Navigator.of(context).push(
      _ViewTicketRoute(ticket: ticket, ticketCount: ticketCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final topPadding = MediaQuery.paddingOf(context).top;
    final artHeight = width * 9 / 16;
    final scaler = MediaQuery.textScalerOf(context);
    final titleStyle = const TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 18,
        fontWeight: FontWeight.w800,
        height: 1.15);
    final titlePainter = TextPainter(
      text: TextSpan(text: ticket.singleLineTitle, style: titleStyle),
      textDirection: Directionality.of(context),
      textScaler: scaler,
      maxLines: 2,
    )..layout(maxWidth: math.max(1, width - 64));
    final titleHeight = titlePainter.height;
    titlePainter.dispose();
    final dateHeight = scaler.scale(12) * 1.3 + 10;
    final infoHeight = titleHeight + math.max(scaler.scale(13) * 1.3, 24) + 28;
    final expandedHeight = artHeight - 25 + dateHeight + infoHeight + 48;

    bool isCollapsed(BuildContext context) {
      final settings = context
          .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
      return settings != null &&
          settings.currentExtent <= settings.minExtent + 24;
    }

    return SliverAppBar(
      pinned: true,
      toolbarHeight: 64,
      leadingWidth: 64,
      titleSpacing: 0,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: const Color(0xFF26045D),
      foregroundColor: Colors.white,
      expandedHeight: expandedHeight,
      leading: Center(
          child: SizedBox.square(
        dimension: 34,
        child: IconButton(
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF1D093A)),
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
      )),
      actions: [
        Builder(
            builder: (context) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: isCollapsed(context)
                      ? SizedBox(
                          width: 48,
                          height: 34,
                          child: IconButton(
                            tooltip: 'View Ticket',
                            style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF024DDF)),
                            icon: const _EventBarcodeIcon(size: 24),
                            onPressed: () => _openTickets(context),
                          ))
                      : Container(
                          width: 74,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D093A),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text('Help',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700))),
                )),
      ],
      title: Builder(builder: (context) {
        if (!isCollapsed(context)) return const SizedBox.shrink();
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Text(ticket.singleLineTitle,
              key: ValueKey<String>(ticket.textKey('title')),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700)),
          Text(ticket.editableVenue,
              key: ValueKey<String>(ticket.textKey('venue')),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700)),
        ]);
      }),
      flexibleSpace: Stack(fit: StackFit.expand, children: [
        // Keep the artwork behind the toolbar when the rest has scrolled away.
        Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            height: artHeight,
            child: _V2TicketArtwork(selection: ticket.imageSelection)),
        FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Stack(children: [
              Positioned.fill(
                  top: artHeight, child: const ColoredBox(color: Colors.white)),
              Positioned(
                top: artHeight - 25,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IntrinsicWidth(
                        child: Container(
                      height: dateHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      constraints: BoxConstraints(maxWidth: width - 32),
                      color: const Color(0xFF232323),
                      child: Text(ticket.editableDateLabel,
                          key: ValueKey<String>(ticket.textKey('date')),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.3,
                              fontWeight: FontWeight.w700)),
                    )),
                    Container(
                      height: infoHeight,
                      width: double.infinity,
                      color: const Color(0xFF232323),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ticket.singleLineTitle,
                              key: ValueKey<String>(ticket.textKey('title')),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: titleStyle.copyWith(color: Colors.white)),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(
                                child: Text(ticket.editableVenue,
                                    key: ValueKey<String>(
                                        ticket.textKey('venue')),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        height: 1.3,
                                        fontWeight: FontWeight.w600))),
                            _TicketCountBadge(
                                count: ticketCount,
                                iconSize: 16,
                                textSize: 13,
                                iconColor: Colors.white,
                                textColor: Colors.white),
                          ]),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () => _openTickets(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF024DDF),
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _EventBarcodeIcon(size: 24),
                            SizedBox(width: 10),
                            Text('View Tickets',
                                key: _V2LegacyTextKey('View Ticket'),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _EventBarcodeIcon extends StatelessWidget {
  const _EventBarcodeIcon({this.size = 24});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
      dimension: size,
      child: const CustomPaint(painter: _EventBarcodePainter()));
}

class _EventBarcodePainter extends CustomPainter {
  const _EventBarcodePainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke;
    for (final corner in [(1.0, 1.0), (23.0, 1.0), (1.0, 23.0), (23.0, 23.0)]) {
      final x = corner.$1, y = corner.$2;
      canvas.drawPath(
          Path()
            ..moveTo(x, y == 1 ? 5 : 19)
            ..lineTo(x, y)
            ..lineTo(x == 1 ? 5 : 19, y),
          paint);
    }
    paint.strokeWidth = 1;
    for (final x in [5.0, 7.0, 10.0, 12.0, 13.5, 17.0, 19.0]) {
      canvas.drawLine(
          Offset(x, 4), Offset(x, x == 10 || x == 17 ? 20 : 18), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
  bool shouldRebuild(covariant _V2EventTabsDelegate oldDelegate) => false;
}

class _V2EventActions extends StatelessWidget {
  const _V2EventActions({required this.onTransfer});
  final VoidCallback onTransfer;
  @override
  Widget build(BuildContext context) {
    Widget action(String label, IconData icon, VoidCallback? onTap) => Expanded(
          child: InkWell(
            onTap: onTap,
            child: ColoredBox(
              color: onTap == null ? const Color(0xFFF6F6F6) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon,
                      color: onTap == null
                          ? const Color(0xFFD3D3D3)
                          : const Color(0xFF0057FF),
                      size: 22),
                  const SizedBox(height: 4),
                  Text(label,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: onTap == null
                              ? const Color(0xFF656565)
                              : Colors.black)),
                ]),
              ),
            ),
          ),
        );
    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(40),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 224,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          action('Upgrade', Icons.upgrade, null),
          action('Transfer', Icons.north_east, onTransfer),
          Container(width: 1, height: 24, color: const Color(0xFFD6D6D6)),
          action('Sell', Icons.cached, () {}),
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
      {super.key, required this.ticket, required this.selectedIndexes,
      required this.selectedCount, required this.onBack});
  final _TicketListEntry ticket;
  final List<int> selectedIndexes;
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
  void initState() {
    super.initState();
    for (final controller in [_firstName, _lastName, _email, _phone]) {
      controller.addListener(_refreshValidation);
    }
  }

  void _refreshValidation() => setState(() {});

  bool _validName(String value) => RegExp(
        r"^[\p{L}\p{M}]+(?:[ .'-][\p{L}\p{M}]+)*$",
        unicode: true,
      ).hasMatch(value.trim());

  bool _validEmail(String value) {
    final email = value.trim();
    return email.length <= 254 &&
        !email.contains('..') &&
        RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9._%+\-]*[A-Za-z0-9])?@'
                r'[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?'
                r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)+$')
            .hasMatch(email);
  }

  bool _validPhone(String value) {
    var phone = value.trim().replaceAll(RegExp(r'[\s().-]'), '');
    if (phone.startsWith('+1')) phone = phone.substring(2);
    return RegExp(r'^[2-9]\d{2}[2-9]\d{6}$').hasMatch(phone);
  }

  bool get _canTransfer =>
      _validName(_firstName.text) &&
      _validName(_lastName.text) &&
      (_usePhone ? _validPhone(_phone.text) : _validEmail(_email.text));

  void _showTransferError() {
    FocusScope.of(context).unfocus();
    _TransferInboxStore.record(widget.ticket, widget.selectedIndexes);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFFF8F4FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const material.Text('Oops! We are experiencing technical difficulties.',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, height: 1.2)),
            const SizedBox(height: 12),
            const material.Text("We apologise - we weren't able to complete your request.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F8),
                border: Border.all(color: const Color(0xFFFF3B3B)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(children: [
                const Icon(Icons.warning_rounded, color: Color(0xFFD20D16), size: 32),
                const SizedBox(width: 12),
                Expanded(child: material.Text(
                  'Due to the client purchasing restrictions in place for these exchanged seats, you are currently not permitted to split. Please transfer ${widget.selectedCount} ticket${widget.selectedCount == 1 ? '' : 's'} at once, we apologise for the inconvenience and appreciate your patience.',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.25),
                )),
              ]),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 150,
                child: FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF202020),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  ),
                  child: const material.Text('Ok'),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in [_firstName, _lastName, _email, _phone, _note]) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _field(String label, TextEditingController controller,
      {TextInputType? keyboardType, int maxLines = 1, String? hint, String? errorText}) {
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
            errorText: controller.text.trim().isEmpty ? null : errorText,
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
                keyboardType: TextInputType.name,
                errorText: _validName(_firstName.text) ? null : 'Enter a valid first name'),
            _field('Last name *', _lastName, keyboardType: TextInputType.name,
                errorText: _validName(_lastName.text) ? null : 'Enter a valid last name'),
            if (_usePhone)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                    padding: EdgeInsets.only(top: 36, right: 12),
                    child: material.Text('🇺🇸 +1',
                        style: TextStyle(fontSize: 13))),
                Expanded(
                    child: _field('Mobile Number *', _phone,
                        keyboardType: TextInputType.phone,
                        hint: '000 000 0000',
                        errorText: _validPhone(_phone.text) ? null : 'Enter a valid 10-digit number')),
              ])
            else
              _field('Email *', _email,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _validEmail(_email.text) ? null : 'Enter a valid email address'),
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
            Flexible(
                child: FilledButton(
                    onPressed: _canTransfer ? _showTransferError : null,
                    onLongPress: _canTransfer ? _showTransferError : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF202020),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE0E2E5),
                      disabledForegroundColor: const Color(0xFF80858A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
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
  const _V2TicketTheme({required this.child, this.fontFamily = 'Roboto'});
  final Widget child;
  final String fontFamily;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: fontFamily),
          primaryTextTheme:
              theme.primaryTextTheme.apply(fontFamily: fontFamily)),
      child: DefaultTextStyle.merge(
          style: TextStyle(fontFamily: fontFamily), child: child),
    );
  }
}
