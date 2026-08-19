class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String? senderImage;
  final String body;
  final List<dynamic> media;
  final String clientUuid;
  final Map<String, String>? sentAt;
  final Map<String, String>? deliveredAt;
  final Map<String, String>? readAt;
  final bool isDeleted;
  final String? deletedAt;
  final String status;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderImage,
    required this.body,
    required this.media,
    required this.clientUuid,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.isDeleted = false,
    this.deletedAt,
    this.status = 'sent',
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    Map<String, String>? parseDateTimeObj(dynamic obj) {
      if (obj == null || obj is! Map) return null;
      return {
        'date': obj['date']?.toString() ?? '',
        'time': obj['time']?.toString() ?? '',
      };
    }

    return MessageModel(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      senderName: json['sender_name'] ?? 'Unknown',
      senderImage: json['sender_image'],
      body: json['body'] ?? '',
      media: json['media'] ?? [],
      clientUuid: json['client_uuid'] ?? '',
      sentAt: parseDateTimeObj(json['sent_at']),
      deliveredAt: parseDateTimeObj(json['delivered_at']),
      readAt: parseDateTimeObj(json['read_at']),
      isDeleted: json['deleted_at'] != null,
      deletedAt: json['deleted_at']?.toString(),
      status: 'sent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_image': senderImage,
      'body': body,
      'media': media,
      'client_uuid': clientUuid,
      'sent_at': sentAt,
      'delivered_at': deliveredAt,
      'read_at': readAt,
      'deleted_at': deletedAt,
    };
  }

  MessageModel copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    String? senderName,
    String? senderImage,
    String? body,
    List<dynamic>? media,
    String? clientUuid,
    Map<String, String>? sentAt,
    Map<String, String>? deliveredAt,
    Map<String, String>? readAt,
    bool? isDeleted,
    String? deletedAt,
    String? status,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      body: body ?? this.body,
      media: media ?? this.media,
      clientUuid: clientUuid ?? this.clientUuid,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      status: status ?? this.status,
    );
  }

  String getFormattedTime() {
    if (sentAt != null && sentAt!['time'] != null && sentAt!['time']!.isNotEmpty) {
      return sentAt!['time']!;
    }
    return '';
  }

  String getMessageDetails() {
    final buffer = StringBuffer();
    if (sentAt != null) {
      buffer.write('🕐 Sent: ${sentAt!['date']} ${sentAt!['time']}\n');
    }
    if (deliveredAt != null) {
      buffer.write('✓ Delivered: ${deliveredAt!['date']} ${deliveredAt!['time']}\n');
    }
    if (readAt != null) {
      buffer.write('✓✓ Read: ${readAt!['date']} ${readAt!['time']}');
    }
    return buffer.toString().trim();
  }

   DateTime getDateTime() {
    try {
      if (sentAt != null) {
        final dateStr = sentAt!['date']; // "2026-08-16"
        final timeStr = sentAt!['time']; // "03:48 AM" or "15:30"
        if (dateStr != null && dateStr.isNotEmpty) {
          if (timeStr != null && timeStr.isNotEmpty) {
            return _parseDateTime(dateStr, timeStr);
          }
          return DateTime.parse(dateStr);
        }
      }
    } catch (e) {
      // ignore
    }
    return DateTime.now();
  }

  DateTime _parseDateTime(String date, String time) {
    try {
      final parts = time.split(' ');
      final hm = parts[0].split(':');
      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);
      
      if (parts.length == 2) {
        final period = parts[1].toUpperCase();
        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }
      
      final dt = DateTime.parse(date);
      return DateTime(dt.year, dt.month, dt.day, hour, minute);
    } catch (_) {
      return DateTime.parse(date);
    }
  }

  int getStatus() {
    if (readAt != null) return 2;
    if (deliveredAt != null) return 1;
    return 0;
  }
}