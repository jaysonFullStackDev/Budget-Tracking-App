// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/common/app_widgets.dart';
import '../widgets/common/password_strength.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();
  String _password = '';

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthProvider>().signUp(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/verify-email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Create Account',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Start managing your finances today.',
                style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              const SizedBox(height: 28),

              if (auth.errorMessage != null)
                ErrorBanner(
                  message:   auth.errorMessage!,
                  onDismiss: () => context.read<AuthProvider>().clearError(),
                ),

              AppTextField(
                controller: _nameCtrl, label: 'Full Name',
                hint: 'Juan Dela Cruz',
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Full name is required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller:  _emailCtrl, label: 'Email Address',
                prefixIcon:  Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
                  if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _passCtrl, label: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                onChanged: (v) => setState(() => _password = v),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'At least 6 characters';
                  return null;
                },
              ),
              PasswordStrengthIndicator(password: _password),
              const SizedBox(height: 14),
              AppTextField(
                controller: _confCtrl, label: 'Confirm Password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: (v) {
                  if (v != _passCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              LoadingButton(
                text: 'Create Account',
                isLoading: auth.isLoading,
                onPressed: _register,
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Already have an account? ',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Sign In',
                      style: TextStyle(color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Forgot Password Screen ─────────────────────────────────────
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool  _sent      = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().resetPassword(_emailCtrl.text);
    if (ok && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'), elevation: 0,
        backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.mark_email_read_rounded,
                  size: 72, color: AppTheme.primaryColor),
                const SizedBox(height: 20),
                Text('Email Sent!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text('Check your inbox for password reset instructions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500])),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Back to Login'),
                ),
              ])
            : Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text('Enter your email address and we\'ll send you a link to reset your password.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    const SizedBox(height: 24),
                    if (auth.errorMessage != null)
                      ErrorBanner(message: auth.errorMessage!),
                    AppTextField(
                      controller:  _emailCtrl,
                      label:       'Email Address',
                      prefixIcon:  Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
                        if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(
                      text:      'Send Reset Link',
                      isLoading: auth.isLoading,
                      onPressed: _send,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
