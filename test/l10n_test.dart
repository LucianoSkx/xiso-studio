import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, String> _read(String locale) {
  final file = File('lib/l10n/app_$locale.arb');
  final raw = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final e in raw.entries)
      if (!e.key.startsWith('@')) e.key: '${e.value}',
  };
}

void main() {
  test('todos os idiomas têm exatamente as mesmas chaves', () {
    final pt = _read('pt');
    expect(pt, isNotEmpty);

    for (final locale in ['en', 'es']) {
      final other = _read(locale);
      expect(
        other.keys.toSet(),
        pt.keys.toSet(),
        reason: 'chaves divergentes em app_$locale.arb',
      );
    }
  });

  test('nenhuma tradução está vazia', () {
    for (final locale in ['pt', 'en', 'es']) {
      for (final e in _read(locale).entries) {
        expect(e.value.trim(), isNotEmpty, reason: '${e.key} vazio em $locale');
      }
    }
  });

  test('os placeholders batem entre os idiomas', () {
    final placeholderRe = RegExp(r'\{(\w+)\}');
    Map<String, Set<String>> holders(String locale) => {
          for (final e in _read(locale).entries)
            e.key: placeholderRe.allMatches(e.value).map((m) => m.group(1)!).toSet(),
        };

    final pt = holders('pt');
    for (final locale in ['en', 'es']) {
      final other = holders(locale);
      for (final key in pt.keys) {
        expect(other[key], pt[key], reason: 'placeholders de $key em $locale');
      }
    }
  });
}
