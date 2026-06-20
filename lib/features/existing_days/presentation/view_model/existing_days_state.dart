part of 'existing_days_cubit.dart';

@immutable
sealed class ExistingDaysState {}

final class ExistingDaysInitial extends ExistingDaysState {}

final class ExistingDaysLoading extends ExistingDaysState {}

final class ExistingDaysSuccess extends ExistingDaysState {
  final List<ExistingDaysModel> days;

  ExistingDaysSuccess({required this.days});
}

final class ExistingDaysError extends ExistingDaysState {
  final String errorMessage;

  ExistingDaysError({required this.errorMessage});
}