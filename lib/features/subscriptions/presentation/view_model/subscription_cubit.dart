import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../data/models/users_subscribed_model.dart';
import '../../data/repository/subscription_repository.dart';

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionCubit(this._subscriptionRepository)
    : super(SubscriptionInitial());

  Future<void> getSubscriptions() async {
    emit(SubscriptionLoading());

    try {
      final result = await _subscriptionRepository.fetchSubscriptions();

      emit(SubscriptionSuccess(usersWithSubscriptions: result));
    } catch (error) {
      print("🚨 Error occurred: $error");
      emit(SubscriptionError(errorMessage: error.toString()));
    }
  }
}
