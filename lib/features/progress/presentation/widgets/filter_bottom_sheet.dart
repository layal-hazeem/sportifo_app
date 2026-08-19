import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/progress/presentation/view_model/exercise_filter_params.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class FilterBottomSheet {
  static void show({
    required BuildContext context,
    required Map<int, String> plans,
    required Map<int, String> exercises,
    required ExerciseFilterParams currentFilters,
    required void Function(ExerciseFilterParams) onApply,
  }) {
    final l10n = AppLocalizations.of(context)!;

    int? tempPlanId = currentFilters.planId;
    int? tempExerciseId = currentFilters.exerciseId;
    DateTime? tempFrom = currentFilters.from != null
        ? DateTime.tryParse(currentFilters.from!)
        : null;
    DateTime? tempTo = currentFilters.to != null
        ? DateTime.tryParse(currentFilters.to!)
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.filter_workouts,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (plans.isNotEmpty) ...[
                    _buildLabel(l10n.plan),
                    const SizedBox(height: 8),
                    _buildDropdown<int?>(
                      value: tempPlanId,
                      hint: l10n.all_plans,
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.all_plans)),
                        ...plans.entries.map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            )),
                      ],
                      onChanged: (v) => setModalState(() => tempPlanId = v),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (exercises.isNotEmpty) ...[
                    _buildLabel(l10n.exercise),
                    const SizedBox(height: 8),
                    _buildDropdown<int?>(
                      value: tempExerciseId,
                      hint: l10n.all_exercises,
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.all_exercises)),
                        ...exercises.entries.map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            )),
                      ],
                      onChanged: (v) => setModalState(() => tempExerciseId = v),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildLabel(l10n.date_range),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: l10n.from,
                          date: tempFrom,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: tempFrom ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() => tempFrom = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateField(
                          label: l10n.to,
                          date: tempTo,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: tempTo ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() => tempTo = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onApply(ExerciseFilterParams(
                              planId: tempPlanId,
                              exerciseId: tempExerciseId,
                              from: tempFrom != null
                                  ? _formatDate(tempFrom!)
                                  : null,
                              to: tempTo != null
                                  ? _formatDate(tempTo!)
                                  : null,
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBtn,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(l10n.apply),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  static Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  static Widget _buildDropdown<T>({
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              date != null
                  ? "${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}"
                  : label,
              style: TextStyle(
                fontSize: 13,
                color: date != null ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}