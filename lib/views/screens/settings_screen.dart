import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text('clinic_settings'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F2033),
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF58A6FF)));
        }

        bool isArabic = Get.locale?.languageCode == 'ar';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 1️⃣ كرت الحساب ولغة التطبيق والـ Logout
              _buildSectionTitle('account_and_language'.tr),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xFF0D1B2A),
                          child: Icon(Icons.lock_person_rounded, color: Color(0xFF58A6FF), size: 22),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('logout_label'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                          onPressed: () => controller.logout(),
                        )
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.white10, height: 1),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('app_language'.tr, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF0D1B2A), borderRadius: BorderRadius.circular(12)),
                          child: ToggleButtons(
                            borderRadius: BorderRadius.circular(10),
                            isSelected: [isArabic, !isArabic],
                            fillColor: const Color(0xFF58A6FF),
                            selectedColor: Colors.black,
                            color: Colors.white38,
                            renderBorder: false,
                            constraints: const BoxConstraints(minHeight: 32, minWidth: 65),
                            children: [
                              Text('arabic_option'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('english_option'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                            onPressed: (index) {
                              if (index == 0) {
                                controller.appLanguage.value = 'ar';
                                Get.updateLocale(const Locale('ar'));
                              } else {
                                controller.appLanguage.value = 'en';
                                Get.updateLocale(const Locale('en'));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 2️⃣ كرت المطورين ومعلومات النظام (About App & Team)
              ListTile(
                leading: const Icon(Icons.info_outline_rounded, color: Colors.white38),
                title: Text('about_system_and_team'.tr, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                onTap: () {
                  Get.defaultDialog(
                    title: 'smart_dentist_secretary'.tr,
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    backgroundColor: const Color(0xFF1B263B),
                    radius: 20,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    content: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF0D1B2A), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Graduation Project v1.0.0', style: TextStyle(color: Color(0xFF58A6FF), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'university_dept_info'.tr,
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(color: Colors.white10, height: 1),
                        ),
                        Text('developed_by_team'.tr, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(height: 10),
                        const Text('Munzer Yehia Ghazi', style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Gabriel Abdi', style: TextStyle(color: Colors.blue, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('Ellie Touma', style: TextStyle(color: Colors.blue, fontSize: 14)),
                      ],
                    ),
                    cancel: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('close_btn'.tr, style: const TextStyle(color: Color(0xFF58A6FF), fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // 3️⃣ زر حفظ التعديلات
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58A6FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: controller.isSaving.value ? null : () => controller.saveSettings(),
                  child: controller.isSaving.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('save_changes'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 5, left: 5),
          child: Text(title, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w500, fontSize: 13))
      )
  );
}