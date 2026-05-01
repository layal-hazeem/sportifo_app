import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class ProfileWebService {
    final Dio dio;
  ProfileWebService(this.dio);

    Future<Response> getProfile() async {
  return await dio.get(
    ApiConstants.getProfile, 
  );
}
}