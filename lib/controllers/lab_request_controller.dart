import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../api_config.dart';

class LabRequestController extends GetxController {
  var isLoading = false.obs;
  final String createLabRequestUrl = ApiConfig.sendLabRequest;

  String _replaceArabicDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    return input;
  }

  Future<void> sendLabRequest({
    required int patientId,
    required String patientName,
    required String jobType,
    required String toothNumber,
    required String instructions,
    int? appointmentId,
    int? doctorId,
    int? technicianId,
  }) async {
    isLoading.value = true;

    try {
      String cleanedInput = toothNumber.trim();
      cleanedInput = _replaceArabicDigits(cleanedInput);

      int formattedToothNumber = int.tryParse(cleanedInput) ?? 46;

      debugPrint('🚀 Tooth Number parsed successfully: $formattedToothNumber');

      final response = await http.post(
        Uri.parse(createLabRequestUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patient_id': patientId,
          'patient_name': patientName,
          'job_type': jobType,
          'tooth_number': formattedToothNumber,
          'doctor_instructions': instructions,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = jsonDecode(response.body);

        if (resData['success'] == true) {
          Get.back();

          Get.snackbar(
            'تم بنجاح',
            'تم حفظ طلب المختبر بنجاح وتوجيهه',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.tealAccent,
            colorText: Colors.black,
          );

          String rawPhone = resData['data']['lab_phone_number'] ?? '';
          if (rawPhone.isNotEmpty) {
            _openWhatsApp(
              phoneNumber: rawPhone,
              message:
                  'دكتور، تم إرسال طلب مختبر للمريض: $patientName\nالعمل المطلوب: $jobType\nرقم السن: $formattedToothNumber\nالملاحظات: $instructions',
            );
          }
        }
      } else {
        _showErrorSnackbar();
      }
    } catch (e) {
      debugPrint('❌ Error sending lab request: $e');
      _showErrorSnackbar();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _openWhatsApp({
    required String phoneNumber,
    required String message,
  }) async {
    String formattedPhone = phoneNumber.replaceAll('+', '').trim();
    final whatsappUrl = Uri.parse(
      'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'تنبيه',
        'لم نتمكن من فتح تطبيق الواتساب',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
      );
    }
  }

  void _showErrorSnackbar() {
    Get.snackbar(
      'تنبيه',
      'فشلت العملية، يرجى التحقق من الشبكة',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}