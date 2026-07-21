import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage stub so `AvatarProvider.createAvatar`/`addExperience` never
/// touch Hive; mirrors the pattern in test/world_map/world_map_regression_test.dart.
class _FakeStorageService extends LocalStorageService {
  @override
  Future<void> saveAvatar(Avatar avatar) async {}

  @override
  Future<Avatar?> getAvatar() async => null;
}

Future<AvatarProvider> _freshAvatarProvider() async {
  final provider = AvatarProvider();
  provider.setStorageService(_FakeStorageService());
  await provider.createAvatar(
    name: 'Test Explorer',
    baseCharacter: 'fox',
    skinColor: '#F5D6A0',
  );
  return provider;
}

RewardTransactionService _service({SharedPreferences? prefs}) {
  return RewardTransactionService(
    shop: ShopService(),
    achievements: AchievementService(),
    streak: StreakService(),
    cosmeticUnlock: CosmeticUnlockService(),
    preferences: prefs,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    // ShopService/AchievementService/StreakService/CosmeticUnlockService are
    // process-wide singletons (factory constructors) shared across every
    // test in this file, so each test resets them to a known baseline
    // rather than relying on execution order.
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    await ShopService().initialize();
    await ShopService().reset();

    await AchievementService().initialize();
    await AchievementService().resetAll();

    await StreakService().initialize();
    await StreakService().resetStreak();

    CosmeticUnlockService()
        .initialize(level: 1, unlockedOutfits: [], unlockedAccessories: []);
  });

  group('RewardTransactionService.apply', () {
    test('awards XP, stars, and streak progress for a fresh outcome', () async {
      final avatar = await _freshAvatarProvider();
      final service = _service(prefs: prefs);

      final outcome = const QuestOutcome(
        outcomeId: 'session-1',
        xpEarned: 40,
        correctAnswers: 9,
        totalQuestions: 10,
        accuracy: 0.9,
      );

      final result = await service.apply(outcome, avatarProvider: avatar);

      expect(result.xpAwarded, 40);
      expect(avatar.avatar!.experiencePoints, 40);
      expect(result.starsAwarded, 3); // accuracy >= 0.9 -> 3 stars
      expect(ShopService().starBalance, 3);
      expect(result.previousLevel, 1);
      expect(result.newLevel, 1);
      expect(result.leveledUp, isFalse);
      expect(result.currentStreak, 1);
      expect(result.newStreakMilestone, isFalse); // milestone list starts at 3
    });

    test(
        'crossing a level boundary reports leveledUp with correct before/after',
        () async {
      final avatar = await _freshAvatarProvider();
      final service = _service(prefs: prefs);

      // xpPerLevel is 100; 150 XP from level 1 should land on level 2 with
      // 50 XP carried over.
      final outcome = const QuestOutcome(
        outcomeId: 'session-level-up',
        xpEarned: 150,
        correctAnswers: 10,
        totalQuestions: 10,
        accuracy: 1.0,
      );

      final result = await service.apply(outcome, avatarProvider: avatar);

      expect(result.previousLevel, 1);
      expect(result.newLevel, 2);
      expect(result.leveledUp, isTrue);
      expect(avatar.avatar!.level, 2);
      expect(avatar.avatar!.experiencePoints, 50);
    });

    test('re-applying the same outcomeId never re-awards anything', () async {
      final avatar = await _freshAvatarProvider();
      final service = _service(prefs: prefs);

      final outcome = const QuestOutcome(
        outcomeId: 'session-repeat',
        xpEarned: 40,
        correctAnswers: 9,
        totalQuestions: 10,
        accuracy: 0.9,
      );

      final first = await service.apply(outcome, avatarProvider: avatar);
      final xpAfterFirst = avatar.avatar!.experiencePoints;
      final starsAfterFirst = ShopService().starBalance;

      // Re-apply several times, as a rebuilding results screen or a
      // revisited results screen would.
      for (var i = 0; i < 3; i++) {
        final again = await service.apply(outcome, avatarProvider: avatar);
        expect(again.outcomeId, first.outcomeId);
        expect(again.xpAwarded, first.xpAwarded);
        expect(again.starsAwarded, first.starsAwarded);
      }

      expect(avatar.avatar!.experiencePoints, xpAfterFirst,
          reason: 'XP must not be awarded again on repeat apply()');
      expect(ShopService().starBalance, starsAfterFirst,
          reason: 'Stars must not be awarded again on repeat apply()');
    });

    test('a different outcomeId with the same shape awards independently',
        () async {
      final avatar = await _freshAvatarProvider();
      final service = _service(prefs: prefs);

      const shape = QuestOutcome(
        outcomeId: 'session-a',
        xpEarned: 20,
        correctAnswers: 5,
        totalQuestions: 10,
        accuracy: 0.5,
      );
      await service.apply(shape, avatarProvider: avatar);
      await service.apply(
        const QuestOutcome(
          outcomeId: 'session-b',
          xpEarned: 20,
          correctAnswers: 5,
          totalQuestions: 10,
          accuracy: 0.5,
        ),
        avatarProvider: avatar,
      );

      expect(avatar.avatar!.experiencePoints, 40);
      expect(ShopService().starBalance, 2); // 1 star x 2 sessions
    });

    test(
        'surviving an app restart: a new service instance backed by the '
        'same SharedPreferences returns the persisted result instead of '
        're-awarding (simulates a crash between persist and reveal)', () async {
      final avatar = await _freshAvatarProvider();
      final firstServiceInstance = _service(prefs: prefs);

      final outcome = const QuestOutcome(
        outcomeId: 'session-restart',
        xpEarned: 40,
        correctAnswers: 9,
        totalQuestions: 10,
        accuracy: 0.9,
      );

      final original =
          await firstServiceInstance.apply(outcome, avatarProvider: avatar);
      final xpAfterFirst = avatar.avatar!.experiencePoints;

      // A brand-new RewardTransactionService instance (as if the app was
      // killed and relaunched) sharing the same persisted prefs.
      final restartedServiceInstance = _service(prefs: prefs);
      final peeked = await restartedServiceInstance.peek(outcome.outcomeId);
      expect(peeked, isNotNull);
      expect(peeked!.xpAwarded, original.xpAwarded);
      expect(peeked.starsAwarded, original.starsAwarded);

      final replayed = await restartedServiceInstance.apply(
        outcome,
        avatarProvider: avatar,
      );
      expect(replayed.outcomeId, original.outcomeId);
      expect(avatar.avatar!.experiencePoints, xpAfterFirst,
          reason: 'Replaying a persisted outcome after "restart" must not '
              're-award XP');
    });

    test('does not crash and awards nothing when there is no avatar', () async {
      final noAvatar = AvatarProvider(); // hasAvatar == false
      final service = _service(prefs: prefs);

      final result = await service.apply(
        const QuestOutcome(
          outcomeId: 'session-no-avatar',
          xpEarned: 40,
          correctAnswers: 9,
          totalQuestions: 10,
          accuracy: 0.9,
        ),
        avatarProvider: noAvatar,
      );

      expect(result.xpAwarded, 40); // reported, even though not applied
      expect(result.previousLevel, 1);
      expect(result.newLevel, 1);
      expect(result.leveledUp, isFalse);
    });
  });
}
