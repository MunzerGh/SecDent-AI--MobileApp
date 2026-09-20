import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/screens/PatientProfileView.dart';
import '../core/app_colors.dart';

class PatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    bool isMale = (patient['gender'] ?? 'male') == 'male';
    Color accentColor = isMale ? AppColors.maleAccent : AppColors.femaleAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        onTap: () {
          final int actualId = int.tryParse(patient['patient_id'].toString()) ?? 0;
          Get.to(() => PatientProfileView(patientId: actualId));
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: accentColor.withValues(alpha: 0.2),
          child: Icon(Icons.person, color: accentColor),
        ),
        title: Text(
          patient['full_name'] ?? 'unknown_name'.tr,
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w600,
            fontSize: 17,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
          ),
        ),
        trailing: Icon(
          isMale ? Icons.male : Icons.female,
          color: accentColor,
        ),
      ),
    );
  }
}