import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:sportifo_app/core/di/service_locator.dart';

import '../../features/ ads/presentation/view_model/ads_cubit.dart';
import '../../features/ ads/presentation/view_model/ads_state.dart';
import '../../features/ ads/presentation/widgets/ads_details_bottom_sheet.dart';
import '../../features/my_plans(user)/presentation/view/my_plans_screen.dart';
import '../../main.dart';
import '../routes/app_routes.dart';
import '../storage/local_storage.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Background Message Received: ${message.notification?.title}");
  await NotificationService().showBackgroundNotification(message);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String _baseUrl = 'https://sportifo.moayadismail.com/api/app';
  Map<String, dynamic>? pendingNotificationData;

  Future<void> init() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted notification permissions.');

      try {
        String? token = await _fcm.getToken();
        log("FCM Token: $token");
      } catch (e) {
        log("Error getting FCM token: $e");
      }

      await _initLocalNotifications();

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      _fcm.onTokenRefresh.listen((newToken) async {
        log("Token refreshed.");
        await registerDeviceToBackend();
      });

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log("Foreground Message Received.");
        _showLocalNotification(message);
      });

      // Listen for messages tapped in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("Notification tapped from background.");
        handleNotificationNavigation(message.data);
      });

      // Handle app opened from terminated state via notification
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        log("App opened from terminated state via notification.");
        Future.delayed(const Duration(milliseconds: 500), () {
          pendingNotificationData = initialMessage.data;
        });
      }

      await registerDeviceToBackend();
    }
  }

  Future<void> registerDeviceToBackend() async {
    try {
      final localStorage = getIt<LocalStorage>();
      final String? userAuthToken = localStorage.getToken();

      if (userAuthToken == null || userAuthToken.isEmpty) return;

      String? token = await _fcm.getToken();
      if (token == null) return;

      final String locale = localStorage.getLanguage();
      final String platform = Platform.isAndroid ? 'android' : 'ios';

      final response = await http.post(
        Uri.parse('$_baseUrl/guest/device'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $userAuthToken',
        },
        body: jsonEncode({
          'fcm_token': token,
          'platform': platform,
          'locale': locale,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Device registered successfully.");
      } else {
        log("Failed to register device: ${response.statusCode}");
      }
    } catch (e) {
      log("Error registering device: $e");
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
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!);
            handleNotificationNavigation(data);
          } catch (e) {
            log("Error parsing payload: $e");
          }
        }
      },
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.deleteNotificationChannel(channelId: 'sportifo_channel');
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'sportifo_channel',
        'Sportifo Notifications',
        description: 'Sportifo app notifications',
        importance: Importance.high,
      ),
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final String? imageUrl = message.data['icon_url'] ?? message.data['icon'];
    final payload = jsonEncode(message.data);

    ByteArrayAndroidBitmap? largeIcon;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final Uint8List imageBytes =
        await _downloadImage(imageUrl).timeout(const Duration(seconds: 5));
        largeIcon = ByteArrayAndroidBitmap(imageBytes);
      } catch (e) {
        log("Error loading image: $e");
      }
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
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
      payload: payload,

    );
  }

  Future<Uint8List> _downloadImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  // Handle navigation based on notification data payload
  void handleNotificationNavigation(Map<String, dynamic> data) {
    final eventType = data['event_type']?.toString().toLowerCase();
    final model = data['model']?.toString().toLowerCase();
    final modelId = data['model_id'];
    final deepLink = data['deep_link']?.toString();

    if (eventType == 'external' && deepLink != null && deepLink.isNotEmpty) {
      _launchExternalUrl(deepLink);
      return;
    }

    if (eventType == 'plan_created' ||
        eventType == 'coach_created_plan' ||
        eventType == 'user_created_plan') {
      MyPlansScreen.activeTabNotifier.value = 0;
      navigatorKey.currentState?.pushNamed(AppRoutes.myPlans);
      return;
    }

    switch (model) {
      case 'home':
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.home,
              (route) => false,
        );
        break;
      case 'plan':
      case 'my_plan':
      case 'my_plans':
      case 'coach_plan':
        MyPlansScreen.activeTabNotifier.value = 0;
        navigatorKey.currentState?.pushNamed(AppRoutes.myPlans);
        break;
      case 'user_profile':
        navigatorKey.currentState?.pushNamed(AppRoutes.getProfile);
        break;
      case 'coach_profile':
      case 'coach':
        if (modelId != null) {
          final coachId = int.tryParse(modelId.toString());
          if (coachId != null) {
            navigatorKey.currentState?.pushNamed(
              AppRoutes.coach,
              arguments: coachId,
            );
          }
        }
        break;
      case 'ad':
        _handleAdNavigation(modelId);
        break;
    // 💬 حالة إشعار المحادثة الفورية
      case 'chat':
      case 'message':
      case 'conversation':
        if (modelId != null) {
          final conversationId = int.tryParse(modelId.toString());

          if (conversationId != null) {
            // 🔥 جلب بيانات الطرف الآخر من الإشعار (إذا كان الباك إند يرسلها)
            // إذا لم يرسلها، نضع قيمة افتراضية مثل "New Message"
            final senderName = data['sender_name']?.toString() ?? 'New Message';
            final senderImage = data['sender_image']?.toString();
            final subType = data['subscription_type']?.toString();

            navigatorKey.currentState?.pushNamed(
              AppRoutes.chatDetail, // 👈 مسار الشات
              arguments: {
                'conversationId': conversationId,
                'otherParticipantName': senderName,
                'otherParticipantImage': senderImage,
                'subscriptionType': subType,
              },
            );
          }
        }
        break;
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleAdNavigation(dynamic adId) {
    if (adId == null) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    final id = int.tryParse(adId.toString());
    final adsCubit = getIt<AdsCubit>();

    if (adsCubit.state is AdsSuccess) {
      final adsList = (adsCubit.state as AdsSuccess).ads;
      try {
        final targetAd = adsList.firstWhere((ad) => ad.id == id);
        AdDetailsBottomSheet.show(context, targetAd);
      } catch (e) {
        log("Ad with id $id not found locally.");
      }
    }
  }
}