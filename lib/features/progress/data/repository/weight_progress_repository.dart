import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_factory.dart';
import '../models/weight_progress_model.dart';
import '../web_services/weight_progress_web_service.dart';

class WeightProgressRepository {
  final WeightProgressWebService _webService;

  WeightProgressRepository(this._webService);
  Future<ApiResult<WeightProgressData>> getWeightProgress({
    bool forceRefresh = false,
  }) async {
    try {
      final cacheOptions = await GetIt.instance<DioFactory>().getCacheOptions();
      final policy = forceRefresh
          ? CachePolicy.refresh
          : CachePolicy.forceCache;

      final dioOptions = cacheOptions.copyWith(policy: policy).toOptions();

      final response = await _webService.getWeightProgress(options: dioOptions);
      final responseModel = WeightProgressResponse.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}
