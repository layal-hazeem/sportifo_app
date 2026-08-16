import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sportifo_app/features/coaches/data/models/coach_model.dart';
import 'package:sportifo_app/features/home/data/repository/coach_home_repository.dart';
import 'package:sportifo_app/features/home/presentation/view_model/coach_home_state.dart';
import 'package:sportifo_app/features/subscriptions/data/models/users_subscribed_model.dart';

class CoachHomeCubit extends Cubit<CoachHomeState> {
  final CoachHomeRepository repository;

  CoachHomeCubit(this.repository) : super(CoachHomeLoading());

  Future<void> loadHomeData() async {
    emit(CoachHomeLoading());

    try {
      final results = await Future.wait([
        repository.getCoachInfo(),
        repository.getUnreadNotificationsCount(),
        repository.getMyClients(),
      ]);

      emit(
        CoachHomeLoaded(
          coach: results[0] as CoachModel,
          notificationsCount: results[1] as int,
          clients: results[2] as List<UsersSubscribedModel>,
        ),
      );
    } catch (e) {
      emit(
        CoachHomeError(
          _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> refresh() async {
    await loadHomeData();
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return message;
  }
}