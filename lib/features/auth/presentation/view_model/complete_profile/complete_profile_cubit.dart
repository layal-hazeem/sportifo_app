import 'package:bloc/bloc.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_request_model.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_respons_model.dart';
import 'package:sportifo_app/features/auth/data/repository/auth_repository.dart';

part 'complete_profile_state.dart';

class CompleteProfileCubit extends Cubit<CompleteProfileState> {
  final AuthRepository repository;

  CompleteProfileCubit(this.repository) : super(const CompleteProfileState());

  // 📸 Image
  void setImage(String path) {
    emit(state.copyWith(imagePath: path));
  }

  // ⚖️ Basic info
  void setWeight(double? value) {
    emit(state.copyWith(weight: value));
  }

  void setHeight(double? value) {
    emit(state.copyWith(height: value));
  }

  void setBirthDate(String date) {
    emit(state.copyWith(birthDate: date));
  }

  void setGender(bool value) {
    emit(state.copyWith(gender: value));
  }

  // 📏 Measurements (optional fields)
  void setShoulders(double? value) {
    emit(state.copyWith(shouldersWidth: value));
  }

  void setChest(double? value) {
    emit(state.copyWith(chestPerimeter: value));
  }

  void setWaist(double? value) {
    emit(state.copyWith(waistPerimeter: value));
  }

  void setHip(double? value) {
    emit(state.copyWith(hipPerimeter: value));
  }

  void setThigh(double? value) {
    emit(state.copyWith(thighPerimeter: value));
  }

  void setHand(double? value) {
    emit(state.copyWith(armPerimeter: value));
  }

  // 🚀 Submit profile
  Future<void> completeProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final request = state.toRequestModel();
    final result = await repository.completeProfile(request);

    // سحر الـ Pattern Matching
    switch (result) {
      case Success():
        emit(state.copyWith(status: ProfileStatus.success));
        break;
      case Failure():
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: result.message,
          ),
        );
        break;
    }
  }
}
