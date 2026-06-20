import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';

class PlanDayUiModel {
  String name;
  List<ExerciseModel> exercises;

  PlanDayUiModel({
    required this.name,
    required this.exercises,
  });
}