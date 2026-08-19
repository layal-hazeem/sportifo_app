import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/core/network/dio_factory.dart';
import 'package:sportifo_app/core/storage/local_storage.dart';
import 'package:sportifo_app/features/ai_chat/data/repository/ai_chat_repository.dart';
import 'package:sportifo_app/features/ai_chat/presentation/view_model/ai_chat_cubit.dart';
import 'package:sportifo_app/features/auth/data/repository/auth_repository.dart';
import 'package:sportifo_app/features/nutrition/data/repository/nutrition_repository.dart';
import 'package:sportifo_app/features/nutrition/presentation/view_model/nutrition_cubit.dart';

part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final AuthRepository _authRepository;

  LogoutCubit(this._authRepository) : super(LogoutInitial());

  Future<void> logout() async {
    emit(LogoutLoading());

    try {
      final localStorage = GetIt.instance<LocalStorage>();
      final userId = localStorage.getUserId();

      final result = await _authRepository.logout();

      // ✅ مسح محادثات الشات (AI Chat)
      try {
        await GetIt.instance<AiChatRepository>().clearAllChats();
      } catch (_) {}

      // ✅ إعادة تعيين AiChatCubit (مسح الذاكرة المؤقتة)
      if (GetIt.instance.isRegistered<AiChatCubit>()) {
        GetIt.instance<AiChatCubit>().reset();
      }

      // ✅ مسح بيانات التغذية (Nutrition)
      try {
        final nutritionRepo = GetIt.instance<NutritionRepository>();
        // مسح خريطة الرسائل-الوجبات
        await nutritionRepo.clearAllMappings();
        // مسح كاش الـ Food Logs الخاص بالمستخدم (اختياري، ولكن يُنصح به)
        await nutritionRepo.clearFoodLogs();
      } catch (_) {}

      // ✅ إعادة تعيين NutritionCubit (مسح الذاكرة المؤقتة وإعادة _isInitialized = false)
      if (GetIt.instance.isRegistered<NutritionCubit>()) {
        GetIt.instance<NutritionCubit>().reset();
      }

      // ✅ مسح جلسة المستخدم من LocalStorage
      await localStorage.clearUserSession();

      // ✅ مسح الكاش الخاص بـ Dio (إن وجد)
      if (userId != null) {
        await GetIt.instance<DioFactory>().clearUserCache(userId);
      }

      // ✅ معالجة نتيجة تسجيل الخروج من الـ API
      switch (result) {
        case Success():
          emit(LogoutSuccess());
        case Failure(message: final msg):
          emit(LogoutError(msg));
      }
    } catch (e) {
      emit(LogoutError('خطأ: ${e.toString()}'));
    }
  }
}