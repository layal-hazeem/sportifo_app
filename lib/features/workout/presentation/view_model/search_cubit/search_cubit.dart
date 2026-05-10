import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/workout_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final WorkoutRepository _repository;

  SearchCubit(this._repository) : super(SearchInitial());

  Future<void> searchExercises(String query) async {
    // إذا الحقل فاضي، بنرجع للحالة الافتراضية
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    // 🔥 بنبعت الكلمة للسيرفر (تأكدي أنك أضفتي name لمكتبة الـ Repository كما اتفقنا)
    final result = await _repository.getExercises(searchQuery: query);

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