import 'package:sportifo_app/features/subscriptions/data/web_services/subscriptions_web_service.dart';

import '../models/users_subscribed_model.dart';

class SubscriptionRepository {
  final SubscriptionWebService _webServices;

  SubscriptionRepository(this._webServices);

  Future<List<UsersSubscribedModel>> fetchSubscriptions() async {
    try {
      // 1. جلب الـ response الخام من الـ Web Service
      final responseMap = await _webServices.getSubscriptions();
      
      // 2. الوصول إلى قائمة الـ "data" داخل الـ JSON
      final List<dynamic> dataList = responseMap['data'] as List<dynamic>;
      
      // 3. تحويل كل عنصر في القائمة إلى موديل UsersSubscribedModel
      final List<UsersSubscribedModel> usersWithSubscriptions = dataList
          .map((userJson) => UsersSubscribedModel.fromJson(userJson as Map<String, dynamic>))
          .toList();
          
      return usersWithSubscriptions;
    } catch (error) {
      // يمكنك هنا تخصيخ رسالة الخطأ بناءً على نوع الـ DioException إذا أردت
      throw Exception('Failed to load subscriptions: ${error.toString()}');
    }
  }
}