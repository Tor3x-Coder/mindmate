import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../breathing/breathing_screen.dart';
import '../meditation/meditation_screen.dart';
import '../journal/journal_screen.dart';
import '../progress/progress_screen.dart';
import '../achievements_screen.dart';
import '../professional/professional_directory_screen.dart';
import '../professional/admin_professionals_screen.dart';

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

    if (uid != null) {
      final admin = await firestoreService.isUserAdmin(uid);
      if (mounted) {
        setState(() {
          _isAdmin = admin;
          _checkedAdmin = true;
        });
      }
    } else {
      setState(() => _checkedAdmin = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Space'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Practice', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PracticeCard(
                      title: 'Breathing',
                      subtitle: 'Reset quickly with guided patterns.',
                      icon: Icons.air_rounded,
                      accentColor: AppTheme.primary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BreathingScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PracticeCard(
                      title: 'Meditation',
                      subtitle: 'Slow down and sit with intention.',
                      icon: Icons.self_improvement_rounded,
                      accentColor: AppTheme.secondary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MeditationScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Explore', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (!_checkedAdmin)
                const Center(child: CircularProgressIndicator())
              else
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.14,
                  children: [
                    _QuickActionTile(
                      icon: Icons.book_outlined,
                      label: 'Journal',
                      subtitle: 'Reflect with prompts and entries.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const JournalScreen()),
                      ),
                    ),
                    _QuickActionTile(
                      icon: Icons.show_chart_rounded,
                      label: 'Progress',
                      subtitle: 'See your patterns over time.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProgressScreen()),
                      ),
                    ),
                    _QuickActionTile(
                      icon: Icons.emoji_events_outlined,
                      label: 'Achievements',
                      subtitle: 'See your streaks and badges.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                      ),
                    ),
                    _QuickActionTile(
                      icon: Icons.people_outline_rounded,
                      label: 'Support',
                      subtitle: 'Reach out when you need guidance.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfessionalDirectoryScreen()),
                      ),
                    ),
                    if (_isAdmin)
                      _QuickActionTile(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Admin',
                        subtitle: 'Manage the support directory.',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AdminProfessionalsScreen()),
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
}

class _PracticeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _PracticeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.75)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.75)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}