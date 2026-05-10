import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/view/complete_profile_info.dart';
import '../../features/auth/presentation/view/register_screen.dart';
import '../../features/auth/presentation/view_model/complete_profile/complete_profile_cubit.dart';
import '../../features/home/presentation/view/home_page.dart';
import '../../features/onboarding/presentation/view/onboarding_screen.dart';
import '../../features/profile/presentation/view/profile_page.dart';
import '../../features/profile/presentation/view_model/profile_cubit.dart';
import '../../features/workout/presentation/view/search_screen.dart';
import '../../features/workout/presentation/view_model/search_cubit/search_cubit.dart';
import '../di/service_locator.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/view/forgot_password_screen.dart';
import '../../features/auth/presentation/view/login_screen.dart';
import '../../features/auth/presentation/view/otp_screen.dart';
import '../../features/auth/presentation/view/reset_password_screen.dart';
import '../../features/auth/presentation/view_model/login/forgot_password_cubit.dart';
import '../../features/auth/presentation/view_model/login/login_cubit.dart';
import '../../features/auth/presentation/view_model/register/register_cubit.dart';
import '../../features/splash/presentation/view/splash_screen.dart';
import '../../features/workout/presentation/view/exercises_list_screen.dart';
import '../../features/workout/presentation/view/muscle_groups_screen.dart';
import '../../features/workout/presentation/view_model/categories_cubit/categories_cubit.dart';
import '../../features/workout/presentation/view_model/exercises_cubit/exercises_cubit.dart';
import '../../features/workout/presentation/view_model/parts_cubit/parts_cubit.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<RegisterCubit>(),
            child: const RegisterScreen(),
          ),
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<LoginCubit>(),
            child: const LoginScreen(),
          ),
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<CategoriesCubit>()),
            ],
            child: const HomePage(),
          ),
        );

      case AppRoutes.getProfile:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<ProfileCubit>()..getProfile(),
            child: ProfilePage(),
          ),
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<CompleteProfileCubit>(),
            child: CompleteProfileInfoView(),
          ),
        );

      case AppRoutes.muscleGroups:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<CategoriesCubit>()),
              BlocProvider(create: (_) => getIt<ExercisesCubit>()),
              BlocProvider(create: (_) => getIt<PartsCubit>()),
            ],
            child: const MuscleGroupsScreen(),
          ),
        );

      case AppRoutes.forgotPasswordScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<ForgotPasswordCubit>(),
            child: const ForgotPasswordScreen(),
          ),
        );

      case AppRoutes.resetPasswordScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<LoginCubit>(),
            child: ResetPasswordScreen(
              email: args?['email'] ?? '',
              otpCode: args?['otpCode'] ?? '',
            ),
          ),
        );

      case AppRoutes.otpScreen:
        final args = settings.arguments;
        String email = "";
        bool isFromForgot = false;

        if (args is String) {
          email = args;
        } else if (args is Map<String, dynamic>) {
          email = args['email'] ?? '';
          isFromForgot = args['isFromForgotPassword'] ?? false;
        }

        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<LoginCubit>(),
            child: OTPScreen(
              loginEmail: email,
              isFromForgotPassword: isFromForgot,
            ),
          ),
        );
      case AppRoutes.searchScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SearchCubit>(),
            child: const SearchExercisesScreen(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}