// lib/utils/constants.dart
// App-wide constants, enums, and helper functions.

import 'package:flutter/material.dart';

class AppConstants {
  // ── App Info ───────────────────────────────────────────────────
  static const String appName    = 'BudgetTrack';
  static const String appVersion = '1.0.0';

  // ── Transaction Types ──────────────────────────────────────────
  static const String income  = 'income';
  static const String expense = 'expense';

  // ── Transaction Categories ─────────────────────────────────────
  static const List<String> expenseCategories = [
    'Food', 'Transportation', 'Bills', 'Shopping', 'Others',
  ];
  static const List<String> incomeCategories = [
    'Salary', 'Freelance', 'Business', 'Investment', 'Others',
  ];
  static List<String> get allCategories => [
    ...expenseCategories, ...incomeCategories,
  ];

  // ── Category Icons ─────────────────────────────────────────────
  static const Map<String, IconData> categoryIcons = {
    'Food':           Icons.restaurant_rounded,
    'Transportation': Icons.directions_car_rounded,
    'Bills':          Icons.receipt_long_rounded,
    'Shopping':       Icons.shopping_bag_rounded,
    'Salary':         Icons.account_balance_wallet_rounded,
    'Freelance':      Icons.work_rounded,
    'Business':       Icons.business_center_rounded,
    'Investment':     Icons.trending_up_rounded,
    'Others':         Icons.category_rounded,
  };

  static IconData getCategoryIcon(String category) =>
      categoryIcons[category] ?? Icons.category_rounded;

  // ── Months ─────────────────────────────────────────────────────
  static const List<String> months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];

  // ── SharedPreferences Keys ────────────────────────────────────
  static const String themeKey    = 'theme_mode';
  static const String currencyKey = 'currency';
}

// ── Currency Formatter ─────────────────────────────────────────
class CurrencyFormatter {
  static String format(double amount, {String symbol = '₱'}) {
    final isNegative = amount < 0;
    final abs = amount.abs();
    final formatted = abs.toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '${isNegative ? '-' : ''}$symbol$formatted';
  }
}

// ── Date Helpers ───────────────────────────────────────────────
class DateHelpers {
  static String formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String formatMonth(DateTime date) {
    const months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
