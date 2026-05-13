import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/workout_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final WorkoutRepository _repository;

  SearchCubit(this._repository) : super(SearchInitial());

// 🔥 أضفنا categoryId اختياري
  Future<void> searchExercises(String query, {int? categoryId, int? organId, List<int>? partIds}) async {    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    // 🔥 بنمرر الـ categoryId للريبوزيتوري
  final result = await _repository.getExercises(
    searchQuery: query,
    categoryId: categoryId,
    organId: organId,
    partIds: partIds,
  );
    switch (result) {
      case Success():
        if (result.data.isEmpty) {
          emit(SearchFailure("No exercises found for '$query'"));
        } else {
          emit(SearchSuccess(result.data));
        }
        break;
      case Failure():
        emit(SearchFailure(result.message));
        break;
    }
  }
}