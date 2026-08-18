import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:developer';
import 'dart:convert';
import 'dart:io'; // 👈 لمعرفة نوع النظام برمجياً (Android / iOS)
import 'package:url_launcher/url_launcher.dart';
import 'package:sportifo_app/core/di/service_locator.dart';

import '../storage/local_storage.dart';

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

  // ✅ رابط الباك
  static const String _baseUrl = 'https://sportifo.moayadismail.com/api/app';

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

      // ✅ لما يتجدد التوكن من فايربيز، نحدثه بالسيرفر إذا كان اليوزر مسجل دخول
      _fcm.onTokenRefresh.listen((newToken) async {
        log("🔄 Token refreshed: $newToken");
        await registerDeviceToBackend();
      });

      // ✅ Foreground Message
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log("🔔 Foreground Message: ${message.notification?.title}");
        log("📦 Data: ${message.data}");
        _showLocalNotification(message);
      });

      // ✅ الضغط على الإشعار بالخلفية
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("👆 User tapped notification from background");
        log("🔗 deep_link: ${message.data['deep_link']}");
        _handleDeepLink(message.data['deep_link']);
      });

      // ✅ فتح التطبيق من حالة الإغلاق عبر الإشعار
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        log("🚀 App opened from terminated state via notification");
        _handleDeepLink(initialMessage.data['deep_link']);
      }

      // 🔥 محاولة المزامنة فور فتح التطبيق (ستعمل فقط إذا كان مسجلاً دخول)
      await registerDeviceToBackend();

    } else {
      log('User declined or has not accepted permission');
    }
  }

  // ✅ دالة المزامنة المخصصة حصراً للمستخدمين المسجلين (User Auth Only)
  Future<void> registerDeviceToBackend() async {
    try {
      final localStorage = getIt<LocalStorage>();

      // 🔍 1. فحص هل المستخدم مسجل دخول حالياً؟
      final String? userAuthToken = localStorage.getToken();

      if (userAuthToken == null || userAuthToken.isEmpty) {
        log("ℹ️ User is NOT logged in. Skipping FCM token registration.");
        return; // ⛔ خروج فوراً بدون إرسال أي Request
      }

      // 2. جلب FCM Token الحالي
      String? token = await _fcm.getToken();
      if (token == null) return;

      final String locale = localStorage.getLanguage() ?? 'en';
      final String platform = Platform.isAndroid ? 'android' : 'ios';

      log("📤 Sending FCM token to backend for AUTHENTICATED USER...");

      // 3. إرسال الطلب مع إرفاق Bearer Token الخاص بهوية المستخدم
      final response = await http.post(
        Uri.parse('$_baseUrl/guest/device'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $userAuthToken', // 🔥 هوية المستخدم المسجل
        },
        body: jsonEncode({
          'fcm_token': token,
          'platform': platform,
          'locale': locale,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        log("✅ Device registered successfully for User!");
        log("🎯 Response: ${data['message']}");
      } else {
        log("❌ Failed: ${response.statusCode}");
        log("❌ Response: ${response.body}");
      }
    } catch (e) {
      log("❌ Error registering device: $e");
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

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    _localNotifications.resolvePlatformSpecificImplementation
    <AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.deleteNotificationChannel(
        channelId: 'sportifo_channel');
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