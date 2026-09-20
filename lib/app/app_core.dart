part of 'package:ticketmaster/main.dart';

class TicketmasterApp extends StatelessWidget {
  const TicketmasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticketmaster',
      navigatorKey: appUpdateNavigatorKey,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.noScaling),
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: TmTypography.family,
        colorScheme: const ColorScheme.light(primary: TmColors.brandBlue),
      ),
      home: const TicketmasterBootstrap(),
    );
  }
}

class TicketmasterBootstrap extends StatefulWidget {
  const TicketmasterBootstrap({super.key});

  @override
  State<TicketmasterBootstrap> createState() => _TicketmasterBootstrapState();
}

class _TicketmasterBootstrapState extends State<TicketmasterBootstrap> {
  Widget? _resolvedScreen;

  @override
  void initState() {
    super.initState();
    unawaited(_resolveInitialScreen());
  }

  Future<void> _resolveInitialScreen() async {
    await checkForGitHubUpdate(context);
    if (!mounted) return;

    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    Widget nextScreen;
    if (currentUser == null) {
      nextScreen = const TicketmasterLoginPage();
    } else if (!await _TicketmasterCloudStore.instance
        .isCurrentUserAuthorized()) {
      _TicketmasterCloudStore.instance.resetLocalState();
      await auth.signOut();
      nextScreen = const TicketmasterLoginPage();
    } else if (!await _TicketmasterCloudStore.instance
        .hasCurrentDeviceAccess()) {
      await auth.signOut();
      nextScreen = const TicketmasterLoginPage();
    } else if (_TicketmasterCloudStore.instance.isSessionExpired) {
      await _TicketmasterCloudStore.instance.clearAuthSession(
        releaseDeviceLock: true,
      );
      await auth.signOut();
      nextScreen = const TicketmasterLoginPage();
    } else {
      await _TicketmasterCloudStore.instance.ensureSessionForCurrentUser();
      nextScreen = const TicketmasterSplash();
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _resolvedScreen = nextScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resolvedScreen = _resolvedScreen;
    if (resolvedScreen != null) {
      return resolvedScreen;
    }

    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}

class TicketmasterSplash extends StatefulWidget {
  const TicketmasterSplash({super.key});

  @override
  State<TicketmasterSplash> createState() => _TicketmasterSplashState();
}

class _TicketmasterSplashState extends State<TicketmasterSplash>
    with WidgetsBindingObserver {
  late final VideoPlayerController _videoController;
  late final StartupConnectionProbe _connectionProbe;
  StreamSubscription<bool>? _connectionSubscription;
  bool _videoReady = false;
  bool _videoFinished = false;
  bool _fadeOut = false;
  bool _hasConnection = false;
  bool _isCheckingConnection = true;
  bool _navigating = false;
  bool _controllerDisposed = false;
  Timer? _fallbackTimer;
  Timer? _videoEndTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectionProbe = createStartupConnectionProbe();
    _connectionSubscription = _connectionProbe.onStatusChanged.listen(
      _handleConnectionUpdate,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAssets();
    });
    _videoController = VideoPlayerController.asset(TmAssets.splashVideo);
    unawaited(_initializeSplashVideo());
    unawaited(_refreshConnectionState(showLoader: true));
  }

  Future<void> _initializeSplashVideo() async {
    _fallbackTimer = Timer(const Duration(seconds: 5), _markVideoComplete);
    try {
      await _videoController.initialize();
      if (!mounted) return;
      await _videoController.setLooping(false);
      await _videoController.setVolume(0);
      await _videoController.play();
      final duration = _videoController.value.duration;
      if (duration > Duration.zero) {
        _videoEndTimer = Timer(
          duration + const Duration(milliseconds: 80),
          _markVideoComplete,
        );
      }
      setState(() => _videoReady = true);
    } catch (_) {
      if (!mounted) return;
      _markVideoComplete();
    }
  }

  Future<void> _refreshConnectionState({required bool showLoader}) async {
    if (!mounted || _navigating) return;
    if (showLoader && !_isCheckingConnection) {
      setState(() => _isCheckingConnection = true);
    }
    final hasConnection = await _connectionProbe.hasConnection();
    if (!mounted || _navigating) return;
    _applyConnectionState(hasConnection);
  }

  void _handleConnectionUpdate(bool hasConnection) {
    if (!mounted || _navigating) return;
    _applyConnectionState(hasConnection);
  }

  void _applyConnectionState(bool hasConnection) {
    if (_hasConnection == hasConnection && !_isCheckingConnection) {
      return;
    }
    setState(() {
      _hasConnection = hasConnection;
      _isCheckingConnection = false;
    });
    _maybeNavigate();
  }

  void _maybeNavigate() {
    if (!_videoFinished || !_hasConnection || _navigating || !mounted) {
      return;
    }
    _startExitFlow();
  }

  void _markVideoComplete() {
    if (!mounted || _videoFinished) return;
    _fallbackTimer?.cancel();
    _videoEndTimer?.cancel();
    if (!_controllerDisposed && _videoController.value.isInitialized) {
      _videoController.pause();
    }
    setState(() => _videoFinished = true);
    _maybeNavigate();
  }

  void _startExitFlow() {
    if (!mounted || _navigating) return;
    _navigating = true;
    setState(() => _fadeOut = true);
    Future.delayed(TmDurations.splashFade, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(TicketmasterHomeRoute());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_controllerDisposed &&
          _videoController.value.isInitialized &&
          !_videoFinished) {
        _videoController.play();
      }
      unawaited(_refreshConnectionState(showLoader: false));
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (!_controllerDisposed && _videoController.value.isInitialized) {
        _videoController.pause();
      }
    }
    if (state == AppLifecycleState.detached) {
      _disposeSplashController();
    }
  }

  void _disposeSplashController() {
    if (_controllerDisposed) {
      return;
    }
    _controllerDisposed = true;
    _videoController.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectionSubscription?.cancel();
    _connectionProbe.dispose();
    _fallbackTimer?.cancel();
    _videoEndTimer?.cancel();
    _disposeSplashController();
    super.dispose();
  }

  void _precacheAssets() {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final screenWidth = MediaQuery.of(context).size.width;

    void precacheAsset(String asset, {double? width, double? height}) {
      final cacheWidth = width != null ? (width * dpr).round() : null;
      final cacheHeight = height != null ? (height * dpr).round() : null;
      final image = ResizeImage(
        AssetImage(asset),
        width: cacheWidth,
        height: cacheHeight,
      );
      precacheImage(image, context);
    }

    // Splash + header assets.
    precacheAsset(TmAssets.splashLogo, width: 120, height: 150);
    precacheAsset(TmAssets.brandLogo, height: 16);
    precacheAsset(TmAssets.flag, width: 24, height: 24);
    precacheAsset(TmAssets.locationIcon, width: 18, height: 18);
    precacheAsset(TmAssets.dateIcon, width: 18, height: 18);
    precacheAsset(TmAssets.searchIcon, width: 16, height: 16);

    // Discover hero + person.
    precacheAsset(TmAssets.discoverHero, width: screenWidth);
    precacheAsset(TmAssets.discoverPerson, width: screenWidth);

    // For You and Sell.
    precacheAsset(TmAssets.forYouEmpty, width: 110, height: 110);
    precacheAsset(TmAssets.sellHero, width: 120, height: 120);

    // Bottom nav icons.
    precacheAsset(TmAssets.bottomDiscover, width: 24, height: 24);
    precacheAsset(TmAssets.bottomDiscoverOn, width: 24, height: 24);
    precacheAsset(TmAssets.bottomForYou, width: 24, height: 24);
    precacheAsset(TmAssets.bottomForYouOn, width: 24, height: 24);
    precacheAsset(TmAssets.bottomTickets, width: 24, height: 24);
    precacheAsset(TmAssets.bottomTicketsOn, width: 24, height: 24);
    precacheAsset(TmAssets.bottomSell, width: 24, height: 24);
    precacheAsset(TmAssets.bottomSellOn, width: 24, height: 24);
    precacheAsset(TmAssets.bottomAccount, width: 24, height: 24);
    precacheAsset(TmAssets.bottomAccountOn, width: 24, height: 24);
  }

  @override
  Widget build(BuildContext context) {
    final showNetworkOverlay = _videoFinished && !_hasConnection;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedOpacity(
        opacity: _fadeOut ? 0.0 : 1.0,
        duration: TmDurations.splashFade,
        curve: TmCurves.easeOut,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Colors.black,
              child: _videoReady
                  ? _SplashVideoPlayer(controller: _videoController)
                  : const SizedBox.expand(),
            ),
            if (showNetworkOverlay)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  minimum: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  child: _SplashNetworkStatusCard(
                    isCheckingConnection: _isCheckingConnection,
                    onRetry: () {
                      unawaited(_refreshConnectionState(showLoader: true));
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SplashVideoPlayer extends StatelessWidget {
  const _SplashVideoPlayer({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.size;
    if (size.isEmpty) {
      return const SizedBox.expand();
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

class _SplashNetworkStatusCard extends StatelessWidget {
  const _SplashNetworkStatusCard({
    required this.isCheckingConnection,
    required this.onRetry,
  });

  final bool isCheckingConnection;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isCheckingConnection
                ? 'Checking your internet connection...'
                : 'Waiting for internet connection...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (isCheckingConnection)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
              child: const Text('Retry now'),
            ),
        ],
      ),
    );
  }
}

class TicketmasterHomeRoute extends PageRouteBuilder<void> {
  TicketmasterHomeRoute()
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) {
            return const TicketmasterHomeShell();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: TmCurves.easeOut,
            );
            // Home fades in while sliding up subtly to avoid a hard cut.
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

class _MyTicketDetailsRoute extends PageRouteBuilder<void> {
  _MyTicketDetailsRoute({
    required _TicketListEntry ticket,
    required int ticketCount,
  }) : super(
          transitionDuration: const Duration(milliseconds: 260),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (context, animation, secondaryAnimation) {
            return _MyTicketDetailsPage(
              ticket: ticket,
              ticketCount: ticketCount,
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.03, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

class _TicketDetailsInfoRoute extends PageRouteBuilder<void> {
  _TicketDetailsInfoRoute({
    required _TicketListEntry ticket,
    required int ticketPageIndex,
  }) : super(
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          pageBuilder: (context, animation, secondaryAnimation) {
            return _TicketDetailsInfoPage(
              ticket: ticket,
              ticketPageIndex: ticketPageIndex,
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.025, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

class _ViewTicketRoute extends PageRouteBuilder<void> {
  _ViewTicketRoute({required _TicketListEntry ticket, required int ticketCount})
      : super(
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          pageBuilder: (context, animation, secondaryAnimation) {
            return _ViewTicketPage(ticket: ticket, ticketCount: ticketCount);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.02, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}
