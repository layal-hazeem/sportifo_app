import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DotsIndicator extends StatelessWidget {
  final int currentIndex;
  final int length;

  const DotsIndicator({
    super.key,
    required this.currentIndex,
    required this.length,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBtn : AppColors.hintText.withOpacity(0.3),            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}