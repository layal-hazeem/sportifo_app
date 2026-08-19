// lib/features/chat/presentation/view_model/conversations_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/conversation_model.dart';

abstract class ConversationsState extends Equatable {
  const ConversationsState();

  @override
  List<Object?> get props => [];
}

class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

class ConversationsLoaded extends ConversationsState {
  final List<ConversationModel> conversations;

  const ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ConversationsError extends ConversationsState {
  final String message;

  const ConversationsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ConversationDeleted extends ConversationsState {
  final int conversationId;

  const ConversationDeleted(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class ConversationAdded extends ConversationsState {
  final ConversationModel newConversation;

  const ConversationAdded(this.newConversation);

  @override
  List<Object?> get props => [newConversation];
}