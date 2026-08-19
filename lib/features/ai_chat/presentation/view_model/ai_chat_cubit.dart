import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repository/ai_chat_repository.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  final AiChatRepository _repository;
  final List<ChatMessageModel> _messages = [];
  CancelToken? _currentCancelToken;
  String? _pendingMessage;

  AiChatCubit(this._repository) : super(AiChatInitial());

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  Future<void> initialize() async {
    await fetchHistory();
  }

  Future<void> fetchHistory({bool forceRefresh = false}) async {
    if (_messages.isNotEmpty && !forceRefresh && !isClosed) {
      emit(AiChatSuccess(List.from(_messages)));
    }

    emit(AiChatLoading(List.from(_messages)));

    final result = await _repository.getChatHistory(forceRefresh: forceRefresh);

    if (isClosed) return;

    if (result is Success<List<ChatMessageModel>>) {
      _messages.clear();
      _messages.addAll(result.data);
      emit(AiChatSuccess(List.from(_messages)));
    } else if (result is Failure) {
      if (_messages.isNotEmpty) {
        emit(AiChatSuccess(List.from(_messages)));
      } else {
        emit(AiChatError((result as Failure).message, const []));
      }
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _pendingMessage = text.trim();
    _currentCancelToken = CancelToken();

    final tempUserMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch,
      sender: 'user',
      body: text.trim(),
      date: _formatDate(DateTime.now()),
      time: _formatTime(DateTime.now()),
    );

    _messages.add(tempUserMsg);
    emit(AiChatSending(List.from(_messages), _pendingMessage!));

    try {
      final result = await _repository.sendMessage(
        text.trim(),
        cancelToken: _currentCancelToken,
      );

      if (isClosed) return;

      if (result is Success<List<ChatMessageModel>>) {
        final newMessages = result.data;
        _messages.removeLast();
        _messages.addAll(newMessages);
        _pendingMessage = null;
        _currentCancelToken = null;
        emit(
          AiChatSuccess(
            List.from(_messages),
            lastAiMessage: newMessages.lastWhere((m) => m.sender == 'ai'),
          ),
        );
      } else if (result is Failure) {
        final errorMsg = (result as Failure).message;
        _currentCancelToken = null;
        emit(AiChatError(errorMsg, List.from(_messages)));
      }
    } on DioException catch (e) {
      _currentCancelToken = null;
      if (e.type == DioExceptionType.cancel) {
        emit(AiChatCancelled(List.from(_messages), _pendingMessage!));
      } else {
        emit(AiChatError(ApiErrorHandler.handle(e), List.from(_messages)));
      }
    } catch (e) {
      _currentCancelToken = null;
      emit(AiChatError(ApiErrorHandler.handle(e), List.from(_messages)));
    }
  }

  void cancelRequest() {
    if (_currentCancelToken != null && !_currentCancelToken!.isCancelled) {
      _currentCancelToken!.cancel('User cancelled');
    }
  }

  void removeLastMessage() {
    if (_messages.isNotEmpty && _messages.last.sender == 'user') {
      _messages.removeLast();
    }
    _pendingMessage = null;
    _currentCancelToken = null;
    if (_messages.isEmpty) {
      emit(AiChatInitial());
    } else {
      emit(AiChatSuccess(List.from(_messages)));
    }
  }

  void resendPendingMessage() {
    if (_pendingMessage != null) {
      if (_messages.isNotEmpty && _messages.last.sender == 'user') {
        _messages.removeLast();
      }
      sendMessage(_pendingMessage!);
    }
  }

void reset() {
  _currentCancelToken?.cancel();
  _currentCancelToken = null;
  _pendingMessage = null;
  _messages.clear();
  if (!isClosed) emit(AiChatInitial());
}
  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return "${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period";
  }
}
