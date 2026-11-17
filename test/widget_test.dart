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
