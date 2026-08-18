import 'package:sportifo_app/features/edit_self_plan/data/models/edit_self_plan_model.dart';

class EditSelfPlanRequest {
  final String goal;
  final int durationMonths;
  final List<EditSelfPlanDay> days;

  EditSelfPlanRequest({
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