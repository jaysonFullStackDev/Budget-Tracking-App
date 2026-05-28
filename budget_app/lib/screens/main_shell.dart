// lib/screens/main_shell.dart
// Main scaffold with bottom navigation bar that hosts all tab screens.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../utils/session_manager.dart';
import '../widgets/common/offline_banner.dart';
import 'home_screen.dart';
import 'other_screens.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TransactionHistoryScreen(),
    BudgetScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      if (userId != null) {
        final txnP = context.read<TransactionProvider>();
        final budgetP = context.read<BudgetProvider>();
        final now = DateTime.now();

        // Wire transaction updates to budget spending calculation
        txnP.onTransactionsUpdated = (txns) {
          budgetP.updateSpending(txns, now.month, now.year);
        };

        txnP.subscribeToTransactions(userId);
        budgetP.subscribeToMonthlyBudgets(userId, now.month, now.year);

        // Initialize session timeout
        SessionManager().initialize(
          onSessionExpired: () => _handleSessionExpired(),
        );
      }
    });
  }

  void _handleSessionExpired() {
    if (!mounted) return;
    context.read<AuthProvider>().signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expired. Please sign in again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    SessionManager().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Track user activity on any interaction
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SessionManager().recordActivity(),
      onPanDown: (_) => SessionManager().recordActivity(),
      child: Scaffold(
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: IndexedStack(
                index:    _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            SessionManager().recordActivity();
            setState(() => _currentIndex = i);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet_outlined),
              activeIcon: Icon(Icons.wallet_rounded),
              label: 'Budget',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
