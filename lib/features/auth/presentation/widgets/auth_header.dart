import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isCentered;

  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.isCentered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isCentered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Text(
            title,
            textAlign: isCentered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: AppSizes.titleFontSize,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: Text(
              subtitle!,
              textAlign: isCentered ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: AppSizes.hintFontSize,
                color: AppColors.hintText,
                height: 1.5, // ليعطي أريحية في القراءة
              ),
            ),
          ),
        ],
      ],
    );
  }
}
