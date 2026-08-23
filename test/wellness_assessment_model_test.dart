import 'package:flutter_test/flutter_test.dart';
import 'package:mindmate/models/wellness_assessment_model.dart';

WellnessAssessmentModel assessment({
  double sleepHours = 7,
  int stressLevel = 5,
  bool exercised = true,
  bool drankEnoughWater = true,
  bool socialized = true,
  bool ateHealthyMeals = true,
}) {
  return WellnessAssessmentModel(
    id: 'assessment-1',
    uid: 'user-1',
    sleepHours: sleepHours,
    exercised: exercised,
    drankEnoughWater: drankEnoughWater,
    stressLevel: stressLevel,
    socialized: socialized,
    ateHealthyMeals: ateHealthyMeals,
    date: DateTime(2026, 8, 23),
  );
}

void main() {
  group('WellnessAssessmentModel.overallScorePercent', () {
    test('returns the expected bounded score for normal input', () {
      expect(
        assessment(sleepHours: 8, stressLevel: 1).overallScorePercent,
        98,
      );
    });

    test('caps impossible positive component values at 100', () {
      expect(
        assessment(sleepHours: 100, stressLevel: -5).overallScorePercent,
        100,
      );
    });

    test('caps impossible negative component values at zero', () {
      final score = assessment(
        sleepHours: -4,
        stressLevel: 50,
        exercised: false,
        drankEnoughWater: false,
        socialized: false,
        ateHealthyMeals: false,
      ).overallScorePercent;

      expect(score, 30);
      expect(score, inInclusiveRange(0, 100));
    });

    test('never returns outside the display range', () {
      final extremeScores = [
        assessment(sleepHours: -1000, stressLevel: 1000),
        assessment(sleepHours: 1000, stressLevel: -1000),
      ].map((item) => item.overallScorePercent);

      for (final score in extremeScores) {
        expect(score, inInclusiveRange(0, 100));
      }
    });
  });
}
