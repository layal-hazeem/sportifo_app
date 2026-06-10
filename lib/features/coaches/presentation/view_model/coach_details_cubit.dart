import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/coaches/data/repositories/coach_repository.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/coach_details_model.dart';
import 'coach_details_state.dart';

class CoachDetailsCubit extends Cubit<CoachDetailsState> {
  final CoachRepository _coachRepository;
  CoachDetailsCubit(this._coachRepository) : super(CoachDetailsInitial());
  Future<void> fetchCoachDetails(int coachId) async {
    emit(CoachDetailsLoading());
    final result = await _coachRepository.getCoachDetails(coachId);
    if (result is Success<CoachDetailsModel>) {
      emit(CoachDetailsLoaded(result.data));
    } else if (result is Failure<CoachDetailsModel>) {
      emit(CoachDetailsError(result.message));
    }
  }
}