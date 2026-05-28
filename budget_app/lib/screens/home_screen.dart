// lib/screens/home_screen.dart
// Dashboard: balance summary, budget alerts, and recent transactions.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/common/app_widgets.dart';
import '../widgets/common/transaction_tile.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final txnP    = context.watch<TransactionProvider>();
    final budgetP = context.watch<BudgetProvider>();
    final theme   = Theme.of(context);
    final now     = DateTime.now();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: txnP.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  final uid = auth.userId;
                  if (uid != null) txnP.subscribeToTransactions(uid);
                },
                child: CustomScrollView(slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(context, auth, txnP),
                  ),
                  if (budgetP.exceededBudgets.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildAlerts(context, budgetP),
                    ),
                  SliverToBoxAdapter(
                    child: _buildSummaryCards(context, txnP),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: SectionHeader(
                        title:       'Recent Transactions',
                        actionLabel: 'See All',
                        onAction: () {},
                      ),
                    ),
                  ),
                  if (txnP.recentTransactions.isEmpty)
                    const SliverToBoxAdapter(
                      child: EmptyState(
                        title:    'No transactions yet',
                        subtitle: 'Tap + to add your first transaction',
                        icon:     Icons.receipt_long_rounded,
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final t = txnP.recentTransactions[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TransactionTile(
                              transaction: t,
                              onDelete: txnP.isDeleting(t.id)
                                  ? null
                                  : () => _confirmDelete(ctx, txnP, t.id),
                            ),
                          );
                        },
                        childCount: txnP.recentTransactions.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
        backgroundColor: AppTheme.primaryColor,
        icon:  const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add', style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider auth,
      TransactionProvider txnP) {
    final name  = auth.user?.name.split(' ').first ?? 'there';
    final hour  = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' :
                     hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return Container(
      margin:  const EdgeInsets.all(20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:  [AppTheme.primaryColor, AppTheme.primaryDark],
          begin:   Alignment.topLeft,
          end:     Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35),
            blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$greeting,',
              style: TextStyle(color: Colors.white.withOpacity(0.8),
                fontSize: 13)),
            Text(name,
              style: const TextStyle(color: Colors.white,
                fontSize: 20, fontWeight: FontWeight.w700)),
          ]),
          Container(
            padding:    const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:        Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_outlined,
              color: Colors.white, size: 22),
          ),
        ]),
        const SizedBox(height: 20),
        Text('Current Balance',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(txnP.netBalance),
          style: const TextStyle(color: Colors.white,
            fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(DateHelpers.formatMonth(DateTime.now()),
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
      ]),
    );
  }

  Widget _buildAlerts(BuildContext context, BudgetProvider budgetP) {
    return Container(
      margin:  const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppTheme.errorColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.25)),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded,
          color: AppTheme.warningColor, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${budgetP.exceededBudgets.length} budget(s) exceeded: '
            '${budgetP.exceededBudgets.map((b) => b.category).join(', ')}',
            style: const TextStyle(fontSize: 13, color: AppTheme.errorColor,
              fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    );
  }

  Widget _buildSummaryCards(BuildContext context, TransactionProvider txnP) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(children: [
        Expanded(
          child: SummaryCard(
            title:  'Income',
            amount: CurrencyFormatter.format(txnP.totalIncome),
            icon:   Icons.trending_up_rounded,
            color:  AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryCard(
            title:  'Expenses',
            amount: CurrencyFormatter.format(txnP.totalExpense),
            icon:   Icons.trending_down_rounded,
            color:  AppTheme.errorColor,
          ),
        ),
      ]),
    );
  }

  void _confirmDelete(BuildContext context, TransactionProvider txnP,
      String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Delete Transaction'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              txnP.deleteTransaction(id);
              Navigator.pop(context);
            },
            child: const Text('Delete',
              style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
  }
}
