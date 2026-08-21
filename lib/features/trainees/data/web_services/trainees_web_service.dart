import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class TraineesWebService {
  final Dio _dio;

  TraineesWebService(this._dio);

    Future<Response> getCoachTrainees({
    bool forceRefresh = false,
  }) async {
    return await _dio.get(
      ApiConstants.trainees,
      options: forceRefresh
          ? CacheOptions(
              policy: CachePolicy.refresh, store: null,
            ).toOptions()
          : null,
    );
  }
}