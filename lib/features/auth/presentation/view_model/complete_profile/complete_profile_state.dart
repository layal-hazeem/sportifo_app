part of 'complete_profile_cubit.dart';

@immutable
sealed class CompleteProfileState {}

final class CompleteProfileInitial extends CompleteProfileState {}
class CompleteProfileLoading extends CompleteProfileState {}
class CompleteProfileSuccess extends CompleteProfileState {
  final CompleteProfileResponsModel user;
  CompleteProfileSuccess(this.user);
}
class Error extends CompleteProfileState {
  final String message;
  Error(this.message);
}
