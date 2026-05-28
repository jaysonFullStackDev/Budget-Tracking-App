// lib/providers/budget_provider.dart
// Manages budget state and calculates spending against limits.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../services/budget_service.dart';
import '../utils/retry_helper.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _service = BudgetService();
  static const _uuid = Uuid();

  List<BudgetModel> _budgets = [];
  bool   _isLoading = false;
  String? _error;
  StreamSubscription<List<BudgetModel>>? _subscription;
  String? _currentUserId;
  int? _currentMonth;
  int? _currentYear;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  Timer? _reconnectTimer;
  bool _disposed = false;

  // Track last spending state to avoid unnecessary rebuilds
  Map<String, double> _lastSpendingMap = {};

  List<BudgetModel> get budgets   => _budgets;
  bool    get isLoading           => _isLoading;
  String? get error               => _error;
  List<BudgetModel> get exceededBudgets =>
      _budgets.where((b) => b.isExceeded).toList();

  // ── Subscribe to real-time stream with auto-reconnect ─────────
  void subscribeToMonthlyBudgets(String userId, int month, int year) {
    _currentUserId = userId;
    _currentMonth = month;
    _currentYear = year;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.streamMonthlyBudgets(userId, month, year).listen(
      (budgets) {
        _budgets   = budgets;
        _isLoading = false;
        _error     = null;
        _reconnectAttempts = 0;
        // Re-apply last known spending
        if (_lastSpendingMap.isNotEmpty) {
          _budgets = _budgets.map((b) =>
              b.copyWith(amountSpent: _lastSpendingMap[b.category] ?? 0)).toList();
        }
        notifyListeners();
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
      if (!_disposed && _currentUserId != null && _currentMonth != null && _currentYear != null) {
        subscribeToMonthlyBudgets(_currentUserId!, _currentMonth!, _currentYear!);
      }
    });
  }

  // ── Recalculate spending from transactions (debounced) ────────
  void updateSpending(List<TransactionModel> transactions, int month, int year) {
    final spendingMap = <String, double>{};
    for (final t in transactions) {
      if (t.isExpense && t.date.month == month && t.date.year == year) {
        spendingMap[t.category] = (spendingMap[t.category] ?? 0) + t.amount;
      }
    }

    // Only notify if spending actually changed
    if (_spendingChanged(spendingMap)) {
      _lastSpendingMap = spendingMap;
      _budgets = _budgets.map((b) =>
          b.copyWith(amountSpent: spendingMap[b.category] ?? 0)).toList();
      notifyListeners();
    }
  }

  bool _spendingChanged(Map<String, double> newMap) {
    if (newMap.length != _lastSpendingMap.length) return true;
    for (final entry in newMap.entries) {
      if (_lastSpendingMap[entry.key] != entry.value) return true;
    }
    return false;
  }

  // ── Set Budget with retry ──────────────────────────────────────
  Future<bool> setBudget({
    required String userId,
    required String category,
    required double limit,
    required int month,
    required int year,
  }) async {
    try {
      final budget = BudgetModel(
        id:          _uuid.v4(),
        userId:      userId,
        category:    category,
        budgetLimit: limit,
        month:       month,
        year:        year,
        createdAt:   DateTime.now(),
      );
      await RetryHelper.withRetry(action: () => _service.setBudget(budget));
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Delete Budget with retry ───────────────────────────────────
  Future<bool> deleteBudget(String id) async {
    try {
      await RetryHelper.withRetry(action: () => _service.deleteBudget(id));
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  BudgetModel? getBudgetForCategory(String category) {
    try {
      return _budgets.firstWhere((b) => b.category == category);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
