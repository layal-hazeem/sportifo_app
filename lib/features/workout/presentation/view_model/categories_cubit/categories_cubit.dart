import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/workout_repository.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final WorkoutRepository _repository;
  bool _isFetching = false;

  CategoriesCubit(this._repository) : super(CategoriesInitial());

  Future<void> fetchCategories(int levelId, {bool forceRefresh = false}) async {
    // 🔥 منع التكرار
    if (_isFetching) return;

    // إذا عندنا data وما بدنا force refresh، لا تعمل شي
    if (!forceRefresh && state is CategoriesSuccess) {
      return;
    }

    _isFetching = true;
    emit(CategoriesLoading());

    final result = await _repository.getCategories(levelId);
    _isFetching = false;

    switch (result) {
      case Success():
        emit(CategoriesSuccess(result.data));
      case Failure():
        emit(CategoriesFailure(result.message));
    }
  }

  void retry(int levelId) => fetchCategories(levelId, forceRefresh: true);
}