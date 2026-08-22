
import 'participant_model.dart';
import 'message_model.dart';

class ConversationModel {
  final int id;
  final ParticipantModel otherParticipant;
  final MessageModel? lastMessage;
  final DateTime lastMessageAt;
  final String? subscriptionType;
  final bool availableNow; 

  ConversationModel({
    required this.id,
    required this.otherParticipant,
    required this.lastMessage,
    required this.lastMessageAt,
    this.subscriptionType,
    this.availableNow = true,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    MessageModel? lastMsg;
    if (json['last_message'] != null) {
      lastMsg = MessageModel.fromJson(json['last_message']);
    }

    DateTime parseTime = DateTime.now();
    if (json['last_message_at'] != null) {
      try {
        parseTime = DateTime.parse(json['last_message_at']);
      } catch (e) {
        parseTime = DateTime.now();
      }
    }

    return ConversationModel(
      id: json['id'] ?? 0,
      otherParticipant:
          ParticipantModel.fromJson(json['other_participant'] ?? {}),
      lastMessage: lastMsg,
      lastMessageAt: parseTime,
      subscriptionType: json['subscription_type']?.toString(),
      availableNow: json['available_now'] ?? true,
    );
  }

ConversationModel copyWith({
  int? id,
  ParticipantModel? otherParticipant,
  MessageModel? lastMessage,
  DateTime? lastMessageAt,
  String? subscriptionType,
  bool? availableNow,
}) {
  return ConversationModel(
    id: id ?? this.id,
    otherParticipant: otherParticipant ?? this.otherParticipant,
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    subscriptionType: subscriptionType ?? this.subscriptionType,
    availableNow: availableNow ?? this.availableNow,
  );
}
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'other_participant': otherParticipant.toJson(),
      'last_message': lastMessage?.toJson(),
      'last_message_at': lastMessageAt.toIso8601String(),
      'subscription_type': subscriptionType,
      'available_now': availableNow,
    };
  }

  int compareByLatest(ConversationModel other) {
    return other.lastMessageAt.compareTo(lastMessageAt);
  }

  String getLastMessagePreview() {
    if (lastMessage == null) return 'No messages yet';
    if (lastMessage!.body.isEmpty) return 'Image';
    if (lastMessage!.body.length > 50) {
      return '${lastMessage!.body.substring(0, 50)}...';
    }
    return lastMessage!.body;
  }
}
