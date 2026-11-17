import 'package:flutter_test/flutter_test.dart';
import 'package:xiso_studio/xiso.dart';

void main() {
  group('progresso a partir da saída da ferramenta', () {
    test('reads the count from the summary ("12 files in ...")', () {
      expect(parseEntryCount('12 files in jogo.iso total 4096 bytes'), 12);
      expect(parseEntryCount('1 files in a.iso total 5 bytes'), 1);
      expect(parseEntryCount('2 files in test.iso total 65541 bytes'), 2);
    });

    test('devolve null quando não há resumo', () {
      expect(parseEntryCount('extracting /a/b.bin (10 bytes) [100%]'), isNull);
      expect(parseEntryCount(''), isNull);
    });

    test('reconhece as linhas de progresso por arquivo', () {
      expect(isFileProgressLine('extracting /out/data.bin (65536 bytes) [100%]'), isTrue);
      expect(isFileProgressLine('adding /data.bin (65536 bytes) [OK]'), isTrue);
      expect(isFileProgressLine('extracting /out/vazio (0 bytes) [100%]'), isTrue);
      // cabeçalhos e listagem não contam como progresso
      expect(isFileProgressLine('extracting test.iso:'), isFalse);
      expect(isFileProgressLine('/data.bin (65536 bytes)'), isFalse);
      expect(isFileProgressLine('2 files in test.iso total 65541 bytes'), isFalse);
      expect(isFileProgressLine(''), isFalse);
    });

    test('conta só arquivos concluídos, nunca porcentagens parciais (saída com \\r)', () {
      // a ferramenta imprime uma linha por trecho de buffer do mesmo arquivo:
      // contar todas passaria do total (573 de 324 numa execução real).
      const chunk = 'extracting /o/a (1048576 bytes) [10%]\r'
          'extracting /o/a (1048576 bytes) [40%]\r'
          'extracting /o/a (1048576 bytes) [100%]\r'
          'extracting /o/b (2048 bytes) [100%]\r'
          'adding /o/c (4096 bytes) [OK]\r';
      expect(countProgressMarkers(chunk), 3);
      expect(countProgressMarkers('extracting /o/a (9 bytes) [37%]'), 0);
    });

    test('linhas de progresso somam o total de um lote', () {
      const lines = [
        'extract-xiso v2.7.1 (01.11.14) for linux',
        '',
        'extracting test.iso:',
        '',
        'extracting /out/data.bin (65536 bytes) [100%]',
        'extracting /out/default.xbe (5 bytes) [100%]',
        '',
        '2 files in test.iso total 65541 bytes',
      ];
      final done = lines.where(isFileProgressLine).length;
      expect(done, 2);
      expect(parseEntryCount(lines.join('\n')), 2);
    });
  });
}
