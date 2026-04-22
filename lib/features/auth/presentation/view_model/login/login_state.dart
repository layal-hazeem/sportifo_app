abstract class LoginState {}

// 1. الحالة الابتدائية
class LoginInitial extends LoginState {}

// 2. حالة التحميل (وقت يضغط المستخدم Login وننتظر السيرفر)
class LoginLoading extends LoginState {}

// 3. حالة النجاح (البيانات وصلت تمام)
// نستخدم الـ <T> لجعلها مرنة تستقبل أي Model يرجعه الباك إيند
class LoginSuccess<T> extends LoginState {
  final T data;
  LoginSuccess(this.data);
}

// 4. حالة الخطأ (في حال فشل الاتصال أو خطأ بالبيانات)
class LoginError extends LoginState {
  final String error;
  LoginError({required this.error});
}