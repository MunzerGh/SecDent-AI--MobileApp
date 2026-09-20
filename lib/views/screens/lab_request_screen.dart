import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lab_request_controller.dart';

class LabRequestScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const LabRequestScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<LabRequestScreen> createState() => _LabRequestScreenState();
}

class _LabRequestScreenState extends State<LabRequestScreen> {
  late final LabRequestController _labController;
  final TextEditingController _toothNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedLabType = 'lab_filling';

  final int _currentAppointmentId = 1;
  final int _currentDoctorId = 1;
  final int _selectedTechnicianId = 2;

  final List<String> _labTypes = [
    'lab_filling',
    'lab_zircon',
    'lab_porcelain',
    'lab_veneers',
    'lab_bridge',
    'lab_denture',
    'lab_repair',
  ];

  @override
  void initState() {
    super.initState();
    _labController = Get.put(LabRequestController());
  }

  @override
  void dispose() {
    _toothNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          title: Text('${"lab_request_for_patient".tr}: ${widget.patientName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: const Color(0xFF1B263B),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: const Color(0xFF1B263B).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF58A6FF).withValues(alpha: 0.3))
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFF58A6FF)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "${"current_patient_label".tr}: ${widget.patientName}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              _buildSectionTitle('job_type_section_title'.tr),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLabType,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1B263B),
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    icon: const Icon(Icons.arrow_drop_down_circle_rounded, color: Color(0xFF58A6FF)),
                    items: _labTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.tr),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedLabType = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('tooth_number_section_title'.tr),
              _buildInputField(
                controller: _toothNumberController,
                hint: 'tooth_number_hint'.tr,
                icon: Icons.grid_3x3_rounded,
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('doctor_instructions_section_title'.tr),
              _buildInputField(
                controller: _notesController,
                hint: 'doctor_instructions_hint'.tr,
                icon: Icons.edit_note_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 35),

              Obx(() {
                return _labController.isLoading.value
                    ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Color(0xFF58A6FF))))
                    : SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _labController.sendLabRequest(
                        patientId: widget.patientId,
                        appointmentId: _currentAppointmentId,
                        doctorId: _currentDoctorId,
                        technicianId: _selectedTechnicianId,
                        jobType: _selectedLabType != null ? _selectedLabType!.tr : 'unspecified_label'.tr,
                        patientName: widget.patientName,
                        toothNumber: _toothNumberController.text.trim().isEmpty ? 'unspecified_label'.tr : _toothNumberController.text.trim(),
                        instructions: _notesController.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58A6FF),
                      foregroundColor: const Color(0xFF0D1B2A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: Text(
                      'save_and_whatsapp_btn'.tr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF58A6FF).withValues(alpha: 0.7)),
        filled: true,
        fillColor: const Color(0xFF1B263B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF58A6FF), width: 1),
        ),
      ),
    );
  }
}