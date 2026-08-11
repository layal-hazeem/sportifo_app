import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';

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
      height: 98,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, index) {
          return SizedBox(
            width: 25,
            child: Center(
              child: Container(
                height: 1,
                width: 25,
                color: AppColors.textDark.withOpacity(.10),
              ),
            ),
          );
        },
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onDaySelected(index),
            child: _DayNode(day: day, index: index, isSelected: isSelected),
          );
        },
      ),
    );
  }
}

class _DayNode extends StatelessWidget {
  final PlanDayModel day;
  final int index;
  final bool isSelected;

  const _DayNode({
    required this.day,
    required this.index,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 95,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            width: isSelected ? 52 : 48,
            height: isSelected ? 52 : 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primaryBtn : Colors.white,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryBtn
                    : AppColors.textDark.withOpacity(.10),
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
                        color: AppColors.textDark.withOpacity(.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                '${(index + 1).toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textDark.withOpacity(.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            day.name.toUpperCase(),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: isSelected ? AppColors.textDark : AppColors.hintText,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
