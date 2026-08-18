import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class PlanDaySelector extends StatelessWidget {
  final List<PlanDayModel> days;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  const PlanDaySelector({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) {
          return SizedBox(
            width: 22,
            child: Center(
              child: Container(
                height: 1.4,
                color: context.textColor.withOpacity(.15),
              ),
            ),
          );
        },
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onDaySelected(index),
            child: Center(
              child: _DayNode(index: index, isSelected: isSelected),
            ),
          );
        },
      ),
    );
  }
}

class _DayNode extends StatelessWidget {
  final int index;
  final bool isSelected;

  const _DayNode({required this.index, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primaryBtn : Colors.white,
        border: Border.all(
          color: isSelected
              ? AppColors.primaryBtn
              : context.textColor.withOpacity(.10),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryBtn.withOpacity(.28),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: context.textColor.withOpacity(.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.day,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withOpacity(.85)
                    : AppColors.hintText,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: .6,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '${index + 1}',
              style: TextStyle(
                color: isSelected ? Colors.white : context.textColor,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
