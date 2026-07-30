import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mood_log_model.dart';
import '../../models/journal_entry_model.dart';
import '../../models/wellness_assessment_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

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
      appBar: AppBar(
        title: const Text('Your Progress'),
      ),
      // Three streams (mood, wellness, journal) are combined below so the
      // whole screen updates live as new entries come in.
      body: SafeArea(
        child: StreamBuilder<List<MoodLogModel>>(
          stream: firestoreService.moodLogsForUser(uid),
          builder: (context, moodSnapshot) {
            return StreamBuilder<List<WellnessAssessmentModel>>(
              stream: firestoreService.wellnessAssessmentsForUser(uid),
              builder: (context, wellnessSnapshot) {
                return StreamBuilder<List<JournalEntryModel>>(
                  stream: firestoreService.journalEntriesForUser(uid),
                  builder: (context, journalSnapshot) {
                    final isLoading = moodSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        wellnessSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        journalSnapshot.connectionState ==
                            ConnectionState.waiting;

                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final moods = moodSnapshot.data ?? [];
                    final assessments = wellnessSnapshot.data ?? [];
                    final journalEntries = journalSnapshot.data ?? [];

                    if (moods.isEmpty &&
                        assessments.isEmpty &&
                        journalEntries.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildProgressView(
                      moods: moods,
                      assessments: assessments,
                      journalEntries: journalEntries,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.show_chart, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No data yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check in with your mood, journal, or take a wellness '
              'assessment to start seeing your progress here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressView({
    required List<MoodLogModel> moods,
    required List<WellnessAssessmentModel> assessments,
    required List<JournalEntryModel> journalEntries,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryRow(
            moodCount: moods.length,
            journalCount: journalEntries.length,
            assessmentCount: assessments.length,
          ),
          const SizedBox(height: 24),

          if (assessments.isNotEmpty) ...[
            const Text(
              'Wellness Score Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildWellnessTrend(assessments),
            const SizedBox(height: 28),
          ],

          if (moods.isNotEmpty) ...[
            const Text(
              'Recent Moods',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildRecentMoods(moods),
            const SizedBox(height: 28),
          ],

          if (journalEntries.isNotEmpty) ...[
            const Text(
              'Journal Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'You\'ve written ${journalEntries.length} '
              '${journalEntries.length == 1 ? 'entry' : 'entries'} so far.',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  // Three little stat cards across the top.
  Widget _buildSummaryRow({
    required int moodCount,
    required int journalCount,
    required int assessmentCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Mood Logs',
            value: '$moodCount',
            color: const Color(0xFF5B9A8B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Journal Entries',
            value: '$journalCount',
            color: const Color(0xFF9B8ECF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Assessments',
            value: '$assessmentCount',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  // A simple bar-per-entry trend view. No charting package needed —
  // each bar's height is just proportional to that day's score.
  Widget _buildWellnessTrend(List<WellnessAssessmentModel> assessments) {
    // Streams come back newest-first; reverse so the trend reads left
    // (oldest) to right (most recent), and cap at the most recent 10.
    final recent = assessments.reversed.toList();
    final display =
        recent.length > 10 ? recent.sublist(recent.length - 10) : recent;

    return Container(
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: display.map((assessment) {
          final score = assessment.overallScorePercent;
          final barColor = score >= 70
              ? Colors.green
              : (score >= 40 ? Colors.orange : Colors.red);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: (score / 100) * 80,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Shows the last several mood emojis in a row so patterns are easy
  // to spot at a glance.
  Widget _buildRecentMoods(List<MoodLogModel> moods) {
    final display = moods.length > 14 ? moods.sublist(0, 14) : moods;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: display.map((mood) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF5B9A8B).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(mood.emoji, style: const TextStyle(fontSize: 22)),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}