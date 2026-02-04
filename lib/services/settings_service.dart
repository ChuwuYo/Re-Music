import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/app_settings.dart';

class AppSettingsStore {
  static const _fileName = 'remusic.settings.json';
  AppSettings? _lastQueued;
  AppSettings? _lastSaved;
  Timer? _debounce;

  void setBaseline(AppSettings settings) {
    _lastQueued = settings;
    _lastSaved = settings;
  }

  Future<AppSettings?> load() async {
    final exeFile = File(_exeConfigPath());
    final userFile = File(_userConfigPath());

    final exeSettings = await _tryRead(exeFile);
    if (exeSettings != null) return exeSettings;

    final userSettings = await _tryRead(userFile);
    return userSettings;
  }

  void scheduleSave(AppSettings settings) {
    if (_lastSaved == settings && _lastQueued == settings) return;
    _lastQueued = settings;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () async {
      final toSave = _lastQueued;
      if (toSave == null || _lastSaved == toSave) return;
      final saved = await _save(toSave);
      if (saved) _lastSaved = toSave;
    });
  }

  Future<AppSettings?> _tryRead(File file) async {
    try {
      if (!await file.exists()) return null;
      final text = await file.readAsString();
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) return null;
      return AppSettings.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _save(AppSettings settings) async {
    final content = const JsonEncoder.withIndent('  ').convert(settings.toJson());
    final exeFile = File(_exeConfigPath());
    final userFile = File(_userConfigPath());

    final exeExists = exeFile.existsSync();
    final userExists = userFile.existsSync();

    final preferExe = exeExists || (!userExists && _preferExeSaveLocation());
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
    return p.join(exeDir, _fileName);
  }

  bool _preferExeSaveLocation() {
    final exeDir = File(Platform.resolvedExecutable).parent.path.toLowerCase();
    return exeDir.contains('program files') || exeDir.contains('windowsapps');
  }

  String _userConfigPath() {
    final base = Platform.environment['LOCALAPPDATA'] ??
        Platform.environment['APPDATA'] ??
        Directory.current.path;
    return p.join(base, 'ReMusic', _fileName);
  }
}
