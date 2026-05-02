part of 'complete_profile_cubit.dart';

enum ProfileStatus { initial, loading, success, error }

class CompleteProfileState {
  final String? imagePath;
  final double? weight;
  final double? height;
  final String? birthDate;
  final bool? gender;

  final double? shouldersWidth;
  final double? chestPerimeter;
  final double? waistPerimeter;
  final double? thighPerimeter;
  final double? hipPerimeter;
  final double? armPerimeter;

  final ProfileStatus status;
  final String? errorMessage;

  const CompleteProfileState({
    this.imagePath,
    this.weight,
    this.height,
    this.birthDate,
    this.gender,
    this.shouldersWidth,
    this.chestPerimeter,
    this.waistPerimeter,
    this.thighPerimeter,
    this.hipPerimeter,
    this.armPerimeter,
    this.status = ProfileStatus.initial,
    this.errorMessage,
  });

  CompleteProfileState copyWith({
    String? imagePath,
    double? weight,
    double? height,
    String? birthDate,
    bool? gender,
    double? shouldersWidth,
    double? chestPerimeter,
    double? waistPerimeter,
    double? thighPerimeter,
    double? hipPerimeter,
    double? armPerimeter,
    ProfileStatus? status,
    String? errorMessage,
  }) {
    return CompleteProfileState(
      imagePath: imagePath ?? this.imagePath,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      shouldersWidth: shouldersWidth ?? this.shouldersWidth,
      chestPerimeter: chestPerimeter ?? this.chestPerimeter,
      waistPerimeter: waistPerimeter ?? this.waistPerimeter,
      thighPerimeter: thighPerimeter ?? this.thighPerimeter,
      hipPerimeter: hipPerimeter ?? this.hipPerimeter,
      armPerimeter: armPerimeter ?? this.armPerimeter,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  CompleteProfileRequestModel toRequestModel() {
    return CompleteProfileRequestModel(
      profile_pic: imagePath,
      weight: weight,
      height: height,
      date_of_birth: birthDate,
      gender: gender,

      shoulders_width: shouldersWidth,
      chest_perimeter: chestPerimeter,
      waist_perimeter: waistPerimeter,
      hip_perimeter: hipPerimeter,
      thigh_perimeter: thighPerimeter,
      arm_perimeter: armPerimeter,
    );
  }

  bool get isComplete =>
      weight != null &&
      height != null &&
      birthDate != null &&
      gender != null &&
      weight != null &&
      height != null &&
      weight! > 0 &&
      height! > 0;
}

final class CompleteProfileInitial extends CompleteProfileState {}

class CompleteProfileLoading extends CompleteProfileState {}

class CompleteProfileSuccess extends CompleteProfileState {
  final CompleteProfileResponsModel user;
  CompleteProfileSuccess(this.user);
}

class CompleteProfileError extends CompleteProfileState {
  final String errorMessage;
  CompleteProfileError(this.errorMessage);
}
