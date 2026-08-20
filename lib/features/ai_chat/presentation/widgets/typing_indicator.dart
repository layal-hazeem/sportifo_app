import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
    });

    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 120), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: BorderRadius.circular(15),

          // نفس الـ AI bubble
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBtn.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controllers[index],
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: 7,
                  height: 7 + (_controllers[index].value * 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBtn.withValues(
                      alpha: 0.65 + (_controllers[index].value * 0.35),
                    ),
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
