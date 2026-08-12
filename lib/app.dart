import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';

/// Uygulamanın kök widget'ı.
/// ConsumerWidget: Riverpod'dan ref.watch / ref.read kullanabilir.
class CampusFlowApp extends ConsumerWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // goRouterProvider: Auth'a göre redirect yapan GoRouter.
    // watch: router değişirse (nadiren) MaterialApp yenilenir.
    final router = ref.watch(goRouterProvider);

    // MaterialApp.router = klasik "home:" yerine GoRouter ile gezinme.
    return MaterialApp.router(
      title: 'CampusFlow',
      theme: ThemeData(
        // fromSeed: tek renkten tüm paleti üretir (Material 3).
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // Tüm sayfa geçişleri bu router üzerinden akar.
      routerConfig: router,
    );
  }
}
