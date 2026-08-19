import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/theme_cubit.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 1. تهيئة Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔥 2. تسجيل Background Handler قبل أي شي
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // باقي الخدمات
  await Hive.initFlutter();

  // 🔥 فتح صندوق الإعدادات
  await Hive.openBox('settings_box');

  await setupServiceLocator();

  // 🔥 3. تشغيل خدمة الإشعارات
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
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          // 🔥 استخدام BlocBuilder للـ ThemeCubit لتوفير متغير themeMode والتبديل ديناميكياً
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return NeumorphicApp(
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
                themeMode: themeMode, // 👈 تم حل الخطأ بربطه هنا
                theme: NeumorphicThemeData(
                  baseColor: AppColors.lightBackground,
                  defaultTextColor: AppColors.lightText,
                  accentColor: AppColors.primaryBtn,
                ),
                darkTheme: NeumorphicThemeData(
                  baseColor: AppColors.darkBackground,
                  defaultTextColor: AppColors.darkText,
                  accentColor: AppColors.primaryBtn,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
