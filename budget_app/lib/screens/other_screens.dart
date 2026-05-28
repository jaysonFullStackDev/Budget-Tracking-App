// lib/screens/other_screens.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/theme_provider.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../services/export_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/common/app_widgets.dart';
import '../widgets/common/transaction_tile.dart';
import '../widgets/common/budget_progress_card.dart';
import '../widgets/common/skeleton_loaders.dart';
import '../widgets/common/success_overlay.dart';
import '../widgets/charts/chart_widgets.dart';
import 'add_transaction_screen.dart';

// ═══════════════════════════════════════════════════════════════
// TRANSACTION HISTORY SCREEN (with pagination)
// ═══════════════════════════════════════════════════════════════

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});
  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filter = 'All';
  String _search = '';
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  static const int _pageSize = 20;
  int _visibleCount = 20;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      setState(() => _visibleCount += _pageSize);
    }
  }

  List get _filtered {
    final txns = context.read<TransactionProvider>().transactions;
    return txns.where((t) {
      final matchFilter = _filter == 'All' ||
          (_filter == 'Income'  && t.isIncome)  ||
          (_filter == 'Expense' && t.isExpense);
      final matchSearch = _search.isEmpty ||
          t.category.toLowerCase().contains(_search.toLowerCase()) ||
          t.description.toLowerCase().contains(_search.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txnP = context.watch<TransactionProvider>();
    final filtered = _filtered;
    final displayList = filtered.take(_visibleCount).toList();
    final hasMore = filtered.length > _visibleCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (txnP.transactions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Export CSV',
              onPressed: () async {
                await ExportService.exportToCsv(txnP.transactions);
              },
            ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() {
              _search = v;
              _visibleCount = _pageSize;
            }),
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      })
                  : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: ['All', 'Income', 'Expense'].map((f) =>
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: _filter == f,
                onSelected: (_) => setState(() {
                  _filter = f;
                  _visibleCount = _pageSize;
                }),
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: _filter == f ? Colors.white : null,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).toList()),
        ),
        // Result count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${filtered.length} transaction${filtered.length == 1 ? '' : 's'}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ),
        Expanded(
          child: txnP.isLoading
              ? const SingleChildScrollView(child: TransactionListSkeleton())
              : filtered.isEmpty
                  ? const EmptyState(
                      title: 'No transactions found',
                      subtitle: 'Try adjusting your filters',
                      icon: Icons.search_off_rounded,
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: displayList.length + (hasMore ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i >= displayList.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        }
                        final t = displayList[i];
                        return _buildDismissibleTile(context, txnP, t);
                      },
                    ),
        ),
      ]),
    );
  }

  Widget _buildDismissibleTile(BuildContext context, TransactionProvider txnP, TransactionModel t) {
    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDeleteSwipe(context),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        txnP.deleteTransaction(t.id);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: TransactionTile(
        transaction: t,
        onEdit: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) =>
            AddTransactionScreen(existing: t))),
      ),
    );
  }

  Future<bool> _confirmDeleteSwipe(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
              style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    ) ?? false;
  }

}


// ═══════════════════════════════════════════════════════════════
// BUDGET SCREEN
// ═══════════════════════════════════════════════════════════════

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetP = context.watch<BudgetProvider>();
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget — ${AppConstants.months[now.month - 1]} ${now.year}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: budgetP.isLoading
          ? const SingleChildScrollView(child: BudgetCardSkeleton())
          : budgetP.budgets.isEmpty
              ? const EmptyState(
                  title: 'No budgets set',
                  subtitle: 'Tap + to set a budget for a category',
                  icon: Icons.wallet_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: budgetP.budgets.length,
                  itemBuilder: (_, i) {
                    final b = budgetP.budgets[i];
                    return BudgetProgressCard(
                      budget: b,
                      onEdit: () => _showBudgetDialog(context, b),
                      onDelete: () => budgetP.deleteBudget(b.id),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBudgetDialog(context, null),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, BudgetModel? existing) {
    final isEdit = existing != null;
    final limitCtrl = TextEditingController(
      text: isEdit ? existing.budgetLimit.toStringAsFixed(0) : '');
    String selectedCat = existing?.category ??
        AppConstants.expenseCategories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) => Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isEdit ? 'Edit Budget' : 'Set Budget',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: AppConstants.expenseCategories.map((c) =>
                  DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setLocal(() => selectedCat = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: limitCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monthly Budget Limit',
                  prefixText: '₱ ',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final limit = double.tryParse(limitCtrl.text) ?? 0;
                    if (limit <= 0) return;
                    final userId = context.read<AuthProvider>().userId!;
                    final now = DateTime.now();
                    final ok = await context.read<BudgetProvider>().setBudget(
                      userId: userId,
                      category: selectedCat,
                      limit: limit,
                      month: now.month,
                      year: now.year,
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      if (ok) {
                        HapticFeedback.mediumImpact();
                        SuccessOverlay.show(ctx,
                          message: isEdit ? 'Budget updated!' : 'Budget set!');
                      }
                    }
                  },
                  child: Text(isEdit ? 'Update Budget' : 'Set Budget'),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}


// ═══════════════════════════════════════════════════════════════
// REPORTS SCREEN
// ═══════════════════════════════════════════════════════════════

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, Map<String, double>> _monthlyData = {};
  bool _loadingChart = true;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return;
    final data = await context.read<TransactionProvider>()
        .getLast6MonthsData(userId);
    if (mounted) setState(() { _monthlyData = data; _loadingChart = false; });
  }

  @override
  Widget build(BuildContext context) {
    final txnP = context.watch<TransactionProvider>();

    final expenses = txnP.transactions.where((t) =>
        t.isExpense && DateHelpers.isSameMonth(t.date, DateTime.now())).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    double cum = 0;
    final spots = <FlSpot>[];
    for (final t in expenses) {
      cum += t.amount;
      spots.add(FlSpot(t.date.day.toDouble(), cum));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(child: SummaryCard(
              title: 'This Month',
              amount: CurrencyFormatter.format(txnP.totalExpense),
              icon: Icons.trending_down_rounded,
              color: AppTheme.errorColor,
            )),
            const SizedBox(width: 12),
            Expanded(child: SummaryCard(
              title: 'Saved',
              amount: CurrencyFormatter.format(
                txnP.netBalance > 0 ? txnP.netBalance : 0),
              icon: Icons.savings_rounded,
              color: AppTheme.accentColor,
            )),
          ]),
          const SizedBox(height: 16),
          ChartCard(
            title: 'Expenses by Category',
            height: 200,
            child: ExpensePieChart(data: txnP.expenseByCategory),
          ),
          const SizedBox(height: 16),
          ChartCard(
            title: 'Monthly Income vs Expense',
            child: _loadingChart
                ? const Center(child: CircularProgressIndicator())
                : Column(children: [
                    SizedBox(height: 200,
                      child: MonthlyBarChart(data: _monthlyData)),
                    const SizedBox(height: 10),
                    const ChartLegend(),
                  ]),
          ),
          const SizedBox(height: 16),
          ChartCard(
            title: 'Spending Trend (This Month)',
            child: SpendingTrendChart(spots: spots),
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════════════
// SETTINGS SCREEN
// ═══════════════════════════════════════════════════════════════

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeP = context.watch<ThemeProvider>();
    final txnP = context.watch<TransactionProvider>();
    final theme = Theme.of(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white,
                    fontSize: 28, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Text(user?.name ?? '',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(user?.email ?? '',
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(height: 4),
              // Email verification badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    auth.isEmailVerified
                        ? Icons.verified_rounded
                        : Icons.warning_amber_rounded,
                    size: 14,
                    color: auth.isEmailVerified
                        ? AppTheme.successColor
                        : AppTheme.warningColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    auth.isEmailVerified ? 'Verified' : 'Not verified',
                    style: TextStyle(
                      fontSize: 11,
                      color: auth.isEmailVerified
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _tile(context, Icons.dark_mode_rounded, 'Dark Mode',
            trailing: Switch.adaptive(
              value: themeP.isDark,
              onChanged: (_) => themeP.toggleDarkMode(),
              activeColor: AppTheme.primaryColor,
            )),
          _tile(context, Icons.person_outline_rounded, 'Edit Profile',
            onTap: () => _editProfile(context, user?.name ?? '')),
          _tile(context, Icons.download_rounded, 'Export Transactions',
            subtitle: '${txnP.transactions.length} transactions',
            onTap: () async {
              if (txnP.transactions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No transactions to export'),
                    behavior: SnackBarBehavior.floating),
                );
                return;
              }
              await ExportService.exportToCsv(txnP.transactions);
            }),
          _tile(context, Icons.info_outline_rounded, 'App Version',
            subtitle: AppConstants.appVersion),
          const SizedBox(height: 8),
          _tile(context, Icons.logout_rounded, 'Sign Out',
            color: AppTheme.errorColor,
            onTap: () => _confirmLogout(context)),
        ]),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, {
    String? subtitle, Widget? trailing, VoidCallback? onTap, Color? color,
  }) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? Theme.of(context).colorScheme.surface;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: ListTile(
        leading: Icon(icon, color: color ?? AppTheme.primaryColor, size: 22),
        title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w500, color: color)),
        subtitle: subtitle != null ? Text(subtitle,
          style: TextStyle(color: Colors.grey[500], fontSize: 12)) : null,
        trailing: trailing ??
            (onTap != null ? const Icon(Icons.chevron_right_rounded,
              color: Colors.grey) : null),
        onTap: onTap,
      ),
    );
  }

  void _editProfile(BuildContext context, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: ctrl,
          maxLength: 50,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().updateProfile(name: ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save')),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
            child: const Text('Sign Out',
              style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
  }
}
