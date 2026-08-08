import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

/// Kayıt (yeni hesap) ekranı.
/// Login gibi ConsumerStatefulWidget: form state + Riverpod ref.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  /// Ad alanı metni.
  final _nameController = TextEditingController();

  /// Email alanı metni.
  final _emailController = TextEditingController();

  /// Şifre alanı metni (Firebase min 6 karakter ister).
  final _passwordController = TextEditingController();

  /// true → buton pasif, "Kayıt Yapılıyor..." yazısı.
  bool _loading = false;

  /// null değilse kırmızı hata satırı gösterilir.
  String? _error;

  /// Sayfa kapanınca controller'ları serbest bırak (bellek sızıntısı önlemi).
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// "Kayıt Ol" butonuna basılınca.
  Future<void> _onRegister() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Auth'ta user aç + Firestore users/{uid} profil yaz.
      await ref.read(authServiceProvider).signUp(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
          );
      // Başarılı olunca authState değişir → router otomatik /home'a atar.
      // Burada context.go yazmana gerek yok.
    } catch (e) {
      // Email zaten kayıtlı, zayıf şifre, ağ hatası vb.
      setState(() => _error = 'Kayıt Başarısız. Email veya şifre hatalı.');
    } finally {
      // async sonrası widget hâlâ duruyor mu? mounted kontrolü.
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ad
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Adınız'),
            ),
            const SizedBox(height: 12),
            // Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            // Şifre (gizli karakter)
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre (min 6 karakter)',
              ),
            ),
            // Hata mesajı (varsa)
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            // Ana CTA
            FilledButton(
              onPressed: _loading ? null : _onRegister,
              child: Text(_loading ? 'Kayıt Yapılıyor...' : 'Kayıt Ol'),
            ),
            // push: geri tuşuyla register'a dönebilir.
            // go kullansaydın yığını değiştirirdi (geri farklı davranır).
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text('Zaten hesabım var'),
            ),
          ],
        ),
      ),
    );
  }
}
