import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../data/models/users_subscribed_model.dart'; 
import '../../data/repository/subscription_repository.dart'; // تأكد من المسار الصحيح

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository _subscriptionRepository;

  // استقبال الـ Repository المحقون من الـ DI
  SubscriptionCubit(this._subscriptionRepository) : super(SubscriptionInitial());

  Future<void> getSubscriptions() async {
    emit(SubscriptionLoading());
    
    try {
      // استدعاء البيانات الحقيقية من الـ Repository
      final result = await _subscriptionRepository.fetchSubscriptions();
      
      // إرسال حالة النجاح وتمرير البيانات للـ UI
      emit(SubscriptionSuccess(usersWithSubscriptions: result));
    } catch (error) {
      // إرسال حالة الخطأ مع الرسالة
      emit(SubscriptionError(errorMessage: error.toString()));
    }
  }
}