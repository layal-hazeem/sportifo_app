import 'package:dio/dio.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';

class SubscriptionWebService {
  final Dio _dio;

  SubscriptionWebService(this._dio);

  Future<Map<String, dynamic>> getSubscriptions() async {
    try {
      // هنا نستخدم المسار الخاص بجلب الاشتراكات من الـ api_constants
      final response = await _dio.get(AppRoutes.usersSubscribed);
      
      // نتحقق من أن الطلب تم بنجاح
      if (response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Response data is empty');
      }
    } catch (e) {
      // إعادة رمي الخطأ ليتم التعامل معه في الطبقات الأعلى
      rethrow;
    }
  }
}