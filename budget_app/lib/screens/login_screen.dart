// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/common/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth    = context.read<AuthProvider>();
    final success = await auth.signIn(
      email:    _emailCtrl.text,
      password: _passCtrl.text,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 24),

              // Logo & Title
              Center(
                child: Column(children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color:        AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                      size: 38, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(AppConstants.appName,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('Welcome back! Sign in to continue.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500])),
                ]),
              ),
              const SizedBox(height: 40),

              // Error banner
              if (auth.errorMessage != null)
                ErrorBanner(
                  message:   auth.errorMessage!,
                  onDismiss: () => context.read<AuthProvider>().clearError(),
                ),

              // Email field
              AppTextField(
                controller:  _emailCtrl,
                label:       'Email Address',
                hint:        'you@example.com',
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

              // Password field
              AppTextField(
                controller: _passCtrl,
                label:      'Password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/forgot-password'),
                  child: const Text('Forgot Password?',
                    style: TextStyle(color: AppTheme.primaryColor, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 20),

              // Login button
              LoadingButton(
                text:      'Sign In',
                isLoading: auth.isLoading,
                onPressed: _login,
              ),
              const SizedBox(height: 20),

              // Divider
              Row(children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or', style: TextStyle(color: Colors.grey[400])),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ]),
              const SizedBox(height: 20),

              // Sign up link
              Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text("Don't have an account? ",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                    child: const Text('Sign Up',
                      style: TextStyle(
                        color:      AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize:   14,
                      )),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
