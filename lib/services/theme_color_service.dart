import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants.dart';

class ThemeColorService {
  ThemeColorService._();

  static final List<Color> _oklchRainbowLight = List.unmodifiable(
    _buildOklchRainbow(lightness: AppConstants.themeHueGradientLightnessLight),
  );
  static final List<Color> _oklchRainbowDark = List.unmodifiable(
    _buildOklchRainbow(lightness: AppConstants.themeHueGradientLightnessDark),
  );

  static int normalizeHue(int hue) {
    return hue.clamp(AppConstants.themeHueMin, AppConstants.themeHueMax);
  }

  static Color seedColorFromHue(int hue) {
    final normalizedHue = normalizeHue(hue);
    return _oklchToSrgb(
      lightness: AppConstants.themeHueSeedLightness,
      chroma: AppConstants.themeHueSeedChroma,
      hue: normalizedHue.toDouble(),
    );
  }

  static List<Color> rainbowGradient(Brightness brightness) {
    return brightness == Brightness.dark
        ? _oklchRainbowDark
        : _oklchRainbowLight;
  }

  static List<Color> _buildOklchRainbow({required double lightness}) {
    final colors = <Color>[];
    for (
      var hue = AppConstants.themeHueMin;
      hue < AppConstants.themeHueMax;
      hue += AppConstants.themeHueGradientStep
    ) {
      colors.add(
        _oklchToSrgb(
          lightness: lightness,
          chroma: AppConstants.themeHueGradientChroma,
          hue: hue.toDouble(),
        ),
      );
    }
    colors.add(
      _oklchToSrgb(
        lightness: lightness,
        chroma: AppConstants.themeHueGradientChroma,
        hue: AppConstants.themeHueMax.toDouble(),
      ),
    );
    return colors;
  }

  static Color _oklchToSrgb({
    required double lightness,
    required double chroma,
    required double hue,
  }) {
    final hueRadians = hue * math.pi / 180.0;
    final a = chroma * math.cos(hueRadians);
    final b = chroma * math.sin(hueRadians);

    final lPrime = lightness + 0.3963377774 * a + 0.2158037573 * b;
    final mPrime = lightness - 0.1055613458 * a - 0.0638541728 * b;
    final sPrime = lightness - 0.0894841775 * a - 1.2914855480 * b;

    final l = lPrime * lPrime * lPrime;
    final m = mPrime * mPrime * mPrime;
    final s = sPrime * sPrime * sPrime;

    final linearR = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
    final linearG = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
    final linearB = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

    final srgbR = _linearToSrgb(linearR);
    final srgbG = _linearToSrgb(linearG);
    final srgbB = _linearToSrgb(linearB);

    return Color.fromRGBO(
      (srgbR * 255).round(),
      (srgbG * 255).round(),
      (srgbB * 255).round(),
      1,
    );
  }

  static double _linearToSrgb(double channel) {
    final clamped = channel.clamp(0.0, 1.0);
    if (clamped <= 0.0031308) return 12.92 * clamped;
    return 1.055 * math.pow(clamped, 1 / 2.4).toDouble() - 0.055;
  }
}
