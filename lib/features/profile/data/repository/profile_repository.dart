import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:sportifo_app/core/network/api_error_handler.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/profile/data/models/coach_profile_response.dart';
import 'package:sportifo_app/features/profile/data/models/edit_profile_request_model.dart';
import 'package:sportifo_app/features/profile/data/models/user_profile_response.dart';
import 'package:sportifo_app/features/profile/data/web_services/profile_web_service.dart';

import '../../../../core/network/dio_factory.dart';

class ProfileRepository {
  final ProfileWebService _profileWebService;

  ProfileRepository(this._profileWebService);

  // داخل ProfileRepository.dart
  Future<ApiResult<ProfileResponsModel>> getProfile() async {
    try {
      // 🔥 تفعيل الكاش للبروفايل بسياسة ذكية (النت أولاً، والكاش كخطة بديلة)
      final cacheOptions = await DioFactory.getCacheOptions();
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.forceCache,
      ).toOptions();

      // مرري الـ dioOptions للـ WebService
      final response = await _profileWebService.getProfile(options: dioOptions);
      return Success(ProfileResponsModel.fromJson(response.data['data']));
    } catch (e, stacktrace) {
      print("Parsing Error: $e");
      print("Stacktrace: $stacktrace");
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<CoachProfileModel>> getCoachProfile() async {
    try {
      final response = await _profileWebService.getCoachProfile();
      return Success(CoachProfileModel.fromJson(response.data['data']));
    } catch (e, stacktrace) {
      print("Parsing Error: $e");
      print("Stacktrace: $stacktrace");
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
