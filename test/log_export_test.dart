import 'package:flutter_test/flutter_test.dart';
import 'package:xiso_studio/log_export.dart';

void main() {
  final quando = DateTime(2026, 1, 17, 14, 32);

  group('exportação do log', () {
    test('cabeçalho traz app, versão e data', () {
      final txt = buildLogExport([], version: '9.9.9', now: quando);
      expect(txt, startsWith('XISO Studio 9.9.9\n'));
      expect(txt, contains('2026-01-17 14:32'));
      expect(txt, contains('(empty)'));
    });

    test('escreve todas as linhas, na ordem, uma por linha', () {
      final txt = buildLogExport(
        ['\$ extract-xiso -l jogo.iso', 'extracting jogo.iso:', '2 files in jogo.iso'],
        version: '1.4.0',
        now: quando,
      );
      final linhas = txt.trimRight().split('\n');
      expect(linhas.sublist(linhas.length - 3), [
        '\$ extract-xiso -l jogo.iso',
        'extracting jogo.iso:',
        '2 files in jogo.iso',
      ]);
      expect(txt, endsWith('\n'));
    });

    test('linhas vazias da ferramenta são preservadas', () {
      final txt = buildLogExport(['a', '', 'b'], version: '1.4.0', now: quando);
      final corpo = txt.trimRight().split('\n').sublist(3);
      expect(corpo, ['a', '', 'b']);
    });

    test('nome sugerido do arquivo é estável e ordenável', () {
      expect(logFileName(now: quando), 'xiso-studio-log-20260117-1432.txt');
      expect(logFileName(now: DateTime(2026, 12, 5, 9, 7)),
          'xiso-studio-log-20261205-0907.txt');
    });
  });
}
