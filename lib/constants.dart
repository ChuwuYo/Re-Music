import 'package:flutter/material.dart';

/// 应用常量定义
/// 集中管理项目中的所有常量，提高代码可维护性

class AppConstants {
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
  static const ThemeMode defaultThemeMode = ThemeMode.light;

  /// 默认种子颜色
  static const AppSeedColor defaultSeedColor = AppSeedColor.teal;

  /// 默认文件过滤器
  static const FileFilter defaultFileFilter = FileFilter.all;

  /// 默认占位符文本
  static const String defaultUnknownArtist = 'Unknown artist';
  static const String defaultUnknownTitle = 'Unknown title';
  static const String defaultUnknownAlbum = 'Unknown album';
  static const String defaultUntitledTrack = 'Untitled track';

  /// 窗口配置
  static const double defaultWindowWidth = 1200;
  static const double defaultWindowHeight = 800;
  static const double minimumWindowWidth = 800;
  static const double minimumWindowHeight = 600;

  /// UI 间距常量
  static const double spacingExtraSmall = 4.0;
  static const double spacingSmall = 8.0;
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

  /// 阴影相关常量
  static const double shadowBlurRadius = 18.0;
  static const double shadowOffsetY = 8.0;
  static const double highlightBlurRadius = 12.0;
  static const double highlightOffsetY = -2.0;

  /// 对话框相关常量
  static const double dialogMaxWidth = 720.0;
  static const double dialogMaxHeight = 640.0;
  static const double dialogPadding = 20.0;
  static const double dialogHorizontalPadding = 24.0;
  static const double dialogVerticalPadding = 24.0;

  /// 进度条相关常量
  static const double progressPanelMaxWidth = 320.0;
  static const double progressBorderRadius = 4.0;

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

/// 主题种子颜色枚举
enum AppSeedColor { teal, blue, indigo, purple, pink, orange, green, red }

extension AppSeedColorExtension on AppSeedColor {
  Color get color {
    switch (this) {
      case AppSeedColor.teal:
        return Colors.teal;
      case AppSeedColor.blue:
        return Colors.blue;
      case AppSeedColor.indigo:
        return Colors.indigo;
      case AppSeedColor.purple:
        return Colors.purple;
      case AppSeedColor.pink:
        return Colors.pink;
      case AppSeedColor.orange:
        return Colors.orange;
      case AppSeedColor.green:
        return Colors.green;
      case AppSeedColor.red:
        return Colors.red;
    }
  }

  String get name {
    switch (this) {
      case AppSeedColor.teal:
        return 'teal';
      case AppSeedColor.blue:
        return 'blue';
      case AppSeedColor.indigo:
        return 'indigo';
      case AppSeedColor.purple:
        return 'purple';
      case AppSeedColor.pink:
        return 'pink';
      case AppSeedColor.orange:
        return 'orange';
      case AppSeedColor.green:
        return 'green';
      case AppSeedColor.red:
        return 'red';
    }
  }
}

/// 排序标准枚举
enum SortCriteria { name, artist, title, size, date }

extension SortCriteriaExtension on SortCriteria {
  String get value {
    switch (this) {
      case SortCriteria.name:
        return 'name';
      case SortCriteria.artist:
        return 'artist';
      case SortCriteria.title:
        return 'title';
      case SortCriteria.size:
        return 'size';
      case SortCriteria.date:
        return 'date';
    }
  }
}

/// 处理状态枚举
enum ProcessingStatus { pending, success, error }

extension ProcessingStatusExtension on ProcessingStatus {
  String get name {
    switch (this) {
      case ProcessingStatus.pending:
        return 'pending';
      case ProcessingStatus.success:
        return 'success';
      case ProcessingStatus.error:
        return 'error';
    }
  }
}
