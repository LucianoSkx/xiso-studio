import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xiso_studio/version.dart';

void main() {
  test('a versão exibida bate com o pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final m = RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)', multiLine: true)
        .firstMatch(pubspec);
    expect(m, isNotNull, reason: 'pubspec.yaml sem campo version');
    expect(m!.group(1), appVersion,
        reason: 'lib/version.dart e pubspec.yaml divergem');
  });
}
