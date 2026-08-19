import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportifo_app/features/%20ads/presentation/view_model/ads_cubit.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/complete_profile/complete_profile_cubit.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:sportifo_app/features/create_self_plan/data/repository/create_self_plan_repository.dart';
import 'package:sportifo_app/features/create_self_plan/data/web_services/create_self_plan_service.dart';
import 'package:sportifo_app/features/create_self_plan/presentation/view_model/create_self_plan_cubit.dart';
import 'package:sportifo_app/features/edit_coach_plan/data/repository/edit_coach_plan_repository.dart';
import 'package:sportifo_app/features/edit_coach_plan/data/web_services/edit_coach_plan_service.dart';
import 'package:sportifo_app/features/edit_coach_plan/presentation/view_model/edit_coach_plan_cubit.dart';
import 'package:sportifo_app/features/edit_self_plan/data/repository/edit_self_plan_repository.dart';
import 'package:sportifo_app/features/edit_self_plan/data/web_services/edit_self_plan_service.dart';
import 'package:sportifo_app/features/edit_self_plan/presentation/view_model/edit_self_plan_cubit.dart';
import 'package:sportifo_app/features/existing_days/data/repository/existing_days_repository.dart';
import 'package:sportifo_app/features/existing_days/data/web_services/existing_days_web_services.dart';
import 'package:sportifo_app/features/existing_days/presentation/view_model/existing_days_cubit.dart';
import 'package:sportifo_app/features/home/data/repository/coach_home_repository.dart';
import 'package:sportifo_app/features/home/presentation/view_model/coach_home_cubit.dart';
import 'package:sportifo_app/features/nutrition/data/repository/nutrition_repository.dart';
import 'package:sportifo_app/features/nutrition/data/web_services/nutrition_web_service.dart';
import 'package:sportifo_app/features/nutrition/presentation/view_model/nutrition_cubit.dart';
import 'package:sportifo_app/features/create_plan_by_coach/data/repository/create_plan_repository.dart';
import 'package:sportifo_app/features/create_plan_by_coach/data/web_services/create_plan_service.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/view_model/create_plan_cubit.dart';
import 'package:sportifo_app/features/plan_details/data/repository/plan_details_repository.dart';
import 'package:sportifo_app/features/plan_details/data/web_services/plan_details_web_service.dart';
import 'package:sportifo_app/features/plan_details/presentation/view_model/plan_details_cubit.dart';
import 'package:sportifo_app/features/profile/data/repository/profile_repository.dart';
import 'package:sportifo_app/features/profile/data/web_services/profile_web_service.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:sportifo_app/features/subscriptions/data/repository/subscription_repository.dart';
import 'package:sportifo_app/features/subscriptions/data/web_services/subscriptions_web_service.dart';
import 'package:sportifo_app/features/subscriptions/presentation/view_model/subscription_cubit.dart';
import 'package:sportifo_app/features/trainees/data/repository/trainees_repository.dart';
import 'package:sportifo_app/features/trainees/data/web_services/trainees_web_service.dart';
import 'package:sportifo_app/features/trainees/presentation/view_model/trainees_cubit.dart';
import '../../features/ ads/data/repository/ads_repository.dart';
import '../../features/ ads/data/web_services/ads_web_service.dart';
import '../../features/auth/data/repository/auth_repository.dart';
import '../../features/auth/data/web_services/auth_webService.dart';
import '../../features/auth/presentation/view_model/login/forgot_password_cubit.dart';
import '../../features/auth/presentation/view_model/login/login_cubit.dart';
import '../../features/auth/presentation/view_model/register/register_cubit.dart';
import '../../features/coaches/data/repositories/coach_repository.dart';
import '../../features/coaches/data/web_services/coach_web_service.dart';
import '../../features/coaches/presentation/view_model/all_coaches_cubit.dart';
import '../../features/coaches/presentation/view_model/coach_details_cubit.dart';
import '../../features/coaches/presentation/view_model/coaches_cubit.dart';
import '../../features/my_plans(user)/data/repository/my_plans_repository.dart';
import '../../features/my_plans(user)/data/web_services/my_plans_service.dart';
import '../../features/my_plans(user)/presentation/view_model/active_workout_cubit.dart';
import '../../features/my_plans(user)/presentation/view_model/my_plans_cubit.dart';
import '../../features/my_plans(user)/presentation/view_model/plan_days_cubit.dart';
import '../../features/notifications/data/repository/notifications_repository.dart';
import '../../features/notifications/data/web_services/notifications_web_service.dart';
import '../../features/notifications/presentation/view_model/notifications_cubit.dart';
import '../../features/platform_plans/data/repository/platform_plans_repository.dart';
import '../../features/platform_plans/data/service/platform_plans_service.dart';
import '../../features/platform_plans/presentation/view_model/platform_plans_cubit.dart';
import '../../features/targets/data/repository/target_repository.dart';
import '../../features/targets/data/web_services/target_web_service.dart';
import '../../features/targets/presentation/view_model/target_cubit/target_cubit.dart';
import '../../features/trainee_subscriptions/data/repositories/trainee_subscription_repository.dart';
import '../../features/trainee_subscriptions/data/web_services/trainee_subscription_web_service.dart';
import '../../features/workout/data/repository/workout_repository.dart';
import '../../features/workout/data/web_services/workout_web_service.dart';
import '../../features/workout/presentation/view_model/categories_cubit/categories_cubit.dart';
import '../../features/workout/presentation/view_model/exercises_cubit/exercises_cubit.dart';
import '../../features/workout/presentation/view_model/saved_exercises/saved_exercises_cubit.dart';
import '../../features/workout/presentation/view_model/parts_cubit/parts_cubit.dart';
import '../../features/workout/presentation/view_model/search_cubit/search_cubit.dart';
import '../../features/progress/data/repository/exercise_activity_repository.dart';
import '../../features/progress/data/web_services/exercise_activity_web_service.dart';
import '../../features/progress/presentation/view_model/exercise_activity_cubit.dart';
import '../../features/progress/data/repository/weight_progress_repository.dart';
import '../../features/progress/data/web_services/weight_progress_web_service.dart';
import '../../features/progress/presentation/view_model/weight_progress_cubit.dart';
import '../../features/ai_chat/data/web_services/ai_chat_web_service.dart';
import '../../features/ai_chat/data/repository/ai_chat_repository.dart';
import '../../features/ai_chat/presentation/view_model/ai_chat_cubit.dart';

import '../localization/locale_cubit.dart';
import '../network/dio_factory.dart';
import '../storage/local_storage.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

  getIt.registerLazySingleton<LocalStorage>(
    () => LocalStorage(getIt<SharedPreferences>()),
  );

  final dioFactory = DioFactory(getIt<LocalStorage>());
  await dioFactory.init();

  getIt.registerSingleton<DioFactory>(dioFactory);
  getIt.registerLazySingleton<Dio>(() => getIt<DioFactory>().dio);

  getIt.registerLazySingleton<AuthWebService>(
    () => AuthWebService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<AuthWebService>()),
  );

  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt<AuthRepository>()));
  getIt.registerFactory(() => ForgotPasswordCubit(getIt()));

  getIt.registerFactory<RegisterCubit>(
    () => RegisterCubit(getIt<AuthRepository>()),
  );
  getIt.registerFactory<CompleteProfileCubit>(
    () => CompleteProfileCubit(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<WorkoutWebService>(
    () => WorkoutWebService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepository(getIt<WorkoutWebService>()),
  );
  getIt.registerLazySingleton<WeightProgressWebService>(
    () => WeightProgressWebService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<WeightProgressRepository>(
    () => WeightProgressRepository(getIt<WeightProgressWebService>()),
  );
  getIt.registerFactory<WeightProgressCubit>(
    () => WeightProgressCubit(getIt<WeightProgressRepository>()),
  );

  getIt.registerLazySingleton<ExerciseActivityWebService>(
    () => ExerciseActivityWebService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ExerciseActivityRepository>(
    () => ExerciseActivityRepository(getIt<ExerciseActivityWebService>()),
  );
  getIt.registerFactory<ExerciseActivityCubit>(
    () => ExerciseActivityCubit(getIt<ExerciseActivityRepository>()),
  );

  getIt.registerLazySingleton<ExercisesCubit>(
    () => ExercisesCubit(getIt<WorkoutRepository>()),
  );
  getIt.registerFactory<CategoriesCubit>(
    () => CategoriesCubit(getIt<WorkoutRepository>()),
  );

  getIt.registerLazySingleton<PartsCubit>(
    () => PartsCubit(getIt<WorkoutRepository>()),
  );
  final savedExercisesCubit = SavedExercisesCubit(getIt<WorkoutRepository>());
  getIt.registerSingleton<SavedExercisesCubit>(savedExercisesCubit);
  await savedExercisesCubit.initialize();

  getIt.registerLazySingleton<ProfileWebService>(
    () => ProfileWebService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(getIt<ProfileWebService>()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt<ProfileRepository>()),
  );
  getIt.registerFactory<LogoutCubit>(
    () => LogoutCubit(getIt<AuthRepository>()),
  );
  getIt.registerFactory<LocaleCubit>(() => LocaleCubit(getIt<LocalStorage>()));
  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(getIt<WorkoutRepository>()),
  );

  getIt.registerLazySingleton<AdsWebService>(() => AdsWebService(getIt<Dio>()));
  getIt.registerLazySingleton<AdsRepository>(
    () => AdsRepository(getIt<AdsWebService>()),
  );
  getIt.registerFactory<AdsCubit>(() => AdsCubit(getIt<AdsRepository>()));

  getIt.registerLazySingleton<CoachWebService>(() => CoachWebService());
  getIt.registerLazySingleton<CoachRepository>(
    () => CoachRepository(getIt<CoachWebService>()),
  );

  getIt.registerFactory<CoachesCubit>(
    () => CoachesCubit(getIt<CoachRepository>()),
  );
  getIt.registerFactory<AllCoachesCubit>(
    () => AllCoachesCubit(getIt<CoachRepository>()),
  );
  getIt.registerFactory<CoachDetailsCubit>(
    () => CoachDetailsCubit(getIt<CoachRepository>()),
  );

  getIt.registerLazySingleton<SubscriptionWebService>(
    () => SubscriptionWebService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepository(getIt<SubscriptionWebService>()),
  );

  getIt.registerFactory<SubscriptionCubit>(
    () => SubscriptionCubit(getIt<SubscriptionRepository>()),
  );

  // 🔥 🎯 تسجيل ميزة الأهداف والاحتياجات الغذائية الجديدة هنا
  getIt.registerLazySingleton<TargetWebService>(
    () => TargetWebService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<TargetRepository>(
    () => TargetRepository(getIt<TargetWebService>()),
  );
  getIt.registerFactory<TargetCubit>(
    () => TargetCubit(getIt<TargetRepository>()),
  );

  getIt.registerLazySingleton<TraineeSubscriptionWebService>(
    () => TraineeSubscriptionWebService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<TraineeSubscriptionRepository>(
    () => TraineeSubscriptionRepository(getIt<TraineeSubscriptionWebService>()),
  ); // تسجيل WebService و Repository الخاص بالخطط (بما فيها الأيام)
  getIt.registerLazySingleton<ExistingDaysWebService>(
    () => ExistingDaysWebService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ExistingDaysRepository>(
    () => ExistingDaysRepository(getIt<ExistingDaysWebService>()),
  );

  // تسجيل الـ Cubit الخاص بالأيام الموجودة مسبقاً
  getIt.registerFactory<ExistingDaysCubit>(
    () => ExistingDaysCubit(getIt<ExistingDaysRepository>()),
  );

  // Create Plan feature

  getIt.registerLazySingleton<CreatePlanService>(
    () => CreatePlanService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<CreatePlanRepository>(
    () => CreatePlanRepository(getIt<CreatePlanService>()),
  );

  getIt.registerFactory<CreatePlanCubit>(
    () => CreatePlanCubit(getIt<CreatePlanRepository>()),
  );

  getIt.registerLazySingleton<AiChatWebService>(
    () => AiChatWebService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AiChatRepository>(
    () => AiChatRepository(getIt<AiChatWebService>()),
  );
  getIt.registerFactory<AiChatCubit>(
    () => AiChatCubit(getIt<AiChatRepository>()),
  );

  // Nutrition
  getIt.registerSingleton<NutritionWebService>(
    NutritionWebService(getIt<Dio>()),
  );

  getIt.registerSingleton<NutritionRepository>(
    NutritionRepository(getIt<NutritionWebService>()),
  );

  getIt.registerSingleton<NutritionCubit>(
    NutritionCubit(getIt<NutritionRepository>()),
  );

  // 🔥 تسجيل My Plans Feature
  getIt.registerLazySingleton<MyPlansService>(
    () => MyPlansService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<MyPlansRepository>(
    () => MyPlansRepository(getIt<MyPlansService>()),
  );

  getIt.registerLazySingleton<MyPlansCubit>(
    () => MyPlansCubit(getIt<MyPlansRepository>()),
  );
  getIt.registerFactory<PlanDaysCubit>(
    () => PlanDaysCubit(getIt<MyPlansRepository>()),
  );
  getIt.registerFactory<ActiveWorkoutCubit>(
    () => ActiveWorkoutCubit(getIt<MyPlansRepository>()),
  );

  getIt.registerLazySingleton<PlatformPlansWebService>(
    () => PlatformPlansWebService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<PlatformPlansRepository>(
    () => PlatformPlansRepository(getIt<PlatformPlansWebService>()),
  );

  getIt.registerLazySingleton<PlatformPlansCubit>(
    () => PlatformPlansCubit(getIt<PlatformPlansRepository>()),
  );
  // Trainees feature

  getIt.registerLazySingleton<TraineesWebService>(
    () => TraineesWebService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<TraineesRepository>(
    () => TraineesRepository(getIt<TraineesWebService>()),
  );

  getIt.registerFactory<TraineesCubit>(
    () => TraineesCubit(getIt<TraineesRepository>()),
  );

  // Plan Details

  getIt.registerLazySingleton<PlanDetailsWebService>(
    () => PlanDetailsWebService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<PlanDetailsRepository>(
    () => PlanDetailsRepository(getIt<PlanDetailsWebService>()),
  );

  getIt.registerFactory<PlanDetailsCubit>(
    () => PlanDetailsCubit(getIt<PlanDetailsRepository>()),
  );

  getIt.registerLazySingleton<EditSelfPlanService>(
    () => EditSelfPlanService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<EditSelfPlanRepository>(
    () => EditSelfPlanRepository(getIt<EditSelfPlanService>()),
  );

  getIt.registerFactory<EditSelfPlanCubit>(
    () => EditSelfPlanCubit(getIt<EditSelfPlanRepository>()),
  );
  // تسجيل الـ Web Service
  getIt.registerLazySingleton<NotificationsWebService>(
    () => NotificationsWebService(getIt<Dio>()),
  );

  // تسجيل الـ Repository
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepository(getIt<NotificationsWebService>()),
  );
  // تسجيل الكيوبيت
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(getIt<NotificationsRepository>()),
  );

  // Create Self Plan Feature
  getIt.registerLazySingleton<CreateSelfPlanService>(
    () => CreateSelfPlanService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<CreateSelfPlanRepository>(
    () => CreateSelfPlanRepository(getIt<CreateSelfPlanService>()),
  );

  // 🔥 قم بإضافة هذا السطر لتسجيل الـ Cubit
  getIt.registerFactory<CreateSelfPlanCubit>(
    () => CreateSelfPlanCubit(getIt<CreateSelfPlanRepository>()),
  );

  getIt.registerLazySingleton<CoachHomeRepository>(
    () => CoachHomeRepositoryImpl(
      getIt<ProfileRepository>(),
      getIt<SubscriptionRepository>(),
    ),
  );

  getIt.registerFactory<CoachHomeCubit>(
    () => CoachHomeCubit(getIt<CoachHomeRepository>()),
  );

  // Edit Coach Plan Feature

  getIt.registerLazySingleton<EditCoachPlanService>(
    () => EditCoachPlanService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<EditCoachPlanRepository>(
    () => EditCoachPlanRepository(getIt<EditCoachPlanService>()),
  );

  getIt.registerFactory<EditCoachPlanCubit>(
    () => EditCoachPlanCubit(getIt<EditCoachPlanRepository>()),
  );
}
