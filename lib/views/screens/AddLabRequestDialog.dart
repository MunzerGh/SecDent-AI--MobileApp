import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lab_request_controller.dart';

class AddLabRequestDialog extends StatefulWidget {
  final int patientId;
  final String patientName;

  const AddLabRequestDialog({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AddLabRequestDialog> createState() => _AddLabRequestDialogState();
}

class _AddLabRequestDialogState extends State<AddLabRequestDialog> {
  late final LabRequestController controller;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _toothNumberController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LabRequestController>()
        ? Get.find<LabRequestController>()
        : Get.put(LabRequestController());
  }

  @override
  void dispose() {
    _jobTypeController.dispose();
    _toothNumberController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Dialog(
      backgroundColor: const Color(0xFF1B263B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'send_lab_request_title'.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.white10),
              const SizedBox(height: 15),
              _buildReadOnlyField(
                label: 'patient_name_label'.tr,
                value: widget.patientName,
                isArabic: isArabic,
              ),
              const SizedBox(height: 15),
              _buildInputField(
                controller: _jobTypeController,
                label: 'job_type_label'.tr,
                hint: 'job_type_hint'.tr,
                icon: Icons.layers_outlined,
                isArabic: isArabic,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'required_field'.tr : null,
              ),
              const SizedBox(height: 15),
              _buildInputField(
                controller: _toothNumberController,
                label: 'tooth_number_label'.tr,
                hint: 'tooth_number_hint_dialog'.tr,
                icon: Icons.pin_rounded,
                isArabic: isArabic,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'required_field'.tr;
                  if (int.tryParse(val.trim()) == null) return 'valid_number_error'.tr;
                  return null;
                },
              ),
              const SizedBox(height: 15),
              _buildInputField(
                controller: _instructionsController,
                label: 'instructions_label'.tr,
                hint: 'instructions_hint'.tr,
                icon: Icons.edit_note_rounded,
                isArabic: isArabic,
                maxLines: 3,
              ),
              const SizedBox(height: 25),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF58A6FF)));
                }
                return Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text('cancel_btn'.tr,
                            style: const TextStyle(color: Colors.white54)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF58A6FF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            controller.sendLabRequest(
                              patientId: widget.patientId,
                              patientName: widget.patientName,
                              jobType: _jobTypeController.text.trim(),
                              toothNumber: _toothNumberController.text.trim(),
                              instructions: _instructionsController.text.trim(),
                            );
                          }
                        },
                        child: Text(
                          'send_btn'.tr,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(
      {required String label, required String value, required bool isArabic}) {
    return Column(
      crossAxisAlignment:
          isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(12)),
          child: Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
              textAlign: isArabic ? TextAlign.right : TextAlign.left),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isArabic,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment:
          isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(12)),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              prefixIcon: Icon(icon, color: const Color(0xFF58A6FF), size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}