import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sec_dent_ai/api_config.dart';
import 'package:sec_dent_ai/models/emergency_model.dart';

class EmergencyController {
  final String getEmergencyCases = ApiConfig.getEmergency;
  final String acceptAndScheduleUrl = ApiConfig.acceptAndSchedule;
  final String rejectEmergencyCases = ApiConfig.rejectEmergency;

  Future<List<EmergencyCase>> fetchEmergencyCases() async {
    try {
      final response = await http.get(Uri.parse(getEmergencyCases));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        final List<dynamic> casesJson = decodedData['data'];
        return casesJson.map((json) => EmergencyCase.fromJson(json)).toList();
      } else {
        throw Exception('فشل جلب البيانات من السيرفر');
      }
    } catch (e) {
      throw Exception('حدث خطأ في الاتصال: $e');
    }
  }

  Future<bool> acceptAndScheduleCase(
    int emergencyId,
    int patientId,
    String conflictTime,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(acceptAndScheduleUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'emergencyId': emergencyId,
          'patient_id': patientId,
          'conflictTime': conflictTime,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectEmergencyCase(int emergencyId) async {
    try {
      final response = await http.post(
        Uri.parse(rejectEmergencyCases),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'emergencyId': emergencyId,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}