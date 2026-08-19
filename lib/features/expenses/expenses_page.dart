import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/expense.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/house_provider.dart';
import '../../utils/money_format.dart';

/// Giderler ekranı (K2). Net bakiye özeti + gider listesi + ekleme FAB'ı.
class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(houseExpensesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Giderler')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/home/expenses/add'),
        child: const Icon(Icons.add),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Bir şeyler ters gitti: $err')),
        data: (expenses) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _NetBalanceCard(),
            const SizedBox(height: 16),
            Text('Giderler', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (expenses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Henüz gider yok. Sağ alttaki + ile ekle.'),
                ),
              ),
            for (final expense in expenses) _ExpenseTile(expense: expense),
            // FAB'ın son öğeyi kapatmaması için altta biraz boşluk.
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }
}

/// Kullanıcının kendi net bakiyesi + evdeki herkesin bakiyesi.
class _NetBalanceCard extends ConsumerWidget {
  const _NetBalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myBalance = ref.watch(myNetBalanceProvider);
    final allBalances = ref.watch(netBalancesProvider);
    final membersAsync = ref.watch(currentHouseMembersProvider);

    final Color color;
    final String myText;
    if (myBalance > 0) {
      color = Colors.green;
      myText = 'Sen ${formatKurusAsTl(myBalance)} alacaklısın';
    } else if (myBalance < 0) {
      color = Colors.red;
      myText = 'Sen ${formatKurusAsTl(myBalance.abs())} borçlusun';
    } else {
      color = Colors.grey;
      myText = 'Ödeştin';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              myText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            const Text(
              'Evdeki durum',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            membersAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (members) => Column(
                children: [
                  for (final member in members)
                    _MemberBalanceRow(
                      uid: member.uid,
                      balanceKurus: allBalances[member.uid] ?? 0,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tek bir üyenin (isim + bakiye) satırı; isim users/{uid}'den bir kerelik
/// çekiliyor (FutureBuilder) — K1'deki _MemberTile ile aynı desen.
class _MemberBalanceRow extends StatelessWidget {
  const _MemberBalanceRow({required this.uid, required this.balanceKurus});

  final String uid;
  final int balanceKurus;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        final name = snapshot.data?.data()?['name'] as String?;
        final label = (name != null && name.isNotEmpty) ? name : uid;
        final text = balanceKurus == 0
            ? 'ödeşti'
            : balanceKurus > 0
                ? '+${formatKurusAsTl(balanceKurus)}'
                : '-${formatKurusAsTl(balanceKurus.abs())}';
        final color = balanceKurus == 0
            ? Colors.grey
            : balanceKurus > 0
                ? Colors.green
                : Colors.red;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                text,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Tek bir gider satırı: açıklama, tutar, ödeyen, "açık/kapandı" durumu.
/// Durum FilterChip ile değiştirilebilir (herhangi bir üye kapatabilir);
/// silme sadece gideri ekleyen kişiye (paidBy) açık.
class _ExpenseTile extends ConsumerWidget {
  const _ExpenseTile({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = ref.watch(authStateProvider).asData?.value?.uid;
    final isMine = myUid == expense.paidBy;
    final houseId = ref.watch(currentHouseIdProvider);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(expense.paidBy)
          .get(),
      builder: (context, snapshot) {
        final payerName = snapshot.data?.data()?['name'] as String?;
        final payerLabel =
            (payerName != null && payerName.isNotEmpty) ? payerName : expense.paidBy;

        return Card(
          child: ListTile(
            title: Text(expense.description),
            subtitle: Text(
              '${formatKurusAsTl(expense.amountKurus)} · Ödeyen: $payerLabel · '
              '${expense.splitBetween.length} kişiye bölündü',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilterChip(
                  label: Text(expense.settled ? 'Kapandı' : 'Açık'),
                  selected: expense.settled,
                  onSelected: houseId == null
                      ? null
                      : (value) {
                          ref.read(expenseServiceProvider).setSettled(
                                houseId: houseId,
                                expenseId: expense.id,
                                settled: value,
                              );
                        },
                ),
                if (isMine && houseId != null)
                  IconButton(
                    tooltip: 'Sil',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref.read(expenseServiceProvider).deleteExpense(
                            houseId: houseId,
                            expenseId: expense.id,
                          );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
