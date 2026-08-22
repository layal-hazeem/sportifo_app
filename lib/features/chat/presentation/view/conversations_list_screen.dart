import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/services/chat_websocket_service.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/widgets/wave_app_bar.dart';
import '../../data/models/message_model.dart';
import '../view_model/conversations_cubit.dart';
import '../view_model/conversations_state.dart';
import '../widgets/conversation_tile.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({Key? key}) : super(key: key);

  @override
  State<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  final ChatWebSocketService _webSocketService = getIt<ChatWebSocketService>();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _initWebSocket();
    _fetchAndSubscribe();
  }

   Future<void> _initWebSocket() async {
    await _webSocketService.init();
    
    _webSocketService.events.listen((event) {
      if (!mounted) return;
      _handleRealtimeEvent(event.eventName, event.data, event.conversationId);
    });
    
    _webSocketService.connectionState.listen((state) {
      if (state == 'CONNECTED' && mounted) {
        _resyncAllConversations();
      }
    });
  }

  void _handleRealtimeEvent(
      String eventName, Map<String, dynamic> data, int conversationId) {
    final cubit = context.read<ConversationsCubit>();

    switch (eventName) {
      case 'message.sent':
        final messageData = data['message'] as Map<String, dynamic>?;
        if (messageData == null) return;
        final message = MessageModel.fromJson(messageData);
        cubit.updateConversationFromRealtime(conversationId, message);
        break;

      case 'message.read':
      case 'message.deleted':
        cubit.fetchConversations(); 
        break;
    }
  }

  Future<void> _fetchAndSubscribe() async {
    final cubit = context.read<ConversationsCubit>();
    await cubit.fetchConversations();

    final state = cubit.state;
    if (state is ConversationsLoaded) {
      for (final conv in state.conversations) {
        await _webSocketService.subscribeToChannel(conv.id);
      }
    }
  }

  void _resyncAllConversations() {
    context.read<ConversationsCubit>().fetchConversations();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const WaveAppBar(title: 'Chats', showBackButton: true),
      body: BlocBuilder<ConversationsCubit, ConversationsState>(
        builder: (context, state) {
          if (state is ConversationsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBtn));
          }

          if (state is ConversationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('حدث خطأ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(state.message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _fetchAndSubscribe,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBtn),
                  ),
                ],
              ),
            );
          }

          if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text("No conversations yet.", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _fetchAndSubscribe,
              color: AppColors.primaryBtn,
              child: ListView.separated(
                itemCount: state.conversations.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final conversation = state.conversations[index];
                  return ConversationTile(
                    conversation: conversation,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.chatDetail,
                        arguments: {
                          'conversationId': conversation.id,
                          'otherParticipantName': conversation.otherParticipant.name,
                          'otherParticipantImage': conversation.otherParticipant.profilePic,
                          'subscriptionType': conversation.subscriptionType,
                          'availableNow': conversation.availableNow,
                        },
                      ).then((_) {
                        context.read<ConversationsCubit>().fetchConversations();
                      });
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
