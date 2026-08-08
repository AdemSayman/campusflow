import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Kimlik (Auth) + profil (Firestore) işlerini tek yerde toplayan servis.
/// Ekranlar Firebase detayını bilmez; bu sınıfa sorar.
class AuthService {
  /// [auth] / [firestore] verilmezse gerçek Firebase instance kullanılır.
  /// Test ederken sahte (fake) bağımlılık enjekte edilebilir.
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Firebase Authentication istemcisi (giriş / kayıt / çıkış).
  final FirebaseAuth _auth;

  /// Cloud Firestore istemcisi (users koleksiyonu = profil belgesi).
  final FirebaseFirestore _firestore;

  /// Oturum aç/kapa oldukça akan yayın.
  /// null = çıkış yapılmış; User = giriş var. Router bunu dinleyecek.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Şu anki kullanıcıyı bir kerelik oku (stream değil).
  User? get currentUser => _auth.currentUser;

  /// 1) Auth'ta hesap açar  2) Firestore'a users/{uid} profil belgesi yazar.
  /// Şifre Firestore'a yazılmaz; sadece Auth tutar.
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    String? university,
  }) async {
    // Email/şifre ile Firebase Auth kullanıcısı oluştur.
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(), // trim: baş/son boşlukları temizle
      password: password,
    );

    final user = credential.user;
    // Teoride nadir; yine de null ise erken hata fırlat.
    if (user == null) {
      throw StateError('Kayıt sonrası user null geldi');
    }

    // SQL'deki INSERT INTO users ... benzeri.
    // Document id = Auth uid → profil ile kimlik aynı anahtarda birleşir.
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email.trim(),
      'name': name.trim(),
      'university': university?.trim() ?? '',
      'bio': '',
      'photoUrl': null,
      'currentHouseId': null, // Ev yokken boş; Kirwe Ev sonrası dolacak
      'createdAt': FieldValue.serverTimestamp(), // Sunucu saati
    });

    return credential;
  }

  /// Email/şifre ile giriş. Profil belgesi zaten kayıtta oluştuğu için
  /// burada tekrar Firestore yazılmaz.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }
  /// Google ile giriş.
  /// Web: popup, mobil: provider akışı.
  /// ilk google girişinde firestore profili yoksa oluşturur.
  Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider();

    final UserCredential credential;
    if (kIsWeb) {
        credential = await _auth.signInWithPopup(provider);
    } else {
        credential = await _auth.signInWithProvider(provider);
    }
    final user = credential.user;
    if (user == null) {
        throw StateError('Google girişi sonrası user null geldi');
    }
    
    await _ensureUserProfile(user);
    return credential;
  }

  ///Profil belgesi yoksa oluşturur.
  Future<void> _ensureUserProfile(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snap = await docRef.get();
    if (snap.exists) return;

    await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'university': '',
        'bio': '',
        'photoUrl': user.photoURL,
        'currentHouseId': null,
        'createdAt': FieldValue.serverTimestamp(),
    });
  }


  /// Oturumu kapatır → authStateChanges null yayınlar.
  Future<void> signOut() => _auth.signOut();
}
