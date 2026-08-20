import '../../../data/models/target_model.dart';

sealed class TargetState {}

final class TargetInitial extends TargetState {}

final class TargetLoading extends TargetState {}

final class TargetSuccess extends TargetState {
  final TargetModel targetData;
  TargetSuccess(this.targetData);
}

final class TargetNotSet extends TargetState {}

final class TargetFailure extends TargetState {
  final String errorMessage;
  TargetFailure(this.errorMessage);
}

final class TargetWeightMissing extends TargetState {
  final String message;
  TargetWeightMissing(this.message);
}