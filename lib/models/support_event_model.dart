class SupportEventModel {
  final String id;
  final String uid;
  final String actionLabel;
  final String detail;
  final String? followUp;
  final DateTime createdAt;

  SupportEventModel({
    required this.id,
    required this.uid,
    required this.actionLabel,
    this.detail = '',
    this.followUp,
    required this.createdAt,
  });

  factory SupportEventModel.fromMap(Map<String, dynamic> map, String id) {
    return SupportEventModel(
      id: id,
      uid: map['uid'] ?? '',
      actionLabel: map['actionLabel'] ?? '',
      detail: map['detail'] ?? '',
      followUp: map['followUp'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'actionLabel': actionLabel,
      'detail': detail,
      'followUp': followUp,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
