// 🔥 موديلات سجل الأنشطة (exercise-logs/activity) - المصدر الحقيقي والدائم
// لكل تمرين اتسجل، بتاريخه ووقته الفعليين. هاد مصدر الحقيقة بدل الذاكرة
// المحلية المؤقتة يلي بتنمسح لما يخلص الـ workout.

class ActivitySetModel {
  final int setNumber;
  final int reps;
  final String weight;

  ActivitySetModel({required this.setNumber, required this.reps, required this.weight});

  factory ActivitySetModel.fromJson(Map<String, dynamic> json) {
    return ActivitySetModel(
      setNumber: json['set_number'] ?? 0,
      reps: json['reps'] ?? 0,
      weight: json['weight']?.toString() ?? '0',
    );
  }
}

class ActivityLogEntry {
  final int id;
  final int planId;
  final String type; // resistance / cardio...
  final String date; // yyyy-MM-dd
  final String time;
  final int exerciseId;
  final String exerciseName;
  final List<ActivitySetModel> sets;

  ActivityLogEntry({
    required this.id,
    required this.planId,
    required this.type,
    required this.date,
    required this.time,
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    final exercise = json['exercise'] as Map<String, dynamic>? ?? {};
    return ActivityLogEntry(
      id: json['id'] ?? 0,
      planId: json['plan_id'] ?? 0,
      type: json['type'] ?? 'resistance',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      exerciseId: exercise['id'] ?? 0,
      exerciseName: exercise['name'] ?? '',
      sets: json['sets'] != null
          ? List<ActivitySetModel>.from((json['sets'] as List).map((s) => ActivitySetModel.fromJson(s)))
          : [],
    );
  }
}

class ActivityDayGroup {
  final String date; // yyyy-MM-dd
  final String dateLabel;
  final int totalExercises;
  final List<ActivityLogEntry> logs;

  ActivityDayGroup({required this.date, required this.dateLabel, required this.totalExercises, required this.logs});

  factory ActivityDayGroup.fromJson(Map<String, dynamic> json) {
    return ActivityDayGroup(
      date: json['date'] ?? '',
      dateLabel: json['date_label'] ?? '',
      totalExercises: json['total_exercises'] ?? 0,
      logs: json['logs'] != null
          ? List<ActivityLogEntry>.from((json['logs'] as List).map((l) => ActivityLogEntry.fromJson(l)))
          : [],
    );
  }
}