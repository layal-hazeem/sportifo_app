import 'dart:async';
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
  Timer? _typingTimer;
  
  bool _canSend = true;
  int? _currentConversationId;
  int? _currentUserId; // 🔥 جديد
  bool _isWebSocketInitialized = false;
  bool _isScreenActive = false;

  ChatDetailCubit({
    required ChatRepository chatRepository,
    required ChatWebSocketService webSocketService,
    required PendingMessagesService pendingService,
  })  : _chatRepository = chatRepository,
        _webSocketService = webSocketService,
        _pendingService = pendingService,
        super(const ChatDetailInitial());

  void setCanSend(bool canSend) => _canSend = canSend;
  void setCurrentUserId(int userId) => _currentUserId = userId; // 🔥 جديد
  void setScreenActive(bool active) {
    _isScreenActive = active;
    dev.log('👁️ Screen active: $active');
  }

  // 🔥 تحويل LocalMessage → MessageModel لعرضها بالواجهة
  MessageModel _localToMessageModel(LocalMessage local) {
    return MessageModel(
      id: -1,
      conversationId: local.conversationId,
      senderId: _currentUserId ?? 0,
      senderName: 'أنت',
      senderImage: null,
      body: local.body ?? '',
      media: local.imagePaths?.map((p) => {'url': p}).toList() ?? [],
      clientUuid: local.clientUuid,
      sentAt: {
        'date': '${local.createdAt.year}-${local.createdAt.month.toString().padLeft(2, '0')}-${local.createdAt.day.toString().padLeft(2, '0')}',
        'time': '${local.createdAt.hour > 12 ? local.createdAt.hour - 12 : local.createdAt.hour}:${local.createdAt.minute.toString().padLeft(2, '0')} ${local.createdAt.hour >= 12 ? 'PM' : 'AM'}',
      },
      status: local.status,
    );
  }

  Future<void> subscribeToChannel(int conversationId) async {
    _currentConversationId = conversationId;
    if (isClosed) return;

      if (!_isWebSocketInitialized) {
      await _webSocketService.init();
      
      // 🔥 استمعي للأحداث من الـ Stream
      _webSocketService.events.listen((event) {
        if (!isClosed && event.conversationId == _currentConversationId) {
          _handleWebSocketEvent(event.eventName, event.data);
        }
      });
      
      _webSocketService.connectionState.listen((state) {
        if (!isClosed && state == 'CONNECTED' && _currentConversationId != null) {
          _resyncConversation(_currentConversationId!);
        }
      });
      
      _isWebSocketInitialized = true;
    }

    await _webSocketService.subscribeToChannel(conversationId);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!isClosed) await _resyncConversation(conversationId);
  }

  void _handleWebSocketEvent(String eventName, Map<String, dynamic> data) {
    dev.log('📨 Handling: $eventName');
    if (isClosed) return;
    
    switch (eventName) {
      case 'message.sent':
        final messageData = data['message'] as Map<String, dynamic>?;
        if (messageData == null) return;
        final newMessage = MessageModel.fromJson(messageData);
        _mergeNewMessage(newMessage);
        if (_isScreenActive && _currentConversationId != null) {
          _resyncConversation(_currentConversationId!);
        }
        break;
      case 'message.read':
        final readerId = data['reader_id'] as int?;
        final lastReadId = data['last_read_message_id'] as int?;
        if (readerId != null && lastReadId != null) _markMessagesAsRead(readerId, lastReadId);
        break;
      case 'message.deleted':
        final messageId = data['message_id'] as int?;
        if (messageId != null) _removeMessage(messageId);
        break;
      case 'client-typing':
        final typingUserId = data['user_id'] as int?;
        if (typingUserId != null) _showTypingIndicator(typingUserId);
        break;
    }
  }

  void _showTypingIndicator(int userId) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is! ChatDetailLoaded) return;
    _typingTimer?.cancel();
    emit(ChatDetailLoaded(
      messages: currentState.messages,
      canSend: currentState.canSend,
      isSending: currentState.isSending,
      typingUserId: userId,
    ));
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (isClosed) return;
      final s = state;
      if (s is ChatDetailLoaded && s.typingUserId == userId) {
        emit(ChatDetailLoaded(
          messages: s.messages,
          canSend: s.canSend,
          isSending: s.isSending,
          typingUserId: null,
        ));
      }
    });
  }

  Future<void> sendTypingNotification(int conversationId, int userId) async {
    await _webSocketService.sendTypingEvent(conversationId, userId);
  }

  // 🔥🔥🔥 دمج الرسالة الجديدة (من WebSocket أو إرسال ناجح)
  void _mergeNewMessage(MessageModel newMessage) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is! ChatDetailLoaded) return;

    final existingIndex = currentState.messages.indexWhere((msg) =>
        msg.clientUuid == newMessage.clientUuid || msg.id == newMessage.id);

    List<MessageModel> updatedMessages;

    if (existingIndex != -1) {
      updatedMessages = List<MessageModel>.from(currentState.messages);
      updatedMessages[existingIndex] = newMessage.copyWith(status: 'sent');
    } else {
      updatedMessages = List<MessageModel>.from(currentState.messages)
        ..add(newMessage.copyWith(status: 'sent'));
    }

    updatedMessages.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
    emit(ChatDetailLoaded(
      messages: updatedMessages,
      canSend: currentState.canSend,
      isSending: false,
    ));
  }

  // 🔥🔥🔥 تحديث حالة رسالة محلية (pending → failed أو العكس)
  void _updateMessageStatus(String clientUuid, String newStatus) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is! ChatDetailLoaded) return;

    final updated = currentState.messages.map((msg) {
      if (msg.clientUuid == clientUuid) {
        return msg.copyWith(status: newStatus);
      }
      return msg;
    }).toList();

    emit(ChatDetailLoaded(
      messages: updated,
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
        if (newMessages.isEmpty) return;
        if (state is ChatDetailLoaded) {
          final current = (state as ChatDetailLoaded).messages;
          final merged = List<MessageModel>.from(current);
          for (final serverMsg in newMessages) {
            final exists = merged.any((m) => 
                m.id == serverMsg.id || m.clientUuid == serverMsg.clientUuid);
            if (!exists) merged.add(serverMsg);
          }
          merged.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
          emit(ChatDetailLoaded(
            messages: merged,
            canSend: (state as ChatDetailLoaded).canSend,
            isSending: false,
          ));
        }
      }
    } catch (e) {
      dev.log('❌ Resync exception: $e');
    }
  }

  // 🔥🔥🔥 fetchMessages محسّن: يدمج المحلية مع السيرفر
  Future<void> fetchMessages(int conversationId) async {
    if (isClosed) return;
    emit(const ChatDetailLoading());
    
    try {
      final result = await _chatRepository.getMessages(conversationId);
      if (isClosed) return;

      if (result is Success<List<MessageModel>>) {
        final serverMessages = result.data;
        
        // 🔥 أضيفي الرسائل المحلية المعلقة
        final pending = _pendingService.getPendingMessages()
            .where((m) => m.conversationId == conversationId);
        
        final localMessages = pending.map(_localToMessageModel).toList();
        
        // ادمج: أضف المحلية يلي ما لها نظير بالسيرفر
        final merged = [...serverMessages];
        for (final local in localMessages) {
          if (!merged.any((m) => m.clientUuid == local.clientUuid)) {
            merged.add(local);
          }
        }

        merged.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
        emit(ChatDetailLoaded(messages: merged, canSend: _canSend));
      } else if (result is Failure<List<MessageModel>>) {
        emit(ChatDetailError(result.message));
      }
    } catch (e) {
      if (!isClosed) emit(ChatDetailError('خطأ في تحميل الرسائل: ${e.toString()}'));
    }
  }

  // 🔥🔥🔥 sendMessage محسّن: ما بيحذف الرسالة عند الفشل
  Future<void> sendMessage(
    int conversationId,
    String messageText,
    int currentUserId,
    String senderName,
    String? senderImage, {
    List<String>? imagePaths,
  }) async {
    if (isClosed) return;
    if (messageText.trim().isEmpty && (imagePaths == null || imagePaths.isEmpty)) return;
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

    // 2. أضف للواجهة فوراً (Optimistic UI)
    final tempMessage = _localToMessageModel(localMessage);

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
        _updateMessageStatus(clientUuid, 'failed');
      }
    } catch (e) {
      if (!isClosed) {
        await _pendingService.updateStatus(clientUuid, 'failed');
        _updateMessageStatus(clientUuid, 'failed');
      }
    }
  }

  // 🔥🔥🔥 إعادة إرسال رسالة محددة (عند الضغط على ❌)
  Future<void> retryMessage(String clientUuid) async {
    if (isClosed) return;
    final msg = _pendingService.getPendingMessages()
        .firstWhere((m) => m.clientUuid == clientUuid, orElse: () => null as LocalMessage);
    
    // تحديث الحالة لـ pending مؤقتاً
    await _pendingService.updateStatus(clientUuid, 'pending');
    _updateMessageStatus(clientUuid, 'pending');

    try {
      final result = await _chatRepository.sendMessage(
        conversationId: msg.conversationId,
        body: msg.body ?? '',
        clientUuid: msg.clientUuid,
        imageFiles: msg.imagePaths,
      );

      if (isClosed) return;

      if (result is Success<MessageModel>) {
        await _pendingService.removeMessage(clientUuid);
        _mergeNewMessage(result.data);
      } else {
        await _pendingService.updateStatus(clientUuid, 'failed');
        _updateMessageStatus(clientUuid, 'failed');
      }
    } catch (e) {
      await _pendingService.updateStatus(clientUuid, 'failed');
      _updateMessageStatus(clientUuid, 'failed');
    }
  }

  Future<void> retryPendingMessages() async {
    if (isClosed) return;
    final pending = _pendingService.getPendingMessages()
        .where((m) => m.conversationId == _currentConversationId)
        .where((m) => m.status == 'pending' || m.status == 'failed')
        .toList();
    
    if (pending.isEmpty) return;

    for (final msg in pending) {
      await _pendingService.updateStatus(msg.clientUuid, 'pending');
      _updateMessageStatus(msg.clientUuid, 'pending');
      
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
          _updateMessageStatus(msg.clientUuid, 'failed');
        }
      } catch (e) {
        await _pendingService.updateStatus(msg.clientUuid, 'failed');
        _updateMessageStatus(msg.clientUuid, 'failed');
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
    if (_currentConversationId != null) {
      await _webSocketService.unsubscribeFromChannel(_currentConversationId!);
    }
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
    await unsubscribe();
    _typingTimer?.cancel();
    return super.close();
  }
}