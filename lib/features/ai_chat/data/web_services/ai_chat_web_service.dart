import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class AiChatWebService {
  final Dio dio;

  AiChatWebService(this.dio);

  Future<Response> getChatHistory({Options? options}) async {
    return await dio.get(ApiConstants.aiChatMessages, options: options);
  }


  Future<Response> sendMessage(
    String message, {
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.post(
      ApiConstants.aiChatMessages,
      data: FormData.fromMap({'message': message}),
      options: options,
      cancelToken: cancelToken,
    );
  }
}
