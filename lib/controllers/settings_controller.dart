import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sec_dent_ai/views/screens/login_screen.dart';
import '../api_config.dart';

class SettingsController extends GetxController {
  var isLoading = false.obs;
  var isSaving = false.obs;

  var appLanguage = 'en'.obs;

  static const String getSettingsUrl = ApiConfig.getSettings;
  static const String settingsUpdateUrl = ApiConfig.Settings_Update;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      isLoading.value = true;
      final response = await http
          .get(Uri.parse(getSettingsUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['success'] == true && decodedData['data'] != null) {
          appLanguage.value = decodedData['data']['app_language'] ?? 'en';
          Get.updateLocale(Locale(appLanguage.value));
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings() async {
    try {
      isSaving.value = true;

      final Map<String, dynamic> bodyData = {
        'app_language': appLanguage.value,
      };

      final response = await http
          .put(
            Uri.parse(settingsUpdateUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(bodyData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        Get.snackbar(
          'تم الحفظ بنجاح',
          'تم تحديث لغة التطبيق بالسيرفر بنجاح ✅',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.greenAccent,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving settings: $e');
    } finally {
      isSaving.value = false;
    }
  }

  void logout() {
    Get.snackbar(
      'تسجيل الخروج',
      'تم تسجيل الخروج بنجاح ✅',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.tealAccent,
      colorText: Colors.black,
    );

    Get.offAll(() => const LoginScreen());
  }
}