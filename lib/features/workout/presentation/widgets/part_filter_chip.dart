import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
        backgroundColor: Colors.white,
        showCheckmark: false, // شلناها لحتى يضل النص بمركز الكبسولة أرتب
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.primaryBtn : Colors.grey.shade300),
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: onSelected,
      ),
    );
  }
}