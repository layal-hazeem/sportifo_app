import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sportifo_app/features/auth/presentation/view/complete_profile_info.dart';
import 'package:sportifo_app/features/auth/presentation/view/register_screen.dart';
import 'package:sportifo_app/features/onboarding/presentation/view/onboarding_screen.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/view/login_screen.dart';
import 'features/splash/presentation/view/splash_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Sportifo',
// first Screen splash
      initialRoute: AppRoutes.splash,

        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.onboarding: (context) => const OnboardingScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
        },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      locale: const Locale('en'),

      // --------------------------------
      themeMode: ThemeMode.light,
      theme: const NeumorphicThemeData(
        baseColor: Color(0xFFF2F2F2),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
    // home: const RegisterScreen(),
    );
  }
}

//وقت نضيف اي كلمة بملفات الترجمة مننفذ هاد الامر بالتيرمينال مشان يتعرف عالنصوص الجديدة اللي ترجمناها
//flutter gen-l10n
