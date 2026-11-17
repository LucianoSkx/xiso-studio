/// Montagem dos argumentos do `extract-xiso`.
///
/// Funções puras (sem I/O) para poderem ser testadas isoladamente e para
/// manter a interface longe dos detalhes das flags.
library;

/// Modo extrair (`-x`).
List<String> buildExtractArgs({
  required String iso,
  String? outDir,
  bool skipSystemUpdate = false,
}) {
  return [
    '-x',
    if (skipSystemUpdate) '-s',
    if (outDir != null && outDir.isNotEmpty) ...['-d', outDir],
    iso,
  ];
}

/// Modo listar (`-l`).
List<String> buildListArgs(String iso) => ['-l', iso];

/// Modo criar (`-c`).
///
/// As opções precisam vir **antes** de `-c`: ela consome o próximo argumento
/// como diretório de origem, então `-c -s dir` faria o `-s` virar o diretório.
List<String> buildCreateArgs({
  required String sourceDir,
  required String outIso,
  bool skipSystemUpdate = false,
  bool noPatch = false,
}) {
  return [
    if (skipSystemUpdate) '-s',
    if (noPatch) '-m',
    '-c',
    sourceDir,
    outIso,
  ];
}

/// Modo reescrita/otimização (`-r`).
List<String> buildRewriteArgs({
  required String iso,
  String? outDir,
  bool deleteOld = false,
}) {
  return [
    '-r',
    if (deleteOld) '-D',
    if (outDir != null && outDir.isNotEmpty) ...['-d', outDir],
    iso,
  ];
}

/// Nome sugerido para o destino de uma extração em lote.
String? extractTargetFor({
  required String outDir,
  required String isoBaseName,
  required int totalFiles,
  required bool perIsoFolder,
}) {
  if (totalFiles <= 1 || !perIsoFolder) return outDir;
  return '$outDir/$isoBaseName';
}
