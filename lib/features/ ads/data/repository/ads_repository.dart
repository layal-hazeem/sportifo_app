import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../models/ad_model.dart';
import '../web_services/ads_web_service.dart';
import '../../../../core/network/dio_factory.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class AdsRepository {
  final AdsWebService _webService;

  AdsRepository(this._webService);

  Future<ApiResult<List<AdModel>>> getAds() async {
    try {

      final cacheOptions = await DioFactory.getCacheOptions();

      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.forceCache,
      ).toOptions();

      final response = await _webService.getAds(options: dioOptions);
      final responseModel = AdsResponseModel.fromJson(response.data);

      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}