import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:remusic/main.dart';
import 'package:remusic/providers/audio_provider.dart';
import 'package:remusic/providers/locale_provider.dart';
import 'package:remusic/providers/navigation_provider.dart';
import 'package:remusic/providers/theme_provider.dart';

void main() {
  testWidgets('App builds and shows title', (WidgetTester tester) async {
    final audioProvider = AudioProvider();
    final localeController = LocaleController();
    final themeController = ThemeController();
    final navigationController = NavigationController();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: audioProvider),
          ChangeNotifierProvider.value(value: localeController),
          ChangeNotifierProvider.value(value: themeController),
          ChangeNotifierProvider.value(value: navigationController),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Re:Music'), findsWidgets);
    expect(find.byIcon(Icons.language), findsOneWidget);
  });
}
