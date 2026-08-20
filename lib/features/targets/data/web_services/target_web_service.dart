import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class TargetWebService {
  final Dio dio;
  TargetWebService(this.dio);

  Future<Response> setTarget(String goal) async {
    return await dio.post(
      ApiConstants.targets,
      data: {
        'goal': goal,
      },
    );
  }

  Future<Response> getLatestTarget({Options? options}) async {
    return await dio.get(ApiConstants.targets, options: options);
  }
}