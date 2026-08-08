import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/discover/discover_placeholder_page.dart';
import '../features/home/home_placeholder_page.dart';
import '../features/profile/profile_placeholder_page.dart';
import '../providers/auth_provider.dart';
import 'app_shell.dart';

/// Auth oturumu değişince GoRouter'a "yeniden düşün" sinyali gönderen köprü.
/// GoRouter sadece Listenable dinler; Riverpod Stream doğrudan Listenable değil.
/// Bu yüzden ChangeNotifier ile ping atıyoruz.
class _AuthRefresh extends ChangeNotifier {
  /// notifyListeners → GoRouter redirect'i tekrar çalıştırır.
  void ping() => notifyListeners();
}

/// Uygulama genelindeki GoRouter.
/// Provider içinde üretiyoruz ki ref.listen / ref.read kullanabilelim.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh();

  // authStateProvider her değişince (giriş/çıkış) refresh.ping()
  // → redirect yeniden hesaplanır.
  ref.listen(authStateProvider, (previous, next) {
    refresh.ping();
  });

  return GoRouter(
    // İlk açılışta denenen yol (redirect gerekirse login'e çevrilir).
    initialLocation: '/home',
    // Auth değişince redirect tetikleyici.
    refreshListenable: refresh,
    // Kapıcı: "Bu sayfaya girebilir mi?" — her navigasyonda / refresh'te çalışır.
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);

      // Stream henüz yükleniyorsa bekle; yoksa yanlışlıkla login flash olur.
      if (auth.isLoading) return null;

      // asData?.value → AsyncValue içinden User? çıkar (yoksa null).
      final user = auth.asData?.value;
      // matchedLocation: şu anki yol (/login, /home, ...).
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/register';

      // Giriş yok + korumalı sayfa (Evim vb.) → login'e zorla.
      if (user == null && !isAuthRoute) return '/login';

      // Giriş var ama login/register'da → ana sayfaya at (çift giriş olmasın).
      if (user != null && isAuthRoute) return '/home';

      // null = "yolu değiştirme, olduğu gibi devam".
      return null;
    },
    routes: [
      // --- Auth rotaları (shell dışında; alt tab bar yok) ---
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      // --- Ana kabuk: altta Evim / Keşfet / Profil ---
      // indexedStack: sekme değişince diğer sekmelerin state'i korunur.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // AppShell: AppBar + NavigationBar + aktif sekme gövdesi.
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Dal 0 → Evim
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePlaceholderPage(),
              ),
            ],
          ),
          // Dal 1 → Keşfet
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                name: 'discover',
                builder: (context, state) => const DiscoverPlaceholderPage(),
              ),
            ],
          ),
          // Dal 2 → Profil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfilePlaceholderPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
