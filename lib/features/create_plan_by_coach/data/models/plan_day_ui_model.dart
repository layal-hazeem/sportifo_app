import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';

class PlanDayUiModel {
  String name;
    int? defaultSets;
  int? defaultReps;
  List<ExerciseModel> exercises;

  PlanDayUiModel({
    required this.name,
    required this.exercises,
    this.defaultSets,
    this.defaultReps,
  });
}