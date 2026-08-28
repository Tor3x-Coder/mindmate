class WellnessAssessmentModel {
  final String id;
  final String uid;
  final double sleepHours;
  final bool exercised;
  final bool drankEnoughWater;
  final int stressLevel; // 1 (low) - 10 (high)
  final bool socialized;
  final bool ateHealthyMeals;
  final DateTime date;

  WellnessAssessmentModel({
    required this.id,
    required this.uid,
    required this.sleepHours,
    required this.exercised,
    required this.drankEnoughWater,
    required this.stressLevel,
    required this.socialized,
    required this.ateHealthyMeals,
    required this.date,
  });

  // A gentle prototype reflection score, not a clinical measurement.
  // Every component is clamped so malformed/legacy data can never produce a
  // result below 0 or above 100.
  int get overallScorePercent {
    final sleepScore = _boundedScore(
      sleepHours >= 7 ? 100 : (sleepHours / 7 * 100),
    );
    final stressScore = _boundedScore((10 - stressLevel) / 10 * 100);
    final exerciseScore = exercised ? 100 : 40;
    final waterScore = drankEnoughWater ? 100 : 40;
    final socialScore = socialized ? 100 : 60;
    final foodScore = ateHealthyMeals ? 100 : 40;

    final average = (sleepScore +
            stressScore +
            exerciseScore +
            waterScore +
            socialScore +
            foodScore) /
        6;
    return _boundedScore(average);
  }

  static int _boundedScore(num value) =>
      value.round().clamp(0, 100).toInt();

  factory WellnessAssessmentModel.fromMap(Map<String, dynamic> map, String id) {
    return WellnessAssessmentModel(
      id: id,
      uid: map['uid'] ?? '',
      sleepHours: (map['sleepHours'] ?? 0).toDouble(),
      exercised: map['exercised'] ?? false,
      drankEnoughWater: map['drankEnoughWater'] ?? false,
      stressLevel: map['stressLevel'] ?? 5,
      socialized: map['socialized'] ?? false,
      ateHealthyMeals: map['ateHealthyMeals'] ?? false,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'sleepHours': sleepHours,
      'exercised': exercised,
      'drankEnoughWater': drankEnoughWater,
      'stressLevel': stressLevel,
      'socialized': socialized,
      'ateHealthyMeals': ateHealthyMeals,
      'date': date.toIso8601String(),
    };
  }
}
