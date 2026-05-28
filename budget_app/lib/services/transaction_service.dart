// lib/services/transaction_service.dart
// Handles all Firestore CRUD operations for transactions.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('transactions');

  // ── Add Transaction ────────────────────────────────────────────
  Future<void> addTransaction(TransactionModel t) async {
    await _col.add(t.toMap());
  }

  // ── Update Transaction ─────────────────────────────────────────
  Future<void> updateTransaction(TransactionModel t) async {
    await _col.doc(t.id).update(t.toMap());
  }

  // ── Delete Transaction ─────────────────────────────────────────
  Future<void> deleteTransaction(String id) async {
    await _col.doc(id).delete();
  }

  // ── Real-time stream for a user's transactions ─────────────────
  Stream<List<TransactionModel>> streamTransactions(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TransactionModel.fromFirestore).toList());
  }

  // ── Get transactions for a specific month ──────────────────────
  Stream<List<TransactionModel>> streamMonthlyTransactions(
      String userId, int month, int year) {
    final start = DateTime(year, month, 1);
    final end   = DateTime(year, month + 1, 0, 23, 59, 59);
    return _col
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo:    Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TransactionModel.fromFirestore).toList());
  }

  // ── Fetch for reports (no stream needed) ──────────────────────
  Future<List<TransactionModel>> fetchMonthlyTransactions(
      String userId, int month, int year) async {
    final start = DateTime(year, month, 1);
    final end   = DateTime(year, month + 1, 0, 23, 59, 59);
    final snap  = await _col
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo:    Timestamp.fromDate(end))
        .get();
    return snap.docs.map(TransactionModel.fromFirestore).toList();
  }

  // ── Fetch last N months for reports ────────────────────────────
  Future<List<TransactionModel>> fetchLastMonths(
      String userId, int months) async {
    final from = DateTime.now().subtract(Duration(days: 30 * months));
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map(TransactionModel.fromFirestore).toList();
  }
}
