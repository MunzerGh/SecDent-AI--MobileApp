class Patient {
  final int? patientId;
  final String? fullName;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? medicalHistory;

  Patient({
    this.patientId = 0,
    this.fullName = 'غير محدد',
    this.phone = 'غير محدد',
    this.dateOfBirth = 'غير محدد',
    this.gender = 'غير محدد',
    this.medicalHistory = 'لا يوجد',
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patient_id'] ?? 0,
      fullName: json['full_name'] ?? 'غير محدد',
      phone: json['phone'] ?? 'غير محدد',
      dateOfBirth: json['date_of_birth'] ?? 'غير محدد',
      gender: json['gender'] ?? 'غير محدد',
      medicalHistory: json['medical_history'] ?? 'لا يوجد تاريخ طبي',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'full_name': fullName,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'medical_history': medicalHistory,
    };
  }
}