import 'package:sportifo_app/core/network/api_error_handler.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../web_services/chat_web_service.dart';

class ChatRepository {
  final ChatWebService _chatWebService;

  ChatRepository(this._chatWebService);

  Future<ApiResult<List<ConversationModel>>> getConversations() async {
    try {
      final response = await _chatWebService.getConversations();

      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data['data'] ?? [];

        final List<ConversationModel> conversations = dataList
            .map((json) => ConversationModel.fromJson(json))
            .toList();

        conversations.sort((a, b) => a.compareByLatest(b));

        return Success(conversations);
      } else {
        return Failure('Failed to fetch conversations');
      }
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<MessageModel>>> getMessages(
  int conversationId, {
  int? afterId, 
}) async {
  try {
    final response = await _chatWebService.getMessages(
      conversationId,
      afterId: afterId,
    );

    if (response.statusCode == 200) {
      final List<dynamic> dataList = response.data['data'] ?? [];
      final List<MessageModel> messages = dataList
          .map((json) => MessageModel.fromJson(json))
          .toList();
      messages.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
      return Success(messages);
    } else {
      return Failure('Failed to fetch messages');
    }
  } catch (e) {
    return Failure(ApiErrorHandler.handle(e));
  }
}

  Future<ApiResult<MessageModel>> sendMessage({
    required int conversationId,
    required String body,
    required String clientUuid,
    List<String>? imageFiles,
  }) async {
    try {
      final response = await _chatWebService.sendMessage(
        conversationId,
        body: body,
        clientUuid: clientUuid,
        imageFiles: imageFiles,
      );

      if (response.statusCode == 201) {
        final messageData = response.data['data'];
        final message = MessageModel.fromJson(messageData);

        return Success(message);
      } else {
        return Failure('Failed to send message');
      }
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<bool>> deleteMessage(
    int conversationId,
    int messageId,
  ) async {
    try {
      final response = await _chatWebService.deleteMessage(
        conversationId,
        messageId,
      );

      if (response.statusCode == 200) {
        return Success(true);
      } else {
        return Failure('Failed to delete message');
      }
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  bool canSendMessage(String subscriptionType, bool isCurrentUserCoach) {
    switch (subscriptionType.toLowerCase()) {
      case 'gold':
        return true;
      case 'silver':
      case 'bronze':
        return isCurrentUserCoach;
      default:
        return false;
    }
  }

  String generateClientUuid() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}