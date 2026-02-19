import 'package:flutter/material.dart';
import '../constants.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = AppConstants.defaultThemeMode;
  AppSeedColor _seedColor = AppConstants.defaultSeedColor;

  ThemeMode get themeMode => _themeMode;
  AppSeedColor get seedColor => _seedColor;
  Color get seedColorValue => _seedColor.color;

  bool get isDark => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) return;
    _themeMode = themeMode;
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setSeedColor(AppSeedColor color) {
    if (_seedColor == color) return;
    _seedColor = color;
    notifyListeners();
  }
}
