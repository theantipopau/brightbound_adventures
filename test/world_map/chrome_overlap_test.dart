// Systematic overlap net for the world map: instead of eyeballing
// screenshots, assert that no zone island's laid-out box intersects any
// chrome box (top HUD, action dock, compact quest bar, quest lens) at
// any supported viewport. RenderBox rects exclude paint effects like
// shadows/glows, so any reported intersection is a real layout collision.
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/screens/world_map/world_map_quest_lens.dart';
import 'package:brightbound_adventures/ui/screens/world_map_screen.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _zoneIds = [
  'word-woods',
  'number-nebula',
  'math-facts',
  'story-springs',
  'science-explorers',
  'creative-corner',
  'puzzle-peaks',
  'adventure-arena',
];

Future<void> _pumpMap(
  WidgetTester tester, {
  required Size size,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final store = _OverlapStorage();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioManager>.value(value: AudioManager()),
        ChangeNotifierProvider<AvatarProvider>(
          create: (_) => _OverlapAvatar(),
        ),
        ChangeNotifierProvider<SkillProvider>(
          create: (_) => SkillProvider(store),
        ),
        ChangeNotifierProvider<StreakService>(create: (_) => StreakService()),
        ChangeNotifierProvider<CosmeticUnlockService>.value(
            value: CosmeticUnlockService()),
        ChangeNotifierProvider<DailyChallengeService>(
            create: (_) => DailyChallengeService(store)),
        ChangeNotifierProvider<SpacedRepetitionService>(
            create: (_) => SpacedRepetitionService()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
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
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 1600));
}

void main() {
  final sizes = [
    const Size(390, 844),
    const Size(360, 640),
    const Size(768, 1024),
    const Size(1366, 768),
  ];

  for (final size in sizes) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';
    final compact = size.width < 980;

    testWidgets('no island-vs-chrome overlap at $label', (tester) async {
      await _pumpMap(tester, size: size);

      Rect box(ValueKey<String> key) {
        final finder = find.byKey(key);
        expect(finder, findsOneWidget, reason: '$key must exist at $label');
        return tester.getRect(finder);
      }

      final chrome = <String, Rect>{
        'top-hud': box(const ValueKey('top-hud')),
        'action-dock': box(const ValueKey('action-dock')),
        if (compact)
          'compact-quest-bar': box(const ValueKey('compact-quest-bar')),
        if (!compact) ...{
          for (final lens in find.byType(WorldMapQuestLens).evaluate())
            'quest-lens': tester.getRect(find.byWidget(lens.widget)),
        },
      };

      // Chrome itself must sit inside the screen.
      final screen = Offset.zero & size;
      for (final entry in chrome.entries) {
        expect(
          screen.contains(entry.value.topLeft) &&
              screen.contains(entry.value.bottomRight),
          isTrue,
          reason: '${entry.key} ${entry.value} escapes the $label screen',
        );
      }

      // No island may touch any chrome box.
      for (final id in _zoneIds) {
        final island = box(ValueKey('zone-island-$id'));
        for (final entry in chrome.entries) {
          expect(
            island.intersect(entry.value).isEmpty,
            isTrue,
            reason: 'island $id $island overlaps ${entry.key} '
                '${entry.value} at $label',
          );
        }
      }

      Object? exception;
      while ((exception = tester.takeException()) != null) {
        fail('Unexpected exception at $label: $exception');
      }
    });
  }

  testWidgets('no island-vs-chrome overlap at 360x640 @200% text',
      (tester) async {
    const size = Size(360, 640);
    await _pumpMap(
      tester,
      size: size,
      textScaler: const TextScaler.linear(2.0),
    );

    Rect box(ValueKey<String> key) {
      final finder = find.byKey(key);
      expect(finder, findsOneWidget, reason: '$key must exist at 200%');
      return tester.getRect(finder);
    }

    final chrome = <String, Rect>{
      'top-hud': box(const ValueKey('top-hud')),
      'action-dock': box(const ValueKey('action-dock')),
      'compact-quest-bar': box(const ValueKey('compact-quest-bar')),
    };

    for (final id in _zoneIds) {
      final island = box(ValueKey('zone-island-$id'));
      for (final entry in chrome.entries) {
        expect(
          island.intersect(entry.value).isEmpty,
          isTrue,
          reason:
              'island $id $island overlaps ${entry.key} ${entry.value} at 200%',
        );
      }
    }

    Object? exception;
    while ((exception = tester.takeException()) != null) {
      fail('Unexpected exception at 200%: $exception');
    }
  });
}

class _OverlapAvatar extends AvatarProvider {
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

class _OverlapStorage extends LocalStorageService {
  @override
  Future<List<Skill>> getAllSkills() async => [];

  @override
  Future<void> saveSkill(Skill skill) async {}

  @override
  Future<Avatar?> getAvatar() async => null;

  @override
  List<DailyChallenge> getDailyChallenges(String dateString) => [];
}
