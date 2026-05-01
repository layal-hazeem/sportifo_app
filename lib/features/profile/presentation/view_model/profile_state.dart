import '../../data/models/profile_response.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final ProfileResponsModel profileModel;
  ProfileSuccess(this.profileModel);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}