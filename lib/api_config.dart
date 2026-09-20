class ApiConfig {
  // 🎯 الرابط الأساسي للـ Backend API
  static const String baseUrl = 'http://10.189.225.163:3000';

  // روابط المصادقة والملف الشخصي
  static const String login = '$baseUrl/api/auth/login';
  static const String logout = '$baseUrl/api/auth/logout';
  static const String profileDoctor = '$baseUrl/api/profile';
  static const String updateProfileDoctor = '$baseUrl/api/profile/update';

  // روابط إدارة المرضى والأرشيف
  static const String addPatient = '$baseUrl/api/patients/add';
  static const String archive = '$baseUrl/api/patients_archive';
  static const String getAllPatient = '$baseUrl/api/patients/get_all_patient';
  static const String searchPatient = '$baseUrl/api/patients/search';
  static const String countOfPatients = '$baseUrl/api/patients/count';
  static const String patientProfile = '$baseUrl/api/patients/profile';
  static const String getFeedbacks = '$baseUrl/api/patients/feedbacks';

  // روابط مخطط الأسنان (Dental Chart)
  static const String dentalChart = '$baseUrl/api/patients/dental-chart';
  static const String dentalChartOnSave = '$baseUrl/api/patients/dental-chart/save';

  // روابط المواعيد واللوحة الرئيسية
  static const String getStats = '$baseUrl/api/dashboard_stats';
  static const String dashboardStats = '$baseUrl/api/appointments/stats/1';
  static const String bookedSlots = '$baseUrl/api/appointments/booked-slots';
  static const String createAppts = '$baseUrl/api/appointments/create';
  static const String getAppointmentsToday = '$baseUrl/api/appointments/today';
  static const String nextAppointment = '$baseUrl/api/appointments/next';
  static const String appointmentsByDate = '$baseUrl/api/appointments/by-date';
  static const String appointmentsStats = '$baseUrl/api/appointments/stats';
  static const String updateStatus = '$baseUrl/api/appointments/update-status';

  // روابط الإعدادات وطلبات المختبر والأشعة
  static const String getSettings = '$baseUrl/api/settings/get';
  static const String settingsUpdate = '$baseUrl/api/settings/update';
  static const String sendLabRequest = '$baseUrl/api/lab/create';
  static const String xrayPatients = '$baseUrl/api/xrays/patient/xrays';

  // روابط الحالات الطارئة
  static const String getEmergency = '$baseUrl/api/emergency/getEmergencyCases';
  static const String acceptAndSchedule = '$baseUrl/api/emergency/accept-and-schedule';
  static const String rejectEmergency = '$baseUrl/api/emergency/reject';

  // دالة جلب الأشعة المخصصة لكل مريض
  static String getPatientXrays(int patientId) {
    return '$baseUrl/api/xrays/patient/$patientId';
  }

  // ⚠️ أسماء بديلة للتوافق مع الأكواد القديمة
  static const String Logout = logout;
  static const String patientprofile = patientProfile;
  static const String DentalChart = dentalChart;
  static const String DentalChartOnSave = dentalChartOnSave;
  static const String BookedSlots = bookedSlots;
  static const String CreateAppts = createAppts;
  static const String getAppoitmentsToday = getAppointmentsToday;
  static const String SearchPatient = searchPatient;
  static const String Settings_Update = settingsUpdate;
  static const String ProfileDoctor = profileDoctor;
  static const String UpdateProfileDoctor = updateProfileDoctor;
}