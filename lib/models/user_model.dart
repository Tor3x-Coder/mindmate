class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final int? age;
  final String? gender;
  final List<String> goals;
  final String? reminderTime;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.age,
    this.gender,
    this.goals = const [],
    this.reminderTime,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      age: map['age'],
      gender: map['gender'],
      goals: List<String>.from(map['goals'] ?? []),
      reminderTime: map['reminderTime'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'age': age,
      'gender': gender,
      'goals': goals,
      'reminderTime': reminderTime,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
