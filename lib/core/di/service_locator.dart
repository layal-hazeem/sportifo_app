import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/complete_profile/complete_profile_cubit.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:sportifo_app/features/profile/data/repository/profile_repository.dart';
import 'package:sportifo_app/features/profile/data/web_services/profile_web_service.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_cubit.dart';
import '../../features/auth/data/repository/auth_repository.dart';
import '../../features/auth/data/web_services/auth_webService.dart';
import '../../features/auth/presentation/view_model/login/forgot_password_cubit.dart';
import '../../features/auth/presentation/view_model/login/login_cubit.dart';
import '../../features/auth/presentation/view_model/register/register_cubit.dart';
import '../../features/workout/data/repository/workout_repository.dart';
import '../../features/workout/data/web_services/workout_web_service.dart';
import '../../features/workout/presentation/view_model/categories_cubit/categories_cubit.dart';
import '../../features/workout/presentation/view_model/exercises_cubit/exercises_cubit.dart';
import '../../features/workout/presentation/view_model/parts_cubit/parts_cubit.dart';
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
  // 1. Dio
  getIt.registerLazySingleton<Dio>(() => DioFactory(getIt<LocalStorage>()).dio);

  // 2. Web Services
  getIt.registerLazySingleton<AuthWebService>(
    () => AuthWebService(getIt<Dio>()),
  );

  // 3. Repository
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

  // 🔥 4. قسم التمارين (Workouts)
  // تأكدي من عمل import لهذه الملفات في الأعلى
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

  getIt.registerFactory<PartsCubit>(() => PartsCubit(getIt<WorkoutRepository>()));



  getIt.registerLazySingleton<ProfileWebService>(
    () => ProfileWebService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(getIt<ProfileWebService>()),
  );

  // Cubit
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt<ProfileRepository>()),
  );

  getIt.registerFactory<LogoutCubit>(
    () => LogoutCubit(getIt<AuthRepository>()),
  );
  // إعدادات اللغة
  getIt.registerFactory<LocaleCubit>(() => LocaleCubit(getIt<LocalStorage>()));
}
