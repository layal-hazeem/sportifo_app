import '../../data/models/chat_message_model.dart';

sealed class AiChatState {}

final class AiChatInitial extends AiChatState {}

final class AiChatLoading extends AiChatState {
  final List<ChatMessageModel> messages;
  AiChatLoading(this.messages);
}

final class AiChatSending extends AiChatState {
  final List<ChatMessageModel> messages;
  final String pendingText;
  AiChatSending(this.messages, this.pendingText);
}

final class AiChatSuccess extends AiChatState {
  final List<ChatMessageModel> messages;
  final ChatMessageModel? lastAiMessage;
  AiChatSuccess(this.messages, {this.lastAiMessage});
}

final class AiChatError extends AiChatState {
  final String message;
  final List<ChatMessageModel> messages;
  AiChatError(this.message, this.messages);
}

final class AiChatCancelled extends AiChatState {
  final List<ChatMessageModel> messages;
  final String pendingText;
  AiChatCancelled(this.messages, this.pendingText);
}
