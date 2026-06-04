// تأكدي من استيراد ApiResult و ApiErrorHandler
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

  // =====================================
  // 1. دالة جلب العضلات الأساسية (للصور اللي فوق)
  // =====================================
  Future<ApiResult<List<FilterItemModel>>> getCategories(int id) async {
    try {
      final response = await _webService.getCategories(id);
      final responseModel = FilterResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  // =====================================
  // 2. دالة جلب الأجزاء الدقيقة (للكبسولات)
  // =====================================
  Future<ApiResult<List<FilterItemModel>>> getSubCategories(int organId) async {
    try {
      final response = await _webService.getSubCategories(organId);
      final responseModel = FilterResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<ExerciseModel>>> getExercises({
    int? categoryId,
    int? organId,
    List<int>? partIds,
    String? searchQuery,
  }) async {
    try {
      // ✅ إزالة كل شيء متعلق بـ cacheOptions و copyWith
      final response = await _webService.getExercises(
        categoryId: categoryId,
        organId: organId,
        partIds: partIds,
        searchQuery: searchQuery,
      );
      final responseModel = ExerciseResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }


  // داخل WorkoutRepository
  Future<ApiResult<bool>> toggleSaveExercise(int exerciseId) async {
    try {
      final response = await _webService.toggleSaveExercise(exerciseId);
      // إذا كان الباك إند يرجع success: true عند النجاح
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

      // إذا كانت الاستجابة هي الكائن نفسه (ResponseModel)
      final responseModel = ExerciseResponseModel.fromJson(response.data);
      return Success(responseModel.data);

    } catch (e) {
      print("Error fetching saved: $e");
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}