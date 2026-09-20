import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/calendar_controller.dart';
import '../../models/appointment_model.dart';

class NextAppointmentCard extends StatefulWidget {
  final AppointmentModel appointment;
  final VoidCallback onRefresh;

  const NextAppointmentCard({
    super.key,
    required this.appointment,
    required this.onRefresh,
  });

  @override
  State<NextAppointmentCard> createState() => _NextAppointmentCardState();
}

class _NextAppointmentCardState extends State<NextAppointmentCard> {
  final CalendarController _calendarController = Get.find<CalendarController>();
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.appointment;

    String statusText = 'confirmed_appt_status'.tr;
    Color statusColor = Colors.purpleAccent;
    Widget? actionButton;

    if (p.status == 'Confirmed' || p.status == 'confirmed' || p.status == 'booked') {
      actionButton = _buildButton('start_session_btn'.tr, Colors.greenAccent, Colors.black, Icons.play_arrow, 'InProgress');
    }
    else if (p.status == 'InProgress' || p.status == 'inProgress' || p.status == 'busy') {
      statusText = 'inside_clinic_status'.tr;
      statusColor = const Color(0xFF58A6FF);
      actionButton = _buildButton('end_session_btn'.tr, const Color(0xFF0D1B2A), Colors.white, Icons.check, 'Completed');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('next_appointment_label'.tr, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              _buildBadge(statusText, statusColor),
            ],
          ),
          const SizedBox(height: 15),
          Text(p.patientName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Color(0xFF58A6FF), size: 16),
              const SizedBox(width: 6),
              Text(p.time, style: const TextStyle(color: Color(0xFF58A6FF), fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              const Icon(Icons.medical_services_outlined, color: Colors.white38, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(p.treatmentType, style: const TextStyle(color: Colors.white38, fontSize: 13), overflow: TextOverflow.ellipsis)),
            ],
          ),

          if (actionButton != null) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 15),
            _isUpdating
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : actionButton,
          ]
        ],
      ),
    );
  }

  Widget _buildButton(String title, Color bg, Color textCol, IconData icon, String nextStatus) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: textCol,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () => _updateStatus(nextStatus),
        icon: Icon(icon, size: 20),
        label: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    bool success = await _calendarController.updateAppointmentStatus(widget.appointment.appointmentId, status);

    if (!mounted) return;
    setState(() => _isUpdating = false);

    if (success) {
      widget.onRefresh();
    } else {
      Get.snackbar('error_title'.tr, 'failed_update_status'.tr, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}