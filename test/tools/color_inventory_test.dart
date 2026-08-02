import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Per-file ceiling on direct `Color(0x...)` / `Colors.foo` usages under
/// `lib/`, keyed by POSIX-style path relative to the repo root.
///
/// This is a *shrinking-only* allowlist: it is fine (expected!) for a
/// file's count to drop below its ceiling as call sites migrate to
/// `SemanticColors`/`ZonePalettes`/`ShapeTokens` (VS-1) — when that
/// happens, lower the number here so it can't silently creep back up.
/// It is NOT fine for a count to rise above its ceiling, or for a new
/// file with direct color usage to appear unlisted: both fail this test,
/// on the theory that new code should reach for the semantic tokens
/// first, and any exception should be a deliberate, reviewed addition to
/// this map rather than a silent drift.
///
/// Baseline recorded 2026-07-28 (VS-2 start), reflecting the state left by
/// VS-1: token *definition* files (`app_theme.dart`, `semantic_colors.dart`,
/// `zone_palettes.dart`) and procedural painters that need literal shading
/// colors are included at their real counts, not exempted — the point of
/// this test is visibility into the total, not letting any file opt out.
const Map<String, int> _colorUsageAllowlist = {
  'lib/ui/screens/world_map_screen.dart': 295,
  'lib/ui/themes/app_theme.dart': 158,
  'lib/ui/widgets/fantasy_map.dart': 126,
  'lib/ui/screens/parent_dashboard_screen.dart': 118,
  'lib/ui/screens/avatar_creator_screen.dart': 118,
  'lib/ui/screens/mini_games_screen.dart': 72,
  'lib/features/logic/widgets/logic_game.dart': 67,
  'lib/ui/themes/zone_palettes.dart': 64,
  'lib/features/numeracy/widgets/numeracy_game.dart': 61,
  'lib/ui/screens/boss_battle_screen.dart': 59,
  'lib/features/storytelling/widgets/story_game.dart': 55,
  'lib/main.dart': 53,
  'lib/features/science/widgets/science_game.dart': 48,
  'lib/ui/screens/world_entry_screen.dart': 46,
  'lib/features/literacy/widgets/multiple_choice_game.dart': 43,
  'lib/ui/widgets/skill_widgets.dart': 40,
  'lib/ui/screens/zone_detail_screen.dart': 40,
  'lib/ui/themes/semantic_colors.dart': 39,
  'lib/features/logic/widgets/logic_results_screen.dart': 39,
  'lib/ui/screens/daily_challenge_screen.dart': 37,
  'lib/ui/screens/shop_screen.dart': 36,
  'lib/features/motor/widgets/motor_game.dart': 36,
  'lib/ui/widgets/animated_answer_option.dart': 35,
  'lib/ui/widgets/animated_character.dart': 34,
  'lib/ui/screens/onboarding_screen.dart': 33,
  'lib/ui/screens/profile_stats_screen.dart': 32,
  'lib/features/storytelling/widgets/story_results_screen.dart': 32,
  'lib/ui/widgets/streak_widget.dart': 29,
  'lib/features/motor/widgets/motor_results_screen.dart': 29,
  'lib/features/literacy/widgets/quiz_results_screen.dart': 27,
  'lib/ui/widgets/quiz_results_celebration.dart': 26,
  'lib/ui/widgets/modern_shop_item_card.dart': 26,
  'lib/features/mini_games/pattern_puzzle_game.dart': 26,
  'lib/ui/widgets/reward_animations.dart': 24,
  'lib/ui/widgets/achievement_card.dart': 24,
  'lib/ui/screens/trophy_room_screen.dart': 24,
  'lib/ui/widgets/quiz_widgets.dart': 23,
  'lib/features/science/widgets/science_results_screen.dart': 21,
  'lib/features/mini_games/word_search_game.dart': 20,
  'lib/ui/widgets/zone_mastered_celebration.dart': 19,
  'lib/ui/widgets/xp_widgets.dart': 19,
  'lib/ui/widgets/mastery_certificate.dart': 18,
  'lib/ui/widgets/level_up_dialog.dart': 17,
  'lib/ui/widgets/daily_challenge_card.dart': 17,
  'lib/ui/widgets/avatar_widgets.dart': 17,
  'lib/ui/widgets/achievement_notification.dart': 17,
  'lib/features/numeracy/widgets/numeracy_results_screen.dart': 17,
  'lib/features/mini_games/memory_match_game.dart': 17,
  'lib/ui/widgets/juicy_button.dart': 16,
  'lib/ui/widgets/streak_milestone_modal.dart': 14,
  'lib/ui/widgets/loading_screen.dart': 14,
  'lib/ui/widgets/graphics_helpers.dart': 14,
  'lib/ui/widgets/enhanced_zone_header.dart': 14,
  'lib/ui/screens/settings_screen.dart': 12,
  'lib/ui/widgets/responsive_quiz_layout.dart': 11,
  'lib/features/storytelling/screens/story_practice_screen.dart': 11,
  'lib/features/logic/screens/logic_practice_screen.dart': 11,
  'lib/ui/screens/mastery_certificate_screen.dart': 10,
  'lib/ui/painters/path_painter.dart': 10,
  'lib/core/services/animation_service.dart': 9,
  'lib/features/motor/models/motor_game.dart': 8,
  'lib/ui/painters/terrain_painter.dart': 7,
  'lib/core/services/streak_enhanced_service.dart': 7,
  'lib/ui/widgets/tracing_widget.dart': 6,
  'lib/features/science/screens/science_practice_screen.dart': 6,
  'lib/core/models/daily_challenge.dart': 6,
  'lib/core/models/shop_item.dart': 5,
  'lib/ui/widgets/visual_effects/animated_cloud_background.dart': 4,
  'lib/core/models/achievement.dart': 4,
  'lib/ui/widgets/streak_badge.dart': 3,
  'lib/ui/widgets/star_burst_overlay.dart': 3,
  'lib/ui/widgets/gradient_text.dart': 3,
  'lib/ui/widgets/animated_score_counter.dart': 3,
  'lib/features/numeracy/screens/numeracy_practice_screen.dart': 3,
  'lib/ui/widgets/zone_guardian_banner.dart': 2,
  'lib/ui/widgets/wave_progress_bar.dart': 2,
  'lib/ui/widgets/visual_effects/particle_background.dart': 2,
  'lib/ui/widgets/rpg_character.dart': 2,
  'lib/ui/widgets/glowing_card.dart': 2,
  'lib/ui/transitions/transitions.dart': 2,
  'lib/ui/widgets/visual_effects/pulse_effect.dart': 1,
  'lib/ui/widgets/difficulty_indicator.dart': 1,
  'lib/ui/widgets/branded_back_button.dart': 1,
  'lib/ui/screens/placeholder_zone_screen.dart': 1,
  'lib/ui/painters/shadow_painter.dart': 1,
  'lib/ui/components/pressable.dart': 1,
  'lib/features/literacy/screens/skill_practice_screen.dart': 1,
};

final RegExp _colorLiteral =
    RegExp(r'Color\(0x[0-9A-Fa-f]{6,8}\)|Colors\.[A-Za-z][A-Za-z0-9]*');

/// Finds the repo root by walking up from this test file until a
/// `pubspec.yaml` is found, so the test works regardless of the CWD the
/// test runner was invoked from.
Directory _findRepoRoot() {
  var dir = Directory.current;
  while (!File('${dir.path}${Platform.pathSeparator}pubspec.yaml')
      .existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Could not locate repo root (no pubspec.yaml found)');
    }
    dir = parent;
  }
  return dir;
}

void main() {
  test('direct Color()/Colors. usage stays within the committed allowlist',
      () {
    final repoRoot = _findRepoRoot();
    final libDir = Directory('${repoRoot.path}${Platform.pathSeparator}lib');
    expect(libDir.existsSync(), isTrue,
        reason: 'expected lib/ under repo root ${repoRoot.path}');

    final actualCounts = <String, int>{};
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final relativePath = entity.path
          .substring(repoRoot.path.length)
          .replaceAll('\\', '/')
          .replaceFirst(RegExp(r'^/'), '');
      final content = entity.readAsStringSync();
      final count = _colorLiteral.allMatches(content).length;
      if (count > 0) {
        actualCounts[relativePath] = count;
      }
    }

    final overBudget = <String>[];
    final unlisted = <String>[];

    actualCounts.forEach((path, count) {
      final budget = _colorUsageAllowlist[path];
      if (budget == null) {
        unlisted.add('$path ($count uses, not in allowlist)');
      } else if (count > budget) {
        overBudget.add('$path: $count uses > allowlisted $budget');
      }
    });

    final totalDirectColors =
        actualCounts.values.fold<int>(0, (sum, c) => sum + c);
    // ignore: avoid_print
    print('Color inventory: $totalDirectColors direct Color()/Colors. uses '
        'across ${actualCounts.length} files under lib/.');

    expect(unlisted, isEmpty,
        reason: 'New files with direct color usage must be added to the '
            '_colorUsageAllowlist in test/tools/color_inventory_test.dart '
            'with a deliberate count, not silently introduced:\n'
            '${unlisted.join('\n')}');

    expect(overBudget, isEmpty,
        reason: 'These files exceed their committed color-usage budget. '
            'Either migrate the new usages to SemanticColors/ZonePalettes, '
            'or if the increase is deliberate, raise the ceiling in '
            '_colorUsageAllowlist with a comment explaining why:\n'
            '${overBudget.join('\n')}');
  });
}
