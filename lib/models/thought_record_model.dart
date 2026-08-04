class ThoughtRecordModel {
  final String id;
  final String uid;
  final String situation;
  final String automaticThought;
  final int intensityBefore;
  final String evidenceFor;
  final String evidenceAgainst;
  final String balancedThought;
  final int intensityAfter;
  final DateTime date;

  ThoughtRecordModel({
    required this.id,
    required this.uid,
    required this.situation,
    required this.automaticThought,
    required this.intensityBefore,
    required this.evidenceFor,
    required this.evidenceAgainst,
    required this.balancedThought,
    required this.intensityAfter,
    required this.date,
  });

  factory ThoughtRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return ThoughtRecordModel(
      id: id,
      uid: map['uid'] ?? '',
      situation: map['situation'] ?? '',
      automaticThought: map['automaticThought'] ?? '',
      intensityBefore: map['intensityBefore'] ?? 5,
      evidenceFor: map['evidenceFor'] ?? '',
      evidenceAgainst: map['evidenceAgainst'] ?? '',
      balancedThought: map['balancedThought'] ?? '',
      intensityAfter: map['intensityAfter'] ?? 5,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'situation': situation,
      'automaticThought': automaticThought,
      'intensityBefore': intensityBefore,
      'evidenceFor': evidenceFor,
      'evidenceAgainst': evidenceAgainst,
      'balancedThought': balancedThought,
      'intensityAfter': intensityAfter,
      'date': date.toIso8601String(),
    };
  }
}