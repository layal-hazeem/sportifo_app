import '../../../data/models/filter_item_model.dart';

sealed class CategoriesState {}

final class CategoriesInitial extends CategoriesState {}

final class CategoriesLoading extends CategoriesState {}

final class CategoriesSuccess extends CategoriesState {
  final List<FilterItemModel> categories;
  CategoriesSuccess(this.categories);
}

final class CategoriesFailure extends CategoriesState {
  final String errorMessage;
  CategoriesFailure(this.errorMessage);
}