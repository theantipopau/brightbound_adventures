// Safety-net tests for `WorldMapScreen` (WM-1), recorded *before* the
// map-rebuild refactor (WM-2..WM-6) so regressions are caught as that work
// proceeds.
//
// Note on scope: this intentionally does NOT use `matchesGoldenFile` pixel
// comparison. CI runs on ubuntu-latest while this suite was authored on
// Windows; font hinting/anti-aliasing differ enough between platforms that
// a golden baselined here would likely fail on first CI run for reasons
// unrelated to any real regression. Instead this asserts the things a
// refactor could actually break: the screen renders without throwing at
// each target viewport/theme, the HUD/zone/quest-panel content a player
// depends on is present, and semantics for zone cards resolve. True pixel
// goldens should be baselined from the CI (Linux) runner as a fast-follow
// (see docs/V2_1_ROADMAP_TRACKER.md, WM-1).
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/screens/world_map_screen.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  final viewportCases = <Size>[
    const Size(360, 640),
    const Size(768, 1024),
    const Size(1366, 768),
  ];

  Future<void> pumpWorldMap(
    WidgetTester tester, {
    required Size size,
    required ThemeMode themeMode,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final storage = _FakeMapStorageService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AudioManager>.value(value: AudioManager()),
          ChangeNotifierProvider<AvatarProvider>(
            create: (_) => _MapTestAvatarProvider(),
          ),
          ChangeNotifierProvider<SkillProvider>(
            create: (_) => SkillProvider(storage),
          ),
          ChangeNotifierProvider<StreakService>(create: (_) => StreakService()),
          // CosmeticUnlockService() is a factory singleton shared across the
          // whole process; using `.value` (not `create:`) means Provider
          // never calls dispose() on it when this test's tree unmounts,
          // which would otherwise permanently poison it for every test
          // that runs afterwards in the same process.
          ChangeNotifierProvider<CosmeticUnlockService>.value(
              value: CosmeticUnlockService()),
          ChangeNotifierProvider<DailyChallengeService>(
              create: (_) => DailyChallengeService(storage)),
          ChangeNotifierProvider<SpacedRepetitionService>(
              create: (_) => SpacedRepetitionService()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          home: MediaQuery(
            data: MediaQueryData(size: size, disableAnimations: true),
            child: const WorldMapScreen(),
          ),
        ),
      ),
    );

    // Let SkillProvider finish its (in-memory, storage-free) seed so zones
    // render with real skill/progress data rather than an empty map.
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 1600)); // entrance anim
  }

  /// Fails on any *unexpected* exception raised during the pump above.
  ///
  /// Two pre-existing overflows are allowlisted by exact size + message so
  /// this net still catches anything new or larger:
  ///
  /// 1. At the desktop breakpoint (1366x768, non-compact layout branch) a
  ///    zone-card Column overflows its fixed-height box by exactly 1.00
  ///    logical pixel. Invisible in release builds (RenderFlex overflow
  ///    only asserts in debug), reproduces regardless of theme. Not worth
  ///    patching blindly without knowing which of the many Columns in the
  ///    non-compact branch is 1px too tall.
  /// 2. At the narrow phone breakpoint (360x640) the top HUD Row (player
  ///    chip + profile/settings/parent buttons + stars/streak/daily/SRS
  ///    badges + avatar circle, none of it `Flexible`) overflows by ~176px.
  ///    This is not a small patch — it is *exactly* the P0 acceptance
  ///    criterion ("no overlap/clipping at 360x640") that the WM-4
  ///    three-region responsive shell task exists to fix properly
  ///    (adventure bar / living board / quest lens, secondary destinations
  ///    moved into an adventure menu). Redesigning the HUD row here, ahead
  ///    of that rebuild, risks new bugs in a screen about to be replaced.
  ///    This allowlist entry should be deleted the moment WM-4 lands.
  void expectNoUnknownException(WidgetTester tester, Size size) {
    final allowedForSize = <String>[
      if (size == const Size(1366, 768))
        'overflowed by 1.00 pixels on the bottom',
      if (size == const Size(360, 640)) 'overflowed by 176 pixels on the right',
    ];
    Object? exception;
    while ((exception = tester.takeException()) != null) {
      final message = exception.toString();
      final isKnown = allowedForSize.any(message.contains);
      expect(isKnown, isTrue,
          reason: 'Unexpected exception at $size: $exception');
    }
  }

  for (final size in viewportCases) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      final label = '${mode.name} ${size.width.toInt()}x${size.height.toInt()}';

      testWidgets('world map renders without exceptions ($label)',
          (tester) async {
        await pumpWorldMap(tester, size: size, themeMode: mode);

        expectNoUnknownException(tester, size);
      });

      testWidgets('world map shows HUD, zones, and quest content ($label)',
          (tester) async {
        await pumpWorldMap(tester, size: size, themeMode: mode);

        // Player identity is visible.
        expect(find.textContaining('Explorer'), findsWidgets);

        // The always-unlocked starter zone renders by name.
        expect(find.textContaining('Word Woods'), findsWidgets);

        // A locked zone (requires stars the fresh test avatar doesn't have)
        // still renders its name rather than disappearing.
        expect(find.textContaining('Number Nebula'), findsWidgets);

        expectNoUnknownException(tester, size);
      });

      testWidgets('zone cards expose accessible semantics ($label)',
          (tester) async {
        await pumpWorldMap(tester, size: size, themeMode: mode);

        expect(
          find.bySemanticsLabel(RegExp('Word Woods.*unlocked')),
          findsWidgets,
        );

        expectNoUnknownException(tester, size);
      });
    }
  }
}

/// In-memory avatar so the map renders its real layout instead of the
/// `_buildNoAvatarScreen()` empty state.
class _MapTestAvatarProvider extends AvatarProvider {
  static final _testAvatar = Avatar(
    id: 'test-avatar',
    name: 'Explorer Test',
    baseCharacter: 'fox',
    skinColor: '#F5D6A0',
    outfitId: 'default',
    createdAt: DateTime(2026, 1, 1),
    lastModified: DateTime(2026, 1, 1),
  );

  @override
  Avatar? get avatar => _testAvatar;

  @override
  bool get hasAvatar => true;

  @override
  Future<void> loadAvatar() async {}
}

/// Storage stub that never touches Hive: `SkillProvider` seeds skills
/// in-memory from `SkillDatabase` and calls `saveSkill` per skill, so both
/// need to be safe no-ops/empty here rather than hitting real boxes.
class _FakeMapStorageService extends LocalStorageService {
  @override
  Future<List<Skill>> getAllSkills() async => [];

  @override
  Future<void> saveSkill(Skill skill) async {}

  @override
  Future<Avatar?> getAvatar() async => null;

  @override
  List<DailyChallenge> getDailyChallenges(String dateString) => [];
}
