import '../../data/models/my_plan_model.dart';

abstract class PlanDaysState {}

class PlanDaysInitial extends PlanDaysState {}

class PlanDaysLoading extends PlanDaysState {}

class PlanDaysSuccess extends PlanDaysState {
  final PlanModel planDetails;
  final int currentWeek;
  final Set<int> completedPlanDayIds; // آيديات الأيام المنجزة (الخضراء)
  final int totalWeeks; // إجمالي عدد الأسابيع (مهم جداً لشريط التقدم)

  PlanDaysSuccess({
    required this.planDetails,
    required this.currentWeek,
    required this.completedPlanDayIds,
    required this.totalWeeks,
  });

  // 🔥 دالة سحرية للـ UI لتعرف إذا الكارت أخضر أو لأ
  bool isDayCompleted(int planDayId) => completedPlanDayIds.contains(planDayId);
}

class PlanDaysFailure extends PlanDaysState {
  final String message;
  PlanDaysFailure(this.message);
}

