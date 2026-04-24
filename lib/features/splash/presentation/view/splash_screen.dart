import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    controller.repeat(reverse: true);


    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, "/onboarding");
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.primaryBtn, // لونك
      body: Center(
        child: ScaleTransition(
          scale: scaleAnimation,
        child: Image.asset(
          "assets/images/logo.png",
          width: 400,
        ),
      ),
      ),
    );
  }
}