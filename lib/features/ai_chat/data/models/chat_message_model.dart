class ChatMessageModel {
  final int id;
  final String sender; 
  final String body;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final String date;
  final String time;

  ChatMessageModel({
    required this.id,
    required this.sender,
    required this.body,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    required this.date,
    required this.time,
  });

  bool hasNutritionData() {
    return calories != null;
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? 0,
      sender: json['sender'] ?? '',
      body: json['body'] ?? '',
      calories: _parseDouble(json['calories']),
      protein: _parseDouble(json['protein']),
      carbs: _parseDouble(json['carbs']),
      fat: _parseDouble(json['fat']),
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'body': body,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'date': date,
      'time': time,
    };
  }
}
class ChatHistoryResponse {
  final String message;
  final List<ChatMessageModel> data;

  ChatHistoryResponse({
    required this.message,
    required this.data,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<ChatMessageModel>.from(
              json['data'].map((x) => ChatMessageModel.fromJson(x)),
            )
          : [],
    );
  }
}

class AiChatResponse {
  final String message;
  final ChatData data;

  AiChatResponse({
    required this.message,
    required this.data,
  });

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    return AiChatResponse(
      message: json['message'] ?? '',
      data: ChatData.fromJson(json['data'] ?? {}),
    );
  }
}

class ChatData {
  final ChatMessageModel userMessage;
  final ChatMessageModel aiMessage;

  ChatData({
    required this.userMessage,
    required this.aiMessage,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      userMessage: ChatMessageModel.fromJson(json['user_message'] ?? {}),
      aiMessage: ChatMessageModel.fromJson(json['ai_message'] ?? {}),
    );
  }
}