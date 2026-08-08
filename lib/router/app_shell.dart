import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Ana kabuk: üstte AppBar, ortada aktif sekme, altta 3 tab.
/// StatefulNavigationShell = GoRouter'ın sekme yöneticisi.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  /// Hangi sekme aktif + sekme içeriğini çizen shell nesnesi.
  final StatefulNavigationShell navigationShell;

  /// Alt bardan sekme seçilince ilgili dala git.
  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Aynı sekmeye tekrar tıklanınca o dalın ilk rotasına dön.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusFlow'),
      ),
      // Ortada o anki sekmenin sayfası (/home, /discover, /profile).
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        // 0 Evim, 1 Keşfet, 2 Profil
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Evim',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Keşfet',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
