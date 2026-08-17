import 'package:cloud_firestore/cloud_firestore.dart';

/// Bir "ev" (paylaşımlı yaşam alanı) belgesini temsil eder.
/// Firestore: houses/{houseId}
class House {
  const House({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    required this.memberIds,
    this.createdAt,
  });

  /// Firestore doküman id'si (houseId).
  final String id;

  /// Ev adı (kullanıcı belirler, örn. "Bahçelievler 3B").
  final String name;

  /// 6 haneli davet kodu; başkaları bu kodla eve katılır.
  final String inviteCode;

  /// Evi oluşturan kullanıcının uid'si.
  final String createdBy;

  /// Şu an evde olan tüm üyelerin uid listesi (denormalize, hızlı okuma için).
  final List<String> memberIds;

  /// Oluşturulma zamanı (sunucu saati); henüz sunucudan dönmemişse null olabilir.
  final DateTime? createdAt;

  /// Firestore'dan gelen belgeyi House nesnesine çevirir.
  factory House.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return House(
      id: doc.id,
      name: data['name'] as String? ?? '',
      inviteCode: data['inviteCode'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      memberIds: List<String>.from(data['memberIds'] as List? ?? const []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Yeni bir ev oluştururken Firestore'a yazılacak alanlar.
  /// Doküman id'sini Firestore kendisi üretir, bu yüzden burada yok.
  Map<String, dynamic> toCreateMap() => {
        'name': name,
        'inviteCode': inviteCode,
        'createdBy': createdBy,
        'memberIds': memberIds,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
