import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CustomAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomAuthButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBtn,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}