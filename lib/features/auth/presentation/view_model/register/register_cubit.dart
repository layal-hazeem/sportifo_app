import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../data/models/register/register_request_model.dart';
import '../../../data/repository/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {

  final AuthRepository _authRepository;

  RegisterCubit(this._authRepository) : super(const RegisterInitial());

  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String otpMethod,
    File? profilePic,
  }) async {
    emit(const RegisterLoading());


      final request = RegisterRequestModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        otpMethod: otpMethod,
        profilePic: profilePic,
      );

      final result = await _authRepository.register(request);

      switch (result) {
        case Success():
          await NotificationService().registerDeviceToBackend();
          emit(const RegisterSuccess());
          break;

        case Failure():
          emit(RegisterFailure(errorMessage: result.message));
          break;
      }
    }
  }
