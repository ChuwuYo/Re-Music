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

  group('AppConfigs sidebar expanded', () {
    test('falls back to default when sidebarExpanded is missing', () {
      final config = AppConfigs.fromJson({});
      expect(config.sidebarExpanded, AppConstants.defaultSidebarExpanded);
    });

    test('reads sidebarExpanded from json', () {
      final config = AppConfigs.fromJson({'sidebarExpanded': false});
      expect(config.sidebarExpanded, isFalse);
    });

    test('serializes sidebarExpanded field', () {
      final config = AppConfigs.fromJson({'sidebarExpanded': false});
      final json = config.toJson();
      expect(json['sidebarExpanded'], isFalse);
    });
  });

  group('AppConfigs transcode settings', () {
    test('reads and serializes transcode fields', () {
      final config = AppConfigs.fromJson({
        'transcodeOutputFormat': 'mp3',
        'transcodeLosslessPreset': 'studio24',
        'transcodeMp3BitRateKbps': 256,
        'allowFormatOnlyConversion': true,
        'enableTranscodeDither': true,
        'transcodeOutputMode': 'replaceOriginal',
        'transcodeOutputDirectory': 'E:/Music/Out',
        'transcodeConcurrency': 99,
      });

      expect(config.transcodeOutputFormat, TranscodeOutputFormat.mp3);
      expect(config.transcodeLosslessPreset, TranscodeLosslessPreset.studio24);
      expect(config.transcodeMp3BitRateKbps, 256);
      expect(config.allowFormatOnlyConversion, isTrue);
      expect(config.enableTranscodeDither, isTrue);
      expect(config.transcodeOutputMode, TranscodeOutputMode.replaceOriginal);
      expect(config.transcodeOutputDirectory, 'E:/Music/Out');
      expect(config.transcodeConcurrency, AppConstants.transcodeConcurrencyMax);

      final json = config.toJson();
      expect(json['transcodeOutputFormat'], 'mp3');
      expect(json['transcodeLosslessPreset'], 'studio24');
      expect(json['transcodeMp3BitRateKbps'], 256);
      expect(json['allowFormatOnlyConversion'], isTrue);
      expect(json['enableTranscodeDither'], isTrue);
      expect(json['transcodeOutputMode'], 'replaceOriginal');
      expect(json['transcodeOutputDirectory'], 'E:/Music/Out');
      expect(
        json['transcodeConcurrency'],
        AppConstants.transcodeConcurrencyMax,
      );
    });

    test(
      'falls back outputDirectory mode to default when directory is missing',
      () {
        final config = AppConfigs.fromJson({
          'transcodeOutputMode': 'outputDirectory',
        });
        expect(
          config.transcodeOutputMode,
          AppConstants.defaultTranscodeOutputMode,
        );
      },
    );

    test('preserves outputDirectory mode when directory is present', () {
      final config = AppConfigs.fromJson({
        'transcodeOutputMode': 'outputDirectory',
        'transcodeOutputDirectory': 'E:/Music/Out',
      });
      expect(config.transcodeOutputMode, TranscodeOutputMode.outputDirectory);
      expect(config.transcodeOutputDirectory, 'E:/Music/Out');
    });

    test('reads and serializes transcode sort/filter fields', () {
      final config = AppConfigs.fromJson({
        'transcodeSortCriteria': 'format',
        'transcodeSortAscending': false,
        'transcodeFilter': 'ready',
      });

      expect(config.transcodeSortCriteria, 'format');
      expect(config.transcodeSortAscending, isFalse);
      expect(config.transcodeFilter, TranscodeItemFilter.ready);

      final json = config.toJson();
      expect(json['transcodeSortCriteria'], 'format');
      expect(json['transcodeSortAscending'], isFalse);
      expect(json['transcodeFilter'], 'ready');
    });

    test('falls back transcode sort/filter to defaults when missing', () {
      final config = AppConfigs.fromJson({});

      expect(
        config.transcodeSortCriteria,
        AppConstants.defaultTranscodeSortCriteria,
      );
      expect(config.transcodeSortAscending, AppConstants.defaultSortAscending);
      expect(config.transcodeFilter, AppConstants.defaultTranscodeItemFilter);
    });

    test('falls back transcode sort criteria for invalid value', () {
      final config = AppConfigs.fromJson({'transcodeSortCriteria': 'invalid'});
      expect(
        config.transcodeSortCriteria,
        AppConstants.defaultTranscodeSortCriteria,
      );
    });
  });
}
