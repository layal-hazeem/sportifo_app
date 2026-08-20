import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart'; // ✅ أضيفي هاد
import 'package:sportifo_app/core/network/api_constants.dart';

class TraineeSubscriptionWebService {
  final Dio _dio;

  TraineeSubscriptionWebService(this._dio);

  Future<Map<String, dynamic>> getSubscriptions() async {
    try {
      final response = await _dio.get(ApiConstants.usersSubscribed);
      if (response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Response data is empty');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> subscribe({
    required int coachId,
    required int subscriptionId,
    required int months,
    required num totalPrice,
    String? transactionId,
    required MultipartFile paymentFile,
  }) async {
    final formData = FormData.fromMap({
      'coach_id': coachId,
      'subscription_id': subscriptionId,
      'months': months,
      'total_price': totalPrice,
      if (transactionId != null && transactionId.isNotEmpty)
        'transaction_id': transactionId,
      'payment_file': paymentFile,
    });

    return await _dio.post(
      ApiConstants.subscribe,
      data: formData,
    );
  }

  // ✅ عدّلنا الطريقة يلي منجبر فيها تجاوز الكاش
  Future<Response> getMySubscriptionsRecords({bool forceRefresh = false}) async {
    final Options? options = forceRefresh
        ? CacheOptions(
      policy: CachePolicy.refresh, store: null, // ✅ هاد يلي فعلياً بيفرض طلب جديد من السيرفر
    ).toOptions()
        : null;

    return await _dio.get(
      ApiConstants.mySubscriptions,
      options: options,
    );
  }
}