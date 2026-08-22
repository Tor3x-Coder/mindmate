class FeedbackRecordModel {
  final String id;
  final String uid;
  final String moodLabel;
  final String moodEmoji;
  final String? moodImpact;
  final String activityId;
  final String activityTitle;
  final String feedback;
  final DateTime date;

  FeedbackRecordModel({
    required this.id,
    required this.uid,
    required this.moodLabel,
    required this.moodEmoji,
    this.moodImpact,
    required this.activityId,
    required this.activityTitle,
    required this.feedback,
    required this.date,
  });

  factory FeedbackRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return FeedbackRecordModel(
      id: id,
      uid: map['uid'] ?? '',
      moodLabel: map['moodLabel'] ?? '',
      moodEmoji: map['moodEmoji'] ?? '',
      moodImpact: map['moodImpact'],
      activityId: map['activityId'] ?? '',
      activityTitle: map['activityTitle'] ?? '',
      feedback: map['feedback'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'moodLabel': moodLabel,
      'moodEmoji': moodEmoji,
      'moodImpact': moodImpact,
      'activityId': activityId,
      'activityTitle': activityTitle,
      'feedback': feedback,
      'date': date.toIso8601String(),
    };
  }
}
