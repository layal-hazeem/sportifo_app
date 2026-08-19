import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/helpers/snack_bar_utils.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/%20ads/presentation/view_model/ads_cubit.dart';
import 'package:sportifo_app/features/ai_chat/presentation/view/ai_chat_screen.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:sportifo_app/features/home/presentation/view/trainee_screen.dart';
import 'package:sportifo_app/features/home/presentation/view/coach_screen.dart';
import 'package:sportifo_app/features/home/presentation/view_model/coach_home_cubit.dart';
import 'package:sportifo_app/features/home/presentation/view_model/home_view_model.dart';
import 'package:sportifo_app/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:sportifo_app/features/home/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:sportifo_app/features/home/presentation/widgets/custom_drawer.dart';
import 'package:sportifo_app/features/subscriptions/presentation/view_model/subscription_cubit.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:sportifo_app/features/subscriptions/presentation/view/subscriptions_screen.dart';
import 'package:sportifo_app/features/trainees/presentation/view/trainees_screen.dart';
import 'package:sportifo_app/features/trainees/presentation/view_model/trainees_cubit.dart';
import 'package:sportifo_app/features/workout/presentation/view_model/categories_cubit/categories_cubit.dart';
import 'package:sportifo_app/features/workout/presentation/view_model/saved_exercises/saved_exercises_cubit.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../../core/di/service_locator.dart';
import '../../../progress/presentation/view/progress_screen.dart';
import '../../../my_plans(user)/presentation/view/my_plans_screen.dart';
import '../../../my_plans(user)/presentation/view_model/my_plans_cubit.dart';
import '../../../workout/presentation/view/workout_type_screen.dart';
import 'package:sportifo_app/core/enum/drawer_enum.dart';
import 'package:flutter/services.dart';

// ⚠️ احرصي على استيراد ملف الـ AppSnackBar الخاص بكِ
// import 'package:sportifo_app/core/widgets/app_snack_bar.dart';

HomeViewModel homeViewModel = HomeViewModel();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DrawerItem selectedDrawerItem = DrawerItem.profile;
  
  // 🔥 متغير لتتبع زمن الضغط على زر الرجوع
  DateTime? _lastPressedAt;

  List<Widget> _getTraineeScreens() {
    return [
      const ProgressScreen(),
      BlocProvider.value(
        value: getIt<MyPlansCubit>(),
        child: const MyPlansScreen(),
      ),
      const TraineeScreen(),
      BlocProvider(
        create: (context) => getIt<CategoriesCubit>(),
        child: const WorkoutTypeScreen(),
      ),
      const AiChatScreen(),
    ];
  }

  List<Widget> _getCoachScreens() {
    return [
      BlocProvider(
        create: (context) => getIt<SubscriptionCubit>()..getSubscriptions(),
        child: const SubscriptionsScreen(),
      ),
      BlocProvider(
        create: (context) => getIt<TraineesCubit>()..getCoachTrainees(),
        child: const TraineesScreen(),
      ),
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => getIt<AdsCubit>()..fetchAds()),
          BlocProvider(
            create: (context) => getIt<CoachHomeCubit>()..loadHomeData(),
          ),
        ],
        child: CoachHomeScreen(
          onNavigate: (index) {
            homeViewModel.changeTab(index);
          },
        ),
      ),
      BlocProvider(
        create: (context) => getIt<CategoriesCubit>(),
        child: const WorkoutTypeScreen(),
      ),
      const AiChatScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LogoutCubit>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()..getProfile()),
        BlocProvider.value(value: getIt<SavedExercisesCubit>()),
      ],
      child: BlocListener<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }

          if (state is LogoutError) {
            // ✅ استخدام AppSnackBar عند حدوث خطأ في تسجيل الخروج
            AppSnackBar.show(
              context,
              message: state.message,
              type: SnackBarType.error,
            );
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading ||
                profileState is ProfileInitial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBtn),
                ),
              );
            }

            if (profileState is ProfileFailure) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(profileState.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ProfileCubit>().getProfile(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBtn,
                        ),
                        child: Text(
                          l10n.retry,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (profileState is ProfileSuccess) {
              final profile = profileState.profileModel;
              final isCoach = profile.role == 'coach';

              final screens = isCoach
                  ? _getCoachScreens()
                  : _getTraineeScreens();

              return ListenableBuilder(
                listenable: homeViewModel,
                builder: (context, child) {
                  final bool isHomeScreen = homeViewModel.currentIndex == 2;

                  // 🔥 تغليف الـ Scaffold بـ PopScope لإدارة زر الرجوع
                  return PopScope(
                    canPop: false, // نمنع الخروج التلقائي
                    onPopInvokedWithResult: (didPop, result) {
                      if (didPop) return;

                      final now = DateTime.now();
                      const backButtonInterval = Duration(seconds: 2);

                      // إذا كانت هذه الضغطة الأولى أو مضى أكثر من ثانيتين على الضغطة المسبقة
                      if (_lastPressedAt == null ||
                          now.difference(_lastPressedAt!) > backButtonInterval) {
                        _lastPressedAt = now;

                        // ✅ استخدام AppSnackBar كـ Warning للتنبيه عند محاولة الخروج
                        AppSnackBar.show(
                          context,
                          message: l10n.press_again_to_exit,
                          type: SnackBarType.warning,
                        );
                      } else {
                        // الضغطة الثانية خلال أقل من ثانيتين -> الخروج من التطبيق
                        SystemNavigator.pop();
                      }
                    },
                    child: Scaffold(
                      drawer: CustomDrawer(
                        selectedItem: selectedDrawerItem,
                        onItemTap: (item) {
                          setState(() {
                            selectedDrawerItem = item;
                          });
                        },
                      ),
                      appBar: CustomAppBar(
                        currentIndex: homeViewModel.currentIndex,
                        userName: profile.firstName,
                        isCoach: isCoach,
                        onHomeTap: () {
                          homeViewModel.changeTab(2);
                        },
                      ),
                      body: IndexedStack(
                        index: homeViewModel.currentIndex,
                        children: screens,
                      ),
                      bottomNavigationBar: isHomeScreen
                          ? BottomNavigationBar(
                              currentIndex: homeViewModel.currentIndex,
                              onTap: (index) {
                                homeViewModel.changeTab(index);
                              },
                              type: BottomNavigationBarType.fixed,
                              showSelectedLabels: false,
                              backgroundColor: AppColors.background,
                              elevation: 0,
                              selectedItemColor: AppColors.primaryBtn,
                              unselectedItemColor: AppColors.hintText,
                              items: [
                                CustomBottomNavBar.build(
                                  icon: isCoach
                                      ? Icons.workspace_premium_rounded
                                      : Icons.show_chart,
                                  label: isCoach ? l10n.sub : l10n.progress,
                                  isSelected: homeViewModel.currentIndex == 0,
                                ),
                                CustomBottomNavBar.build(
                                  icon: isCoach
                                      ? Icons.groups_rounded
                                      : Icons.calendar_today,
                                  label: isCoach ? l10n.trainees : l10n.myPlans,
                                  isSelected: homeViewModel.currentIndex == 1,
                                ),
                                CustomBottomNavBar.build(
                                  icon: Icons.home,
                                  label: l10n.home,
                                  isSelected: homeViewModel.currentIndex == 2,
                                ),
                                CustomBottomNavBar.build(
                                  icon: Icons.fitness_center_outlined,
                                  label: l10n.workouts,
                                  isSelected: homeViewModel.currentIndex == 3,
                                ),
                                CustomBottomNavBar.build(
                                  icon: Icons.chat,
                                  svgIcon: 'assets/icons/bot-message-square.svg',
                                  label: l10n.chatAI,
                                  isSelected: homeViewModel.currentIndex == 4,
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}