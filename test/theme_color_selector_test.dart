import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:remusic/constants.dart';
import 'package:remusic/l10n/app_localizations.dart';
import 'package:remusic/providers/theme_provider.dart';
import 'package:remusic/widgets/settings/theme_color_selector.dart';

Widget buildTestApp(ThemeController controller) {
  return ChangeNotifierProvider<ThemeController>.value(
    value: controller,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Column(
          children: [
            const ThemeColorSelector(),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => FocusScope.of(context).unfocus(),
                child: const Text('blur'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  test('parseHueInput reports validation status', () {
    final controller = ThemeController();

    expect(
      controller.parseHueInput('abc').status,
      HueInputStatus.invalidNumber,
    );
    expect(controller.parseHueInput('999').status, HueInputStatus.outOfRange);

    final valid = controller.parseHueInput('120');
    expect(valid.status, HueInputStatus.valid);
    expect(valid.hue, 120);
  });

  testWidgets('typed hue commits on focus loss', (tester) async {
    final controller = ThemeController();
    await tester.pumpWidget(buildTestApp(controller));
    await tester.pumpAndSettle();

    final field = find.byType(TextField);
    await tester.enterText(field, '120');
    await tester.tap(find.text('blur'));
    await tester.pumpAndSettle();

    expect(controller.themeHue, 120);
    expect(tester.widget<TextField>(field).controller!.text, '120');
  });

  testWidgets('invalid hue on focus loss reverts to current value', (
    tester,
  ) async {
    final controller = ThemeController();
    await tester.pumpWidget(buildTestApp(controller));
    await tester.pumpAndSettle();

    final field = find.byType(TextField);
    final original = tester.widget<TextField>(field).controller!.text;
    await tester.enterText(field, '999');
    await tester.tap(find.text('blur'));
    await tester.pumpAndSettle();

    expect(controller.themeHue, int.parse(original));
    expect(tester.widget<TextField>(field).controller!.text, original);
  });

  testWidgets('invalid hue on Apply shows a persistent error', (tester) async {
    final controller = ThemeController();
    await tester.pumpWidget(buildTestApp(controller));
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    final field = find.byType(TextField);
    await tester.enterText(field, '999');
    await tester.tap(find.text(l10n.apply));
    await tester.pumpAndSettle();

    expect(
      find.text(
        l10n.invalidHueRange(
          AppConstants.themeHueMin,
          AppConstants.themeHueMax,
        ),
      ),
      findsOneWidget,
    );
    expect(controller.themeHue, isNot(999));
    expect(tester.widget<TextField>(field).controller!.text, '999');
  });

  testWidgets('error from Apply clears and reverts on focus loss', (
    tester,
  ) async {
    final controller = ThemeController();
    await tester.pumpWidget(buildTestApp(controller));
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    final field = find.byType(TextField);
    final original = tester.widget<TextField>(field).controller!.text;
    await tester.enterText(field, '999');
    await tester.tap(find.text(l10n.apply));
    await tester.pumpAndSettle();

    expect(
      find.text(
        l10n.invalidHueRange(
          AppConstants.themeHueMin,
          AppConstants.themeHueMax,
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('blur'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        l10n.invalidHueRange(
          AppConstants.themeHueMin,
          AppConstants.themeHueMax,
        ),
      ),
      findsNothing,
    );
    expect(controller.themeHue, int.parse(original));
    expect(tester.widget<TextField>(field).controller!.text, original);
  });

  testWidgets('valid hue on Apply commits without an error', (tester) async {
    final controller = ThemeController();
    await tester.pumpWidget(buildTestApp(controller));
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    final field = find.byType(TextField);
    await tester.enterText(field, '120');
    await tester.tap(find.text(l10n.apply));
    await tester.pumpAndSettle();

    expect(controller.themeHue, 120);
    expect(find.text(l10n.invalidNumber), findsNothing);
    expect(find.textContaining('Enter a hue'), findsNothing);
    expect(tester.widget<TextField>(field).controller!.text, '120');
  });
}
