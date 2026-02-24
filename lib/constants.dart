import 'package:flutter/material.dart';

/// 应用常量定义
/// 集中管理项目中的所有常量，提高代码可维护性

class AppConstants {
  AppConstants._();

  /// 支持的音频文件扩展名
  static const List<String> supportedAudioExtensions = [
    'mp3',
    'flac',
    'ogg',
    'm4a',
    'aac',
    'wma',
    'wv',
    'opus',
    'dsf',
    'dff',
  ];

  /// 预定义的命名模式
  static const List<Map<String, String>> predefinedPatterns = [
    {'name': 'Artist - Title', 'pattern': '{artist} - {title}'},
    {'name': 'Title - Artist', 'pattern': '{title} - {artist}'},
    {'name': 'Track - Title', 'pattern': '{track} - {title}'},
    {
      'name': 'Album Artist - Track - Title',
      'pattern': '{albumArtist} - {track} - {title}',
    },
    {
      'name': 'Artist - Album - Title',
      'pattern': '{artist} - {album} - {title}',
    },
  ];

  /// 默认命名模式
  static const String defaultNamingPattern = '{artist} - {title}';

  /// 默认排序标准
  static const String defaultSortCriteria = 'name';

  /// 默认排序顺序（升序）
  static const bool defaultSortAscending = true;

  /// 文件名非法字符正则表达式
  static final RegExp invalidFilenameChars = RegExp(r'[\\/:*?"<>|]');

  /// 文件名非法字符替换字符
  static const String invalidFilenameReplacement = '_';

  /// 数字填充长度
  static const int numberPaddingLength = 2;

  /// 处理状态常量
  static const String errorMetadataReadFailed = 'metadataReadFailed';

  /// 默认语言代码（null 表示系统语言）
  static const String? defaultLocale = null;

  /// 默认主题模式
  static const ThemeMode defaultThemeMode = ThemeMode.system;

  /// 默认主题色相（范围 0-360）
  static const int defaultThemeHue = 180;

  /// 主题色相范围
  static const int themeHueMin = 0;
  static const int themeHueMax = 360;

  /// 主题色实时预览节流间隔（避免拖动时高频重建）
  static const Duration themeHuePreviewInterval = Duration(milliseconds: 50);

  /// 主题色实时预览最小变化步进（拖动中小于该值不触发主题重建）
  static const int themeHuePreviewMinDelta = 2;

  /// 主题色彩虹条（OKLCH）参数
  static const int themeHueGradientStep = 30;
  static const double themeHueGradientChroma = 0.10;
  static const double themeHueGradientLightnessLight = 0.80;
  static const double themeHueGradientLightnessDark = 0.70;

  /// 主题种子色（OKLCH）参数
  /// 与 Charlotte 的主色参数保持一致，提升滑块和实际主题的对应性。
  static const double themeHueSeedLightness = 0.70;
  static const double themeHueSeedChroma = 0.14;

  /// 默认文件过滤器
  static const FileFilter defaultFileFilter = FileFilter.all;

  /// 默认占位符文本
  static const String defaultUnknownArtist = 'Unknown artist';
  static const String defaultUnknownTitle = 'Unknown title';
  static const String defaultUnknownAlbum = 'Unknown album';
  static const String defaultUntitledTrack = 'Untitled track';

  /// 默认艺术家分隔符（多个艺术家时使用什么符号分割）
  static const String defaultArtistSeparator = '_';

  /// 可选的艺术家分隔符列表
  static const List<String> artistSeparatorOptions = ['_', ';', ',', '·', '、'];

  /// 校验艺术家分隔符是否可用于文件名
  static bool isValidArtistSeparator(String separator) {
    return separator.isNotEmpty &&
        artistSeparatorOptions.contains(separator) &&
        !invalidFilenameChars.hasMatch(separator);
  }

  /// 默认文件添加模式
  static const FileAddMode defaultSingleFileAddMode = FileAddMode.append;
  static const FileAddMode defaultDirectoryAddMode = FileAddMode.append;

  /// 窗口配置
  static const double defaultWindowWidth = 1440;
  static const double defaultWindowHeight = 900;
  static const double minimumWindowWidth = 900;
  static const double minimumWindowHeight = 760;

  /// 左侧栏响应式：窗口宽度低于此值时自动收起
  static const double sidebarAutoCollapseWidth = 1000.0;

  /// UI 间距常量
  static const double spacingExtraSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMediumSmall = 12.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  /// 边框半径常量
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;

  /// 动画时长
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  /// 元数据并发读取数量上限
  static const int metadataConcurrency = 8;

  /// 设置相关常量
  static const String settingsFileName = 'remusic.settings.json';
  static const Duration settingsSaveDebounce = Duration(milliseconds: 200);
  static const String jsonIndent = '  ';
  static const String programFilesPath = 'program files';
  static const String windowsAppsPath = 'windowsapps';
  static const String appName = 'ReMusic';

  /// UI 尺寸常量
  static const double defaultMenuWidth = 260.0;
  static const double edgeThreshold = 48.0;
  static const double menuMinWidth = 140.0;
  static const double menuMaxWidth = 320.0;
  static const double menuPaddingAndIconSpace = 56.0;
  static const double renameSettingsNarrowWidth = 480.0;
  static const double artistSeparatorOptionWidth = 40.0;

  /// 主题色选择器尺寸常量
  static const double themeHueSliderTrackHeight = 24.0;
  static const double themeHueSliderThumbHeight = 16.0;
  static const double themeHueInputWidth = 64.0;
  static const double themeHueControlHeight = 32.0;
  static const double themeHueSliderEdgeInset =
      (themeHueSliderTrackHeight - themeHueSliderThumbHeight) / 2;

  /// 阴影相关常量
  static const double shadowBlurRadius = 18.0;
  static const double shadowOffsetY = 8.0;
  static const double highlightBlurRadius = 12.0;
  static const double highlightOffsetY = -2.0;

  /// 主页文件列表底部留白（为 BottomRightPanel 悬浮面板预留空间）
  static const double homeListBottomPadding = 80.0;

  /// 页面切换动画横向位移量（AnimatedSwitcher slide offset）
  static const double pageTransitionSlideOffset = 0.03;

  /// 对话框相关常量
  static const double dialogMaxWidth = 720.0;
  static const double dialogMaxHeight = 640.0;
  static const double dialogPadding = 20.0;
  static const double dialogHorizontalPadding = 24.0;
  static const double dialogVerticalPadding = 24.0;

  /// 进度条相关常量
  static const double progressPanelMaxWidth = 320.0;
  static const double progressBorderRadius = 4.0;

  /// 提示通知（SnackBar）相关常量
  static const Duration snackBarDefaultDuration = Duration(seconds: 2);
  static const double snackBarDefaultHorizontalMargin = spacingMedium;
  static const double snackBarDefaultBottomMargin = spacingMedium;
  static const double homeRenameSnackBarTargetWidth = 400.0;
  static const double homeRenameSnackBarCenteringBreakpoint =
      homeRenameSnackBarTargetWidth + snackBarDefaultHorizontalMargin * 2;

  /// 图标相关常量
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 18.0;
  static const double iconSizeLarge = 28.0;
  static const double iconSizeExtraLarge = 72.0;
  static const double iconSizeHuge = 80.0;

  /// 标题栏相关常量
  static const double titleBarHeight = 40.0;
  static const double titleBarLogoWidth = 28.0;
  static const double titleBarLogoHeight = 28.0;
  static const double titleBarLeftPadding = 12.0;
  static const double titleBarRightPadding = 8.0;
  static const double titleBarRightMargin = 4.0;
  static const double titleBarIconSpacing = 8.0;
}

/// 文件过滤器枚举
enum FileFilter { all, valid, invalid }

/// 文件添加模式枚举（点击添加文件/扫描目录时的行为）
enum FileAddMode { append, replace }

/// 处理状态枚举
enum ProcessingStatus { pending, success, error }

/// 应用页面枚举
enum AppPage { home, settings }
