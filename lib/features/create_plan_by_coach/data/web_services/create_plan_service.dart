import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class CreatePlanService {
  final Dio _dio;

  CreatePlanService(this._dio);

  Future<Response> createPlan(
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post(
      ApiConstants.createPlan,
      data: FormData.fromMap(body),
    );

    return response;
  }
}