class ProfessionalModel {
  final String id;
  final String fullName;
  final String category;
  final String bio;
  final String contactEmail;
  final String contactPhone;
  final String photoUrl;
  final bool offersOnline;
  final bool offersPhysical;
  final String location;

  ProfessionalModel({
    required this.id,
    required this.fullName,
    required this.category,
    this.bio = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.photoUrl = '',
    this.offersOnline = false,
    this.offersPhysical = false,
    this.location = '',
  });

  factory ProfessionalModel.fromMap(Map<String, dynamic> map, String id) {
    return ProfessionalModel(
      id: id,
      fullName: map['fullName'] ?? '',
      category: map['category'] ?? '',
      bio: map['bio'] ?? '',
      contactEmail: map['contactEmail'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      offersOnline: map['offersOnline'] ?? false,
      offersPhysical: map['offersPhysical'] ?? false,
      location: map['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'category': category,
      'bio': bio,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'photoUrl': photoUrl,
      'offersOnline': offersOnline,
      'offersPhysical': offersPhysical,
      'location': location,
    };
  }
}
