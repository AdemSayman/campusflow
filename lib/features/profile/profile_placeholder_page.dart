import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

/// Profil sekmesi (şimdilik placeholder + çıkış).
/// ConsumerWidget: setState yok; ref ile AuthService'e erişir.
class ProfilePlaceholderPage extends ConsumerWidget {
  const ProfilePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        // İçeriği dikeyde mümkün olduğunca küçük tut, ortala.
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Profil — yakında'),
          const SizedBox(height: 16),
          // Çıkış: Auth oturumunu kapatır.
          // authState null olur → goRouter redirect → /login.
          FilledButton(
            onPressed: () {
              ref.read(authServiceProvider).signOut();
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
