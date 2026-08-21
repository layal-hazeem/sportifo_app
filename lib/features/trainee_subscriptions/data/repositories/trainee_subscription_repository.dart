import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_error_handler.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import '../models/my_subscription_record_model.dart';
import '../web_services/trainee_subscription_web_service.dart';

class TraineeSubscriptionRepository {
  final TraineeSubscriptionWebService _webService;

  TraineeSubscriptionRepository(this._webService);

  Future<ApiResult<String>> subscribe({
    required int coachId,
    required int subscriptionId,
    required int months,
    required num totalPrice,
    String? transactionId,
    required MultipartFile paymentFile,
  }) async {
    try {
      final response = await _webService.subscribe(
        coachId: coachId,
        subscriptionId: subscriptionId,
        months: months,
        totalPrice: totalPrice,
        transactionId: transactionId,
        paymentFile: paymentFile,
      );

      final message = response.data['message'] ?? 'تم إرسال طلب الاشتراك بنجاح';
      return Success(message);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
// ✅ صار الويب سيرفس هو يلي بيبني الـ options، الريبو بس بيمرر bool
  Future<ApiResult<List<MySubscriptionRecordModel>>> getMySubscriptionsRecords({bool forceRefresh = false}) async {
    try {
      final response = await _webService.getMySubscriptionsRecords(forceRefresh: forceRefresh);

      final List data = response.data['data']['data'] ?? [];
      final subscriptions = data
          .map((json) => MySubscriptionRecordModel.fromJson(json))
          .toList();

      return Success(subscriptions);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}