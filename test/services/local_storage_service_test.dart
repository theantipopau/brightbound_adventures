// Regression coverage for LocalStorageService.getAvatar(), which had zero
// test coverage anywhere in the repo — every other test exercises a fake
// subclass that overrides getAvatar() directly, bypassing the real Hive
// deserialization path entirely.
//
// This matters because the real _mapToAvatar() used direct, unguarded map
// access (data['name'], DateTime.parse(data['createdAt']), etc.) with no
// error handling anywhere in the call chain up through
// AvatarProvider.loadAvatar() to the splash screen's fire-and-forget
// _checkAppState() in main.dart. A corrupt or partially-written avatar
// record (app killed mid-write, an old/incompatible schema) would throw
// during startup and hang the splash screen forever with no recovery path
// for the player. See CHANGELOG_CODEX.md / docs/PROMPT_MD_EXECUTION_TRACKER.md
// (2026-09-15 entry) for the full root-cause note.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/local_storage_service.dart';

void main() {
  late Directory tempDir;
  late LocalStorageService storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('brightbound_hive_test');
    Hive.init(tempDir.path);
    storage = LocalStorageService();
    await Hive.openBox(LocalStorageService.avatarBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('LocalStorageService.getAvatar', () {
    test('returns null when no avatar has been saved', () async {
      expect(await storage.getAvatar(), isNull);
    });

    test('round-trips a saved avatar unchanged', () async {
      final avatar = Avatar(
        id: 'avatar_1',
        name: 'Rex',
        baseCharacter: 'dragon',
        skinColor: '#ABCDEF',
        outfitId: 'outfit_adventure',
        unlockedOutfits: const ['outfit_adventure', 'outfit_sky_scout'],
        unlockedAccessories: const ['acc_bow'],
        experiencePoints: 42,
        level: 3,
        createdAt: DateTime(2026, 1, 1),
        lastModified: DateTime(2026, 1, 2),
      );

      await storage.saveAvatar(avatar);
      final loaded = await storage.getAvatar();

      expect(loaded, avatar);
    });

    test(
        'returns null instead of throwing for a record missing required '
        'fields (simulates a partially-written or legacy record)', () async {
      final box = Hive.box(LocalStorageService.avatarBoxName);
      await box.put('current', {'id': 'broken'});

      expect(await storage.getAvatar(), isNull);
    });

    test('returns null instead of throwing when stored dates are unparsable',
        () async {
      final box = Hive.box(LocalStorageService.avatarBoxName);
      await box.put('current', {
        'id': 'avatar_1',
        'name': 'Rex',
        'baseCharacter': 'dragon',
        'skinColor': '#ABCDEF',
        'outfitId': 'outfit_adventure',
        'createdAt': 'not-a-date',
        'lastModified': 'not-a-date',
      });

      expect(await storage.getAvatar(), isNull);
    });

    test(
        'tolerates a record missing the optional outfit/accessory lists '
        '(older schema shape)', () async {
      final box = Hive.box(LocalStorageService.avatarBoxName);
      await box.put('current', {
        'id': 'avatar_1',
        'name': 'Rex',
        'baseCharacter': 'dragon',
        'skinColor': '#ABCDEF',
        'outfitId': 'outfit_adventure',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'lastModified': DateTime(2026, 1, 2).toIso8601String(),
        // unlockedOutfits/unlockedAccessories/experiencePoints/level
        // deliberately omitted.
      });

      final loaded = await storage.getAvatar();
      expect(loaded, isNotNull);
      expect(loaded!.unlockedOutfits, isEmpty);
      expect(loaded.unlockedAccessories, isEmpty);
      expect(loaded.experiencePoints, 0);
      expect(loaded.level, 1);
    });
  });
}
