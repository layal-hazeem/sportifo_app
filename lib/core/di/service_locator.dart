import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportifo_app/features/%20ads/presentation/view_model/ads_cubit.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/complete_profile/complete_profile_cubit.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:sportifo_app/features/existing_days/data/repository/existing_days_repository.dart';
import 'package:sportifo_app/features/existing_days/data/web_services/existing_days_web_services.dart';
import 'package:sportifo_app/features/existing_days/presentation/view_model/existing_days_cubit.dart';
import 'package:sportifo_app/features/plans/data/repository/create_plan_repository.dart';
import 'package:sportifo_app/features/plans/data/web_services/create_plan_service.dart';
import 'package:sportifo_app/features/plans/presentation/view_model/create_plan_cubit.dart';
import 'package:sportifo_app/features/profile/data/repository/profile_repository.dart';
import 'package:sportifo_app/features/profile/data/web_services/profile_web_service.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:sportifo_app/features/subscriptions/data/repository/subscription_repository.dart';
import 'package:sportifo_app/features/subscriptions/data/web_services/subscriptions_web_service.dart';
import 'package:sportifo_app/features/subscriptions/presentation/view_model/subscription_cubit.dart';
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
import '../../features/targets/data/repository/target_repository.dart';
import '../../features/targets/data/web_services/target_web_service.dart';
import '../../features/targets/presentation/view_model/target_cubit/target_cubit.dart';
import '../../features/workout/data/repository/workout_repository.dart';
import '../../features/workout/data/web_services/workout_web_service.dart';
import '../../features/workout/presentation/view_model/categories_cubit/categories_cubit.dart';
import '../../features/workout/presentation/view_model/exercises_cubit/exercises_cubit.dart';
import '../../features/workout/presentation/view_model/saved_exercises/saved_exercises_cubit.dart';
import '../../features/workout/presentation/view_model/parts_cubit/parts_cubit.dart';
import '../../features/workout/presentation/view_model/search_cubit/search_cubit.dart';

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
  getIt.registerFactory<ExercisesCubit>(
    () => ExercisesCubit(getIt<WorkoutRepository>()),
  );
  getIt.registerFactory<CategoriesCubit>(
    () => CategoriesCubit(getIt<WorkoutRepository>()),
  );

  getIt.registerFactory<PartsCubit>(
    () => PartsCubit(getIt<WorkoutRepository>()),
  );
  getIt.registerLazySingleton<SavedExercisesCubit>(
    () => SavedExercisesCubit(getIt<WorkoutRepository>()),
  );

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

  // تسجيل WebService و Repository الخاص بالخطط (بما فيها الأيام)
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
}
