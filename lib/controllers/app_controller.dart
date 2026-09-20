import 'package:flutter/foundation.dart';

class AppController {
  String doctorName = 'Dr.Munzer';

  void printLog(String message) {
    debugPrint('Log from Controller: $message');
  }
}