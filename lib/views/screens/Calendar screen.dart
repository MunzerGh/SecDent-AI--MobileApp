import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' as intl;

import '../../controllers/calendar_controller.dart';
import '../../models/appointment_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  late final CalendarController _controller;

  List<AppointmentModel> _appointments = [];

  double _available = 0,
      _confirmed = 0,
      _inProgress = 0,
      _cancelled = 0,
      _completed = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<CalendarController>()
        ? Get.find<CalendarController>()
        : Get.put(CalendarController());
    _fetchData(_selectedDate);
  }

  String _convertMonthToLevantine(String text) {
    if (Get.locale?.languageCode != 'ar') return text;

    const monthMap = {
      'يناير': 'كانون الثاني',
      'فبراير': 'شباط',
      'مارس': 'آذار',
      'أبريل': 'نيسان',
      'مايو': 'أيار',
      'يونيو': 'حزيران',
      'يوليو': 'تموز',
      'أغسطس': 'آب',
      'سبتمبر': 'أيلول',
      'أكتوبر': 'تشرين الأول',
      'نوفمبر': 'تشرين الثاني',
      'ديسمبر': 'كانون الأول',
    };

    String updatedText = text;
    monthMap.forEach((egyptian, levantine) {
      updatedText = updatedText.replaceAll(egyptian, levantine);
    });
    return updatedText;
  }

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

  String _formatTimeByLocale(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty || timeStr == '--:--') {
      return '--:--';
    }
    try {
      final currentLocale = Get.locale?.languageCode ?? 'ar';
      final dummyDate = DateTime.parse('2026-01-01 ${timeStr.trim()}');
      String formattedTime = intl.DateFormat.jm(currentLocale).format(dummyDate);

      if (currentLocale == 'ar') {
        formattedTime = formattedTime.replaceAll('PM', 'م').replaceAll('AM', 'ص');
      }
      return formattedTime;
    } catch (_) {
      if (Get.locale?.languageCode == 'ar') {
        return timeStr.toUpperCase().replaceAll('PM', 'م').replaceAll('AM', 'ص');
      }
      return timeStr;
    }
  }

  Future<void> _fetchData(DateTime date) async {
    setState(() => _isLoading = true);
    try {
      _appointments.clear();
      final appointments = await _controller.fetchAppointmentsForDate(date);
      final stats = await _controller.fetchStatsForDate(date);

      if (!mounted) return;

      setState(() {
        final filtered = appointments.where((app) {
          final String status = app.status.trim().toLowerCase();
          return status != 'requested' &&
              status != 'مطلوب' &&
              !status.contains('طلب');
        }).toList();

        final now = DateTime.now();
        if (date.year == now.year &&
            date.month == now.month &&
            date.day == now.day) {
          _appointments = filtered.where((app) {
            if (app.time.trim().isEmpty) return true;
            try {
              final timeParts = app.time.trim().split(':');
              final int hour = int.parse(timeParts[0]);
              final int minute = int.parse(timeParts[1]);
              final appDateTime =
                  DateTime(now.year, now.month, now.day, hour, minute);

              return appDateTime.isAfter(now);
            } catch (_) {
              return true;
            }
          }).toList();
        } else {
          _appointments = filtered;
        }

        _available = (stats['available'] ?? 0).toDouble();
        _confirmed = (stats['confirmed'] ?? 0).toDouble();
        _inProgress = (stats['inProgress'] ?? 0).toDouble();
        _cancelled = (stats['cancelled'] ?? 0).toDouble();
        _completed = (stats['completed'] ?? 0).toDouble();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching calendar data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changeMonth(int monthsToAdd) {
    setState(() {
      _selectedDate =
          DateTime(_selectedDate.year, _selectedDate.month + monthsToAdd, 1);
    });
    _fetchData(_selectedDate);
  }

  void _showContactOptionsBottomSheet(AppointmentModel appointment) {
    final String? phoneNumber = appointment.phone;
    final String patientName = appointment.patientName.isNotEmpty
        ? appointment.patientName
        : (Get.locale?.languageCode == 'ar' ? 'المريض' : 'Patient');

    final bool hasPhone = phoneNumber != null &&
        phoneNumber.trim().isNotEmpty &&
        phoneNumber.trim() != 'null' &&
        phoneNumber.trim() != '0';

    final String cleanPhone =
        hasPhone ? phoneNumber.trim().replaceAll(RegExp(r'\s+'), '') : '';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1B263B),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text(
                "${Get.locale?.languageCode == 'ar' ? "الاتصال بالمريض" : "Contact Patient"}: $patientName",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              ListTile(
                enabled: hasPhone,
                trailing: CircleAvatar(
                  backgroundColor: hasPhone
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.withValues(alpha: 0.2),
                  child: const Icon(Icons.phone_rounded, color: Colors.white),
                ),
                title: Text(
                  Get.locale?.languageCode == 'ar'
                      ? 'اتصال عادي'
                      : 'Normal Call',
                  style: TextStyle(
                      color: hasPhone
                          ? const Color(0xFF2E7D32)
                          : Colors.white38,
                      fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Get.back();
                  final Uri url = Uri(scheme: 'tel', path: cleanPhone);
                  if (await canLaunchUrl(url)) await launchUrl(url);
                },
              ),
              const Divider(color: Colors.white12, height: 1),
              ListTile(
                enabled: hasPhone,
                trailing: CircleAvatar(
                  backgroundColor: hasPhone
                      ? const Color(0xFF1976D2)
                      : Colors.grey.withValues(alpha: 0.2),
                  child: const Icon(Icons.chat_bubble_rounded,
                      color: Colors.white, size: 20),
                ),
                title: Text(
                  Get.locale?.languageCode == 'ar'
                      ? 'إرسال رسالة SMS'
                      : 'SMS Message',
                  style: TextStyle(
                      color: hasPhone
                          ? const Color(0xFF1976D2)
                          : Colors.white38,
                      fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Get.back();
                  final Uri smsUri = Uri.parse('sms:$cleanPhone');
                  await launchUrl(smsUri,
                      mode: LaunchMode.externalNonBrowserApplication);
                },
              ),
              const Divider(color: Colors.white12, height: 1),
              ListTile(
                enabled: hasPhone,
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasPhone
                        ? const Color(0xFF25D366)
                        : Colors.grey.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                title: Text(
                  Get.locale?.languageCode == 'ar' ? 'واتساب' : 'WhatsApp',
                  style: TextStyle(
                      color: hasPhone
                          ? const Color(0xFF25D366)
                          : Colors.white38,
                      fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Get.back();
                  final Uri url = Uri.parse('https://wa.me/$cleanPhone');
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Column(
        children: [
          const SizedBox(height: 60),
          _buildMonthHeader(isArabic),
          _buildWeeklyCalendar(isArabic),
          const SizedBox(height: 20),
          _buildCircularStats(isArabic),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
                alignment:
                    isArabic ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                    isArabic ? 'قائمة المواعيد' : 'Appointments List',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.bold))),
          ),
          Expanded(child: _buildAppointmentList(isArabic)),
        ],
      ),
    );
  }

  Widget _buildCircularStats(bool isArabic) {
    final statusList = [
      {'labelAr': 'متاح', 'labelEn': 'Available', 'count': _available, 'color': Colors.green},
      {'labelAr': 'مؤكد', 'labelEn': 'Confirmed', 'count': _confirmed, 'color': Colors.purpleAccent},
      {'labelAr': 'قيد التنفيذ', 'labelEn': 'In Progress', 'count': _inProgress, 'color': const Color(0xFF58A6FF)},
      {'labelAr': 'ملغي', 'labelEn': 'Cancelled', 'count': _cancelled, 'color': Colors.redAccent},
      {'labelAr': 'مكتمل', 'labelEn': 'Completed', 'count': _completed, 'color': Colors.tealAccent},
    ];

    final double total = _available + _confirmed + _inProgress + _cancelled + _completed;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            width: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  key: ValueKey(_selectedDate.toString() + Get.locale.toString()),
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 55,
                    borderData: FlBorderData(show: false),
                    sections: [
                      PieChartSectionData(
                          color: Colors.green,
                          value: _available > 0 ? _available : (total == 0 ? 1 : 0),
                          radius: 20,
                          title: ''),
                      PieChartSectionData(
                          color: Colors.purpleAccent,
                          value: _confirmed,
                          radius: 20,
                          title: ''),
                      PieChartSectionData(
                          color: const Color(0xFF58A6FF),
                          value: _inProgress,
                          radius: 20,
                          title: ''),
                      PieChartSectionData(
                          color: Colors.redAccent,
                          value: _cancelled,
                          radius: 20,
                          title: ''),
                      PieChartSectionData(
                          color: Colors.tealAccent,
                          value: _completed,
                          radius: 20,
                          title: ''),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatNumbers('${_appointments.length}'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(isArabic ? 'موعد' : 'Appts',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: 12.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.center,
              children: statusList.map((status) {
                return _buildWrapIndicator(
                  isArabic
                      ? status['labelAr'] as String
                      : status['labelEn'] as String,
                  _formatNumbers(
                      (status['count'] as double).toInt().toString()),
                  status['color'] as Color,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWrapIndicator(String label, String count, Color col) => IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Text('($count)',
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      );

  Widget _buildAppointmentList(bool isArabic) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }
    if (_appointments.isEmpty) {
      return Center(
          child: Text(
              isArabic
                  ? 'لا توجد مواعيد متبقية اليوم'
                  : 'No remaining appointments today',
              style: const TextStyle(color: Colors.white38)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _appointments.length,
      itemBuilder: (context, i) => _card(_appointments[i], isArabic),
    );
  }

  Widget _card(AppointmentModel p, bool isArabic) {
    String statusText = '';
    Color statusColor = Colors.transparent;
    final String rawStatus = p.status.trim().toLowerCase();

    if (rawStatus == 'available' || rawStatus == 'متاح') {
      statusText = isArabic ? 'متاح' : 'Available';
      statusColor = Colors.green;
    } else if (rawStatus == 'confirmed' ||
        rawStatus == 'booked' ||
        rawStatus == 'مؤكد') {
      statusText = isArabic ? 'مؤكد' : 'Confirmed';
      statusColor = Colors.purpleAccent;
    } else if (rawStatus == 'inprogress' ||
        rawStatus == 'busy' ||
        rawStatus == 'قيد التنفيذ') {
      statusText = isArabic ? 'قيد التنفيذ' : 'In Progress';
      statusColor = const Color(0xFF58A6FF);
    } else if (rawStatus == 'cancelled' ||
        rawStatus == 'ملغي' ||
        rawStatus == 'ملغى') {
      statusText = isArabic ? 'ملغي' : 'Cancelled';
      statusColor = Colors.redAccent;
    } else if (rawStatus == 'completed' || rawStatus == 'مكتمل') {
      statusText = isArabic ? 'مكتمل' : 'Completed';
      statusColor = Colors.tealAccent;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Text(_formatNumbers(_formatTimeByLocale(p.time)),
              style: const TextStyle(
                  color: Color(0xFF58A6FF), fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  p.patientName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showContactOptionsBottomSheet(p),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.greenAccent.withValues(alpha: 0.4),
                      width: 1)),
              child: const Icon(Icons.phone_in_talk_rounded,
                  color: Colors.greenAccent, size: 15),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: statusColor.withValues(alpha: 0.5), width: 1)),
            child: Text(statusText,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(bool isArabic) {
    final String formattedMonthYear =
        intl.DateFormat.yMMMM(isArabic ? 'ar' : 'en').format(_selectedDate);

    List<DateTime> generateMonthsList() {
      final List<DateTime> months = [];
      for (int i = -6; i <= 6; i++) {
        months.add(DateTime(DateTime.now().year, DateTime.now().month + i, 1));
      }
      return months;
    }

    final String mainHeaderDisplay =
        _formatNumbers(_convertMonthToLevantine(formattedMonthYear));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
              onPressed: () => _changeMonth(-1)),
          PopupMenuButton<DateTime>(
            offset: const Offset(0, 45),
            color: const Color(0xFF1B263B),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (DateTime pickedDate) {
              if (pickedDate.month != _selectedDate.month ||
                  pickedDate.year != _selectedDate.year) {
                setState(() {
                  _selectedDate = DateTime(
                      pickedDate.year, pickedDate.month, _selectedDate.day);
                });
                _fetchData(_selectedDate);
              }
            },
            child: Row(children: [
              Text(mainHeaderDisplay,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_drop_down_rounded,
                  color: Colors.white70, size: 28)
            ]),
            itemBuilder: (BuildContext context) {
              return generateMonthsList().map((DateTime monthDate) {
                final String monthLabel =
                    intl.DateFormat.yMMMM(isArabic ? 'ar' : 'en')
                        .format(monthDate);
                final bool isCurrentText =
                    monthDate.month == _selectedDate.month &&
                        monthDate.year == _selectedDate.year;

                final String dropDownDisplay =
                    _formatNumbers(_convertMonthToLevantine(monthLabel));

                return PopupMenuItem<DateTime>(
                  value: monthDate,
                  child: Align(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(dropDownDisplay,
                          style: TextStyle(
                              color: isCurrentText
                                  ? const Color(0xFF58A6FF)
                                  : Colors.white,
                              fontWeight: isCurrentText
                                  ? FontWeight.bold
                                  : FontWeight.normal))),
                );
              }).toList();
            },
          ),
          IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white, size: 30),
              onPressed: () => _changeMonth(1)),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar(bool isArabic) {
    final int daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daysInMonth,
        itemBuilder: (context, i) {
          final DateTime date =
              DateTime(_selectedDate.year, _selectedDate.month, i + 1);
          final bool isSelected = _selectedDate.day == date.day &&
              _selectedDate.month == date.month &&
              _selectedDate.year == date.year;
          final String dayName =
              intl.DateFormat.E(isArabic ? 'ar' : 'en').format(date);
          final String displayDay =
              isArabic ? dayName : dayName.substring(0, 2);
          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              _fetchData(date);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF58A6FF)
                      : const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(displayDay,
                      style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white54,
                          fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(_formatNumbers('${i + 1}'),
                      style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}