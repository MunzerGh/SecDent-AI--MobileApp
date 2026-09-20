import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/dashboard_controller.dart';

class EmergencyNotificationsScreen extends StatelessWidget {
  const EmergencyNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text('emergency_telegram_bot'.tr),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (dashboardController.emergencyList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gpp_good_rounded, color: Colors.green, size: 60),
                const SizedBox(height: 15),
                Text(
                  'clinic_safe_status'.tr,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Directionality(
          textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: dashboardController.emergencyList.length,
            itemBuilder: (context, index) {
              final emergency = dashboardController.emergencyList[index];

              final String patientName = emergency['patient_name'] ?? 'unknown_patient'.tr;
              final String timeStr = emergency['time'] ?? '--:--';
              final String caseDesc = emergency['case_description'] ?? '';
              final String phone = emergency['phone'] ?? '';
              final dynamic emergencyId = emergency['id'];

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.redAccent,
                                radius: 18,
                                child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  patientName,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          timeStr,
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "📝 ${'emergency_case_description'.tr}:\n$caseDesc",
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: phone.isEmpty
                                ? null
                                : () async {
                                    final Uri telUri = Uri(scheme: 'tel', path: phone);
                                    if (await canLaunchUrl(telUri)) await launchUrl(telUri);
                                  },
                            icon: const Icon(Icons.phone, color: Colors.white, size: 16),
                            label: Text('call_now_btn'.tr, style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF58A6FF)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: emergencyId == null
                                ? null
                                : () {
                                    dashboardController.clearEmergency(emergencyId);
                                  },
                            icon: const Icon(Icons.check_circle_outline, color: Color(0xFF58A6FF), size: 16),
                            label: Text('verified_btn'.tr, style: const TextStyle(color: Color(0xFF58A6FF))),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}