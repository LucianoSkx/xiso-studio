import 'dart:convert';
import 'dart:io';

/// Preferências simples do app, guardadas em
/// `~/.config/xiso-studio/settings.json`.
class Settings {
  Settings._(this._file);

  final File _file;
  String? localeTag;

  /// Caminhos de imagens usadas recentemente, o mais recente primeiro.
  final List<String> recentImages = [];

  static const _maxRecentes = 8;

  /// Instância apontando para um arquivo específico (usada nos testes).
  factory Settings.at(String path) {
    final s = Settings._(File(path));
    s._read();
    return s;
  }

  static Settings load() {
    final base = Platform.environment['XDG_CONFIG_HOME'] ??
        '${Platform.environment['HOME']}/.config';
    final s = Settings._(File('$base/xiso-studio/settings.json'));
    s._read();
    return s;
  }

  void _read() {
    try {
      if (_file.existsSync()) {
        final data = jsonDecode(_file.readAsStringSync());
        if (data is Map && data['locale'] is String) {
          localeTag = data['locale'] as String;
        }
        if (data is Map && data['recent'] is List) {
          recentImages.addAll(
            (data['recent'] as List).whereType<String>().take(_maxRecentes),
          );
        }
      }
    } catch (_) {
      // arquivo corrompido: ignora e começa do zero
    }
  }

  void setLocale(String? tag) {
    localeTag = tag;
    _save();
  }

  /// Guarda [path] no topo da lista recente (sem repetir, com limite).
  void addRecentImage(String path) {
    final limpo = path.trim();
    if (limpo.isEmpty) return;
    recentImages.remove(limpo);
    recentImages.insert(0, limpo);
    if (recentImages.length > _maxRecentes) {
      recentImages.removeRange(_maxRecentes, recentImages.length);
    }
    _save();
  }

  void _save() {
    try {
      _file.parent.createSync(recursive: true);
      _file.writeAsStringSync(
        jsonEncode({'locale': localeTag, 'recent': recentImages}),
        flush: true,
      );
    } catch (_) {
      // sem permissão de escrita: a escolha vale só para esta sessão
    }
  }
}
