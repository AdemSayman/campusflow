import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/house.dart';
import '../models/membership.dart';
import '../services/house_service.dart';
import 'auth_provider.dart';

/// HouseService'e uygulama genelinden erişim noktası.
/// Örnek: ref.read(houseServiceProvider).createHouse(...)
final houseServiceProvider = Provider<HouseService>((ref) {
  return HouseService();
});

/// Giriş yapmış kullanıcının users/{uid} dokümanını canlı dinler.
/// currentHouseId gibi profil alanlarını buradan okuyoruz.
/// Kullanıcı çıkış yaparsa (authStateProvider null) null yayınlar.
final currentUserDocProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data());
});

/// Kullanıcının şu an bağlı olduğu ev id'si (yoksa null).
/// Provider (StreamProvider değil): sadece currentUserDocProvider'dan
/// türetilen basit bir okuma, kendi başına bir veri kaynağı değil.
final currentHouseIdProvider = Provider<String?>((ref) {
  final userDoc = ref.watch(currentUserDocProvider).asData?.value;
  return userDoc?['currentHouseId'] as String?;
});

/// currentHouseIdProvider doluysa o evi canlı dinler; boşsa null yayınlar.
final currentHouseProvider = StreamProvider<House?>((ref) {
  final houseId = ref.watch(currentHouseIdProvider);
  if (houseId == null) return Stream.value(null);

  return ref.watch(houseServiceProvider).watchHouse(houseId);
});

/// currentHouseIdProvider doluysa o evin üyelerini canlı dinler; boşsa boş liste.
final currentHouseMembersProvider = StreamProvider<List<Membership>>((ref) {
  final houseId = ref.watch(currentHouseIdProvider);
  if (houseId == null) return Stream.value(const []);

  return ref.watch(houseServiceProvider).watchMembers(houseId);
});
