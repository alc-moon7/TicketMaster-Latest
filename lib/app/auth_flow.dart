part of 'package:ticketmaster/main.dart';

class TicketmasterLoginPage extends StatefulWidget {
  const TicketmasterLoginPage({super.key});

  @override
  State<TicketmasterLoginPage> createState() => _TicketmasterLoginPageState();
}

class _TicketmasterLoginPageState extends State<TicketmasterLoginPage> {
  bool _submitting = false;
  String? _errorText;

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!await _TicketmasterCloudStore.instance.isEmailAuthorized(
        FirebaseAuth.instance.currentUser?.email,
      )) {
        await GoogleSignIn.instance.signOut();
        await FirebaseAuth.instance.signOut();
        if (!mounted) {
          return;
        }
        setState(() {
          _errorText = 'This Google account is not authorized to use this app.';
        });
        return;
      }
      await _TicketmasterCloudStore.instance.markLoginSucceeded();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(_TicketmasterSplashRoute());
    } on _TicketmasterSingleDeviceException catch (error) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText =
            '${error.message} Please log out from the other device first.';
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = _friendlyAuthMessage(error);
      });
    } on GoogleSignInException catch (error) {
      if (!mounted) {
        return;
      }
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return;
      }
      setState(() {
        _errorText = _googleSignInMessage(error);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = 'Google sign-in failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  String _friendlyAuthMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase yet.';
      case 'account-exists-with-different-credential':
        return 'This email is already registered with a different sign-in method.';
      default:
        return error.message ?? 'Login failed. Please try again.';
    }
  }

  String _googleSignInMessage(GoogleSignInException error) {
    final description = error.description?.trim();
    switch (error.code) {
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        if (description != null && description.isNotEmpty) {
          return 'Google sign-in config error: $description';
        }
        return 'Google sign-in is not configured correctly. Check the SHA-1 '
            'fingerprint and package name registered in Firebase.';
      default:
        if (description != null && description.isNotEmpty) {
          return 'Google sign-in failed: $description';
        }
        return 'Google sign-in failed (${error.code.name}). Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(TmAssets.discoverHero, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.78),
                  const Color(0xFF071A33).withValues(alpha: 0.95),
                  const Color(0xFF020B15),
                ],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.08),
                radius: 0.95,
                colors: [Colors.transparent, Color(0xE6020B15)],
                stops: [0.52, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      TmAssets.brandLogo,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(flex: 3),
                  Center(
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: const BoxDecoration(
                        color: Color(0xFF026CDF),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          TmAssets.loginMark,
                          width: 46,
                          height: 72,
                          fit: BoxFit.contain,
                          color: Colors.white,
                          colorBlendMode: BlendMode.srcIn,
                          filterQuality: FilterQuality.high,
                          isAntiAlias: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF58B8FF), TmColors.brandBlue],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x55026CDF),
                                blurRadius: 18,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const material.Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            height: 0.96,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_errorText != null) ...[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xE6FFF1F1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFD1D1)),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 16,
                              color: Color(0xFFCE2C37),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: material.Text(
                              _errorText!,
                              style: const TextStyle(
                                color: Color(0xFF9B1C24),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _submitting ? null : _signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF111827),
                        backgroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white70,
                        side: const BorderSide(
                          color: Color(0xFFD0D5DD),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  TmColors.brandBlue,
                                ),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _GoogleLogo(size: 20),
                                SizedBox(width: 10),
                                material.Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const Spacer(flex: 5),
                  const material.Text(
                    '\u00A9 2026 Moonx.dev. All Rights Reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0x99FFFFFF),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
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

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 48.0;
    canvas.save();
    canvas.scale(scale);

    canvas.drawPath(_redPath(), Paint()..color = const Color(0xFFEA4335));
    canvas.drawPath(_bluePath(), Paint()..color = const Color(0xFF4285F4));
    canvas.drawPath(_yellowPath(), Paint()..color = const Color(0xFFFBBC05));
    canvas.drawPath(_greenPath(), Paint()..color = const Color(0xFF34A853));

    canvas.restore();
  }

  Path _redPath() => Path()
    ..moveTo(24, 9.5)
    ..cubicTo(27.54, 9.5, 30.71, 10.72, 33.21, 13.1)
    ..lineTo(40.06, 6.25)
    ..cubicTo(35.9, 2.38, 30.47, 0, 24, 0)
    ..cubicTo(14.62, 0, 6.51, 5.38, 2.56, 13.22)
    ..lineTo(10.54, 19.41)
    ..cubicTo(12.43, 13.72, 17.74, 9.5, 24, 9.5)
    ..close();

  Path _bluePath() => Path()
    ..moveTo(46.98, 24.55)
    ..cubicTo(46.98, 22.98, 46.83, 21.46, 46.6, 20.0)
    ..lineTo(24, 20.0)
    ..lineTo(24, 29.02)
    ..lineTo(36.94, 29.02)
    ..cubicTo(36.36, 31.98, 34.68, 34.5, 32.16, 36.2)
    ..lineTo(39.89, 42.2)
    ..cubicTo(44.4, 38.02, 46.98, 31.84, 46.98, 24.55)
    ..close();

  Path _yellowPath() => Path()
    ..moveTo(10.53, 28.59)
    ..cubicTo(10.05, 27.14, 9.77, 25.6, 9.77, 24.0)
    ..cubicTo(9.77, 22.4, 10.04, 20.86, 10.53, 19.41)
    ..lineTo(2.55, 13.22)
    ..cubicTo(0.92, 16.46, 0, 20.12, 0, 24.0)
    ..cubicTo(0, 27.88, 0.92, 31.54, 2.56, 34.78)
    ..lineTo(10.53, 28.59)
    ..close();

  Path _greenPath() => Path()
    ..moveTo(24, 48)
    ..cubicTo(30.48, 48, 35.93, 45.87, 39.89, 42.19)
    ..lineTo(32.16, 36.19)
    ..cubicTo(30.01, 37.64, 27.24, 38.49, 24.0, 38.49)
    ..cubicTo(17.74, 38.49, 12.43, 34.27, 10.53, 28.58)
    ..lineTo(2.55, 34.77)
    ..cubicTo(6.51, 42.62, 14.62, 48, 24, 48)
    ..close();

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TicketmasterSplashRoute extends PageRouteBuilder<void> {
  _TicketmasterSplashRoute()
      : super(
          transitionDuration: const Duration(milliseconds: 260),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, animation, secondaryAnimation) {
            return const TicketmasterSplash();
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
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

class _TicketmasterLoginRoute extends PageRouteBuilder<void> {
  _TicketmasterLoginRoute()
      : super(
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          pageBuilder: (context, animation, secondaryAnimation) {
            return const TicketmasterLoginPage();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(opacity: curved, child: child);
          },
        );
}
