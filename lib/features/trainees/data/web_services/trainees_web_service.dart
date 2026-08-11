import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class TraineesWebService {
  final Dio _dio;

  TraineesWebService(this._dio);

  Future<Response> getCoachTrainees() async {
    return await _dio.get(
      ApiConstants.trainees,
    );
  }
}