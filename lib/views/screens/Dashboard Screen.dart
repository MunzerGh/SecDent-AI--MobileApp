import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sec_dent_ai/controllers/feedback_controller.dart';
import 'package:sec_dent_ai/views/screens/patient_feedback_screen.dart';
import 'package:sec_dent_ai/views/screens/patients_archive_screen.dart';
import 'package:sec_dent_ai/views/screens/settings_screen.dart';
import 'package:sec_dent_ai/views/screens/add_patient_screen.dart';
import 'package:sec_dent_ai/views/screens/doctor_info_screen.dart';
import '../../controllers/calendar_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/profile_controller.dart';
import 'Calendar screen.dart';
import 'PatientProfileView.dart';
import 'PatientSearchScreen.dart';
import 'emergency_cases_view.dart';
import 'patient_xray_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _dashboardController = Get.put(DashboardController());
  final ProfileController _profileController = Get.put(ProfileController());
  final FeedbackController _feedbackController = Get.put(FeedbackController());
  
  int _selectedIndex = 0;
  int? _nextAppointmentId;

  String _totalPatientsCount = '0';
  String _todayAppointmentsCount = '0';
  bool _isLoading = true;
  int _appointmentDurationMinutes = 0;

  String _nextName = 'no_appointments_today';
  String _nextTime = '--:--';
  int? _nextPatientId;
  String _nextDescription = '';

  List<dynamic> _todayScheduleList = [];

  String _nextStatus = 'Confirmed';
  bool _isActionLoading = false;

  Timer? _appointmentTimer;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;

  final RxString _currentLanguage = ''.obs;

  // دالة مساعدة لتحويل الأرقام الإنجليزية إلى عربية عند تحويل لغة التطبيق
  String _formatNumbers(String input) {
    if (Get.locale?.languageCode == 'ar') {
      const englishToArabic = {
        '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
        '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'
      };
      return input.split('').map((char) => englishToArabic[char] ?? char).join();
    }
    return input;
  }

  // دالة لتنسيق الوقت القادم من السيرفر ليناسب لغة التطبيق الحالية
  String _formatTimeByLocale(String timeStr) {
    if (timeStr == '--:--') return timeStr;
    try {
      final currentLocale = Get.locale?.languageCode ?? 'ar';
      final dummyDate = DateTime.parse('2026-01-01 $timeStr');
      return DateFormat.jm(currentLocale).format(dummyDate);
    } catch (_) {
      return timeStr;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'cancelled':
      case 'cancel':
      case 'ملغي':
        return const Color(0xFFE63946);
      case 'confirmed':
      case 'confirm':
      case 'مؤكد':
        return const Color(0xFFD000FF);
      case 'completed':
      case 'complete':
      case 'مكتمل':
        return const Color(0xFF00F5D4);
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _getDashboardData();
    _currentLanguage.value = Get.locale?.languageCode ?? 'ar';
  }

  @override
  void dispose() {
    _appointmentTimer?.cancel();
    super.dispose();
  }

  Future<void> _getDashboardData() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      
      await _feedbackController.fetchDashboardFeedbacks();
      final stats = await DashboardController.fetchClinicStats();
      final todayAppts = await DashboardController.fetchTodayAppointments();
      final totalPatientsResult = await DashboardController.fetchTotalPatientsCount();
      final nextApptResult = await DashboardController.fetchNextAppointment();

      _dashboardController.fetchEmergencyNotifications();

      if (mounted) {
        setState(() {
          if (todayAppts != null) {
            _todayScheduleList = todayAppts;
          } else {
            _todayScheduleList = (stats != null && stats['todaySchedule'] != null)
                ? stats['todaySchedule']
                : [];
          }

          if (stats != null) {
            _todayAppointmentsCount = stats['todayAppointments']?.toString() ?? '0';
          }

          _totalPatientsCount = totalPatientsResult.toString();

          if (_nextStatus.toLowerCase() == 'inprogress' && _nextPatientId != null) {
            _isLoading = false;
            return;
          }

          if (nextApptResult != null &&
              nextApptResult['success'] == true &&
              nextApptResult['has_next'] == true) {
            var nextApp = nextApptResult['appointment'];

            _nextName = nextApp['patient_name'] ?? nextApp['full_name'] ?? 'unknown_name'.tr;
            _nextPatientId = nextApp['patient_id'];
            _nextStatus = nextApp['status'] ?? 'Confirmed';
            _appointmentDurationMinutes = nextApp['duration_minutes'] ?? 30;
            _nextDescription = nextApp['description'] ?? '';

            if (nextApp['appointment_id'] != null) {
              _nextAppointmentId = int.tryParse(nextApp['appointment_id'].toString());
            } else if (nextApp['id'] != null) {
              _nextAppointmentId = int.tryParse(nextApp['id'].toString());
            } else {
              _nextAppointmentId = null;
            }

            _nextTime = nextApp['appointment_time'] ?? '--:--';
          } else {
            _nextName = 'no_appointments_today'.tr;
            _nextTime = '--:--';
            _nextPatientId = null;
            _nextAppointmentId = null;
            _nextStatus = 'Confirmed';
            _nextDescription = '';
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error in Dashboard UI: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPatientOptionsSheet(BuildContext context, dynamic appointment) {
    final int? patientId = appointment['patient_id'];
    final String patientName = appointment['patient_name'] ??
        appointment['full_name'] ??
        'unknown_patient'.tr;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B263B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 25),
              Text(patientName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.account_box, color: Color(0xFF58A6FF)),
                title: Text('patient_file'.tr,
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  if (patientId != null) {
                    Get.to(() => PatientProfileView(patientId: patientId));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics_outlined,
                    color: Colors.greenAccent),
                title: Text('ai_analysis'.tr,
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  if (patientId != null) {
                    Get.to(() => PatientXRayScreen(patientId: patientId));
                  } else {
                    Get.snackbar('alert'.tr, 'image_link_unavailable'.tr);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.redAccent),
                title: Text('none'.tr,
                    style: const TextStyle(color: Colors.white54)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      const CalendarScreen(),
      const PatientsArchiveScreen(),
      const SettingsScreen(),
      const DoctorInfoScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _getDashboardData,
      color: const Color(0xFF58A6FF),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            _buildHeader(),
            const SizedBox(height: 25),
            _buildStatsGrid(),
            const SizedBox(height: 25),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('next_appointment'.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            _buildFeaturedNextAppointment(),
            const SizedBox(height: 25),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('settings'.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            _buildQuickActionsRow(),
            const SizedBox(height: 25),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('todays_schedule'.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            _buildTodayTimeline(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                    'welcome_doc'.trParams({
                      'name': _profileController.fullName.value.isEmpty
                          ? 'unknown_name'.tr
                          : _profileController.fullName.value
                    }),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  )),
            ],
          ),
        ),
        
        // 🔔 زر الملاحظات والتقييمات الذكي مع العداد وتأثير الطوارئ
        Obx(() {
          int notesCount = _feedbackController.unreadCount.value;
          bool hasNotes = notesCount > 0;

          return Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: hasNotes
                      ? Colors.orangeAccent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasNotes ? Colors.orangeAccent : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.rate_review_outlined,
                    color: hasNotes
                        ? Colors.orangeAccent
                        : const Color(0xFF58A6FF),
                    size: 26,
                  ),
                  onPressed: () async {
                    await _feedbackController.fetchDashboardFeedbacks();
                    _feedbackController.markAllAsRead();
                    Get.to(() => const PatientFeedbackScreen());
                  },
                ),
              ),
              if (hasNotes)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _formatNumbers('$notesCount'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }),

        const SizedBox(width: 8),

        // 🚨 زر حالات الطوارئ
        Obx(() {
          bool hasEmergency = _dashboardController.emergencyCount.value > 0;
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  hasEmergency
                      ? Icons.campaign_rounded
                      : Icons.notifications_none_rounded,
                  color: hasEmergency ? Colors.redAccent : Colors.white70,
                  size: 28,
                ),
                onPressed: () {
                  Get.to(() => const EmergencyCasesView());
                },
              ),
              if (hasEmergency)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _formatNumbers('${_dashboardController.emergencyCount.value}'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
            child: _buildSmallStatCard(
                'patients_archive'.tr,
                _formatNumbers(_totalPatientsCount),
                Icons.people,
                Colors.orangeAccent)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildSmallStatCard(
                'todays_appts_stat'.tr,
                _formatNumbers(_todayAppointmentsCount),
                Icons.event_available,
                Colors.greenAccent)),
      ],
    );
  }

  Widget _buildSmallStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(title,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildFeaturedNextAppointment() {
    if (_nextPatientId == null ||
        _nextName == 'No appointments' ||
        _nextName == 'لا يوجد مواعيد قادمة' ||
        _nextName == 'no_appointments_today'.tr ||
        _nextName == 'no_appointments_today') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFF1B263B),
            borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            const CircleAvatar(
                backgroundColor: Colors.white12,
                child: Icon(Icons.alarm_off, color: Colors.white38)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('next_appointment'.tr,
                      style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  Text('no_appointments_today'.tr,
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    bool isInProgress = _nextStatus == 'InProgress';
    Color cardBorderColor = isInProgress ? const Color(0xFF58A6FF) : Colors.purpleAccent;
    String badgeText = isInProgress ? 'in_clinic_now'.tr : 'confirmed_appointment'.tr;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: cardBorderColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isInProgress
                    ? const Color(0xFF58A6FF).withValues(alpha: 0.2)
                    : Colors.purpleAccent.withValues(alpha: 0.2),
                child: Icon(isInProgress ? Icons.medical_services : Icons.alarm,
                    color: isInProgress
                        ? const Color(0xFF58A6FF)
                        : Colors.purpleAccent),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: cardBorderColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(badgeText,
                          style: TextStyle(
                              color: cardBorderColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Text(_nextName.contains('_') ? _nextName.tr : _nextName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                    if (_nextDescription.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _nextDescription,
                        style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontWeight: FontWeight.normal),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                  isInProgress
                      ? _formatNumbers(_formatRemainingTime())
                      : _formatNumbers(_formatTimeByLocale(_nextTime)),
                  style: TextStyle(
                      color: isInProgress
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          if (isInProgress) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(
                    _remainingSeconds < 120
                        ? Colors.redAccent
                        : const Color(0xFF58A6FF)),
                minHeight: 5,
              ),
            ),
          ],
          const SizedBox(height: 15),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          _isActionLoading
              ? const Center(
                  child: SizedBox(
                      height: 35,
                      width: 35,
                      child: CircularProgressIndicator(
                          color: Color(0xFF58A6FF), strokeWidth: 2.5)))
              : SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInProgress
                          ? const Color(0xFF0D1B2A)
                          : Colors.greenAccent,
                      foregroundColor: isInProgress ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: isInProgress
                          ? const BorderSide(color: Colors.white24)
                          : BorderSide.none,
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (isInProgress) {
                        _handleNextAppointmentStatusChange('Completed');
                      } else {
                        _handleNextAppointmentStatusChange('InProgress');
                      }
                    },
                    icon: Icon(
                        isInProgress
                            ? Icons.check_circle_outline
                            : Icons.play_arrow_rounded,
                        size: 20,
                        color: isInProgress ? Colors.tealAccent : Colors.black),
                    label: Text(
                        isInProgress
                            ? 'finish_appointment'.tr
                            : 'start_session'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _handleNextAppointmentStatusChange(String newStatus) async {
    int? idToSend = _nextAppointmentId;

    if (idToSend == null) {
      Get.snackbar('alert'.tr, 'error_occurred'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.black);
      return;
    }

    setState(() => _isActionLoading = true);

    final calendarController = Get.put(CalendarController());
    bool success = await calendarController.updateAppointmentStatus(idToSend, newStatus);

    setState(() {
      _isActionLoading = false;
    });

    if (success) {
      if (newStatus == 'Completed') {
        _appointmentTimer?.cancel();

        Get.snackbar('active_session_title'.tr, 'no_active_session'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.tealAccent,
            colorText: Colors.black);

        setState(() {
          _nextStatus = 'Confirmed';
          _nextPatientId = null;
          _nextAppointmentId = null;
          _remainingSeconds = 0;
          _nextName = 'no_appointments_today'.tr;
          _nextDescription = '';
        });

        _getDashboardData();
      } else if (newStatus == 'InProgress') {
        setState(() {
          _nextStatus = 'InProgress';
        });

        _startCountdown(
            _appointmentDurationMinutes > 0 ? _appointmentDurationMinutes : 30);

        Get.snackbar('start_session'.tr, 'processing_patient'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.greenAccent,
            colorText: Colors.black);
      }
    } else {
      Get.snackbar('alert'.tr, 'update_status_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }

  void _startCountdown(int minutes) {
    _appointmentTimer?.cancel();
    _totalSeconds = minutes * 60;
    _remainingSeconds = _totalSeconds;

    _appointmentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        _appointmentTimer?.cancel();
        Get.snackbar('alert'.tr, 'patient_alert'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.black);
      }
    });
  }

  String _formatRemainingTime() {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Widget _buildQuickActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _quickActionButton(
            Icons.person_add,
            'add_new_patient'.tr,
            () => Get.to(() => const AddPatientScreen()),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _quickActionButton(
            Icons.search,
            'search_patient'.tr,
            () => Get.to(() => const PatientSearchScreen()),
          ),
        ),
      ],
    );
  }

  Widget _quickActionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
                color: Color(0xFF1B263B), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF58A6FF), size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildTodayTimeline() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFF58A6FF)),
        ),
      );
    }

    final now = DateTime.now();

    final filteredList = _todayScheduleList.where((appointment) {
      final String status = (appointment['status'] ?? '').toString().toLowerCase();

      if (status == 'available' ||
          status == 'متاح' ||
          status == 'pending' ||
          status == 'مطلوب' ||
          status == 'processing' ||
          status == 'قيد التنفيذ') {
        return false;
      }

      String timeStr = appointment['appointment_time'] ?? '--:--';
      if (timeStr != '--:--') {
        try {
          final timeParts = timeStr.trim().split(':');
          final int hour = int.parse(timeParts[0]);
          final int minute = int.parse(timeParts[1]);
          final appDateTime = DateTime(now.year, now.month, now.day, hour, minute);

          return appDateTime.isAfter(now);
        } catch (_) {
          return true;
        }
      }
      return true;
    }).toList();

    if (filteredList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
            color: const Color(0xFF1B263B),
            borderRadius: BorderRadius.circular(25)),
        child: Center(
          child: Text(
            'no_appointments_today'.tr,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(25)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredList.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.white10, height: 1),
        itemBuilder: (context, index) {
          final appointment = filteredList[index];
          String timeStr = appointment['appointment_time'] ?? '--:--';

          if (timeStr == '--:--' && appointment['appointment_date'] != null) {
            try {
              DateTime dateUtc = DateTime.parse(appointment['appointment_date']);
              DateTime dateLocal = dateUtc.toLocal();
              timeStr = "${dateLocal.hour.toString().padLeft(2, '0')}:${dateLocal.minute.toString().padLeft(2, '0')}";
            } catch (_) {}
          }

          return _timelineTile(appointment, timeStr);
        },
      ),
    );
  }

  Widget _timelineTile(dynamic appointment, String time) {
    return InkWell(
      onTap: () => _showPatientOptionsSheet(context, appointment),
      borderRadius: BorderRadius.circular(25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Text(
              _formatNumbers(_formatTimeByLocale(time)),
              style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 20),
            Container(
              width: 2,
              height: 30,
              color: const Color(0xFF58A6FF).withValues(alpha: 0.4),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                appointment['patient_name'] ??
                    appointment['full_name'] ??
                    'unknown_name'.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _getStatusColor(appointment['status']),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(appointment['status']).withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Obx(() {
      String _ = _currentLanguage.value;
      bool isArabic = Get.locale?.languageCode == 'ar';

      Widget buildCustomLabel(String text, bool isSelected) {
        return Text(
          text,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
          style: TextStyle(
            fontSize: isArabic ? 10 : 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF58A6FF) : Colors.white38,
          ),
        );
      }

      return BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _currentLanguage.value = Get.locale?.languageCode ?? 'ar';
          });
        },
        backgroundColor: const Color(0xFF0F2033),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            label: '',
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.dashboard_rounded, color: Color(0xFF58A6FF)),
                const SizedBox(height: 4),
                buildCustomLabel('dashboard'.tr, true),
              ],
            ),
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.dashboard_rounded, color: Colors.white38),
                const SizedBox(height: 4),
                buildCustomLabel('dashboard'.tr, false),
              ],
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, color: Color(0xFF58A6FF)),
                const SizedBox(height: 4),
                buildCustomLabel('calendar_appts'.tr, true),
              ],
            ),
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, color: Colors.white38),
                const SizedBox(height: 4),
                buildCustomLabel('calendar_appts'.tr, false),
              ],
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_alt_rounded, color: Color(0xFF58A6FF)),
                const SizedBox(height: 4),
                buildCustomLabel('patients_archive'.tr, true),
              ],
            ),
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_alt_rounded, color: Colors.white38),
                const SizedBox(height: 4),
                buildCustomLabel('patients_archive'.tr, false),
              ],
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.settings_rounded, color: Color(0xFF58A6FF)),
                const SizedBox(height: 4),
                buildCustomLabel('settings'.tr, true),
              ],
            ),
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.settings_rounded, color: Colors.white38),
                const SizedBox(height: 4),
                buildCustomLabel('settings'.tr, false),
              ],
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_rounded, color: Color(0xFF58A6FF)),
                const SizedBox(height: 4),
                buildCustomLabel('doctor_info'.tr, true),
              ],
            ),
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_rounded, color: Colors.white38),
                const SizedBox(height: 4),
                buildCustomLabel('doctor_info'.tr, false),
              ],
            ),
          ),
        ],
      );
    });
  }
}