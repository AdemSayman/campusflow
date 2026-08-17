import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/house_provider.dart';

/// "Davet Koduyla Katıl" formu.
class JoinHousePage extends ConsumerStatefulWidget {
  const JoinHousePage({super.key});

  @override
  ConsumerState<JoinHousePage> createState() => _JoinHousePageState();
}

class _JoinHousePageState extends ConsumerState<JoinHousePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
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
      await ref.read(houseServiceProvider).joinWithCode(
            uid: uid,
            code: _codeController.text,
          );
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _errorText = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object e) {
    final text = e.toString();
    return text.startsWith('StateError: ')
        ? text.substring('StateError: '.length)
        : 'Katılınamadı: $text';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Davet Koduyla Katıl')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Davet kodu',
                  hintText: '6 haneli kod',
                ),
                validator: (value) {
                  if (value == null || value.trim().length != 6) {
                    return 'Kod 6 haneli olmalı';
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
                    : const Text('Katıl'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
