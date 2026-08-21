import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repositories/trainee_subscription_repository.dart';
import 'my_subscriptions_state.dart';

class MySubscriptionsCubit extends Cubit<MySubscriptionsState> {
  final TraineeSubscriptionRepository _repository; // 👈 استخدمنا الريبوزتوري تبعك

  MySubscriptionsCubit(this._repository) : super(MySubscriptionsInitial());

  // 🔥 أضفنا bool isRefresh = false
  Future<void> fetchMySubscriptions({bool isRefresh = false}) async {
    // إذا لم يكن ريفريش، نظهر دائرة التحميل العادية
    if (!isRefresh) {
      emit(MySubscriptionsLoading());
    }

    // 👈 تمرير isRefresh للـ Repository
    final result = await _repository.getMySubscriptionsRecords(forceRefresh: isRefresh);

    if (result is Success) {
      emit(MySubscriptionsSuccess((result as Success).data));
    } else if (result is Failure) {
      emit(MySubscriptionsError((result as Failure).message));
    }
  }
}