import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/workout_repository.dart';
import 'parts_state.dart';

class PartsCubit extends Cubit<PartsState> {
  final WorkoutRepository _repository;
  bool _isFetching = false;

  PartsCubit(this._repository) : super(PartsInitial());

  Future<void> fetchParts(int levelId, {bool forceRefresh = false}) async {
    if (_isFetching) return;
    if (!forceRefresh && state is PartsSuccess) return;

    _isFetching = true;
    emit(PartsLoading());

    final result = await _repository.getSubCategories(levelId);
    _isFetching = false;
    if (isClosed) return;

    switch (result) {
      case Success():
        emit(PartsSuccess(result.data));
      case Failure():
        emit(PartsFailure(result.message));
    }
  }

  void reset() => emit(PartsInitial());
}