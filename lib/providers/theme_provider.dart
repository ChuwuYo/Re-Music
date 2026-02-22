import 'package:flutter/material.dart';
import '../constants.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = AppConstants.defaultThemeMode;
  AppSeedColor _seedColor = AppConstants.defaultSeedColor;

  ThemeMode get themeMode => _themeMode;
  AppSeedColor get seedColor => _seedColor;
  Color get seedColorValue => _seedColor.color;

  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLight => _themeMode == ThemeMode.light;
  bool get isSystem => _themeMode == ThemeMode.system;

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) return;
    _themeMode = themeMode;
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    notifyListeners();
  }

  void setSeedColor(AppSeedColor color) {
    if (_seedColor == color) return;
    _seedColor = color;
    notifyListeners();
  }
}
