// Guards the "no placeholder bait" rule from the content-honesty pass:
// no screen may promise the child something that does not exist yet.
// Every former hit (numeracy's fake fallback question, logic/story
// "Coming Soon" empty states, the shop's empty category, the unused
// placeholder zone screen) has been replaced with an honest state.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Directory _findRepoRoot() {
  var dir = Directory.current;
  while (
      !File('${dir.path}${Platform.pathSeparator}pubspec.yaml').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Could not locate repo root (no pubspec.yaml found)');
    }
    dir = parent;
  }
  return dir;
}

void main() {
  test('no screen promises content that does not exist yet', () {
    final repoRoot = _findRepoRoot();
    final libDir = Directory('${repoRoot.path}${Platform.pathSeparator}lib');
    expect(libDir.existsSync(), isTrue);

    final offenders = <String>[];
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final content = entity.readAsStringSync().toLowerCase();
      if (content.contains('coming soon')) {
        final relative = entity.path
            .substring(repoRoot.path.length)
            .replaceAll('\\', '/')
            .replaceFirst(RegExp(r'^/'), '');
        offenders.add(relative);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Screens must show honest states (empty, unavailable, '
          'nothing-here) instead of teasing "coming soon" content to a '
          'child. Offending files: $offenders',
    );
  });
}
