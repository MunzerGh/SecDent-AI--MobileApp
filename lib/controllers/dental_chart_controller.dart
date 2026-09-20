import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/tooth_mode.dart';

class DentalChartController extends GetxController {
  var teeth = <Tooth>[].obs;
  var isLoading = false.obs;

  static const String dentalChartUrl = ApiConfig.DentalChart;
  static const String dentalChartOnSaveUrl = ApiConfig.DentalChartOnSave;

  @override
  void onInit() {
    super.onInit();
    _initializeDefaultTeeth();
  }

  void _initializeDefaultTeeth() {
    teeth.value = List.generate(32, (index) {
      return Tooth(number: index + 1, status: ToothStatus.healthy);
    });
  }

  Future<void> loadPatientChart(int patientId) async {
    try {
      isLoading(true);

      final response = await http.post(
        Uri.parse(dentalChartUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'patient_id': patientId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['teeth'] != null) {
          List savedTeeth = data['teeth'];

          var tempTeeth = List.generate(
            32,
            (index) => Tooth(number: index + 1, status: ToothStatus.healthy),
          );

          for (var toothJson in savedTeeth) {
            int toothNum = toothJson['tooth_number'];
            String statusStr = toothJson['status'];

            int index = tempTeeth.indexWhere((t) => t.number == toothNum);
            if (index != -1) {
              tempTeeth[index] = Tooth(
                number: toothNum,
                status: _parseStatus(statusStr),
              );
            }
          }
          teeth.value = tempTeeth;
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب بيانات المخطط: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> savePatientChart(int patientId) async {
    try {
      List<Map<String, dynamic>> teethData = teeth.map((t) {
        return {
          'tooth_number': t.number,
          'status': _statusToString(t.status),
        };
      }).toList();

      final response = await http.post(
        Uri.parse(dentalChartOnSaveUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patient_id': patientId,
          'teeth': teethData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
            'نجاح الحفظ',
            'تم تسجيل مخطط الأسنان الجديد للمريض بنجاح 👍',
            colorText: Colors.white,
            backgroundColor: const Color(0xFF2A9D8F),
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        Get.snackbar('فشل الحفظ', 'السيرفر لم يستطع معالجة طلب الحفظ ⚠️');
      }
    } catch (e) {
      Get.snackbar('خطأ تقني', 'فشل الاتصال بالسيرفر أثناء الحفظ: $e');
    }
  }

  void updateStatus(int toothNumber, ToothStatus newStatus) {
    int index = teeth.indexWhere((t) => t.number == toothNumber);
    if (index != -1) {
      teeth[index] = Tooth(number: toothNumber, status: newStatus);
      teeth.refresh();
    }
  }

  ToothStatus _parseStatus(String status) {
    switch (status) {
      case 'decayed':
        return ToothStatus.decayed;
      case 'rootCanal':
        return ToothStatus.rootCanal;
      case 'rootAndFill':
        return ToothStatus.rootAndFill;
      case 'missing':
        return ToothStatus.missing;
      default:
        return ToothStatus.healthy;
    }
  }

  String _statusToString(ToothStatus status) {
    switch (status) {
      case ToothStatus.decayed:
        return 'decayed';
      case ToothStatus.rootCanal:
        return 'rootCanal';
      case ToothStatus.rootAndFill:
        return 'rootAndFill';
      case ToothStatus.missing:
        return 'missing';
      default:
        return 'healthy';
    }
  }
}