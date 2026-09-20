import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import 'dental_chart_view.dart';
import '../../models/patient_model.dart';

class PatientDentalDetailsScreen extends StatelessWidget {
  final Patient patient;

  const PatientDentalDetailsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('patient_profile_title'.tr),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildPatientInfoCard(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'dental_chart_title'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            DentalChartView(currentPatientId: patient.patientId ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                patient.fullName ?? 'unknown_patient'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          _infoRow(Icons.phone, "${'phone_number_label'.tr}: ${patient.phone ?? 'not_registered'.tr}"),
          _infoRow(Icons.cake, "${'birth_date_label'.tr}: ${patient.dateOfBirth ?? 'not_registered'.tr}"),
          _infoRow(Icons.person, "${'gender_label'.tr}: ${patient.gender ?? 'not_registered'.tr}"),
          _infoRow(Icons.medical_services, "${'medical_history_label'.tr}: ${patient.medicalHistory ?? 'no_medical_history'.tr}"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}