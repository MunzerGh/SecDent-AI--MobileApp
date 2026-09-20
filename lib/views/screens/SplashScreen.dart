import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'login_screen.dart';
import 'Dashboard Screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    _handleInit();
  }

  @override
  void dispose() {
    // التأكد من إرجاع واجهة النظام لوضعها الطبيعي دائماً عند تدمير الشاشة
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _handleInit() async {
    await Future.delayed(const Duration(seconds: 3));

    // فحص سلامة السياق في حال غادر المستخدم التطبيق قبل انتهاء التباعد الزمني
    if (!mounted) return;

    bool isLoggedIn = await AuthController.checkLoginStatus();

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (!mounted) return;

    if (isLoggedIn) {
      Get.offAll(() => const DashboardScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double logoSize = (screenWidth * 0.45).clamp(120.0, 250.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage('assets/dentist_logo.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF58A6FF).withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30 + MediaQuery.of(context).padding.bottom,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: screenWidth * 0.4,
                  height: 2,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF58A6FF)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'developed_by'.tr,
                  style: TextStyle(
                    color: const Color(0xFF58A6FF).withValues(alpha: 0.6),
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Munzer Ghazi\nGabriel Abdi\nEllie Touma',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.5,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}