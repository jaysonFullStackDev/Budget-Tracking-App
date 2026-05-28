// test/integration/app_flow_test.dart
// Integration tests covering full user flows end-to-end.
// Run with: flutter test integration_test/app_flow_test.dart --device-id=<id>
//
// NOTE: Integration tests require a real device or emulator and a Firebase
// emulator running locally. See README.md for setup instructions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:budget_tracking_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── Test 1: App launches and shows splash screen ───────────────
  group('App Launch', () {
    testWidgets('Splash screen is displayed on launch', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show either login or home depending on auth state
      final hasLogin  = find.text('Sign In').evaluate().isNotEmpty;
      final hasHome   = find.text('BudgetTrack').evaluate().isNotEmpty;
      expect(hasLogin || hasHome, isTrue);
    });
  });

  // ── Test 2: Login flow ─────────────────────────────────────────
  group('Authentication Flow', () {
    testWidgets('User can navigate to signup from login', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // If on login screen, tap sign up link
      if (find.text("Don't have an account?").evaluate().isNotEmpty) {
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();
        expect(find.text('Create Account'), findsOneWidget);
      }
    });

    testWidgets('Login shows validation errors for empty fields', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (find.text('Sign In').evaluate().isNotEmpty) {
        // Tap sign in without filling fields
        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Email is required'), findsOneWidget);
      }
    });

    testWidgets('Login shows error for invalid credentials', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (find.byType(TextFormField).evaluate().length >= 2) {
        // Enter invalid credentials
        await tester.enterText(
          find.byType(TextFormField).first, 'wrong@email.com');
        await tester.enterText(
          find.byType(TextFormField).last,  'wrongpassword');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Should show an error message
        expect(find.byType(ErrorBanner).evaluate().isNotEmpty ||
               find.textContaining('No account').evaluate().isNotEmpty, isTrue);
      }
    });
  });

  // ── Test 3: Bottom Navigation ──────────────────────────────────
  group('Navigation', () {
    testWidgets('Bottom nav tabs switch screens', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Only test navigation if authenticated (home screen visible)
      if (find.byType(BottomNavigationBar).evaluate().isNotEmpty) {
        // Tap History tab
        await tester.tap(find.byIcon(Icons.receipt_long_outlined));
        await tester.pumpAndSettle();
        expect(find.text('Transaction History'), findsOneWidget);

        // Tap Budget tab
        await tester.tap(find.byIcon(Icons.wallet_outlined));
        await tester.pumpAndSettle();
        expect(find.textContaining('Budget'), findsWidgets);

        // Tap Reports tab
        await tester.tap(find.byIcon(Icons.bar_chart_outlined));
        await tester.pumpAndSettle();
        expect(find.text('Reports & Analytics'), findsOneWidget);

        // Tap Profile tab
        await tester.tap(find.byIcon(Icons.person_outline_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Profile & Settings'), findsOneWidget);

        // Return to Home
        await tester.tap(find.byIcon(Icons.home_outlined));
        await tester.pumpAndSettle();
      }
    });
  });

  // ── Test 4: Add Transaction ────────────────────────────────────
  group('Transaction Management', () {
    testWidgets('FAB opens Add Transaction screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(find.text('Add Transaction'), findsOneWidget);
      }
    });

    testWidgets('Add transaction validates empty amount', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Tap Save without entering amount
        await tester.tap(find.widgetWithText(ElevatedButton, 'Save Transaction'));
        await tester.pumpAndSettle();

        expect(find.text('Amount is required'), findsOneWidget);
      }
    });

    testWidgets('Category chips are selectable', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Tap Food category chip
        if (find.text('Food').evaluate().isNotEmpty) {
          await tester.tap(find.text('Food'));
          await tester.pumpAndSettle();
          // Food chip should now be selected (no crash)
          expect(find.text('Food'), findsOneWidget);
        }
      }
    });
  });

  // ── Test 5: Budget Screen ──────────────────────────────────────
  group('Budget Management', () {
    testWidgets('Budget FAB opens set budget dialog', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (find.byType(BottomNavigationBar).evaluate().isNotEmpty) {
        // Navigate to Budget tab
        await tester.tap(find.byIcon(Icons.wallet_outlined));
        await tester.pumpAndSettle();

        if (find.byType(FloatingActionButton).evaluate().isNotEmpty) {
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          expect(find.text('Set Budget'), findsWidgets);
        }
      }
    });
  });

  // ── Test 6: Dark Mode Toggle ───────────────────────────────────
  group('Settings', () {
    testWidgets('Dark mode toggle is present on settings screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (find.byType(BottomNavigationBar).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.person_outline_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Dark Mode'), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);
      }
    });
  });
}
