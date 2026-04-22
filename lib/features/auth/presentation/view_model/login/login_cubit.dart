import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/login/login_request.dart';
import '../../../data/repository/AuthRepository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  // نمرر الـ Repository عبر الـ Constructor (Dependency Injection)
  LoginCubit(this._authRepository) : super(LoginInitial());

  // الدالة التي ستستدعيها الواجهة عند الضغط على زر Login
  void emitLoginStates(LoginRequestBody loginRequestBody) async {
    // أول خطوة: أخبر الواجهة أنني بدأت التحميل
    emit(LoginLoading());

    // استدعاء الـ Repository لإتمام عملية الدخول
    final response = await _authRepository.login(loginRequestBody);

    // التحقق من النتيجة (هنا سنستخدم معالجة الأخطاء لاحقاً)
    try {
      // إذا نجحنا نرسل Success ومعها بيانات الرد (Token مثلاً)
      emit(LoginSuccess(response));
    } catch (error) {
      // إذا فشلنا نرسل Error مع الرسالة
      emit(LoginError(error: error.toString()));
    }
  }
}