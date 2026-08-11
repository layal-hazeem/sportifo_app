import '../../../workout/data/models/exercise_model.dart';

class PlanModel {
  final int id;
  final String status;
  final bool isSelfMade;
  final CoachInfo? coach;
  final String? type;
  final String? image;
  final String? goal;
  final int? durationMonths;
  final int? daysCount;
  final String? createdAt;

  // 🔥 1. إضافة متغير السيف (بدون final ليكون قابل للتعديل من الكيوبيت)
  bool isSaved;

  final List<PlanDayModel> days;

  PlanModel({
    required this.id,
    required this.status,
    required this.isSelfMade,
    this.coach,
    this.goal,
    this.durationMonths,
    this.daysCount,
    this.createdAt,
    required this.days,
    this.type,
    this.image,
    this.isSaved = false, // 👈 2. قيمة افتراضية بالكونستراكتور
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'unknown',
      isSelfMade: json['is_self_made'] == 1 || json['is_self_made'] == true,
      coach: json['coach'] != null ? CoachInfo.fromJson(json['coach']) : null,
      goal: json['goal'],
      durationMonths: json['duration_months'],
      daysCount: json['days_count'],
      createdAt: json['created_at'],
      type: json['type'],
      image: json['image'],

      // 👈 3. قراءة حالة الحفظ من الباك إند (إذا كانت موجودة)
      isSaved: json['is_saved'] == 1 || json['is_saved'] == true,

      days: json['days'] != null
          ? List<PlanDayModel>.from(
        json['days'].map((x) => PlanDayModel.fromJson(x)),
      )
          : [],
    );
  }
}

// 2. معلومات الكوتش المصغرة التي تأتي مع الخطة
class CoachInfo {
  final int id;
  final String fullName;
  final String profilePic;

  CoachInfo({
    required this.id,
    required this.fullName,
    required this.profilePic,
  });

  factory CoachInfo.fromJson(Map<String, dynamic> json) {
    return CoachInfo(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      profilePic: json['profile_pic'] ?? '',
    );
  }
}

// 3. موديل يوم التدريب (يحتوي على اسم اليوم وقائمة التمارين)
class PlanDayModel {
  final int id;
  final String name;
  final List<ExerciseModel> exercises;

  PlanDayModel({
    required this.id,
    required this.name,
    required this.exercises,
  });

  factory PlanDayModel.fromJson(Map<String, dynamic> json) {
    return PlanDayModel(
      id: json['id'] ?? json['day_id'] ?? 0,
      name: json['name'] ?? '',
      exercises: json['exercises'] != null
          ? List<ExerciseModel>.from(
        json['exercises'].map((x) => ExerciseModel.fromJson(x)),
      )
          : [],
    );
  }
}