import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/PatientController.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedGender = 'male';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final String? errorMessage = await PatientController.addPatient(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _selectedGender,
        birthDate: _birthDateController.text.trim(),
        medicalHistory: _notesController.text.trim(),
      );

      setState(() => _isSaving = false);

      if (errorMessage == null) {
        Get.snackbar(
          'success_title'.tr,
          'patient_added_success'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        _clearForm();
      } else {
        debugPrint('Detailed Error From Server: $errorMessage');

        Get.snackbar(
          'error_adding_patient'.tr,
          errorMessage.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _birthDateController.clear();
    _notesController.clear();
    setState(() {
      _selectedGender = 'male';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text('add_new_patient'.tr),
        backgroundColor: const Color(0xFF1B263B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'full_name_label'.tr,
                icon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'required_field'.tr : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _phoneController,
                label: 'phone_number_label'.tr,
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'required_field'.tr : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                onTap: _selectDate,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                    'birth_date_label'.tr, Icons.calendar_today),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'select_date_validation'.tr : null,
              ),
              const SizedBox(height: 20),
              Text('gender_label'.tr,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Row(
                children: [
                  Radio<String>(
                    value: 'male',
                    groupValue: _selectedGender,
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedGender = v);
                    },
                    activeColor: const Color(0xFF58A6FF),
                  ),
                  Text('male'.tr, style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'female',
                    groupValue: _selectedGender,
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedGender = v);
                    },
                    activeColor: const Color(0xFF58A6FF),
                  ),
                  Text('female'.tr, style: const TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _notesController,
                label: 'medical_history_label'.tr,
                icon: Icons.history_edu,
                maxLines: 4,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58A6FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('save_patient_profile'.tr,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: const Color(0xFF58A6FF)),
      filled: true,
      fillColor: const Color(0xFF1B263B),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF58A6FF))),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
    );
  }
}