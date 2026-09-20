import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/archive_controller.dart';
import '../../core/app_colors.dart';
import '../../widgets/patient_card.dart';
import '../../widgets/empty_state_widget.dart';

class PatientsArchiveScreen extends StatelessWidget {
  const PatientsArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArchiveController controller = Get.put(ArchiveController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'patients_archive'.tr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.appBarBg,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final displayedPatients = controller.filteredPatients;

        if (displayedPatients.isEmpty) {
          return EmptyStateWidget(message: 'no_patients'.tr);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          itemCount: displayedPatients.length,
          itemBuilder: (context, index) {
            return PatientCard(patient: displayedPatients[index]);
          },
        );
      }),
    );
  }
}