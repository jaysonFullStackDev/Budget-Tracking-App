// lib/screens/main_shell.dart
// Main scaffold with floating bottom navigation and center FAB.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../utils/app_theme.dart';
import '../utils/session_manager.dart';
import '../widgets/common/offline_banner.dart';
import 'home_screen.dart';
import 'add_transaction_screen.dart';
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
    SizedBox(), // Placeholder for center FAB
    BudgetScreen(),
    ReportsScreen(),
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

        txnP.onTransactionsUpdated = (txns) {
          budgetP.updateSpending(txns, now.month, now.year);
        };

        txnP.subscribeToTransactions(userId);
        budgetP.subscribeToMonthlyBudgets(userId, now.month, now.year);

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
                index: _currentIndex == 2 ? 0 : _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
        floatingActionButton: _buildCenterFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildFloatingNav(context),
      ),
    );
  }

  Widget _buildCenterFAB() {
    return Container(
      height: 60,
      width: 60,
      margin: const EdgeInsets.only(top: 24),
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
        },
        backgroundColor: AppTheme.primaryColor,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildFloatingNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          height: 68,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _navItem(1, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'History'),
              const SizedBox(width: 56), // Space for center FAB
              _navItem(3, Icons.wallet_outlined, Icons.wallet_rounded, 'Budget'),
              _navItem(4, Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Reports'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        SessionManager().recordActivity();
        setState(() => _currentIndex = index);
      },
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.primaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppTheme.primaryColor : Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            // Active dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 5 : 0,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
