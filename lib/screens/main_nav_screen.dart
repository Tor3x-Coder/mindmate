import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_settings_controller.dart';
import '../widgets/floating_tide_navigation_bar.dart';
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

  static const List<FloatingTideDestination> _destinations = [
    FloatingTideDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    FloatingTideDestination(
      icon: Icons.self_improvement_outlined,
      selectedIcon: Icons.self_improvement_rounded,
      label: 'Practice',
    ),
    FloatingTideDestination(
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
      label: 'Chat',
    ),
    FloatingTideDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Me',
    ),
  ];

  final List<Widget> _tabs = const [
    HomeTabScreen(),
    PracticeTabScreen(),
    ChatTabScreen(),
    MeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: FloatingTideNavigationBar(
        selectedIndex: _currentIndex,
        destinations: _destinations,
        animationIntensity: settings.animationIntensity,
        onDestinationSelected: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}