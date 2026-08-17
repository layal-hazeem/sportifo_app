import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("🔔 Background Message: ${message.notification?.title}");
  log("📦 Data: ${message.data}");

  await NotificationService().showBackgroundNotification(message);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission for notifications');

      try {
        String? token = await _fcm.getToken();
        log("====================================");
        log("🔥 FCM Token: $token");
        log("====================================");
      } catch (e) {
        log("Error getting FCM token: $e");
      }

      await _initLocalNotifications();

      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log("🔔 Foreground Message: ${message.notification?.title}");
        log("📦 Data: ${message.data}");
        _showLocalNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("👆 User tapped notification from background");
        log("🔗 deep_link: ${message.data['deep_link']}");
        _handleDeepLink(message.data['deep_link']);
      });

      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        log("🚀 App opened from terminated state via notification");
        _handleDeepLink(initialMessage.data['deep_link']);
      }
    } else {
      log('User declined or has not accepted permission');
    }
  }

  Future<void> showBackgroundNotification(RemoteMessage message) async {
    await _initLocalNotifications();
    await _showLocalNotification(message);
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("👆 Notification tapped: ${response.payload}");
        _handleDeepLink(response.payload);
      },
    );

    // ✅ السطر المصحح - في < و > بالشكل الصح
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation
   <AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.deleteNotificationChannel(channelId: 'sportifo_channel');
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'sportifo_channel',
        'Sportifo Notifications',
        description: 'Sportifo app notifications',
        importance: Importance.high,
      ),
    );

    log("✅ Notification channel created fresh");
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final String? imageUrl = message.data['icon_url'] ?? message.data['icon'];

    ByteArrayAndroidBitmap? largeIcon;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final Uint8List imageBytes = await _downloadImage(imageUrl)
            .timeout(const Duration(seconds: 5));
        largeIcon = ByteArrayAndroidBitmap(imageBytes);
        log("✅ Image loaded successfully");
      } catch (e) {
        log("❌ Error loading notification image: $e");
      }
    }

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'sportifo_channel',
      'Sportifo Notifications',
      channelDescription: 'Sportifo app notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: largeIcon,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id: message.hashCode & 0x7FFFFFFF,
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      notificationDetails: notificationDetails,
      payload: message.data['deep_link'],
    );
  }

  Future<Uint8List> _downloadImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  void _handleDeepLink(String? deepLink) {
    if (deepLink == null || deepLink.isEmpty || deepLink == '/') return;

    log("🔗 Handling deep link: $deepLink");

    if (deepLink.startsWith('http://') || deepLink.startsWith('https://')) {
      _launchUrl(deepLink);
      return;
    }

    log("📱 Internal deep link: $deepLink");
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      log("❌ Could not launch: $url");
    }
  }
}