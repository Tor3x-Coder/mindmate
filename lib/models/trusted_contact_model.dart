class TrustedContactModel {
  final String id;
  final String uid;
  final String name;
  final String relationship;
  final String phone;
  final DateTime createdAt;

  TrustedContactModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.relationship,
    required this.phone,
    required this.createdAt,
  });

  factory TrustedContactModel.fromMap(Map<String, dynamic> map, String id) {
    return TrustedContactModel(
      id: id,
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      phone: map['phone'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
