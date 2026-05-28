// lib/models/transaction_model.dart
// Represents a single financial transaction (income or expense).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final String userId;
  final String transactionType; // 'income' | 'expense'
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.category,
    required this.amount,
    this.description = '',
    required this.date,
    required this.createdAt,
  });

  bool get isIncome  => transactionType == 'income';
  bool get isExpense => transactionType == 'expense';

  // ── Firestore Deserialization ──────────────────────────────────
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id:              doc.id,
      userId:          data['userId']          ?? '',
      transactionType: data['transactionType'] ?? 'expense',
      category:        data['category']        ?? 'Others',
      amount:          (data['amount'] as num).toDouble(),
      description:     data['description']     ?? '',
      date:            (data['date'] as Timestamp).toDate(),
      createdAt:       (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // ── Firestore Serialization ────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'userId':          userId,
    'transactionType': transactionType,
    'category':        category,
    'amount':          amount,
    'description':     description,
    'date':            Timestamp.fromDate(date),
    'createdAt':       Timestamp.fromDate(createdAt),
  };

  // ── CopyWith ───────────────────────────────────────────────────
  TransactionModel copyWith({
    String? id, String? userId, String? transactionType,
    String? category, double? amount, String? description,
    DateTime? date, DateTime? createdAt,
  }) {
    return TransactionModel(
      id:              id              ?? this.id,
      userId:          userId          ?? this.userId,
      transactionType: transactionType ?? this.transactionType,
      category:        category        ?? this.category,
      amount:          amount          ?? this.amount,
      description:     description     ?? this.description,
      date:            date            ?? this.date,
      createdAt:       createdAt       ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, transactionType, category, amount, date];
}
