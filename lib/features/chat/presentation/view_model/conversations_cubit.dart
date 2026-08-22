import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repository/chat_repository.dart';
import 'conversations_state.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  final ChatRepository _chatRepository;

  ConversationsCubit(this._chatRepository) : super(const ConversationsInitial());

  Future<void> fetchConversations() async {
    emit(const ConversationsLoading());
    try {
      final result = await _chatRepository.getConversations();
      if (result is Success<List<ConversationModel>>) {
        emit(ConversationsLoaded(result.data));
      } else if (result is Failure<List<ConversationModel>>) {
        emit(ConversationsError(result.message));
      }
    } catch (e) {
      emit(ConversationsError('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }
  void updateConversationFromRealtime(int conversationId, MessageModel message) {
    final currentState = state;
    if (currentState is! ConversationsLoaded) return;

    final updatedList = List<ConversationModel>.from(currentState.conversations);
    final index = updatedList.indexWhere((c) => c.id == conversationId);

    if (index >= 0) {
      // محادثة موجودة → حدّث last_message
      updatedList[index] = updatedList[index].copyWith(
        lastMessage: message,
        lastMessageAt: message.getDateTime(),
      );
    } else {
      // محادثة جديدة → جيب الكل من السيرفر
      fetchConversations();
      return;
    }

    // رتّبي حسب الأحدث
    updatedList.sort((a, b) => a.compareByLatest(b));
    emit(ConversationsLoaded(updatedList));
  }

  void updateConversation(ConversationModel updatedConversation) {
    final currentState = state;
    if (currentState is ConversationsLoaded) {
      final updatedList = List<ConversationModel>.from(currentState.conversations);
      final index = updatedList.indexWhere((conv) => conv.id == updatedConversation.id);
      if (index >= 0) {
        updatedList[index] = updatedConversation;
      } else {
        updatedList.insert(0, updatedConversation);
      }
      updatedList.sort((a, b) => a.compareByLatest(b));
      emit(ConversationsLoaded(updatedList));
    }
  }

  void removeConversation(int conversationId) {
    final currentState = state;
    if (currentState is ConversationsLoaded) {
      final updatedList = currentState.conversations.where((conv) => conv.id != conversationId).toList();
      emit(ConversationsLoaded(updatedList));
    }
  }

  void searchConversations(String query) {
    final currentState = state;
    if (currentState is ConversationsLoaded) {
      if (query.isEmpty) {
        emit(ConversationsLoaded(currentState.conversations));
        return;
      }
      final filteredList = currentState.conversations.where((conv) =>
          conv.otherParticipant.name.toLowerCase().contains(query.toLowerCase()) ||
          conv.getLastMessagePreview().toLowerCase().contains(query.toLowerCase())
      ).toList();
      emit(ConversationsLoaded(filteredList));
    }
  }

  Future<void> refreshConversations() async {
    await fetchConversations();
  }
}