import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';

// 🔥 لا تنسي استيراد هذه الملفات (تأكدي من صحة المسارات حسب مشروعك)
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/routes/app_routes.dart';

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

    // 🔥 التعديل الأول: نستدعي الفحص الذكي بعد 3 ثواني
    Future.delayed(const Duration(seconds: 3), () {
      _checkUserStatus();
    });
  }

  // 🔥 التعديل الثاني: إضافة دالة التوجيه الذكي
  void _checkUserStatus() {
    // جلب الذاكرة من GetIt
    final localStorage = getIt<LocalStorage>();

    // سحب البيانات
    final token = localStorage.getToken();
    final isOnboardingSeen = localStorage.isOnboardingSeen();

    // حماية: التأكد أن الشاشة لم يتم إغلاقها
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // 1. عنده توكن -> اذهب للصفحة الرئيسية (Home)
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (isOnboardingSeen) {
      // 2. شاهد الأون بوردينغ ولكن ليس لديه توكن -> اذهب لتسجيل الدخول (Login)
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      // 3. مستخدم جديد -> اذهب للأون بوردينغ (Onboarding)
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