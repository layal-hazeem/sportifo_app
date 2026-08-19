import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/notifications/presentation/view_model/notifications_cubit.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';

// ⚠️ [جديد] استدعاء الـ Background Handler هون بالـ main
import 'core/services/notification_service.dart'
    show firebaseMessagingBackgroundHandler;

import 'core/di/service_locator.dart';
import 'core/localization/locale_cubit.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/app_router.dart';
import 'l10n/app_localizations.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 1. تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 2. تسجيل Background Handler قبل أي شي
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);


  // باقي الخدمات
  await Hive.initFlutter();
  await setupServiceLocator();


  // 🔥 3. تشغيل خدمة الإشعارات
  await NotificationService().init();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 حولنا الـ BlocProvider لـ MultiBlocProvider لحتى نحط الإشعارات
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<LocaleCubit>()),
        // 🔥 إضافة كيوبيت الإشعارات ليكون متاحاً في كل التطبيق وزر الجرس
        BlocProvider(create: (context) => getIt<NotificationsCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return NeumorphicApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Sportifo',
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.generateRoute,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            locale: locale,
            themeMode: ThemeMode.light,
            theme: const NeumorphicThemeData(
              baseColor: Color(0xFFF2F2F2),
              lightSource: LightSource.topLeft,
              depth: 10,
            ),
          );
        },
      ),
    );
  }
}