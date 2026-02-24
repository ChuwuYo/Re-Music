import 'package:flutter/material.dart';

import '../constants.dart';

/// 应用页面导航状态管理
/// 管理主页 / 设置页之间的切换，无需持久化
class NavigationController extends ChangeNotifier {
  AppPage _currentPage = AppPage.home;
  bool _sidebarExpanded = AppConstants.defaultSidebarExpanded;

  AppPage get currentPage => _currentPage;
  bool get sidebarExpanded => _sidebarExpanded;

  void navigateTo(AppPage page) {
    if (_currentPage == page) return;
    _currentPage = page;
    notifyListeners();
  }

  void setSidebarExpanded(bool expanded) {
    if (_sidebarExpanded == expanded) return;
    _sidebarExpanded = expanded;
    notifyListeners();
  }
}
