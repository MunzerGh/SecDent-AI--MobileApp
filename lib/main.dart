import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/app_colors.dart';
import 'Services/notification_service.dart';
import 'views/screens/SplashScreen.dart';
import 'app_translations.dart';

Future<void> main() async {
  // 1️⃣ التأكد من تهيئة أدوات فلاتر
  WidgetsFlutterBinding.ensureInitialized();

  // 2️⃣ إخفاء شريط النظام العلوي والسفلي (وضع ملء الشاشة)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // 3️⃣ تهيئة تنسيق التواريخ باللغة العربية
  await initializeDateFormatting('ar', null);

  // 4️⃣ تهيئة خدمة الإشعارات المحلية
  await NotificationService.initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      title: 'SecDent AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const SplashScreen(),
    );
  }
}