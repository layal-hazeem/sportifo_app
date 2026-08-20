import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'local_message.g.dart';

@HiveType(typeId: 1)
class LocalMessage extends Equatable {
  @HiveField(0)
  final String clientUuid;
  
  @HiveField(1)
  final int conversationId;
  
  @HiveField(2)
  final String? body;
  
  @HiveField(3)
  final List<String>? imagePaths;
  
  @HiveField(4)
  final String status;
  
  @HiveField(5)
  final DateTime createdAt;

  const LocalMessage({
    required this.clientUuid,
    required this.conversationId,
    this.body,
    this.imagePaths,
    this.status = 'pending',
    required this.createdAt,
  });

  LocalMessage copyWith({
    String? clientUuid,
    int? conversationId,
    String? body,
    List<String>? imagePaths,
    String? status,
    DateTime? createdAt,
  }) {
    return LocalMessage(
      clientUuid: clientUuid ?? this.clientUuid,
      conversationId: conversationId ?? this.conversationId,
      body: body ?? this.body,
      imagePaths: imagePaths ?? this.imagePaths,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [clientUuid, conversationId, body, status, createdAt];
}