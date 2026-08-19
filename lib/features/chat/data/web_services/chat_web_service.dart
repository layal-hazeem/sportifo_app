import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class ChatWebService {
  final Dio _dio;

  ChatWebService(this._dio);

  /// 🔥 نضيف timestamp فريد لكل طلب لنمنع الكاش نهائياً
  Map<String, dynamic> get _cacheBust {
    return {'_': DateTime.now().millisecondsSinceEpoch.toString()};
  }

  Future<Response> getConversations() async {
    return await _dio.get(
      ApiConstants.conversations,
      queryParameters: _cacheBust,
    );
  }

Future<Response> getMessages(
  int conversationId, {
  int page = 1,
  int? afterId, // 🔥 جديد
}) async {
  final queryParams = {
    'page': page,
    ..._cacheBust,
  };
  if (afterId != null) {
    queryParams['after_id'] = afterId; // 🔥 إضافة after_id
  }
  return await _dio.get(
    ApiConstants.conversationMessages(conversationId),
    queryParameters: queryParams,
  );
}
  Future<Response> sendMessage(
    int conversationId, {
    required String body,
    required String clientUuid,
    List<String>? imageFiles,
  }) async {
    FormData formData = FormData.fromMap({
      'body': body,
      'client_uuid': clientUuid,
    });

    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (int i = 0; i < imageFiles.length; i++) {
        formData.files.add(
          MapEntry(
            'images[$i]',
            await MultipartFile.fromFile(imageFiles[i]),
          ),
        );
      }
    }

    return await _dio.post(
      ApiConstants.sendMessage(conversationId),
      data: formData,
    );
  }

  Future<Response> deleteMessage(
    int conversationId,
    int messageId,
  ) async {
    return await _dio.delete(
      ApiConstants.deleteMessage(conversationId, messageId),
    );
  }

  Future<Response> markMessagesAsRead(int conversationId) async {
    return await _dio.patch(
      '${ApiConstants.conversationMessages(conversationId)}/mark-read',
    );
  }
}