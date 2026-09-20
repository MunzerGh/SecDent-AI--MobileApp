import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class PatientController extends GetxController {
  var allPatients = <dynamic>[].obs;
  var filteredPatients = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredPatients.assignAll(allPatients);
  }

  void filterPatients(String query) {
    if (query.isEmpty) {
      filteredPatients.assignAll(allPatients);
    } else {
      filteredPatients.assignAll(
        allPatients.where((patient) {
          final String name =
              patient['full_name']?.toString().toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  static Future<String?> addPatient({
    required String fullName,
    required String phone,
    required String gender,
    required String birthDate,
    required String medicalHistory,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.addPatient),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'phone': phone,
          'gender': gender,
          'birth_date': birthDate,
          'medical_history': medicalHistory,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      } else {
        return 'خطأ في السيرفر (${response.statusCode})';
      }
    } catch (e) {
      return 'خطأ في الاتصال: $e';
    }
  }
}