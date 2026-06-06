import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/coaches/data/repositories/coach_repository.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/coach_model.dart';
import 'all_coaches_state.dart';

class AllCoachesCubit extends Cubit<AllCoachesState> {
  final CoachRepository _coachRepository;

  AllCoachesCubit(this._coachRepository) : super(AllCoachesInitial());

  Future<void> fetchAllCoaches({
    String? search,
    int? gender,
    int? minExp,
    int? maxExp,
    bool reset = true,
  }) async {
    if (reset) emit(AllCoachesLoading());

    final result = await _coachRepository.getCoaches(
      search: search,
      gender: gender,
      minExp: minExp,
      maxExp: maxExp,
    );

    if (result is Success<List<CoachModel>>) {
      emit(AllCoachesLoaded(result.data));
    }else if (result is Failure<List<CoachModel>>) {
      emit(AllCoachesError(result.message));
    }
  }
}