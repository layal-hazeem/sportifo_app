import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../data/repository/weight_progress_repository.dart';
import '../../data/models/weight_progress_model.dart';
import 'weight_progress_state.dart';

class WeightProgressCubit extends Cubit<WeightProgressState> {
  final WeightProgressRepository _repository;

  // ✅✅✅ هون عدلنا: كاش داخلي لحفظ آخر بيانات ناجحة
  // بيمنع عرض NoInternetView لو في بيانات قديمة مخزنة
  WeightProgressData? _cachedData;

  WeightProgressCubit(this._repository) : super(WeightProgressInitial());

  Future<void> fetchWeightProgress({bool forceRefresh = false}) async {
    emit(WeightProgressLoading());
    final result = await _repository.getWeightProgress(
      forceRefresh: forceRefresh,
    );

    if (isClosed) return;

    if (result is Success<WeightProgressData>) {
      _cachedData = result.data; // ✅ خزن الكاش
      emit(WeightProgressSuccess(result.data));
    } else if (result is Failure) {
      // ✅ إذا في كاش قديم، ارجع البيانات القديمة بدل Error
      if (_cachedData != null) {
        emit(WeightProgressSuccess(_cachedData!));
      } else {
        emit(WeightProgressError((result as Failure).message));
      }
    }
  }
}