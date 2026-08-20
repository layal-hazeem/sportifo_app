import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

extension ThemeColors on BuildContext {
  Color get backgroundColor => NeumorphicTheme.currentTheme(this).baseColor;
  Color get primaryColor => NeumorphicTheme.currentTheme(this).accentColor ;
  Color get textColor => NeumorphicTheme.currentTheme(this).defaultTextColor ;
}