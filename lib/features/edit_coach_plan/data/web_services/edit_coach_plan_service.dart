import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class EditCoachPlanService {
  final Dio _dio;

  EditCoachPlanService(this._dio);

  Future<Response> updatePlan(
    int planId,
    Map<String, dynamic> body,
  ) async {
    return await _dio.put(
      '${ApiConstants.planDetails}/$planId',
      data: body,
    );
  }
}