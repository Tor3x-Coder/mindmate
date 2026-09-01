import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_settings_controller.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../breathing/breathing_screen.dart';
import '../chat/chat_tab_screen.dart';
import '../emergency_support_screen.dart';
import '../journal/journal_screen.dart';
import '../learn/learn_screen.dart';
import '../mood/mood_checkin_screen.dart';
import '../settings/settings_screen.dart';
import '../wellness/wellness_assessment_screen.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  String _userName = 'there';
  bool _isLoading = true;
  bool _profileLoadFailed = false;
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

    if (uid == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    try {
      final profile = await firestoreService.getUserProfile(uid);
      if (!mounted) return;

      final fullName = profile?['fullName']?.toString().trim() ?? '';
      setState(() {
        _profile = profile;
        _userName = fullName.isEmpty ? 'there' : fullName.split(' ').first;
        _isLoading = false;
      });
    } catch (_) {
      // Home should remain useful even if the profile request fails because
      // of a temporary network problem. The check-in flow can still work.
      if (!mounted) return;
      setState(() {
        _profileLoadFailed = true;
        _isLoading = false;
      });
    }
  }

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  void _openMoodCheckIn() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MoodCheckinScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final reminderTime =
        _profile?['reminderTime']?.toString() ?? settings.checkInWindow;
    final goals = List<String>.from(_profile?['goals'] ?? const <String>[]);
    final greeting = _greetingForNow();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MindMate'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '$greeting, $_userName',
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'You can start with one small thing.',
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 15,
                      ),
                    ),
                    if (_profileLoadFailed) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Some profile details are unavailable right now, but your check-in is still ready.',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    _buildRightNowCard(),
                    const SizedBox(height: 12),
                    _buildNeedHelpCard(),
                    const SizedBox(height: 26),
                    _buildRoutineCard(
                      reminderTime: reminderTime,
                      goalsCount: goals.length,
                    ),
                    const SizedBox(height: 14),
                    _buildWellnessCard(onSurface),
                    const SizedBox(height: 14),
                    _buildLearnCard(),
                    const SizedBox(height: 26),
                    Text(
                      'Quick starts',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickStartCard(
                            icon: Icons.air_rounded,
                            title: 'Breathe',
                            subtitle: '3 min',
                            color: AppTheme.primary,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BreathingScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickStartCard(
                            icon: Icons.book_outlined,
                            title: 'Journal',
                            subtitle: 'Reflect',
                            color: AppTheme.secondary,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const JournalScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickStartCard(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'Talk',
                            subtitle: 'AI companion',
                            color: AppTheme.accent,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChatTabScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRightNowCard() {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(brightness),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FOR RIGHT NOW',
                  style: TextStyle(
                    color: Color(0xFF35545B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'What would feel useful?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'A quick check-in helps us choose your next step.',
                  style: TextStyle(
                    color: Color(0xFF35545B),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _openMoodCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Check in now'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.48),
              shape: BoxShape.circle,
            ),
            child: const Text('🌊', style: TextStyle(fontSize: 36)),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedHelpCard() {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const EmergencySupportScreen(),
        ),
      ),
      borderRadius: BorderRadius.circular(21),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.danger.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: AppTheme.danger.withValues(alpha: 0.38),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppTheme.danger,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need help right now?',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Open emergency and human-support options.',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.danger,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppTheme.textOnDark : AppTheme.textDark;
    final supportingColor = isDark
        ? const Color(0xFFB9D3CE)
        : const Color(0xFF35545B);

    return Semantics(
      button: true,
      label: 'Learn: honest reads on what helps and hurts your mind',
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LearnScreen()),
        ),
        borderRadius: BorderRadius.circular(23),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradientFor(Theme.of(context).brightness),
            borderRadius: BorderRadius.circular(23),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEARN',
                      style: TextStyle(
                        color: supportingColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Learn — honest reads on what helps and hurts your mind',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Take what is useful. Leave the lecture.',
                      style: TextStyle(
                        color: supportingColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineCard({
    required String reminderTime,
    required int goalsCount,
  }) {
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.waves_rounded,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your routine',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  '$reminderTime check-in  •  $goalsCount ${goalsCount == 1 ? 'goal' : 'goals'}',
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textLight,
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessCard(Color onSurface) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const WellnessAssessmentScreen()),
      ),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.favorite_outline_rounded,
                color: AppTheme.danger,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Take a wellness check',
                    style: TextStyle(
                      color: onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Reflect on how today has been feeling.',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickStartCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 13),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
