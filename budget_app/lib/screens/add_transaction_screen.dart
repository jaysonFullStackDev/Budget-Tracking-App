// lib/screens/add_transaction_screen.dart
// Form screen for adding and editing transactions.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/input_sanitizer.dart';
import '../widgets/common/app_widgets.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existing; // null = add mode, non-null = edit mode

  const AddTransactionScreen({super.key, this.existing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _formKey     = GlobalKey<FormState>();
  final _amountCtrl  = TextEditingController();
  final _descCtrl    = TextEditingController();

  String   _type       = AppConstants.expense;
  String   _category   = AppConstants.expenseCategories.first;
  DateTime _date       = DateTime.now();
  bool     _isLoading  = false;

  bool get _isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);

    if (_isEditMode) {
      final t = widget.existing!;
      _type      = t.transactionType;
      _category  = t.category;
      _date      = t.date;
      _amountCtrl.text = t.amount.toStringAsFixed(2);
      _descCtrl.text   = t.description;
      _tabCtrl.index   = t.isIncome ? 1 : 0;
    }

    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() {
          _type = _tabCtrl.index == 0 ? AppConstants.expense : AppConstants.income;
          _category = _tabCtrl.index == 0
              ? AppConstants.expenseCategories.first
              : AppConstants.incomeCategories.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  List<String> get _currentCategories => _type == AppConstants.expense
      ? AppConstants.expenseCategories
      : AppConstants.incomeCategories;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: _date,
      firstDate:   DateTime(2020),
      lastDate:    DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final txnP   = context.read<TransactionProvider>();
    final userId = context.read<AuthProvider>().userId!;
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;

    bool ok;
    if (_isEditMode) {
      ok = await txnP.updateTransaction(
        widget.existing!.copyWith(
          transactionType: _type,
          category:        _category,
          amount:          amount,
          description:     _descCtrl.text.trim(),
          date:            _date,
        ),
      );
    } else {
      ok = await txnP.addTransaction(
        userId:      userId,
        type:        _type,
        category:    _category,
        amount:      amount,
        date:        _date,
        description: _descCtrl.text.trim(),
      );
    }

    setState(() => _isLoading = false);
    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditMode
            ? 'Transaction updated!' : 'Transaction added!'),
        backgroundColor: AppTheme.successColor,
        behavior:        SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:            Text(_isEditMode ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor:  Colors.transparent,
        elevation:        0,
        leading:          const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Type Tabs ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color:        theme.brightness == Brightness.dark
                    ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller:      _tabCtrl,
                labelColor:      Colors.white,
                unselectedLabelColor: Colors.grey,
                indicator: BoxDecoration(
                  color:        _type == AppConstants.expense
                      ? AppTheme.errorColor : AppTheme.successColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor:  Colors.transparent,
                tabs: const [
                  Tab(text: 'Expense'),
                  Tab(text: 'Income'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Amount Field ───────────────────────────────────────
            Text('Amount', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600, color: Colors.grey[600])),
            const SizedBox(height: 8),
            TextFormField(
              controller:  _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText:  '₱ ',
                prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor),
                hintText:    '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled:    true,
              ),
              validator: (v) => InputSanitizer.validateAmount(v),
            ),
            const SizedBox(height: 20),

            // ── Category Grid ──────────────────────────────────────
            Text('Category', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600, color: Colors.grey[600])),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _currentCategories.map((cat) =>
                CategoryChip(
                  category:   cat,
                  isSelected: _category == cat,
                  onTap:      () => setState(() => _category = cat),
                ),
              ).toList(),
            ),
            const SizedBox(height: 20),

            // ── Date Picker ────────────────────────────────────────
            Text('Date', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600, color: Colors.grey[600])),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color:        theme.brightness == Brightness.dark
                      ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_rounded,
                    size: 18, color: AppTheme.primaryColor),
                  const SizedBox(width: 10),
                  Text(DateHelpers.formatDate(_date),
                    style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            // ── Description ────────────────────────────────────────
            AppTextField(
              controller: _descCtrl,
              label:      'Description (optional)',
              hint:       'e.g. Grocery run at SM',
              prefixIcon: Icons.notes_rounded,
            ),
            const SizedBox(height: 32),

            // ── Submit ─────────────────────────────────────────────
            LoadingButton(
              text:      _isEditMode ? 'Update Transaction' : 'Save Transaction',
              isLoading: _isLoading,
              onPressed: _submit,
              color: _type == AppConstants.expense
                  ? AppTheme.errorColor : AppTheme.successColor,
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}
