import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:sportifo_app/core/network/api_error_handler.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/profile/data/models/edit_coach_profile_request_model.dart';
import 'package:sportifo_app/features/profile/data/models/edit_profile_request_model.dart';
import 'package:sportifo_app/features/profile/data/models/get_profile_response.dart';
import 'package:sportifo_app/features/profile/data/web_services/profile_web_service.dart';

import '../../../../core/network/dio_factory.dart';

class ProfileRepository {
  final ProfileWebService _profileWebService;

  ProfileRepository(this._profileWebService);

  Future<ApiResult<ProfileResponseModel>> getProfile() async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();
      final dioOptions = cacheOptions
          .copyWith(policy: CachePolicy.refresh)
          .toOptions();

      // مرري الـ dioOptions للـ WebService
      final response = await _profileWebService.getProfile(options: dioOptions);
      return Success(ProfileResponseModel.fromJson(response.data['data']));
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ProfileResponseModel>> updateProfileImage(
    File imageFile,
  ) async {
    try {
      final response = await _profileWebService.updateProfileImage(imageFile);
      final json = response.data['data'] ?? response.data;

      return Success(ProfileResponseModel.fromJson(json));
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ProfileResponseModel>> updateProfile(
    EditProfileRequestModel request,
  ) async {
    try {
      final formData = await request.toFormData();

      final response = await _profileWebService.updateProfile(formData);

      return Success(ProfileResponseModel.fromJson(response.data['data']));
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ProfileResponseModel>> updateCoachProfile(
  EditCoachProfileRequestModel request,
) async {
  try {
    final formData = await request.toFormData();

    final response = await _profileWebService.updateProfile(formData);

    return Success(ProfileResponseModel.fromJson(response.data['data']));
  } catch (e) {
    return Failure(ApiErrorHandler.handle(e));
  }
}

  Future<ApiResult<String>> deleteAccount() async {
    try {
      final response = await _profileWebService.deleteAccount();

      return Success(
        response.data['message'] ?? "Account deleted successfully",
      );
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}
