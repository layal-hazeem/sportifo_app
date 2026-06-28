import 'subscription_month_model.dart';

class SubscriptionModel {
  final int id;
  final String title;
  final String description;
  final String type;
  final String currency;
  final bool isGeneral;
  final bool isActive;
  final List<SubscriptionMonthModel> months;

  SubscriptionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.currency,
    required this.isGeneral,
    required this.isActive,
    required this.months,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final monthsList = json['months'] as List? ?? [];

    return SubscriptionModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'bronze',
      currency: json['currency'] ?? 'SYP',
      isGeneral: json['is_general'] ?? false,
      isActive: json['is_active'] ?? false,
      months: monthsList.map((e) => SubscriptionMonthModel.fromJson(e)).toList(),
    );
  }
}