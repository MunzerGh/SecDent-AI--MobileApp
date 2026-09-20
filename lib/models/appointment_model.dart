class AppointmentModel {
  final int appointmentId;
  final int patientId;
  final String patientName;
  final String time;
  final String? phone;
  final String treatmentType;
  final String status;

  AppointmentModel({
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.time,
    this.phone,
    required this.treatmentType,
    required this.status,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      appointmentId: json['appointment_id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      patientName: json['patient_name'] ?? 'بدون اسم',
      time: json['appointment_time'] ?? '',
      phone: json['phone'],
      treatmentType: json['description'] ?? 'لم يحدد بعد',
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'patient_name': patientName,
      'appointment_time': time,
      'phone': phone,
      'description': treatmentType,
      'status': status,
    };
  }
}