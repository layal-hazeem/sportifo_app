import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_factory.dart';
import '../models/chat_message_model.dart';
import '../web_services/ai_chat_web_service.dart';

class AiChatRepository {
  final AiChatWebService _webService;
  Box<String>? _chatBox;

  AiChatRepository(this._webService) {
    _initBox();
  }

  Future<void> _initBox() async {
    _chatBox ??= await Hive.openBox<String>('ai_chat_cache');
  }

  List<ChatMessageModel> getCachedMessages() {
    if (_chatBox == null) return [];
    final raw = _chatBox!.get('messages');
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
    await _chatBox!.put('messages', encoded);
  }

  // 🔥 الدالة السحرية لمسح رسائل المستخدم القديم من ذاكرة الهاتف
  Future<void> clearCache() async {
    await _initBox();
    await _chatBox!.clear();
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

      final cacheOptions = await DioFactory.getCacheOptions();
      final options = cacheOptions
          .copyWith(policy: CachePolicy.refreshForceCache) // 👈 إجبار جلب داتا جديدة
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