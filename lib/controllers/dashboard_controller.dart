import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class DashboardController extends GetxController {
  static const String dashboardStats = ApiConfig.dashboardStats;
  static const String getAppoitmentsTodayUrl = ApiConfig.getAppoitmentsToday;
  static const String countOfPatientsUrl = ApiConfig.countOfPatients;
  static const String searchPatientUrl = ApiConfig.SearchPatient;
  static const String nextAppointmentUrl = ApiConfig.nextAppointment;

  var emergencyCount = 0.obs;
  var emergencyList = <Map<String, dynamic>>[].obs;
  var isEmergencyLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEmergencyNotifications();
  }

  Future<void> fetchEmergencyNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getEmergency),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData['success'] == true) {
          List<dynamic> pendingCases = decodedData['data'] ?? [];
          emergencyCount.value = pendingCases.length;

          debugPrint('🔔 Emergency Count Updated Successfully: ${emergencyCount.value}');
        }
      } else {
        debugPrint('❌ Failed to load emergency cases. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching emergency notifications: $e');
    }
  }

  void clearEmergency(int id) {
    emergencyList.removeWhere((element) => element['id'] == id);
    emergencyCount.value = emergencyList.length;
  }

  static Future<Map<String, dynamic>?> fetchClinicStats() async {
    try {
      final response = await http.get(Uri.parse(dashboardStats.trim()));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['success'] == true) {
          debugPrint('Data sent to UI: $decodedData');
          return decodedData['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> fetchTodayAppointments() async {
    try {
      final response = await http.get(
        Uri.parse(getAppoitmentsTodayUrl.trim()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData is Map && decodedData['success'] == true) {
          if (decodedData['appointments'] != null) {
            return decodedData['appointments'];
          }
          return decodedData['data'] ?? [];
        } else if (decodedData is List) {
          return decodedData;
        }
      }
      return null;
    } catch (e) {
      debugPrint("❌ Error fetching today's appointments from Controller: $e");
      return null;
    }
  }

  static Future<int> fetchTotalPatientsCount() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.getAllPatient.trim()));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData['count'] != null) {
          return int.tryParse(decodedData['count'].toString()) ?? 0;
        }
      }
      return 0;
    } catch (e) {
      debugPrint('❌ Error fetching total patients count: $e');
      return 0;
    }
  }

  static Future<Map<String, dynamic>?> fetchNextAppointment() async {
    try {
      final response = await http.get(
        Uri.parse(nextAppointmentUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching next appointment: $e');
      return null;
    }
  }
}