import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';

class CustomGlassBottomSheet extends StatelessWidget {
  final Widget child;
  final double height;

  const CustomGlassBottomSheet({
    super.key,
    required this.child,
    this.height = 0.45,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double height = 0.45,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.15),
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: CustomGlassBottomSheet(height: height, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: height,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  color: context.backgroundColor.withOpacity(.88),
                ),
              ),
            ),

            Container(padding: const EdgeInsets.all(20), child: child),
          ],
        ),
      ),
    );
  }
}
