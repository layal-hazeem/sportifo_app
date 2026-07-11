import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/profile/data/models/edit_profile_request_model.dart';
import '../../data/repository/profile_repository.dart';
import 'profile_state.dart';
import '../../../../core/network/api_result.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(this._profileRepository) : super(ProfileInitial());

  // داخل ProfileCubit.dart - دالة getProfile
// داخل profile_cubit.dart

  Future<void> getProfile() async {
    // 1. لا تطلعي التحميل إذا كانت الواجهة معروضة سابقاً
    if (state is! ProfileSuccess) {
      emit(ProfileLoading());
    }

    final result = await _profileRepository.getProfile();

    if (isClosed) return;

    switch (result) {
      case Success(data: final profileModel):
        emit(ProfileSuccess(profileModel));
        break;

      case Failure(message: final errorMsg):
      // 🔥 الحماية القصوى: إذا الخطأ سببه "لا يوجد إنترنت"
        if (errorMsg.contains("No Internet") || errorMsg.contains("Connection timeout")) {
          // إذا عندنا داتا سابقة بنبقى عليها
          if (state is ProfileSuccess) return;

          // إذا ماعندنا داتا بالـ State، لكن التطبيق عم يفتح أوفلاين:
          // هنا بنعمل emit(Failure) بس الواجهة رح تعالجها
        }

        // إذا الخطأ سيرفر حقيقي، بنطلعه
        emit(ProfileFailure(errorMsg));
        print("Profile Error: $errorMsg");
        break;
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    emit(ProfileLoading());

    print("Uploading image: ${imageFile.path}");

    final result = await _profileRepository.updateProfileImage(imageFile);

    switch (result) {
      case Success(data: final updatedProfile):
        print("Upload success");
        emit(ProfileSuccess(updatedProfile));
        break;

      case Failure(message: final errorMsg):
        print("Upload failed: $errorMsg");
        emit(ProfileFailure(errorMsg));
        break;
    }
  }

  Future<void> updateProfile(EditProfileRequestModel request) async {
    emit(ProfileLoading());

    final result = await _profileRepository.updateProfile(request);

    switch (result) {
      case Success(data: final updatedProfile):
        emit(ProfileSuccess(updatedProfile));
        break;

      case Failure(message: final errorMsg):
        emit(ProfileFailure(errorMsg));
        break;
    }
  }

  Future<void> getCoachProfile() async {
    emit(ProfileLoading());

    final result = await _profileRepository.getCoachProfile();

    switch (result) {
      case Success(data: final coachModel):
          print("🔥COACH STATE EMITTED");
        emit(CoachProfileSuccess(coachModel));
        break;
      case Failure(message: final errorMsg):
        emit(ProfileFailure(errorMsg));
        break;
    }
  }
}
