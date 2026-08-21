import 'dart:async';
import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:sportifo_app/core/storage/local_storage.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'dart:developer' as dev;

/// الحدث يلي بيوصل من الـ WebSocket
class ChatWebSocketEvent {
  final String eventName;
  final Map<String, dynamic> data;
  final int conversationId;

  ChatWebSocketEvent(this.eventName, this.data, this.conversationId);
}

class ChatWebSocketService {
  static final ChatWebSocketService _instance = ChatWebSocketService._internal();
  factory ChatWebSocketService() => _instance;
  ChatWebSocketService._internal();

  PusherChannelsClient? _client;

  final Map<int, Channel> _channels = {};
  final Map<int, StreamSubscription> _eventSubs = {};
  final Map<int, int> _refCount = {};

  final LocalStorage _localStorage = getIt<LocalStorage>();

  bool _isConnected = false;
  bool _isInitialized = false;

  // 🔥 Broadcast Streams — أكتر من مستمع بيقدر يسمع
  final _eventController = StreamController<ChatWebSocketEvent>.broadcast();
  final _connectionController = StreamController<String>.broadcast();

  Stream<ChatWebSocketEvent> get events => _eventController.stream;
  Stream<String> get connectionState => _connectionController.stream;

  static const String appKey = 'xciiem3ixu10pjwb6pbr';
    static const String host = '172.29.6.72';  // ← بدّل IP
  static const int wsPort = 8080;  

  bool get isConnected => _isConnected;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final options = PusherChannelsOptions.fromHost(
      scheme: 'ws',
      host: host,
      key: appKey,
      port: wsPort,
    );

    _client = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (exception, trace, refresh) {
        dev.log('❌ WebSocket Error: $exception');
        _isConnected = false;
        _connectionController.add('ERROR');
        refresh();
      },
    );

    _client!.onConnectionEstablished.listen((_) {
      _isConnected = true;
      _connectionController.add('CONNECTED');
      dev.log('🟢 WebSocket Connected');
      for (final entry in _channels.entries.toList()) {
        entry.value.subscribe();
      }
    });

    await _client!.connect();
  }

  Future<void> subscribeToChannel(int conversationId) async {
    final presenceName = 'presence-conversation.$conversationId';

    if (_channels.containsKey(conversationId)) {
      _refCount[conversationId] = (_refCount[conversationId] ?? 1) + 1;
      dev.log('📡 RefCount for $conversationId: ${_refCount[conversationId]}');
      return;
    }
    if (_client == null) return;

    final token = _localStorage.getToken() ?? '';

    try {
      dev.log('🔐 Subscribing to: $presenceName');

      final presenceChannel = _client!.presenceChannel(
        presenceName,
        authorizationDelegate:
            EndpointAuthorizableChannelTokenAuthorizationDelegate
                .forPresenceChannel(
          authorizationEndpoint:
              Uri.parse('https://$host/broadcasting/auth'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final sub = presenceChannel.bindToAll().listen((event) {
        _handleEvent(event, conversationId);
      });

      presenceChannel.subscribe();
      _channels[conversationId] = presenceChannel;
      _eventSubs[conversationId] = sub;
      _refCount[conversationId] = 1;

      dev.log('📡 Subscribed to PRESENCE: $presenceName');
    } catch (e) {
      dev.log('❌ Presence channel failed: $e');
    }
  }

  void _handleEvent(ChannelReadEvent event, int conversationId) {
    dev.log('📩 RAW EVENT: ${event.name}');

    Map<String, dynamic> eventData;

    if (event.data is Map<String, dynamic>) {
      eventData = event.data as Map<String, dynamic>;
    } else if (event.data is String) {
      try {
        final parsed = jsonDecode(event.data as String);
        if (parsed is Map<String, dynamic>) {
          eventData = parsed;
        } else {
          dev.log('❌ Decoded data is not Map: ${parsed.runtimeType}');
          return;
        }
      } catch (e) {
        dev.log('❌ Failed to parse JSON: $e');
        return;
      }
    } else {
      dev.log('⚠️ Unknown data type: ${event.data.runtimeType}');
      return;
    }

    dev.log('✅ Event processed: ${event.name}');
    _eventController.add(ChatWebSocketEvent(event.name, eventData, conversationId));
  }

  Future<void> unsubscribeFromChannel(int? conversationId) async {
    if (conversationId == null) {
      for (final sub in _eventSubs.values) {
        await sub.cancel();
      }
      for (final ch in _channels.values) {
        ch.unsubscribe();
      }
      _eventSubs.clear();
      _channels.clear();
      _refCount.clear();
      dev.log('🔌 Unsubscribed from ALL channels');
      return;
    }

    final currentCount = _refCount[conversationId] ?? 0;
    if (currentCount <= 1) {
      _eventSubs[conversationId]?.cancel();
      _channels[conversationId]?.unsubscribe();
      _eventSubs.remove(conversationId);
      _channels.remove(conversationId);
      _refCount.remove(conversationId);
      dev.log('🔌 Unsubscribed from channel: $conversationId');
    } else {
      _refCount[conversationId] = currentCount - 1;
      dev.log('📡 RefCount for $conversationId: ${_refCount[conversationId]}');
    }
  }

  Future<void> sendTypingEvent(int conversationId, int userId) async {
    if (!_isConnected) return;
    final channel = _channels[conversationId];
    if (channel is! PresenceChannel) return;

    try {
      channel.trigger(
        eventName: 'client-typing',
        data: {'user_id': userId},
      );
    } catch (e) {
      dev.log('❌ Typing failed: $e');
    }
  }

  Future<void> disconnect() async {
    await _eventController.close();
    await _connectionController.close();
    for (final sub in _eventSubs.values) {
      await sub.cancel();
    }
    for (final ch in _channels.values) {
      ch.unsubscribe();
    }
    _client?.dispose();
    _client = null;
    _isConnected = false;
    _isInitialized = false;
    _channels.clear();
    _eventSubs.clear();
    _refCount.clear();
    dev.log('🔌 Global Disconnected');
  }
}