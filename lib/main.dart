import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sportifo_app/features/auth/presentation/view/register_screen.dart';
import 'package:sportifo_app/features/onboarding/presentation/view/onboarding_screen.dart';
import 'core/di/service_locator.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/view/login_screen.dart';
import 'features/auth/presentation/view/otp_screen.dart';
import 'features/auth/presentation/view_model/login/login_cubit.dart';
import 'features/auth/presentation/view_model/register/register_cubit.dart';
import 'features/home/presentation/view/home_page.dart';
import 'features/splash/presentation/view/splash_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator(); // 🔥 وضعنا await هنا لكي ينتظر تحميل الذاكرة
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. أضفنا الـ BlocProvider هون عشان يكون متاح لكل الشاشات
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Sportifo',
      initialRoute: AppRoutes.splash,

      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),

        AppRoutes.register: (context) => BlocProvider(
          create: (context) => getIt<RegisterCubit>(),
          child: const RegisterScreen(),
        ),

        AppRoutes.login: (context) => BlocProvider(
          create: (context) => getIt<LoginCubit>(),
          child: const LoginScreen(),
        ),
        AppRoutes.otpScreen: (context) {
          final email =
              ModalRoute.of(context)?.settings.arguments as String? ?? '';

          return BlocProvider(
            create: (context) => getIt<LoginCubit>(), // 🔥 الحل هون
            child: OTPScreen(loginEmail: email),
          );
        },
        AppRoutes.home: (context) => const HomePage(), // 🔥 تأكدي من إضافة هذه!
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
      );
  }
}

//وقت نضيف اي كلمة بملفات الترجمة مننفذ هاد الامر بالتيرمينال مشان يتعرف عالنصوص الجديدة اللي ترجمناها
//flutter gen-l10n
