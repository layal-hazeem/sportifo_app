class SubscriptionMonthModel {
  final int id;
  final int number;
  final num price;

  SubscriptionMonthModel({
    required this.id,
    required this.number,
    required this.price,
  });

  factory SubscriptionMonthModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionMonthModel(
      id: json['id'] ?? 0,
      number: json['number'] ?? 0,
      price: json['price'] ?? 0,
    );
  }
}