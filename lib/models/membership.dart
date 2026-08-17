import 'package:cloud_firestore/cloud_firestore.dart';

/// Bir kullanıcının bir evdeki üyelik kaydı.
/// Firestore: houses/{houseId}/memberships/{uid}
class Membership {
  const Membership({
    required this.uid,
    required this.role,
    this.joinedAt,
  });

  /// Üye kullanıcının uid'si (doküman id'si ile aynı).
  final String uid;

  /// "owner" (evi kuran) ya da "member" (sonradan katılan).
  final String role;

  /// Katılma zamanı (sunucu saati); henüz sunucudan dönmemişse null olabilir.
  final DateTime? joinedAt;

  bool get isOwner => role == 'owner';

  /// Firestore'dan gelen belgeyi Membership nesnesine çevirir.
  factory Membership.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return Membership(
      uid: data['uid'] as String? ?? doc.id,
      role: data['role'] as String? ?? 'member',
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Yeni bir üyelik kaydı yazarken Firestore'a gidecek alanlar.
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'role': role,
        'joinedAt': FieldValue.serverTimestamp(),
      };
}
