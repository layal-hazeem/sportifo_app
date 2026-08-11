import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class PlatformPlansWebService {
  final Dio dio;

  PlatformPlansWebService(this.dio);

  // 1. جلب الخطط المجانية
  Future<Response> getPlatformPlans({int page = 1, Options? options}) async {
    return await dio.get(
      ApiConstants.platformPlans,
      queryParameters: {'page': page},
      options: options,
    );
  }

  // 2. حفظ أو إلغاء حفظ الخطة
  Future<Response> toggleSavePlan(int planId) async {
    return await dio.post(
      ApiConstants.toggleSavePlatformPlan(planId),
    );
  }

  // 3. جلب الخطط المحفوظة
  Future<Response> getSavedPlatformPlans({int page = 1, Options? options}) async {
    return await dio.get(
      ApiConstants.savedPlatformPlans,
      queryParameters: {'page': page},
      options: options,
    );
  }
}