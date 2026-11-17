import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xiso_studio/xiso.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a ferramenta embarcada é extraída e roda o extract-xiso real', () async {
    final exe = await ensureExtractXiso();
    final f = File(exe);
    expect(f.existsSync(), isTrue);
    expect(f.lengthSync(), greaterThan(100000));

    final info = await toolVersion(exe);
    expect(info.version, '2.7.1');

    // Cria uma imagem XISO de teste a partir de uma pasta qualquer.
    final tmp = Directory.systemTemp.createTempSync('xiso_test_');
    final src = Directory('${tmp.path}/game')..createSync();
    File('${src.path}/default.xbe').writeAsStringSync('hello');
    File('${src.path}/data.bin').writeAsBytesSync(List.filled(4096, 7));
    final iso = '${tmp.path}/test.iso';

    final createLines = <String>[];
    final createCode = await runExtractXiso(
      exe: exe,
      args: ['-c', src.path, iso],
      onLine: createLines.add,
    );
    expect(createCode, 0, reason: createLines.join('\n'));
    expect(File(iso).existsSync(), isTrue);

    // Lista e extrai.
    final listLines = <String>[];
    final listCode = await runExtractXiso(
      exe: exe,
      args: ['-l', iso],
      onLine: listLines.add,
    );
    expect(listCode, 0);
    expect(listLines.join('\n'), contains('default.xbe'));

    final outDir = '${tmp.path}/out';
    final extractCode = await runExtractXiso(
      exe: exe,
      args: ['-x', '-d', outDir, iso],
      onLine: (_) {},
    );
    expect(extractCode, 0);
    expect(File('$outDir/default.xbe').existsSync(), isTrue);
    expect(File('$outDir/data.bin').lengthSync(), 4096);

    tmp.deleteSync(recursive: true);
  }, timeout: const Timeout(Duration(minutes: 2)));
}
