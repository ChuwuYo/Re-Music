import 'dart:async';

import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/theme_color_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = AppConstants.defaultThemeMode;
  int _themeHue = AppConstants.defaultThemeHue;
  bool _isHuePreviewing = false;
  Timer? _huePreviewTimer;
  DateTime _lastHuePreviewAt = DateTime.fromMillisecondsSinceEpoch(0);
  int _lastFlushedHue = AppConstants.defaultThemeHue;
  int? _pendingHue;

  ThemeMode get themeMode => _themeMode;
  int get themeHue => _themeHue;
  bool get isHuePreviewing => _isHuePreviewing;
  Color get seedColorValue => ThemeColorService.seedColorFromHue(_themeHue);

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

  void setThemeHue(int hue) {
    final normalizedHue = ThemeColorService.normalizeHue(hue);
    if (_themeHue == normalizedHue) return;
    _themeHue = normalizedHue;
    _lastFlushedHue = normalizedHue;
    notifyListeners();
  }

  int? parseHueInput(String rawText) {
    final parsed = int.tryParse(rawText.trim());
    if (parsed == null) return null;
    return ThemeColorService.normalizeHue(parsed);
  }

  void setHuePreviewing(bool value) {
    if (_isHuePreviewing == value) return;
    _isHuePreviewing = value;
    notifyListeners();
  }

  void beginHuePreview() {
    _lastFlushedHue = _themeHue;
    setHuePreviewing(true);
  }

  void updateHuePreview(int hue) {
    _scheduleHuePreview(hue, force: false);
  }

  void commitHuePreview(int hue) {
    _scheduleHuePreview(hue, force: true);
    setHuePreviewing(false);
  }

  void disposeHuePreview() {
    if (_pendingHue != null) {
      _flushHuePreview();
    }
    setHuePreviewing(false);
  }

  void _scheduleHuePreview(int hue, {required bool force}) {
    final normalizedHue = ThemeColorService.normalizeHue(hue);

    if (!force) {
      final hueDelta = (normalizedHue - _lastFlushedHue).abs();
      if (hueDelta < AppConstants.themeHuePreviewMinDelta) {
        return;
      }
    }

    _pendingHue = normalizedHue;

    if (force) {
      _flushHuePreview();
      return;
    }

    final elapsed = DateTime.now().difference(_lastHuePreviewAt);
    if (_huePreviewTimer == null &&
        elapsed >= AppConstants.themeHuePreviewInterval) {
      _flushHuePreview();
      return;
    }

    if (_huePreviewTimer != null) return;

    final waitTime = AppConstants.themeHuePreviewInterval - elapsed;
    _huePreviewTimer = Timer(waitTime, _flushHuePreview);
  }

  void _flushHuePreview() {
    _huePreviewTimer?.cancel();
    _huePreviewTimer = null;

    final pendingHue = _pendingHue;
    _pendingHue = null;
    if (pendingHue == null) return;

    _lastFlushedHue = pendingHue;
    _lastHuePreviewAt = DateTime.now();
    if (_themeHue == pendingHue) return;

    _themeHue = pendingHue;
    notifyListeners();
  }

  @override
  void dispose() {
    _huePreviewTimer?.cancel();
    super.dispose();
  }
}
