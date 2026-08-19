enum SubscriptionType {
  gold,    // ثنائي الاتجاه - coach و trainee يرسلان
  silver,  // الكوتش فقط يرسل
  bronze   // الكوتش فقط يرسل
}

// في message_bubble.dart
bool canSend(SubscriptionType type, bool isCurrentUserCoach) {
  if (type == SubscriptionType.gold) return true; // الكل يقدر يرسل
  if (type == SubscriptionType.silver || type == SubscriptionType.bronze) {
    return isCurrentUserCoach; // بس الكوتش يرسل
  }
  return false;
}