import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:remusic/constants.dart';
import 'package:remusic/main.dart';
import 'package:remusic/providers/audio_provider.dart';
import 'package:remusic/providers/locale_provider.dart';
import 'package:remusic/providers/navigation_provider.dart';
import 'package:remusic/providers/theme_provider.dart';
import 'package:remusic/providers/transcode_provider.dart';
import 'package:remusic/services/ffmpeg_binary_service.dart';

void main() {
  testWidgets('navigates to transcode page and shows binary error', (
    WidgetTester tester,
  ) async {
    final audioProvider = AudioProvider();
    final localeController = LocaleController()..setLocale(const Locale('en'));
    final themeController = ThemeController();
    final navigationController = NavigationController()
      ..navigateTo(AppPage.transcode);
    final transcodeProvider = TranscodeProvider(
      binaryService: const _MissingBinaryService(),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: audioProvider),
          ChangeNotifierProvider.value(value: transcodeProvider),
          ChangeNotifierProvider.value(value: localeController),
          ChangeNotifierProvider.value(value: themeController),
          ChangeNotifierProvider.value(value: navigationController),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Transcode'), findsOneWidget);
    expect(find.text('FFmpeg binaries are missing'), findsOneWidget);
  });
}

class _MissingBinaryService extends FfmpegBinaryService {
  const _MissingBinaryService();

  @override
  FfmpegBinaryPaths? resolve() => null;
}
