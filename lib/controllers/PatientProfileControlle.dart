import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/patient_model.dart';

class PatientProfileController extends GetxController {
  var isLoading = true.obs;
  var patientData = Patient().obs;

  static const String profilePatientUrl = ApiConfig.patientprofile;

  Future<void> fetchPatientProfile(int patientId) async {
    try {
      isLoading(true);

      final response = await http.post(
        Uri.parse(profilePatientUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'patient_id': patientId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          patientData.value = Patient.fromJson(responseData['patient']);
        }
      } else {
        Get.snackbar('خطأ', 'فشل جلب البيانات من السيرفر');
      }
    } catch (e) {
      Get.snackbar('خطأ تقني', 'تأكد من اتصالك بالسيرفر: $e');
    } finally {
      isLoading(false);
    }
  }
}