import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/pattern_insight.dart';
import '../breathing/breathing_screen.dart';
import '../chat/chat_tab_screen.dart';
import '../emergency_support_screen.dart';
import '../journal/journal_screen.dart';

class WellnessResultScreen extends StatelessWidget {
  final int score;
  final PatternInsight insight;

  const WellnessResultScreen({
    super.key,
    required this.score,
    required this.insight,
  });

  bool get _needsExtraSupport => score < 45 || insight.isConcerning;

  String get _observation {
    if (insight.message != null && insight.message!.trim().isNotEmpty) {
      return insight.message!;
    }

    if (score >= 70) {
      return 'You shared several signs of steadiness today. Keep noticing what supports you.';
    }
    if (score >= 40) {
      return 'Your answers show a mixed day. A small reset or quiet reflection may help.';
    }
    return 'Your answers suggest today feels heavier than usual. Be gentle with yourself.';
  }

  _ResultAction get _primaryAction {
    if (score >= 70) {
      return _ResultAction(
        title: 'Keep the good going',
        subtitle: 'Take a moment to notice what is supporting you today.',
        icon: Icons.favorite_border_rounded,
        color: AppTheme.secondary,
        builder: (_) => const JournalScreen(),
      );
    }

    if (_needsExtraSupport) {
      return _ResultAction(
        title: 'Talk it through',
        subtitle: 'Share what is making today feel heavier than usual.',
        icon: Icons.chat_bubble_outline_rounded,
        color: AppTheme.primary,
        builder: (_) => const ChatTabScreen(),
      );
    }

    return _ResultAction(
      title: 'Try a short breathing reset',
      subtitle: 'Give yourself three quiet minutes before doing anything else.',
      icon: Icons.air_rounded,
      color: AppTheme.primary,
      builder: (_) => const BreathingScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final action = _primaryAction;

    return Scaffold(
      appBar: AppBar(title: const Text('Your reflection')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildReflectionHero(context),
              const SizedBox(height: 22),
              const Text(
                'What we noticed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              _buildObservationCard(context),
              const SizedBox(height: 22),
              const Text(
                'One gentle next step',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              _buildActionCard(context, action),
              const SizedBox(height: 18),
              const Text(
                'Other ways to support yourself',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.book_outlined,
                title: 'Write it out',
                subtitle: 'Reflect on what is behind today’s snapshot.',
                color: AppTheme.secondary,
                onTap: () => _open(context, const JournalScreen()),
              ),
              _ActionTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Talk it through',
                subtitle: 'Use MindMate as a supportive sounding board.',
                color: AppTheme.accent,
                onTap: () => _open(context, const ChatTabScreen()),
              ),
              if (_needsExtraSupport) ...[
                const SizedBox(height: 10),
                _buildSupportCard(context),
              ],
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _buildReflectionHero(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(theme.brightness),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.68),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHECK-IN COMPLETE',
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.seaGlass
                        : const Color(0xFF806B59),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you for checking in with yourself.',
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textOnDark
                        : AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.insights_outlined, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _observation,
              style: const TextStyle(fontSize: 14, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
  BuildContext context,
  _ResultAction action,
) {
    return InkWell(
      onTap: () => _open(context, action.builder(context)),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: action.color.withValues(alpha: 0.55),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(action.icon, color: action.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.subtitle,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: action.color),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return InkWell(
      onTap: () => _open(context, const EmergencySupportScreen()),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.danger.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.danger.withValues(alpha: 0.32),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.support_agent_rounded, color: AppTheme.danger),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'If today feels heavier than usual, see the human-support options.',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.danger),
          ],
        ),
      ),
    );
  }
}

class _ResultAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;

  const _ResultAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
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
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
