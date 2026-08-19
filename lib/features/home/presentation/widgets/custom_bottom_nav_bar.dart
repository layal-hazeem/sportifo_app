import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart'; // 👈 لا تنسَ الـ import

class CustomBottomNavBar {
  static BottomNavigationBarItem build(
    BuildContext context, {
    required IconData icon,
    String? svgIcon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      label: label,
      icon: _buildNeumorphicIcon(context, icon, svgIcon, false),
      activeIcon: _buildNeumorphicIcon(context, icon, svgIcon, true),
    );
  }

  static Widget _buildNeumorphicIcon(
    BuildContext context,
    IconData icon,
    String? svgIcon,
    bool isSelected,
  ) {
    return AnimatedScale(
      scale: isSelected ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: 0,
          intensity: 0,
          shape: NeumorphicShape.flat,
          boxShape: const NeumorphicBoxShape.circle(),
          color: isSelected ? AppColors.primaryBtn : context.backgroundColor,
          shadowLightColor: Colors.transparent,
          shadowDarkColor: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: svgIcon != null
              ? SvgPicture.asset(
                  svgIcon,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    isSelected ? context.backgroundColor : AppColors.primaryBtn,
                    BlendMode.srcIn,
                  ),
                )
              : Icon(
                  icon,
                  size: 22,
                  color: isSelected ? context.textColor : AppColors.primaryBtn,
                ),
        ),
      ),
    );
  }
}
