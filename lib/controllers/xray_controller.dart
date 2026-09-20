import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class XRayController extends GetxController {
  var isLoading = false.obs;
  var xrayList = <dynamic>[].obs;
  var patientName = ''.obs;

  static const String xrayPatientsUrl = ApiConfig.xrayPatients;

  // 🎯 دالة جلب صور الأشعة بناءً على الـ patient_id
  Future<void> fetchPatientXRays(int patientId) async {
    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse(xrayPatientsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'patient_id': patientId}),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['success'] == true) {
          patientName.value = decodedData['patient'] ?? 'المريض';
          List<dynamic> rawData = decodedData['data'] ?? [];
          xrayList.value = rawData.map((item) {
            if (item['image_url'] != null &&
                item['image_url'].contains('localhost')) {
              item['image_url'] =
                  item['image_url'].replaceAll('localhost', '192.168.1.58');
            }
            return item;
          }).toList();
        }
      } else {
        debugPrint('❌ فشل جلب صور الأشعة: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ خطأ في الاتصال بسيرفر الأشعة: $e');
    } finally {
      isLoading.value = false;
    }
  }
}