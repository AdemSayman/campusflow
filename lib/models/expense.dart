import 'package:cloud_firestore/cloud_firestore.dart';

/// Bir gider kaydını temsil eder.
/// Firestore: houses/{houseId}/expenses/{expenseId}
///
/// [amountKurus] neden int ve neden "kuruş" cinsinden tutuluyor:
/// Ondalıklı sayılarla (double) para hesaplamak yuvarlama hatalarına açık
/// (örn. 0.1 + 0.2 == 0.30000000000000004 gibi). Bunun yerine en küçük para
/// birimini (kuruş) tam sayı olarak tutuyoruz: 45.50 TL = 4550 kuruş.
/// Ekranda gösterirken kuruş -> TL çevrimi UI katmanında yapılır.
class Expense {
  const Expense({
    required this.id,
    required this.description,
    required this.amountKurus,
    required this.paidBy,
    required this.splitBetween,
    required this.settled,
    this.createdAt,
  });

  /// Firestore doküman id'si.
  final String id;

  /// Ne için harcandı (örn. "Migros market alışverişi").
  final String description;

  /// Toplam tutar, kuruş cinsinden (bkz. sınıf açıklaması).
  final int amountKurus;

  /// Ödemeyi yapan kullanıcının uid'si.
  final String paidBy;

  /// Bu gideri kimlerin paylaştığı (eşit bölünecek uid listesi).
  /// paidBy genelde bu listenin içinde de yer alır (kendi payını da öder).
  final List<String> splitBetween;

  /// true ise bu gider "kapatıldı" sayılır ve net borç hesabına dahil edilmez.
  final bool settled;

  /// Oluşturulma zamanı (sunucu saati).
  final DateTime? createdAt;

  factory Expense.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Expense(
      id: doc.id,
      description: data['description'] as String? ?? '',
      amountKurus: (data['amountKurus'] as num?)?.toInt() ?? 0,
      paidBy: data['paidBy'] as String? ?? '',
      splitBetween: List<String>.from(data['splitBetween'] as List? ?? const []),
      settled: data['settled'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'description': description,
        'amountKurus': amountKurus,
        'paidBy': paidBy,
        'splitBetween': splitBetween,
        'settled': settled,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
