import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/feedback_controller.dart';
import 'PatientProfileView.dart';

class PatientFeedbackScreen extends StatelessWidget {
  const PatientFeedbackScreen({super.key});

  String _formatNumbersByLocale(String input) {
    if (Get.locale?.languageCode == 'ar') {
      const englishToArabic = {
        '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
        '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'
      };
      return input.split('').map((char) => englishToArabic[char] ?? char).join();
    }
    return input;
  }

  String _formatDateTime(String timestampStr) {
    try {
      final parsedDate = DateTime.parse(timestampStr).toLocal();
      final currentLocale = Get.locale?.languageCode ?? 'ar';
      return DateFormat.yMMMd(currentLocale).add_jm().format(parsedDate);
    } catch (_) {
      return timestampStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final FeedbackController controller = Get.put(FeedbackController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text('patient_feedbacks'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: const Color(0xFF0F2033),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF58A6FF)),
            onPressed: () => controller.fetchDashboardFeedbacks(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF58A6FF)));
        }

        if (controller.feedbacksList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_chat_read_outlined, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  'no_feedbacks_yet'.tr,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDashboardFeedbacks(),
          color: const Color(0xFF58A6FF),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.feedbacksList.length,
            itemBuilder: (context, index) {
              final feedback = controller.feedbacksList[index];

              final String patientName = feedback['patient_name'] ?? 'unknown_name'.tr;
              final String feedbackText = feedback['feedback_text'] ?? '';
              final String createdAt = feedback['created_at'] ?? '';
              final dynamic patientId = feedback['patient_id'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF58A6FF).withValues(alpha: 0.1), width: 1),
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
                                radius: 16,
                                backgroundColor: Colors.white10,
                                child: Icon(Icons.person_outline, size: 18, color: Colors.orangeAccent),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  patientName,
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF0D1B2A),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            if (patientId != null) {
                              Get.to(() => PatientProfileView(patientId: patientId));
                            }
                          },
                          icon: const Icon(Icons.folder_shared_outlined, size: 14, color: Color(0xFF58A6FF)),
                          label: Text('view_patient_file_short'.tr, style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 11)),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.white10, height: 1),
                    ),
                    Text(
                      feedbackText,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Colors.white38),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumbersByLocale(_formatDateTime(createdAt)),
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
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