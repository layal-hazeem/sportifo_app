// تأكدي من استيراد ApiResult و ApiErrorHandler
import '../../../../core/network/api_result.dart';
import '../../../../core/network/api_error_handler.dart';

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
}