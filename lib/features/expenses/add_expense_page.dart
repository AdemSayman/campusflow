import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/house_provider.dart';

/// "Gider Ekle" formu.
class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final Set<String> _selectedUids = {};
  bool _loading = false;
  String? _errorText;
  bool _initializedSelection = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// "45,50" veya "45.50" gibi bir TL string'ini kuruşa (int) çevirir.
  /// Geçersiz/negatif/sıfırsa null döner.
  int? _parseTlToKurus(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null || value <= 0) return null;
    return (value * 100).round();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUids.isEmpty) {
      setState(() => _errorText = 'En az bir kişi seçmelisin');
      return;
    }

    final uid = ref.read(authStateProvider).asData?.value?.uid;
    final houseId = ref.read(currentHouseIdProvider);
    if (uid == null || houseId == null) return;

    final amountKurus = _parseTlToKurus(_amountController.text);
    if (amountKurus == null) {
      setState(() => _errorText = 'Geçerli bir tutar gir');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await ref.read(expenseServiceProvider).addExpense(
            houseId: houseId,
            description: _descriptionController.text,
            amountKurus: amountKurus,
            paidBy: uid,
            splitBetween: _selectedUids.toList(),
          );
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _errorText = 'Eklenemedi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(currentHouseMembersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gider Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Ne için?',
                  hintText: 'Örn. Migros market alışverişi',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Açıklama boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Tutar (TL)',
                  hintText: 'Örn. 45,50',
                ),
                validator: (value) {
                  if (value == null || _parseTlToKurus(value) == null) {
                    return 'Geçerli bir tutar gir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Kimler paylaşıyor?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              membersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => Text('Üyeler yüklenemedi: $err'),
                data: (members) {
                  // İlk yüklemede herkesi seçili başlat (en yaygın senaryo:
                  // gider evdeki herkes arasında bölünür). setState değil,
                  // doğrudan atama — bu build çağrısı içinde zaten
                  // güncel değerle çiziliyor, ekstra rebuild gerekmiyor.
                  if (!_initializedSelection) {
                    _selectedUids.addAll(members.map((m) => m.uid));
                    _initializedSelection = true;
                  }
                  return Column(
                    children: [
                      for (final member in members)
                        _MemberCheckbox(
                          uid: member.uid,
                          selected: _selectedUids.contains(member.uid),
                          onChanged: (value) {
                            setState(() {
                              if (value) {
                                _selectedUids.add(member.uid);
                              } else {
                                _selectedUids.remove(member.uid);
                              }
                            });
                          },
                        ),
                    ],
                  );
                },
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(_errorText!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tek bir üyenin seçilebilir satırı (checkbox + isim).
class _MemberCheckbox extends StatelessWidget {
  const _MemberCheckbox({
    required this.uid,
    required this.selected,
    required this.onChanged,
  });

  final String uid;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        final name = snapshot.data?.data()?['name'] as String?;
        return CheckboxListTile(
          value: selected,
          title: Text((name != null && name.isNotEmpty) ? name : uid),
          onChanged: (value) => onChanged(value ?? false),
        );
      },
    );
  }
}
