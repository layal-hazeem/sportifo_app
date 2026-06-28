import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:sportifo_app/features/plans/presentation/view/create_plan_screen.dart';
import 'package:sportifo_app/features/plans/presentation/view_model/create_plan_cubit.dart';
import 'package:sportifo_app/features/profile/data/models/user_profile_response.dart';
import 'package:sportifo_app/features/profile/presentation/view/edit_profile_page.dart';
import 'package:sportifo_app/features/subscriptions/presentation/view/subscriptions_screen.dart';
import 'package:sportifo_app/features/subscriptions/presentation/view_model/subscription_cubit.dart';
import '../../features/auth/presentation/view/complete_profile_info.dart';
import '../../features/auth/presentation/view/register_screen.dart';
import '../../features/auth/presentation/view_model/complete_profile/complete_profile_cubit.dart';
import '../../features/trainee_subscriptions/data/models/subscription_month_model.dart';
import '../../features/trainee_subscriptions/presentation/views/payment_screen.dart';
import '../../features/trainee_subscriptions/presentation/views/select_month_screen.dart';
import '../../features/home/presentation/view/home_page.dart';
import '../../features/onboarding/presentation/view/onboarding_screen.dart';
import '../../features/profile/presentation/view/profile_page.dart';
import '../../features/profile/presentation/view_model/profile_cubit.dart';
import '../../features/workout/data/models/exercise_model.dart';
import '../../features/workout/presentation/view/exercise_details_screen.dart';
import '../../features/workout/presentation/view/saved_exercises_screen.dart';
import '../../features/workout/presentation/view/workout_type_screen.dart';
import '../../features/workout/presentation/view_model/saved_exercises/saved_exercises_cubit.dart';
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
import '../../features/trainee_subscriptions/data/models/subscription_model.dart';



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
            providers: [BlocProvider(create: (_) => getIt<CategoriesCubit>())],
            child: const HomePage(),
          ),
        );

      case AppRoutes.usersSubscribed:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SubscriptionCubit>()..getSubscriptions(),
            child: const SubscriptionsScreen(),
          ),
        );

      case AppRoutes.completeProfile:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<CompleteProfileCubit>(),
            child: CompleteProfileInfoView(),
          ),
        );
      case AppRoutes.workoutType:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<CategoriesCubit>(),
            child:
                const WorkoutTypeScreen(), // تأكدي من عمل import لهذه الشاشة في الأعلى
          ),
        );
      case AppRoutes.muscleGroups:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<CategoriesCubit>()),
              BlocProvider(create: (_) => getIt<ExercisesCubit>()),
              BlocProvider(create: (_) => getIt<PartsCubit>()),
              // 🔥 أضيفي هذا السطر المفقود هنا
              BlocProvider.value(value: getIt<SavedExercisesCubit>()),
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

      case AppRoutes.getProfile:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<ProfileCubit>()..getProfile()),
              BlocProvider(create: (_) => getIt<LogoutCubit>()),
            ],
            child: const ProfilePage(),
          ),
        );

      case AppRoutes.editProfile:
        final profile = settings.arguments as ProfileResponsModel;

        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<ProfileCubit>(),
            child: EditProfilePage(profile: profile),
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

      // 1. شاشة قائمة التمارين
      case AppRoutes.exercisesList:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    getIt<ExercisesCubit>()
                      ..fetchExercises(categoryId: args['categoryId']),
              ),
              // تعديل هنا: استخدمي .value بدلاً من create
              BlocProvider.value(value: getIt<SavedExercisesCubit>()),
            ],
            child: ExercisesListScreen(
              categoryId: args['categoryId'],
              categoryName: args['categoryName'] ?? "Exercises",
            ),
          ),
        );

      case AppRoutes.exerciseDetails:
        final exercise = settings.arguments as ExerciseModel;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<SavedExercisesCubit>(),
            child: ExerciseDetailsScreen(exercise: exercise),
          ),
        );

      case AppRoutes.searchScreen:
        // استخراج الـ Map بالكامل
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<SearchCubit>()),
              BlocProvider.value(value: getIt<SavedExercisesCubit>()),
            ],
            child: SearchExercisesScreen(
              categoryId: args?['categoryId'], // مرريها من الـ Map
              organId: args?['organId'], // مرريها من الـ Map
              smallestCategoryId:
                  args?['smallestCategoryId'], // مرريها من الـ Map
            ),
          ),
        );
      case AppRoutes.savedExercises:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<SavedExercisesCubit>()..fetchSavedExercises(),
            child: const SavedExercisesScreen(),
          ),
        );

      case AppRoutes.createPlan:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<CreatePlanCubit>(),
            child: const CreatePlanScreen(),
          ),
        );


      case AppRoutes.selectMonth:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SelectMonthScreen(
            coachId: args?['coachId'] as int,
            subscription: args?['subscription'] as SubscriptionModel,
          ),
        );

      case AppRoutes.payment:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            coachId: args?['coachId'] as int,
            subscription: args?['subscription'] as SubscriptionModel,
            selectedMonth: args?['selectedMonth'] as SubscriptionMonthModel,
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
