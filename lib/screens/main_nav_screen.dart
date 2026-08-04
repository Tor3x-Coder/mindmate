import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'home/home_tab_screen.dart';
import 'practice/practice_tab_screen.dart';
import 'chat/chat_tab_screen.dart';
import 'me/me_screen.dart';

// The main shell of the app after login. Holds the bottom nav bar and
// switches between the 4 main sections. IndexedStack (not just
// swapping widgets) keeps each tab's scroll position and state alive
// when you switch away and back, same as TikTok/Instagram behave.
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTabScreen(),
    PracticeTabScreen(),
    ChatTabScreen(),
    MeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppTheme.primary.withValues(alpha: isDark ? 0.24 : 0.14),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement_rounded),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}