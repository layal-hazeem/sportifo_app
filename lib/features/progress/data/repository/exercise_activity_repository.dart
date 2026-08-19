import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_factory.dart';
import '../models/exercise_activity_model.dart';
import '../web_services/exercise_activity_web_service.dart';

class ExerciseActivityRepository {
  final ExerciseActivityWebService _webService;

  ExerciseActivityRepository(this._webService);
  Future<ApiResult<List<DayActivity>>> getExerciseActivity({
    int? planId,
    int? exerciseId,
    String? from,
    String? to,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheOptions = await GetIt.instance<DioFactory>().getCacheOptions();
      final policy = forceRefresh
          ? CachePolicy.refresh
          : CachePolicy.forceCache;

      final dioOptions = cacheOptions.copyWith(policy: policy).toOptions();

      final response = await _webService.getExerciseActivity(
        planId: planId,
        exerciseId: exerciseId,
        from: from,
        to: to,
        options: dioOptions,
      );

      final responseModel = ExerciseActivityResponse.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}
