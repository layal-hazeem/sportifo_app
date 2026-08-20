import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';

extension ThemeColors on BuildContext {
  Color get backgroundColor => NeumorphicTheme.currentTheme(this).baseColor;
  Color get primaryColor => NeumorphicTheme.currentTheme(this).accentColor ;
  Color get textColor => NeumorphicTheme.currentTheme(this).defaultTextColor ;
  Color get secondaryBackgroundColor =>
      Theme.of(this).brightness == Brightness.dark
          ? AppColors.secondaryDarkBackground
          : AppColors.secondaryLightBackground;
}