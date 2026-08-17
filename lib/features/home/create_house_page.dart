import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/house_provider.dart';

/// "Ev Oluştur" formu.
/// ConsumerStatefulWidget: hem ref (Riverpod) hem de kendi State'imiz
/// (form kontrolcüleri, loading/hata durumu) gerektiği için.
class CreateHousePage extends ConsumerStatefulWidget {
  const CreateHousePage({super.key});

  @override
  ConsumerState<CreateHousePage> createState() => _CreateHousePageState();
}

class _CreateHousePageState extends ConsumerState<CreateHousePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = ref.read(authStateProvider).asData?.value?.uid;
    if (uid == null) return;

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await ref.read(houseServiceProvider).createHouse(
            uid: uid,
            name: _nameController.text,
          );
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _errorText = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// StateError('mesaj') gibi hataları kullanıcıya "StateError:" öneki
  /// olmadan gösterir.
  String _friendlyError(Object e) {
    final text = e.toString();
    return text.startsWith('StateError: ')
        ? text.substring('StateError: '.length)
        : 'Ev oluşturulamadı: $text';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ev Oluştur')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ev adı',
                  hintText: 'Örn. Bahçelievler 3B',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ev adı boş olamaz';
                  }
                  return null;
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
                    : const Text('Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
