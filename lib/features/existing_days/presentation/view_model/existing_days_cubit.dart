import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sportifo_app/features/existing_days/data/model/existing_days_model.dart';
import 'package:sportifo_app/features/existing_days/data/repository/existing_days_repository.dart';

part 'existing_days_state.dart';

class ExistingDaysCubit extends Cubit<ExistingDaysState> {
  final ExistingDaysRepository _existingDaysRepository;

  ExistingDaysCubit(this._existingDaysRepository)
    : super(ExistingDaysInitial());

  Future<void> getExistingDays() async {
    emit(ExistingDaysLoading());

    try {
      final result = await _existingDaysRepository.fetchExistingDays();

      emit(ExistingDaysSuccess(days: result));
    } catch (error) {
      emit(ExistingDaysError(errorMessage: error.toString()));
    }
  }
}
