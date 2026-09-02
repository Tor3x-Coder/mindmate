import 'package:flutter_test/flutter_test.dart';

import 'package:mindmate/models/feedback_record_model.dart';
import 'package:mindmate/models/journal_entry_model.dart';
import 'package:mindmate/models/mood_log_model.dart';
import 'package:mindmate/models/wellness_assessment_model.dart';
import 'package:mindmate/utils/weekly_insight.dart';

void main() {
  final now = DateTime(2026, 9, 2, 12);

  test('summarises the recent week and leaves older data out', () {
    final insight = WeeklyInsight.fromData(
      now: now,
      moods: [
        MoodLogModel(
          id: 'mood-1',
          uid: 'demo',
          emoji: '😣',
          label: 'Stressed',
          impactLabel: 'A lot',
          date: DateTime(2026, 8, 30, 18),
        ),
        MoodLogModel(
          id: 'mood-2',
          uid: 'demo',
          emoji: '😔',
          label: 'Sad',
          impactLabel: 'Somewhat',
          date: DateTime(2026, 8, 31, 18),
        ),
        MoodLogModel(
          id: 'mood-old',
          uid: 'demo',
          emoji: '😐',
          label: 'Okay',
          impactLabel: 'A little',
          date: DateTime(2026, 8, 20, 18),
        ),
      ],
      journalEntries: [
        JournalEntryModel(
          id: 'journal-1',
          uid: 'demo',
          content: 'One small step is enough for today.',
          date: DateTime(2026, 9, 1, 20),
        ),
        JournalEntryModel(
          id: 'journal-old',
          uid: 'demo',
          content: 'An older note.',
          date: DateTime(2026, 8, 20, 20),
        ),
      ],
      assessments: [
        WellnessAssessmentModel(
          id: 'assessment-1',
          uid: 'demo',
          sleepHours: 7,
          exercised: true,
          drankEnoughWater: true,
          stressLevel: 5,
          socialized: true,
          ateHealthyMeals: true,
          date: DateTime(2026, 8, 29, 19),
        ),
      ],
      feedbackRecords: [
        FeedbackRecordModel(
          id: 'feedback-1',
          uid: 'demo',
          moodLabel: 'Stressed',
          moodEmoji: '😣',
          moodImpact: 'A lot',
          activityId: 'breathing',
          activityTitle: 'A short breathing reset',
          feedback: 'A little better',
          date: DateTime(2026, 8, 30, 19),
        ),
        FeedbackRecordModel(
          id: 'feedback-old',
          uid: 'demo',
          moodLabel: 'Sad',
          moodEmoji: '😔',
          moodImpact: 'Somewhat',
          activityId: 'journal',
          activityTitle: 'Write it out',
          feedback: 'A little better',
          date: DateTime(2026, 8, 20, 19),
        ),
      ],
    );

    expect(insight.checkInCount, 2);
    expect(insight.journalCount, 1);
    expect(insight.reflectionCount, 1);
    expect(insight.hardestDay, 'Sunday');
    expect(insight.hardestMood, 'Stressed');
    expect(insight.practicesAfterHardCheckIns, ['A short breathing reset']);
    expect(insight.headline, 'You made room to notice how you are doing.');
    expect(insight.observation, contains('Sunday'));
    expect(insight.practiceObservation, contains('A short breathing reset'));
  });

  test('uses a calm empty state without inventing a pattern', () {
    final insight = WeeklyInsight.fromData(
      now: now,
      moods: const [],
      journalEntries: const [],
      assessments: const [],
      feedbackRecords: const [],
    );

    expect(insight.hasActivity, isFalse);
    expect(insight.headline, 'Your week can start small.');
    expect(insight.hardestDay, isNull);
    expect(insight.hardestMood, isNull);
    expect(insight.practiceObservation, contains('After a harder check-in'));
  });
}
