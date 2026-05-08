import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class ProfileWebService {
  final Dio dio;
  ProfileWebService(this.dio);

  Future<Response> getProfile() async {
    return await dio.get(ApiConstants.getProfile);
  }

  Future<Response> updateProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      "profile_pic": await MultipartFile.fromFile(imageFile.path),
    });

    return await dio.put(ApiConstants.editProfile, data: formData);
  }

  Future<Response> updateProfile(FormData formData) async {
    return await dio.put(ApiConstants.editProfile, data: formData);
  }
}
