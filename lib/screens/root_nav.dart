import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'breathe/breathe_list_screen.dart';
import 'train/train_list_screen.dart';
import 'read/book_list_screen.dart';
import 'profile/profile_screen.dart';

/// The bottom-nav shell: Home · Breathe · Train · Read · Profile.
class RootNav extends StatefulWidget {
  const RootNav({super.key});

  /// Lets other screens jump to a tab (e.g. Home quick-start buttons).
  static void go(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_RootNavState>();
    state?._select(index);
  }

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  // Keep pages alive so scroll/tab state is preserved between switches.
  late final List<Widget> _pages = const [
    HomeScreen(),
    BreatheListScreen(),
    TrainListScreen(),
    BookListScreen(),
    ProfileScreen(),
  ];

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.air_outlined),
            selectedIcon: Icon(Icons.air),
            label: 'Breathe',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement),
            label: 'Train',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Read',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
