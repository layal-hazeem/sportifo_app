import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_result.dart';
import '../../data/repository/ads_repository.dart';
import 'ads_state.dart';

class AdsCubit extends Cubit<AdsState> {
  final AdsRepository _repository;

  AdsCubit(this._repository) : super(AdsInitial());

  Future<void> fetchAds() async {
    emit(AdsLoading());

    final result = await _repository.getAds();

    switch (result) {
      case Success():
        emit(AdsSuccess(result.data));
        break;
      case Failure():
        emit(AdsFailure(result.message));
        break;
    }
  }
}