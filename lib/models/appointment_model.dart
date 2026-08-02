class AppointmentModel {
  final String id;
  final String uid;
  final String professionalId;
  final String professionalName;
  final String consultationType; // 'Online' or 'Physical'
  final String preferredDate; // stored as YYYY-MM-DD for simple display
  final String preferredTime; // stored as HH:mm
  final String note;
  final String status; // 'pending', 'approved', or 'declined'
  final DateTime requestedAt;

  AppointmentModel({
    required this.id,
    required this.uid,
    required this.professionalId,
    required this.professionalName,
    required this.consultationType,
    required this.preferredDate,
    required this.preferredTime,
    this.note = '',
    this.status = 'pending',
    required this.requestedAt,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      uid: map['uid'] ?? '',
      professionalId: map['professionalId'] ?? '',
      professionalName: map['professionalName'] ?? '',
      consultationType: map['consultationType'] ?? 'Online',
      preferredDate: map['preferredDate'] ?? '',
      preferredTime: map['preferredTime'] ?? '',
      note: map['note'] ?? '',
      status: map['status'] ?? 'pending',
      requestedAt:
          DateTime.tryParse(map['requestedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'professionalId': professionalId,
      'professionalName': professionalName,
      'consultationType': consultationType,
      'preferredDate': preferredDate,
      'preferredTime': preferredTime,
      'note': note,
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
    };
  }
}
