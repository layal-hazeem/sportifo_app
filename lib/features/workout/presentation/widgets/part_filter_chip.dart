import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';

class PartFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const PartFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,

        selectedColor: AppColors.primaryBtn,

        backgroundColor: AppColors.hintText.withOpacity(0.07),

        showCheckmark: false,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? AppColors.primaryBtn
                : AppColors.hintText.withOpacity(0.25),
            width: 1,
          ),
        ),

        labelStyle: TextStyle(
          color: isSelected ? Colors.white : context.textColor,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

        onSelected: onSelected,
      ),
    );
  }
}
