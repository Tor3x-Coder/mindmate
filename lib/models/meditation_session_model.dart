class MeditationSessionModel {
  final String id;
  final String uid;
  final String sessionType; // e.g. "Stress Relief", "Sleep Meditation"
  final int durationMinutes;
  final DateTime date;

  MeditationSessionModel({
    required this.id,
    required this.uid,
    required this.sessionType,
    required this.durationMinutes,
    required this.date,
  });

  factory MeditationSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return MeditationSessionModel(
      id: id,
      uid: map['uid'] ?? '',
      sessionType: map['sessionType'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'sessionType': sessionType,
      'durationMinutes': durationMinutes,
      'date': date.toIso8601String(),
    };
  }
}