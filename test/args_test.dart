import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xiso_studio/args.dart';
import 'package:xiso_studio/xiso.dart';

void main() {
  group('args do extract-xiso', () {
    test('extrair mínimo', () {
      expect(buildExtractArgs(iso: 'jogo.iso'), ['-x', 'jogo.iso']);
    });

    test('extrair com destino e -s', () {
      expect(
        buildExtractArgs(iso: 'jogo.iso', outDir: '/tmp/out', skipSystemUpdate: true),
        ['-x', '-s', '-d', '/tmp/out', 'jogo.iso'],
      );
    });

    test('destino vazio é ignorado', () {
      expect(buildExtractArgs(iso: 'a.iso', outDir: ''), ['-x', 'a.iso']);
    });

    test('listar', () {
      expect(buildListArgs('a.iso'), ['-l', 'a.iso']);
    });

    test('criar com todas as opções', () {
      expect(
        buildCreateArgs(
          sourceDir: '/jogos/halo',
          outIso: '/jogos/halo.iso',
          skipSystemUpdate: true,
          noPatch: true,
        ),
        ['-s', '-m', '-c', '/jogos/halo', '/jogos/halo.iso'],
      );
    });

    test('criar sem opções', () {
      expect(
        buildCreateArgs(sourceDir: 'src', outIso: 'out.iso'),
        ['-c', 'src', 'out.iso'],
      );
    });

    test('opções vêm antes de -c (senão -s vira o diretório de origem)', () {
      final args = buildCreateArgs(
        sourceDir: '/jogos/halo',
        outIso: '/jogos/halo.iso',
        skipSystemUpdate: true,
      );
      expect(args.indexOf('-s'), lessThan(args.indexOf('-c')));
    });

    test('reescrever com -D e destino', () {
      expect(
        buildRewriteArgs(iso: 'a.iso', outDir: '/tmp/o', deleteOld: true),
        ['-r', '-D', '-d', '/tmp/o', 'a.iso'],
      );
    });

    test('subpasta por imagem só quando há mais de um arquivo', () {
      expect(
        extractTargetFor(
          outDir: '/out',
          isoBaseName: 'halo',
          totalFiles: 1,
          perIsoFolder: true,
        ),
        '/out',
      );
      expect(
        extractTargetFor(
          outDir: '/out',
          isoBaseName: 'halo',
          totalFiles: 3,
          perIsoFolder: true,
        ),
        '/out/halo',
      );
      expect(
        extractTargetFor(
          outDir: '/out',
          isoBaseName: 'halo',
          totalFiles: 3,
          perIsoFolder: false,
        ),
        '/out',
      );
    });
  });

  group('contagem de arquivos', () {
    test('conta arquivos recursivamente e ignora \$SystemUpdate', () {
      final tmp = Directory.systemTemp.createTempSync('xiso_count_');
      try {
        File('${tmp.path}/a.bin').writeAsStringSync('a');
        Directory('${tmp.path}/sub').createSync();
        File('${tmp.path}/sub/b.bin').writeAsStringSync('b');
        Directory('${tmp.path}/\$SystemUpdate').createSync();
        File('${tmp.path}/\$SystemUpdate/update.xbe').writeAsStringSync('c');

        expect(countFilesInDir(tmp.path), 3);
        expect(countFilesInDir(tmp.path, skipSystemUpdate: true), 2);
      } finally {
        tmp.deleteSync(recursive: true);
      }
    });
  });
}
