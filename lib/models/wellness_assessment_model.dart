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

  // Simple scoring logic — we'll refine this when we build the Rule Engine
  int get overallScorePercent {
    int sleepScore = sleepHours >= 7 ? 100 : (sleepHours / 7 * 100).round();
    int stressScore = ((10 - stressLevel) / 10 * 100).round();
    int exerciseScore = exercised ? 100 : 40;
    int waterScore = drankEnoughWater ? 100 : 40;
    int socialScore = socialized ? 100 : 60;
    int foodScore = ateHealthyMeals ? 100 : 40;

    return ((sleepScore +
                stressScore +
                exerciseScore +
                waterScore +
                socialScore +
                foodScore) /
            6)
        .round();
  }

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
