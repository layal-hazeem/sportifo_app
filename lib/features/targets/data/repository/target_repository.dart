import 'package:dio_cache_interceptor/dio_cache_interceptor.dart'; // تأكدي من هذا الاستيراد
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_factory.dart'; // لاستدعاء DioFactory
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
      // 🔥 تفعيل الكاش الذكي لجلب الأهداف
      final cacheOptions = await DioFactory.getCacheOptions();
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.forceCache,
      ).toOptions();

      // تمرير الـ dioOptions للـ WebService
      final response = await _webService.getLatestTarget(options: dioOptions);
      final responseModel = TargetResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}