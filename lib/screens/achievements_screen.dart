import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mood_log_model.dart';
import '../models/journal_entry_model.dart';
import '../models/meditation_session_model.dart';
import '../models/wellness_assessment_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';

// A single badge definition: a milestone the user can unlock.
// `isUnlocked` is computed live from the user's real data — nothing
// is stored separately, so badges always reflect the truth.
class _Badge {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;

  const _Badge({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  // Looks at a list of dates and counts how many consecutive days
  // (including today or yesterday) the person has shown up. This is
  // the same idea as a "day streak" in habit apps like Duolingo.
  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    // Reduce every date down to just the day (ignore time-of-day),
    // then remove duplicates so multiple check-ins on the same day
    // only count once.
    final uniqueDays = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // The streak only counts if the most recent entry was today or
    // yesterday — otherwise the streak has already been broken.
    final mostRecent = uniqueDays.first;
    final daysSinceLast = todayOnly.difference(mostRecent).inDays;
    if (daysSinceLast > 1) return 0;

    var streak = 1;
    for (var i = 0; i < uniqueDays.length - 1; i++) {
      final difference = uniqueDays[i].difference(uniqueDays[i + 1]).inDays;
      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final firestoreService = context.watch<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to see your achievements.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Progress')),
      body: SafeArea(
        // Four streams combined, same pattern as the Progress screen —
        // everything updates live as the user logs more activity.
        child: StreamBuilder<List<MoodLogModel>>(
          stream: firestoreService.moodLogsForUser(uid),
          builder: (context, moodSnapshot) {
            return StreamBuilder<List<JournalEntryModel>>(
              stream: firestoreService.journalEntriesForUser(uid),
              builder: (context, journalSnapshot) {
                return StreamBuilder<List<MeditationSessionModel>>(
                  stream: firestoreService.meditationSessionsForUser(uid),
                  builder: (context, meditationSnapshot) {
                    return StreamBuilder<List<WellnessAssessmentModel>>(
                      stream: firestoreService.wellnessAssessmentsForUser(uid),
                      builder: (context, wellnessSnapshot) {
                        final isLoading = moodSnapshot.connectionState ==
                                ConnectionState.waiting ||
                            journalSnapshot.connectionState ==
                                ConnectionState.waiting ||
                            meditationSnapshot.connectionState ==
                                ConnectionState.waiting ||
                            wellnessSnapshot.connectionState ==
                                ConnectionState.waiting;

                        if (isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final moods = moodSnapshot.data ?? [];
                        final journalEntries = journalSnapshot.data ?? [];
                        final meditationSessions = meditationSnapshot.data ?? [];
                        final assessments = wellnessSnapshot.data ?? [];

                        // Combine every activity type's dates into one
                        // list so the streak reflects "showed up in the
                        // app at all today," not just one specific
                        // feature.
                        final allDates = <DateTime>[
                          ...moods.map((m) => m.date),
                          ...journalEntries.map((j) => j.date),
                          ...meditationSessions.map((m) => m.date),
                          ...assessments.map((a) => a.date),
                        ];

                        final streak = _calculateStreak(allDates);

                        final badges = _buildBadges(
                          moodCount: moods.length,
                          journalCount: journalEntries.length,
                          meditationCount: meditationSessions.length,
                          wellnessCount: assessments.length,
                          streak: streak,
                        );

                        return _buildContent(context, streak, badges);
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // The full set of possible badges. Each one checks against real
  // counts, so it's easy to add more later — just add another _Badge
  // with its own unlock condition.
  List<_Badge> _buildBadges({
    required int moodCount,
    required int journalCount,
    required int meditationCount,
    required int wellnessCount,
    required int streak,
  }) {
    return [
      _Badge(
        title: 'First Check-In',
        description: 'Logged your very first mood.',
        icon: Icons.mood_rounded,
        isUnlocked: moodCount >= 1,
      ),
      _Badge(
        title: 'First Entry',
        description: 'Wrote your first journal entry.',
        icon: Icons.book_outlined,
        isUnlocked: journalCount >= 1,
      ),
      _Badge(
        title: 'First Session',
        description: 'Completed your first meditation.',
        icon: Icons.self_improvement_rounded,
        isUnlocked: meditationCount >= 1,
      ),
      _Badge(
        title: 'Self-Aware',
        description: 'Completed your first wellness assessment.',
        icon: Icons.favorite_border_rounded,
        isUnlocked: wellnessCount >= 1,
      ),
      _Badge(
        title: 'Reflective',
        description: 'Wrote 5 journal entries.',
        icon: Icons.edit_note_rounded,
        isUnlocked: journalCount >= 5,
      ),
      _Badge(
        title: 'Centered',
        description: 'Completed 10 meditation sessions.',
        icon: Icons.spa_outlined,
        isUnlocked: meditationCount >= 10,
      ),
      _Badge(
        title: '3-Day Streak',
        description: 'Showed up 3 days in a row.',
        icon: Icons.local_fire_department_rounded,
        isUnlocked: streak >= 3,
      ),
      _Badge(
        title: '7-Day Streak',
        description: 'A full week of showing up for yourself.',
        icon: Icons.local_fire_department_rounded,
        isUnlocked: streak >= 7,
      ),
      _Badge(
        title: '30-Day Streak',
        description: 'A month of consistent care.',
        icon: Icons.emoji_events_rounded,
        isUnlocked: streak >= 30,
      ),
    ];
  }

  Widget _buildContent(BuildContext context, int streak, List<_Badge> badges) {
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The streak card — the headline number, front and center.
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradientFor(Theme.of(context).brightness),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.surfaceBorder.withValues(alpha: 0.9),
              ),
            ),
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final textColor = isDark ? Colors.white : AppTheme.textDark;
                return Column(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: streak > 0 ? Colors.orange : textColor.withValues(alpha: 0.3),
                      size: 44,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$streak',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      streak == 1 ? 'day streak' : 'day streak',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.75),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      streak == 0
                          ? 'Log a mood, entry, or session today to start one.'
                          : 'Keep it going — check in today to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Badges', style: Theme.of(context).textTheme.titleLarge),
              Text(
                '$unlockedCount / ${badges.length} unlocked',
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: badges.map((badge) => _BadgeTile(badge: badge)).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final _Badge badge;

  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final locked = !badge.isUnlocked;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badge.isUnlocked
              ? AppTheme.primary.withValues(alpha: 0.4)
              : AppTheme.surfaceBorder.withValues(alpha: 0.6),
          width: badge.isUnlocked ? 1.4 : 1,
        ),
      ),
      child: Opacity(
        opacity: locked ? 0.45 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: badge.isUnlocked ? AppTheme.accentGradient : null,
                color: badge.isUnlocked
                    ? null
                    : AppTheme.surfaceAlt.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                locked ? Icons.lock_outline : badge.icon,
                color: badge.isUnlocked ? Colors.white : AppTheme.textLight,
                size: 22,
              ),
            ),
            const Spacer(),
            Text(
              badge.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}