import '../models/mood_log_model.dart';
import '../models/wellness_assessment_model.dart';

// Looks across a person's RECENT history (not just one entry) and
// produces a plain-language insight. This is the foundation the AI
// companion chat will build on later — for now it's simple rule-based
// logic, no AI needed, completely free to run.
class PatternInsight {
  final String? message; // null if nothing notable to say
  final bool isConcerning; // true = worth surfacing support options

  const PatternInsight({this.message, this.isConcerning = false});

  static const List<String> _hardMoods = ['Sad', 'Stressed', 'Angry', 'Tired'];

  static PatternInsight fromRecentMoods(List<MoodLogModel> recentMoods) {
    if (recentMoods.length < 2) {
      return const PatternInsight();
    }

    var hardStreak = 0;
    for (final mood in recentMoods) {
      if (_hardMoods.contains(mood.label)) {
        hardStreak++;
      } else {
        break;
      }
    }

    if (hardStreak >= 3) {
      return const PatternInsight(
        message:
            'You\'ve logged a tough few days in a row. That takes real '
            'strength to keep showing up through. It might help to talk '
            'to someone about what\'s been going on.',
        isConcerning: true,
      );
    }

    if (hardStreak == 2) {
      return const PatternInsight(
        message:
            'Two harder days back to back. Be extra gentle with yourself '
            'today.',
      );
    }

    return const PatternInsight();
  }

  static PatternInsight fromRecentAssessments(
    List<WellnessAssessmentModel> recentAssessments,
  ) {
    if (recentAssessments.length < 3) {
      return const PatternInsight();
    }

    final recentScores = recentAssessments
        .take(3)
        .map((a) => a.overallScorePercent)
        .toList();

    final isDeclining =
        recentScores[0] < recentScores[1] && recentScores[1] < recentScores[2];
    final allLow = recentScores.every((s) => s < 45);

    if (isDeclining && allLow) {
      return const PatternInsight(
        message:
            'Your wellness score has been trending down over your last '
            'few check-ins. This is worth paying attention to \u2014 '
            'consider reaching out to someone for support.',
        isConcerning: true,
      );
    }

    if (isDeclining) {
      return const PatternInsight(
        message:
            'Your score has been dipping over your last few check-ins. '
            'Small changes today could help turn that around.',
      );
    }

    if (allLow) {
      return const PatternInsight(
        message:
            'Things have been consistently tough lately. You don\'t have '
            'to carry that alone.',
        isConcerning: true,
      );
    }

    return const PatternInsight();
  }
}