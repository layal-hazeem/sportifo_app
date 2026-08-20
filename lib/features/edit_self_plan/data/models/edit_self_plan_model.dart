class SelfPlanResponseModel {
  final String message;
  final SelfPlanData data;

  SelfPlanResponseModel({
    required this.message,
    required this.data,
  });

  factory SelfPlanResponseModel.fromJson(Map<String, dynamic> json) {
    return SelfPlanResponseModel(
      message: json['message'] ?? '',
      data: SelfPlanData.fromJson(json['data']),
    );
  }
}

class SelfPlanData {
  final int id;
  final String goal;
  final int durationMonths;
  final List<EditSelfPlanDay> days;

  SelfPlanData({
    required this.id,
    required this.goal,
    required this.durationMonths,
    required this.days,
  });

  factory SelfPlanData.fromJson(Map<String, dynamic> json) {
    return SelfPlanData(
      id: json['id'] ?? 0,
      goal: json['goal'] ?? '',
      durationMonths: json['duration_months'] ?? 0,
      days: (json['days'] as List?)
              ?.map(
                (e) => EditSelfPlanDay.fromJson(e),
              )
              .toList() ??
          [],
    );
  }
}

class EditSelfPlanDay {
  final int? id;
  final String name;
  final int? sets;
  final String? reps;
  final bool delete;
  final List<EditSelfPlanExercise> exercises;

  EditSelfPlanDay({
    this.id,
    required this.name,
    this.sets,
    this.reps,
    this.delete = false,
    this.exercises = const [],
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) {
      data['id'] = id;
    }

    data['name'] = name;

    if (sets != null) {
      data['sets'] = sets;
    }

    if (reps != null) {
      data['reps'] = reps;
    }

    if (delete) {
      data['_delete'] = true;
    }

    data['exercises'] = exercises
        .map(
          (exercise) => exercise.toJson(),
        )
        .toList();

    return data;
  }

  factory EditSelfPlanDay.fromJson(Map<String, dynamic> json) {
    return EditSelfPlanDay(
      id: json['id'],
      name: json['name'] ?? '',
      sets: json['sets'],
      reps: json['reps'],
      exercises: (json['exercises'] as List?)
              ?.map(
                (e) => EditSelfPlanExercise.fromJson(e),
              )
              .toList() ??
          [],
    );
  }
}

class EditSelfPlanExercise {
  final int? id;
  final int exerciseId;
  final String? name;
  final String? description;
  final int? sets;
  final String? reps;
  final int order;
  final bool delete;

  EditSelfPlanExercise({
    this.id,
    required this.exerciseId,
    this.name,
    this.description,
    this.sets,
    this.reps,
    required this.order,
    this.delete = false,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['exercise_id'] = exerciseId;

    if (sets != null) {
      data['sets'] = sets;
    }

    if (reps != null) {
      data['reps'] = reps;
    }

    data['order'] = order;

    if (delete) {
      data['_delete'] = true;
    }

    return data;
  }

  factory EditSelfPlanExercise.fromJson(Map<String, dynamic> json) {
    return EditSelfPlanExercise(
      id: json['id'],
      exerciseId: json['id'] ?? 0,
      name: json['name'],
      description: json['description'],
      sets: json['sets'],
      reps: json['reps'],
      order: json['order'] ?? 1,
    );
  }
}