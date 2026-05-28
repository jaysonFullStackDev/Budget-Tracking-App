// lib/services/budget_service.dart
// Handles all Firestore CRUD operations for budgets.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';

class BudgetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('budgets');

  // ── Set / Upsert Budget ────────────────────────────────────────
  // Creates a new budget or updates the existing one for category+month+year.
  Future<void> setBudget(BudgetModel budget) async {
    final existing = await _col
        .where('userId',   isEqualTo: budget.userId)
        .where('category', isEqualTo: budget.category)
        .where('month',    isEqualTo: budget.month)
        .where('year',     isEqualTo: budget.year)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await _col.doc(existing.docs.first.id).update({
        'budgetLimit': budget.budgetLimit,
      });
    } else {
      await _col.add(budget.toMap());
    }
  }

  // ── Delete Budget ──────────────────────────────────────────────
  Future<void> deleteBudget(String id) async {
    await _col.doc(id).delete();
  }

  // ── Stream budgets for a specific month ───────────────────────
  Stream<List<BudgetModel>> streamMonthlyBudgets(
      String userId, int month, int year) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('month',  isEqualTo: month)
        .where('year',   isEqualTo: year)
        .snapshots()
        .map((snap) => snap.docs.map(BudgetModel.fromFirestore).toList());
  }
}
