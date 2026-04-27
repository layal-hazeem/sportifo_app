import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/models/register/register_request_model.dart';
import '../../../data/repository/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {

  final AuthRepository _authRepository;

  // حقن الـ Repository داخل الـ Constructor عند استدعاء الكيوبت
  RegisterCubit(this._authRepository) : super(const RegisterInitial());

  // الدالة التي سيتم استدعاؤها عند الضغط على زر التسجيل في الواجهة
  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String otpMethod,
    File? profilePic, // اختياري لأن المستخدم قد لا يرفع صورة
  }) async {
    // 1. إخبار الواجهة أننا بدأنا التحميل (لإظهار دائرة تحميل CircularProgressIndicator)
    emit(const RegisterLoading());


      // 2. تجميع البيانات القادمة من الواجهة داخل الـ Request Model
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

      // 🔥 سحر الـ Pattern Matching في Dart (للتعامل مع الـ sealed class)
      switch (result) {
        case Success():
        // إذا كان الرد Success، نطلق حالة النجاح
          emit(const RegisterSuccess());
          break;

        case Failure():
        // إذا كان الرد Failure، نأخذ الرسالة الجاهزة والمترجمة التي جهزها لنا الـ ApiErrorHandler
          emit(RegisterFailure(errorMessage: result.message));
          break;
      }
    }
  }
