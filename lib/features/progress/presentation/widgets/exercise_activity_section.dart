import 'package:flutter/material.dart';
import 'package:sportifo_app/features/progress/presentation/view_model/exercise_filter_params.dart';
import 'package:sportifo_app/features/progress/presentation/widgets/day_card.dart';
import 'package:sportifo_app/features/progress/presentation/widgets/exercise_chart.dart';
import 'package:sportifo_app/features/progress/presentation/widgets/filter_widgets.dart';
import 'package:sportifo_app/features/progress/presentation/widgets/stat_card.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../data/models/exercise_activity_model.dart';
import 'filter_bottom_sheet.dart';

class ExerciseActivitySection extends StatefulWidget {
  final List<DayActivity> days;
  final ExerciseFilterParams filters;
  final void Function(ExerciseFilterParams) onApplyFilters;
  final VoidCallback onClearFilters;

  const ExerciseActivitySection({
    super.key,
    required this.days,
    required this.filters,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<ExerciseActivitySection> createState() =>
      _ExerciseActivitySectionState();
}

class _ExerciseActivitySectionState extends State<ExerciseActivitySection> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final totalWorkouts =
        widget.days.fold<int>(0, (sum, d) => sum + d.totalExercises);
    final totalSets = widget.days.fold<int>(
      0,
      (sum, d) => sum + d.logs.fold<int>(0, (s, l) => s + l.sets.length),
    );

    final showDayDetails = !widget.filters.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.workout_activity,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const Spacer(),
            FilterButton(
              hasFilters: !widget.filters.isEmpty,
              onTap: () => _showFilterSheet(context, l10n),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (!widget.filters.isEmpty) ...[
          ActiveFilters(
            filters: widget.filters,
            onRemove: (newFilters) => widget.onApplyFilters(newFilters),
            onClearAll: widget.onClearFilters,
          ),
          const SizedBox(height: 12),
        ],

        Row(
          children: [
            StatCard(l10n.workouts, totalWorkouts.toString(), Icons.fitness_center),
            const SizedBox(width: 12),
            StatCard(l10n.sets, totalSets.toString(), Icons.format_list_numbered),
            const SizedBox(width: 12),
            StatCard(l10n.days, widget.days.length.toString(), Icons.calendar_today),
          ],
        ),
        const SizedBox(height: 20),

        ExerciseChart(days: widget.days),
        const SizedBox(height: 25),

        Text(
          l10n.activity_timeline,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),

        ...widget.days.map(
          (day) => DayCard(
            day: day,
            showDetails: showDayDetails,
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context, AppLocalizations l10n) {
    final plans = <int, String>{};
    final exercises = <int, String>{};

    for (final day in widget.days) {
      for (final log in day.logs) {
        plans[log.planId] = l10n.plan_prefix(log.planId);
        exercises[log.exercise.id] = log.exercise.name;
      }
    }

    FilterBottomSheet.show(
      context: context,
      plans: plans,
      exercises: exercises,
      currentFilters: widget.filters,
      onApply: widget.onApplyFilters,
    );
  }
}