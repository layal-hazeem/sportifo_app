import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/complete_profile/complete_profile_cubit.dart';
import '../../features/auth/data/repository/auth_repository.dart';
import '../../features/auth/data/web_services/auth_webService.dart';
import '../../features/auth/presentation/view_model/login/login_cubit.dart';
import '../../features/auth/presentation/view_model/register/register_cubit.dart';
import '../network/dio_factory.dart';
import '../storage/local_storage.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage(getIt<SharedPreferences>()));
  // 1. Dio
  getIt.registerLazySingleton<Dio>(() => DioFactory(getIt<LocalStorage>()).dio);

  // 2. Web Services
  getIt.registerLazySingleton<AuthWebService>(() => AuthWebService(getIt<Dio>()));

  // 3. Repository
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<AuthWebService>()));

  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt<AuthRepository>()));

  getIt.registerFactory<RegisterCubit>(() => RegisterCubit(getIt<AuthRepository>()));

  getIt.registerFactory<CompleteProfileCubit>(() => CompleteProfileCubit(getIt<AuthRepository>()));
}