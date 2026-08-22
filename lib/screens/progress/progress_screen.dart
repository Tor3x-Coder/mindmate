import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/journal_entry_model.dart';
import '../../models/mood_log_model.dart';
import '../../models/wellness_assessment_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final firestoreService = context.watch<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to see your progress.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your progress')),
      body: SafeArea(
        child: StreamBuilder<List<MoodLogModel>>(
          stream: firestoreService.moodLogsForUser(uid),
          builder: (context, moodSnapshot) {
            if (moodSnapshot.hasError) return _buildErrorState();

            return StreamBuilder<List<WellnessAssessmentModel>>(
              stream: firestoreService.wellnessAssessmentsForUser(uid),
              builder: (context, wellnessSnapshot) {
                if (wellnessSnapshot.hasError) return _buildErrorState();

                return StreamBuilder<List<JournalEntryModel>>(
                  stream: firestoreService.journalEntriesForUser(uid),
                  builder: (context, journalSnapshot) {
                    if (journalSnapshot.hasError) return _buildErrorState();

                    final isLoading =
                        moodSnapshot.connectionState == ConnectionState.waiting ||
                        wellnessSnapshot.connectionState == ConnectionState.waiting ||
                        journalSnapshot.connectionState == ConnectionState.waiting;

                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return _buildProgressView(
                      context: context,
                      moods: moodSnapshot.data ?? const <MoodLogModel>[],
                      assessments: wellnessSnapshot.data ??
                          const <WellnessAssessmentModel>[],
                      journalEntries: journalSnapshot.data ??
                          const <JournalEntryModel>[],
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

  Widget _buildProgressView({
    required BuildContext context,
    required List<MoodLogModel> moods,
    required List<WellnessAssessmentModel> assessments,
    required List<JournalEntryModel> journalEntries,
  }) {
    final weekMoodCount = _countThisWeek(moods.map((mood) => mood.date));
    final weekJournalCount =
        _countThisWeek(journalEntries.map((entry) => entry.date));
    final weekAssessmentCount =
        _countThisWeek(assessments.map((assessment) => assessment.date));
    final hasAnyData =
        moods.isNotEmpty || assessments.isNotEmpty || journalEntries.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWeeklyStory(
            hasAnyData: hasAnyData,
            moodCount: weekMoodCount,
            journalCount: weekJournalCount,
            assessmentCount: weekAssessmentCount,
          ),
          const SizedBox(height: 24),
          _buildObservationCard(moods, journalEntries),
          const SizedBox(height: 14),
          _buildHelpfulCard(),
          if (moods.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildMoodTrail(context, moods),
          ],
          if (assessments.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildWellnessReflectionCard(assessments),
          ],
        ],
      ),
    );
  }

  int _countThisWeek(Iterable<DateTime> dates) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    return dates.where((date) => !date.isBefore(start)).length;
  }

  Widget _buildWeeklyStory({
    required bool hasAnyData,
    required int moodCount,
    required int journalCount,
    required int assessmentCount,
  }) {
    final summary = hasAnyData
        ? 'You made space for yourself this week.'
        : 'Your story can start with one small check-in.';

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
                  'THIS WEEK',
                  style: TextStyle(
                    color: Color(0xFF59646F),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  summary,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$moodCount check-ins  •  $journalCount journal entries  •  $assessmentCount reflections',
                  style: const TextStyle(
                    color: Color(0xFF59646F),
                    fontSize: 12,
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
              color: Colors.white.withValues(alpha: 0.62),
              shape: BoxShape.circle,
            ),
            child: const Text('✦', style: TextStyle(fontSize: 28, color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationCard(
    List<MoodLogModel> moods,
    List<JournalEntryModel> journalEntries,
  ) {
    final observation = moods.isNotEmpty
        ? 'Your most recent check-in was ${moods.first.label.toLowerCase()}. Keep noticing without judging yourself.'
        : journalEntries.isNotEmpty
            ? 'You have made space to reflect. Keep checking in when it feels useful.'
            : 'As you check in, MindMate will help you notice patterns over time.';

    return _ProgressCard(
      eyebrow: 'WHAT YOU\'VE NOTICED',
      icon: Icons.insights_outlined,
      iconColor: AppTheme.primary,
      title: observation,
      subtitle: 'These are observations from your entries, not diagnoses.',
    );
  }

  Widget _buildHelpfulCard() {
    return const _ProgressCard(
      eyebrow: 'WHAT SEEMS HELPFUL',
      icon: Icons.auto_awesome_outlined,
      iconColor: AppTheme.secondary,
      title: 'We are still learning this with you.',
      subtitle:
          'After a practice, tell MindMate whether it felt better, the same, worse, or unclear.',
      trailing: Text(
        'Feedback will make future suggestions more personal.',
        style: TextStyle(
          color: AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMoodTrail(BuildContext context, List<MoodLogModel> moods) {
    final display = moods.take(7).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent mood trail',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: display
                      .map(
                        (mood) => Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textLight,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWellnessReflectionCard(
    List<WellnessAssessmentModel> assessments,
  ) {
    return _ProgressCard(
      eyebrow: 'WELLNESS REFLECTIONS',
      icon: Icons.favorite_outline_rounded,
      iconColor: AppTheme.danger,
      title: '${assessments.length} reflection${assessments.length == 1 ? '' : 's'} saved',
      subtitle:
          'Use these check-ins to notice how your routines and feelings change over time.',
      trailing: const Text(
        'Not a medical score or diagnosis.',
        style: TextStyle(
          color: AppTheme.textLight,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Your progress could not load right now. Check your connection and try again.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.danger),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String eyebrow;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _ProgressCard({
    required this.eyebrow,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
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
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 10),
                  trailing!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
