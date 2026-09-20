import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sec_dent_ai/controllers/emergency_controller.dart';
import 'package:sec_dent_ai/models/emergency_model.dart';

class EmergencyCasesView extends StatefulWidget {
  const EmergencyCasesView({super.key});

  @override
  State<EmergencyCasesView> createState() => _EmergencyCasesViewState();
}

class _EmergencyCasesViewState extends State<EmergencyCasesView> {
  final EmergencyController _controller = EmergencyController();
  late Future<List<EmergencyCase>> _futureCases;

  static const Color bgColor = Color(0xFF0F162A);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color accentRed = Color(0xFFE11D48);
  static const Color textWhite = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _futureCases = _controller.fetchEmergencyCases();
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'emergency_requests'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textWhite),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textWhite),
      ),
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: FutureBuilder<List<EmergencyCase>>(
          future: _futureCases,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: accentRed));
            } else if (snapshot.hasError) {
              return Center(
                child: Text('${'error_occurred'.tr}: ${snapshot.error}', style: const TextStyle(color: accentRed)),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('no_emergency_cases'.tr, style: const TextStyle(color: textMuted, fontSize: 16)),
              );
            }

            final cases = snapshot.data!;
            return RefreshIndicator(
              color: accentRed,
              onRefresh: () async {
                setState(() {
                  _futureCases = _controller.fetchEmergencyCases();
                });
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cases.length,
                itemBuilder: (context, index) {
                  final item = cases[index];
                  return _buildEmergencyCard(item);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(EmergencyCase item) {
    return Card(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.patientName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textWhite),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentRed.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(
                    item.urgencyLevel == 'critical' ? 'critical_label'.tr : item.urgencyLevel,
                    style: const TextStyle(
                      color: accentRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "${'complaint_label'.tr}: ${item.message}",
              style: const TextStyle(fontSize: 14, color: textWhite, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: textMuted),
                const SizedBox(width: 6),
                Text(
                  "${'request_date_label'.tr}: ${item.createdAt.toLocal().toString().substring(0, 16)}",
                  style: const TextStyle(color: textMuted, fontSize: 12),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Divider(color: Color(0xFF334155), height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  onPressed: () => _showDetailsDialog(item),
                  icon: const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 18),
                  label: Text(
                    'details_btn'.tr,
                    style: const TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade400.withValues(alpha: 0.6)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _handleReject(item),
                    child: Text(
                      'reject_request_btn'.tr,
                      style: TextStyle(color: Colors.red.shade400, fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () => _handleAccept(item),
                    child: Text(
                      'accept_schedule_btn'.tr,
                      style: const TextStyle(color: textWhite, fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleReject(EmergencyCase item) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    bool confirm = await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('confirm_reject_title'.tr, style: const TextStyle(color: textWhite, fontWeight: FontWeight.bold)),
          content: Text(
            "${'confirm_reject_body'.tr} ${item.patientName}؟ ${'confirm_reject_note'.tr}",
            style: const TextStyle(color: textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('none'.tr, style: const TextStyle(color: textMuted)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('yes_reject_btn'.tr, style: const TextStyle(color: accentRed, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ) ?? false;

    if (!confirm || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: accentRed)),
    );

    bool success = await _controller.rejectEmergencyCase(item.emergencyId);

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${'request_rejected_success'.tr} ${item.patientName} ❌'),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      setState(() {
        _futureCases = _controller.fetchEmergencyCases();
      });
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('server_error_reject'.tr), backgroundColor: accentRed),
      );
    }
  }

  void _showDetailsDialog(EmergencyCase item) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "${'medical_file_for'.tr} ${item.patientName}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textWhite),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.phone_rounded, 'phone_number_label'.tr, item.phoneNumber),
                  _buildInfoRow(Icons.person_rounded, 'gender_label'.tr, item.gender == 'male' ? 'male_gender'.tr : 'female_gender'.tr),
                  _buildInfoRow(Icons.cake_rounded, 'birth_date_label'.tr,
                      (item.dateOfBirth != null && item.dateOfBirth!.length >= 10)
                          ? item.dateOfBirth!.substring(0, 10)
                          : (item.dateOfBirth ?? 'unspecified_label'.tr)),
                  _buildInfoRow(Icons.history_edu_rounded, 'medical_history_label'.tr, item.medicalHistory ?? 'no_medical_history'.tr),
                  const Divider(color: Color(0xFF334155), height: 24),

                  if (item.xrayImageUrl != null) ...[
                    Text(
                      'xray_attached_hint'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textMuted),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showZoomableImage(item.xrayImageUrl!),
                      child: Hero(
                        tag: item.emergencyId,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.xrayImageUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              height: 100,
                              color: Colors.black26,
                              alignment: Alignment.center,
                              child: Text('image_load_error'.tr, style: const TextStyle(color: textMuted)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close_btn'.tr, style: const TextStyle(color: textMuted, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textMuted),
          const SizedBox(width: 8),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold, color: textMuted, fontSize: 14)),
          Expanded(child: Text(value, style: const TextStyle(color: textWhite, fontSize: 14))),
        ],
      ),
    );
  }

  void _showZoomableImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: textWhite, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAccept(EmergencyCase item) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'pick_time_help_text'.tr,
      cancelText: 'none'.tr,
      confirmText: 'confirm_time_btn'.tr,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: accentRed,
            onPrimary: textWhite,
            surface: cardColor,
            onSurface: textWhite,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: cardColor),
        ),
        child: child!,
      ),
    );

    if (pickedTime == null || !mounted) return;

    final now = DateTime.now();
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    String formattedConflictTime = selectedDateTime.toString().substring(0, 19);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: accentRed)),
    );

    bool success = await _controller.acceptAndScheduleCase(
      item.emergencyId,
      item.patientId,
      formattedConflictTime,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${'request_accepted_success_prefix'.tr} ${item.patientName} ${'request_accepted_success_suffix_1'.tr} ${pickedTime.format(context)} ${'request_accepted_success_suffix_2'.tr}'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
      setState(() {
        _futureCases = _controller.fetchEmergencyCases();
      });
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('server_error_accept'.tr), backgroundColor: accentRed),
      );
    }
  }
}