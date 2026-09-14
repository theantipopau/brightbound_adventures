// Regression coverage for AvatarProvider — previously untested anywhere in
// the repo. Focuses on the save-then-commit ordering fix: every mutator
// used to assign the new Avatar to `_avatar` *before* awaiting
// `saveAvatar()`, so a failed save left the in-memory avatar reporting a
// change that was never actually persisted — invisible until the next
// restart silently reverted it. Each mutator now builds the new value,
// awaits the save, and only then commits it to `_avatar`.
import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';

void main() {
  group('AvatarProvider persistence-failure consistency', () {
    test(
        'addExperience leaves the in-memory avatar unchanged if saveAvatar fails',
        () async {
      final storage = _FailingSaveStorageService(
        seed: Avatar(
          id: 'a1',
          name: 'Rex',
          baseCharacter: 'dragon',
          skinColor: '#ABCDEF',
          outfitId: 'outfit_adventure',
          experiencePoints: 10,
          level: 1,
          createdAt: DateTime(2026, 1, 1),
          lastModified: DateTime(2026, 1, 1),
        ),
      );
      final provider = AvatarProvider()..setStorageService(storage);
      await provider.loadAvatar();

      storage.shouldFailNextSave = true;
      await expectLater(
        () => provider.addExperience(50),
        throwsA(isA<Exception>()),
      );

      // The in-memory avatar must still reflect the last *persisted*
      // state, not a phantom update that was never actually saved.
      expect(provider.avatar!.experiencePoints, 10);
      expect(provider.avatar!.level, 1);
    });

    test('addExperience commits the update once saveAvatar succeeds', () async {
      final storage = _FailingSaveStorageService(
        seed: Avatar(
          id: 'a1',
          name: 'Rex',
          baseCharacter: 'dragon',
          skinColor: '#ABCDEF',
          outfitId: 'outfit_adventure',
          experiencePoints: 10,
          level: 1,
          createdAt: DateTime(2026, 1, 1),
          lastModified: DateTime(2026, 1, 1),
        ),
      );
      final provider = AvatarProvider()..setStorageService(storage);
      await provider.loadAvatar();

      await provider.addExperience(50);

      expect(provider.avatar!.experiencePoints, 60);
      expect(storage.lastSaved?.experiencePoints, 60,
          reason: 'the successful update should also have been persisted');
    });

    test(
        'unlockOutfit leaves the in-memory avatar unchanged if saveAvatar fails',
        () async {
      final storage = _FailingSaveStorageService(
        seed: Avatar(
          id: 'a1',
          name: 'Rex',
          baseCharacter: 'dragon',
          skinColor: '#ABCDEF',
          outfitId: 'outfit_adventure',
          unlockedOutfits: const ['outfit_adventure'],
          createdAt: DateTime(2026, 1, 1),
          lastModified: DateTime(2026, 1, 1),
        ),
      );
      final provider = AvatarProvider()..setStorageService(storage);
      await provider.loadAvatar();

      storage.shouldFailNextSave = true;
      await expectLater(
        () => provider.unlockOutfit('outfit_sky_scout'),
        throwsA(isA<Exception>()),
      );

      expect(provider.avatar!.unlockedOutfits, ['outfit_adventure']);
    });
  });
}

class _FailingSaveStorageService extends LocalStorageService {
  _FailingSaveStorageService({required Avatar seed}) : _stored = seed;

  Avatar _stored;
  Avatar? lastSaved;
  bool shouldFailNextSave = false;

  @override
  Future<Avatar?> getAvatar() async => _stored;

  @override
  Future<void> saveAvatar(Avatar avatar) async {
    if (shouldFailNextSave) {
      shouldFailNextSave = false;
      throw Exception('simulated storage failure');
    }
    _stored = avatar;
    lastSaved = avatar;
  }
}
