// تأكدي من استيراد ApiResult و ApiErrorHandler
 import '../../../../core/network/api_result.dart';
 import '../../../../core/network/api_error_handler.dart';

import '../models/exercise_model.dart';
import '../models/filter_item_model.dart';
import '../web_services/workout_web_service.dart';

class WorkoutRepository {
  final WorkoutWebService _webService;
  WorkoutRepository(this._webService);

  // أضيفي هذه الدالة داخل WorkoutRepository

  Future<ApiResult<List<FilterItemModel>>> getSubCategories(int parentId) async {
    try {
      final response = await _webService.getSubCategories(parentId);
      final responseModel = FilterResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
  Future<ApiResult<List<ExerciseModel>>> getExercises({
    int? categoryId,
    int? organId,
    int? partId,
  }) async {
    try {
      final response = await _webService.getExercises(
        categoryId: categoryId,
        organId: organId,
        partId: partId,
      );

      final responseModel = ExerciseResponseModel.fromJson(response.data);

      // نرجع الـ Data (وهي List<ExerciseModel>)
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}