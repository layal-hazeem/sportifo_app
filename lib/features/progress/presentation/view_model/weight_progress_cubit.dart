import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../data/repository/weight_progress_repository.dart';
import '../../data/models/weight_progress_model.dart';
import 'weight_progress_state.dart';

class WeightProgressCubit extends Cubit<WeightProgressState> {
  final WeightProgressRepository _repository;

  WeightProgressCubit(this._repository) : super(WeightProgressInitial());
  Future<void> fetchWeightProgress({bool forceRefresh = false}) async {
    emit(WeightProgressLoading());
    final result = await _repository.getWeightProgress(
      forceRefresh: forceRefresh,
    );

    if (isClosed) return;

    if (result is Success<WeightProgressData>) {
      emit(WeightProgressSuccess(result.data));
    } else if (result is Failure) {
      emit(WeightProgressError((result as Failure).message));
    }
  }
}