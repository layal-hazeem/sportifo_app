import 'edit_coach_plan_day_request.dart';

class EditCoachPlanRequest {
  final String? goal;
  final int? durationMonths;
  final List<EditCoachPlanDayRequest> days;

  const EditCoachPlanRequest({
    this.goal,
    this.durationMonths,
    required this.days,
  });

  Map<String, dynamic> toMap() {
    return {
      if (goal != null) 'goal': goal,
      if (durationMonths != null) 'duration_months': durationMonths,
      'days': days.map((day) => day.toMap()).toList(),
    };
  }
}