class MySubscriptionRecordModel {
  final int id;
  final String status; // active, pending, expired, rejected
  final int isActive; // 1 للفعال حالياً، 0 لغير الفعال
  final String? startDate;
  final String? endDate;
  final String? processNumber;
  final String? confirmedAt;
  final int? countPlan;
  final double amount;
  final String currency;
  final SubscriptionInfoModel? subscription;

  MySubscriptionRecordModel({
    required this.id,
    required this.status,
    required this.isActive,
    this.startDate,
    this.endDate,
    this.processNumber,
    this.confirmedAt,
    this.countPlan,
    required this.amount,
    required this.currency,
    this.subscription,
  });

  factory MySubscriptionRecordModel.fromJson(Map<String, dynamic> json) {
    return MySubscriptionRecordModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'pending',
      isActive: json['is_active'] ?? 0,
      startDate: json['start_date'],
      endDate: json['end_date'],
      processNumber: json['process_number']?.toString(),
      confirmedAt: json['confirmed_at'],
      countPlan: json['count_plan'],
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString()) ?? 0.0
          : 0.0,
      currency: json['currency'] ?? 'USD',
      subscription: json['subscription'] != null
          ? SubscriptionInfoModel.fromJson(json['subscription'])
          : null,
    );
  }

  // دالة مساعدة لتنسيق التاريخ بدون الساعات YYYY-MM-DD
  static String formatDateOnly(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(rawDate);
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    } catch (_) {
      // في حال جاء التاريخ بتنسيق غير قياسي
      if (rawDate.contains('T')) {
        return rawDate.split('T').first;
      }
      if (rawDate.contains(' ')) {
        return rawDate.split(' ').first;
      }
      return rawDate;
    }
  }
}

class SubscriptionInfoModel {
  final int id;
  final String title;
  final String? description;
  final String? type; // gold, silver, etc.
  final CoachInfoModel? coach;

  SubscriptionInfoModel({
    required this.id,
    required this.title,
    this.description,
    this.type,
    this.coach,
  });

  factory SubscriptionInfoModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfoModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      type: json['type'],
      coach: json['coach'] != null
          ? CoachInfoModel.fromJson(json['coach'])
          : null,
    );
  }
}

class CoachInfoModel {
  final int id;
  final String fullName;

  CoachInfoModel({required this.id, required this.fullName});

  factory CoachInfoModel.fromJson(Map<String, dynamic> json) {
    return CoachInfoModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
    );
  }
}