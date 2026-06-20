import 'package:dio/dio.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';

class ExistingDaysWebService {
  final Dio _dio;

  ExistingDaysWebService(this._dio);

  Future<Map<String, dynamic>> getExistingDays() async {
    try {
      // المسار الخاص بجلب الأيام الموجودة مسبقاً
      final response = await _dio.get(AppRoutes.existingDays);
      
      if (response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Response data is empty');
      }
    } catch (e) {
      rethrow;
    }
  }
}