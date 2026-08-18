import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class EditSelfPlanService {
  final Dio _dio;

  EditSelfPlanService(this._dio);

  Future<Response> updateSelfPlan(
    int planId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.put(
      '${ApiConstants.editSelfPlan}/$planId',
      data: body,
    );

    return response;
  }
}