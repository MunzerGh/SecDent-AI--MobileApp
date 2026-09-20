import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/xray_controller.dart';
import '../../core/app_colors.dart';
import '../../widgets/xray_card.dart';
import '../../widgets/empty_state_widget.dart';

class PatientXRayScreen extends StatelessWidget {
  final int patientId;
  final XRayController xrayController = Get.put(XRayController());

  PatientXRayScreen({super.key, required this.patientId}) {
    xrayController.fetchPatientXRays(patientId);
  }

  void _openFullScreenImage(BuildContext context, String imageUrl, String aiAnalysis) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(aiAnalysis, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, color: AppColors.textHint, size: 60),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text("${"xray_archive_title".tr} - ${xrayController.patientName.value}")),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (xrayController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (xrayController.xrayList.isEmpty) {
          return EmptyStateWidget(
            message: 'no_xrays_found_msg'.tr,
            icon: Icons.blur_off_rounded,
          );
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: GridView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: xrayController.xrayList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final xray = xrayController.xrayList[index];
              final String imageUrl = xray['image_url'] ?? '';
              final String aiFinding = (xray['ai_result'] ?? {})['finding'] ?? 'no_notes_label'.tr;

              return XRayCard(
                xray: xray,
                onTap: () {
                  if (imageUrl.isNotEmpty) {
                    _openFullScreenImage(context, imageUrl, aiFinding);
                  } else {
                    Get.snackbar('warning_title'.tr, 'image_url_unavailable'.tr);
                  }
                },
              );
            },
          ),
        );
      }),
    );
  }
}