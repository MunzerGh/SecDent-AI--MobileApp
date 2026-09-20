import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DentalController extends GetxController {
  // Map لتخزين حالة كل سن (رقم السن -> الحالة)
  // الحالة الافتراضية هي "سليم"
  var toothStates = <int, String>{}.obs;

  void updateToothStatus(int toothNumber, String status) {
    toothStates[toothNumber] = status;
    update(); // أمر للواجهة بتحديث نفسها
  }

  Color getToothColor(int toothNumber) {
    String? status = toothStates[toothNumber];
    switch (status) {
      case 'تسوس':
        return Colors.redAccent;
      case 'حشوة':
        return Colors.blueAccent;
      case 'سليم':
        return Colors.green;
      default:
        return const Color(0xFF1B263B); // اللون الافتراضي
    }
  }
}