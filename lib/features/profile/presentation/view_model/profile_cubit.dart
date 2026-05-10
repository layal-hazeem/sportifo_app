import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/profile/data/models/edit_profile_request_model.dart';
import '../../data/repository/profile_repository.dart';
import 'profile_state.dart';
import '../../../../core/network/api_result.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(this._profileRepository) : super(ProfileInitial());

  Future<void> getProfile() async {
    emit(ProfileLoading());

    final result = await _profileRepository.getProfile();

    switch (result) {
      case Success(data: final profileModel):
        emit(ProfileSuccess(profileModel));
        break;

      case Failure(message: final errorMsg):
        emit(ProfileError(errorMsg));
        print(errorMsg);
        break;
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    final currentState = state;

    final result = await _profileRepository.updateProfileImage(imageFile);

    switch (result) {
      case Success(data: final updatedProfile):
        emit(ProfileSuccess(updatedProfile));
        break;

      case Failure(message: final errorMsg):
        emit(ProfileError(errorMsg));
        if (currentState is ProfileSuccess) {
          emit(currentState);
        }
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
        emit(ProfileError(errorMsg));
        break;
    }
  }
}
