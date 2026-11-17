import 'package:flutter_test/flutter_test.dart';
import 'package:xiso_studio/notify.dart';

void main() {
  group('notificação de conclusão', () {
    test('sucesso usa urgência normal e expira sozinha', () {
      final args = DesktopNotifier.argumentos(
        titulo: 'XISO Studio',
        corpo: 'Done: Extraction of Halo Demo',
        icone: '/home/u/.cache/xiso-studio/icon.png',
      );
      expect(args, [
        '--app-name=XISO Studio',
        '--icon=/home/u/.cache/xiso-studio/icon.png',
        '--urgency=normal',
        '--expire-time=6000',
        'XISO Studio',
        'Done: Extraction of Halo Demo',
      ]);
    });

    test('falha é crítica e fica na tela até ser dispensada', () {
      final args = DesktopNotifier.argumentos(
        titulo: 'XISO Studio',
        corpo: 'Failed (exit 2): Extraction of x.iso',
        critica: true,
      );
      expect(args, contains('--urgency=critical'));
      expect(args, contains('--expire-time=0'));
      expect(args, isNot(contains('--icon=null')));
      expect(args.every((a) => !a.contains('null')), isTrue);
    });

    test('sem ícone a opção nem aparece', () {
      final args = DesktopNotifier.argumentos(titulo: 't', corpo: 'c');
      expect(args.where((a) => a.startsWith('--icon')), isEmpty);
      expect(args.last, 'c');
    });

    test('binário ausente não lança: apenas devolve false', () async {
      const notifier = DesktopNotifier(binario: 'xiso-notificador-inexistente');
      final enviado = await notifier.enviar(titulo: 't', corpo: 'c');
      expect(enviado, isFalse);
    });
  });
}
