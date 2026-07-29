import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/plans/data/models/plan_day_ui_model.dart';
import 'package:sportifo_app/features/plans/presentation/widgets/exercise_settings_bottom_sheet.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';

class PlanDayCard extends StatefulWidget {
  final PlanDayUiModel day;

  final VoidCallback onAddExercise;

  final Function(int) onDeleteExercise;

  final VoidCallback onDeleteDay;
  final VoidCallback onSettings;

  const PlanDayCard({
    super.key,

    required this.day,

    required this.onAddExercise,

    required this.onDeleteExercise,

    required this.onDeleteDay,

    required this.onSettings,
  });

  @override
  State<PlanDayCard> createState() => _PlanDayCardState();
}

class _PlanDayCardState extends State<PlanDayCard> {
  bool isExpanded = false;

  int? _getSets(ExerciseModel exercise) {
    if (exercise.isCardio) {
      return null;
    }

    if (exercise.sets != null) {
      return exercise.sets;
    }

    return widget.day.defaultSets;
  }

  String? _getReps(ExerciseModel exercise) {
    if (exercise.isCardio) {
      return null;
    }

    if (exercise.reps != null && exercise.reps!.isNotEmpty) {
      return exercise.reps;
    }

    return widget.day.defaultReps?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.day.exercises;

    final visibleExercises = isExpanded
        ? exercises
        : exercises.take(2).toList();

    return Dismissible(
      key: ValueKey(widget.day.name),

      direction: DismissDirection.endToStart,

      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        padding: const EdgeInsets.only(right: 30),

        alignment: Alignment.centerRight,

        decoration: BoxDecoration(
          color: Colors.red,

          borderRadius: BorderRadius.circular(22),
        ),

        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),

      onDismissed: (_) {
        widget.onDeleteDay();
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        curve: Curves.easeOut,

        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),

              blurRadius: 12,

              offset: const Offset(0, 4),
            ),
          ],

          border: Border.all(color: Colors.grey.shade200),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  width: 45,

                  height: 45,

                  decoration: BoxDecoration(
                    color: AppColors.primaryBtn.withOpacity(.12),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.calendar_today_rounded,

                    color: AppColors.primaryBtn,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        widget.day.name,

                        style: const TextStyle(
                          fontSize: 18,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "${exercises.length} Exercises",

                        style: TextStyle(
                          color: Colors.grey.shade600,

                          fontSize: 13,
                        ),
                      ),
                      if (widget.day.defaultSets != null ||
                          widget.day.defaultReps != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "${widget.day.defaultSets ?? '-'} Sets • ${widget.day.defaultReps ?? '-'} Reps",
                            style: TextStyle(
                              color: AppColors.primaryBtn,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showDaySettings(context);
                  },

                  icon: const Icon(
                    Icons.settings_outlined,
                    color: AppColors.primaryBtn,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (exercises.isEmpty)
              Text(
                "No exercises added yet",

                style: TextStyle(color: Colors.grey.shade500),
              ),

            /// EXERCISES
            AnimatedSize(
              duration: const Duration(milliseconds: 300),

              child: Column(
                children: [
                  ...visibleExercises.asMap().entries.map((entry) {
                    final index = entry.key;

                    final exercise = entry.value;

                    final sets = _getSets(exercise);
                    final reps = _getReps(exercise);
                    return AnimatedOpacity(
                      duration: Duration(milliseconds: 200 + (index * 80)),

                      opacity: 1,

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),

                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,

                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Row(
                          children: [
                            Container(
                              width: 8,

                              height: 8,

                              decoration: BoxDecoration(
                                color: AppColors.primaryBtn,

                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    exercise.name,

                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  Text(
                                    exercise.category?.name ?? "",

                                    style: TextStyle(
                                      fontSize: 12,

                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (exercise.isCardio &&
                                      exercise.duration != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        exercise.duration!,
                                        style: const TextStyle(
                                          color: AppColors.primaryBtn,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  else if (sets != null || reps != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        "${sets ?? '-'} Sets • ${reps ?? '-'} Reps",
                                        style: const TextStyle(
                                          color: AppColors.primaryBtn,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                ExerciseSettingsBottomSheet.show(
                                  context,
                                  exercise,
                                ).then((_) {
                                  setState(() {});
                                });
                              },

                              icon: const Icon(
                                Icons.settings_outlined,
                                color: AppColors.primaryBtn,
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                widget.onDeleteExercise(
                                  exercises.indexOf(exercise),
                                );
                              },

                              icon: const Icon(
                                Icons.delete_outline,

                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            /// ACTION BUTTONS
            Row(
              children: [
                if (exercises.length > 2)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },

                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBtn,

                        side: BorderSide(
                          color: AppColors.primaryBtn.withOpacity(.4),
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),

                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),

                      child: Text(
                        isExpanded
                            ? "Show Less"
                            : "+ ${exercises.length - 2} More",

                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                if (exercises.length > 2) const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onAddExercise,

                    icon: const Icon(Icons.add, size: 18),

                    label: const Text("Add Exercise"),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBtn,

                      side: BorderSide(color: AppColors.primaryBtn),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),

                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDaySettings(BuildContext context) {
    final setsController = TextEditingController(
      text: widget.day.defaultSets?.toString() ?? "",
    );

    final repsController = TextEditingController(
      text: widget.day.defaultReps?.toString() ?? "",
    );

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),

          child: Container(
            padding: const EdgeInsets.all(24),

            decoration: const BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  width: 45,

                  height: 5,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,

                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Workout Day Settings",

                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  "These values will apply to all exercises unless customized.",

                  textAlign: TextAlign.center,

                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: setsController,

                  keyboardType: TextInputType.number,

                  decoration: InputDecoration(
                    labelText: "Default Sets",

                    hintText: "Example: 4",

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: repsController,

                  keyboardType: TextInputType.number,

                  decoration: InputDecoration(
                    labelText: "Default Reps",

                    hintText: "Example: 12",

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBtn,

                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),

                    onPressed: () {
                      setState(() {
                        widget.day.defaultSets = int.tryParse(
                          setsController.text,
                        );

                        widget.day.defaultReps = int.tryParse(
                          repsController.text,
                        );
                      });

                      Navigator.pop(context);
                    },

                    child: const Text(
                      "Save Settings",

                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
