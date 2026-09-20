import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/profile_controller.dart';

class DoctorInfoScreen extends StatefulWidget {
  const DoctorInfoScreen({super.key});

  @override
  State<DoctorInfoScreen> createState() => _DoctorInfoScreenState();
}

class _DoctorInfoScreenState extends State<DoctorInfoScreen> {
  final ProfileController _profileController = Get.put(ProfileController());

  // تركنا إيميل كـ controller لأنه ثابت ولا يتأثر باللغة
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = _profileController.email.value;
    ever(_profileController.email, (String val) => _emailController.text = val);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // دالة الترجمة الذكية حسب لغة التطبيق
  String _getLocalizedValue(String originalValue, String type) {
    if (Get.locale?.languageCode == 'ar') {
      if (type == 'name' && originalValue == 'Munzer Ghazi') {
        return 'منذر غازي';
      }
      if (type == 'specialty' && originalValue == 'Orthodontist & Dental Surgeon') {
        return 'أخصائي تقويم أسنان وجراحة فم';
      }
      if (type == 'address' && originalValue == 'Main Street, Clinic No. 4') {
        return 'الشارع الرئيسي، عيادة رقم 4';
      }
    }
    return originalValue; // بالإنجليزية يرجع القيمة الأصلية كما هي
  }

  void _saveChanges(String name, String specialty, String address) {
    // إذا كانت اللغة عربية، نرجع القيم لأصلها الإنجليزي عند الحفظ بالسيرفر لعدم تخريب البيانات
    String finalName = name;
    String finalSpecialty = specialty;
    String finalAddress = address;

    if (Get.locale?.languageCode == 'ar') {
      if (name == 'منذر غازي') finalName = 'Munzer Ghazi';
      if (specialty == 'أخصائي تقويم أسنان وجراحة فم') finalSpecialty = 'Orthodontist & Dental Surgeon';
      if (address == 'الشارع الرئيسي، عيادة رقم 4') finalAddress = 'Main Street, Clinic No. 4';
    }

    _profileController.fullName.value = finalName;
    _profileController.specialty.value = finalSpecialty;
    _profileController.email.value = _emailController.text;
    _profileController.address.value = finalAddress;

    _profileController.updateDoctorProfile();
  }

  void _openFullImagePreview(ImageProvider? imageProvider) {
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: imageProvider != null
                ? Image(
              image: imageProvider,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            )
                : const Icon(Icons.person, size: 150, color: Color(0xFF58A6FF)),
          ),
        ),
      ),
      useSafeArea: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = Get.locale?.languageCode == 'ar';

    // متغيرات محلية لحفظ التعديلات الجديدة أثناء الكتابة بالحقول
    String updatedName = _getLocalizedValue(_profileController.fullName.value, 'name');
    String updatedSpecialty = _getLocalizedValue(_profileController.specialty.value, 'specialty');
    String updatedAddress = _getLocalizedValue(_profileController.address.value, 'address');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          title: Text('doctor_profile_title'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: const Color(0xFF0D1B2A),
          elevation: 0,
          centerTitle: true,
        ),
        body: Obx(() {
          if (_profileController.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF58A6FF)));
          }

          ImageProvider? currentImageProvider;
          if (_profileController.selectedImagePath.value.isNotEmpty) {
            currentImageProvider = FileImage(File(_profileController.selectedImagePath.value));
          } else if (_profileController.currentProfileImage.value.isNotEmpty) {
            currentImageProvider = NetworkImage(_profileController.currentProfileImage.value);
          }

          // إعادة جلب القيم المحدثة داخل الـ Obx لضمان قلب النصوص فوراً عند تغيير اللغة
          String currentName = _getLocalizedValue(_profileController.fullName.value, 'name');
          String currentSpecialty = _getLocalizedValue(_profileController.specialty.value, 'specialty');
          String currentAddress = _getLocalizedValue(_profileController.address.value, 'address');

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _openFullImagePreview(currentImageProvider),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: const Color(0xFF1B263B),
                          backgroundImage: currentImageProvider,
                          child: currentImageProvider == null
                              ? const Icon(Icons.person, size: 55, color: Color(0xFF58A6FF))
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: isArabic ? null : 4,
                        left: isArabic ? 4 : null,
                        child: GestureDetector(
                          onTap: () => _showDoctorImagePicker(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF58A6FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                Text(
                  currentName,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  currentSpecialty,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),

                const Divider(color: Colors.white24, height: 40),

                // حقول ذكية تستخدم الـ Key والـ controller لتحديث نصوصها تلقائياً عند تغيير اللغة
                _buildDynamicTile('full_name_label'.tr, currentName, Icons.badge_rounded, (val) => updatedName = val),
                _buildDynamicTile('medical_specialty_label'.tr, currentSpecialty, Icons.medical_services_rounded, (val) => updatedSpecialty = val),

                // حقل الإيميل يعتمد على الـ Controller التقليدي لأنه إنجليزي دوماً
                _buildEmailTile('email_label'.tr, _emailController, Icons.email_rounded),

                _buildDynamicTile('clinic_address_label'.tr, currentAddress, Icons.location_on_rounded, (val) => updatedAddress = val),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58A6FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _profileController.isSaving.value
                        ? null
                        : () => _saveChanges(updatedName, updatedSpecialty, updatedAddress),
                    child: _profileController.isSaving.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      'save_changes'.tr,
                      style: const TextStyle(color: Color(0xFF0D1B2A), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // 🟢 ودجت مخصصة للحقول الثلاثة التي تقلب (الاسم، الاختصاص، العنوان) تعتمد على قيم متغيرة بشكل مباشر
  Widget _buildDynamicTile(String label, String value, IconData icon, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextFormField(
          key: ValueKey(value), // هاد الـ Key بيجبر الحقل يقلب القيمة فورا لما تتغير اللغة
          initialValue: value,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF58A6FF), size: 22),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // ودجت خاصة بالإيميل فقط
  Widget _buildEmailTile(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF58A6FF), size: 22),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  void _showDoctorImagePicker() {
    bool isArabic = Get.locale?.languageCode == 'ar';

    Get.bottomSheet(
      Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1B263B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'update_doctor_photo_title'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF58A6FF)),
                title: Text('pick_from_gallery'.tr, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Get.back();
                  _profileController.pickImage(ImageSource.gallery);
                },
              ),

              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF58A6FF)),
                title: Text('take_new_photo'.tr, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Get.back();
                  _profileController.pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}