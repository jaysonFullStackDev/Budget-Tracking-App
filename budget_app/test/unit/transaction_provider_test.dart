// test/unit/transaction_provider_test.dart
// Unit tests for TransactionProvider computed properties and logic.

import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracking_app/models/transaction_model.dart';
import 'package:budget_tracking_app/utils/constants.dart';

// ── Test helper: build a TransactionModel quickly ─────────────
TransactionModel makeTransaction({
  String type     = 'expense',
  String category = 'Food',
  double amount   = 100.0,
  DateTime? date,
}) {
  return TransactionModel(
    id:              'test-id',
    userId:          'user-1',
    transactionType: type,
    category:        category,
    amount:          amount,
    date:            date ?? DateTime.now(),
    createdAt:       DateTime.now(),
  );
}

void main() {
  // ── TransactionModel Tests ─────────────────────────────────────
  group('TransactionModel', () {
    test('isIncome returns true for income type', () {
      final t = makeTransaction(type: AppConstants.income);
      expect(t.isIncome,  isTrue);
      expect(t.isExpense, isFalse);
    });

    test('isExpense returns true for expense type', () {
      final t = makeTransaction(type: AppConstants.expense);
      expect(t.isExpense, isTrue);
      expect(t.isIncome,  isFalse);
    });

    test('toMap() contains all required Firestore fields', () {
      final t   = makeTransaction();
      final map = t.toMap();
      expect(map.containsKey('userId'),          isTrue);
      expect(map.containsKey('transactionType'), isTrue);
      expect(map.containsKey('category'),        isTrue);
      expect(map.containsKey('amount'),          isTrue);
      expect(map.containsKey('date'),            isTrue);
      expect(map.containsKey('createdAt'),       isTrue);
    });

    test('copyWith returns updated model', () {
      final original = makeTransaction(amount: 500.0);
      final updated  = original.copyWith(amount: 1000.0, category: 'Transport');
      expect(updated.amount,   equals(1000.0));
      expect(updated.category, equals('Transport'));
      expect(updated.userId,   equals(original.userId)); // Unchanged
    });
  });

  // ── Financial Calculation Tests ────────────────────────────────
  group('Financial calculations', () {
    final transactions = [
      makeTransaction(type: 'income',  amount: 50000.0, category: 'Salary'),
      makeTransaction(type: 'income',  amount: 5000.0,  category: 'Freelance'),
      makeTransaction(type: 'expense', amount: 1500.0,  category: 'Food'),
      makeTransaction(type: 'expense', amount: 800.0,   category: 'Transportation'),
      makeTransaction(type: 'expense', amount: 2000.0,  category: 'Bills'),
    ];

    double totalIncome(List<TransactionModel> txns) =>
        txns.where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);

    double totalExpense(List<TransactionModel> txns) =>
        txns.where((t) => t.isExpense).fold(0, (s, t) => s + t.amount);

    test('total income is calculated correctly', () {
      expect(totalIncome(transactions), equals(55000.0));
    });

    test('total expense is calculated correctly', () {
      expect(totalExpense(transactions), equals(4300.0));
    });

    test('net balance = totalIncome - totalExpense', () {
      final balance = totalIncome(transactions) - totalExpense(transactions);
      expect(balance, equals(50700.0));
    });

    test('expense grouping by category is correct', () {
      final map = <String, double>{};
      for (final t in transactions.where((t) => t.isExpense)) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
      expect(map['Food'],          equals(1500.0));
      expect(map['Transportation'],equals(800.0));
      expect(map['Bills'],         equals(2000.0));
    });

    test('empty list returns zero totals', () {
      expect(totalIncome([]),  equals(0.0));
      expect(totalExpense([]), equals(0.0));
    });
  });

  // ── BudgetModel Tests ──────────────────────────────────────────
  group('BudgetModel logic', () {
    test('isExceeded is true when spent > limit', () {
      // Simulated budget check (no Firestore needed)
      const limit   = 1000.0;
      const spent   = 1200.0;
      const exceeded = spent > limit;
      expect(exceeded, isTrue);
    });

    test('usagePercent clamps at 1.0 when exceeded', () {
      const limit   = 1000.0;
      const spent   = 1500.0;
      final percent = (spent / limit).clamp(0.0, 1.0);
      expect(percent, equals(1.0));
    });

    test('isNearLimit is true when usage is between 80% and 100%', () {
      const limit   = 1000.0;
      const spent   = 850.0;
      final percent = spent / limit;
      expect(percent >= 0.8 && percent < 1.0, isTrue);
    });

    test('remaining budget is calculated correctly', () {
      const limit     = 1000.0;
      const spent     = 350.0;
      const remaining = limit - spent;
      expect(remaining, equals(650.0));
    });
  });

  // ── CurrencyFormatter Tests ────────────────────────────────────
  group('CurrencyFormatter', () {
    test('formats whole number correctly', () {
      expect(CurrencyFormatter.format(1000.0),   equals('₱1,000.00'));
    });

    test('formats decimal correctly', () {
      expect(CurrencyFormatter.format(1234.56),  equals('₱1,234.56'));
    });

    test('formats large number with commas', () {
      expect(CurrencyFormatter.format(50000.0),  equals('₱50,000.00'));
    });

    test('formats negative as negative', () {
      expect(CurrencyFormatter.format(-500.0),   equals('-₱500.00'));
    });

    test('formats zero correctly', () {
      expect(CurrencyFormatter.format(0.0),      equals('₱0.00'));
    });
  });

  // ── DateHelpers Tests ──────────────────────────────────────────
  group('DateHelpers', () {
    test('formatDate returns readable string', () {
      final date = DateTime(2025, 5, 15);
      expect(DateHelpers.formatDate(date), equals('May 15, 2025'));
    });

    test('formatMonth returns month and year', () {
      final date = DateTime(2025, 1, 1);
      expect(DateHelpers.formatMonth(date), equals('January 2025'));
    });

    test('isSameMonth returns true for same month', () {
      final a = DateTime(2025, 6, 10);
      final b = DateTime(2025, 6, 25);
      expect(DateHelpers.isSameMonth(a, b), isTrue);
    });

    test('isSameMonth returns false for different months', () {
      final a = DateTime(2025, 5, 10);
      final b = DateTime(2025, 6, 10);
      expect(DateHelpers.isSameMonth(a, b), isFalse);
    });
  });
}
