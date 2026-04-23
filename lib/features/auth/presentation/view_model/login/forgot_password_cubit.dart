import 'package:bloc/bloc.dart';

import '../../../data/models/login/forgot_password_request_body.dart';
import '../../../data/repository/auth_repository.dart';
import 'login_state.dart';

class ForgotPasswordCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;
  ForgotPasswordCubit(this._authRepository) : super(LoginInitial());

  void emitForgotPasswordStates(String email) async {
    emit(LoginLoading());
    try {
      final response = await _authRepository.forgotPassword(ForgotPasswordRequestBody(login: email));
      emit(LoginSuccess(response));
    } catch (error) {
      emit(LoginError(error.toString()));
    }
  }
}