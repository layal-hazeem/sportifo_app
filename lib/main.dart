import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sportifo_app/core/models/local_message.dart';
import 'package:sportifo_app/core/services/pending_messages_service.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/theme_cubit.dart';

import 'features/notifications/presentation/view_model/notifications_cubit.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';

// استيراد الـ Background Handler
import 'core/services/notification_service.dart'
    show firebaseMessagingBackgroundHandler;

import 'core/di/service_locator.dart';
import 'core/localization/locale_cubit.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/app_router.dart';
import 'l10n/app_localizations.dart';

// استيراد خدمات الاتصال
import 'core/services/connectivity_service.dart';
import 'core/connectivity/presentation/view_model/connectivity_cubit.dart';
import 'core/connectivity/presentation/widgets/app_connectivity_wrapper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Firebase وتسجيل الـ Background Handler
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 2. تهيئة Hive
  await Hive.initFlutter();
  Hive.registerAdapter(LocalMessageAdapter());
  await Hive.openBox('settings_box');

  // 3. تهيئة Service Locator والـ Pending Messages
  await setupServiceLocator();
  await getIt<PendingMessagesService>().init();

  // 4. تشغيل خدمة الإشعارات
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<LocaleCubit>()),
        BlocProvider(create: (context) => getIt<NotificationsCubit>()),
        BlocProvider(create: (context) => ThemeCubit()),        // 👈 تم إبقاء ThemeCubit
        BlocProvider.value(value: getIt<ConnectivityCubit>()), // 👈 موجود في الكود الثاني
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return Directionality(
            textDirection: locale.languageCode == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: AppConnectivityWrapper(
              child: BlocBuilder<ThemeCubit, ThemeMode>(
                // 🔥 إضافة BlocBuilder للثيم
                builder: (context, themeMode) {
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
                    supportedLocales: const [Locale('en'), Locale('ar')],
                    locale: locale,
                    themeMode: themeMode, // 👈 ربط الثيم ديناميكياً
                    theme: NeumorphicThemeData(
                      baseColor: AppColors.lightBackground,
                      defaultTextColor: AppColors.lightText,
                      accentColor: AppColors.primaryBtn,
                      lightSource: LightSource.topLeft,
                      depth: 10,
                    ),
                    darkTheme: NeumorphicThemeData(
                      baseColor: AppColors.darkBackground,
                      defaultTextColor: AppColors.darkText,
                      accentColor: AppColors.primaryBtn,
                      lightSource: LightSource.topLeft,
                      depth: 10,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}