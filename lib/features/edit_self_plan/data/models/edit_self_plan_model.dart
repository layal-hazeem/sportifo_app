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
      data: SelfPlanData.fromJson(
        json['data'] ?? {},
      ),
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
                (e) => EditSelfPlanDay.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          [],
    );
  }
}

class EditSelfPlanDay {
  final int? id;
  final String name;

  // Sets و reps على مستوى اليوم
  final int? sets;
  final String? reps;

  // حذف اليوم
  final bool? delete;

  final List<EditSelfPlanExercise> exercises;

  EditSelfPlanDay({
    this.id,
    required this.name,
    this.sets,
    this.reps,
    this.delete,
    required this.exercises,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory EditSelfPlanDay.fromJson(Map<String, dynamic> json) {
    return EditSelfPlanDay(
      id: json['id'],
      name: json['name'] ?? '',
      sets: json['sets'],
      reps: json['reps']?.toString(),
      delete: json['_delete'] == true || json['_delete'] == 1,

      exercises: (json['exercises'] as List?)
              ?.map(
                (e) => EditSelfPlanExercise.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          [],
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };

    // اليوم الموجود مسبقًا
    if (id != null) {
      json['id'] = id;
    }

    // Sets الخاصة باليوم
    if (sets != null) {
      json['sets'] = sets;
    }

    // Reps الخاصة باليوم
    if (reps != null) {
      json['reps'] = reps;
    }

    // حذف اليوم
    if (delete != null) {
      json['_delete'] = delete;
    }

    return json;
  }
}

class EditSelfPlanExercise {
  final int exerciseId;
  final int? sets;
  final String? reps;
  final int order;

  // حذف التمرين
  final bool? delete;

  EditSelfPlanExercise({
    required this.exerciseId,
    this.sets,
    this.reps,
    required this.order,
    this.delete,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory EditSelfPlanExercise.fromJson(Map<String, dynamic> json) {
    return EditSelfPlanExercise(
      exerciseId: json['exercise_id'] ?? json['id'] ?? 0,
      sets: json['sets'],
      reps: json['reps']?.toString(),
      order: json['order'] ?? 0,
      delete: json['_delete'] == true || json['_delete'] == 1,
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'exercise_id': exerciseId,
      'order': order,
    };

    if (sets != null) {
      json['sets'] = sets;
    }

    if (reps != null) {
      json['reps'] = reps;
    }

    if (delete != null) {
      json['_delete'] = delete;
    }

    return json;
  }
}