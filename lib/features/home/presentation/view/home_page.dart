import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/home/presentation/view_model/home_view_model.dart';
import 'package:sportifo_app/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:sportifo_app/features/home/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:sportifo_app/features/home/presentation/widgets/custom_drawer.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

HomeViewModel homeViewModel = HomeViewModel();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedDrawerIndex = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: homeViewModel,
      builder: (context, child) {
        return Scaffold(
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
    );
  }
}
