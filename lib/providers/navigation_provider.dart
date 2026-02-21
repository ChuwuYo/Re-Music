import 'package:flutter/material.dart';

import '../constants.dart';

/// 应用页面导航状态管理
/// 管理主页 / 设置页之间的切换，无需持久化
class NavigationController extends ChangeNotifier {
  AppPage _currentPage = AppPage.home;

  AppPage get currentPage => _currentPage;

  void navigateTo(AppPage page) {
    if (_currentPage == page) return;
    _currentPage = page;
    notifyListeners();
  }
}
