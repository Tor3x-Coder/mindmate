import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../breathing/breathing_screen.dart';
import '../cbt/cbt_thought_reframe_screen.dart';
import '../chat/chat_tab_screen.dart';
import '../journal/journal_screen.dart';
import '../meditation/meditation_screen.dart';
import '../professional/admin_professionals_screen.dart';
import '../professional/professional_directory_screen.dart';
import '../progress/progress_screen.dart';
import '../achievements_screen.dart';

class PracticeTabScreen extends StatefulWidget {
  const PracticeTabScreen({super.key});

  @override
  State<PracticeTabScreen> createState() => _PracticeTabScreenState();
}

class _PracticeTabScreenState extends State<PracticeTabScreen> {
  bool _isAdmin = false;
  bool _checkedAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid == null) {
      if (!mounted) return;
      setState(() => _checkedAdmin = true);
      return;
    }

    try {
      final admin = await firestoreService.isUserAdmin(uid);
      if (!mounted) return;
      setState(() {
        _isAdmin = admin;
        _checkedAdmin = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _checkedAdmin = true);
    }
  }

  void _open(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose a path and take your time.',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              _buildPathIntro(),
              const SizedBox(height: 18),
              _PracticePathCard(
                icon: Icons.air_rounded,
                title: 'Calm your body',
                subtitle: 'Breathing patterns and quick resets',
                color: AppTheme.primary,
                onTap: () => _open(const BreathingScreen()),
              ),
              const SizedBox(height: 10),
              _PracticePathCard(
                icon: Icons.self_improvement_rounded,
                title: 'Quiet your mind',
                subtitle: 'Meditation and focus sessions',
                color: AppTheme.secondary,
                onTap: () => _open(const MeditationScreen()),
              ),
              const SizedBox(height: 10),
              _PracticePathCard(
                icon: Icons.edit_note_rounded,
                title: 'Reflect on it',
                subtitle: 'Journal prompts and thought reframing',
                color: AppTheme.accent,
                onTap: () => _open(const JournalScreen()),
                trailingAction: () => _open(const CbtThoughtReframeScreen()),
                trailingLabel: 'Reframe',
              ),
              const SizedBox(height: 10),
              _PracticePathCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Connect',
                subtitle: 'Talk with MindMate or find human support',
                color: const Color(0xFF52759A),
                onTap: () => _open(const ChatTabScreen()),
                trailingAction: () => _open(const ProfessionalDirectoryScreen()),
                trailingLabel: 'People',
              ),
              const SizedBox(height: 24),
              Text(
                'Your practice shelf',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              _PracticeShelfRow(
                icon: Icons.air_rounded,
                title: 'Breathing patterns',
                subtitle: '1–5 minute sessions',
                color: AppTheme.primary,
                onTap: () => _open(const BreathingScreen()),
              ),
              const SizedBox(height: 8),
              _PracticeShelfRow(
                icon: Icons.self_improvement_rounded,
                title: 'Guided meditation',
                subtitle: '18 sessions across 6 categories',
                color: AppTheme.secondary,
                onTap: () => _open(const MeditationScreen()),
              ),
              const SizedBox(height: 8),
              _PracticeShelfRow(
                icon: Icons.book_outlined,
                title: 'Private journaling',
                subtitle: 'Prompts and personal entries',
                color: AppTheme.accent,
                onTap: () => _open(const JournalScreen()),
              ),
              const SizedBox(height: 8),
              _PracticeShelfRow(
                icon: Icons.show_chart_rounded,
                title: 'Progress',
                subtitle: 'See your patterns over time',
                color: AppTheme.primary,
                onTap: () => _open(const ProgressScreen()),
              ),
              const SizedBox(height: 8),
              _PracticeShelfRow(
                icon: Icons.emoji_events_outlined,
                title: 'Achievements',
                subtitle: 'Celebrate the steps you have taken',
                color: AppTheme.secondary,
                onTap: () => _open(const AchievementsScreen()),
              ),
              if (_checkedAdmin && _isAdmin) ...[
                const SizedBox(height: 24),
                _PracticeShelfRow(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Manage support directory',
                  subtitle: 'Admin tools',
                  color: AppTheme.danger,
                  onTap: () => _open(const AdminProfessionalsScreen()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathIntro() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRACTICE PATHS',
            style: TextStyle(
              color: Color(0xFF35545B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'What kind of practice are you looking for?',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticePathCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? trailingAction;
  final String? trailingLabel;

  const _PracticePathCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.trailingAction,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (trailingAction != null && trailingLabel != null)
          TextButton(
            onPressed: trailingAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(trailingLabel!),
          )
        else
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textLight,
          ),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
          ),
        ),
        child: content,
      ),
    );
  }
}

class _PracticeShelfRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PracticeShelfRow({
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.72),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
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
