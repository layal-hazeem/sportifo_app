import 'package:bloc/bloc.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_request_model.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_respons_model.dart';
import 'package:sportifo_app/features/auth/data/repository/auth_repository.dart';

part 'complete_profile_state.dart';

class CompleteProfileCubit extends Cubit<CompleteProfileState> {
  final AuthRepository repository;

  CompleteProfileCubit(this.repository)
      : super(const CompleteProfileState());

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

  void setGender(String value) {
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

    try {
      final request = state.toRequestModel();

      final CompleteProfileResponsModel response =
          await repository.completeProfile(request);

      emit(state.copyWith(status: ProfileStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}