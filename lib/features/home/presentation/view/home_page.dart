import 'package:flutter/material.dart';
import 'package:sportifo_app/features/home/presentation/view_model/home_view_model.dart';
import 'package:sportifo_app/features/home/presentation/widgets/BottomNavItem.dart';

HomeViewModel viewModel = HomeViewModel();

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading : user avatar
        //title : user name
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.deepOrange),
            onPressed: () {
              // منطق المحادثات
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.deepOrange,
            ),
            onPressed: () {
              // منطق الاشعارات
            },
          ),
          const SizedBox(width: 8), // مسافة بسيطة عن حافة الشاشة
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: viewModel.currentIndex,
        onTap: (index) => viewModel.changeTab(index),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavItem.build(
            icon: Icons.show_chart,
            label: 'progress',
            isSelected: viewModel.currentIndex == 0,
          ),
          BottomNavItem.build(
            icon: Icons.calendar_today,
            label: 'my plane',
            isSelected: viewModel.currentIndex == 1,
          ),
          BottomNavItem.build(
            icon: Icons.home,
            label: 'Home',
            isSelected: viewModel.currentIndex == 2,
          ),
          BottomNavItem.build(
            icon: Icons.fitness_center_outlined,
            label: 'workouts',
            isSelected: viewModel.currentIndex == 3,
          ),
          BottomNavItem.build(
            icon: Icons.settings,
            label: 'settings',
            isSelected: viewModel.currentIndex == 4,
          ),
        ],
      ),
    );
  }
}
