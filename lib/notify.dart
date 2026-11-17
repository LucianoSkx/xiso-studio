import 'dart:io';

/// Notificação de desktop para avisar que uma execução terminou.
///
/// Usa o `notify-send` (libnotify), que já vem nas principais distribuições.
/// Se ele não existir, a função não faz nada: o app continua funcionando, o
/// rodapé segue mostrando o resultado.
class DesktopNotifier {
  const DesktopNotifier({this.binario = 'notify-send'});

  final String binario;

  /// Argumentos do `notify-send`. Separado do envio para poder ser testado.
  static List<String> argumentos({
    required String titulo,
    required String corpo,
    String app = 'XISO Studio',
    String? icone,
    bool critica = false,
  }) {
    return [
      '--app-name=$app',
      if (icone != null) '--icon=$icone',
      '--urgency=${critica ? 'critical' : 'normal'}',
      '--expire-time=${critica ? 0 : 6000}',
      titulo,
      corpo,
    ];
  }

  /// Envia a notificação e devolve `false` quando não há como avisar
  /// (binário ausente, erro de D-Bus, etc.).
  Future<bool> enviar({
    required String titulo,
    required String corpo,
    String? icone,
    bool critica = false,
  }) async {
    try {
      final r = await Process.run(
        binario,
        argumentos(
          titulo: titulo,
          corpo: corpo,
          icone: icone,
          critica: critica,
        ),
      );
      return r.exitCode == 0;
    } on ProcessException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
