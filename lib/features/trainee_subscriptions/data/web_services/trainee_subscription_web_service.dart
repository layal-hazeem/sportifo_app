import 'package:dio/dio.dart';
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
}