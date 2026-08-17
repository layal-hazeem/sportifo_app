// data/models/plan_model.dart

class PlanResponseModel {
  final String message;
  final PlanData data;

  PlanResponseModel({required this.message, required this.data});

  factory PlanResponseModel.fromJson(Map<String, dynamic> json) {
    return PlanResponseModel(
      message: json['message'] ?? '',
      data: PlanData.fromJson(json['data']),
    );
  }
}

class PlanData {
  final int id;
  final String goal;
  final int durationMonths;
  final List<PlanDay> days;

  PlanData({
    required this.id,
    required this.goal,
    required this.durationMonths,
    required this.days,
  });

  factory PlanData.fromJson(Map<String, dynamic> json) {
    return PlanData(
      id: json['id'],
      goal: json['goal'] ?? '',
      durationMonths: json['duration_months'] ?? 0,
      days: (json['days'] as List?)
              ?.map((e) => PlanDay.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PlanDay {
  final int? id;
  final String name;
  final int? sets;
  final String? reps;
  final bool delete;
  final List<PlanExercise> exercises;

  PlanDay({
    this.id,
    required this.name,
    this.sets,
    this.reps,
    this.delete = false,
    this.exercises = const [],
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['id'] = id;
    data['name'] = name;
    if (sets != null) data['sets'] = sets;
    if (reps != null) data['reps'] = reps;
    data['_delete'] = delete;
    data['exercises'] = exercises.map((e) => e.toJson()).toList();
    return data;
  }

  factory PlanDay.fromJson(Map<String, dynamic> json) {
    return PlanDay(
      id: json['id'],
      name: json['name'] ?? '',
      sets: json['sets'],
      reps: json['reps'],
      exercises: (json['exercises'] as List?)
              ?.map((e) => PlanExercise.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PlanExercise {
  final int? id; // الـ ID الخاص بالتمرين داخل اليوم (في الـ Response)
  final int exerciseId; // الـ ID الأساسي للتمرين (في الـ Request)
  final String? name;
  final int? sets;
  final String? reps;
  final int order;
  final bool delete;

  PlanExercise({
    this.id,
    required this.exerciseId,
    this.name,
    this.sets,
    this.reps,
    required this.order,
    this.delete = false,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['exercise_id'] = exerciseId;
    if (sets != null) data['sets'] = sets;
    if (reps != null) data['reps'] = reps;
    data['order'] = order;
    if (delete) data['_delete'] = true;
    return data;
  }

  factory PlanExercise.fromJson(Map<String, dynamic> json) {
    return PlanExercise(
      id: json['id'],
      exerciseId: json['id'] ?? 0, // افتراضي حسب الـ Response
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      order: json['order'] ?? 1,
    );
  }
}