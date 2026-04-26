import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_request_model.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_respons_model.dart';
import 'package:sportifo_app/features/auth/data/repository/auth_repository.dart';

part 'complete_profile_state.dart';

class CompleteProfileCubit extends Cubit<CompleteProfileState> {
  final AuthRepository repository;

  CompleteProfileCubit(this.repository) : super(CompleteProfileInitial());

  Future completeProfile(CompleteProfileRequestModel model) async {
    emit(CompleteProfileLoading());

    try {
      final response = await repository.completeProfile(model);
      emit(CompleteProfileSuccess(response));
    } catch (e) {
      emit(Error(e.toString()));
    }
  }
}