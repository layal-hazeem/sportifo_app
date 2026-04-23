import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/register/register_request_model.dart';
import '../../../data/repository/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  // تعريف الـ Repository كمتغير لا يمكن تغييره
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
      // 5. في حال حدوث أي خطأ (مثل إيميل مستخدم سابقاً، أو انقطاع النت)
      // نلتقط الخطأ ونرسله للواجهة كرسالة نصية لتعرضه للمستخدم في SnackBar
      emit(RegisterFailure(errorMessage: e.toString()));
    }
  }
}
