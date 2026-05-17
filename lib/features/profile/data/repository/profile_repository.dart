import 'dart:io';

import 'package:sportifo_app/core/network/api_error_handler.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/profile/data/models/edit_profile_request_model.dart';
import 'package:sportifo_app/features/profile/data/models/profile_response.dart';
import 'package:sportifo_app/features/profile/data/web_services/profile_web_service.dart';

class ProfileRepository {
  final ProfileWebService _profileWebService;

  ProfileRepository(this._profileWebService);

  Future<ApiResult<ProfileResponsModel>> getProfile() async {
    try {
      final response = await _profileWebService.getProfile();
      print(response.data);
      return Success(ProfileResponsModel.fromJson(response.data['data']));
    } catch (e, stacktrace) {
      print("Parsing Error: $e");
      print(
        "Stacktrace: $stacktrace",
      ); // هذا سيخبرك في أي سطر بالضبط فشل التحويل
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ProfileResponsModel>> updateProfileImage(
    File imageFile,
  ) async {
    try {
      final response = await _profileWebService.updateProfileImage(imageFile);
      final json = response.data['data'] ?? response.data;

      return Success(ProfileResponsModel.fromJson(json));
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ProfileResponsModel>> updateProfile(
    EditProfileRequestModel request,
  ) async {
    try {
      final formData = await request.toFormData();

      final response = await _profileWebService.updateProfile(formData);

      return Success(ProfileResponsModel.fromJson(response.data['data']));
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}
