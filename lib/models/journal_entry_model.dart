class JournalEntryModel {
  final String id;
  final String uid;
  final String prompt;
  final String content;
  final DateTime date;

  JournalEntryModel({
    required this.id,
    required this.uid,
    this.prompt = '',
    required this.content,
    required this.date,
  });

  factory JournalEntryModel.fromMap(Map<String, dynamic> map, String id) {
    return JournalEntryModel(
      id: id,
      uid: map['uid'] ?? '',
      prompt: map['prompt'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'prompt': prompt,
      'content': content,
      'date': date.toIso8601String(),
    };
  }
}
