import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    try {
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

      // 3. إرسال الطلب للسيرفر عبر الـ Repository
      // الكيوبت هنا لا يهتم كيف سيتم الإرسال (JSON أم FormData)، الـ Repository يتكفل بذلك
      await _authRepository.register(request);

      // 4. إذا مر الكود من السطر السابق بدون أخطاء، فهذا يعني أن التسجيل نجح!
      // نخبر الواجهة بالنجاح (مثلاً للانتقال لشاشة الـ OTP)
      emit(const RegisterSuccess());
    } catch (e) {
      String errorMessage = "Something went wrong. Please try again."; // رسالة افتراضية

      // 🔥 سحب رسالة الخطأ القادمة من الباك إند (Laravel)
      if (e is DioException && e.response != null) {
        if (e.response?.data is Map) {
          // جلب رسالة الخطأ من السيرفر وعرضها للمستخدم
          errorMessage =
              e.response?.data['message']?.toString() ?? errorMessage;
        }
      }

      emit(RegisterFailure(errorMessage: errorMessage));
    }
  }
}
