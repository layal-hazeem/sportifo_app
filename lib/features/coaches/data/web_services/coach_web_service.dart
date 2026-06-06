import 'package:dio/dio.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class CoachWebService {
  final Dio _dio = getIt<Dio>();

  Future<Response> getCoaches({
    Options? options,
    String? search,
    int? gender,
    int? minExp,
    int? maxExp,
  }) async {
    return await _dio.get(
      ApiConstants.coaches,
      options: options,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (gender != null) 'gender': gender,
        if (minExp != null) 'min_exp': minExp,
        if (maxExp != null) 'max_exp': maxExp,
      },
    );
  }

  Future<Response> getCoachDetails(int coachId, {Options? options}) async {
    return await _dio.get(
      '${ApiConstants.coaches}/$coachId',
      options: options,
    );
  }
}