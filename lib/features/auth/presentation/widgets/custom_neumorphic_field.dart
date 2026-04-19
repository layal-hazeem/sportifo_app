import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../../../core/theme/app_colors.dart';

class CustomNeumorphicField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final Function(String)? onChanged; 
  final TextInputType? keyboardType; 

  const CustomNeumorphicField({
    super.key,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -5,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(AppSizes.borderRadius),
        ),
        color: AppColors.background,
      ),
      child: TextField(
        onChanged: onChanged, 
        keyboardType: keyboardType,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.hintText,
            fontSize: AppSizes.hintFontSize,
          ),
          suffixIcon: Icon(icon, color: AppColors.hintText, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
