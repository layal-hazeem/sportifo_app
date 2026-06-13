import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../models/target_model.dart';
import '../web_services/target_web_service.dart';

class TargetRepository {
  final TargetWebService _webService;

  TargetRepository(this._webService);

  // 1️⃣ إرسال/تعديل الهدف (POST)
  Future<ApiResult<TargetModel>> setTarget(String goal) async {
    try {
      final response = await _webService.setTarget(goal);
      final responseModel = TargetResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  // 2️⃣ جلب آخر هدف ونظام التغذية الحالي (GET)
  Future<ApiResult<TargetModel>> getLatestTarget() async {
    try {
      final response = await _webService.getLatestTarget();
      final responseModel = TargetResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}