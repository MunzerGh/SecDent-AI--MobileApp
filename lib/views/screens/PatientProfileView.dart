import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/PatientProfileControlle.dart';
import '../../controllers/dental_chart_controller.dart';
import '../../core/app_colors.dart';
import '../../widgets/profile_info_row.dart';
import 'BookAppointmentScreen.dart';
import 'dental_chart_view.dart';
import 'patient_xray_screen.dart';
import 'lab_request_screen.dart';

class PatientProfileView extends StatelessWidget {
  final int patientId;
  final PatientProfileController controller = Get.put(PatientProfileController());
  final DentalChartController dentalController = Get.put(DentalChartController());

  PatientProfileView({super.key, required this.patientId}) {
    controller.fetchPatientProfile(patientId);
    dentalController.loadPatientChart(patientId);
  }

  String _formatNumbers(String input) {
    if (Get.locale?.languageCode == 'ar') {
      const englishToArabic = {
        '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
        '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'
      };
      return input.split('').map((char) => englishToArabic[char] ?? char).join();
    }
    return input;
  }

  String _getLocalizedMedicalHistory(String historyValue) {
    if (historyValue.isEmpty || historyValue.trim() == 'no_medical_history'.tr) {
      return 'no_medical_history'.tr;
    }

    if (Get.locale?.languageCode == 'ar') {
      if (historyValue.toLowerCase() == 'diabetes') return 'مرض السكري';
      if (historyValue.toLowerCase() == 'hypertension') return 'ارتفاع ضغط الدم';
      if (historyValue.toLowerCase() == 'normal') return 'سليم / لا يوجد سجل مرضي';
      if (historyValue == 'ضصثق') return 'حالة صحية تجريبية';
    } else {
      if (historyValue == 'ضصثق') return 'Test Disease / Experimental';
      if (historyValue == 'مرض السكري') return 'Diabetes';
      if (historyValue == 'ارتفاع ضغط الدم') return 'Hypertension';
      if (historyValue == 'سليم / لا يوجد سجل مرضي') return 'Normal';
    }

    return historyValue;
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'patient_profile_title'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back, color: AppColors.textMain),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final patient = controller.patientData.value;
          final String gender = (patient.gender ?? '').toLowerCase();
          final bool isFemale = gender.contains('female') || gender.contains('أنثى');

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: isFemale
                        ? const Color(0xFFE63946).withValues(alpha: 0.15)
                        : AppColors.cardBg,
                    child: Icon(
                      isFemale ? Icons.female_rounded : Icons.male_rounded,
                      size: 50,
                      color: isFemale ? AppColors.femaleAccent : AppColors.maleAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  patient.fullName ?? 'unknown_patient'.tr,
                  style: const TextStyle(color: AppColors.textMain, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Divider(color: Colors.white24, height: 40),

                // 🌟 استخدام ProfileInfoRow الموحدة من مجلد الـ widgets
                ProfileInfoRow(
                  label: 'phone_number_label'.tr,
                  value: patient.phone != null ? _formatNumbers(patient.phone!) : 'not_registered'.tr,
                  icon: Icons.phone,
                  isFemale: isFemale,
                ),

                ProfileInfoRow(
                  label: 'birth_date_label'.tr,
                  value: (patient.dateOfBirth != null && patient.dateOfBirth!.length >= 10)
                      ? _formatNumbers(patient.dateOfBirth!.substring(0, 10))
                      : 'not_registered'.tr,
                  icon: Icons.cake,
                  isFemale: isFemale,
                ),

                ProfileInfoRow(
                  label: 'gender_label'.tr,
                  value: isFemale ? 'female_gender'.tr : 'male_gender'.tr,
                  icon: isFemale ? Icons.female_rounded : Icons.male_rounded,
                  isFemale: isFemale,
                ),

                const SizedBox(height: 25),

                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'medical_history_label'.tr,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    _getLocalizedMedicalHistory(patient.medicalHistory ?? ''),
                    style: const TextStyle(color: AppColors.textMain, fontSize: 15, height: 1.4),
                  ),
                ),

                const SizedBox(height: 25),

                InkWell(
                  onTap: () => Get.to(() => PatientXRayScreen(patientId: patientId)),
                  child: _buildActionCard(
                    icon: Icons.blur_on_rounded,
                    title: 'xrays_title'.tr,
                    subtitle: 'xrays_subtitle'.tr,
                    isArabic: isArabic,
                  ),
                ),

                const SizedBox(height: 35),

                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'dental_chart_title'.tr,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                DentalChartView(currentPatientId: patientId),
                const SizedBox(height: 35),

                _buildMainButton(
                  label: 'add_appointment_btn'.tr,
                  color: AppColors.primary,
                  icon: Icons.add_task,
                  onTap: () => Get.to(() => BookAppointmentScreen(
                    patientId: patientId,
                    patientName: patient.fullName ?? 'unknown_patient'.tr,
                  )),
                ),

                const SizedBox(height: 15),

                _buildMainButton(
                  label: 'new_lab_request_btn'.tr,
                  color: AppColors.cardBg,
                  icon: Icons.biotech_rounded,
                  isOutlined: true,
                  onTap: () => Get.to(() => LabRequestScreen(
                    patientId: patientId,
                    patientName: patient.fullName ?? 'unknown_patient'.tr,
                  )),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: isOutlined ? AppColors.primary : Colors.black, size: 20),
        label: Text(
          label,
          style: TextStyle(
            color: isOutlined ? AppColors.primary : Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          side: isOutlined ? const BorderSide(color: AppColors.primary, width: 1) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isArabic,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: AppColors.textMain.withValues(alpha: 0.5), fontSize: 11)),
                ],
              ),
            ],
          ),
          Icon(
            isArabic ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
            color: AppColors.textHint,
            size: 16,
          ),
        ],
      ),
    );
  }
}