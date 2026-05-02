import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/profile/data/models/profile_response.dart';
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
        break;
    }
  }
}