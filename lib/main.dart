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
import 'core/localization/locale_cubit.dart';
import 'core/routes/app_routes.dart';
import 'core/storage/local_storage.dart';
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
import 'features/workout/presentation/view/workout_type_screen.dart';
import 'features/workout/presentation/view_model/categories_cubit/categories_cubit.dart';
import 'features/workout/presentation/view_model/exercises_cubit/exercises_cubit.dart';
import 'features/workout/presentation/view_model/parts_cubit/parts_cubit.dart';
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
    return BlocProvider(
        create: (context) => getIt<LocaleCubit>(),
        // 🔥 2. نستخدم BlocBuilder للاستماع لتغيرات اللغة
        child: BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return NeumorphicApp(      debugShowCheckedModeBanner: false,
      title: 'Sportifo',
      initialRoute: AppRoutes.splash,

                routes: {
                  AppRoutes.splash: (context) => const SplashScreen(),
                  AppRoutes.onboarding: (context) => const OnboardingScreen(),

                  AppRoutes.register: (context) => BlocProvider(
                    create: (_) => getIt<RegisterCubit>(),
                    child: const RegisterScreen(),
                  ),

                  AppRoutes.login: (context) => BlocProvider(
                    create: (_) => getIt<LoginCubit>(),
                    child: const LoginScreen(),
                  ),

                  // 🔥 تم دمج مسار الـ Home ليكون واحداً فقط ويحتوي على الكيوبتات المطلوبة
                  AppRoutes.home: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (context) => getIt<CategoriesCubit>()),
                      // يمكننا وضع الكيوبتات الأخرى هنا إذا احتجناها، لكن بما أننا سنضعها في MuscleGroupsScreen فهذا يكفي حالياً
                    ],
                    child: const HomePage(),
                  ),

                  AppRoutes.getProfile: (context) => BlocProvider(
                    create: (_) => getIt<ProfileCubit>()..getProfile(),
                    child: ProfilePage(),
                  ),

                  AppRoutes.editProfile: (context) => BlocProvider(
                    create: (_) => getIt<CompleteProfileCubit>(),
                    child: CompleteProfileInfoView(),
                  ),

                  // 🔥 هنا أضفنا الـ PartsCubit لكي تعمل شاشة العضلات بشكل صحيح مع الفلاتر الدقيقة
                  AppRoutes.muscleGroups: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (_) => getIt<CategoriesCubit>()),
                      BlocProvider(create: (_) => getIt<ExercisesCubit>()),
                      BlocProvider(create: (_) => getIt<PartsCubit>()), // أضفنا PartsCubit هنا
                    ],
                    child: const MuscleGroupsScreen(),
                  ),

                  // AppRoutes.exercisesList: (context) {
                  //   final args = ModalRoute.of(context)?.settings.arguments as Map<String, int>?;
                  //
                  //   return BlocProvider(
                  //     create: (_) => getIt<ExercisesCubit>(),
                  //     child: ExercisesListScreen(
                  //       categoryId: args?['categoryId'],
                  //       organId: args?['organId'],
                  //     ),
                  //   );
                  // },

                  AppRoutes.forgotPasswordScreen: (context) => BlocProvider(
                    create: (_) => getIt<ForgotPasswordCubit>(),
                    child: const ForgotPasswordScreen(),
                  ),

                  AppRoutes.resetPasswordScreen: (context) {
                    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

                    return BlocProvider(
                      create: (_) => getIt<LoginCubit>(),
                      child: ResetPasswordScreen(
                        email: args?['email'] ?? '',
                        otpCode: args?['otpCode'] ?? '',
                      ),
                    );
                  },

                  AppRoutes.otpScreen: (context) {
                    final args = ModalRoute.of(context)?.settings.arguments;

                    String email = "";
                    bool isFromForgot = false;

                    if (args is String) {
                      email = args;
                    } else if (args is Map<String, dynamic>) {
                      email = args['email'] ?? '';
                      isFromForgot = args['isFromForgotPassword'] ?? false;
                    }

                    return BlocProvider(
                      create: (_) => getIt<LoginCubit>(),
                      child: OTPScreen(
                        loginEmail: email,
                        isFromForgotPassword: isFromForgot,
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

      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],

                locale: locale,
                themeMode: ThemeMode.light,

      theme: const NeumorphicThemeData(
        baseColor: Color(0xFFF2F2F2),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
              );
            },
        ),
    );
  }
}

//وقت نضيف اي كلمة بملفات الترجمة مننفذ هاد الامر بالتيرمينال مشان يتعرف عالنصوص الجديدة اللي ترجمناها
//flutter gen-l10n
