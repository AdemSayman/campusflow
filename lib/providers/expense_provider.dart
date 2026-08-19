import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';
import '../services/expense_calculator.dart';
import '../services/expense_service.dart';
import 'auth_provider.dart';
import 'house_provider.dart';

/// ExpenseService'e uygulama genelinden erişim noktası.
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

/// Şu anki evin tüm giderlerini canlı dinler; ev yoksa boş liste.
final houseExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final houseId = ref.watch(currentHouseIdProvider);
  if (houseId == null) return Stream.value(const []);

  return ref.watch(expenseServiceProvider).watchExpenses(houseId);
});

/// houseExpensesProvider'dan türeyen net bakiye map'i (uid -> kuruş).
/// Veri henüz yüklenmediyse boş map döner (ekranlar loading state'i zaten
/// houseExpensesProvider üzerinden ayrıca kontrol ediyor).
final netBalancesProvider = Provider<Map<String, int>>((ref) {
  final expenses = ref.watch(houseExpensesProvider).asData?.value ?? const [];
  return ExpenseCalculator.calculateNetBalances(expenses);
});

/// Giriş yapmış kullanıcının bu evdeki net bakiyesi (kuruş).
/// Pozitif = alacaklı, negatif = borçlu.
final myNetBalanceProvider = Provider<int>((ref) {
  final uid = ref.watch(authStateProvider).asData?.value?.uid;
  if (uid == null) return 0;
  return ExpenseCalculator.netBalanceFor(ref.watch(netBalancesProvider), uid);
});
