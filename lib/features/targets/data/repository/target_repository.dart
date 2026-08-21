import 'package:dio/dio.dart'; // 🔥 ضفنا استيراد Dio لمعرفة الـ DioException
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_factory.dart';
import '../models/target_model.dart';
import '../web_services/target_web_service.dart';

class TargetRepository {
  final TargetWebService _webService;

  TargetRepository(this._webService);

  Future<ApiResult<TargetModel>> setTarget(String goal) async {
    try {
      final response = await _webService.setTarget(goal);
      final responseModel = TargetResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<TargetModel>> getLatestTarget() async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.forceCache,
      ).toOptions();

      final response = await _webService.getLatestTarget(options: dioOptions);
      final responseModel = TargetResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return Failure("not found");
      }
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}