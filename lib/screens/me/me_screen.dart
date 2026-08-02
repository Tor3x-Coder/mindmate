import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_settings_controller.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../settings/settings_screen.dart';
import '../welcome_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Me'),
      ),
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text('Please log in to view your space.'))
            : FutureBuilder<Map<String, dynamic>?>(
                future: firestoreService.getUserProfile(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final profile = snapshot.data ?? <String, dynamic>{};
                  return _MeContent(profile: profile);
                },
              ),
      ),
    );
  }
}

class _MeContent extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _MeContent({required this.profile});

  String _formatJoinedDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
final settings = context.watch<AppSettingsController>();
    final authService = context.read<AuthService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroTextColor = isDark ? Colors.white : AppTheme.textDark;

    final fullName = profile['fullName']?.toString().trim().isNotEmpty == true
        ? profile['fullName'].toString()
        : 'MindMate User';
    final email = profile['email']?.toString() ?? '';
    final goals = List<String>.from(profile['goals'] ?? const []);
    final createdAt = DateTime.tryParse(profile['createdAt']?.toString() ?? '');
    final reminderTime =
        profile['reminderTime']?.toString() ?? settings.checkInWindow;
    final initials = fullName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradientFor(Theme.of(context).brightness),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppTheme.surfaceBorder.withValues(alpha: 0.9),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: heroTextColor.withValues(alpha: 0.14),
                    child: Text(
                      initials.isEmpty ? 'M' : initials,
                      style: TextStyle(
                        color: heroTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: TextStyle(
                            color: heroTextColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            color: heroTextColor.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InfoBadge(
                    icon: Icons.schedule_rounded,
                    label: reminderTime,
                    isDark: isDark,
                  ),
                  _InfoBadge(
                    icon: Icons.timer_outlined,
                    label: '${settings.preferredSessionMinutes} min sessions',
                    isDark: isDark,
                  ),
                  _InfoBadge(
                    icon: Icons.auto_awesome_rounded,
                    label: settings.themeMode.name,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _SectionCard(
          title: 'Your rhythm',
          child: Column(
            children: [
              _SummaryTile(
                icon: Icons.wb_twilight_outlined,
                title: 'Preferred check-in',
                value: settings.checkInWindow,
              ),
              _SummaryTile(
                icon: Icons.timelapse_rounded,
                title: 'Go-to practice length',
                value: '${settings.preferredSessionMinutes} minutes',
              ),
              _SummaryTile(
                icon: Icons.calendar_month_outlined,
                title: 'Joined',
                value: createdAt == null
                    ? 'Recently'
                    : _formatJoinedDate(createdAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Focus areas',
          child: goals.isEmpty
              ? const Text(
                  'Your wellness goals will show up here once they are added.',
                  style: TextStyle(color: AppTheme.textLight),
                )
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: goals
                      .map(
                        (goal) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceAlt.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppTheme.surfaceBorder.withValues(alpha: 0.9),
                            ),
                          ),
                          child: Text(goal),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Account',
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.tune_rounded, color: AppTheme.primary),
                title: const Text('Open Settings'),
                subtitle: const Text('Adjust theme, motion, and daily flow.'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await authService.logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log out'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.isDark,
  });

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
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
