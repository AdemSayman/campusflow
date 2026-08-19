import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';

/// Ev içi gider CRUD işlemlerini yürüten servis.
/// K2 kapsamı: houses/{houseId}/expenses.
class ExpenseService {
  ExpenseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _expensesRef(String houseId) {
    return _firestore.collection('houses').doc(houseId).collection('expenses');
  }

  /// Yeni bir gider ekler. [amountKurus] > 0 ve [splitBetween] boş olmamalı
  /// (bu kontrolleri UI form validasyonu yapıyor, burada tekrar etmiyoruz).
  Future<void> addExpense({
    required String houseId,
    required String description,
    required int amountKurus,
    required String paidBy,
    required List<String> splitBetween,
  }) async {
    final expense = Expense(
      id: '', // Firestore doc id'yi kendisi üretecek, burada önemsiz.
      description: description.trim(),
      amountKurus: amountKurus,
      paidBy: paidBy,
      splitBetween: splitBetween,
      settled: false,
    );
    await _expensesRef(houseId).add(expense.toCreateMap());
  }

  /// Bir evin tüm giderlerini canlı dinler (en yeni en üstte).
  Stream<List<Expense>> watchExpenses(String houseId) {
    return _expensesRef(houseId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Expense.fromFirestore).toList());
  }

  /// Bir giderin "kapatıldı" (settled) durumunu değiştirir.
  /// Rules: bunu ev üyelerinden herhangi biri yapabilir (sadece bu alan).
  Future<void> setSettled({
    required String houseId,
    required String expenseId,
    required bool settled,
  }) {
    return _expensesRef(houseId).doc(expenseId).update({'settled': settled});
  }

  /// Bir gideri siler. Rules: sadece gideri ekleyen (paidBy) silebilir.
  Future<void> deleteExpense({
    required String houseId,
    required String expenseId,
  }) {
    return _expensesRef(houseId).doc(expenseId).delete();
  }
}
