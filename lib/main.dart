import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sportifo_app/features/auth/presentation/view/complete_profile_info.dart';
import 'package:sportifo_app/features/auth/presentation/view/register_screen.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/complete_profile/complete_profile_cubit.dart';
import 'package:sportifo_app/features/home/presentation/view/home_page.dart';
import 'package:sportifo_app/features/onboarding/presentation/view/onboarding_screen.dart';
import 'package:sportifo_app/features/profile/presentation/view/profile_page.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_cubit.dart';
import 'core/di/service_locator.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/view/forgot_password_screen.dart';
import 'features/auth/presentation/view/login_screen.dart';
import 'features/auth/presentation/view/otp_screen.dart';
import 'features/auth/presentation/view/reset_password_screen.dart';
import 'features/auth/presentation/view_model/login/forgot_password_cubit.dart';
import 'features/auth/presentation/view_model/login/login_cubit.dart';
import 'features/auth/presentation/view_model/register/register_cubit.dart';
import 'features/splash/presentation/view/splash_screen.dart';
import 'features/workout/presentation/view/exercises_list_screen.dart';
import 'features/workout/presentation/view/muscle_groups_screen.dart';
import 'features/workout/presentation/view_model/categories_cubit/categories_cubit.dart';
import 'features/workout/presentation/view_model/exercises_cubit/exercises_cubit.dart';
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
          // استقبال الـ Arguments كـ Map بدلاً من String لكي نمرر الـ flag
          final args = ModalRoute.of(context)?.settings.arguments;

          String email = "";
          bool isFromForgot = false;

          if (args is String) {
            email = args; // للحالة القديمة (Login normal)
          } else if (args is Map<String, dynamic>) {
            email = args['email'] ?? '';
            isFromForgot = args['isFromForgotPassword'] ?? false;
          }

          return BlocProvider(
            create: (context) => getIt<LoginCubit>(),
            child: OTPScreen(loginEmail: email),
          );
        },
        AppRoutes.home: (context) => const HomePage(),
            child: OTPScreen(
              loginEmail: email,
              isFromForgotPassword: isFromForgot,
            ),
          );
        },
        AppRoutes.editProfile: (context) => BlocProvider(
          create: (_) => getIt<CompleteProfileCubit>(),
          child: CompleteProfileInfoView(),
        ),
// 🔥 مسارات التمارين
        AppRoutes.muscleGroups: (context) => BlocProvider(
          create: (context) => getIt<CategoriesCubit>(),
          child: const MuscleGroupsScreen(),
        ),
        AppRoutes.exercisesList: (context) {
          // استلام الـ ID (إما للكارديو أو للعضلة)
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, int>?;
          return BlocProvider(
            create: (context) => getIt<ExercisesCubit>(), // حقن الكيوبت
            child: ExercisesListScreen(
              categoryId: args?['categoryId'],
              organId: args?['organId'],
            ),
          );
        },

        // AppRoutes.exerciseDetails: (context) {
        //   // استلام كائن التمرين بالكامل لعرض تفاصيله
        //   final exercise = ModalRoute.of(context)?.settings.arguments as ExerciseModel;
        //   return ExerciseDetailsScreen(exercise: exercise);
        // },
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
        AppRoutes.getProfile: (context) => BlocProvider(
          create: (context) => getIt<ProfileCubit>()..getProfile(),
          child: ProfilePage(),
        ),

        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.forgotPasswordScreen: (context) => BlocProvider(
          create: (context) => getIt<ForgotPasswordCubit>(), // ✅ استخدمي هذا
          child: const ForgotPasswordScreen(),
        ),
        AppRoutes.resetPasswordScreen: (context) {
          // استقبال الـ Map الذي يحتوي على الإيميل والكود
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

          return BlocProvider(
            create: (context) => getIt<LoginCubit>(),
            child: ResetPasswordScreen(
              email: args?['email'] ?? '',
              otpCode: args?['otpCode'] ?? '',
            ),
          );
        },

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

        // ملاحظة: الـ OTP والـ Reset Password يتم حقنهم هنا بنفس الطريقة لاحقاً
      ),
    );
  }
}

//وقت نضيف اي كلمة بملفات الترجمة مننفذ هاد الامر بالتيرمينال مشان يتعرف عالنصوص الجديدة اللي ترجمناها
//flutter gen-l10n
