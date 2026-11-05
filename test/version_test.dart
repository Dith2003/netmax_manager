import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/version.dart';

void main() {
  test('la versión que muestra la app es la de pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s*([0-9.]+)\+\d+', multiLine: true).firstMatch(pubspec);
    expect(version, isNotNull, reason: 'pubspec.yaml debe tener version: X.Y.Z+N');
    expect(versionApp, version!.group(1));
  });
}
