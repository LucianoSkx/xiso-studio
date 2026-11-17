import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

/// Localiza (e materializa em disco, se necessário) o binário do
/// extract-xiso embarcado no bundle do app.
///
/// Retorna o caminho absoluto de um executável válido, ou lança
/// [StateError] se algo falhar.
Future<String> ensureExtractXiso() async {
  final cacheDir = Directory(
    '${Platform.environment['XDG_CACHE_HOME'] ?? '${Platform.environment['HOME']}/.cache'}'
    '/xiso-studio',
  );
  final tool = File('${cacheDir.path}/extract-xiso');

  if (!tool.existsSync() || tool.lengthSync() == 0) {
    cacheDir.createSync(recursive: true);
    final data = await rootBundle.load('assets/bin/extract-xiso');
    await tool.writeAsBytes(data.buffer.asUint8List(), flush: true);
  }

  if (!_isExecutable(tool)) {
    await Process.run('chmod', ['+x', tool.path]);
  }
  if (!tool.existsSync()) {
    throw StateError('Falha ao materializar a ferramenta embarcada.');
  }
  return tool.path;
}

bool _isExecutable(File f) {
  try {
    return f.statSync().mode & 0x40 != 0; // owner-execute
  } catch (_) {
    return false;
  }
}

/// Representa a versão do extract-xiso embarcado (lida com `-v`).
class ToolInfo {
  final String raw;
  ToolInfo(this.raw);

  String get version {
    final m = RegExp(r'v(\d+\.\d+(?:\.\d+)?)').firstMatch(raw);
    return m?.group(1) ?? '?';
  }
}

Future<ToolInfo> toolVersion(String exe) async {
  final r = await Process.run(exe, ['-v']);
  return ToolInfo('${r.stdout}\n${r.stderr}'.trim());
}

/// Executa o extract-xiso com [args], canalizando stdout+stderr para
/// [onLine] (linha a linha). O processo é entregue a [onStart] para que o
/// chamador possa cancelá-lo.
Future<int> runExtractXiso({
  required String exe,
  required List<String> args,
  required void Function(String line) onLine,
  void Function(Process process)? onStart,
  String? workingDirectory,
}) async {
  final process = await Process.start(
    exe,
    args,
    workingDirectory: workingDirectory,
    runInShell: false,
  );
  onStart?.call(process);

  final sb = StringBuffer();
  final sink = _LineSplitter(onLine);

  void feed(List<int> bytes) {
    sb.write(utf8.decode(bytes, allowMalformed: true));
    final text = sb.toString();
    final lastNl = text.lastIndexOf('\n');
    if (lastNl >= 0) {
      final complete = text.substring(0, lastNl);
      sb.clear();
      sb.write(text.substring(lastNl + 1));
      sink.add(complete);
    }
  }

  // Espera os dois pipes terminarem antes de ler o exit code: o processo pode
  // sair antes das últimas linhas serem entregues pelo sistema (corrida que
  // aparecia justamente em máquinas rápidas, como o CI).
  final outDone = Completer<void>();
  final errDone = Completer<void>();
  process.stdout.listen(
    feed,
    onError: (_) {},
    onDone: () {
      if (!outDone.isCompleted) outDone.complete();
    },
  );
  process.stderr.listen(
    feed,
    onError: (_) {},
    onDone: () {
      if (!errDone.isCompleted) errDone.complete();
    },
  );

  final code = await process.exitCode;
  await Future.wait([outDone.future, errDone.future]);
  if (sb.isNotEmpty) sink.add(sb.toString());
  sink.flush();
  return code;
}

/// Divide texto em linhas, chamando o callback para cada uma.
class _LineSplitter {
  final void Function(String) _cb;
  String _pending = '';

  _LineSplitter(this._cb);

  void add(String text) {
    _pending += text;
    // a ferramenta usa \r no progresso e \n nas linhas normais
    final lines = _pending.split(RegExp(r'\r\n|\r|\n'));
    _pending = lines.removeLast();
    for (final l in lines) {
      if (l.trim().isNotEmpty) _cb(l);
    }
  }

  void flush() {
    if (_pending.isNotEmpty) {
      _cb(_pending);
      _pending = '';
    }
  }
}

/// Reconhece a linha de resumo da ferramenta: "12 files in x.iso total 456 bytes".
final _summaryCountRe = RegExp(r'(\d+)\s+files?\s+in\s', caseSensitive: false);

/// Uma linha por trecho de buffer enquanto a ferramenta copia cada arquivo:
/// o mesmo arquivo emite `[12%]`, `[37%]`, … e uma última linha `[100%]` — ou
/// `[OK]` no modo criar — então só a última conta como "concluído".
///
/// `extracting /out/data.bin (65536 bytes) [100%]`
/// `adding /data.bin (65536 bytes) [OK]`
final _fileProgressRe = RegExp(r'\((?:0|\d+) bytes\) \[', caseSensitive: false);
final _fileDoneRe = RegExp(r'\((?:0|\d+) bytes\) \[(?:100%|OK)\]', caseSensitive: false);

int? parseEntryCount(String text) {
  final m = _summaryCountRe.firstMatch(text);
  return m == null ? null : int.tryParse(m.group(1)!);
}

/// Verdadeiro para qualquer linha de progresso por arquivo, concluída ou não.
bool isFileProgressLine(String line) => _fileProgressRe.hasMatch(line);

/// Quantos arquivos o texto reporta como concluídos (pode haver mais de um
/// quando a saída chega sem quebras de linha). Linhas parciais como `[37%]`
/// são ignoradas, senão a contagem passa do total.
int countProgressMarkers(String text) => _fileDoneRe.allMatches(text).length;

/// Conta quantos arquivos existem dentro de uma imagem XISO, rodando `-l`
/// (leitura só do diretório, rápida mesmo em imagens grandes).
Future<int?> countXisoEntries(String exe, String iso) async {
  try {
    final lines = <String>[];
    final code = await runExtractXiso(
      exe: exe,
      args: ['-l', iso],
      onLine: lines.add,
    );
    if (code != 0) return null;
    return parseEntryCount(lines.join('\n'));
  } catch (_) {
    return null;
  }
}

/// Conta arquivos (não pastas) dentro de [dir], opcionalmente ignorando
/// a pasta $SystemUpdate como a ferramenta faz com `-s`.
int countFilesInDir(String dir, {bool skipSystemUpdate = false}) {
  var count = 0;
  try {
    for (final entity in Directory(dir).listSync(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      if (skipSystemUpdate && entity.path.split('/').contains(r'$SystemUpdate')) {
        continue;
      }
      count++;
    }
  } catch (_) {
    return 0;
  }
  return count;
}
