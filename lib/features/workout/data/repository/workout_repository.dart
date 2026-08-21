import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_factory.dart';
import '../models/exercise_model.dart';
import '../models/filter_item_model.dart';
import '../web_services/workout_web_service.dart';

class WorkoutRepository {
  final WorkoutWebService _webService;
  WorkoutRepository(this._webService);
 Future<ApiResult<List<FilterItemModel>>> getCategories(int id) async {
  try {
    final cacheOptions = await DioFactory.getCacheOptions();
    final dioOptions = cacheOptions.copyWith(
      policy: CachePolicy.request,        // ← يحاول السيرفر أولاً
      maxStale: const Duration(days: 30), // ← صلاحية الكاش
    ).toOptions();

    final response = await _webService.getCategories(id, options: dioOptions);
    final responseModel = FilterResponseModel.fromJson(response.data);
    return Success(responseModel.data);
  } catch (e) {
    return Failure(ApiErrorHandler.handle(e));
  }
}
Future<ApiResult<List<ExerciseModel>>> getExercises({
  int? categoryId,
  int? organId,
  List<int>? smallestCategoryId,
  String? searchQuery,
}) async {
  try {
    final cacheOptions = await DioFactory.getCacheOptions();
    final dioOptions = cacheOptions.copyWith(
      policy: CachePolicy.request,        // ← جرب السيرفر أولاً
      maxStale: const Duration(days: 7),  // ← صلاحية الكاش
    ).toOptions();

  Future<ApiResult<List<ExerciseModel>>> getAlternativeExercises(int exerciseId) async {
    try {
      final response = await _webService.getAlternativeExercises(exerciseId);
      final List data = response.data['data'] ?? [];
      final List<ExerciseModel> exercises = data.map((json) => ExerciseModel.fromJson(json)).toList();
      return Success(exercises);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
  Future<ApiResult<List<FilterItemModel>>> getSubCategories(int organId) async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.forceCache,
      ).toOptions();

    final response = await _webService.getExercises(
      categoryId: categoryId,
      organId: organId,
      smallestCategoryId: smallestCategoryId,
      searchQuery: searchQuery,
      options: dioOptions,
    );

    final responseModel = ExerciseResponseModel.fromJson(response.data);
    return Success(responseModel.data);
  } catch (e) {
    return Failure(ApiErrorHandler.handle(e));
  }
}

Future<ApiResult<List<FilterItemModel>>> getSubCategories(int organId) async {
  try {
    final cacheOptions = await DioFactory.getCacheOptions();
    final dioOptions = cacheOptions.copyWith(
      policy: CachePolicy.request,
      maxStale: const Duration(days: 30),
    ).toOptions();

    final response = await _webService.getSubCategories(organId, options: dioOptions);
    final responseModel = FilterResponseModel.fromJson(response.data);
    return Success(responseModel.data);
  } catch (e) {
    return Failure(ApiErrorHandler.handle(e));
  }
}

  Future<ApiResult<bool>> toggleSaveExercise(int exerciseId) async {
    try {
      final response = await _webService.toggleSaveExercise(exerciseId);
      final isSuccess = response.statusCode == 200 || response.statusCode == 201;
      if (isSuccess) {
        return Success(true);
      }
      return Failure("Failed to save exercise");
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

Future<ApiResult<List<ExerciseModel>>> getSavedExercises({
  bool forceRefresh = false,
}) async {
  try {
    final cacheOptions = await DioFactory.getCacheOptions();
    final policy = forceRefresh 
        ? CachePolicy.refresh  
        : CachePolicy.forceCache; 
    
    final dioOptions = cacheOptions.copyWith(
      policy: policy,
    ).toOptions();

    final response = await _webService.getSavedExercises(options: dioOptions);

    if (response.data['data'] is List) {
      final List data = response.data['data'];
      final exercises = data.map((e) => ExerciseModel.fromJson(e)).toList();
      return Success(exercises);
    }

    final responseModel = ExerciseResponseModel.fromJson(response.data);
    return Success(responseModel.data);
  } catch (e) {
    print("Error fetching saved: $e");
    return Failure(ApiErrorHandler.handle(e));
  }
}
}