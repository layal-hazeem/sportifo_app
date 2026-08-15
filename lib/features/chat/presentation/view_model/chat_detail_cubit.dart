import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:sportifo_app/core/services/chat_websocket_service.dart';
import 'package:sportifo_app/core/services/pending_messages_service.dart';
import 'package:sportifo_app/core/models/local_message.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import '../../data/models/message_model.dart';
import '../../data/repository/chat_repository.dart';
import 'chat_detail_state.dart';
import 'dart:developer' as dev;

class ChatDetailCubit extends Cubit<ChatDetailState> {
  final ChatRepository _chatRepository;
  final ChatWebSocketService _webSocketService;
  final PendingMessagesService _pendingService;
  
  bool _canSend = true;
  int? _currentConversationId;
  bool _isWebSocketInitialized = false;

  ChatDetailCubit({
    required ChatRepository chatRepository,
    required ChatWebSocketService webSocketService,
    required PendingMessagesService pendingService,
  })  : _chatRepository = chatRepository,
        _webSocketService = webSocketService,
        _pendingService = pendingService,
        super(const ChatDetailInitial());

  void setCanSend(bool canSend) => _canSend = canSend;

  /// 🔥 تحديث: تأكد أن الـ Cubit مش مغلق عند الـ subscription
  Future<void> subscribeToChannel(int conversationId) async {
    _currentConversationId = conversationId;
    
    // تأكد أن الـ Cubit ما زال نشط
    if (isClosed) {
      dev.log('⚠️ Cubit closed, skipping subscription');
      return;
    }

    if (!_isWebSocketInitialized) {
      await _webSocketService.init(
        onEvent: (eventName, data) {
          // تأكد أن الـ Cubit ما زال نشط قبل ما تعالج الـ event
          if (!isClosed) {
            _handleWebSocketEvent(eventName, data);
          }
        },
        onConnectionChange: (state) {
          if (!isClosed && state == 'CONNECTED' && _currentConversationId != null) {
            _resyncConversation(_currentConversationId!);
          }
        },
      );
      _isWebSocketInitialized = true;
    }

    await _webSocketService.subscribeToChannel(conversationId);
    
    // 🔥 تحديث: أضيف delay قصير للتأكد من الـ subscription وبعدها resync فوراً
    await Future.delayed(const Duration(milliseconds: 500));
    if (!isClosed) {
      await _resyncConversation(conversationId);
    }
  }

  void _handleWebSocketEvent(String eventName, Map<String, dynamic> data) {
    dev.log('📨 Handling: $eventName');
    
    // تأكد أن الـ Cubit ما زال نشط
    if (isClosed) return;
    
    switch (eventName) {
      case 'message.sent':
        final messageData = data['message'] as Map<String, dynamic>?;
        if (messageData == null) return;
        final newMessage = MessageModel.fromJson(messageData);
        dev.log('✅ Merging new message: ${newMessage.id}');
        _mergeNewMessage(newMessage);
        break;

      case 'message.read':
        final readerId = data['reader_id'] as int?;
        final lastReadId = data['last_read_message_id'] as int?;
        if (readerId != null && lastReadId != null) {
          dev.log('✅ Marking messages as read up to: $lastReadId');
          _markMessagesAsRead(readerId, lastReadId);
        }
        break;

      case 'message.deleted':
        final messageId = data['message_id'] as int?;
        if (messageId != null) {
          dev.log('✅ Removing message: $messageId');
          _removeMessage(messageId);
        }
        break;

      case 'client-typing':
        dev.log('📝 User typing...');
        break;
    }
  }

  /// 🔥 Merge: إذا كانت الـ Cubit closed، ما نعمل إشي
  void _mergeNewMessage(MessageModel newMessage) {
    if (isClosed) return;
    
    final currentState = state;
    if (currentState is! ChatDetailLoaded) return;

    // Check if message already exists
    final existingIndex = currentState.messages.indexWhere((msg) =>
        msg.clientUuid == newMessage.clientUuid || msg.id == newMessage.id);

    List<MessageModel> updatedMessages;

    if (existingIndex != -1) {
      // Replace existing message
      updatedMessages = List<MessageModel>.from(currentState.messages);
      updatedMessages[existingIndex] = newMessage;
      dev.log('🔄 Updated message at index $existingIndex');
    } else {
      // Add new message
      updatedMessages = List<MessageModel>.from(currentState.messages)..add(newMessage);
      dev.log('➕ Added new message: ${newMessage.id}');
    }

    updatedMessages.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
    
    emit(ChatDetailLoaded(
      messages: updatedMessages,
      canSend: currentState.canSend,
      isSending: false,
    ));
  }

  void _markMessagesAsRead(int readerId, int lastReadId) {
    if (isClosed) return;
    
    final currentState = state;
    if (currentState is! ChatDetailLoaded) return;

    final updated = currentState.messages.map((msg) {
      if (msg.id <= lastReadId && msg.senderId != readerId) {
        return msg.copyWith(
          readAt: {
            'date': DateTime.now().toLocal().toString().split(' ')[0],
            'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          },
        );
      }
      return msg;
    }).toList();

    emit(ChatDetailLoaded(
      messages: updated,
      canSend: currentState.canSend,
      isSending: currentState.isSending,
    ));
  }

  void _removeMessage(int messageId) {
    if (isClosed) return;
    
    final currentState = state;
    if (currentState is! ChatDetailLoaded) return;
    
    final updated = currentState.messages.where((m) => m.id != messageId).toList();
    emit(ChatDetailLoaded(
      messages: updated,
      canSend: currentState.canSend,
      isSending: currentState.isSending,
    ));
  }

  /// 🔥 Resync محسّن: أضيف proper error handling
  Future<void> _resyncConversation(int conversationId) async {
    if (isClosed) return;
    
    try {
      final currentState = state;
      int? afterId;
      
      if (currentState is ChatDetailLoaded && currentState.messages.isNotEmpty) {
        afterId = currentState.messages
            .map((m) => m.id)
            .where((id) => id > 0)
            .fold<int>(0, (prev, curr) => curr > prev ? curr : prev);
        
        if (afterId == 0) afterId = null;
      }

      dev.log('🔄 Resyncing conversation (afterId: $afterId)...');

      final result = await _chatRepository.getMessages(conversationId, afterId: afterId);

      if (isClosed) return;

      if (result is Success<List<MessageModel>>) {
        final newMessages = result.data;
        dev.log('📥 Received ${newMessages.length} new messages');
        
        if (newMessages.isEmpty) return;

        if (state is ChatDetailLoaded) {
          final current = (state as ChatDetailLoaded).messages;
          final merged = List<MessageModel>.from(current);

          for (final serverMsg in newMessages) {
            final exists = merged.any((m) => 
                m.id == serverMsg.id || m.clientUuid == serverMsg.clientUuid);
            if (!exists) {
              merged.add(serverMsg);
              dev.log('➕ Added synced message: ${serverMsg.id}');
            }
          }

          merged.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
          
          emit(ChatDetailLoaded(
            messages: merged,
            canSend: (state as ChatDetailLoaded).canSend,
            isSending: false,
          ));
          dev.log('✅ Resync complete');
        }
      } else if (result is Failure<List<MessageModel>>) {
        dev.log('❌ Resync failed: ${result.message}');
      }
    } catch (e) {
      dev.log('❌ Resync exception: $e');
    }
  }

  Future<void> fetchMessages(int conversationId) async {
    if (isClosed) return;
    
    emit(const ChatDetailLoading());
    try {
      final result = await _chatRepository.getMessages(conversationId);
      
      if (isClosed) return;
      
      if (result is Success<List<MessageModel>>) {
        final messages = result.data;
        messages.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
        emit(ChatDetailLoaded(messages: messages, canSend: _canSend));
      } else if (result is Failure<List<MessageModel>>) {
        emit(ChatDetailError(result.message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(ChatDetailError('خطأ في تحميل الرسائل: ${e.toString()}'));
      }
    }
  }

  Future<void> sendMessage(
    int conversationId,
    String messageText,
    int currentUserId,
    String senderName,
    String? senderImage, {
    List<String>? imagePaths,
  }) async {
    if (isClosed) return;
    
    if (messageText.trim().isEmpty && (imagePaths == null || imagePaths.isEmpty)) {
      return;
    }
    if (!_canSend) {
      emit(const ChatDetailError('ليس لديك صلاحية للإرسال'));
      return;
    }

    final clientUuid = const Uuid().v4();
    final now = DateTime.now();

    // 1. خزّن محلياً
    final localMessage = LocalMessage(
      clientUuid: clientUuid,
      conversationId: conversationId,
      body: messageText.trim().isEmpty ? null : messageText.trim(),
      imagePaths: imagePaths,
      status: 'pending',
      createdAt: now,
    );
    await _pendingService.addMessage(localMessage);

    // 2. أضف للواجهة فوراً
    final tempMessage = MessageModel(
      id: -1,
      conversationId: conversationId,
      senderId: currentUserId,
      senderName: senderName,
      senderImage: senderImage,
      body: messageText.trim(),
      media: imagePaths?.map((path) => {'url': path}).toList() ?? [],
      clientUuid: clientUuid,
      sentAt: {
        'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        'time': '${now.hour > 12 ? now.hour - 12 : now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}',
      },
      isDeleted: false,
    );

    final currentState = state;
    if (currentState is ChatDetailLoaded && !isClosed) {
      final updated = List<MessageModel>.from(currentState.messages)..add(tempMessage);
      emit(ChatDetailLoaded(
        messages: updated,
        canSend: true,
        isSending: true,
      ));
    }

    // 3. أرسل للسيرفر
    try {
      final result = await _chatRepository.sendMessage(
        conversationId: conversationId,
        body: messageText.trim(),
        clientUuid: clientUuid,
        imageFiles: imagePaths,
      );

      if (isClosed) return;

      if (result is Success<MessageModel>) {
        await _pendingService.removeMessage(clientUuid);
        _mergeNewMessage(result.data);
      } else if (result is Failure<MessageModel>) {
        await _pendingService.updateStatus(clientUuid, 'failed');
        _removeTempMessage(clientUuid);
        emit(ChatDetailError(result.message));
      }
    } catch (e) {
      if (!isClosed) {
        await _pendingService.updateStatus(clientUuid, 'failed');
        _removeTempMessage(clientUuid);
        emit(ChatDetailError('فشل إرسال الرسالة: ${e.toString()}'));
      }
    }
  }

  void _removeTempMessage(String clientUuid) {
    if (isClosed) return;
    
    final currentState = state;
    if (currentState is ChatDetailLoaded) {
      final updated = currentState.messages
          .where((msg) => msg.clientUuid != clientUuid)
          .toList();
      emit(ChatDetailLoaded(
        messages: updated,
        canSend: _canSend,
        isSending: false,
      ));
    }
  }

  Future<void> retryPendingMessages() async {
    if (isClosed) return;
    
    final pending = _pendingService.getPendingMessages();
    if (pending.isEmpty) return;

    for (final msg in pending.where((m) => m.status == 'pending' || m.status == 'failed')) {
      try {
        final result = await _chatRepository.sendMessage(
          conversationId: msg.conversationId,
          body: msg.body ?? '',
          clientUuid: msg.clientUuid,
          imageFiles: msg.imagePaths,
        );

        if (isClosed) return;

        if (result is Success<MessageModel>) {
          await _pendingService.removeMessage(msg.clientUuid);
          _mergeNewMessage(result.data);
        } else {
          await _pendingService.updateStatus(msg.clientUuid, 'failed');
        }
      } catch (e) {
        await _pendingService.updateStatus(msg.clientUuid, 'failed');
        dev.log('❌ Retry failed: $e');
      }
    }
  }

  Future<void> deleteMessage(int conversationId, int messageId, String clientUuid) async {
    if (isClosed) return;
    
    final currentState = state;
    if (currentState is! ChatDetailLoaded) return;

    final optimistic = currentState.messages
        .where((msg) => msg.id != messageId && msg.clientUuid != clientUuid)
        .toList();

    emit(ChatDetailLoaded(
      messages: optimistic,
      canSend: currentState.canSend,
      isSending: currentState.isSending,
    ));

    try {
      final result = await _chatRepository.deleteMessage(conversationId, messageId);
      if (result is Failure<bool>) {
        emit(ChatDetailError(result.message));
        await fetchMessages(conversationId);
      }
    } catch (e) {
      emit(ChatDetailError('فشل حذف الرسالة: ${e.toString()}'));
      await fetchMessages(conversationId);
    }
  }

  Future<void> unsubscribe() async {
    await _webSocketService.unsubscribeFromChannel();
  }

  Future<void> checkConnectivityAndRetry() async {
    if (isClosed) return;
    
    await retryPendingMessages();
    if (_currentConversationId != null) {
      await _resyncConversation(_currentConversationId!);
    }
  }

  @override
  Future<void> close() async {
    await _webSocketService.disconnect();
    return super.close();
  }
}