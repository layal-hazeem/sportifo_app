import 'package:sportifo_app/features/edit_coach_plan/data/models/edit_coach_plan_model.dart';

class EditCoachPlanRequest {
  final String goal;
  final int durationMonths;
  final List<PlanDay> days;

  EditCoachPlanRequest({
    required this.goal,
    required this.durationMonths,
    required this.days,
  });

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'duration_months': durationMonths,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }
}