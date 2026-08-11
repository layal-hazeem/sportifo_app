import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class PlanDetailsWebService {
  final Dio _dio;

  PlanDetailsWebService(this._dio);

  Future<Response> getPlanDetails(int planId) async {
    return await _dio.get('${ApiConstants.planDetails}/$planId');
  }
}
