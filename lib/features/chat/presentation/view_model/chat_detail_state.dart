
import 'package:equatable/equatable.dart';
import '../../data/models/message_model.dart';

abstract class ChatDetailState extends Equatable {
  const ChatDetailState();

  @override
  List<Object?> get props => [];
}

class ChatDetailInitial extends ChatDetailState {
  const ChatDetailInitial();
}

class ChatDetailLoading extends ChatDetailState {
  const ChatDetailLoading();
}

class ChatDetailLoaded extends ChatDetailState {
  final List<MessageModel> messages;
  final bool canSend;
  final bool isSending;

  const ChatDetailLoaded({
    required this.messages,
    required this.canSend,
    this.isSending = false,
  });

  @override
  List<Object?> get props => [messages, canSend, isSending];
}

class MessageDeleting extends ChatDetailState {
  final int messageId;

  const MessageDeleting(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class ChatDetailError extends ChatDetailState {
  final String message;

  const ChatDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

