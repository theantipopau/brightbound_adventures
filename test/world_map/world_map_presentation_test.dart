import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/features/world_map/models/world_map_view_model.dart';
import 'package:brightbound_adventures/ui/screens/world_map/world_map_adventure_bar.dart';
import 'package:brightbound_adventures/ui/screens/world_map/world_map_quest_lens.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final avatar = Avatar(
    id: 'presentation-avatar',
    name: 'Explorer Test',
    baseCharacter: 'fox',
    skinColor: '#F5D6A0',
    outfitId: 'outfit_adventure',
    createdAt: DateTime(2026, 1, 1),
    lastModified: DateTime(2026, 1, 1),
    experiencePoints: 120,
    level: 2,
  );

  final zone = const ZoneData(
    id: 'word-woods',
    name: 'Word Woods',
    emoji: '🌲',
    color: AppColors.wordWoodsColor,
    position: Offset(0.1, 0.8),
    description: 'Master letters and reading.',
    order: 0,
    requiredStars: 0,
  );

  Widget themed(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme(),
      home: Scaffold(body: Stack(children: [child])),
    );
  }

  testWidgets('Adventure Bar exposes compact destinations and callbacks',
      (tester) async {
    await tester.pumpWidget(
      themed(
        WorldMapAdventureBar(
          avatar: avatar,
          totalStars: 4,
          streak: 2,
          dailyCompleted: 1,
          dailyTotal: 3,
          reviewDue: 0,
          compact: true,
          uiScale: 1,
          onAvatarInfo: () {},
          onAvatarCreator: () {},
          onAppInfo: () {},
          onProfile: () {},
          onSettings: () {},
          onParentDashboard: () {},
          onDailyChallenges: () {},
          onMiniGames: () {},
          onShop: () {},
          onAchievements: () {},
        ),
      ),
    );

    expect(find.text('Explorer Test'), findsOneWidget);
    expect(find.textContaining('⭐ 4'), findsOneWidget);
    expect(find.byTooltip('Adventure menu'), findsOneWidget);

    await tester.tap(find.byTooltip('Adventure menu'));
    await tester.pump();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Daily challenges'), findsOneWidget);
  });

  testWidgets('Quest Lens expands and invokes its primary action',
      (tester) async {
    var expanded = false;
    var started = false;
    final stats = ZoneStats(
      zoneId: 'word_woods',
      totalSkills: 10,
      masteredSkills: 4,
      averageAccuracy: 0.8,
    );

    await tester.pumpWidget(
      themed(
        WorldMapQuestLens(
          selected: zone,
          status: const WorldMapZoneStatus(
            state: WorldMapZoneState.recommended,
            label: 'Recommended',
            reason: 'Recommended for your next quest.',
          ),
          stats: stats,
          progress: 0.4,
          rewardXp: 65,
          nextReward: null,
          rewardProgress: 0,
          rewardRequirement: null,
          nextSkillName: 'Letter Recognition',
          moodText: 'Reading trails and vocabulary quests.',
          featureIcons: const ['📚'],
          featureTags: const ['Reading'],
          isUnlocked: true,
          compact: true,
          uiScale: 1,
          expanded: false,
          isMoving: false,
          isCurrentZone: true,
          onToggleExpanded: () => expanded = true,
          onPrimaryAction: () => started = true,
          onRewardPreview: null,
        ),
      ),
    );

    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Enter Zone'), findsOneWidget);
    final action = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Enter Zone'),
    );
    final minimumSize = action.style?.minimumSize?.resolve({});
    expect(minimumSize?.height, greaterThanOrEqualTo(48));

    await tester.tap(find.byTooltip('Expand quest details'));
    await tester.pump();
    expect(expanded, isTrue);
    await tester.tap(find.text('Enter Zone'));
    expect(started, isTrue);
  });
}
