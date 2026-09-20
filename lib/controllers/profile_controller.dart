import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../api_config.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;
  var isSaving = false.obs;

  var fullName = ''.obs;
  var specialty = ''.obs;
  var email = ''.obs;
  var address = ''.obs;

  var selectedImagePath = ''.obs;
  var currentProfileImage = ''.obs;

  final ImagePicker _picker = ImagePicker();

  final int doctorId = 3;

  static const String profileDoctorUrl = ApiConfig.ProfileDoctor;
  static const String updateProfileDoctorUrl = ApiConfig.UpdateProfileDoctor;

  @override
  void onInit() {
    super.onInit();
    getDoctorProfile();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        selectedImagePath.value = pickedFile.path;
      }
    } catch (e) {
      debugPrint('🚨 خطأ أثناء اختيار الصورة: $e');
      Get.snackbar('خطأ', 'فشل جلب الصورة من الجهاز');
    }
  }

  Future<void> getDoctorProfile() async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse(profileDoctorUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'doctor_id': doctorId}),
      );

      if (response.statusCode == 200) {
        var decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          var data = decoded['profile'];
          fullName.value = data['full_name'] ?? '';
          specialty.value = data['specialty'] ?? '';
          email.value = data['email'] ?? '';
          address.value = data['address'] ?? '';

          currentProfileImage.value =
              data['profile_image'] ?? data['image'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('🚨 خطأ في جلب البيانات: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDoctorProfile() async {
    try {
      isSaving.value = true;

      var request =
          http.MultipartRequest('PUT', Uri.parse(updateProfileDoctorUrl));

      request.headers.addAll({
        'Accept': 'application/json',
      });

      request.fields['doctor_id'] = doctorId.toString();
      request.fields['full_name'] = fullName.value;
      request.fields['specialty'] = specialty.value;
      request.fields['email'] = email.value;
      request.fields['address'] = address.value;

      if (selectedImagePath.value.isNotEmpty) {
        File imageFile = File(selectedImagePath.value);
        if (await imageFile.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'profile_image',
              imageFile.path,
            ),
          );
          debugPrint('📸 تم إرفاق ملف الصورة بنجاح بالطلب المتجه للسيرفر.');
        }
      }

      debugPrint(
          '🌐 جاري إرسال الطلب كمجسم Multipart إلى: $updateProfileDoctorUrl');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('🟢 كود رد السيرفر: ${response.statusCode}');
      debugPrint('💬 جسم رد السيرفر: ${response.body}');

      if (response.statusCode == 200) {
        var decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          selectedImagePath.value = '';

          if (decoded['profile_image'] != null) {
            currentProfileImage.value = decoded['profile_image'];
          }

          Get.snackbar(
            'نجاح العمل',
            'تم تحديث بياناتك وصورتك الشخصية بنجاح',
            backgroundColor: Colors.green.withValues(alpha: 0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'تنبيه',
            decoded['message'] ?? 'فشل التحديث من جهة السيرفر',
          );
        }
      } else {
        Get.statusCodeSnack(response.statusCode);
      }
    } catch (e) {
      debugPrint('🚨🚨 خطأ صريح أثناء الاتصال بالسيرفر: $e');
      Get.snackbar('خطأ في الاتصال', 'فشل إرسال البيانات، تحقق من السيرفر');
    } finally {
      isSaving.value = false;
    }
  }
}

extension StatusCodeSnack on GetInterface {
  void statusCodeSnack(int statusCode) {
    Get.snackbar(
      'خطأ في السيرفر ($statusCode)',
      'السيرفر رفض الطلب. تأكد من تطابق الحقول أو الـ Method مع الباك إند',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}