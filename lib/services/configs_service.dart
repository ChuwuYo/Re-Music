import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/app_configs.dart';
import '../constants.dart';

class AppSettingsStore {
  static const _fileName = AppConstants.settingsFileName;
  AppConfigs? _lastQueued;
  AppConfigs? _lastSaved;
  Timer? _debounce;

  void setBaseline(AppConfigs settings) {
    _lastQueued = settings;
    _lastSaved = settings;
  }

  Future<AppConfigs?> load() async {
    final exeFile = File(_exeConfigPath());
    final userFile = File(_userConfigPath());

    final exeSettings = await _tryRead(exeFile);
    if (exeSettings != null) return exeSettings;

    final userSettings = await _tryRead(userFile);
    return userSettings;
  }

  void scheduleSave(AppConfigs settings) {
    if (_lastSaved == settings && _lastQueued == settings) return;
    _lastQueued = settings;
    _debounce?.cancel();
    _debounce = Timer(AppConstants.settingsSaveDebounce, () async {
      final toSave = _lastQueued;
      if (toSave == null || _lastSaved == toSave) return;
      final saved = await _save(toSave);
      if (saved) _lastSaved = toSave;
    });
  }

  Future<AppConfigs?> _tryRead(File file) async {
    try {
      if (!await file.exists()) return null;
      final text = await file.readAsString();
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) return null;
      return AppConfigs.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _save(AppConfigs settings) async {
    final content = const JsonEncoder.withIndent(
      AppConstants.jsonIndent,
    ).convert(settings.toJson());
    final exeFile = File(_exeConfigPath());
    final userFile = File(_userConfigPath());

    // 如果 exe 目录下的配置文件已存在，或者当前不在系统受限目录且用户配置不存在
    // 则优先保存到 exe 目录（便携模式）
    final preferExe =
        exeFile.existsSync() ||
        (!_isSystemLocation() && !userFile.existsSync());

    if (preferExe) {
      if (await _tryWrite(exeFile, content)) return true;
      return _tryWrite(userFile, content);
    }

    if (await _tryWrite(userFile, content)) return true;
    return _tryWrite(exeFile, content);
  }

  Future<bool> _tryWrite(File file, String content) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
      return true;
    } catch (_) {
      return false;
    }
  }

  String _exeConfigPath() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return p.join(exeDir, 'configs', _fileName);
  }

  bool _isSystemLocation() {
    final exeDir = File(Platform.resolvedExecutable).parent.path.toLowerCase();
    return exeDir.contains(AppConstants.programFilesPath) ||
        exeDir.contains(AppConstants.windowsAppsPath);
  }

  String _userConfigPath() {
    final base =
        Platform.environment['LOCALAPPDATA'] ??
        Platform.environment['APPDATA'] ??
        Directory.current.path;
    return p.join(base, AppConstants.appName, _fileName);
  }
}
