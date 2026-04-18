import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';

class CustomBottomNavBar {
  static BottomNavigationBarItem build({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: AppColors.hintText),

      activeIcon: AnimatedScale(
        scale: isSelected ? 1.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: isSelected ? 1.0 : 0.7,
          duration: const Duration(milliseconds: 350),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBtn : AppColors.background,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBtn.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(icon, color: AppColors.background, size: 24),
          ),
        ),
      ),
      label: label,
    );
  }
}
