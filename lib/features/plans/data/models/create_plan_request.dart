class CreatePlanRequest {
  final int userId;
  final List<PlanDayRequest> days;

  CreatePlanRequest({
    required this.userId,
    required this.days,
  });
}

class PlanDayRequest {
  final String name;
  final List<int> exerciseIds;

  PlanDayRequest({
    required this.name,
    required this.exerciseIds,
  });
}

extension CreatePlanRequestMapper on CreatePlanRequest {
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {};

    data['user_id'] = userId;

    for (int i = 0; i < days.length; i++) {
      data['days[$i][name]'] = days[i].name;

      for (int j = 0; j < days[i].exerciseIds.length; j++) {
        data['days[$i][exercises][$j]'] =
            days[i].exerciseIds[j];
      }
    }

    return data;
  }
}