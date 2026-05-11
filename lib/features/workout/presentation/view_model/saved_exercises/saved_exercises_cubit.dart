import 'package:bloc/bloc.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/repository/workout_repository.dart';
import '../../../../../core/network/api_result.dart';
import 'saved_exercises_state.dart'; // تأكدي من عمل import لملف الـ state

class SavedExercisesCubit extends Cubit<SavedExercisesState> {
  final WorkoutRepository _repository;

  // القائمة المحلية للمزامنة الفورية
  List<ExerciseModel> savedList = [];

  SavedExercisesCubit(this._repository) : super(SavedExercisesInitial());

  // 1. جلب المحفوظات
  Future<void> fetchSavedExercises() async {
    emit(SavedExercisesLoading());
    final result = await _repository.getSavedExercises();

    if (result is Success<List<ExerciseModel>>) {
      savedList = result.data;
      // 🔥 تأكدي أن كل التمارين القادمة من السيرفر تعتبر "محفوظة"
      for (var element in savedList) {
        element.isSaved = true;
      }
      emit(SavedExercisesSuccess(List.from(savedList)));
    } else if (result is Failure) {
      emit(SavedExercisesError((result as Failure).message));
    }
  }

  // 2. التبديل بين الحفظ والإزالة (Optimistic Update)
  Future<void> toggleSave(ExerciseModel exercise) async {
    // 1. تحديث الحالة فوراً في الذاكرة (Optimistic Update)
    exercise.isSaved = !exercise.isSaved;

    if (exercise.isSaved) {
      if (!savedList.any((e) => e.id == exercise.id)) {
        savedList.add(exercise);
      }
    } else {
      savedList.removeWhere((e) => e.id == exercise.id);
    }

    // 2. تحديث الواجهة (الأيقونات)
    emit(SavedExercisesSuccess(List.from(savedList)));

    // 🔥 السطر السحري: إطلاق حالة التبديل لكي يظهر السناك بار فوراً
    emit(SavedExercisesToggleSuccess(exercise.id, exercise.isSaved));

    // 3. الطلب للسيرفر
    final result = await _repository.toggleSaveExercise(exercise.id);

    if (result is Failure) {
      // إذا فشل الطلب، نرجع الحالة كما كانت (Rollback)
      exercise.isSaved = !exercise.isSaved;
      if (exercise.isSaved) {
        savedList.add(exercise);
      } else {
        savedList.removeWhere((e) => e.id == exercise.id);
      }
      // تحديث الواجهة بعد الفشل
      emit(SavedExercisesSuccess(List.from(savedList)));
      // إبلاغ الـ Listener بالفشل إذا أردتِ إظهار سناك بار أحمر
      emit(SavedExercisesError((result as Failure).message));
    }
  }
}