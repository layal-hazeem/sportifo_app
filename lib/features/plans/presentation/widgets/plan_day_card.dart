import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/plans/data/models/plan_day_ui_model.dart';

class PlanDayCard extends StatefulWidget {
  final PlanDayUiModel day;

  final VoidCallback onAddExercise;

  final Function(int) onDeleteExercise;

  final VoidCallback onDeleteDay;

  const PlanDayCard({
    super.key,

    required this.day,

    required this.onAddExercise,

    required this.onDeleteExercise,

    required this.onDeleteDay,
  });

  @override
  State<PlanDayCard> createState() => _PlanDayCardState();
}

class _PlanDayCardState extends State<PlanDayCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final exercises = widget.day.exercises;

    final visibleExercises = isExpanded
        ? exercises
        : exercises.take(3).toList();

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
                    ],
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
                                    exercise.name ?? "",

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
                                ],
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
                if (exercises.length > 3)
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
                            : "+ ${exercises.length - 3} More",

                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                if (exercises.length > 3) const SizedBox(width: 10),

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
}
