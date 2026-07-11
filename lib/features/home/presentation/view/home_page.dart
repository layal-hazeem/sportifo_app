import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/auth/data/repository/auth_repository.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:sportifo_app/features/home/presentation/view/trainee_screen.dart';
import 'package:sportifo_app/features/home/presentation/view/coach_screen.dart';
import 'package:sportifo_app/features/home/presentation/view_model/home_view_model.dart';
import 'package:sportifo_app/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:sportifo_app/features/home/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:sportifo_app/features/home/presentation/widgets/custom_drawer.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:sportifo_app/features/subscriptions/presentation/view/subscriptions_screen.dart';
import 'package:sportifo_app/features/subscriptions/presentation/view_model/subscription_cubit.dart';
import 'package:sportifo_app/features/workout/presentation/view_model/categories_cubit/categories_cubit.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../../core/di/service_locator.dart';
import '../../../workout/presentation/view/workout_type_screen.dart';
import 'package:sportifo_app/core/enum/drawer_enum.dart';

HomeViewModel homeViewModel = HomeViewModel();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DrawerItem selectedDrawerItem = DrawerItem.profile;

  List<Widget> _getTraineeScreens() {
    final l10n = AppLocalizations.of(context)!;
    return [
      Center(child: Text(l10n.progress)),
      Center(child: Text(l10n.myPlans)),
      const TraineeScreen(),
      BlocProvider(
        create: (context) => getIt<CategoriesCubit>(),
        child: const WorkoutTypeScreen(),
      ),
      Center(child: Text(l10n.chat)),
    ];
  }

  List<Widget> _getCoachScreens() {
    final l10n = AppLocalizations.of(context)!;
    return [
      BlocProvider(
        create: (context) => getIt<SubscriptionCubit>()..getSubscriptions(),
        child: SubscriptionsScreen(),
      ),
      Center(child: Text(l10n.myPlans)),
      const CoachScreen(),
      BlocProvider(
        create: (context) => getIt<CategoriesCubit>(),
        child: const WorkoutTypeScreen(),
      ),
      Center(child: Text(l10n.chat)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LogoutCubit>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()..getProfile()),
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBtn),
                ),
              );
            }

            // 1. حالة التحميل
            if (profileState is ProfileLoading || profileState is ProfileInitial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBtn),
                ),
              );
            }

            // 2. حالة الفشل (لا يوجد كاش ولا يوجد إنترنت) - هنا تصميم السينيور
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
                        onPressed: () => context.read<ProfileCubit>().getProfile(),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBtn),
                        child: const Text("Retry", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              );
            }

            // 3. حالة النجاح (الإنترنت شغال أو الداتا مكيشة)
            if (profileState is ProfileSuccess) {
              final profile = profileState.profileModel;
              final isCoach = profile.role == 'coach';

              final screens = isCoach ? _getCoachScreens() : _getTraineeScreens();

              return ListenableBuilder(
                listenable: homeViewModel,
                builder: (context, child) {
                  return Scaffold(
                    body: IndexedStack(
                      index: homeViewModel.currentIndex,
                      children: screens,
                    ),
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
                    ),
                    bottomNavigationBar: BottomNavigationBar(
                      currentIndex: homeViewModel.currentIndex,
                      onTap: (index) => homeViewModel.changeTab(index),
                      type: BottomNavigationBarType.fixed,
                      showSelectedLabels: false,
                      selectedItemColor: AppColors.primaryBtn,
                      unselectedItemColor: AppColors.hintText,
                      items: [
                        CustomBottomNavBar.build(
                          icon: isCoach
                              ? Icons.people_outline
                              : Icons.show_chart,
                          label: isCoach ? "Sub's" : l10n.progress,
                          isSelected: homeViewModel.currentIndex == 0,
                        ),
                        CustomBottomNavBar.build(
                          icon: Icons.calendar_today,
                          label: l10n.myPlans,
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
                          label: l10n.chat,
                          isSelected: homeViewModel.currentIndex == 4,
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            // return Scaffold(body: Center(child: Text(l10n.error)));
            return const SizedBox.shrink(); // حالة افتراضية آمنة
          },
        ),
      ),
    );
  }
}
