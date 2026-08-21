import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/coaches/data/repositories/coach_repository.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/coach_details_model.dart';
import 'coach_details_state.dart';

class CoachDetailsCubit extends Cubit<CoachDetailsState> {
  final CoachRepository _coachRepository;

  // ✅✅✅ هون عدلنا: كاش داخلي لحفظ تفاصيل الكوتش
  // لو رجعت للشاشة وانقطع النت، بيضل يعرض البيانات القديمة
  CoachDetailsModel? _cachedDetails;

  CoachDetailsCubit(this._coachRepository) : super(CoachDetailsInitial());

  Future<void> fetchCoachDetails(int coachId) async {
    emit(CoachDetailsLoading());
    final result = await _coachRepository.getCoachDetails(coachId);
    if (result is Success<CoachDetailsModel>) {
      // ✅ خزن النتيجة بالكاش
      _cachedDetails = result.data;
      emit(CoachDetailsLoaded(result.data));
    } else if (result is Failure<CoachDetailsModel>) {
      // ✅ إذا في كاش قديم، ارجعه بدل Error
      if (_cachedDetails != null) {
        emit(CoachDetailsLoaded(_cachedDetails!));
      } else {
        // ✅ ما في كاش → Error حقيقي
        emit(CoachDetailsError(result.message));
      }
    }
  }
}