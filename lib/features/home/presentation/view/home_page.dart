import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/auth/data/repository/auth_repository.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:sportifo_app/features/home/presentation/view_model/home_view_model.dart';
import 'package:sportifo_app/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:sportifo_app/features/home/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:sportifo_app/features/home/presentation/widgets/custom_drawer.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

import '../../../workout/presentation/view/workout_type_screen.dart';

HomeViewModel homeViewModel = HomeViewModel();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedDrawerIndex = 1;

  final List<Widget> _screens = [
    const Center(child: Text("Progress Screen")),
    const Center(child: Text("My Plans Screen")),
    const Center(child: Text("Home Dashboard")),
    const WorkoutTypeScreen(),
    const Center(child: Text("Chat Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => LogoutCubit(GetIt.instance<AuthRepository>()),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: ListenableBuilder(
          listenable: homeViewModel,
          builder: (context, child) {
            return Scaffold(
              body: _screens[homeViewModel.currentIndex],

              drawer: CustomDrawer(
                selectedIndex: selectedDrawerIndex,
                onItemTap: (index) {
                  setState(() {
                    selectedDrawerIndex = index;
                  });
                },
              ),

              appBar: CustomAppBar(
                currentIndex: homeViewModel.currentIndex,
                userName: "Unknown",
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
                    icon: Icons.show_chart,
                    label: l10n.progress,
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
        ),
      ),
    );
  }
}
