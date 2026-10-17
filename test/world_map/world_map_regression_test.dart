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
import 'package:brightbound_adventures/ui/screens/world_map/world_map_quest_lens.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/animated_character.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    TextScaler textScaler = TextScaler.noScaling,
    LocalStorageService? storage,
    Map<String, WidgetBuilder>? routes,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = storage ?? _FakeMapStorageService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AudioManager>.value(value: AudioManager()),
          ChangeNotifierProvider<AvatarProvider>(
            create: (_) => _MapTestAvatarProvider(),
          ),
          ChangeNotifierProvider<SkillProvider>(
            create: (_) => SkillProvider(store),
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
              create: (_) => DailyChallengeService(store)),
          ChangeNotifierProvider<SpacedRepetitionService>(
              create: (_) => SpacedRepetitionService()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          routes: routes ?? const {},
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              disableAnimations: true,
              textScaler: textScaler,
            ),
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

  /// Fails on ANY exception raised during the pump above — there are no
  /// allowlisted overflows. (A former 1px desktop overflow in the adventure
  /// bar identity Column was traced to its true cause — the 1.5px border
  /// eats 3px of the 58px box, leaving 45px for 46px of font-metric text —
  /// and fixed with pinned 1.25 line heights, so the allowlist was removed
  /// rather than carried forward.)
  void expectNoUnknownException(WidgetTester tester, Size size) {
    Object? exception;
    while ((exception = tester.takeException()) != null) {
      fail('Unexpected exception at $size: $exception');
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

      // The quick-zone rail duplicates island labels above the action dock;
      // it shows on wide layouts (room to spare) and hides on compact
      // (phones), where world names live once on the islands ringing the
      // map instead of crowding Mini Games / Star Shop.
      testWidgets(
          'quick-zone rail shows on wide, hides on compact ($label)',
          (tester) async {
        await pumpWorldMap(tester, size: size, themeMode: mode);

        expect(
          find.byKey(const ValueKey('quick-zone-rail')),
          size.width < 980 ? findsNothing : findsOneWidget,
        );
        expectNoUnknownException(tester, size);
      });

      if (size.width < 980) {
        testWidgets('compact map exposes the adventure menu ($label)',
            (tester) async {
          await pumpWorldMap(tester, size: size, themeMode: mode);

          expect(find.byTooltip('Adventure menu'), findsOneWidget);
          await tester.tap(find.byTooltip('Adventure menu'));
          await tester.pump();

          expect(find.text('Settings'), findsOneWidget);
          expect(find.text('Daily challenges'), findsOneWidget);
          expectNoUnknownException(tester, size);
        });

        // Compact renders a slim summary bar above the dock (the floating
        // lens covered ~40% of a 390px map); details open as a sheet.
        testWidgets(
            'compact quest bar opens details without losing action ($label)',
            (tester) async {
          await pumpWorldMap(tester, size: size, themeMode: mode);

          expect(
            find.byKey(const ValueKey('compact-quest-bar')),
            findsOneWidget,
          );
          expect(find.byType(WorldMapQuestLens), findsNothing);

          // Timed pumps, not pumpAndSettle: the map's ambient animations
          // never settle, so pumpAndSettle times out.
          await tester.tap(find.byTooltip('Quest details'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          expect(find.text('Enter Zone'), findsWidgets);
          expect(find.byTooltip('Collapse quest details'), findsOneWidget);

          Navigator.of(tester.element(find.text('Enter Zone').first)).pop();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          expect(
            find.byKey(const ValueKey('compact-quest-bar')),
            findsOneWidget,
          );
          expectNoUnknownException(tester, size);
        });
      }
    }
  }

  // 200% text-scale coverage (Phase 3 of docs/PROMPT_MD_EXECUTION_TRACKER.md):
  // main.dart's global text-scale clamp used to cap the real platform
  // setting down to 1.28x, so nothing had ever exercised this screen at a
  // genuine 200% scale. Limited to the narrowest phone breakpoint (the
  // highest-risk case) rather than the full viewport x theme matrix, to
  // keep this addition focused on proving the clamp fix is actually safe
  // rather than re-running the whole existing matrix at a second scale.
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    final label = '${mode.name} 360x640 @200% text';

    testWidgets('world map renders without exceptions ($label)',
        (tester) async {
      await pumpWorldMap(
        tester,
        size: const Size(360, 640),
        themeMode: mode,
        textScaler: const TextScaler.linear(2.0),
      );

      expectNoUnknownException(tester, const Size(360, 640));
    });

    testWidgets('world map shows HUD, zones, and quest content ($label)',
        (tester) async {
      await pumpWorldMap(
        tester,
        size: const Size(360, 640),
        themeMode: mode,
        textScaler: const TextScaler.linear(2.0),
      );

      expect(find.textContaining('Explorer'), findsWidgets);
      expect(find.textContaining('Word Woods'), findsWidgets);
      expect(find.textContaining('Number Nebula'), findsWidgets);
      expectNoUnknownException(tester, const Size(360, 640));
    });

    testWidgets('compact quest bar opens details ($label)', (tester) async {
      await pumpWorldMap(
        tester,
        size: const Size(360, 640),
        themeMode: mode,
        textScaler: const TextScaler.linear(2.0),
      );

      expect(
        find.byKey(const ValueKey('compact-quest-bar')),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Quest details'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byTooltip('Collapse quest details'), findsOneWidget);
      expect(find.text('Enter Zone'), findsWidgets);
      expectNoUnknownException(tester, const Size(360, 640));
    });
  }

  // The pawn must genuinely walk the shared BoardPath route frame-by-frame.
  // It used to sample its position only when the parent rebuilt, so travel
  // rendered as a 1.2s freeze followed by a jump to the destination.
  testWidgets('pawn walks the board route into an unlocked zone',
      (tester) async {
    const size = Size(1366, 768);
    await pumpWorldMap(
      tester,
      size: size,
      themeMode: ThemeMode.light,
      storage: _SeededStarStorageService(),
      routes: {
        '/number-nebula': (_) =>
            const Scaffold(body: Center(child: Text('zone route reached'))),
      },
    );

    Offset pawnTopLeft() {
      final finder = find.byType(AnimatedCharacter);
      expect(finder, findsOneWidget,
          reason: 'the travelling pawn is the only AnimatedCharacter');
      Positioned? positioned;
      final chain = <String>[];
      finder.evaluate().single.visitAncestorElements((node) {
        final widget = node.widget;
        chain.add(widget.runtimeType.toString());
        // The pawn's internal Stack also uses Positioned (bottom/right
        // anchored); the route anchor is the one with left+top set.
        if (widget is Positioned && widget.left != null && widget.top != null) {
          positioned = widget;
        }
        return true;
      });
      final box = positioned;
      expect(box, isNotNull,
          reason: 'pawn must sit inside a Positioned; chain: $chain');
      expect(box!.left, isNotNull);
      expect(box.top, isNotNull);
      return Offset(box.left!, box.top!);
    }

    final start = pawnTopLeft();

    // Number Nebula (index 1) needs 3 stars; the seeded storage reports
    // exactly one mastered skill, which is exactly 3 stars.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 300));
    final early = pawnTopLeft();
    expect(early, isNot(start),
        reason: 'pawn position must tick during travel instead of freezing');

    await tester.pump(const Duration(milliseconds: 300));
    final later = pawnTopLeft();
    expect(later, isNot(early),
        reason: 'pawn keeps walking the route frame-by-frame');

    // Ride out arrival (1250ms), then the 400ms beat: the delayed push is
    // scheduled *during* the arrival frame, so it needs its own elapsed
    // pump before the route exists.
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('zone route reached'), findsOneWidget,
        reason: 'arrival must navigate into the target zone');

    expectNoUnknownException(tester, size);
  });
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

/// Storage stub that reports one mastered skill so the test avatar holds
/// the 3 stars that unlock Number Nebula (zone index 1), letting the
/// pawn-travel test exercise real route walking instead of the locked
/// dialog.
class _SeededStarStorageService extends _FakeMapStorageService {
  @override
  Future<List<Skill>> getAllSkills() async => [
        Skill(
          id: 'skill_place_value',
          name: 'Place Value',
          description: 'Seeded mastery for the pawn travel test',
          strand: 'Numeracy',
          state: SkillState.mastered,
          lastPracticed: DateTime(2026, 1, 1),
        ),
      ];
}
