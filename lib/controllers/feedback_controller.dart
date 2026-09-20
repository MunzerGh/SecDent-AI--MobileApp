import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sec_dent_ai/Services/notification_service.dart';
import '../../api_config.dart';

class FeedbackController extends GetxController {
  var feedbacksList = <dynamic>[].obs;
  var isLoading = true.obs;
  static const String getFeedbacksUrl = ApiConfig.getFeedbacks;

  var unreadCount = 0.obs;
  dynamic _lastSeenId;
  bool _isFirstLoad = true;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardFeedbacks();
  }

  Future<void> fetchDashboardFeedbacks() async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse(getFeedbacksUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          List<dynamic> newData = jsonResponse['data'];

          if (feedbacksList.isNotEmpty && newData.isNotEmpty) {
            if (newData[0]['id'] != feedbacksList[0]['id']) {
              NotificationService.showNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                title: 'وارد جديد من البوت الذكي 🤖',
                body:
                    'قام المريض بمراسلة العيادة وإرسال ملاحظة جديدة، تفقد الـ Dashboard.',
              );
            }
          }

          feedbacksList.value = newData;

          if (newData.isNotEmpty) {
            if (_isFirstLoad) {
              _lastSeenId = newData[0]['id'];
              unreadCount.value = 0;
              _isFirstLoad = false;
            } else if (_lastSeenId != null) {
              int newItemsCount = 0;
              for (var item in newData) {
                if (item['id'] == _lastSeenId) break;
                newItemsCount++;
              }
              unreadCount.value = newItemsCount;
            }
          }
        }
      } else {
        Get.snackbar(
          'alert'.tr,
          'error_occurred'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching dashboard feedbacks: $e');
    } finally {
      isLoading(false);
    }
  }

  void markAllAsRead() {
    if (feedbacksList.isNotEmpty) {
      _lastSeenId = feedbacksList[0]['id'];
    }
    unreadCount.value = 0;
  }
}