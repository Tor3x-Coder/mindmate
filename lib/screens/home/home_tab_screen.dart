import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_settings_controller.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../mood/mood_checkin_screen.dart';
import '../wellness/wellness_assessment_screen.dart';
import '../settings/settings_screen.dart';

// The trimmed-down Home tab — just the greeting, Mood Check-in, and
// Wellness Score. Everything else that used to crowd the old
// Dashboard now lives in the Practice tab instead.
class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  String _userName = '';
  bool _isLoading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid != null) {
      final profile = await firestoreService.getUserProfile(uid);
      if (mounted) {
        setState(() {
          _profile = profile;
          _userName =
              profile?['fullName']?.toString().split(' ').first ?? 'there';
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>();
    final reminderTime =
        _profile?['reminderTime']?.toString() ?? settings.checkInWindow;
    final goalsCount = List<String>.from(_profile?['goals'] ?? const []).length;
    final greeting = _greetingForNow();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroTextColor = isDark ? Colors.white : AppTheme.textDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MindMate'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.heroGradientFor(Theme.of(context).brightness),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppTheme.surfaceBorder.withValues(alpha: 0.95),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting, $_userName',
                            style: TextStyle(
                              color: heroTextColor,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'A softer, calmer space for your day.',
                            style: TextStyle(
                              color: heroTextColor.withValues(alpha: 0.76),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _HeroPill(
                                icon: Icons.schedule_rounded,
                                label: '$reminderTime rhythm',
                                isDark: isDark,
                              ),
                              _HeroPill(
                                icon: Icons.auto_awesome_rounded,
                                label: '$goalsCount goals',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('For right now', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _FeatureSpotlight(
                      title: 'Daily Mood Check-In',
                      subtitle: 'Log how you feel and keep your emotional rhythm visible.',
                      icon: Icons.mood_rounded,
                      gradient: isDark
                          ? const LinearGradient(colors: [Color(0xFF1A3242), Color(0xFF23364B)])
                          : const LinearGradient(colors: [Color(0xFFDCEEE7), Color(0xFFE8F4F0)]),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MoodCheckinScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FeatureSpotlight(
                      title: 'Wellness Score',
                      subtitle: 'Take today\'s assessment and see where your energy stands.',
                      icon: Icons.favorite_border_rounded,
                      gradient: isDark
                          ? const LinearGradient(colors: [Color(0xFF2A2443), Color(0xFF1C2842)])
                          : const LinearGradient(colors: [Color(0xFFE9E5F9), Color(0xFFEFF1FB)]),
                      trailingLabel: 'Start',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WellnessAssessmentScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _FeatureSpotlight extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final String trailingLabel;
  final VoidCallback onTap;

  const _FeatureSpotlight({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.trailingLabel = 'Open',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: textColor.withValues(alpha: 0.72), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(trailingLabel, style: TextStyle(color: textColor.withValues(alpha: 0.82), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _HeroPill({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white : AppTheme.textDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}