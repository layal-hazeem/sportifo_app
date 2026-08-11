import '../../../my_plans(user)/data/models/my_plan_model.dart';

abstract class PlatformPlansState {}

class PlatformPlansInitial extends PlatformPlansState {}

class PlatformPlansLoading extends PlatformPlansState {}

class PlatformPlansSuccess extends PlatformPlansState {
  final List<PlanModel> plans;
  PlatformPlansSuccess(this.plans);
}

class PlatformPlansError extends PlatformPlansState {
  final String message;
  PlatformPlansError(this.message);
}