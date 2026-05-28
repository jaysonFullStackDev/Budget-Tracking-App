// lib/screens/email_verification_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/common/app_widgets.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _checkTimer;
  bool _canResend = true;
  int _cooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Periodically check if email is verified
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkVerification());
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    final auth = context.read<AuthProvider>();
    final verified = await auth.checkEmailVerified();
    if (verified && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;
    await context.read<AuthProvider>().resendVerificationEmail();
    setState(() {
      _canResend = false;
      _cooldown = 60;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _cooldown--);
      if (_cooldown <= 0) {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_rounded,
                size: 80, color: AppTheme.primaryColor),
              const SizedBox(height: 24),
              Text('Verify Your Email',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to\n${auth.user?.email ?? "your email"}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              LoadingButton(
                text: _canResend
                    ? 'Resend Verification Email'
                    : 'Resend in ${_cooldown}s',
                isLoading: false,
                onPressed: _canResend ? _resendEmail : null,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Sign in with a different account',
                  style: TextStyle(color: AppTheme.primaryColor)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Waiting for verification...',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
