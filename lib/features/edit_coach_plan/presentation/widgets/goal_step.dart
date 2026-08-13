import 'package:flutter/material.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/plan_details_card.dart';

class EditPlanGoalStep extends StatelessWidget {
  final String? selectedGoal;
  final int durationMonths;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<int> onDurationChanged;

  const EditPlanGoalStep({
    super.key,
    required this.selectedGoal,
    required this.durationMonths,
    required this.onGoalChanged,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: PlanDetailsCard(
        selectedGoal: selectedGoal,
        durationMonths: durationMonths,
        onGoalChanged: onGoalChanged,
        onDurationChanged: onDurationChanged,
      ),
    );
  }
}