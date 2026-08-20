import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class CreateSelfPlanService {
  final Dio _dio;

  CreateSelfPlanService(this._dio);

  Future<Response> createSelfPlan(
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post(
      ApiConstants.createSelfPlan,
      data: FormData.fromMap(body),
    );

    return response;
  }
}