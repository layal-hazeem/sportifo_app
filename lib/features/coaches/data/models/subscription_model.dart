// lib/features/coaches/data/models/subscription_model.dart

class SubscriptionModel {
  final int id;
  final String title;
  final String description;
  final String type; // gold, silver, bronze
  final num price; // استخدمنا num لتفادي مشاكل الـ int والـ double
  final String currency;
  final bool isGeneral;
  final bool isActive;
  final int months;

  SubscriptionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    required this.currency,
    required this.isGeneral,
    required this.isActive,
    required this.months,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'bronze',
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 'SYP',
      isGeneral: json['is_general'] ?? false,
      isActive: json['is_active'] ?? false,
      months: json['months'] ?? 1,
    );
  }
}