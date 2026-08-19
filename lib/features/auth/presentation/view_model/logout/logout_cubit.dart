import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/core/network/dio_factory.dart';
import 'package:sportifo_app/core/storage/local_storage.dart';
import 'package:sportifo_app/features/auth/data/repository/auth_repository.dart';
import 'package:sportifo_app/features/nutrition/presentation/view_model/nutrition_cubit.dart';
import '../../../../targets/presentation/view_model/target_cubit/target_cubit.dart';
// 🔥 استيراد الـ AiChatCubit
import 'package:sportifo_app/features/ai_chat/presentation/view_model/ai_chat_cubit.dart';

part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final AuthRepository _authRepository;

  LogoutCubit(this._authRepository) : super(LogoutInitial());

  Future<void> logout() async {
    emit(LogoutLoading());

    final result = await _authRepository.logout();

    switch (result) {
      case Success():
        await GetIt.instance<LocalStorage>().clearToken();
        await GetIt.instance<LocalStorage>().clearRole();
        await DioFactory.clearCache(); // بيمسح كاش النتوورك (Dio)
// ✅ تصفير الكيوبيتات اللي بتضل محتفظة بالداتا تبع اليوزر
        await GetIt.instance<NutritionCubit>().reset();
        GetIt.instance<TargetCubit>().reset();
        await GetIt.instance<AiChatCubit>().reset(); // 🔥 سطر واحد فقط ومسبوق بـ await

        emit(LogoutSuccess());
        break;

      case Failure(message: final msg):
        emit(LogoutError(msg));
        break;
    }
  }
}