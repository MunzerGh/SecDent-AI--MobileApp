import 'package:sec_dent_ai/api_config.dart';

class EmergencyCase {
  final int emergencyId;
  final String message;
  final String urgencyLevel;
  final String? xrayImageUrl;
  final DateTime createdAt;
  final int patientId;
  final String patientName;
  final String phoneNumber;
  final String? gender;
  final String? dateOfBirth;
  final String? medicalHistory;

  EmergencyCase({
    required this.emergencyId,
    required this.message,
    required this.urgencyLevel,
    this.xrayImageUrl,
    required this.createdAt,
    required this.patientId,
    required this.patientName,
    required this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.medicalHistory,
  });

  factory EmergencyCase.fromJson(Map<String, dynamic> json) {
    String? rawPath = json['xray_image_url'];
    
    DateTime parsedDate = DateTime.now();
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    return EmergencyCase(
      emergencyId: json['emergency_id'] ?? 0,
      message: json['message'] ?? 'لا يوجد رسالة',
      urgencyLevel: json['urgency_level'] ?? 'normal',
      createdAt: parsedDate,
      patientId: json['patient_id'] ?? 0,
      patientName: json['patient_name'] ?? 'مريض غير معروف',
      phoneNumber: json['phone_number'] ?? 'بدون رقم',
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      medicalHistory: json['medical_history'],
      xrayImageUrl: (rawPath != null && rawPath.isNotEmpty)
          ? (rawPath.startsWith('http')
              ? rawPath
              : '${ApiConfig.baseUrl.endsWith('/') ? ApiConfig.baseUrl : '${ApiConfig.baseUrl}/'}$rawPath')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emergency_id': emergencyId,
      'message': message,
      'urgency_level': urgencyLevel,
      'created_at': createdAt.toIso8601String(),
      'patient_id': patientId,
      'patient_name': patientName,
      'phone_number': phoneNumber,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'medical_history': medicalHistory,
      'xray_image_url': xrayImageUrl,
    };
  }
}