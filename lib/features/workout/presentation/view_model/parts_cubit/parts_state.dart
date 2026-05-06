import '../../../data/models/filter_item_model.dart';

sealed class PartsState {}

final class PartsInitial extends PartsState {}

final class PartsLoading extends PartsState {}

final class PartsSuccess extends PartsState {
  final List<FilterItemModel> Parts;
  PartsSuccess(this.Parts);
}

final class PartsFailure extends PartsState {
  final String errorMessage;
  PartsFailure(this.errorMessage);
}