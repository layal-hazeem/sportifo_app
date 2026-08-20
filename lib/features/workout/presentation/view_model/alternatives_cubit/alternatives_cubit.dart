import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/workout_repository.dart';
import 'alternatives_state.dart';

class AlternativesCubit extends Cubit<AlternativesState> {
  final WorkoutRepository _repository;

  AlternativesCubit(this._repository) : super(AlternativesInitial());

  Future<void> fetchAlternatives(int exerciseId) async {
    emit(AlternativesLoading());
    final result = await _repository.getAlternativeExercises(exerciseId);

    if (result is Success) {
      emit(AlternativesSuccess((result as Success).data));
    } else if (result is Failure) {
      emit(AlternativesError((result as Failure).message));
    }
  }
}