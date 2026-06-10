import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/coaches/data/repositories/coach_repository.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/coach_model.dart';
import 'coaches_state.dart';

class CoachesCubit extends Cubit<CoachesState> {
  final CoachRepository _coachRepository;
  CoachesCubit(this._coachRepository) : super(CoachesInitial());
  Future<void> fetchCoaches({
    String? search,
    int? gender,
    int? minExp,
    int? maxExp,
  }) async {
    emit(CoachesLoading());
    final result = await _coachRepository.getCoaches(
      search: search,
      gender: gender,
      minExp: minExp,
      maxExp: maxExp,
    );
    if (result is Success<List<CoachModel>>) {
      emit(CoachesLoaded(result.data.take(10).toList()));
    } else if (result is Failure<List<CoachModel>>) {
      emit(CoachesError(result.message));
    }
  }
}