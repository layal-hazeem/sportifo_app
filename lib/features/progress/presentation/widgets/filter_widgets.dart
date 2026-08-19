import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/progress/presentation/view_model/exercise_filter_params.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class FilterButton extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onTap;

  const FilterButton({super.key, required this.hasFilters, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasFilters
              ? AppColors.primaryBtn.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: hasFilters
              ? Border.all(color: AppColors.primaryBtn.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 16,
              color: hasFilters ? AppColors.primaryBtn : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.filter,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasFilters ? AppColors.primaryBtn : Colors.grey.shade600,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBtn,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  "!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ActiveFilters extends StatelessWidget {
  final ExerciseFilterParams filters;
  final void Function(ExerciseFilterParams) onRemove;
  final VoidCallback onClearAll;

  const ActiveFilters({
    super.key,
    required this.filters,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (filters.planId != null)
          CustomFilterChip(
            label: l10n.plan_prefix(filters.planId!),
            onRemove: () => onRemove(filters.copyWith(planId: null)),
          ),
        if (filters.exerciseId != null)
          CustomFilterChip(
            label: l10n.exercise_prefix(filters.exerciseId!),
            onRemove: () => onRemove(filters.copyWith(exerciseId: null)),
          ),
        if (filters.from != null || filters.to != null)
          CustomFilterChip(
            label: "${filters.from ?? '...'} → ${filters.to ?? '...'}",
            onRemove: () => onRemove(filters.copyWith(from: null, to: null)),
          ),
        ActionChip(
          label: Text(
            l10n.clear_all,
            style: const TextStyle(fontSize: 11, color: Colors.red),
          ),
          backgroundColor: Colors.red.shade50,
          side: BorderSide.none,
          padding: EdgeInsets.zero,
          onPressed: onClearAll,
        ),
      ],
    );
  }
}

class CustomFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const CustomFilterChip({super.key, required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: AppColors.primaryBtn.withValues(alpha: 0.08),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}