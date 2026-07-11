import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/api_error_handler.dart';

import '../../../../core/network/dio_factory.dart';
import '../models/exercise_model.dart';
import '../models/filter_item_model.dart';
import '../web_services/workout_web_service.dart';

class WorkoutRepository {
  final WorkoutWebService _webService;
  WorkoutRepository(this._webService);

  // 1. دالة جلب العضلات الأساسية (للصور اللي فوق)
  Future<ApiResult<List<FilterItemModel>>> getCategories(int id) async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();

      // 🔥 التعديل السحري 1: forceCache
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.forceCache,
      ).toOptions();

      final response = await _webService.getCategories(id, options: dioOptions);

      final responseModel = FilterResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  // 2. دالة جلب الأجزاء الدقيقة (للكبسولات)
  Future<ApiResult<List<FilterItemModel>>> getSubCategories(int organId) async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();

      // 🔥 التعديل السحري 2: forceCache
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.forceCache,
      ).toOptions();

      final response = await _webService.getSubCategories(organId, options: dioOptions);

      final responseModel = FilterResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  // 3. دالة جلب التمارين الأساسية
  Future<ApiResult<List<ExerciseModel>>> getExercises({
    int? categoryId,
    int? organId,
    List<int>? smallestCategoryId,
    String? searchQuery,
  }) async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();

      // 🔥 التعديل السحري 3: forceCache
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.forceCache,
      ).toOptions();

      final response = await _webService.getExercises(
        categoryId: categoryId,
        organId: organId,
        smallestCategoryId: smallestCategoryId,
        searchQuery: searchQuery,
        options: dioOptions, // ✅ ممتاز، أنتِ ممررتيها هنا بشكل صحيح
      );

      final responseModel = ExerciseResponseModel.fromJson(response.data);

      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  // ---------------- باقي الدوال (بدون كاش لأنها عمليات حيوية) ----------------

  Future<ApiResult<bool>> toggleSaveExercise(int exerciseId) async {
    try {
      final response = await _webService.toggleSaveExercise(exerciseId);
      // السيرفر يرجع {"message":201,"data":"..."}  أو {"success":true}
      // نتحقق من status code وليس success field
      final isSuccess = response.statusCode == 200 || response.statusCode == 201;
      if (isSuccess) {
        return Success(true);
      }
      return Failure("Failed to save exercise");
      return Success(response.data['success'] ?? true);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<ExerciseModel>>> getSavedExercises() async {
    try {
      final response = await _webService.getSavedExercises();

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