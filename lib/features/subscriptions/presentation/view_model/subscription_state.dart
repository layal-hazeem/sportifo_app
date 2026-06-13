part of 'subscription_cubit.dart';

@immutable
sealed class SubscriptionState {}

// الحالة الابتدائية
final class SubscriptionInitial extends SubscriptionState {}

// حالة تحميل البيانات
final class SubscriptionLoading extends SubscriptionState {}

// حالة نجاح جلب البيانات وتمرير القائمة للـ UI
final class SubscriptionSuccess extends SubscriptionState {
  final List<UsersSubscribedModel> usersWithSubscriptions;

  SubscriptionSuccess({required this.usersWithSubscriptions});
}

// حالة حدوث خطأ وتمرير رسالة الخطأ
final class SubscriptionError extends SubscriptionState {
  final String errorMessage;

  SubscriptionError({required this.errorMessage});
}