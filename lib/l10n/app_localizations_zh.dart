// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Re:Music';

  @override
  String get clearList => '清空列表';

  @override
  String get language => '语言';

  @override
  String get followSystem => '自动';

  @override
  String get chinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get switchToDark => '深色模式';

  @override
  String get switchToLight => '浅色模式';

  @override
  String get themeColor => '主题色';

  @override
  String get themeHueLabel => '色相 (Hue)';

  @override
  String get addFiles => '添加文件';

  @override
  String get scanDirectory => '扫描目录';

  @override
  String get namingMode => '命名模式';

  @override
  String namingModeHint(Object artist, Object title) {
    return '选择或输入自定义模式（例如：$artist - $title）';
  }

  @override
  String get patternArtistTitle => '艺术家 - 标题';

  @override
  String get patternTitleArtist => '标题 - 艺术家';

  @override
  String get patternTrackTitle => '音轨号 - 标题';

  @override
  String get patternAlbumArtistTrackTitle => '专辑艺术家 - 音轨号 - 标题';

  @override
  String get patternArtistAlbumTitle => '艺术家 - 专辑 - 标题';

  @override
  String get customPattern => '自定义模式';

  @override
  String get filter => '筛选';

  @override
  String get showAll => '显示全部';

  @override
  String get showNoRenameNeeded => '仅显示无需重命名';

  @override
  String get showNeedRename => '仅显示需重命名';

  @override
  String get sort => '排序';

  @override
  String get sortByName => '按文件名';

  @override
  String get sortByArtist => '按艺术家';

  @override
  String get sortByTitle => '按标题';

  @override
  String get sortBySize => '按大小';

  @override
  String get sortByModifiedTime => '按修改时间';

  @override
  String get emptyTitle => '拖入文件或点击添加';

  @override
  String get emptySubtitle => '支持 MP3、FLAC、M4A 等常见音频格式';

  @override
  String get noMatchTitle => '没有符合当前筛选的文件';

  @override
  String get noMatchSubtitle => '请调整筛选条件后再查看';

  @override
  String processingProgress(int percent) {
    return '处理中... $percent%';
  }

  @override
  String totalFiles(int count) {
    return '共 $count 个文件';
  }

  @override
  String get startRename => '开始';

  @override
  String renameCompleted(int count) {
    return '完成！成功重命名 $count 个文件';
  }

  @override
  String get readingMetadata => '正在读取元数据...';

  @override
  String get readFailed => '读取失败';

  @override
  String get nameMatches => '名称符合标准';

  @override
  String get renameToPrefix => '重命名为：';

  @override
  String get unknownArtist => '未知艺术家';

  @override
  String get unknownTitle => '未知标题';

  @override
  String get unknownAlbum => '未知专辑';

  @override
  String get untitledTrack => '未命名音轨';

  @override
  String get metadataReadFailed => '无法读取元数据';

  @override
  String get unknownError => '未知错误';

  @override
  String get metadataEditorTitle => '编辑元数据';

  @override
  String get metadataTitle => '标题';

  @override
  String get metadataTrackArtist => '曲目艺术家';

  @override
  String get metadataAlbumArtist => '专辑艺术家';

  @override
  String get metadataArtist => '艺术家';

  @override
  String get metadataAlbum => '专辑';

  @override
  String get metadataTrackNumber => '音轨号';

  @override
  String get metadataTrackTotal => '总音轨数';

  @override
  String get metadataYear => '年份';

  @override
  String get metadataGenre => '流派';

  @override
  String get metadataLanguage => '语言';

  @override
  String get metadataComment => '注释';

  @override
  String get apply => '应用';

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get close => '关闭';

  @override
  String get invalidNumber => '请输入有效的数字';

  @override
  String get sortAscending => '升序';

  @override
  String get sortDescending => '降序';

  @override
  String get sidebarExpand => '展开侧边栏';

  @override
  String get sidebarCollapse => '收起侧边栏';

  @override
  String get sidebarTooNarrow => '窗口太窄，拖宽窗口后可展开';

  @override
  String get navHome => '主页';

  @override
  String get navSettings => '设置';

  @override
  String get appearance => '外观';

  @override
  String get themeMode => '主题模式';

  @override
  String get renameSettings => '重命名设置';

  @override
  String get singleFileAddMode => '添加单文件时';

  @override
  String get directoryAddMode => '扫描目录时';

  @override
  String get addModeAppend => '叠加到列表';

  @override
  String get addModeReplace => '替换现有列表';

  @override
  String get artistSeparator => '艺术家分隔符';

  @override
  String get artistSeparatorHint => '多个艺术家时使用的分隔符';
}
