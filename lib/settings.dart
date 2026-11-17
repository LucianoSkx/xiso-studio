import 'dart:convert';
import 'dart:io';

/// Preferências simples do app, guardadas em
/// `~/.config/xiso-studio/settings.json`.
class Settings {
  Settings._(this._file);

  final File _file;
  String? localeTag;

  /// Instância apontando para um arquivo específico (usada nos testes).
  factory Settings.at(String path) => Settings._(File(path));

  static Settings load() {
    final base = Platform.environment['XDG_CONFIG_HOME'] ??
        '${Platform.environment['HOME']}/.config';
    final s = Settings._(File('$base/xiso-studio/settings.json'));
    try {
      if (s._file.existsSync()) {
        final data = jsonDecode(s._file.readAsStringSync());
        if (data is Map && data['locale'] is String) {
          s.localeTag = data['locale'] as String;
        }
      }
    } catch (_) {
      // arquivo corrompido: ignora e começa do zero
    }
    return s;
  }

  void setLocale(String? tag) {
    localeTag = tag;
    try {
      _file.parent.createSync(recursive: true);
      _file.writeAsStringSync(jsonEncode({'locale': tag}), flush: true);
    } catch (_) {
      // sem permissão de escrita: a escolha vale só para esta sessão
    }
  }
}
