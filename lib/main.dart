import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/app_localizations.dart';
import 'models/app_settings.dart';
import 'providers/audio_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_page.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final settingsStore = AppSettingsStore();
  final audioProvider = AudioProvider();
  final localeController = LocaleController();
  final themeController = ThemeController();

  final settings = await settingsStore.load();
  if (settings != null) {
    localeController.setLocale(
      settings.locale == null ? null : Locale(settings.locale!),
    );
    themeController.setThemeMode(settings.themeMode);
    themeController.setSeedColor(settings.seedColor);
    audioProvider.setSortCriteria(settings.sortCriteria);
    audioProvider.setSortAscending(settings.sortAscending);
    audioProvider.setPattern(settings.pattern);
    audioProvider.setFilter(settings.filter);
  }

  settingsStore.setBaseline(
    AppSettings(
      locale: localeController.locale?.languageCode,
      themeMode: themeController.themeMode,
      seedColor: themeController.seedColor,
      sortCriteria: audioProvider.sortCriteria,
      sortAscending: audioProvider.sortAscending,
      pattern: audioProvider.pattern,
      filter: audioProvider.filter,
    ),
  );

  void scheduleSave() {
    settingsStore.scheduleSave(
      AppSettings(
        locale: localeController.locale?.languageCode,
        themeMode: themeController.themeMode,
        seedColor: themeController.seedColor,
        sortCriteria: audioProvider.sortCriteria,
        sortAscending: audioProvider.sortAscending,
        pattern: audioProvider.pattern,
        filter: audioProvider.filter,
      ),
    );
  }

  localeController.addListener(scheduleSave);
  themeController.addListener(scheduleSave);
  audioProvider.addListener(scheduleSave);

  const windowOptions = WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: audioProvider),
        ChangeNotifierProvider.value(value: localeController),
        ChangeNotifierProvider.value(value: themeController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>().locale;
    final theme = context.watch<ThemeController>();
    final seed = theme.seedColorValue;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: locale,
      themeAnimationDuration: Duration.zero,
      themeAnimationCurve: Curves.linear,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        fontFamily: 'HanYiJiaShuJian',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        fontFamily: 'HanYiJiaShuJian',
      ),
      themeMode: theme.themeMode,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context)!;
        context.read<AudioProvider>().setNamingPlaceholders(
          unknownArtist: l10n.unknownArtist,
          unknownTitle: l10n.unknownTitle,
          unknownAlbum: l10n.unknownAlbum,
          untitledTrack: l10n.untitledTrack,
        );
        return child ?? const SizedBox.shrink();
      },
      home: const HomePage(),
    );
  }
}
