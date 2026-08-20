import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class EditCoachPlanService {
  final Dio dio;

  EditCoachPlanService(this.dio);

  Future<Map<String, dynamic>> updatePlan({
    required int planId,
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      final response = await dio.put(
         '${ApiConstants.planDetails}/$planId',
        data: requestBody,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}