part of 'package:ticketmaster/main.dart';

class _MyTicketDetailsPage extends StatefulWidget {
  const _MyTicketDetailsPage({required this.ticket, required this.ticketCount});

  final _TicketListEntry ticket;
  final int ticketCount;

  @override
  State<_MyTicketDetailsPage> createState() => _MyTicketDetailsPageState();
}

class _MyTicketDetailsPageState extends State<_MyTicketDetailsPage> {
  static const double _ticketPagerHeight = 656;

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
    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      body: SafeArea(
        child: Column(
          children: [
            const _MyTicketDetailsHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Column(
                  children: [
                    SizedBox(
                      height: _ticketPagerHeight,
                      child: PageView.builder(
                        controller: _ticketPageController,
                        itemCount: widget.ticketCount,
                        onPageChanged: _handlePageChanged,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: _MyTicketDetailsCard(
                              ticket: widget.ticket,
                              ticketCount: widget.ticketCount,
                              ticketPageIndex: index,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TicketPagerDots(
                      count: widget.ticketCount,
                      activeIndex: _activeTicketPage,
                      onDotTap: _handleDotTap,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _DarkActionButton(
                            label: 'Transfer',
                            height: 36,
                            fontSize: 30 / 2,
                            onPressed: () {
                              Navigator.of(context).push(
                                _TransferPageRoute(
                                  ticket: widget.ticket,
                                  ticketCount: widget.ticketCount,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: _DarkActionButton(
                            label: 'Sell',
                            height: 36,
                            fontSize: 30 / 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _DetailMapCard(),
                    const SizedBox(height: 12),
                    const _DarkActionButton(
                      label: 'Get Directions',
                      height: 40,
                      fontSize: 30 / 2,
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

class _MyTicketDetailsHeader extends StatelessWidget {
  const _MyTicketDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TmColors.ticketHeader,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    width: 46,
                    child: Icon(Icons.close, color: Colors.white, size: 26),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'My Tickets',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38 / 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 62,
                  child: Text(
                    'Help',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34 / 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: double.infinity,
            height: 1,
            child: ColoredBox(color: Color(0xFF303133)),
          ),
          SizedBox(
            height: 56,
            child: Stack(
              children: const [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'MY TICKETS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'ADD-ONS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: SizedBox(
                      height: 2.5,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB8B8B8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFF1E1F22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                SizedBox(width: 38),
                Expanded(
                  child: Text(
                    'Standard Ticket',
                    key: ValueKey<String>(
                      ticket.ticketInstanceTextKey(
                        ticketPageIndex,
                        'standard-ticket-label',
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 38,
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF212226),
            padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
            child: Row(
              children: [
                Expanded(
                  child: _TicketStatItem(
                    label: 'SEC',
                    value: '402',
                    labelTextKey: ticket.ticketInstanceTextKey(
                      ticketPageIndex,
                      'section-label',
                    ),
                    valueTextKey: ticket.ticketInstanceTextKey(
                      ticketPageIndex,
                      'section-value',
                    ),
                  ),
                ),
                Expanded(
                  child: _TicketStatItem(
                    label: 'ROW',
                    value: '5',
                    labelTextKey: ticket.ticketInstanceTextKey(
                      ticketPageIndex,
                      'row-label',
                    ),
                    valueTextKey: ticket.ticketInstanceTextKey(
                      ticketPageIndex,
                      'row-value',
                    ),
                  ),
                ),
                Expanded(
                  child: _TicketStatItem(
                    label: 'SEAT',
                    value: '1',
                    labelTextKey: ticket.ticketInstanceTextKey(
                      ticketPageIndex,
                      'seat-label',
                    ),
                    valueTextKey: ticket.ticketInstanceTextKey(
                      ticketPageIndex,
                      'seat-value',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 186,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (ticket.imageSelection != null)
                  _TicketCardHeaderImage(selection: ticket.imageSelection!)
                else ...[
                  const _TicketCardHeaderBackground(),
                  Align(
                    alignment: const Alignment(0, -0.60),
                    child: Opacity(
                      opacity: 0.7,
                      child: Transform.scale(
                        scale: 0.96,
                        child: const _RockiesMonogram(),
                      ),
                    ),
                  ),
                ],
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0x7A151A20),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Column(
                        children: [
                          Text(
                            ticket.singleLineTitle,
                            key: ValueKey<String>(ticket.textKey('title')),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xDEFFFFFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ticket.detailsSubtitle,
                            key: ValueKey<String>(ticket.textKey('subtitle')),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xCFFFFFFF),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: const Color(0xFFF2F2F2),
            padding: const EdgeInsets.fromLTRB(26, 56, 26, 62),
            child: Column(
              children: [
                Text(
                  'Mobile',
                  key: ValueKey<String>(
                    ticket.ticketInstanceTextKey(
                      ticketPageIndex,
                      'mobile-label',
                    ),
                  ),
                  style: TextStyle(
                    color: Color(0xFF2E2F31),
                    fontSize: 32 / 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 52),
                _DarkActionButton(
                  label: 'View Ticket',
                  height: 50,
                  icon: Icons.qr_code_scanner,
                  fontSize: 30 / 2,
                  onPressed: () {
                    Navigator.of(context).push(
                      _ViewTicketRoute(
                        ticket: ticket,
                        ticketCount: ticketCount,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 66),
                _TicketDetailsLink(
                  onTap: () {
                    Navigator.of(context).push(
                      _TicketDetailsInfoRoute(
                        ticket: ticket,
                        ticketPageIndex: ticketPageIndex,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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
  });

  final String label;
  final String value;
  final String? labelTextKey;
  final String? valueTextKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          key: labelTextKey == null ? null : ValueKey<String>(labelTextKey!),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          value,
          key: valueTextKey == null ? null : ValueKey<String>(valueTextKey!),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40 / 2,
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
          backgroundColor: const Color(0xFF212226),
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
            Text(
              label,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
            ),
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
            color: Color(0xFF18191B),
            fontSize: 30 / 2,
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
    return Scaffold(
      backgroundColor: const Color(0xFF1B2330),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1B2330),
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
                            Icons.close,
                            color: Colors.white,
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
                                color: Colors.white,
                                fontSize: 34 / 2,
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
                                color: Color(0xE6FFFFFF),
                                fontSize: 28 / 2,
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
                          color: Colors.white,
                          fontSize: 34 / 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                const SizedBox(
                  width: double.infinity,
                  height: 3,
                  child: ColoredBox(color: Color(0xFF4F4C3C)),
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
                  onPrevious: _activeTicketPage > 0 ? _goToPreviousPage : null,
                  onNext: _activeTicketPage < widget.ticketCount - 1
                      ? _goToNextPage
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    return Stack(
      fit: StackFit.expand,
      children: [
        if (ticket.imageSelection != null)
          TicketCardImageViewport(selection: ticket.imageSelection!)
        else
          Image.asset(
            TmAssets.discoverPerson,
            fit: BoxFit.cover,
            alignment: const Alignment(0.15, 0),
          ),
        const ColoredBox(color: Color(0x7A000000)),
        Column(
          children: [
            const SizedBox(height: 52),
            Text(
              ticket.primaryVenue,
              key: ValueKey<String>(ticket.textKey('venue-line')),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 34 / 2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                ticket.singleLineTitle,
                key: ValueKey<String>(ticket.textKey('title')),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 46 / 2,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'SEC',
              key: ValueKey<String>(
                ticket.ticketInstanceTextKey(ticketPageIndex, 'section-label'),
              ),
              style: TextStyle(
                color: Color(0xD9FFFFFF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'GA',
              key: ValueKey<String>(
                ticket.ticketInstanceTextKey(ticketPageIndex, 'section-value'),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _TicketBarcodeCard(lineAnimation: lineAnimation),
            ),
            const SizedBox(height: 34),
            const Text(
              'Mobile',
              style: TextStyle(
                color: Color(0xF2FFFFFF),
                fontSize: 34 / 2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF20242D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 21,
                        color: Color(0xFFFFB347),
                      ),
                      SizedBox(width: 9),
                      Text(
                        'Add to Apple Wallet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            const _TicketEntranceStrip(),
          ],
        ),
      ],
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          children: [
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
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    "Screenshots won't get you in.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1E1F21),
                      fontSize: 28 / 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.refresh, size: 32 / 2, color: Color(0xFF161718)),
              ],
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
      color: const Color(0xFF1A2434),
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 12),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENTRANCE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30 / 2,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 1),
          Text(
            'GENERAL ADMISSN',
            style: TextStyle(
              color: Color(0xE6FFFFFF),
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
      color: const Color(0xFF223043),
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
                  ? const Color(0x66FFFFFF)
                  : const Color(0xE6FFFFFF),
              size: 38 / 2,
            ),
          ),
          const SizedBox(width: 24),
          Text(
            '$currentPage of $totalPages',
            style: const TextStyle(
              color: Color(0xF2FFFFFF),
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
                  ? const Color(0x66FFFFFF)
                  : const Color(0xE6FFFFFF),
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
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: Column(
          children: [
            _TransferHeader(ticket: widget.ticket),
            const _TransferTabStrip(),
            Expanded(
              child: SingleChildScrollView(
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
                Text(
                  "Share You're Going",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
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
              Text(
                'x$ticketCount Mobile Tickets',
                style: const TextStyle(
                  color: Color(0xFF2A2A2A),
                  fontSize: 26 / 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Text(
                'View on Map',
                style: TextStyle(
                  color: Color(0xFF2A5CA9),
                  fontSize: 24 / 2,
                  decoration: TextDecoration.underline,
                ),
              ),
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

enum _TransferSheetStep { selectTickets, transferTo }

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
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: media.size.height *
              (_step == _TransferSheetStep.selectTickets ? 0.58 : 0.64),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
                : _TransferRecipientStep(
                    key: const ValueKey('recipient-step'),
                    selectedCount: _selectedCount,
                    bottomInset: media.padding.bottom,
                    onBack: _goBackToSelection,
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
          height: 118,
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
        const Spacer(),
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
        width: 104,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
                color: Color(0xFF1F2024),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
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
                  width: 26,
                  height: 26,
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
  });

  final int selectedCount;
  final double bottomInset;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            children: const [
              _TransferRecipientButton(
                label: 'SELECT FROM CONTACTS',
                icon: Icons.contacts_outlined,
              ),
              SizedBox(height: 12),
              _TransferRecipientButton(
                label: 'MANUALLY ENTER A RECIPIENT',
                icon: Icons.add_circle_outline,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: 82,
          height: 82,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F5F8),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.send_outlined,
            size: 34,
            color: Color(0xFFA9B4C2),
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
        const Spacer(),
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
  const _TransferRecipientButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: () {},
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
                  const Spacer(),
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
              ),
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
              Text(
                'Order #\n51-52844/ARZ',
                style: TextStyle(
                  color: Color(0xFF4B4B4B),
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
              Spacer(),
              Text(
                'View Order Receipt',
                style: TextStyle(
                  color: Color(0xFF2A5CA9),
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _TicketDetailsHeaderBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _TicketDetailsTopSection(
                  ticket: ticket,
                  ticketPageIndex: ticketPageIndex,
                ),
                _TicketInfoRow(
                  title: ticket.singleLineTitle,
                  value:
                      '${ticket.editableDateLabel} · ${ticket.editableVenue}',
                ),
                const _TicketInfoRow(title: 'Entry Info', value: 'Mobile'),
                const _TicketInfoRow(
                  title: 'Barcode Number',
                  value: '363016857385265158a',
                ),
                _TicketInfoRow(title: 'Venue', value: ticket.editableVenue),
                const _TicketInfoRow(
                  title: 'Order Number',
                  value: '51-52844/ARZ',
                ),
                const _TicketInfoRow(title: 'Ticket Type', value: 'Mobile'),
                _TicketInfoRow(
                  title: 'Entrance',
                  value: ticket.primaryVenue.toUpperCase(),
                ),
                const _TicketInfoRow(
                  title: 'Purchase Date',
                  value: 'Sat, Feb 21 2026',
                ),
                const _TicketPriceSection(),
                const _TicketTermsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketDetailsHeaderBar extends StatelessWidget {
  const _TicketDetailsHeaderBar();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      color: TmColors.ticketHeader,
      padding: EdgeInsets.only(top: topInset),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 60,
                child: Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
            const Expanded(
              child: Text(
                'Ticket Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42 / 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(
              width: 70,
              child: Text(
                'Help',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36 / 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2A2C2F),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF6D747C),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.25,
            ),
          ),
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
    final hasUploadedImage = uploadedImageSelection != null;
    final cardWidth = MediaQuery.sizeOf(context).width - 32;
    final headerHeight = (cardWidth * 0.56).clamp(180.0, 220.0).toDouble();
    final displayDateLabel = dateLabel == 'MON, SEP 14 2026, 6:40 PM'
        ? 'MON • 14 SEP, 2026 • 6:40 PM'
        : dateLabel;
    final card = Material(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.zero,
      color: Colors.transparent,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: headerHeight,
                width: double.infinity,
                child: hasUploadedImage
                    ? _TicketCardHeaderImage(selection: uploadedImageSelection!)
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          _TicketCardHeaderBackground(),
                          const Center(child: _TicketCardImageSlot()),
                        ],
                      ),
              ),
              Container(
                width: double.infinity,
                color: TmColors.ticketBody,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: _TicketCardBodyContent(
                  ticketCount: ticketCount,
                  title: title,
                  venue: venue,
                  titleTextKey: titleTextKey,
                  venueTextKey: venueTextKey,
                  onCountDoubleTap: onCountDoubleTap,
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            top: headerHeight - 28,
            child: Container(
              color: const Color(0xFF242528),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                displayDateLabel,
                key:
                    dateTextKey == null ? null : ValueKey<String>(dateTextKey!),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: ColoredBox(
              color: const Color(0xFF616A73),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                child: Text(
                  eventLabel,
                  key: ValueKey<String>(
                    '${titleTextKey ?? 'ticket'}-event-label',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.15,
                  ),
                ),
              ),
            ),
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
    );

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: card,
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.05,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        const SizedBox(
          width: 266,
          height: 3,
          child: ColoredBox(color: Colors.white),
        ),
        const SizedBox(height: 10),
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
              iconSize: 19,
              textSize: 16,
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
