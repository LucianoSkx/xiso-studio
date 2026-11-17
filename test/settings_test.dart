import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xiso_studio/settings.dart';

void main() {
  group('histórico de imagens', () {
    test('a mais recente vem primeiro e não repete', () {
      final tmp = Directory.systemTemp.createTempSync('xiso_set_');
      try {
        final s = Settings.at('${tmp.path}/settings.json');
        s.addRecentImage('/a.iso');
        s.addRecentImage('/b.iso');
        s.addRecentImage('/a.iso');
        expect(s.recentImages, ['/a.iso', '/b.iso']);
      } finally {
        tmp.deleteSync(recursive: true);
      }
    });

    test('guarda no máximo 8 e sobrevive ao reinício', () {
      final tmp = Directory.systemTemp.createTempSync('xiso_set_');
      try {
        final caminho = '${tmp.path}/settings.json';
        final s = Settings.at(caminho);
        for (var i = 0; i < 12; i++) {
          s.addRecentImage('/jogo$i.iso');
        }
        expect(s.recentImages.length, 8);
        expect(s.recentImages.first, '/jogo11.iso');

        final relido = Settings.at(caminho);
        relido.setLocale('pt');
        final novo = Settings.at(caminho);
        expect(novo.recentImages.first, '/jogo11.iso');
        expect(novo.recentImages.length, 8);
        expect(novo.localeTag, 'pt');
      } finally {
        tmp.deleteSync(recursive: true);
      }
    });

    test('caminho vazio é ignorado', () {
      final tmp = Directory.systemTemp.createTempSync('xiso_set_');
      try {
        final s = Settings.at('${tmp.path}/settings.json');
        s.addRecentImage('   ');
        expect(s.recentImages, isEmpty);
      } finally {
        tmp.deleteSync(recursive: true);
      }
    });
  });
}
