import '../../../data/models/exercise_model.dart';

sealed class SavedExercisesState {}

// الحالة الابتدائية
final class SavedExercisesInitial extends SavedExercisesState {}

// حالة التحميل (Loading)
final class SavedExercisesLoading extends SavedExercisesState {}

// حالة نجاح جلب القائمة (لشاشة المحفوظات)
final class SavedExercisesSuccess extends SavedExercisesState {
  final List<ExerciseModel> savedExercises;
  SavedExercisesSuccess(this.savedExercises);
}

// حالة الفشل (Error)
final class SavedExercisesError extends SavedExercisesState {
  final String message;
  SavedExercisesError(this.message);
}

// --- حالات خاصة بعملية الحفظ/الإلغاء (Toggle) ---

// حالة يتم إطلاقها عند الضغط على الزر (لتغيير الشكل فوراً أو إظهار مؤشر بسيط)
final class SavedExercisesToggleLoading extends SavedExercisesState {
  final int exerciseId; // نمرر الـ ID لنعرف أي تمرين يتم معالجته حالياً
  SavedExercisesToggleLoading(this.exerciseId);
}

// حالة نجاح عملية الحفظ أو الإلغاء
final class SavedExercisesToggleSuccess extends SavedExercisesState {
  final int exerciseId;
  final bool isSaved;
  SavedExercisesToggleSuccess(this.exerciseId, this.isSaved);
}