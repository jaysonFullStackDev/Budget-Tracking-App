// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _gradientCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Alignment> _gradientBegin;
  late Animation<Alignment> _gradientEnd;

  @override
  void initState() {
    super.initState();

    // Content animation
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );

    // Gradient animation
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _gradientBegin = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topLeft, end: Alignment.bottomLeft),
        weight: 1,
      ),
    ]).animate(_gradientCtrl);
    _gradientEnd = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomRight, end: Alignment.topRight),
        weight: 1,
      ),
    ]).animate(_gradientCtrl);

    _ctrl.forward();
    _gradientCtrl.repeat(reverse: true);
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;

    if (!onboardingDone) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      final auth = context.read<AuthProvider>();
      if (auth.status == AuthStatus.authenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _gradientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientCtrl,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _gradientBegin.value,
                end: _gradientEnd.value,
                colors: const [
                  AppTheme.primaryDark,
                  AppTheme.primaryColor,
                  Color(0xFF1B5E20),
                ],
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track. Budget. Thrive.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 30,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'v${AppConstants.appVersion}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
