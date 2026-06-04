import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    controller.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 4), () {
      _checkUserStatus();
    });
  }

  void _checkUserStatus() {
    final localStorage = getIt<LocalStorage>();

    final token = localStorage.getToken();
    final isOnboardingSeen = localStorage.isOnboardingSeen();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (isOnboardingSeen) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBtn,
      body: Center(
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Image.asset("assets/images/logo.png", width: 400),
        ),
      ),
    );
  }
}
