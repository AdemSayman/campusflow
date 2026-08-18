import '../models/expense.dart';

/// Gider bölüşüm ve net borç hesaplarını yapan SAF (pure) fonksiyonlar.
/// Bilerek Firebase'den bağımsız, tek başına test edilebilir bir dosya —
/// K2 belgesindeki "Expense model + ayrı calculator dosyası" isteği bu.
///
/// ============================================================
/// KURUŞ KURALI (belgede özellikle istenen, burada yazılı hali):
/// ============================================================
/// Bir gideri N kişiye eşit bölerken:
///   pay = amountKurus ~/ N   (tam sayı bölme, kalan atılır)
///   kalan = amountKurus % N  (0 <= kalan < N)
/// "kalan" kuruş, bölüşülemeyen artık kuruşlardır (örn. 100 kuruşu 3 kişiye
/// bölersen 33'er kuruş düşer, 1 kuruş artar). Bu artan kuruşlar, uid'lere
/// göre ALFABETİK SIRALANMIŞ listenin BAŞINDAKİ "kalan" kişiye 1'er kuruş
/// fazladan verilir. Sıralama şart: aynı girdiyle her zaman aynı sonucu
/// üretmeli (deterministik), yoksa kim 1 kuruş fazla öder her seferinde
/// değişir ve testte/production'da tutarsızlık çıkar.
/// Örnek: 100 kuruş, 3 kişi (A, B, C) -> pay=33, kalan=1 -> A 34, B 33, C 33.
class ExpenseCalculator {
  const ExpenseCalculator._();

  /// Bir gideri [splitBetween] listesindeki kişilere eşit böler.
  /// Dönen map: uid -> o kişinin payı (kuruş).
  static Map<String, int> splitEqually({
    required int amountKurus,
    required List<String> splitBetween,
  }) {
    if (splitBetween.isEmpty) return const {};

    // Deterministik olması için her zaman sırala (bkz. yukarıdaki kural notu).
    final sorted = [...splitBetween]..sort();

    final n = sorted.length;
    final basePay = amountKurus ~/ n;
    final remainder = amountKurus % n;

    return {
      for (var i = 0; i < n; i++)
        sorted[i]: basePay + (i < remainder ? 1 : 0),
    };
  }

  /// Bir ev için tüm giderlere bakarak her üyenin NET bakiyesini hesaplar.
  /// Dönen map: uid -> net bakiye (kuruş).
  ///   pozitif = evdeki diğerlerinden alacaklı (ona borçlular)
  ///   negatif = evdeki diğerlerine borçlu
  ///   0       = ödeşmiş
  ///
  /// [settled] = true olan giderler hesaba katılmaz (kapatılmış sayılır).
  static Map<String, int> calculateNetBalances(List<Expense> expenses) {
    final balances = <String, int>{};

    void add(String uid, int deltaKurus) {
      balances[uid] = (balances[uid] ?? 0) + deltaKurus;
    }

    for (final expense in expenses) {
      if (expense.settled) continue;
      if (expense.splitBetween.isEmpty) continue;

      final shares = splitEqually(
        amountKurus: expense.amountKurus,
        splitBetween: expense.splitBetween,
      );

      // Ödeyen kişi: tüm tutarı öne yatırdı -> alacağı artar.
      add(expense.paidBy, expense.amountKurus);

      // Her paylaşan kişi kendi payı kadar borçlanır (ödeyen dahil —
      // ödeyen zaten yukarıda tam tutarı aldığı için, kendi payını da
      // burada düşünce net olarak sadece "başkalarına ödediği kısım"
      // kadar alacaklı kalır).
      shares.forEach((uid, share) => add(uid, -share));
    }

    return balances;
  }

  /// [balances] içinden tek bir kullanıcının net bakiyesini okur (yoksa 0).
  static int netBalanceFor(Map<String, int> balances, String uid) {
    return balances[uid] ?? 0;
  }
}
