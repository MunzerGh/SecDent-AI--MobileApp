import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/appointment_controller.dart';

class BookAppointmentScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const BookAppointmentScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  late final AppointmentController appointmentController;

  final TextEditingController _durationController = TextEditingController();
  int? _selectedTreatmentId;
  String _treatmentDescriptionKey = '';

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;

  final List<String> _clinicHours = const [
    '10:00', '10:45', '11:30', '12:15', '13:00', '13:45',
    '14:30', '15:15', '16:00', '16:45'
  ];

  final List<Map<String, dynamic>> _treatmentsList = const [
    {'id': 1, 'name': 'treatment_exam', 'default_duration': 15},
    {'id': 2, 'name': 'treatment_extraction', 'default_duration': 30},
    {'id': 3, 'name': 'treatment_filling', 'default_duration': 30},
    {'id': 4, 'name': 'treatment_root_canal', 'default_duration': 45},
    {'id': 5, 'name': 'treatment_ortho', 'default_duration': 20},
    {'id': 6, 'name': 'treatment_whitening', 'default_duration': 40},
    {'id': 7, 'name': 'treatment_implant', 'default_duration': 60}
  ];

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

  @override
  void initState() {
    super.initState();
    appointmentController = Get.isRegistered<AppointmentController>()
        ? Get.find<AppointmentController>()
        : Get.put(AppointmentController());
    _fetchSlotsForSelectedDate();
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  void _fetchSlotsForSelectedDate() {
    final String formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    appointmentController.fetchBookedSlots(formattedDate);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF58A6FF),
              onPrimary: Colors.black,
              surface: Color(0xFF1B263B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null;
      });
      _fetchSlotsForSelectedDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text('book_new_appointment'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF0F2033),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: const Color(0xFF58A6FF).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF0D1B2A),
                    child: Icon(Icons.person, color: Color(0xFF58A6FF)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('current_patient_label'.tr,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                        Text(widget.patientName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text(
                            'ID: #${_formatNumbers(widget.patientId.toString())}',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Text('select_date_label'.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                    color: const Color(0xFF1B263B),
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatNumbers(formattedDate),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const Icon(Icons.calendar_month, color: Color(0xFF58A6FF)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text('available_slots_label'.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Obx(() {
              if (appointmentController.isLoadingSlots.value) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                            color: Color(0xFF58A6FF))));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _clinicHours.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  final String time = _clinicHours[index];
                  final bool isBooked =
                      appointmentController.bookedSlots.contains(time);
                  final bool isSelected = _selectedTimeSlot == time;

                  return InkWell(
                    onTap: isBooked
                        ? null
                        : () => setState(() => _selectedTimeSlot = time),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isBooked
                            ? Colors.redAccent.withValues(alpha: 0.1)
                            : isSelected
                                ? const Color(0xFF58A6FF)
                                : const Color(0xFF1B263B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isBooked
                                ? Colors.redAccent
                                : isSelected
                                    ? Colors.transparent
                                    : Colors.white10),
                      ),
                      child: Center(
                        child: Text(
                          _formatNumbers(time),
                          style: TextStyle(
                            color: isBooked
                                ? Colors.redAccent
                                : isSelected
                                    ? Colors.black
                                    : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 25),
            Text('treatment_type_label'.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  color: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(15)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedTreatmentId,
                  dropdownColor: const Color(0xFF1B263B),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Color(0xFF58A6FF)),
                  hint: Text('select_treatment_hint'.tr,
                      style: const TextStyle(color: Colors.white38)),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items: _treatmentsList.map((treatment) {
                    return DropdownMenuItem<int>(
                      value: treatment['id'] as int,
                      child: Text(treatment['name'].toString().tr),
                    );
                  }).toList(),
                  onChanged: (newId) {
                    if (newId != null) {
                      setState(() {
                        _selectedTreatmentId = newId;
                        final selected = _treatmentsList
                            .firstWhere((el) => el['id'] == newId);
                        _durationController.text =
                            selected['default_duration'].toString();
                        _treatmentDescriptionKey = selected['name'].toString();
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text('duration_label'.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                fillColor: const Color(0xFF1B263B),
                filled: true,
                hintText: 'duration_hint'.tr,
                hintStyle: const TextStyle(color: Colors.white38),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: appointmentController.isSubmitting.value
                      ? null
                      : () async {
                          if (_selectedTimeSlot == null) {
                            Get.snackbar('warning_title'.tr,
                                'select_time_warning'.tr,
                                backgroundColor: Colors.orangeAccent,
                                colorText: Colors.black,
                                snackPosition: SnackPosition.BOTTOM);
                            return;
                          }

                          final int? durationToSend =
                              _durationController.text.trim().isEmpty
                                  ? null
                                  : int.tryParse(_durationController.text.trim());

                          final String finalDescription =
                              _treatmentDescriptionKey.isEmpty
                                  ? 'general_appt_desc'.tr
                                  : _treatmentDescriptionKey.tr;

                          final bool isSuccess =
                              await appointmentController.createAppointment(
                            patientId: widget.patientId,
                            treatmentId: _selectedTreatmentId ?? 1,
                            durationMinutes: durationToSend ?? 30,
                            date: formattedDate,
                            time: _selectedTimeSlot!,
                            description: finalDescription,
                          );

                          if (isSuccess) {
                            Get.back();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58A6FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: appointmentController.isSubmitting.value
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text('confirm_booking_btn'.tr,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}