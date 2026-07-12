import 'package:bloc/bloc.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/repository/workout_repository.dart';
import '../../../../../core/network/api_result.dart';
import 'saved_exercises_state.dart';

class SavedExercisesCubit extends Cubit<SavedExercisesState> {
  final WorkoutRepository _repository;

  /// القائمة المحلية للتمارين المحفوظة
  List<ExerciseModel> savedList = [];
  /// مجموعة IDs للتمارين المحفوظة — للبحث السريع O(1)
  final Set<int> _savedIds = {};
  /// هل تم تهيئة البيانات من السيرفر؟
  bool _isInitialized = false;

  SavedExercisesCubit(this._repository) : super(SavedExercisesInitial());

  /// 🔥 يجب استدعاؤها مرة واحدة عند بدء التطبيق (في main.dart)
  Future<void> initialize() async {
    if (_isInitialized) return;
    await fetchSavedExercises();
    _isInitialized = true;
  }

  /// ✅ يشيك إذا تمرين محفوظ بناءً على ID — O(1)
  bool isSaved(int exerciseId) => _savedIds.contains(exerciseId);

  /// يحدّث حالة `isSaved` لقائمة تمارين جاية من السيرفر
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

  /// 1. جلب المحفوظات من السيرفر (أو من الكاش لو offline)
  Future<void> fetchSavedExercises() async {
    emit(SavedExercisesLoading());
    final result = await _repository.getSavedExercises();

    if (result is Success<List<ExerciseModel>>) {
      savedList = result.data;
      for (final exercise in savedList) {
        exercise.isSaved = true;
      }
      _updateSavedIds();
      emit(SavedExercisesSuccess(List.from(savedList)));
    } else if (result is Failure) {
      emit(SavedExercisesError((result as Failure).message));
    }
  }

  /// 2. التبديل بين الحفظ والإزالة (Optimistic Update)
  Future<void> toggleSave(ExerciseModel exercise) async {
    final bool wasSaved = _savedIds.contains(exercise.id);
    final bool newSavedState = !wasSaved;

    // 1. تحديث الحالة فوراً في الذاكرة (Optimistic)
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

    // 2. تحديث الواجهة (كل الـ ExerciseCards رح تعيد البناء)
    emit(SavedExercisesSuccess(List.from(savedList)));
    emit(SavedExercisesToggleSuccess(exercise.id, newSavedState));

    // 3. الطلب للسيرفر
    final result = await _repository.toggleSaveExercise(exercise.id);

    if (result is Failure) {
      // ❌ Rollback لو فشل
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
    }
    // ✅ لو نجح: ما بنعمل شي — الـ optimistic update صحيح
  }
}