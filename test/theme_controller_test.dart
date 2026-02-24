import 'package:flutter_test/flutter_test.dart';

import 'package:remusic/constants.dart';
import 'package:remusic/providers/theme_provider.dart';

void main() {
  group('ThemeController hue behavior', () {
    test('clamps hue into valid range', () {
      final controller = ThemeController();

      controller.setThemeHue(AppConstants.themeHueMax + 50);
      expect(controller.themeHue, AppConstants.themeHueMax);

      controller.setThemeHue(AppConstants.themeHueMin - 50);
      expect(controller.themeHue, AppConstants.themeHueMin);
    });

    test('notifies listeners only on actual hue change', () {
      final controller = ThemeController();
      var notifyCount = 0;
      controller.addListener(() {
        notifyCount++;
      });

      controller.setThemeHue(controller.themeHue);
      expect(notifyCount, 0);

      controller.setThemeHue(controller.themeHue + 1);
      expect(notifyCount, 1);
    });

    test('updates seedColorValue when hue changes', () {
      final controller = ThemeController();
      final before = controller.seedColorValue.toARGB32();

      controller.setThemeHue(240);

      expect(controller.seedColorValue.toARGB32(), isNot(before));
    });

    test('updates hue previewing state only on change', () {
      final controller = ThemeController();
      var notifyCount = 0;
      controller.addListener(() {
        notifyCount++;
      });

      controller.setHuePreviewing(false);
      expect(notifyCount, 0);

      controller.setHuePreviewing(true);
      expect(controller.isHuePreviewing, isTrue);
      expect(notifyCount, 1);

      controller.setHuePreviewing(true);
      expect(notifyCount, 1);
    });
  });
}
