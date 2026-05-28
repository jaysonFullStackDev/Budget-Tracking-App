// lib/providers/transaction_provider.dart
// Manages transaction state and exposes computed financial summaries.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../utils/constants.dart';
import '../utils/input_sanitizer.dart';
import '../utils/retry_helper.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();
  static const _uuid = Uuid();
  final RateLimiter _rateLimiter = RateLimiter(cooldown: const Duration(seconds: 2));

  List<TransactionModel> _transactions = [];
  bool   _isLoading  = false;
  String? _error;
  StreamSubscription<List<TransactionModel>>? _subscription;
  String? _currentUserId;
  final Set<String> _deletingIds = {};
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  Timer? _reconnectTimer;
  bool _disposed = false;

  /// Callback to notify listeners (e.g. BudgetProvider) when transactions update.
  void Function(List<TransactionModel>)? onTransactionsUpdated;

  List<TransactionModel> get transactions => _transactions;
  bool    get isLoading => _isLoading;
  String? get error     => _error;

  bool isDeleting(String id) => _deletingIds.contains(id);

  // ── Computed Summaries ─────────────────────────────────────────
  double get totalIncome  => _transactions
      .where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.isExpense).fold(0, (s, t) => s + t.amount);

  double get netBalance   => totalIncome - totalExpense;

  List<TransactionModel> get recentTransactions =>
      _transactions.take(5).toList();

  // ── Category Expense Map (for pie chart) ──────────────────────
  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => t.isExpense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  // ── Subscribe to real-time stream with auto-reconnect ─────────
  void subscribeToTransactions(String userId) {
    _currentUserId = userId;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.streamTransactions(userId).listen(
      (txns) {
        _transactions = txns;
        _isLoading    = false;
        _error        = null;
        _reconnectAttempts = 0;
        notifyListeners();
        onTransactionsUpdated?.call(txns);
      },
      onError: (e) {
        _isLoading = false;
        _error     = e.toString();
        notifyListeners();
        _scheduleReconnect();
      },
    );
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts || _disposed) return;
    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 5 * _reconnectAttempts), () {
      if (!_disposed && _currentUserId != null) {
        subscribeToTransactions(_currentUserId!);
      }
    });
  }

  // ── Add Transaction with retry ─────────────────────────────────
  Future<bool> addTransaction({
    required String userId,
    required String type,
    required String category,
    required double amount,
    required DateTime date,
    String description = '',
  }) async {
    // Rate limiting
    if (!_rateLimiter.canProceed) {
      _error = 'Please wait before adding another transaction.';
      notifyListeners();
      return false;
    }

    // Validate amount bounds
    if (!InputSanitizer.isValidAmount(amount)) {
      _error = 'Amount must be between 0.01 and 10,000,000';
      notifyListeners();
      return false;
    }

    // Sanitize text inputs
    final sanitizedDesc = InputSanitizer.sanitizeWithLimit(description, maxLength: 200);

    try {
      final t = TransactionModel(
        id:              _uuid.v4(),
        userId:          userId,
        transactionType: type,
        category:        category,
        amount:          amount,
        description:     sanitizedDesc,
        date:            date,
        createdAt:       DateTime.now(),
      );
      await RetryHelper.withRetry(action: () => _service.addTransaction(t));
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Update Transaction with retry ──────────────────────────────
  Future<bool> updateTransaction(TransactionModel t) async {
    // Validate amount bounds
    if (!InputSanitizer.isValidAmount(t.amount)) {
      _error = 'Amount must be between 0.01 and 10,000,000';
      notifyListeners();
      return false;
    }

    // Sanitize description
    final sanitized = t.copyWith(
      description: InputSanitizer.sanitizeWithLimit(t.description, maxLength: 200),
    );

    try {
      await RetryHelper.withRetry(action: () => _service.updateTransaction(sanitized));
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Delete Transaction with loading state and retry ────────────
  Future<bool> deleteTransaction(String id) async {
    if (_deletingIds.contains(id)) return false; // Prevent double-tap

    _deletingIds.add(id);
    notifyListeners();

    try {
      await RetryHelper.withRetry(action: () => _service.deleteTransaction(id));
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _deletingIds.remove(id);
      notifyListeners();
    }
  }

  // ── Monthly data for bar chart (last 6 months) ─────────────────
  Future<Map<String, Map<String, double>>> getLast6MonthsData(String userId) async {
    final txns = await _service.fetchLastMonths(userId, 6);
    final result = <String, Map<String, double>>{};

    for (final t in txns) {
      final key = '${AppConstants.months[t.date.month - 1]} ${t.date.year}';
      result[key] ??= {'income': 0, 'expense': 0};
      if (t.isIncome)  result[key]!['income']  = result[key]!['income']!  + t.amount;
      if (t.isExpense) result[key]!['expense'] = result[key]!['expense']! + t.amount;
    }
    return result;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
