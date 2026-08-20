import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool isDanger;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? Colors.red : AppColors.primaryBtn;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: NeumorphicButton(
        onPressed: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        style: NeumorphicStyle(
          depth: 2,
          intensity: 0.4,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(18)),
          color: context.backgroundColor,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? color),
            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      textColor ?? (isDanger ? Colors.red : context.textColor),
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 17,
              color: isDanger ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
