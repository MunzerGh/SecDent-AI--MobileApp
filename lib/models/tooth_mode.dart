// 🎨 الحالات الخمسة المعتمدة للسن بمشروعك
enum ToothStatus {
  healthy, // سليم
  decayed, // تسوس
  rootCanal, // سحب عصب
  rootAndFill, // سحب عصب + حشوة
  missing, // مفقود / قلع
}

class Tooth {
  final int number; // رقم السن من 1 إلى 32
  ToothStatus status; // حالة السن الحالية

  Tooth({
    required this.number,
    required this.status,
  });

  // تحويل البيانات القادمة من الـ API إلى كائن Tooth
  factory Tooth.fromJson(Map<String, dynamic> json) {
    return Tooth(
      number: json['tooth_number'] ?? 0,
      status: _parseStatus(json['status']),
    );
  }

  // تحويل كائن Tooth إلى Map لإرساله للباكيند عند الحفظ
  Map<String, dynamic> toJson() {
    return {
      'tooth_number': number,
      'status': status.name,
    };
  }

  // دالة مساعدة لتحويل النص القادم من قاعدة البيانات إلى Enum
  static ToothStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'decayed':
        return ToothStatus.decayed;
      case 'rootCanal':
        return ToothStatus.rootCanal;
      case 'rootAndFill':
        return ToothStatus.rootAndFill;
      case 'missing':
        return ToothStatus.missing;
      default:
        return ToothStatus.healthy;
    }
  }
}