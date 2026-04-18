import 'package:flutter/material.dart';

class BottomNavItem {
  static BottomNavigationBarItem build({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: Colors.grey),

      activeIcon: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      label: label,
    );
  }
}
