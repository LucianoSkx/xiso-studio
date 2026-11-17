import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'settings.dart';
import 'xiso.dart';

/// Como terminou a última execução da ferramenta.
enum RunOutcome { none, ok, failed, cancelled, error }

/// Estado compartilhado do app: ferramenta embarcada, execução atual,
/// progresso, log e idioma escolhido.
class AppState extends ChangeNotifier {
  AppState({Settings? settings}) : _settings = settings ?? Settings.load();

  final Settings _settings;

  String? exe;
  String version = '';
  bool ready = false;
  String? fatalError;

  bool busy = false;
  String? taskLabel;
  RunOutcome outcome = RunOutcome.none;
  int? exitCode;
  String? errorMessage;

  int progressDone = 0;
  int? progressTotal;

  String? lastOutputDir;

  final List<String> log = [];
  Process? _proc;

  /// `null` significa "seguir o idioma do sistema".
  Locale? get locale {
    final tag = _settings.localeTag;
    if (tag == null || tag.isEmpty) return null;
    return Locale(tag);
  }

  void setLocale(Locale? l) {
    _settings.setLocale(l?.languageCode);
    notifyListeners();
  }

  /// Fração concluída (0..1) ou `null` quando não há total conhecido.
  double? get progress {
    final total = progressTotal;
    if (total == null || total <= 0) return null;
    return (progressDone / total).clamp(0.0, 1.0);
  }

  Future<void> init() async {
    try {
      exe = await ensureExtractXiso();
      final info = await toolVersion(exe!);
      version = info.version;
      ready = true;
      log.add('extract-xiso v$version (embedded)');
    } catch (e) {
      fatalError = '$e';
    }
    notifyListeners();
  }

  bool get canRun => ready && !busy;

  Future<void> run(
    List<String> args, {
    required String label,
    String? cwd,
    int? totalFiles,
    bool clearLog = true,
  }) async {
    if (!ready || exe == null || busy) return;
    busy = true;
    taskLabel = label;
    outcome = RunOutcome.none;
    exitCode = null;
    errorMessage = null;
    progressDone = 0;
    progressTotal = totalFiles;
    if (clearLog) log.clear();
    log.add('\$ extract-xiso ${args.join(' ')}');
    notifyListeners();

    try {
      final code = await runExtractXiso(
        exe: exe!,
        args: args,
        workingDirectory: cwd,
        onStart: (p) => _proc = p,
        onLine: (line) {
          log.add(line);
          if (isFileProgressLine(line)) {
            progressDone += countProgressMarkers(line);
          }
          notifyListeners();
        },
      );
      exitCode = code;
      outcome = code == 0 ? RunOutcome.ok : RunOutcome.failed;
    } catch (e) {
      exitCode = -1;
      outcome = RunOutcome.error;
      errorMessage = '$e';
      log.add('ERRO: $e');
    } finally {
      _proc = null;
      busy = false;
      notifyListeners();
    }
  }

  void cancel() {
    final p = _proc;
    if (p == null) return;
    p.kill(ProcessSignal.sigterm);
    log.add('— cancelled —');
    outcome = RunOutcome.cancelled;
    notifyListeners();
  }

  void clearLog() {
    log.clear();
    notifyListeners();
  }

  /// Mensagem avulsa na barra de status (usada para resumos de lote).
  void setOutcome(RunOutcome o) {
    outcome = o;
    notifyListeners();
  }
}
