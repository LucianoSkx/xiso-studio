import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xiso_studio/main.dart';
import 'package:xiso_studio/settings.dart';
import 'package:xiso_studio/state.dart';
import 'package:xiso_studio/version.dart';
import 'package:xiso_studio/widgets.dart';

AppState buildState(Directory tmp, {String locale = 'pt'}) {
  final state = AppState(settings: Settings.at('${tmp.path}/settings.json'));
  state.setLocale(Locale(locale));
  return state;
}

Future<void> pumpApp(WidgetTester tester, AppState state) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(XisoStudioApp(state: state));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await tester.pump();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a janela monta com os quatro modos e a versão', (tester) async {
    final tmp = Directory.systemTemp.createTempSync('xiso_widget_');
    try {
      await pumpApp(tester, buildState(tmp));

      expect(find.text('XISO Studio'), findsOneWidget);
      expect(find.text('Extrair'), findsWidgets);
      expect(find.text('Listar'), findsWidgets);
      expect(find.text('Criar'), findsWidgets);
      expect(find.text('Otimizar'), findsWidgets);
      // versão do app no rodapé e no selo da barra lateral
      expect(find.text('v$appVersion'), findsOneWidget);
      expect(find.text(appVersion), findsOneWidget);
    } finally {
      tmp.deleteSync(recursive: true);
    }
  });

  testWidgets('troca de idioma pela interface traduz os rótulos', (tester) async {
    final tmp = Directory.systemTemp.createTempSync('xiso_lang_');
    try {
      final state = buildState(tmp);
      await pumpApp(tester, state);
      expect(find.text('Extrair'), findsWidgets);

      await tester.tap(find.byIcon(Icons.translate));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      expect(find.text('Extract'), findsWidgets);
      expect(find.text('Optimize'), findsWidgets);
      expect(find.text('Extrair'), findsNothing);

      // espanhol
      await tester.tap(find.byIcon(Icons.translate));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Español').last);
      await tester.pumpAndSettle();

      expect(find.text('Extraer'), findsWidgets);
      expect(find.text('Optimizar'), findsWidgets);

      // a escolha foi persistida
      final saved = File('${tmp.path}/settings.json').readAsStringSync();
      expect(saved, contains('"es"'));
    } finally {
      tmp.deleteSync(recursive: true);
    }
  });

  testWidgets('trocar de aba limpa o console', (tester) async {
    final tmp = Directory.systemTemp.createTempSync('xiso_tab_');
    try {
      // janela larga: o painel de log só aparece nesse layout
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final state = buildState(tmp);
      await pumpApp(tester, state);

      state.log.add('linha da aba Extrair');
      state.setOutcome(RunOutcome.ok);
      await tester.pump();
      expect(find.text('linha da aba Extrair'), findsOneWidget);

      await tester.tap(find.text('Listar').first);
      await tester.pumpAndSettle();

      expect(state.log, isEmpty);
      expect(state.outcome, RunOutcome.none);
      expect(find.text('linha da aba Extrair'), findsNothing);

      // durante uma execução o console é preservado
      state.log.add('saída em andamento');
      state.busy = true;
      await tester.pump();
      state.resetConsole();
      expect(state.log, contains('saída em andamento'));
      state.busy = false;
    } finally {
      tmp.deleteSync(recursive: true);
    }
  });

  testWidgets('botão "Abrir pasta" só aparece quando há destino', (tester) async {
    final tmp = Directory.systemTemp.createTempSync('xiso_open_');
    try {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final state = buildState(tmp);
      await pumpApp(tester, state);
      expect(find.text('Abrir pasta'), findsNothing);

      state.setOutputDir(tmp.path);
      await tester.pump();
      expect(find.text('Abrir pasta'), findsOneWidget);

      // trocar de aba limpa o console e volta a esconder o botão
      await tester.tap(find.text('Listar').first);
      await tester.pumpAndSettle();
      expect(state.lastOutputDir, isNull);
      expect(find.text('Abrir pasta'), findsNothing);
    } finally {
      tmp.deleteSync(recursive: true);
    }
  });

  testWidgets('histórico de recentes preenche o campo de imagem', (tester) async {
    final tmp = Directory.systemTemp.createTempSync('xiso_recent_');
    try {
      File('${tmp.path}/settings.json').writeAsStringSync(
        '{"locale":"pt","recent":["/tmp/jogo-velho.iso","/tmp/outro.iso"]}',
      );
      final state = buildState(tmp);
      await pumpApp(tester, state);
      expect(state.recentImages, ['/tmp/jogo-velho.iso', '/tmp/outro.iso']);

      await tester.tap(find.byIcon(Icons.history).first);
      await tester.pumpAndSettle();
      expect(find.text('jogo-velho.iso'), findsOneWidget);

      await tester.tap(find.text('jogo-velho.iso'));
      await tester.pumpAndSettle();
      expect(find.text('/tmp/jogo-velho.iso'), findsWidgets);
    } finally {
      tmp.deleteSync(recursive: true);
    }
  });

  testWidgets('barra de progresso mostra a contagem de arquivos', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressStrip(
            value: 0.5,
            done: 5,
            total: 10,
            label: 'Extraindo jogo',
            fileLabel: '5 / 10 arquivos',
          ),
        ),
      ),
    );

    expect(find.text('5 / 10 arquivos'), findsOneWidget);
    expect(find.text('Extraindo jogo'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, 0.5);
  });
}
