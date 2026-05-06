import 'package:bloc/bloc.dart';

import '../../../../../core/network/api_result.dart';
import '../../../data/models/login/forgot_password_request_body.dart';
import '../../../data/models/login/login_response.dart';
import '../../../data/repository/auth_repository.dart';
import 'login_state.dart';

class ForgotPasswordCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;
  ForgotPasswordCubit(this._authRepository) : super(LoginInitial());

  void emitForgotPasswordStates(String email) async {
    emit(LoginLoading());

    final result = await _authRepository.forgotPassword(
      ForgotPasswordRequestBody(login: email),
    );

    if (result is Success<LoginResponse>) {
      emit(LoginSuccess(result.data));
    } else if (result is Failure<LoginResponse>) {
      emit(LoginError(result.message));
    }
  }
}