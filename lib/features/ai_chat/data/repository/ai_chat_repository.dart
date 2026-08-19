import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:sportifo_app/core/storage/local_storage.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_factory.dart';
import '../models/chat_message_model.dart';
import '../web_services/ai_chat_web_service.dart';

class AiChatRepository {
  final AiChatWebService _webService;
  final LocalStorage _localStorage;
  Box<String>? _chatBox;

  AiChatRepository(this._webService, this._localStorage) {
    _initBox();
  }

  Future<void> _initBox() async {
    _chatBox ??= await Hive.openBox<String>('ai_chat_cache');
  }

  List<ChatMessageModel> getCachedMessages() {
    if (_chatBox == null) return [];
    final raw = _chatBox!.get(_messagesKey);        // ✅ بدل 'messages'
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => ChatMessageModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

   Future<void> _saveMessages(List<ChatMessageModel> messages) async {
    await _initBox();
    final encoded = jsonEncode(messages.map((m) => m.toJson()).toList());
    await _chatBox!.put(_messagesKey, encoded);     // ✅ بدل 'messages'
  }
  // ✅ حذف كل المحادثات المحفوظة (تنادى عند تسجيل الخروج)
  Future<void> clearAllChats() async {
    await _initBox();
    final keys = _chatBox!.keys
        .where((k) => k.toString().startsWith('messages_'))
        .toList();
    await _chatBox!.deleteAll(keys);
    await _chatBox!.delete('messages'); // المفتاح القديم قبل التعديل
  }

  // ✅ مفتاح خاص بكل مستخدم
  String get _messagesKey {
    final uid = _localStorage.getUserId() ?? 'guest';
    return 'messages_$uid';
  }
  Future<ApiResult<List<ChatMessageModel>>> getChatHistory({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        await _initBox();
        final cached = getCachedMessages();
        if (cached.isNotEmpty) {
          return Success(cached);
        }
      }

      final cacheOptions = await GetIt.instance<DioFactory>().getCacheOptions();
      final options = cacheOptions
          .copyWith(policy: CachePolicy.refresh)
          .toOptions();

      final response = await _webService.getChatHistory(options: options);
      final data = ChatHistoryResponse.fromJson(response.data).data;

      await _saveMessages(data);
      return Success(data);
    } catch (e) {
      final cached = getCachedMessages();
      if (cached.isNotEmpty) {
        return Success(cached);
      }
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<ChatMessageModel>>> sendMessage(
    String message, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _webService.sendMessage(
        message,
        cancelToken: cancelToken,
      );

      final responseModel = AiChatResponse.fromJson(response.data);
      final newMessages = [
        responseModel.data.userMessage,
        responseModel.data.aiMessage,
      ];

      await _initBox();
      final current = getCachedMessages();
      current.addAll(newMessages);
      await _saveMessages(current);

      return Success(newMessages);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      return Failure(ApiErrorHandler.handle(e));
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}
