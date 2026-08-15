import 'dart:async';
import 'dart:convert'; // 🔥 ADD THIS
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:sportifo_app/core/storage/local_storage.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'dart:developer' as dev;

typedef OnEventCallback = void Function(String eventName, Map<String, dynamic> data);
typedef OnConnectionChange = void Function(String currentState);

class ChatWebSocketService {
  static final ChatWebSocketService _instance = ChatWebSocketService._internal();
  factory ChatWebSocketService() => _instance;
  ChatWebSocketService._internal();

  PusherChannelsClient? _client;
  
  Channel? _currentChannel;
  PresenceChannel? _presenceChannel;
  
  final LocalStorage _localStorage = getIt<LocalStorage>();

  bool _isConnected = false;
  String? _currentChannelName;
  OnEventCallback? _onEvent;
  OnConnectionChange? _onConnectionChange;

  StreamSubscription? _connectionSub;
  StreamSubscription? _eventSub;

  static const String appKey = 'xciiem3ixu10pjwb6pbr';
  static const String host = '192.168.1.106';
  static const int wsPort = 8080;

  Future<void> init({
    required OnEventCallback onEvent,
    required OnConnectionChange onConnectionChange,
  }) async {
    if (_client != null) return;

    _onEvent = onEvent;
    _onConnectionChange = onConnectionChange;

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
        _onConnectionChange?.call('ERROR');
        refresh();
      },
    );

    _connectionSub = _client!.onConnectionEstablished.listen((_) {
      _isConnected = true;
      _onConnectionChange?.call('CONNECTED');
      dev.log('🟢 WebSocket Connected');
      if (_currentChannel != null) {
        _currentChannel!.subscribeIfNotUnsubscribed();
      }
    });

    await _client!.connect();
  }

  Future<void> subscribeToChannel(int conversationId) async {
    final presenceName = 'presence-conversation.$conversationId';
    
    if (_currentChannelName == presenceName) return;
    if (_client == null) return;

    final token = _localStorage.getToken() ?? '';

    try {
      dev.log('🔐 Trying presence channel: $presenceName');
      
      _presenceChannel = _client!.presenceChannel(
        presenceName,
        authorizationDelegate: EndpointAuthorizableChannelTokenAuthorizationDelegate
            .forPresenceChannel(
          authorizationEndpoint: Uri.parse('http://$host:8000/broadcasting/auth'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      
      _currentChannel = _presenceChannel;
      
      _eventSub = _currentChannel!.bindToAll().listen((event) {
        _handleEvent(event, presenceName);
      });
      
      _currentChannel!.subscribe();
      _currentChannelName = presenceName;
      dev.log('📡 Subscribed to PRESENCE: $presenceName');
      
    } catch (e) {
      dev.log('❌ Presence channel failed: $e');
    }
  }

  // 🔥🔥🔥 FIXED METHOD - Handle String JSON events
  void _handleEvent(ChannelReadEvent event, String channelName) {
    dev.log('📩 RAW EVENT: ${event.name}');
    
    Map<String, dynamic> eventData;
    
    // Handle Map data directly
    if (event.data is Map<String, dynamic>) {
      eventData = event.data as Map<String, dynamic>;
    } 
    // Handle JSON String data (THIS WAS THE MISSING PART!)
    else if (event.data is String) {
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
    } 
    else {
      dev.log('⚠️ Unknown data type: ${event.data.runtimeType}');
      return;
    }
    
    dev.log('✅ Event processed: ${event.name}');
    _onEvent?.call(event.name, eventData);
  }

  Future<void> unsubscribeFromChannel() async {
    _currentChannel?.unsubscribe();
    await _eventSub?.cancel();
    _eventSub = null;
    _currentChannel = null;
    _presenceChannel = null;
    _currentChannelName = null;
    dev.log('🔌 Unsubscribed');
  }

  Future<void> sendTypingEvent(int conversationId, int userId) async {
    if (!_isConnected || _presenceChannel == null) return;
    try {
      _presenceChannel!.trigger(
        eventName: 'client-typing',
        data: {'user_id': userId},
      );
    } catch (e) {
      dev.log('❌ Typing failed: $e');
    }
  }

  Future<void> disconnect() async {
    await _connectionSub?.cancel();
    await _eventSub?.cancel();
    _client?.dispose();
    _client = null;
    _isConnected = false;
    _currentChannel = null;
    _presenceChannel = null;
    _currentChannelName = null;
    dev.log('🔌 Disconnected');
  }

  bool get isConnected => _isConnected;
}