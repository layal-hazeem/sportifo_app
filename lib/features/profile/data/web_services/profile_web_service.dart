import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class ProfileWebService {
  final Dio dio;
  ProfileWebService(this.dio);

  Future<Response> getProfile( { Options? options}) async {
    return await dio.get(ApiConstants.getProfile,
      options: options,

    );

  }

   Future<Response> getCoachProfile() async {
      return await dio.get(ApiConstants.getProfile);

  }

  Future<Response> updateProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      "profile_pic": await MultipartFile.fromFile(imageFile.path),
      "update_pic": 1,
    });

    return await dio.put(ApiConstants.editProfile, data: formData);
  }

  Future<Response> updateProfile(FormData formData) async {
    return await dio.put(ApiConstants.editProfile, data: formData);
  }

  Future<Response> deleteAccount() async {
  return await dio.delete(ApiConstants.profile);
}
}
