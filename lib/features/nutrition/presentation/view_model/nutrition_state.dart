import '../../data/models/food_log_model.dart';

sealed class NutritionState {}

final class NutritionInitial extends NutritionState {}

final class NutritionLoading extends NutritionState {}

final class NutritionSuccess extends NutritionState {
  final TodayFoodLogsResponse foodLogs;
  final bool isMealLogged;

  NutritionSuccess({required this.foodLogs, this.isMealLogged = false});
}

final class NutritionError extends NutritionState {
  final String message;
  NutritionError(this.message);
}

final class AddMealLoading extends NutritionState {
  final int? messageId;
  AddMealLoading([this.messageId]);
}

final class AddMealSuccess extends NutritionState {
  final int? messageId;
  final AddMealResponse mealResponse;
  AddMealSuccess({this.messageId, required this.mealResponse});
}

final class AddMealError extends NutritionState {
  final int? messageId;
  final String message;
  AddMealError({this.messageId, required this.message});
}

final class DeleteMealLoading extends NutritionState {
  final int mealId;
  DeleteMealLoading(this.mealId);
}

final class DeleteMealSuccess extends NutritionState {
  final int mealId;
  final AddMealResponse mealResponse;
  DeleteMealSuccess({required this.mealId, required this.mealResponse});
}

final class DeleteMealError extends NutritionState {
  final int mealId;
  final String message;
  DeleteMealError({required this.mealId, required this.message});
}
