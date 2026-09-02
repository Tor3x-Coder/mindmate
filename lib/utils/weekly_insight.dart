import '../models/feedback_record_model.dart';
import '../models/journal_entry_model.dart';
import '../models/mood_log_model.dart';
import '../models/wellness_assessment_model.dart';

/// A small, read-only summary of the user's recent activity.
///
/// This is a gentle observation layer, not a clinical score or diagnosis. It
/// uses only the last seven days of data and never writes anything back to
/// Firestore.
class WeeklyInsight {
  final int checkInCount;
  final int journalCount;
  final int reflectionCount;
  final String? hardestDay;
  final String? hardestMood;
  final List<String> practicesAfterHardCheckIns;

  const WeeklyInsight({
    required this.checkInCount,
    required this.journalCount,
    required this.reflectionCount,
    required this.hardestDay,
    required this.hardestMood,
    required this.practicesAfterHardCheckIns,
  });

  bool get hasActivity =>
      checkInCount > 0 || journalCount > 0 || reflectionCount > 0;

  String get headline {
    if (!hasActivity) return 'Your week can start small.';
    if (checkInCount >= 3) return 'You kept making space to check in.';
    if (journalCount > 0 || reflectionCount > 0) {
      return 'You made room to notice how you are doing.';
    }
    return 'You started a record of your week.';
  }

  String get countsLabel =>
      '$checkInCount check-ins  •  $journalCount journal entries  •  $reflectionCount reflections';

  String get observation {
    if (hardestDay == null || hardestMood == null) {
      return 'There is not a clear harder day to call out yet. That is okay—this is about noticing, not grading the week.';
    }

    return 'Your heaviest check-in was on $hardestDay, when you felt ${hardestMood!.toLowerCase()}. Naming a day can make the pattern easier to notice without turning it into a verdict.';
  }

  String get practiceObservation {
    if (practicesAfterHardCheckIns.isEmpty) {
      return 'After a harder check-in, try a practice and leave a quick note about whether it helped, felt the same, or was unclear.';
    }

    final practices = practicesAfterHardCheckIns.join(' and ');
    return 'After harder check-ins, you tried $practices. Notice what gives you a little more room, without expecting one practice to fix everything.';
  }

  static WeeklyInsight fromData({
    required DateTime now,
    required List<MoodLogModel> moods,
    required List<JournalEntryModel> journalEntries,
    required List<WellnessAssessmentModel> assessments,
    required List<FeedbackRecordModel> feedbackRecords,
  }) {
    final start = now.subtract(const Duration(days: 6));
    final recentMoods = moods.where((mood) => _inWindow(mood.date, start, now));
    final recentJournals =
        journalEntries.where((entry) => _inWindow(entry.date, start, now));
    final recentAssessments = assessments
        .where((assessment) => _inWindow(assessment.date, start, now));
    final recentFeedback = feedbackRecords
        .where((feedback) => _inWindow(feedback.date, start, now))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final difficultMoods = recentMoods.where(_isDifficultMood).toList();
    final hardest = _hardestDay(difficultMoods);
    final practices = <String>[];
    for (final feedback in recentFeedback) {
      final followsHardCheckIn = _isDifficultMoodLabel(feedback.moodLabel) ||
          feedback.moodImpact == 'A lot' ||
          feedback.moodImpact == 'Overwhelming';
      final title = feedback.activityTitle.trim();
      if (followsHardCheckIn &&
          title.isNotEmpty &&
          !practices.contains(title)) {
        practices.add(title);
      }
      if (practices.length == 2) break;
    }

    return WeeklyInsight(
      checkInCount: recentMoods.length,
      journalCount: recentJournals.length,
      reflectionCount: recentAssessments.length,
      hardestDay: hardest?.day,
      hardestMood: hardest?.mood,
      practicesAfterHardCheckIns: practices,
    );
  }

  static bool _inWindow(DateTime date, DateTime start, DateTime now) {
    return !date.isBefore(start) && !date.isAfter(now);
  }

  static bool _isDifficultMood(MoodLogModel mood) =>
      _isDifficultMoodLabel(mood.label);

  static bool _isDifficultMoodLabel(String label) =>
      const {'Sad', 'Stressed', 'Angry', 'Tired'}.contains(label);

  static _HardestDay? _hardestDay(List<MoodLogModel> moods) {
    if (moods.isEmpty) return null;

    final grouped = <String, List<MoodLogModel>>{};
    for (final mood in moods) {
      final localDate = mood.date.toLocal();
      final key = '${localDate.year}-${localDate.month}-${localDate.day}';
      grouped.putIfAbsent(key, () => []).add(mood);
    }

    String? selectedKey;
    var selectedScore = -1;
    var selectedCount = -1;
    DateTime? selectedDate;
    for (final entry in grouped.entries) {
      final score = entry.value.fold<int>(
        0,
        (total, mood) => total + _moodWeight(mood.label),
      );
      final date = entry.value
          .map((mood) => mood.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      if (score > selectedScore ||
          (score == selectedScore && entry.value.length > selectedCount) ||
          (score == selectedScore &&
              entry.value.length == selectedCount &&
              (selectedDate == null || date.isAfter(selectedDate)))) {
        selectedKey = entry.key;
        selectedScore = score;
        selectedCount = entry.value.length;
        selectedDate = date;
      }
    }

    final selectedMoods = grouped[selectedKey]!;
    selectedMoods.sort((a, b) => b.date.compareTo(a.date));
    final localDate = selectedDate!.toLocal();
    final weekday = _weekdayName(localDate.weekday);
    return _HardestDay(
      day: weekday,
      mood: selectedMoods.first.label,
    );
  }

  static int _moodWeight(String label) {
    switch (label) {
      case 'Stressed':
      case 'Angry':
        return 3;
      case 'Sad':
        return 2;
      case 'Tired':
        return 1;
      default:
        return 0;
    }
  }

  static String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday - 1];
  }
}

class _HardestDay {
  final String day;
  final String mood;

  const _HardestDay({required this.day, required this.mood});
}
