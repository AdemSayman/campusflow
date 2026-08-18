import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/house.dart';
import '../../models/membership.dart';
import '../../providers/auth_provider.dart';
import '../../providers/house_provider.dart';

/// Evim sekmesi (K1).
/// Kullanıcının bir evi yoksa "oluştur / katıl" CTA'sı, varsa ev bilgisi +
/// davet kodu + üye listesi + ayrılma seçeneği gösterir.
///
/// Not: Dosya adı hâlâ "home_placeholder_page.dart" — router importlarını
/// karıştırmamak için değiştirmedik, istersen ileride `git mv` ile
/// `home_page.dart`'a taşıyabiliriz. Fonksiyonel olarak artık placeholder
/// değil.
class HomePlaceholderPage extends ConsumerWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final houseAsync = ref.watch(currentHouseProvider);

    return houseAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Bir şeyler ters gitti: $err'),
        ),
      ),
      data: (house) {
        if (house == null) {
          return const _NoHouseView();
        }
        return _HouseView(house: house);
      },
    );
  }
}

/// Henüz eve bağlı değilken gösterilen CTA.
class _NoHouseView extends StatelessWidget {
  const _NoHouseView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Henüz bir evin yok',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yeni bir ev oluştur ya da ev arkadaşının verdiği davet '
              'koduyla katıl.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/home/create'),
              icon: const Icon(Icons.add_home_outlined),
              label: const Text('Ev Oluştur'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/home/join'),
              icon: const Icon(Icons.key_outlined),
              label: const Text('Davet Koduyla Katıl'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kullanıcının evi varken gösterilen ana görünüm.
class _HouseView extends ConsumerWidget {
  const _HouseView({required this.house});

  final House house;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(currentHouseMembersProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  house.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Davet kodu: '),
                    Text(
                      house.inviteCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Kodu kopyala',
                      icon: const Icon(Icons.copy_outlined),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: house.inviteCode),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kod kopyalandı')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Giderler'),
            subtitle: const Text('Ortak harcamalar ve net borç durumu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/home/expenses'),
          ),
        ),
        const SizedBox(height: 16),
        Text('Üyeler', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        membersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Üyeler yüklenemedi: $err'),
          data: (members) => Column(
            children: [
              for (final member in members) _MemberTile(member: member),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          icon: const Icon(Icons.logout),
          label: const Text('Evden Ayrıl'),
          onPressed: () => _confirmLeave(context, ref),
        ),
      ],
    );
  }

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Evden ayrılmak istediğine emin misin?'),
        content: const Text(
          'Bu evle ilgili gider/görev geçmişin evde kalır, sadece '
          'üyelikten çıkarsın.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ayrıl'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final uid = ref.read(authStateProvider).asData?.value?.uid;
    if (uid == null) return;

    await ref.read(houseServiceProvider).leaveHouse(
          uid: uid,
          houseId: house.id,
        );
  }
}

/// Tek bir üyeyi (isim + rol rozeti) gösteren satır.
/// Üye adı users/{uid} dokümanından bir kerelik çekiliyor (FutureBuilder) —
/// üye sayısı MVP'de az olduğu için bu basit yaklaşım yeterli.
class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final Membership member;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(member.uid)
          .get(),
      builder: (context, snapshot) {
        final name = snapshot.data?.data()?['name'] as String?;
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(
            (name != null && name.isNotEmpty) ? name : member.uid,
          ),
          trailing: member.isOwner ? const Chip(label: Text('Kurucu')) : null,
        );
      },
    );
  }
}
