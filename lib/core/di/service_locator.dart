import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../features/auth/data/repository/auth_repository.dart';
import '../../features/auth/data/web_services/auth_webService.dart';
import '../../features/auth/presentation/view_model/login/login_cubit.dart';
import '../network/dio_factory.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // 1. Dio
  getIt.registerLazySingleton<Dio>(() => DioFactory().dio);

  // 2. Web Services
  getIt.registerLazySingleton<AuthWebService>(() => AuthWebService(getIt<Dio>()));

  // 3. Repository
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<AuthWebService>()));

  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt<AuthRepository>()));
}