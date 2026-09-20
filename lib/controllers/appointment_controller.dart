import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class AppointmentController extends GetxController {
  var isLoadingSlots = false.obs;
  var bookedSlots = <String>[].obs;
  var isSubmitting = false.obs;

  var todaysAppointments = <dynamic>[].obs;
  var isLoadingTodaysAppts = false.obs;

  static const String bookedSlotsUrl = ApiConfig.BookedSlots;
  static const String createApptsUrl = ApiConfig.CreateAppts;

  @override
  void onInit() {
    super.onInit();
    fetchTodaysAppointments();
  }

  Future<void> fetchTodaysAppointments() async {
    try {
      isLoadingTodaysAppts(true);

      final response = await http.get(
        Uri.parse(ApiConfig.getAppoitmentsToday),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData['success'] == true) {
          todaysAppointments.assignAll(decodedData['data']);
        } else {
          todaysAppointments.assignAll(decodedData);
        }
      } else {
        debugPrint('📌 Server Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Error fetching today's appointments: $e");
    } finally {
      isLoadingTodaysAppts(false);
    }
  }

  Future<void> fetchBookedSlots(String date) async {
    try {
      isLoadingSlots(true);
      final response = await http.post(
        Uri.parse(bookedSlotsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'date': date}),
      );
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          bookedSlots.assignAll(List<String>.from(decodedData['bookedSlots']));
        }
      } else {
        Get.snackbar('تنبيه', 'فشل جلب الساعات المحجوزة من السيرفر');
      }
    } catch (e) {
      debugPrint('❌ Error fetching booked slots: $e');
    } finally {
      isLoadingSlots(false);
    }
  }

  Future<bool> createAppointment({
    required int patientId,
    required int treatmentId,
    required int durationMinutes,
    required String date,
    required String time,
    required String description,
  }) async {
    try {
      isSubmitting(true);

      final Map<String, dynamic> requestBody = {
        'patient_id': patientId,
        'doctor_id': 1,
        'treatment_id': treatmentId,
        'appointment_date': date,
        'appointment_time': time,
        'duration_minutes': durationMinutes,
        'description': description,
      };

      debugPrint('🚀 Sending Data to Monther Server: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(createApptsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      debugPrint('📌 Server Status Code: ${response.statusCode}');
      debugPrint('📦 Server Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          Get.snackbar(
            'تم بنجاح 🎉',
            decodedData['message'] ?? 'تم حجز وتثبيت الموعد بنجاح.',
          );
          fetchTodaysAppointments();
          return true;
        }
      }

      final errorData = jsonDecode(response.body);
      Get.snackbar(
        'خطأ من السيرفر',
        errorData['message'] ?? 'فشل في حفظ الموعد',
      );
      return false;
    } catch (e) {
      debugPrint('❌ Catch Error: $e');
      return false;
    } finally {
      isSubmitting(false);
    }
  }
}