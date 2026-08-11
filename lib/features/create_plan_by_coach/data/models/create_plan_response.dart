import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';

class CreatePlanResponse {
  final String message;
  final PlanData data;

  CreatePlanResponse({required this.message, required this.data});

  factory CreatePlanResponse.fromJson(Map<String, dynamic> json) {
    return CreatePlanResponse(
      message: json['message'] ?? '',

      data: json['data'] != null
          ? PlanData.fromJson(json['data'])
          : PlanData(id: 0, status: '', days: []),
    );
  }
}

class PlanData {
  final int id;
  final String status;
  final List<PlanDayModel> days;

  PlanData({required this.id, required this.status, required this.days});

  factory PlanData.fromJson(Map<String, dynamic> json) {
    return PlanData(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      days: json['days'] != null
          ? List<PlanDayModel>.from(
              json['days'].map((e) => PlanDayModel.fromJson(e)),
            )
          : [],
    );
  }
}

class PlanDayModel {
  final int id;
  final String name;

  final int? sets;
  final String? reps;
  
  final List<ExerciseModel> exercises;

  PlanDayModel({required this.id, required this.name, required this.exercises,this.sets,
    this.reps,});

  factory PlanDayModel.fromJson(Map<String, dynamic> json) {
  return PlanDayModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',

    sets: json['sets'],
    reps: json['reps']?.toString(),

    exercises: json['exercises'] != null
        ? List<ExerciseModel>.from(
            json['exercises'].map(
              (e) => ExerciseModel.fromJson(e),
            ),
          )
        : [],
  );
}
}
