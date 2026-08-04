import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'onboarding_carousel_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
      Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OnboardingCarouselScreen()),
              );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.self_improvement, color: Colors.white, size: 72),
            const SizedBox(height: 16),
            const Text(
              'MindMate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your personal wellness companion',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}