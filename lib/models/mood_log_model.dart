class MoodLogModel {
  final String id;
  final String uid;
  final String emoji;
  final String label;
  final String note;
  final DateTime date;

  MoodLogModel({
    required this.id,
    required this.uid,
    required this.emoji,
    required this.label,
    this.note = '',
    required this.date,
  });

  factory MoodLogModel.fromMap(Map<String, dynamic> map, String id) {
    return MoodLogModel(
      id: id,
      uid: map['uid'] ?? '',
      emoji: map['emoji'] ?? '😐',
      label: map['label'] ?? '',
      note: map['note'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'emoji': emoji,
      'label': label,
      'note': note,
      'date': date.toIso8601String(),
    };
  }
}
