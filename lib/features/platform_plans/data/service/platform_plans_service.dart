import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class PlatformPlansWebService {
  final Dio dio;

  PlatformPlansWebService(this.dio);

  Future<Response> getPlatformPlans({int page = 1, Options? options}) async {
    return await dio.get(
      ApiConstants.platformPlans,
      queryParameters: {'page': page},
      options: options,
    );
  }

  Future<Response> toggleSavePlan(int planId) async {
    return await dio.post(
      ApiConstants.toggleSavePlatformPlan(planId),
    );
  }

  Future<Response> getSavedPlatformPlans({int page = 1, Options? options}) async {
    return await dio.get(
      ApiConstants.savedPlatformPlans,
      queryParameters: {'page': page},
      options: options,
    );
  }
}