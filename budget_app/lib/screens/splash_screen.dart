// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>    _fadeAnim;
  late Animation<double>    _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200));
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.status == AuthStatus.authenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color:        Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                  size: 48, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(AppConstants.appName,
                style: const TextStyle(
                  color:      Colors.white,
                  fontSize:   32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                )),
              const SizedBox(height: 8),
              Text('Track. Budget. Thrive.',
                style: TextStyle(
                  color:    Colors.white.withOpacity(0.7),
                  fontSize: 15,
                )),
              const SizedBox(height: 48),
              SizedBox(
                width: 30,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor:      const AlwaysStoppedAnimation<Color>(Colors.white),
                  borderRadius:    BorderRadius.circular(4),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
