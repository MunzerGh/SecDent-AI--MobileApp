import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/archive_controller.dart';
import '../../core/app_colors.dart';
import '../../widgets/patient_card.dart';
import '../../widgets/empty_state_widget.dart';

class PatientSearchScreen extends StatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  State<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  final ArchiveController controller = Get.put(ArchiveController());
  final RxString searchQuery = ''.obs;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'search_patient'.tr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 5),
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              autofocus: true,
              onChanged: (value) => searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'search_patient_hint'.tr,
                hintStyle: const TextStyle(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textHint),
                        onPressed: () {
                          _textController.clear();
                          searchQuery.value = '';
                        },
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (searchQuery.value.trim().isEmpty) {
                return EmptyStateWidget(
                  message: 'start_typing_search_hint'.tr,
                  icon: Icons.search_rounded,
                );
              }

              final displayedPatients = controller.filteredPatients.where((patient) {
                final String name = patient['full_name']?.toString().toLowerCase() ?? '';
                return name.contains(searchQuery.value.toLowerCase());
              }).toList();

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
          ),
        ],
      ),
    );
  }
}