import '../../../workout/data/models/exercise_model.dart';

// موديل لحفظ حالة السيت محلياً أثناء اللعب
class LoggedSetModel {
  final int setIndex;
  final String weight;
  final String reps;
  final bool isSkipped; // لمعرفة إذا تم تخطي السيت أم لعبه

  LoggedSetModel({
    required this.setIndex,
    required this.weight,
    required this.reps,
    this.isSkipped = false,
  });
}

abstract class ActiveWorkoutState {}

class ActiveWorkoutInitial extends ActiveWorkoutState {}

class ActiveWorkoutInProgress extends ActiveWorkoutState {
  final List<ExerciseModel> exercises;
  final int currentIndex;
  final ExerciseModel currentExercise;
  final List<LoggedSetModel> completedSets; // السيتات اللي خلصها المتدرب

  ActiveWorkoutInProgress({
    required this.exercises,
    required this.currentIndex,
    required this.currentExercise,
    this.completedSets = const [],
  });
}

class ActiveWorkoutCompleted extends ActiveWorkoutState {}