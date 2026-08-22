import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/journal_entry_model.dart';
import '../models/meditation_session_model.dart';
import '../models/mood_log_model.dart';
import '../models/wellness_assessment_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';

class _Badge {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final int progress;
  final int target;

  const _Badge({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.progress,
    required this.target,
  });
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final uniqueDays = dates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final daysSinceLast = todayOnly.difference(uniqueDays.first).inDays;
    if (daysSinceLast > 1) return 0;

    var streak = 1;
    for (var index = 0; index < uniqueDays.length - 1; index++) {
      final difference =
          uniqueDays[index].difference(uniqueDays[index + 1]).inDays;
      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int _progress(int value, int target) => value.clamp(0, target).toInt();

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
      appBar: AppBar(title: const Text('Your wins')),
      body: SafeArea(
        child: StreamBuilder<List<MoodLogModel>>(
          stream: firestoreService.moodLogsForUser(uid),
          builder: (context, moodSnapshot) {
            if (moodSnapshot.hasError) return _buildErrorState();

            return StreamBuilder<List<JournalEntryModel>>(
              stream: firestoreService.journalEntriesForUser(uid),
              builder: (context, journalSnapshot) {
                if (journalSnapshot.hasError) return _buildErrorState();

                return StreamBuilder<List<MeditationSessionModel>>(
                  stream: firestoreService.meditationSessionsForUser(uid),
                  builder: (context, meditationSnapshot) {
                    if (meditationSnapshot.hasError) return _buildErrorState();

                    return StreamBuilder<List<WellnessAssessmentModel>>(
                      stream: firestoreService.wellnessAssessmentsForUser(uid),
                      builder: (context, wellnessSnapshot) {
                        if (wellnessSnapshot.hasError) {
                          return _buildErrorState();
                        }

                        final isLoading =
                            moodSnapshot.connectionState ==
                                ConnectionState.waiting ||
                            journalSnapshot.connectionState ==
                                ConnectionState.waiting ||
                            meditationSnapshot.connectionState ==
                                ConnectionState.waiting ||
                            wellnessSnapshot.connectionState ==
                                ConnectionState.waiting;

                        if (isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final moods = moodSnapshot.data ?? const <MoodLogModel>[];
                        final journalEntries =
                            journalSnapshot.data ?? const <JournalEntryModel>[];
                        final meditationSessions = meditationSnapshot.data ??
                            const <MeditationSessionModel>[];
                        final assessments = wellnessSnapshot.data ??
                            const <WellnessAssessmentModel>[];

                        final allDates = <DateTime>[
                          ...moods.map((mood) => mood.date),
                          ...journalEntries.map((entry) => entry.date),
                          ...meditationSessions.map((session) => session.date),
                          ...assessments.map((assessment) => assessment.date),
                        ];

                        final streak = _calculateStreak(allDates);
                        final badges = _buildBadges(
                          moodCount: moods.length,
                          journalCount: journalEntries.length,
                          meditationCount: meditationSessions.length,
                          wellnessCount: assessments.length,
                          streak: streak,
                        );

                        return _buildContent(
                          context,
                          streak,
                          badges,
                        );
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

  List<_Badge> _buildBadges({
    required int moodCount,
    required int journalCount,
    required int meditationCount,
    required int wellnessCount,
    required int streak,
  }) {
    return [
      _Badge(
        title: 'First check-in',
        description: 'You started noticing how you feel.',
        icon: Icons.mood_rounded,
        isUnlocked: moodCount >= 1,
        progress: _progress(moodCount, 1),
        target: 1,
      ),
      _Badge(
        title: 'First entry',
        description: 'You made space to reflect.',
        icon: Icons.book_outlined,
        isUnlocked: journalCount >= 1,
        progress: _progress(journalCount, 1),
        target: 1,
      ),
      _Badge(
        title: 'First session',
        description: 'You tried a guided meditation.',
        icon: Icons.self_improvement_rounded,
        isUnlocked: meditationCount >= 1,
        progress: _progress(meditationCount, 1),
        target: 1,
      ),
      _Badge(
        title: 'Self-aware',
        description: 'You completed a wellness reflection.',
        icon: Icons.favorite_border_rounded,
        isUnlocked: wellnessCount >= 1,
        progress: _progress(wellnessCount, 1),
        target: 1,
      ),
      _Badge(
        title: 'Reflective',
        description: 'Five private entries completed.',
        icon: Icons.edit_note_rounded,
        isUnlocked: journalCount >= 5,
        progress: _progress(journalCount, 5),
        target: 5,
      ),
      _Badge(
        title: 'Centered',
        description: 'Ten meditation sessions completed.',
        icon: Icons.spa_outlined,
        isUnlocked: meditationCount >= 10,
        progress: _progress(meditationCount, 10),
        target: 10,
      ),
      _Badge(
        title: 'Three-day showing up',
        description: 'You showed up three days in a row.',
        icon: Icons.local_fire_department_rounded,
        isUnlocked: streak >= 3,
        progress: _progress(streak, 3),
        target: 3,
      ),
      _Badge(
        title: 'Seven-day showing up',
        description: 'A full week of returning to yourself.',
        icon: Icons.local_fire_department_rounded,
        isUnlocked: streak >= 7,
        progress: _progress(streak, 7),
        target: 7,
      ),
      _Badge(
        title: 'Thirty-day showing up',
        description: 'A month of consistent care.',
        icon: Icons.emoji_events_rounded,
        isUnlocked: streak >= 30,
        progress: _progress(streak, 30),
        target: 30,
      ),
    ];
  }

  Widget _buildContent(
    BuildContext context,
    int streak,
    List<_Badge> badges,
  ) {
    final unlocked = badges.where((badge) => badge.isUnlocked).toList();
    final locked = badges.where((badge) => !badge.isUnlocked).toList();
    final next = locked.isEmpty ? null : locked.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWinsHero(unlocked.length, badges.length, streak),
          const SizedBox(height: 22),
          if (next != null) ...[
            const Text(
              'Next little win',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _buildNextWin(context, next),
            const SizedBox(height: 24),
          ],
          if (unlocked.isNotEmpty) ...[
            const Text(
              'Unlocked',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: unlocked.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) => _UnlockedBadgeCard(
                  badge: unlocked[index],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            'All milestones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) => _BadgeTile(badge: badges[index]),
          ),
          const SizedBox(height: 18),
          const Text(
            'No punishment for missed days. Come back when you are ready.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textLight, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWinsHero(int unlocked, int total, int streak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientLight,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR WINS',
                  style: TextStyle(
                    color: Color(0xFF806B59),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  '$unlocked of $total milestones unlocked',
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  streak == 0
                      ? 'Your next step can be small.'
                      : '$streak-day showing-up run. Keep it gentle.',
                  style: const TextStyle(
                    color: Color(0xFF59646F),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.68),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '✦',
              style: TextStyle(color: AppTheme.primary, fontSize: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextWin(BuildContext context, _Badge badge) {
    final progress = badge.target == 0 ? 0.0 : badge.progress / badge.target;

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
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(badge.icon, color: AppTheme.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  badge.description,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0, 1),
                          minHeight: 7,
                          backgroundColor: AppTheme.surfaceBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      '${badge.progress}/${badge.target}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Your wins could not load right now. Check your connection and try again.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.danger),
        ),
      ),
    );
  }
}

class _UnlockedBadgeCard extends StatelessWidget {
  final _Badge badge;

  const _UnlockedBadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: AppTheme.accentGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(badge.icon, color: Colors.white, size: 21),
          ),
          const Spacer(),
          Text(
            badge.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          const Text(
            'Unlocked',
            style: TextStyle(color: AppTheme.primary, fontSize: 11),
          ),
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
      padding: const EdgeInsets.all(14),
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
        opacity: locked ? 0.58 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: badge.isUnlocked ? AppTheme.accentGradient : null,
                color: badge.isUnlocked
                    ? null
                    : AppTheme.surfaceAlt.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                locked ? Icons.lock_outline : badge.icon,
                color: badge.isUnlocked ? Colors.white : AppTheme.textLight,
                size: 21,
              ),
            ),
            const Spacer(),
            Text(
              badge.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
