import 'package:flutter_test/flutter_test.dart';

import 'package:remusic/constants.dart';
import 'package:remusic/models/app_configs.dart';

void main() {
  group('AppConfigs theme hue', () {
    test('reads themeHue field from json', () {
      final config = AppConfigs.fromJson({'themeHue': 250});
      expect(config.themeHue, 250);
    });

    test('migrates legacy seedColor to themeHue', () {
      final config = AppConfigs.fromJson({'seedColor': 'purple'});
      expect(config.themeHue, 285);
    });

    test('falls back to default hue when value is invalid', () {
      final config = AppConfigs.fromJson({'themeHue': 'invalid'});
      expect(config.themeHue, AppConstants.defaultThemeHue);
    });

    test('clamps numeric hue into valid range', () {
      final high = AppConfigs.fromJson({'themeHue': 999});
      final low = AppConfigs.fromJson({'themeHue': -10});
      expect(high.themeHue, AppConstants.themeHueMax);
      expect(low.themeHue, AppConstants.themeHueMin);
    });

    test('serializes themeHue field', () {
      final config = AppConfigs.defaults();
      final json = config.toJson();
      expect(json['themeHue'], config.themeHue);
      expect(json.containsKey('seedColor'), isFalse);
    });
  });
}
