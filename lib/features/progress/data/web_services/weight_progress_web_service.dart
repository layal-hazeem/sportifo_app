import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class WeightProgressWebService {
  final Dio dio;

  WeightProgressWebService(this.dio);
  Future<Response> getWeightProgress({Options? options}) async {
    return await dio.get(ApiConstants.weightProgress, options: options);
  }
}
