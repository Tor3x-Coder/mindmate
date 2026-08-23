import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_settings_controller.dart';
import '../widgets/floating_tide_navigation_bar.dart';
import '../widgets/mindmate_contextual_tour.dart';
import 'home/home_tab_screen.dart';
import 'practice/practice_tab_screen.dart';
import 'chat/chat_tab_screen.dart';
import 'me/me_screen.dart';

// The main shell of the app after login. Holds the bottom nav bar and
// switches between the 4 main sections. IndexedStack (not just
// swapping widgets) keeps each tab's scroll position and state alive
// when you switch away and back, same as TikTok/Instagram behave.
class MainNavScreen extends StatefulWidget {
  final bool showFirstUseGuide;

  const MainNavScreen({
    super.key,
    this.showFirstUseGuide = false,
  });

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  static const int _tourVersion = 1;

  int _currentIndex = 0;
  int _tourStepIndex = 0;
  int _lastReplayRequest = 0;
  bool _replayRequestInitialized = false;
  bool _automaticTourChecked = false;
  bool _showTour = false;

  static const List<MindMateTourStep> _tourSteps = [
    MindMateTourStep(
      label: 'Home',
      title: 'Start with this moment',
      message:
          'Use a quick check-in and MindMate will help you choose one small next step for right now.',
    ),
    MindMateTourStep(
      label: 'Practice',
      title: 'Choose what feels manageable',
      message:
          'Breathing, meditation, journaling, and thought-reflection tools live here. You never have to do everything.',
    ),
    MindMateTourStep(
      label: 'Chat',
      title: 'Talk in the way you need',
      message:
          'Ask the AI companion to listen, help you settle, or make one small plan. It is supportive, not a therapist.',
    ),
    MindMateTourStep(
      label: 'Me',
      title: 'Your space stays together',
      message:
          'Find your progress, support requests, privacy information, and personal settings here.',
    ),
  ];

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

  void _syncTourState(AppSettingsController settings) {
    if (!_replayRequestInitialized) {
      _lastReplayRequest = settings.tourReplayRequest;
      _replayRequestInitialized = true;
    } else if (_lastReplayRequest != settings.tourReplayRequest) {
      _lastReplayRequest = settings.tourReplayRequest;
      WidgetsBinding.instance.addPostFrameCallback((_) => _beginTour());
    }

    if (!settings.isLoaded || _automaticTourChecked) return;
    _automaticTourChecked = true;

    if (widget.showFirstUseGuide &&
        settings.completedTourVersion < _tourVersion) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _beginTour());
    }
  }

  void _beginTour() {
    if (!mounted) return;
    setState(() {
      _showTour = true;
      _tourStepIndex = 0;
      _currentIndex = 0;
    });
  }

  void _selectDestination(int index) {
    if (index == _currentIndex &&
        (!_showTour || index == _tourStepIndex)) {
      return;
    }

    setState(() {
      _currentIndex = index;
      if (_showTour) _tourStepIndex = index;
    });
  }

  void _nextTourStep() {
    if (_tourStepIndex >= _tourSteps.length - 1) {
      _finishTour();
      return;
    }

    setState(() {
      _tourStepIndex++;
      _currentIndex = _tourStepIndex;
    });
  }

  void _finishTour() {
    if (!_showTour) return;
    setState(() => _showTour = false);
    unawaited(
      context.read<AppSettingsController>().markTourCompleted(_tourVersion),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>();
    _syncTourState(settings);

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final tourAnimationDuration = reduceMotion
        ? Duration.zero
        : Duration(
            milliseconds:
                (360 / settings.animationIntensity.clamp(0.6, 1.3)).round(),
          );

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          if (_showTour)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: Colors.black.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.20
                        : 0.08,
                  ),
                ),
              ),
            ),
          if (_showTour)
            Positioned.fill(
              child: MindMateContextualTour(
                step: _tourSteps[_tourStepIndex],
                stepIndex: _tourStepIndex,
                stepCount: _tourSteps.length,
                animationDuration: tourAnimationDuration,
                onSkip: _finishTour,
                onNext: _nextTourStep,
              ),
            ),
        ],
      ),
      bottomNavigationBar: FloatingTideNavigationBar(
        selectedIndex: _currentIndex,
        destinations: _destinations,
        animationIntensity: settings.animationIntensity,
        onDestinationSelected: _selectDestination,
      ),
    );
  }
}