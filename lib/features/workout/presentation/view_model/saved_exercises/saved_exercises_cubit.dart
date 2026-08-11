import 'package:bloc/bloc.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/repository/workout_repository.dart';
import '../../../../../core/network/api_result.dart';
import 'saved_exercises_state.dart';

class SavedExercisesCubit extends Cubit<SavedExercisesState> {
  final WorkoutRepository _repository;

  List<ExerciseModel> savedList = [];
  final Set<int> _savedIds = {};
  bool _isInitialized = false;

  SavedExercisesCubit(this._repository) : super(SavedExercisesInitial());
  Future<void> initialize() async {
    if (_isInitialized) return;
    await fetchSavedExercises(forceRefresh: false);
    _isInitialized = true;
  }

  bool isSaved(int exerciseId) => _savedIds.contains(exerciseId);

  void syncExerciseSaveStatus(List<ExerciseModel> exercises) {
    if (!_isInitialized) return;
    for (final exercise in exercises) {
      exercise.isSaved = _savedIds.contains(exercise.id);
    }
  }

  void _updateSavedIds() {
    _savedIds.clear();
    for (final exercise in savedList) {
      _savedIds.add(exercise.id);
    }
  }

  Future<void> fetchSavedExercises({bool forceRefresh = false}) async {
    if (savedList.isNotEmpty && !forceRefresh && !isClosed) {
      emit(SavedExercisesSuccess(List.from(savedList)));
    }

    emit(SavedExercisesLoading());

    final result = await _repository.getSavedExercises(
      forceRefresh: forceRefresh,
    );

    if (isClosed) return;

    if (result is Success<List<ExerciseModel>>) {
      savedList = result.data;
      for (final exercise in savedList) {
        exercise.isSaved = true;
      }
      _updateSavedIds();
      emit(SavedExercisesSuccess(List.from(savedList)));
    } else if (result is Failure) {
      if (savedList.isNotEmpty) {
        emit(SavedExercisesSuccess(List.from(savedList)));
      } else {
        emit(SavedExercisesError((result as Failure).message));
      }
    }
  }

  Future<void> toggleSave(ExerciseModel exercise) async {
    final bool wasSaved = _savedIds.contains(exercise.id);
    final bool newSavedState = !wasSaved;

    // 1. Optimistic Update
    exercise.isSaved = newSavedState;

    if (newSavedState) {
      if (!savedList.any((e) => e.id == exercise.id)) {
        savedList.add(exercise);
      }
      _savedIds.add(exercise.id);
    } else {
      savedList.removeWhere((e) => e.id == exercise.id);
      _savedIds.remove(exercise.id);
    }

    emit(SavedExercisesSuccess(List.from(savedList)));
    emit(SavedExercisesToggleSuccess(exercise.id, newSavedState));

    final result = await _repository.toggleSaveExercise(exercise.id);

    if (result is Failure) {
      exercise.isSaved = wasSaved;
      if (wasSaved) {
        if (!savedList.any((e) => e.id == exercise.id)) {
          savedList.add(exercise);
        }
        _savedIds.add(exercise.id);
      } else {
        savedList.removeWhere((e) => e.id == exercise.id);
        _savedIds.remove(exercise.id);
      }
      emit(SavedExercisesSuccess(List.from(savedList)));
      emit(SavedExercisesError((result as Failure).message));
    } else {
      await fetchSavedExercises(forceRefresh: true);
    }
  }
}
