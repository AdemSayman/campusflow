import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

/// Giriş ekranı.
/// ConsumerStatefulWidget = hem State (loading/error) hem Riverpod ref.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  /// TextField'daki email yazısını tutar.
  final _emailController = TextEditingController();

  /// TextField'daki şifre yazısını tutar.
  final _passwordController = TextEditingController();

  /// true iken buton disabled + "Giriş yapılıyor..." gösterilir.
  bool _loading = false;

  /// null değilse kırmızı hata mesajı çizilir.
  String? _error;

  /// Controller bellek sızıntısı yapmasın diye sayfa kapanınca temizle.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Giriş butonuna basılınca çalışır.
  Future<void> _onLogin() async {
    // UI'ı yükleniyor durumuna al; eski hatayı temizle.
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Riverpod'dan AuthService'i al, Firebase'e giriş yap.
      await ref.read(authServiceProvider).signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
      // Başarılı olursa authStateChanges → router otomatik /home'a atar.
    } catch (e) {
      // Yanlış şifre / ağ hatası vb. → kullanıcıya anlaşılır mesaj.
      setState(() => _error = 'Giriş Başarısız. Email veya şifre hatalı.');
    } finally {
      // Widget hâlâ ekrandaysa loading'i kapat (async sonrası güvenlik).
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onGoogle() async {
    setState(() {
        _loading = true;
        _error = null;
    });
    try {
        await ref.read(authServiceProvider).signInWithGoogle();
    }catch (e) {
        setState(() => _error = 'Google girişi başarısız. Lütfen daha sonra tekrar deneyiniz.');
    } finally {
        if (mounted) setState(() => _loading = false);
    }
  }


  /// Ekranı çiz. setState olunca Flutter tekrar build çağırır.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CampusFlow')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email kutusu
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            // Şifre kutusu (obscureText: gizli göster)
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Şifre'),
            ),
            // Hata varsa göster (... = listeye birden fazla widget ekle)
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            // loading true iken onPressed: null → buton pasif
            FilledButton(
              onPressed: _loading ? null : _onLogin,
              child: Text(_loading ? 'Giriş Yapılıyor...' : 'Giriş Yap'),
            ),
            // Google ile giriş yap butonu
            const SizedBox(height: 12),
            OutlinedButton.icon(
                onPressed: _loading ? null : _onGoogle,
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Google ile Giriş Yap'),
            ),
            // Kayıt sayfasına git (yığın üstüne push)
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('Hesabınız Yok Mu? Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
