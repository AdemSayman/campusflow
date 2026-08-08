import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

/// AuthService'e uygulama genelinden erişim noktası.
/// Örnek: ref.read(authServiceProvider).signIn(...)
/// Provider = "bu değeri bir kez üret, isteyen herkese ver".
final authServiceProvider = Provider<AuthService>((ref) {
  // Şimdilik tek AuthService; ileride fake/mock da enjekte edilebilir.
  return AuthService();
});

/// Auth oturum akışını Riverpod'a bağlar.
/// `AsyncValue` içinde `User?` üretir: loading / data(user|null) / error.
/// null User = giriş yok; dolu User = giriş var.
/// Router redirect ve UI bunu dinler.
final authStateProvider = StreamProvider<User?>((ref) {
  // Servisten Firebase authStateChanges stream'ini al.
  // read: Provider sabit olduğu için bir kerelik almak yeterli.
  return ref.read(authServiceProvider).authStateChanges();
});
