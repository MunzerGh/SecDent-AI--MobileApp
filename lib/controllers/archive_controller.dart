import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class ArchiveController extends GetxController {
  var allPatients = <dynamic>[].obs;
  var filteredPatients = <dynamic>[].obs;

  var isLoading = true.obs;
  var isSearchingLoading = false.obs;

  static const String getAllPatientsUrl = ApiConfig.getAllPatient;
  static const String searchPatientUrl = ApiConfig.SearchPatient;

  @override
  void onInit() {
    super.onInit();
    fetchAllPatients();
  }

  Future<void> fetchAllPatients() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse(getAllPatientsUrl));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['success'] == true) {
          allPatients.assignAll(decodedData['data'] ?? []);
          filteredPatients.assignAll(allPatients);
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchPatient(String query) async {
    if (query.trim().isEmpty) {
      filteredPatients.assignAll(allPatients);
      return;
    }

    try {
      isSearchingLoading.value = true;

      final response = await http.post(
        Uri.parse(searchPatientUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': query,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData['success'] == true) {
          filteredPatients.assignAll(decodedData['data'] ?? []);
        }
      }
    } catch (e) {
      debugPrint('❌ الخطأ أثناء البحث: $e');
    } finally {
      isSearchingLoading.value = false;
    }
  }
}