import 'package:sportifo_app/features/subscriptions/data/web_services/subscriptions_web_service.dart';

import '../models/users_subscribed_model.dart';

class SubscriptionRepository {
  final SubscriptionWebService _webServices;

  SubscriptionRepository(this._webServices);

  Future<List<UsersSubscribedModel>> fetchSubscriptions({
    bool forceRefresh = false,
  }) async {
    try {
      final responseMap = await _webServices.getSubscriptions(
        forceRefresh: forceRefresh,
      );

      final List<dynamic> dataList =
          responseMap['data'] as List<dynamic>;

      return dataList
          .map(
            (userJson) => UsersSubscribedModel.fromJson(
              userJson as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (error) {
      throw Exception(
        'Failed to load subscriptions: ${error.toString()}',
      );
    }
  }
}