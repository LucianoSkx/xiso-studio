import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xiso_studio/main.dart';
import 'package:xiso_studio/settings.dart';
import 'package:xiso_studio/state.dart';
import 'package:xiso_studio/xiso.dart';

/// Fluxos reais de ponta a ponta pela interface, usando a ferramenta embarcada
/// e arquivos de verdade no disco.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('extrair um xiso pela interface funciona de ponta a ponta',
      (tester) async {
    await tester.runAsync(() async {
      final tmp = Directory.systemTemp.createTempSync('xiso_e2e_');
      try {
        final exe = await ensureExtractXiso();
        final iso = await _makeIso(exe, tmp.path);
        final out = '${tmp.path}/out';

        final state = AppState(
          settings: Settings.at('${tmp.path}/settings.json'),
        )..setLocale(const Locale('pt'));

        await tester.pumpWidget(XisoStudioApp(state: state));
        await Future<void>.delayed(const Duration(milliseconds: 600));
        await tester.pump();

        final fields = find.byType(TextField);
        expect(fields, findsNWidgets(2));
        await tester.enterText(fields.at(0), iso);
        await tester.enterText(fields.at(1), out);
        await tester.pump();

        await tester.tap(find.widgetWithText(FilledButton, 'Extrair'));
        await tester.pump();

        var done = false;
        for (var i = 0; i < 400 && !done; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 120));
          await tester.pump();
          done = File('$out/default.xbe').existsSync() &&
              File('$out/data.bin').existsSync();
        }

        expect(done, isTrue, reason: 'extração não concluiu em tempo hábil');
        expect(File('$out/data.bin').lengthSync(), 4096);
        expect(state.outcome, RunOutcome.ok);
        expect(state.progressTotal, 2);
        expect(state.progressDone, 2);
        expect(find.textContaining('Concluído'), findsWidgets);
      } finally {
        tmp.deleteSync(recursive: true);
      }
    });
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('criar um xiso pela interface grava a imagem no disco',
      (tester) async {
    await tester.runAsync(() async {
      final tmp = Directory.systemTemp.createTempSync('xiso_create_');
      try {
        final src = Directory('${tmp.path}/jogo')..createSync();
        File('${src.path}/default.xbe').writeAsStringSync('hello');
        File('${src.path}/level1.bin').writeAsBytesSync(List.filled(2048, 3));
        final outIso = '${tmp.path}/jogo.iso';

        final state = AppState(
          settings: Settings.at('${tmp.path}/settings.json'),
        )..setLocale(const Locale('pt'));

        await tester.pumpWidget(XisoStudioApp(state: state));
        await Future<void>.delayed(const Duration(milliseconds: 600));
        await tester.pump();

        // abre a página Criar
        await tester.tap(find.text('Criar').first);
        await tester.pump();

        final fields = find.byType(TextField);
        expect(fields, findsNWidgets(2));
        await tester.enterText(fields.at(0), src.path);
        await tester.enterText(fields.at(1), outIso);
        await tester.pump();

        await tester.tap(find.widgetWithText(FilledButton, 'Criar imagem'));
        await tester.pump();

        var done = false;
        for (var i = 0; i < 400 && !done; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 120));
          await tester.pump();
          done = File(outIso).existsSync() && File(outIso).lengthSync() > 0;
        }

        expect(done, isTrue,
            reason: 'imagem não foi criada em tempo hábil\n'
                'outcome=${state.outcome} exit=${state.exitCode}\n'
                'log:\n${state.log.join('\n')}');
        expect(state.outcome, RunOutcome.ok);
        expect(state.progressTotal, 2);

        // a imagem criada é listável pela ferramenta
        final exe = await ensureExtractXiso();
        final entries = await countXisoEntries(exe, outIso);
        expect(entries, 2);
      } finally {
        tmp.deleteSync(recursive: true);
      }
    });
  }, timeout: const Timeout(Duration(minutes: 3)));
}

Future<String> _makeIso(String exe, String dir) async {
  final src = Directory('$dir/game')..createSync();
  File('${src.path}/default.xbe').writeAsStringSync('hello');
  File('${src.path}/data.bin').writeAsBytesSync(List.filled(4096, 7));
  final iso = '$dir/test.iso';
  final lines = <String>[];
  final code = await runExtractXiso(
    exe: exe,
    args: ['-c', src.path, iso],
    onLine: lines.add,
  );
  expect(code, 0, reason: lines.join('\n'));
  return iso;
}
