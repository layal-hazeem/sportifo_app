import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/workout_repository.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final WorkoutRepository _repository;

  CategoriesCubit(this._repository) : super(CategoriesInitial());

  Future<void> fetchCategories(int levelId) async {
    emit(CategoriesLoading());

    final result = await _repository.getCategories(levelId);

    switch (result) {
      case Success():
        emit(CategoriesSuccess(result.data));
        break;
      case Failure():
        emit(CategoriesFailure(result.message));
        break;
    }
  }

}