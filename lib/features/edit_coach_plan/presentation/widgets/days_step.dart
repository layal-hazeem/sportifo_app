import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/create_plan_by_coach/data/models/plan_day_ui_model.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/plan_day_card.dart';
import 'package:sportifo_app/features/edit_coach_plan/presentation/widgets/empty_days_state.dart';

class EditPlanDaysStep extends StatelessWidget {
  final List<PlanDayUiModel> days;
  final void Function(int dayIndex) onAddExercise;
  final void Function(int dayIndex, int exerciseIndex) onDeleteExercise;
  final void Function(int dayIndex) onDeleteDay;
  final Future<void> Function(PlanDayUiModel day) onDaySettings;

  const EditPlanDaysStep({
    super.key,
    required this.days,
    required this.onAddExercise,
    required this.onDeleteExercise,
    required this.onDeleteDay,
    required this.onDaySettings,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBtn,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'WORKOUT DAYS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                Text(
                  '${days.length} ${days.length == 1 ? 'day' : 'days'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (days.isEmpty)
          const SliverToBoxAdapter(child: EditPlanEmptyDaysState()),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final day = days[index];

              return PlanDayCard(
                day: day,
                onSettings: () => onDaySettings(day),
                onAddExercise: () => onAddExercise(index),
                onDeleteExercise: (exerciseIndex) =>
                    onDeleteExercise(index, exerciseIndex),
                onDeleteDay: () => onDeleteDay(index),
              );
            },
            childCount: days.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}