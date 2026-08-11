import '../../data/models/weight_progress_model.dart';

sealed class WeightProgressState {}

final class WeightProgressInitial extends WeightProgressState {}

final class WeightProgressLoading extends WeightProgressState {}

final class WeightProgressSuccess extends WeightProgressState {
  final WeightProgressData data;
  WeightProgressSuccess(this.data);
}

final class WeightProgressError extends WeightProgressState {
  final String message;
  WeightProgressError(this.message);
}