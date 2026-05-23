import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../models/ad_model.dart';
import '../web_services/ads_web_service.dart';

class AdsRepository {
  final AdsWebService _webService;

  AdsRepository(this._webService);

  Future<ApiResult<List<AdModel>>> getAds() async {
    try {
      final response = await _webService.getAds();

      final responseModel = AdsResponseModel.fromJson(response.data);

      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}