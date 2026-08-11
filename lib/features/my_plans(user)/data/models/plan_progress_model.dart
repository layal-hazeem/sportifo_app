class PlanProgressModel {
  final int currentWeek;
  final List<ProgressDayModel> days;

  PlanProgressModel({required this.currentWeek, required this.days});

  factory PlanProgressModel.fromJson(Map<String, dynamic> json) {
    return PlanProgressModel(
      currentWeek: json['current_week'] ?? 1,
      days: (json['days'] as List?)?.map((e) => ProgressDayModel.fromJson(e)).toList() ?? [],
    );
  }
}

class ProgressDayModel {
  final int id;
  final int planDayId;
  final String name;
  final bool completed;

  ProgressDayModel({
    required this.id,
    required this.planDayId,
    required this.name,
    required this.completed,
  });

  factory ProgressDayModel.fromJson(Map<String, dynamic> json) {
    return ProgressDayModel(
      id: json['id'] ?? 0,
      planDayId: json['plan_day_id'] ?? 0,
      name: json['name'] ?? '',
      completed: json['completed'] ?? false,
    );
  }
}