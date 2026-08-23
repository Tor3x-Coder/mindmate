import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_settings_controller.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'auth/missing_profile_screen.dart';
import 'main_nav_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'onboarding_carousel_screen.dart';
import 'settings/delete_account_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _routeTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _routeTimer = Timer(
      const Duration(milliseconds: 2800),
      _routeAfterSplash,
    );
  }

  Future<void> _routeAfterSplash() async {
    final settings = context.read<AppSettingsController>();
    final auth = context.read<AuthService>();
    await settings.loaded;
    if (!mounted) return;

    final currentUser = auth.currentUser;
    Widget nextScreen;

    if (currentUser == null) {
      nextScreen = const OnboardingCarouselScreen();
    } else if (settings.accountDeletionPending) {
      nextScreen = const DeleteAccountScreen(resumePendingDeletion: true);
    } else {
      try {
        final profile = await auth.getCurrentUserProfile();
        if (!mounted) return;

        if (profile == null) {
          nextScreen = const MissingProfileScreen();
        } else if (profile.goals.isEmpty || profile.reminderTime == null) {
          nextScreen = const OnboardingScreen();
        } else {
          nextScreen = const MainNavScreen();
        }
      } catch (_) {
        // A temporary profile read failure should not sign out a valid user.
        // Home already has a friendly profile-unavailable state.
        nextScreen = const MainNavScreen();
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => nextScreen),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _routeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary, width: 3),
                ),
                child: const Icon(
                  Icons.self_improvement,
                  color: AppTheme.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'MindMate',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
