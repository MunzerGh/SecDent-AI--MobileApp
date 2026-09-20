class DoctorModel {
  final String name;
  final String specialization;
  final String profileImage;

  DoctorModel({
    required this.name,
    this.specialization = 'Dentist',
    required this.profileImage,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      name: json['full_name'] ?? json['name'] ?? 'دكتور',
      specialization: json['specialty'] ?? json['specialization'] ?? 'Dentist',
      profileImage: json['profile_image'] ?? json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': name,
      'specialty': specialization,
      'profile_image': profileImage,
    };
  }
}