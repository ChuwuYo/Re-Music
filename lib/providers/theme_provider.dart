import 'package:flutter/material.dart';

enum AppSeedColor { teal, blue, indigo, purple, pink, orange, green, red }

extension AppSeedColorExtension on AppSeedColor {
  Color get color {
    switch (this) {
      case AppSeedColor.teal:
        return Colors.teal;
      case AppSeedColor.blue:
        return Colors.blue;
      case AppSeedColor.indigo:
        return Colors.indigo;
      case AppSeedColor.purple:
        return Colors.purple;
      case AppSeedColor.pink:
        return Colors.pink;
      case AppSeedColor.orange:
        return Colors.orange;
      case AppSeedColor.green:
        return Colors.green;
      case AppSeedColor.red:
        return Colors.red;
    }
  }
}

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  AppSeedColor _seedColor = AppSeedColor.teal;

  ThemeMode get themeMode => _themeMode;
  AppSeedColor get seedColor => _seedColor;

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
