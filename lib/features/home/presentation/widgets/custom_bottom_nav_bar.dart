import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';

class CustomBottomNavBar {
  static BottomNavigationBarItem build({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      label: label,

      icon: _buildNeumorphicIcon(icon, false),
      activeIcon: _buildNeumorphicIcon(icon, true),
    );
  }

  static Widget _buildNeumorphicIcon(IconData icon, bool isSelected) {
    return AnimatedScale(
      scale: isSelected ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),

      child: Neumorphic(
        style: NeumorphicStyle(
          depth: isSelected ? 6 : -4,
          intensity: 0.8,
          shape: NeumorphicShape.flat,
          boxShape: const NeumorphicBoxShape.circle(),
          color: isSelected ? AppColors.primaryBtn : AppColors.background,
        ),

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(
            icon,
            size: 22,
            color: isSelected ? AppColors.background : AppColors.primaryBtn,
          ),
        ),
      ),
    );
  }
}
