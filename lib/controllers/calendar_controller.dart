import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/appointment_model.dart';

class CalendarController extends GetxController {
  static const String appointmentsByDate = ApiConfig.appointmentsByDate;
  static const String appointmentsStats = ApiConfig.appointmentsStats;
  static const String updateStatus = ApiConfig.updateStatus;

  // 1️⃣ دالة جلب المواعيد الحقيقية من السيرفر
  Future<List<AppointmentModel>> fetchAppointmentsForDate(DateTime date) async {
    String formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await http.post(
        Uri.parse(appointmentsByDate),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'date': formattedDate}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<dynamic> list = data['appointments'];
          return list.map((json) => AppointmentModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    }
    return [];
  }

  // 2️⃣ دالة جلب الإحصائيات الحقيقية للقرص (Pie Chart)
  Future<Map<String, int>> fetchStatsForDate(DateTime date) async {
    String formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await http.post(
        Uri.parse(appointmentsStats),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'date': formattedDate}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true && data['stats'] != null) {
          final stats = data['stats'];
          final detailed = stats['detailed'] ?? {};

          return {
            'available': int.tryParse(stats['available'].toString()) ?? 0,
            'confirmed': int.tryParse(detailed['confirmed'].toString()) ?? 0,
            'inProgress': int.tryParse(detailed['inProgress'].toString()) ?? 0,
            'requested': int.tryParse(detailed['requested'].toString()) ?? 0,
            'cancelled': int.tryParse(detailed['cancelled'].toString()) ?? 0,
            'completed': int.tryParse(detailed['completed'].toString()) ?? 0,
          };
        }
      }
    } catch (e) {
      debugPrint('Error fetching detailed stats: $e');
    }
    return {
      'available': 0,
      'confirmed': 0,
      'inProgress': 0,
      'requested': 0,
      'cancelled': 0,
      'completed': 0,
    };
  }

  // 3️⃣ دالة تحديث حالة الموعد بالسيرفر
  Future<bool> updateAppointmentStatus(int appointmentId, String newStatus) async {
    String url = '${ApiConfig.baseUrl}/api/appointments/update-status';

    try {
      debugPrint('📡 Sending: $url');
      debugPrint('📦 Body: appointment_id: $appointmentId, status: $newStatus');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appointment_id': appointmentId,
          'status': newStatus,
        }),
      );

      debugPrint('🚨 Server Response Code: ${response.statusCode}');
      debugPrint('🚨 Server Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
    } catch (e) {
      debugPrint('❌ Error updating appointment status: $e');
    }
    return false;
  }
}