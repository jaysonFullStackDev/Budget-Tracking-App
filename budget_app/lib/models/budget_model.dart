// lib/models/budget_model.dart
// Represents a monthly budget limit for a specific category.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BudgetModel extends Equatable {
  final String id;
  final String userId;
  final String category;
  final double budgetLimit;
  final double amountSpent; // Calculated, not stored in Firestore
  final int month;          // 1-12
  final int year;
  final DateTime createdAt;

  const BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.budgetLimit,
    this.amountSpent = 0.0,
    required this.month,
    required this.year,
    required this.createdAt,
  });

  // ── Computed Properties ────────────────────────────────────────
  double get remaining      => budgetLimit - amountSpent;
  double get usagePercent   => budgetLimit > 0 ? (amountSpent / budgetLimit).clamp(0.0, 1.0) : 0.0;
  bool   get isExceeded     => amountSpent > budgetLimit;
  bool   get isNearLimit    => usagePercent >= 0.8 && !isExceeded;

  // ── Firestore Deserialization ──────────────────────────────────
  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id:          doc.id,
      userId:      data['userId']      ?? '',
      category:    data['category']    ?? 'Others',
      budgetLimit: (data['budgetLimit'] as num).toDouble(),
      month:       data['month']       ?? DateTime.now().month,
      year:        data['year']        ?? DateTime.now().year,
      createdAt:   (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // ── Firestore Serialization ────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'userId':      userId,
    'category':    category,
    'budgetLimit': budgetLimit,
    'month':       month,
    'year':        year,
    'createdAt':   Timestamp.fromDate(createdAt),
  };

  // ── CopyWith ───────────────────────────────────────────────────
  BudgetModel copyWith({
    String? id, String? userId, String? category,
    double? budgetLimit, double? amountSpent,
    int? month, int? year, DateTime? createdAt,
  }) {
    return BudgetModel(
      id:          id          ?? this.id,
      userId:      userId      ?? this.userId,
      category:    category    ?? this.category,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      amountSpent: amountSpent ?? this.amountSpent,
      month:       month       ?? this.month,
      year:        year        ?? this.year,
      createdAt:   createdAt   ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, category, budgetLimit, month, year];
}
