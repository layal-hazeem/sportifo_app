import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  int _currentIndex = 2;
    int get currentIndex => _currentIndex;
  @override
  void onInit() {
    _currentIndex = 2;
  }
  void changeTab(int index) {
    _currentIndex= index;
  }

}
