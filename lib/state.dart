import 'dart:async';
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

  /// Linhas em memória; as mais antigas saem primeiro (console com histórico).
  static const _maxLinhas = 5000;

  /// Agrupa atualizações: a ferramenta escreve dezenas de linhas por segundo
  /// (uma por trecho de 64 KB), e notificar a cada linha trava a interface.
  /// Acumulamos e avisamos no máximo a cada [_intervaloFlush].
  static const _intervaloFlush = Duration(milliseconds: 60);
  Timer? _flush;

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
      _append('extract-xiso v$version (embedded)');
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
    if (clearLog) _limpar();
    _append('\$ extract-xiso ${args.join(' ')}');
    notifyListeners();

    try {
      final code = await runExtractXiso(
        exe: exe!,
        args: args,
        workingDirectory: cwd,
        onStart: (p) => _proc = p,
        onLine: (line) {
          _append(line);
          if (isFileProgressLine(line)) {
            progressDone += countProgressMarkers(line);
            // a ferramenta pode reportar um arquivo duas vezes (ex.: após aviso
            // de truncamento); nunca deixe o contador passar do total.
            final total = progressTotal;
            if (total != null) progressDone = progressDone.clamp(0, total);
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
      _append('ERRO: $e');
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
    _append('— cancelled —');
    outcome = RunOutcome.cancelled;
    notifyListeners();
  }

  /// Adiciona uma linha ao console e agenda uma notificação agrupada.
  void _append(String line) {
    log.add(line);
    if (log.length > _maxLinhas) {
      log.removeRange(0, log.length - _maxLinhas);
    }
    _flush ??= Timer(_intervaloFlush, () {
      _flush = null;
      notifyListeners();
    });
  }

  /// Esvazia o console sem notificar (o chamador avisa logo em seguida).
  void _limpar() => log.clear();

  @override
  void dispose() {
    _flush?.cancel();
    _flush = null;
    super.dispose();
  }

  void clearLog() {
    log.clear();
    _flush?.cancel();
    _flush = null;
    notifyListeners();
  }

  /// Zera a saída e o resultado da última execução. Chamado ao trocar de aba:
  /// cada modo começa com o console limpo. Durante uma execução o log é do
  /// processo em andamento e é preservado, para não perder o progresso.
  void resetConsole() {
    if (busy) return;
    _flush?.cancel();
    _flush = null;
    log.clear();
    outcome = RunOutcome.none;
    exitCode = null;
    errorMessage = null;
    progressDone = 0;
    progressTotal = null;
    taskLabel = null;
    lastOutputDir = null;
    notifyListeners();
  }

  /// Mensagem avulsa na barra de status (usada para resumos de lote).
  void setOutcome(RunOutcome o) {
    outcome = o;
    notifyListeners();
  }
}
