import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../breathing/breathing_screen.dart';
import '../journal/journal_screen.dart';
import '../meditation/meditation_screen.dart';
import '../emergency_support_screen.dart';
import '../../utils/pattern_insight.dart';

// Shown right after a Wellness Assessment is saved. Same "never a dead
// end" principle as MoodResultScreen — plus, if a PatternInsight was
// found (looking across recent history, not just this one score), it
// gets shown too.
class WellnessResultScreen extends StatelessWidget {
  final int score;
  final PatternInsight insight;

  const WellnessResultScreen({
    super.key,
    required this.score,
    required this.insight,
  });

  Color get _scoreColor {
    if (score >= 70) return AppTheme.success;
    if (score >= 40) return Colors.orange;
    return AppTheme.danger;
  }

  String get _baseMessage {
    if (score >= 70) return 'You\'re doing great! Keep it up.';
    if (score >= 40) return 'You\'re doing okay — small changes can help.';
    return 'Things seem tough right now. Be kind to yourself.';
  }

  bool get _isLowScore => score < 45;

  @override
  Widget build(BuildContext context) {
    // Support options show for a low score OR when the pattern
    // detector flagged something concerning across recent history,
    // even if today's single score looks fine on its own.
    final showSupport = _isLowScore || insight.isConcerning;

    return Scaffold(
      appBar: AppBar(title: const Text('Wellness Check')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Your Wellness Score',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _scoreColor.withValues(alpha: 0.12),
                        border: Border.all(color: _scoreColor, width: 4),
                      ),
                      child: Center(
                        child: Text(
                          '$score%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _scoreColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _baseMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),

              // The personalization layer: only shows if a real
              // pattern was detected across recent entries.
              if (insight.message != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: insight.isConcerning
                        ? AppTheme.danger.withValues(alpha: 0.08)
                        : AppTheme.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: insight.isConcerning
                          ? AppTheme.danger.withValues(alpha: 0.25)
                          : AppTheme.secondary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        color: insight.isConcerning ? AppTheme.danger : AppTheme.secondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight.message!,
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),
              Text('What might help right now', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.air_rounded,
                title: 'A few minutes of breathing',
                subtitle: 'Reset with a short guided pattern.',
                color: AppTheme.primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BreathingScreen()),
                ),
              ),
              _ActionTile(
                icon: Icons.self_improvement_rounded,
                title: 'A guided meditation',
                subtitle: 'Slow down and sit with how you\'re feeling.',
                color: AppTheme.secondary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MeditationScreen()),
                ),
              ),
              _ActionTile(
                icon: Icons.book_outlined,
                title: 'Write it down',
                subtitle: 'Reflect on what\'s behind today\'s score.',
                color: AppTheme.accent,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const JournalScreen()),
                ),
              ),

              if (showSupport) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.danger.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'If this feeling is heavier than usual',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'There are real people ready to listen, any time.',
                        style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EmergencySupportScreen()),
                        ),
                        icon: const Icon(Icons.support_agent, color: AppTheme.danger),
                        label: const Text('See who you can talk to'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.danger,
                          side: const BorderSide(color: AppTheme.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }
}