import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sportifo_app/features/auth/presentation/view/register_screen.dart';
import 'package:sportifo_app/features/onboarding/presentation/view/onboarding_screen.dart';
import 'core/di/service_locator.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/view/login_screen.dart';
import 'features/auth/presentation/view_model/login/login_cubit.dart';
import 'features/splash/presentation/view/splash_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. أضفنا الـ BlocProvider هون عشان يكون متاح لكل الشاشات
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: NeumorphicApp(
        debugShowCheckedModeBanner: false,
        title: 'Sportifo',
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.onboarding: (context) => const OnboardingScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          // ملاحظة: الـ OTP والـ Reset Password يفضل تضيفيهم هون كمان كـ Named Routes لاحقاً
        },
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        locale: const Locale('en'),
        themeMode: ThemeMode.light,
        theme: const NeumorphicThemeData(
          baseColor: Color(0xFFF2F2F2),
          lightSource: LightSource.topLeft,
          depth: 10,
        ),
      ),
    );
  }
}

//وقت نضيف اي كلمة بملفات الترجمة مننفذ هاد الامر بالتيرمينال مشان يتعرف عالنصوص الجديدة اللي ترجمناها
//flutter gen-l10n
