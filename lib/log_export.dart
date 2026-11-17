import 'version.dart';

/// Cabeçalho + linhas do console, no formato do arquivo salvo por "Salvar log".
///
/// O cabeçalho fica em inglês de propósito: o arquivo costuma ser anexado em
/// relatos de problema, que circulam fora do idioma escolhido na interface.
String buildLogExport(
  Iterable<String> lines, {
  String version = appVersion,
  DateTime? now,
}) {
  final t = now ?? DateTime.now();
  final b = StringBuffer()
    ..writeln('XISO Studio $version')
    ..writeln('extract-xiso session log — ${_stamp(t)}')
    ..writeln();
  final lista = lines.toList(growable: false);
  if (lista.isEmpty) {
    b.writeln('(empty)');
  } else {
    b.writeAll(lista, '\n');
    b.writeln();
  }
  return b.toString();
}

/// Nome sugerido no diálogo: `xiso-studio-log-20260117-1432.txt`.
String logFileName({DateTime? now}) {
  final t = now ?? DateTime.now();
  final d = '${t.year.toString().padLeft(4, '0')}'
      '${t.month.toString().padLeft(2, '0')}'
      '${t.day.toString().padLeft(2, '0')}';
  final h = '${t.hour.toString().padLeft(2, '0')}'
      '${t.minute.toString().padLeft(2, '0')}';
  return 'xiso-studio-log-$d-$h.txt';
}

String _stamp(DateTime t) {
  String dois(int v) => v.toString().padLeft(2, '0');
  return '${t.year.toString().padLeft(4, '0')}-${dois(t.month)}-${dois(t.day)} '
      '${dois(t.hour)}:${dois(t.minute)}';
}
