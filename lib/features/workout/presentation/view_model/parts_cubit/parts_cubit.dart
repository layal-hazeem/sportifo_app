import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/workout/presentation/view_model/parts_cubit/parts_state.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/workout_repository.dart';

class PartsCubit extends Cubit<PartsState> {
  final WorkoutRepository _repository;

  PartsCubit(this._repository) : super(PartsInitial());

  // نمرر 2 لجلب العضلات، أو 3 لجلب الأجزاء الدقيقة
  Future<void> fetchParts(int levelId) async {
    emit(PartsLoading());

    final result = await _repository.getSubCategories(levelId);
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(PartsSuccess(result.data));
        break;
      case Failure():
        emit(PartsFailure(result.message));
        break;
    }
  }

  void reset() {
    emit(PartsInitial());
  }
}