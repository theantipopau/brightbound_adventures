# v2.1 "Living World" — Roadmap & File Tracker

**Created:** 20 July 2026
**This is the working document.** Tick boxes as tasks land; every task lists the exact files to create/modify/delete.
**Detail specs:** [Execution Plan](V2_1_RELEASE_EXECUTION_PLAN.md) (task definitions, owners) · [3D & Visual Spec](V2_1_3D_VISUAL_DIRECTION.md) (art + rendering detail) · [Premium Audit](V2_1_PREMIUM_AUDIT_AND_ROADMAP.md) (rationale, acceptance criteria).

---

## How to work through this document

1. **Pick the topmost unchecked task in the current sprint.** Dependencies are already encoded in the ordering — don't skip ahead within a sprint's "sequence" list.
2. **Branch:** `feat/<task-id-lowercase>` off `main` (e.g. `feat/mo-1-motion-tokens`).
3. **Read the task's spec section** (linked per task) before coding.
4. **Verify before PR** (every task, no exceptions):

```powershell
& 'E:\Flutter\flutter\bin\dart.bat' format --output=none --set-exit-if-changed lib test
& 'E:\Flutter\flutter\bin\flutter.bat' analyze
& 'E:\Flutter\flutter\bin\flutter.bat' test
& 'E:\Flutter\flutter\bin\flutter.bat' build web --release   # release-touching tasks only
```

5. **Tick the box here, note the date + PR** in the same commit as the merge.
6. File conventions: `CREATE` = new file · `MODIFY` = edit existing · `DELETE` = remove after confirming no imports (grep first) · `MOVE` = git mv, keep history.

---

## Target end-state structure (what the repo looks like when v2.1 ships)

New/changed areas only; everything else stays where it is today.

```text
lib/
  ui/
    themes/
      app_theme.dart                    (slimmed: builds ThemeData from tokens)
      motion_tokens.dart                NEW  MO-1
      semantic_colors.dart              NEW  VS-1  (ThemeExtension)
      zone_palettes.dart                NEW  VS-1  (ThemeExtension, 8 zones × light/dark)
      shape_tokens.dart                 NEW  VS-1  (radii, spacing, elevation)
      index.dart                        (exports all of the above)
    transitions/
      app_routes.dart                   NEW  MO-2  (zone-entry, sheet, celebration routes)
      transitions.dart                  MOVED from ui/widgets/  MO-2
    components/                         NEW  VS-3  (the component kit)
      adventure_scaffold.dart
      surface_card.dart                 (standard/feature/reward/quest/modal variants)
      pressable.dart                    NEW  MO-3  (shared press/juice behaviour)
      tilt_card.dart                    NEW  A3D-6
      badges.dart  progress_bars.dart  stat_chips.dart
      app_states.dart                   (empty/loading/error)
  features/
    world_map/                          REBUILT  WM-2..WM-6, A3D-1..5
      models/
        world_map_view_model.dart       NEW  WM-2   (pure, no Flutter imports)
        zone_view_state.dart            NEW  WM-2   (the 7-state enum + per-zone data)
        quest_lens_model.dart           NEW  WM-2
      services/
        map_scene_builder.dart          NEW  WM-2   (view model → immutable scene data)
        map_asset_manifest.dart         NEW  A3D-2  (typed manifest loader + fallbacks)
        recommendation_service.dart     NEW  RE-2
      screens/
        world_map_screen.dart           NEW shell ≤300 lines  WM-4 (replaces 5,541-line file)
      widgets/
        adventure_bar.dart              NEW  WM-4
        living_board.dart               NEW  WM-4  (camera + layer stack host)
        quest_lens.dart                 NEW  WM-4  (side/bottom/sheet variants)
        adventure_menu.dart             NEW  WM-4  (replaces action dock)
        zone_node.dart                  NEW  WM-5  (renders ZoneViewState)
        map_pawn.dart                   NEW  A3D-4 (sprite pawn, hop arcs, shadow)
        iso_sprite.dart                 NEW  A3D-2
      painters/
        board_painter.dart              MOVED/upgraded from ui/painters/terrain_painter.dart  A3D-7
        route_painter.dart              MOVED from ui/painters/path_painter.dart
        effects_painter.dart            NEW  A3D-1 (one-shot celebration layer)
      tokens/
        map_metrics.dart                NEW  WM-4  (breakpoints, regions, camera limits)
  core/services/
    reward_transaction_service.dart     NEW  RE-1
    (existing services unchanged; shop/achievement/streak called THROUGH RE-1)
  features/interactions/                NEW  IN-1  (shared interaction framework)
    framework/
      interaction_scaffold.dart  drag_primitives.dart  snap_targets.dart
      interaction_result.dart    hint_system.dart
    types/
      drag_to_order.dart          IN-2
      number_line.dart            IN-3
      sort_into_bins.dart         IN-4
      tap_evidence.dart           IN-5

assets/
  images/map/                           NEW  WM-7/8  (see 3D spec §4.3 for full tree)
    islands/  landmarks/  props/  routes/  pawn/  effects/  sky/
  map_manifest.json                     NEW  A3D-2
  art/PROMPTS.md                        NEW  WM-7   (append-only generation log)

test/
  world_map/
    world_map_regression_test.dart      DONE WM-1  (structural baseline; pixel goldens still a follow-up)
    world_map_view_model_test.dart      NEW  WM-2
    zone_states_golden_test.dart        NEW  WM-5  (7 states × 2 themes)
    map_scene_perf_test.dart            NEW  A3D-8
  services/
    reward_transaction_test.dart        NEW  RE-1
    recommendation_service_test.dart    NEW  RE-2
  interactions/
    interaction_framework_test.dart     NEW  IN-1
    (one test per interaction type)     IN-2..5
  tools/
    color_inventory_test.dart           NEW  VS-2  (fails if direct colours exceed budget)
    content_dead_end_test.dart          NEW  CO-1/CO-2

.github/workflows/
  ci.yml                                NEW  CO-4

DELETED by end of release:
  lib/ui/screens/world_map_screen.dart      (old monolith — after WM-4)
  lib/ui/screens/placeholder_zone_screen.dart (WM-9 / CO-1)
  lib/ui/widgets/fantasy_map.dart            (WM-9)
```

---

## Sprint 1 (wk 1–2) — Foundation

*Everything else builds on these five. MO-1/VS-1/WM-1/RE-1/CO-4 are independent — parallelisable across sessions. A3D-7 is a free visual win.*

- [x] **CO-4 · CI pipeline** — [plan §4F](V2_1_RELEASE_EXECUTION_PLAN.md) — done 2026-07-20
  - MODIFIED the existing `.github/workflows/build-deploy.yml` rather than creating a separate `ci.yml` (it already had analyze/build-web/deploy jobs): added a `test` job (`flutter test`) gating `build-web`, widened the format check to cover `test/` as well as `lib/`, and widened the PR trigger from `[main, develop]` to `['**']` so feature branches get CI too.
  - Done-when not literally re-verified (would need a real PR to observe CI fail on a format error), but the format/analyze/test steps are the exact commands run locally throughout this session and all pass.
- [x] **MO-1 · Motion tokens** — [plan §4A] — done 2026-07-20
  - CREATED `lib/ui/themes/motion_tokens.dart` exactly as specified, plus `test/ui/themes/motion_tokens_test.dart` (2 tests: normal + reduced-motion collapse). Reduced-motion resolves via the existing `MediaQuery.disableAnimations` flag (already combines platform + in-app preference in `main.dart`) rather than reading `VisualAccessibilityService` directly.
  - Discovered `AppMotion` (a pre-existing, non-context-aware static duration/curve class in `app_theme.dart`) is already used in 10 files; doc-marked it as superseded, migration tracked under MO-2/MO-3 below.
- [x] **VS-1 · Semantic theme extensions** — [plan §4E] — done 2026-07-20
  - CREATED `semantic_colors.dart`, `zone_palettes.dart` (8 zones × primary/secondary/glow/route × light/dark, snake_case zone ids matching gameplay models), `shape_tokens.dart`; registered on both `AppTheme.lightTheme()`/`darkTheme()`; `test/ui/themes/semantic_theme_extensions_test.dart` (8 tests) confirms resolution in both themes plus a swatch-distinctness check (no golden image, per the WM-1 cross-platform-goldens rationale).
  - Confirmed by grep: 58 pre-existing call sites across 13 files still bypass brightness via raw `AppColors.*`; doc-marked as VS-2 migration work, not done here.
- [x] **WM-1 · Map safety-net tests (BEFORE any map refactor)** — [plan §4B] — done 2026-07-20
  - CREATED `test/world_map/world_map_regression_test.dart` (not `world_map_golden_test.dart` — renamed; see below): 18 tests, current monolith at 360×640/768×1024/1366×768 × light/dark, covering render-without-exception, HUD/zone/quest content, and zone semantics.
  - **Deviation from the original plan:** this does NOT do `matchesGoldenFile` pixel comparison. CI runs ubuntu-latest; this suite was authored on Windows, and font/AA differences would likely fail a Windows-baselined golden on first CI run for reasons unrelated to real regressions. **Follow-up:** baseline true pixel goldens from the CI (Linux) runner when convenient — the structural tests are a safety net in the meantime, not a replacement.
  - Found and fixed 3 real bugs while writing this (see CHANGELOG_CODEX.md 2026-07-20): a negative-margin crash on keyboard focus (`world_map_screen.dart`), a `JuicyButton` label overflow (`juicy_button.dart`), a "Quest reward" row label overflow (`world_map_screen.dart`).
  - **2 known issues intentionally allowlisted in the test** (exact size + message, so anything new/larger still fails) rather than patched: a 1.00px hairline overflow at 1366×768 (debug-only, not worth blind-patching), and the ~176px top-HUD overflow at 360×640 — the latter **is** the P0 "no overlap/clipping at 360×640" acceptance criterion and should be resolved by **WM-4**, not patched piecemeal. Delete that allowlist entry when WM-4 lands.
  - Also fixed: a test-scaffolding trap where `CosmeticUnlockService` (a `factory` singleton) must be provided via `.value(value: ...)`, never `create: (_) => ...` — the latter causes Provider to `dispose()` the shared singleton, poisoning every later test in the process. `AudioManager` is the same pattern; already handled correctly.
- [x] **RE-1 · Atomic reward transaction (service done; call-site migration NOT done)** — [plan §4D] — service done 2026-07-20
  - CREATED `lib/core/services/reward_transaction_service.dart`: `QuestOutcome` (input) → `RewardResult` (output), applied via `apply()`. Idempotent by `outcomeId`: caches results in-memory AND persists to SharedPreferences (`reward_transactions_v1`, capped at 50 entries) *before* returning, so a fresh `RewardTransactionService` instance backed by the same prefs (i.e. after an app restart) replays the identical result instead of re-awarding — this is tested directly (`test/services/reward_transaction_test.dart`, 6 tests: fresh apply, level-boundary crossing, repeat-apply, two-different-outcomes, restart-survival via a second service instance + `peek()`, no-avatar path).
  - MODIFIED `lib/core/services/service_registry.dart` + `lib/main.dart` to construct/provide it. MODIFIED `lib/core/services/shop_service.dart`: `awardStarsForActivity` now returns the star count it awarded (`Future<int>`, was `Future<void>`) so the transaction can report it — backward compatible, all 3 existing callers already discarded the return value.
  - **NOT done: call-site migration.** Investigated migrating `lib/features/literacy/widgets/quiz_results_screen.dart` (the most complete example) and found the fragmentation is worse than the audit's description implies: `lib/features/literacy/screens/skill_practice_screen.dart`'s `_onGameComplete()` *already* does its own independent achievement (`achievementService.updateProgress('achievement_stars_25', ...)` etc.) and daily-challenge tracking *before* `QuizResultsScreen` even mounts and runs its *separate* `_processResults()` (which calls the differently-named `trackQuestionAnswered`/`trackPerfectScore`). These are two divergent reward-tracking code paths for one quiz completion, not one. Reconciling them safely needs to be understood and tested as its own task — attempting it as a bolt-on here, in a screen with zero existing reward-flow tests, risked a real regression for no Sprint-1-scoped benefit. **Follow-up:** this reconciliation naturally belongs to **IN-7** (session pacing) and **MO-4** (reward reveal) in Sprint 5, which already touch these same screens — do the migration there, not as a standalone task.
  - Done-when items not yet met: "no screen mutates stars/XP/streak directly" — still false; grep still finds direct `avatarProvider.addExperience`/`shopService.awardStarsForActivity`/`achievementService.updateProgress` calls in `quiz_results_screen.dart`, `skill_practice_screen.dart`, `numeracy_results_screen.dart`, `science_results_screen.dart`, `boss_battle_screen.dart`, `logic_practice_screen.dart`, `motor_practice_screen.dart`, `story_practice_screen.dart`.
- [x] **A3D-7 · Procedural 3D painter upgrade** — [3D spec §6/A3D-7](V2_1_3D_VISUAL_DIRECTION.md) — done 2026-07-20
  - MODIFIED `lib/ui/painters/terrain_painter.dart`: each zone island's top-face diamond now sits on an extruded 24px platform with two side faces (HSL lightness −16%/−26% for left/right, faking a top-left light source), a rounded bottom seam, a tighter AO ellipse under the extrusion (in addition to the existing ambient glow), and a darker rim inset on the top face.
  - MODIFIED `lib/ui/painters/path_painter.dart`: the animated travel dots get a small offset drop-shadow + top-left highlight (glossy "bead" look) instead of a flat filled circle — the lightweight version of "path nodes get the same treatment," since this codebase doesn't yet have discrete stamped route nodes (that's part of the WM-3/WM-6 route rebuild).
  - **Not done: before/after screenshot.** Could not capture one — `flutter run -d web-server` served the app cleanly (asset requests 200 OK, no console/server errors) but the Browser-pane `computer screenshot` tool itself timed out repeatedly, including on a freshly opened tab, which points at an environment/tool limitation rather than an app problem. Confidence instead comes from: `flutter analyze` clean, the full 66-test suite passing (including the WM-1 structural regression tests, which exercise `TerrainPainter` through `WorldMapScreen` and assert no render exceptions), and the extrusion math being plain vertex geometry with no external unknowns. **Follow-up:** grab a real screenshot/recording next time a working browser/device is available, for the PR record and to sanity-check the visual proportions (24px depth, corner radius) against the art direction in the 3D spec.
  - Added `.claude/launch.json` (`flutter run -d web-server --web-port 5959`) so future sessions can preview the app via the `run` skill / Browser pane without rediscovering the Flutter SDK path.

**Sprint exit:** CI green on a clean checkout · tokens/extensions merged · 6 map goldens recorded · rewards atomic.

**Sprint 1 status (2026-07-20): substantially complete.** All 6 tasks landed; two deliberate deviations are carried forward rather than hidden: (1) WM-1 uses structural/regression tests instead of pixel goldens (cross-platform goldens deferred — see WM-1 note); (2) RE-1's service is done and tested, but call-site migration is explicitly deferred to Sprint 5 (IN-7/MO-4) after discovering two divergent reward-tracking code paths per activity screen. Everything else met its done-when bar on a clean local checkout (format/analyze/test all green, 66 tests passing). Commits: `9b187e2`, `5e73797`, `5697a65`, `82e02a7`, `7119f49`, `eaeec33`, `032fedd` on `codex/rpg-map-ui-loop`.

---

## Sprint 2 (wk 3–4) — Feel + Model

*Sequence: MO-2 → MO-3 any time; WM-2 before Sprint 3. Art track starts in parallel.*

- [x] **MO-2 · Shared transition kit** — [plan §4A] — done 2026-07-21
  - CREATED `lib/ui/transitions/app_routes.dart` (`ZoneEntryRoute`/`SheetRoute`/`CelebrationRoute`, all `MotionTokens`-driven). MOVED `lib/ui/widgets/transitions.dart` → `lib/ui/transitions/transitions.dart`, dropping 2 confirmed-dead classes (`AnswerFeedbackAnimation`, a duplicate unused `ResponsiveHelper`) found while moving it.
  - MODIFIED the one real ad-hoc `PageRouteBuilder` (`mini_games_screen.dart`) and 9 `FadeSlidePageRoute` call sites across `world_map_screen.dart`/`zone_detail_screen.dart` to use the new semantic routes.
  - Done-when met with one documented exception: `main.dart`'s `onGenerateRoute` catch-all still uses `FadeSlidePageRoute` (now living in `lib/ui/transitions/`, so technically not "ad-hoc" or "outside" the folder) because `onGenerateRoute` receives no `BuildContext` to resolve `MotionTokens` from. Follow-up if this matters later: thread a context through (e.g. a navigator observer or restructuring route generation inside a `Builder`).
- [x] **MO-3 · Juice pass / Pressable** — [plan §4A] — done 2026-07-28
  - CREATED `lib/ui/components/pressable.dart` (single `AnimationController` driving press scale 1.0→0.96, keyboard activation Enter/Space, hover/focus tracking, optional haptic). Headless: builder receives `PressableState` to render decoration.
  - MODIFIED `lib/ui/widgets/juicy_button.dart` (rebuilt on Pressable, kept shimmer as separate 2s loop, tilt derived from press scale to preserve 0.9 feel, uses `MotionTokens.of(context).quick` for transitions).
  - CREATED tests: `test/ui/components/pressable_test.dart` (6 tests: tap, disabled, press animation, reduced motion, long press), `test/ui/widgets/juicy_button_test.dart` (8 baseline safety-net tests). All 84 tests passing; JuicyButton rebuild verified backward-compatible.
  - Partial: Did NOT migrate the 10 `AppMotion` call sites to `MotionTokens.of(context)` (numeracy_game.dart, multiple_choice_game.dart, science_game.dart, responsive_quiz_layout.dart, animated_answer_option.dart, skill_widgets.dart, quiz_widgets.dart, glowing_card.dart, animated_score_counter.dart) — those are NOT built on Pressable and deserve their own focused pass. Scope clarification: only `animated_answer_option.dart` (answer press-down) explicitly needed for shared behaviour; the others are separable. This follow-up is tracked as a subtask under Sprint 3/Sprint 4's motion cull work (MO-4/MO-5).
- [ ] **WM-2 · WorldMapViewModel extraction** — [plan §4B] — part 1 done 2026-07-28
  - **Part 1 (Done):** CREATED `lib/features/world_map/models/world_map_view_model.dart` (pure model: `calculateTotalStars`, `isZoneUnlocked`, `recommendedZoneIndex`, `zoneProgressFraction`, `zoneMoodText`, `zoneFeatureTags` — zero Flutter imports). CREATED `test/world_map/world_map_view_model_test.dart` (8 unit tests). All logic proven testable in isolation.
  - **Part 2 (Pending):** MODIFY `lib/ui/screens/world_map_screen.dart` — monolith now *reads* the ViewModel instead of reimplementing; all unlock/progress/recommendation logic becomes a single ViewModel instance, constructed at the top of build().
  - Done when: world_map_screen.dart no longer contains duplicated unlock/progress logic; model-layer tests cover the extracted functions.
- [x] **VS-2 (start) · Colour inventory** — [plan §4E] — done 2026-07-28
  - CREATED `test/tools/color_inventory_test.dart` (counts `Color(0x`, `Colors.` per file; asserts per-file budget against a committed, shrinking-only allowlist; unlisted files with usage fail the test).
  - Done when: inventory report is in CI output (via `flutter test` stdout); baseline recorded here: **2506 direct colours across 87 files** (2026-07-28). Largest: `world_map_screen.dart` (295), `app_theme.dart` (158, token-definition file), `fantasy_map.dart` (126).
  - Known debt from VS-1 (confirmed by grep, 2026-07-20): 58 occurrences of `AppColors.textPrimary`/`textSecondary`/`surface` across 13 files bypass brightness entirely, incl. `avatar_creator_screen.dart` (15), `world_map_screen.dart` (5), `skill_widgets.dart` (5), `animated_answer_option.dart` (5), `zone_detail_screen.dart` (4). These are exactly the call sites `SemanticColors`/`ZonePalettes` (VS-1) exist to replace — the inventory test now makes any regression in this debt visible and blocked, but migrating the 58 sites themselves is still open, separate work (full VS-2 migration pass, not yet scheduled).
- [ ] **WM-7 (start, art track) · Art bible + global asset set** — [3D spec §4–5]
  - CREATE `assets/art/PROMPTS.md`, first global assets under `assets/images/map/{islands,routes,sky}/`, `assets/map_manifest.json` (schema per 3D spec §4.4).
  - MODIFY `pubspec.yaml` (asset folders).
  - Done when: island bases ×3, gate pair, route stamps, clouds ×3 pass the 3D-spec §4.5 QA checklist. **Gate: Matt approves style.**

**Sprint exit:** all navigation uses the kit · map logic is pure and tested · art pipeline producing approved assets.

**Status as of 2026-08-02:** `main` is synced through MO-3/WM-2 pt.1/VS-2 (CI: Analyze/Test/Build Web all green). Deploy jobs (`Deploy Website`/`Deploy Flutter Game` to Cloudflare Pages) are wired up correctly but blocked on missing `CLOUDFLARE_API_TOKEN`/`CLOUDFLARE_ACCOUNT_ID` repo secrets — needs repo admin to set these in GitHub Settings → Secrets and variables → Actions. Local `wrangler` deploy is also blocked, by an unrelated malformed Windows `PATH` entry (`C:\Program Files\nodejs"`, stray trailing quote) breaking `node` resolution for npm-spawned install scripts.

---

## Sprint 3 (wk 5–6) — Map Rebuild I

*Sequence: WM-3 → WM-4 → MO-5; RE-2 parallel; A3D-1/A3D-2 land inside WM-3.*

- [ ] **WM-3 · Split the monolith** — [plan §4B; structure tree above]
  - CREATE the `lib/features/world_map/{widgets,painters,tokens}` files listed in the target tree, including `iso_sprite.dart` (A3D-2) and the layer stack in `living_board.dart` (A3D-1: sky/board/route/scene/effects/hud, each behind `RepaintBoundary`, pawn depth-sorted with props).
  - MOVE `lib/ui/painters/terrain_painter.dart` → `world_map/painters/board_painter.dart`, `path_painter.dart` → `route_painter.dart` (update `lib/ui/painters/` consumers; `shadow_painter.dart` folds into `iso_sprite.dart`).
  - Done when: no file in `world_map/` exceeds ~600 lines; WM-1 goldens still pass (pixel-tolerant rebaseline allowed once, documented in PR).
- [ ] **WM-4 · Three-region responsive shell** — [plan §4B]
  - CREATE `screens/world_map_screen.dart` (new ≤300-line shell), `widgets/{adventure_bar,quest_lens,adventure_menu}.dart`, `tokens/map_metrics.dart`.
  - MODIFY `lib/ui/screens/index.dart` + route registrations to point at the new screen. DELETE `lib/ui/screens/world_map_screen.dart` (the old monolith) in the same PR.
  - Done when: desktop = board+side lens, tablet = bottom collapsible lens, phone = pannable board + quest sheet; goldens re-recorded at 3 breakpoints × 2 themes.
- [ ] **MO-5 · Ambient motion cull** — [plan §4A]
  - MODIFY `lib/ui/widgets/visual_effects/*` call sites; document every surviving loop in a `// MOTION:` comment with justification.
  - Done when: idle map runs ≤1 subtle loop on capable layouts, zero under reduced motion.
- [ ] **RE-2 · Recommendation service** — [plan §4D]
  - CREATE `world_map/services/recommendation_service.dart` (+ test): Continue/Review/Challenge/Daily/Boss with reason strings, fed by `QuestSessionHistoryService`, `SpacedRepetitionService`, `DailyChallengeService`.
  - MODIFY `map_scene_builder.dart` (recommended state into zone view states), `quest_lens.dart` (shows reason + reward preview).
  - Done when: lens explains *why* ("You missed fractions twice — let's review") from real history in tests.

**Sprint exit:** old monolith deleted · three-region shell on all form factors · recommendations live on the map.

---

## Sprint 4 (wk 7–8) — Map Rebuild II + Interactions I

- [ ] **WM-5 · Zone state language** — [plan §4B; treatments in 3D spec §5.6]
  - MODIFY `zone_node.dart` (7 states: locked/available/recommended/in-progress/needs-review/boss-ready/mastered — visual + motion + semantic label each).
  - CREATE `test/world_map/zone_states_golden_test.dart` (7 × 2 themes = 14 goldens).
- [ ] **WM-6 · Travel choreography + A3D-3/4/5** — [plan §4B; 3D spec §6]
  - CREATE `widgets/map_pawn.dart` (sprite pawn, hop arcs, dynamic shadow — A3D-4; pawn frames into `assets/images/map/pawn/`).
  - MODIFY `living_board.dart` (camera pan/zoom + parallax + depth haze — A3D-5; hover lift physics — A3D-3), reuse `IsometricMovementController` from `lib/core/utils/isometric_engine.dart`.
  - Done when: travel = anticipation → path hops → settle → door opens, 700–1000 ms, reduced-motion = fade-move.
- [ ] **WM-9 · Retire legacy**
  - DELETE `lib/ui/widgets/fantasy_map.dart`, `lib/ui/screens/placeholder_zone_screen.dart` (grep imports first; placeholder deletion may slip to CO-1 if practice screens still route there).
- [ ] **IN-1 · Interaction framework** — [plan §4C]
  - CREATE `lib/features/interactions/framework/*` (see target tree) + `test/interactions/interaction_framework_test.dart` (drag primitives, snap targets, forgiving hit areas ≥48 px, keyboard-equivalent paths).
- [ ] **WM-8 (art track) · Zone families 2–5** — one PR per zone, 3D-spec checklist each.
- [ ] **CO-8 · Playtest #1 (Matt)** — capture friction as issues tagged `playtest-1`.

**Sprint exit:** 14 zone-state goldens green · pawn travel shipped · framework merged · 5/8 zones authored.

---

## Sprint 5 (wk 9–10) — Interactions II + Reward Loop

- [ ] **IN-2 · Drag-to-order** — CREATE `interactions/types/drag_to_order.dart` (+test); MODIFY `story_practice_screen.dart`, literacy `skill_practice_screen.dart` to route sequencing questions to it.
- [ ] **IN-3 · Number line & quantity drag** — CREATE `types/number_line.dart` (+test); MODIFY `numeracy_practice_screen.dart` / `numeracy_game.dart`.
- [ ] **IN-4 · Sort-into-bins** — CREATE `types/sort_into_bins.dart` (+test); MODIFY science + literacy practice screens.
- [ ] **IN-5 · Tap-the-evidence** — CREATE `types/tap_evidence.dart` (+test); MODIFY literacy comprehension flow.
- [ ] **MO-4 · Choreographed reward reveal** — [plan §4A]
  - CREATE `lib/ui/components/reward_reveal.dart` (sequenced: stars → XP → callout queue → next card; consumes `RewardResult` from RE-1 only).
  - MODIFY `quiz_results_celebration.dart` call sites to the new reveal; retire overlapping one-shot celebration widgets.
- [ ] **RE-3 · Visible world change** — MODIFY `zone_node.dart`/`map_scene_builder.dart` (decoration tiers, mastery flags from `CosmeticUnlockService`).
- [ ] **RE-4 · Near-miss visibility** — MODIFY `reward_reveal.dart`, `shop_screen.dart` ("2 more stars for…").
- [ ] **WM-8 (art track) · Zone families 6–8** — all zones authored; dark emissive overlays (3D spec §5.5) wired.
- [ ] **A3D-6 · TiltCard** — CREATE `lib/ui/components/tilt_card.dart`; MODIFY `modern_shop_item_card.dart`, zone detail header, reward chest reveal.

**Sprint exit (the demo gate):** one full quest uses ≥2 non-MCQ interactions and ends in the new reveal with a visible world change — record the capture.

---

## Sprint 6 (wk 11–12) — Completion

- [ ] **IN-6 · Generator wiring** — MODIFY `question_loader_service.dart`, `question_variation_engine.dart`, zone generators in `lib/core/utils/` to emit interaction types with MCQ fallback; `adaptive_difficulty_service.dart` + `question_freshness_service.dart` treat them first-class.
- [ ] **IN-7 · Session pacing** — MODIFY `zone_detail_screen.dart` / practice screens: intro beat → question beats + mid-quest surprise → results beat, via MO-2 routes.
- [ ] **CO-1 · Dead-end elimination** — MODIFY the 5 confirmed files (`literacy/screens/skill_practice_screen.dart`, `storytelling/screens/story_practice_screen.dart`, `logic/screens/logic_practice_screen.dart`, `numeracy/screens/numeracy_practice_screen.dart`) + finish `placeholder_zone_screen.dart` deletion. CREATE `test/tools/content_dead_end_test.dart` (greps for coming-soon markers; CI-enforced).
- [ ] **CO-2 · Content evidence matrix** — CREATE `assets/content_matrix.json` + generator script `lib/scripts/` + CI check.
- [ ] **VS-3 · Component kit completion** — CREATE remaining `lib/ui/components/*` (target tree); migrate shop/results/settings/parent screens; deprecate one-off widgets (`glowing_card.dart` etc.) as they lose consumers.
- [ ] **VS-4 · Dark composition** — MODIFY `app_theme.dart` + component kit (tonal separation, dark elevation); high-contrast composes.
- [ ] **VS-2 (finish)** — allowlist reaches **0 on critical screens** (map, quest, results, shop, settings, parent).
- [ ] **VS-5 · 200% text pass** — widget tests at `textScaleFactor: 2.0` for critical journeys.

**Sprint exit:** zero reachable placeholders (CI-proven) · colour inventory 0 on critical screens · dark mode designed, not derived.

---

## Sprint 7 (wk 13–14) — Harden + Ship

- [ ] **CO-3 · Parent weekly insight** — MODIFY `parent_dashboard_screen.dart`; reuse RE-2 model (7/30-day trends, review-due with evidence, plain-language data note).
- [ ] **MO-6 + A3D-8 · Motion/perf proof** — CREATE `test/world_map/map_scene_perf_test.dart`; record frame budgets (idle repaint ≈ 0, travel ≥ 55 fps low-end web) in the PR.
- [ ] **CO-5 · Accessibility device pass (Matt+Agent)** — keyboard journeys, semantics on painted zones, TalkBack/VoiceOver spot checks, targets ≥48 px. Findings → issues → fixed or waived in writing.
- [ ] **CO-6 · Claims audit (Matt)** — MODIFY `README.md`, `website/` copy: every claim supported or softened.
- [ ] **CO-7 · Release runbook** — CREATE `docs/RELEASE_RUNBOOK.md` (deploy, rollback, service-worker update, offline reload, production smoke list).
- [ ] **CO-8 · Playtest #2 (Matt)** — blockers fixed; nice-to-haves → v2.2 backlog.
- [ ] **SHIP** — version bump to `2.1.0` in `pubspec.yaml` · CHANGELOG entry · `flutter build web --release` → `wrangler pages deploy` · production smoke per runbook · tag `v2.1.0`.

**Release gate:** all Definition-of-Done items in [Execution Plan §6](V2_1_RELEASE_EXECUTION_PLAN.md) checked.

---

## Progress ledger

| Sprint | Status | Started | Finished | Notes |
|---|---|---|---|---|
| 1 — Foundation | substantially complete | 2026-07-20 | 2026-07-20 | RE-1 call-site migration deferred to Sprint 5; WM-1 pixel goldens deferred (structural tests in place) |
| 2 — Feel + Model | not started | | | |
| 3 — Map Rebuild I | not started | | | |
| 4 — Map Rebuild II + Interactions I | not started | | | |
| 5 — Interactions II + Rewards | not started | | | |
| 6 — Completion | not started | | | |
| 7 — Harden + Ship | not started | | | |

**Standing rules:** WM-1 goldens before ANY map change · new UI code imports tokens, never raw colours/durations · every DELETE preceded by an import grep · art PRs = one zone each with the QA checklist pasted in · this file is updated in the same PR as the work.
