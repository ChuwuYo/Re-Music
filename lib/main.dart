import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/app_localizations.dart';
import 'models/app_configs.dart';
import 'providers/audio_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_page.dart';
import 'services/configs_service.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final configsStore = AppConfigsStore();
  final audioProvider = AudioProvider();
  final localeController = LocaleController();
  final themeController = ThemeController();
  final navigationController = NavigationController();

  final settings = await configsStore.load();
  if (settings != null) {
    localeController.setLocale(
      settings.locale == null ? null : Locale(settings.locale!),
    );
    themeController.setThemeMode(settings.themeMode);
    themeController.setThemeHue(settings.themeHue);
    audioProvider.setSortCriteria(settings.sortCriteria);
    audioProvider.setSortAscending(settings.sortAscending);
    audioProvider.setPattern(settings.pattern);
    audioProvider.setFilter(settings.filter);
    audioProvider.setArtistSeparator(settings.artistSeparator);
    audioProvider.setSingleFileAddMode(settings.singleFileAddMode);
    audioProvider.setDirectoryAddMode(settings.directoryAddMode);
    navigationController.setSidebarExpanded(settings.sidebarExpanded);
  }

  AppConfigs currentConfigsSnapshot() {
    return AppConfigs(
      locale: localeController.locale?.languageCode,
      themeMode: themeController.themeMode,
      themeHue: themeController.themeHue,
      sortCriteria: audioProvider.sortCriteria,
      sortAscending: audioProvider.sortAscending,
      pattern: audioProvider.pattern,
      filter: audioProvider.filter,
      artistSeparator: audioProvider.artistSeparator,
      singleFileAddMode: audioProvider.singleFileAddMode,
      directoryAddMode: audioProvider.directoryAddMode,
      sidebarExpanded: navigationController.sidebarExpanded,
    );
  }

  configsStore.setBaseline(currentConfigsSnapshot());

  void scheduleSave() {
    configsStore.scheduleSave(currentConfigsSnapshot());
  }

  void handleThemeChanged() {
    // Skip persistence churn while dragging hue slider preview.
    if (themeController.isHuePreviewing) return;
    scheduleSave();
  }

  localeController.addListener(scheduleSave);
  themeController.addListener(handleThemeChanged);
  audioProvider.addListener(scheduleSave);
  navigationController.addListener(scheduleSave);

  const windowOptions = WindowOptions(
    size: Size(
      AppConstants.defaultWindowWidth,
      AppConstants.defaultWindowHeight,
    ),
    minimumSize: Size(
      AppConstants.minimumWindowWidth,
      AppConstants.minimumWindowHeight,
    ),
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
        ChangeNotifierProvider.value(value: navigationController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.select<LocaleController, Locale?>(
      (controller) => controller.locale,
    );
    final seed = context.select<ThemeController, Color>(
      (controller) => controller.seedColorValue,
    );
    final themeMode = context.select<ThemeController, ThemeMode>(
      (controller) => controller.themeMode,
    );
    final isHuePreviewing = context.select<ThemeController, bool>(
      (controller) => controller.isHuePreviewing,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: locale,
      themeAnimationDuration: isHuePreviewing
          ? Duration.zero
          : AppConstants.defaultAnimationDuration,
      themeAnimationCurve: Curves.easeInOut,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        ),
        fontFamily: 'HanYiJiaShuJian',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        ),
        fontFamily: 'HanYiJiaShuJian',
      ),
      themeMode: themeMode,
      builder: (context, child) =>
          _LocalizationBridge(child: child ?? const SizedBox.shrink()),
      home: const HomePage(),
    );
  }
}

class _LocalizationBridge extends StatefulWidget {
  final Widget child;

  const _LocalizationBridge({required this.child});

  @override
  State<_LocalizationBridge> createState() => _LocalizationBridgeState();
}

class _LocalizationBridgeState extends State<_LocalizationBridge> {
  String? _unknownArtist;
  String? _unknownTitle;
  String? _unknownAlbum;
  String? _untitledTrack;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_unknownArtist == l10n.unknownArtist &&
        _unknownTitle == l10n.unknownTitle &&
        _unknownAlbum == l10n.unknownAlbum &&
        _untitledTrack == l10n.untitledTrack) {
      return;
    }

    _unknownArtist = l10n.unknownArtist;
    _unknownTitle = l10n.unknownTitle;
    _unknownAlbum = l10n.unknownAlbum;
    _untitledTrack = l10n.untitledTrack;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AudioProvider>().setNamingPlaceholders(
        unknownArtist: _unknownArtist!,
        unknownTitle: _unknownTitle!,
        unknownAlbum: _unknownAlbum!,
        untitledTrack: _untitledTrack!,
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
