import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/core/storage/local_storage.dart';
import 'package:sportifo_app/features/auth/data/repository/auth_repository.dart';

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
        emit(LogoutSuccess());
        break;

      case Failure(message: final msg):
        emit(LogoutError(msg));
        break;
    }
  }
}
