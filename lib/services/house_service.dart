import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/house.dart';
import '../models/membership.dart';

/// Ev oluşturma / davet koduyla katılma / ayrılma işlerini yürüten servis.
/// K1 kapsamı: houses + houses/memberships + houseCodes + users.currentHouseId.
///
/// houseCodes/{code} → { houseId } eşlemesi ayrı bir koleksiyonda tutuluyor.
/// Neden: "davet koduyla katıl" akışı, kullanıcı henüz üyesi olmadığı bir evi
/// bulabilmeli. houses/{houseId} dokümanı sadece üyelere açık (rules), o yüzden
/// "bu koda sahip ev hangisi" sorusunu houses koleksiyonunda arattırmak yerine
/// herkese (giriş yapmış) açık, içinde hassas veri olmayan bu küçük eşleme
/// koleksiyonundan çözüyoruz.
class HouseService {
  HouseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Karışıklık yaratan karakterleri (0/O, 1/I) dışarıda bırakan alfabe.
  static const _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _generateCode(Random random) {
    return List.generate(
      6,
      (_) => _codeAlphabet[random.nextInt(_codeAlphabet.length)],
    ).join();
  }

  /// Kullanılmayan (henüz houseCodes'ta olmayan) 6 haneli kod üretir.
  /// En fazla 5 deneme yapar; çakışma ihtimali çok düşük olduğu için
  /// MVP'de bu kadarı yeterli.
  Future<String> _generateUniqueCode() async {
    final random = Random();
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _generateCode(random);
      final existing =
          await _firestore.collection('houseCodes').doc(code).get();
      if (!existing.exists) return code;
    }
    throw StateError('Davet kodu üretilemedi, tekrar dene.');
  }

  /// Kullanıcının şu an başka bir evde olup olmadığını kontrol eder.
  /// MVP kuralı: aynı anda sadece bir evde olabilirsin.
  Future<void> _assertNoCurrentHouse(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final currentHouseId = userDoc.data()?['currentHouseId'] as String?;
    if (currentHouseId != null && currentHouseId.isNotEmpty) {
      throw StateError(
        'Zaten bir evdesin. Önce mevcut evden ayrılman gerekiyor.',
      );
    }
  }

  /// Yeni ev oluşturur: house dokümanı + owner membership + houseCodes
  /// eşlemesi + users.currentHouseId, hepsi tek bir batch'te.
  Future<House> createHouse({
    required String uid,
    required String name,
  }) async {
    await _assertNoCurrentHouse(uid);

    final code = await _generateUniqueCode();
    final houseRef = _firestore.collection('houses').doc();

    final house = House(
      id: houseRef.id,
      name: name.trim(),
      inviteCode: code,
      createdBy: uid,
      memberIds: [uid],
    );

    final batch = _firestore.batch();
    batch.set(houseRef, house.toCreateMap());
    batch.set(
      houseRef.collection('memberships').doc(uid),
      Membership(uid: uid, role: 'owner').toMap(),
    );
    batch.set(
      _firestore.collection('houseCodes').doc(code),
      {'houseId': houseRef.id},
    );
    batch.update(_firestore.collection('users').doc(uid), {
      'currentHouseId': houseRef.id,
    });
    await batch.commit();

    return house;
  }

  /// Davet koduyla mevcut bir eve katılır.
  /// Önce houseCodes'tan houseId'yi bulur (bunun için üye olman gerekmez),
  /// sonra memberships + houses.memberIds + users.currentHouseId'i günceller.
  Future<void> joinWithCode({
    required String uid,
    required String code,
  }) async {
    await _assertNoCurrentHouse(uid);

    final normalizedCode = code.trim().toUpperCase();
    final codeDoc =
        await _firestore.collection('houseCodes').doc(normalizedCode).get();

    if (!codeDoc.exists) {
      throw StateError('Bu davet kodu geçersiz. Kodu kontrol et.');
    }

    final houseId = codeDoc.data()!['houseId'] as String;
    final houseRef = _firestore.collection('houses').doc(houseId);

    final batch = _firestore.batch();
    batch.set(
      houseRef.collection('memberships').doc(uid),
      Membership(uid: uid, role: 'member').toMap(),
    );
    batch.update(houseRef, {
      'memberIds': FieldValue.arrayUnion([uid]),
    });
    batch.update(_firestore.collection('users').doc(uid), {
      'currentHouseId': houseId,
    });
    await batch.commit();
  }

  /// Evden ayrılır: membership silinir, memberIds'ten çıkarılır,
  /// users.currentHouseId null'a döner.
  ///
  /// NOT (v0 sınırlama): owner ayrılırsa ev "sahipsiz" kalır; ownership
  /// devri K1 kapsamı dışında — Adem + Kirwe ile K2 öncesi konuşulup
  /// netleştirilecek (TODO).
  Future<void> leaveHouse({
    required String uid,
    required String houseId,
  }) async {
    final houseRef = _firestore.collection('houses').doc(houseId);

    final batch = _firestore.batch();
    batch.delete(houseRef.collection('memberships').doc(uid));
    batch.update(houseRef, {
      'memberIds': FieldValue.arrayRemove([uid]),
    });
    batch.update(_firestore.collection('users').doc(uid), {
      'currentHouseId': null,
    });
    await batch.commit();
  }

  /// Tek bir evi canlı dinler (isim/kod değişirse UI güncellensin diye).
  Stream<House?> watchHouse(String houseId) {
    return _firestore
        .collection('houses')
        .doc(houseId)
        .snapshots()
        .map((doc) => doc.exists ? House.fromFirestore(doc) : null);
  }

  /// Bir evin üyelerini canlı dinler.
  Stream<List<Membership>> watchMembers(String houseId) {
    return _firestore
        .collection('houses')
        .doc(houseId)
        .collection('memberships')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Membership.fromFirestore(d)).toList(),
        );
  }
}
