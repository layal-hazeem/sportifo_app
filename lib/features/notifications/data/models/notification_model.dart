class NotificationModel {
  final String id;
  final String? eventType;
  final String? model;
  final int? modelId;
  final String? deepLink;
  final String? iconUrl;
  final String title;
  final String body;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  NotificationModel({
    required this.id,
    this.eventType,
    this.model,
    this.modelId,
    this.deepLink,
    this.iconUrl,
    required this.title,
    required this.body,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      eventType: json['event_type'],
      model: json['model'],
      modelId: json['model_id'],
      deepLink: json['deep_link'],
      iconUrl: json['icon_url'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
    );
  }
}