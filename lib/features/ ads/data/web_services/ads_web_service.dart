import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class AdsWebService {
  final Dio dio;

  AdsWebService(this.dio);

  Future<Response> getAds() async {
    return await dio.get(ApiConstants.advertisement);
  }
}