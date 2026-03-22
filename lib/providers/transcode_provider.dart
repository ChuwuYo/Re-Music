import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/transcode_item.dart';
import '../models/transcode_request.dart';
import '../services/ffmpeg_binary_service.dart';
import '../services/probe_service.dart';
import '../services/transcode_command_builder.dart';
import '../services/transcode_rule_engine.dart';
import '../services/transcode_task_queue.dart';

class TranscodeProvider extends ChangeNotifier {
  final FfmpegBinaryService _binaryService;
  final TranscodeRuleEngine _ruleEngine;
  final TranscodeCommandBuilder _commandBuilder;

  FfmpegBinaryPaths? _binaryPaths;
  ProbeService? _probeService;
  String? _binaryError;

  final List<TranscodeItem> _items = [];
  bool _isBusy = false;
  double _progress = 0.0;
  String? _outputDirectory;
  TranscodeItemFilter _filter = AppConstants.defaultTranscodeItemFilter;
  String _sortCriteria = AppConstants.defaultTranscodeSortCriteria;
  bool _sortAscending = AppConstants.defaultSortAscending;
  TranscodeOutputFormat _outputFormat =
      AppConstants.defaultTranscodeOutputFormat;
  TranscodeLosslessPreset _losslessPreset =
      AppConstants.defaultTranscodeLosslessPreset;
  int _mp3BitRateKbps = AppConstants.defaultTranscodeMp3BitRateKbps;
  bool _allowFormatOnlyConversion =
      AppConstants.defaultAllowFormatOnlyConversion;
  bool _enableDither = AppConstants.defaultEnableTranscodeDither;
  TranscodeOutputMode _outputMode = AppConstants.defaultTranscodeOutputMode;
  int _concurrency = AppConstants.defaultTranscodeConcurrency;

  TranscodeProvider({
    FfmpegBinaryService? binaryService,
    TranscodeRuleEngine? ruleEngine,
    TranscodeCommandBuilder? commandBuilder,
  }) : _binaryService = binaryService ?? const FfmpegBinaryService(),
       _ruleEngine = ruleEngine ?? const TranscodeRuleEngine(),
       _commandBuilder = commandBuilder ?? const TranscodeCommandBuilder() {
    refreshBinaryStatus();
  }

  List<TranscodeItem> get items => List.unmodifiable(_items);
  bool get isBusy => _isBusy;
  double get progress => _progress;
  String? get binaryError => _binaryError;
  String? get outputDirectory => _outputDirectory;
  TranscodeOutputFormat get outputFormat => _outputFormat;
  TranscodeLosslessPreset get losslessPreset => _losslessPreset;
  int get mp3BitRateKbps => _mp3BitRateKbps;
  bool get allowFormatOnlyConversion => _allowFormatOnlyConversion;
  bool get enableDither => _enableDither;
  TranscodeOutputMode get outputMode => _outputMode;
  int get concurrency => _concurrency;
  int get totalFilesCount => _items.length;
  int get runnableCount => _items.where((item) => item.canRun).length;
  TranscodeItemFilter get filter => _filter;
  String get sortCriteria => _sortCriteria;
  bool get sortAscending => _sortAscending;

  List<TranscodeItem> get displayItems {
    Iterable<TranscodeItem> result = _items;
    if (_filter != TranscodeItemFilter.all) {
      result = result.where(
        (item) => switch (_filter) {
          TranscodeItemFilter.ready => item.status == TranscodeItemStatus.ready,
          TranscodeItemFilter.skipped =>
            item.status == TranscodeItemStatus.skipped,
          TranscodeItemFilter.success =>
            item.status == TranscodeItemStatus.success,
          TranscodeItemFilter.error => item.status == TranscodeItemStatus.error,
          TranscodeItemFilter.all => true,
        },
      );
    }
    final list = result.toList();
    _sortItems(list);
    return list;
  }

  bool get canStart => !_isBusy && runnableCount > 0 && _binaryPaths != null;

  TranscodeRequest get currentRequest => TranscodeRequest(
    outputFormat: _outputFormat,
    losslessPreset: _losslessPreset,
    mp3BitRateKbps: _mp3BitRateKbps,
    allowFormatOnlyConversion: _allowFormatOnlyConversion,
    enableDither: _enableDither,
    outputMode: _outputMode,
    outputDirectory: _outputDirectory,
    concurrency: _concurrency,
  );

  void setFilter(TranscodeItemFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void setSortCriteria(String criteria) {
    if (_sortCriteria == criteria) return;
    _sortCriteria = criteria;
    notifyListeners();
  }

  void setSortAscending(bool ascending) {
    if (_sortAscending == ascending) return;
    _sortAscending = ascending;
    notifyListeners();
  }

  void refreshBinaryStatus() {
    _binaryPaths = _binaryService.resolve();
    _probeService = _binaryPaths == null
        ? null
        : ProbeService(ffprobeExecutablePath: _binaryPaths!.ffprobePath);
    _binaryError = _binaryPaths == null
        ? AppConstants.transcodeSkipBinaryMissing
        : null;
    notifyListeners();
  }

  Future<bool> openBinaryDownloadPage() async {
    return _binaryService.openWindowsDownloadPage();
  }

  Future<bool> openBinaryFolder() async {
    return _binaryService.openWindowsBinaryFolder();
  }

  void setOutputFormat(TranscodeOutputFormat format) {
    if (_outputFormat == format) return;
    _outputFormat = format;
    _refreshDecisions();
  }

  void setLosslessPreset(TranscodeLosslessPreset preset) {
    if (_losslessPreset == preset) return;
    _losslessPreset = preset;
    _refreshDecisions();
  }

  void setMp3BitRateKbps(int value) {
    if (_mp3BitRateKbps == value) return;
    _mp3BitRateKbps = value;
    _refreshDecisions();
  }

  void setAllowFormatOnlyConversion(bool value) {
    if (_allowFormatOnlyConversion == value) return;
    _allowFormatOnlyConversion = value;
    _refreshDecisions();
  }

  void setEnableDither(bool value) {
    if (_enableDither == value) return;
    _enableDither = value;
    notifyListeners();
  }

  void setOutputMode(TranscodeOutputMode mode) {
    if (_outputMode == mode) return;
    _outputMode = mode;
    _refreshDecisions();
  }

  void setOutputDirectory(String? path) {
    final normalized = path?.trim();
    if (_outputDirectory == normalized) return;
    _outputDirectory = normalized?.isEmpty == true ? null : normalized;
    _refreshDecisions();
  }

  void setConcurrency(int value) {
    final normalized = value
        .clamp(
          AppConstants.transcodeConcurrencyMin,
          AppConstants.transcodeConcurrencyMax,
        )
        .toInt();
    if (_concurrency == normalized) return;
    _concurrency = normalized;
    notifyListeners();
  }

  Future<void> clearItems() async {
    if (_isBusy) return;
    _items.clear();
    _progress = 0.0;
    notifyListeners();
  }

  Future<void> addFiles(List<String> paths) async {
    refreshBinaryStatus();
    if (_probeService == null) {
      notifyListeners();
      return;
    }

    final existingPaths = _items
        .map((item) => item.inputPath.toLowerCase())
        .toSet();
    final newItems = <TranscodeItem>[];
    for (final path in paths) {
      if (existingPaths.add(path.toLowerCase())) {
        newItems.add(
          TranscodeItem(inputPath: path, status: TranscodeItemStatus.probing),
        );
      }
    }
    if (newItems.isEmpty) return;

    ProbeService.resetProbeErrorLog();

    _items.addAll(newItems);
    _isBusy = true;
    _progress = 0.0;
    notifyListeners();

    try {
      var completed = 0;
      for (
        int index = 0;
        index < newItems.length;
        index += AppConstants.transcodeProbeConcurrency
      ) {
        final chunk = newItems
            .skip(index)
            .take(AppConstants.transcodeProbeConcurrency)
            .toList(growable: false);
        await Future.wait(chunk.map(_probeAndDecide));
        completed += chunk.length;
        _progress = completed / newItems.length;
        notifyListeners();
      }

      _refreshDecisions();
    } finally {
      _isBusy = false;
      _progress = 0.0;
      notifyListeners();
    }
  }

  Future<int> startTranscoding() async {
    if (_isBusy) return 0;

    refreshBinaryStatus();
    if (_binaryPaths == null || _probeService == null) {
      return 0;
    }

    final runnable = _items
        .where((item) => item.canRun)
        .toList(growable: false);
    if (runnable.isEmpty) return 0;

    TranscodeTaskQueue.resetTranscodeErrorLog();

    _isBusy = true;
    _progress = 0.0;
    notifyListeners();
    try {
      final queue = TranscodeTaskQueue(
        ffmpegExecutablePath: _binaryPaths!.ffmpegPath,
        probeService: _probeService!,
        commandBuilder: _commandBuilder,
      );
      final results = await queue.run(
        items: _items,
        request: currentRequest,
        onItemUpdated: (item) {
          _progress = _calculateExecutionProgress(runnable);
          notifyListeners();
        },
      );

      _progress = 1.0;
      return results.where((result) => result.isSuccess).length;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> _probeAndDecide(TranscodeItem item) async {
    try {
      final probeInfo = await _probeService!.probeFile(item.inputPath);
      item.probeInfo = probeInfo;
      _applyDecision(item);
    } catch (error) {
      item.status = TranscodeItemStatus.error;
      item.message = '$error';
    }
  }

  void _refreshDecisions() {
    final reservedOutputPaths = _buildReservedOutputPaths();
    for (final item in _items) {
      if (item.probeInfo == null) continue;
      if (item.status == TranscodeItemStatus.running ||
          item.status == TranscodeItemStatus.queued ||
          item.status == TranscodeItemStatus.success) {
        continue;
      }
      _applyDecision(item, reservedOutputPaths: reservedOutputPaths);
    }
    notifyListeners();
  }

  void _applyDecision(TranscodeItem item, {Set<String>? reservedOutputPaths}) {
    final probeInfo = item.probeInfo;
    if (probeInfo == null) return;

    final decision = _ruleEngine.evaluate(
      probeInfo: probeInfo,
      request: currentRequest,
    );
    item.decision = decision;
    if (decision.shouldTranscode && _binaryPaths != null) {
      final plan = _commandBuilder.build(
        probeInfo: probeInfo,
        decision: decision,
        request: currentRequest,
        reservedOutputPaths: reservedOutputPaths,
      );
      item.plannedOutputPath = plan.finalOutputPath;
      item.tempOutputPath = plan.commandOutputPath;
      item.status = TranscodeItemStatus.ready;
      item.message = null;
      item.progress = 0.0;
      return;
    }

    item.plannedOutputPath = null;
    item.tempOutputPath = null;
    item.progress = 0.0;
    item.status = decision.shouldTranscode
        ? TranscodeItemStatus.ready
        : TranscodeItemStatus.skipped;
    item.message = decision.skipReasonKey ?? binaryError;
  }

  Set<String> _buildReservedOutputPaths() {
    final reserved = <String>{};
    for (final item in _items) {
      if (item.status == TranscodeItemStatus.running ||
          item.status == TranscodeItemStatus.queued ||
          item.status == TranscodeItemStatus.success) {
        final planned = item.plannedOutputPath;
        final temp = item.tempOutputPath;
        if (planned != null && planned.isNotEmpty) {
          reserved.add(TranscodeCommandBuilder.normalizePath(planned));
        }
        if (temp != null && temp.isNotEmpty) {
          reserved.add(TranscodeCommandBuilder.normalizePath(temp));
        }
      }
    }
    return reserved;
  }

  void _sortItems(List<TranscodeItem> list) {
    list.sort((a, b) {
      final cmp = switch (_sortCriteria) {
        'format' => (a.probeInfo?.kind.index ?? 99).compareTo(
          b.probeInfo?.kind.index ?? 99,
        ),
        'sampleRate' => (a.probeInfo?.sampleRate ?? 0).compareTo(
          b.probeInfo?.sampleRate ?? 0,
        ),
        'status' => a.status.index.compareTo(b.status.index),
        _ => a.fileName.compareTo(b.fileName),
      };
      return _sortAscending ? cmp : -cmp;
    });
  }

  double _calculateExecutionProgress(List<TranscodeItem> runnable) {
    if (runnable.isEmpty) return 0.0;
    var total = 0.0;
    for (final item in runnable) {
      if (item.status == TranscodeItemStatus.success ||
          item.status == TranscodeItemStatus.error) {
        total += 1.0;
        continue;
      }
      if (item.status == TranscodeItemStatus.running) {
        total += item.progress ?? 0.0;
      }
    }
    return total / runnable.length;
  }
}
