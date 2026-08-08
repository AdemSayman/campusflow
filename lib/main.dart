import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

/// Uygulama giriş noktası.
Future<void> main() async {
  // Firebase init'ten önce Flutter motorunu hazırla (zorunlu).
  WidgetsFlutterBinding.ensureInitialized();

  // firebase_options.dart içindeki platform config ile Firebase'i başlat.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ProviderScope: tüm Riverpod provider'larının kökü.
  // Bunun dışında ref.watch / ref.read çalışmaz.
  runApp(
    const ProviderScope(
      child: CampusFlowApp(),
    ),
  );
}
