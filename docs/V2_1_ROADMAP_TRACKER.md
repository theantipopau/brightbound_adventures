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
& 'F:\Flutter\flutter\bin\dart.bat' format --output=none --set-exit-if-changed lib test
& 'F:\Flutter\flutter\bin\flutter.bat' analyze
& 'F:\Flutter\flutter\bin\flutter.bat' test
& 'F:\Flutter\flutter\bin\flutter.bat' build web --release   # release-touching tasks only
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

- [ ] **CO-4 · CI pipeline** — [plan §4F](V2_1_RELEASE_EXECUTION_PLAN.md)
  - CREATE `.github/workflows/ci.yml`: format → analyze → test → `build web --release` on PR; upload golden failures as artifacts.
  - Done when: a PR with a format error fails CI.
- [ ] **MO-1 · Motion tokens** — [plan §4A]
  - CREATE `lib/ui/themes/motion_tokens.dart` (durations: instant 100/quick 180/standard 250/emphasised 400/celebration 700–1000 ms; curves: standard/enter/exit/bounce/elastic; `MotionTokens.of(context)` resolver that collapses to fades when `VisualAccessibilityService.reducedMotion`).
  - MODIFY `lib/ui/themes/index.dart` (export).
  - Done when: tokens exist with doc comments + a unit test asserting reduced-motion collapse.
- [ ] **VS-1 · Semantic theme extensions** — [plan §4E]
  - CREATE `lib/ui/themes/semantic_colors.dart`, `zone_palettes.dart` (8 zones × primary/secondary/glow/route × light/dark), `shape_tokens.dart`.
  - MODIFY `lib/ui/themes/app_theme.dart` (register extensions on both ThemeData), `index.dart`.
  - Done when: `Theme.of(context).extension<ZonePalettes>()` resolves in both themes; golden of a token swatch sheet.
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
- [ ] **A3D-7 · Procedural 3D painter upgrade** — [3D spec §6/A3D-7](V2_1_3D_VISUAL_DIRECTION.md)
  - MODIFY `lib/ui/painters/terrain_painter.dart` (extruded platforms: lit top face, −25%/−40% side faces, 24 px thickness, rounded corners, AO ellipse), `lib/ui/painters/path_painter.dart` (nodes get same treatment).
  - Done when: WM-1 goldens intentionally re-recorded with the new look; before/after screenshot in PR.

**Sprint exit:** CI green on a clean checkout · tokens/extensions merged · 6 map goldens recorded · rewards atomic.

---

## Sprint 2 (wk 3–4) — Feel + Model

*Sequence: MO-2 → MO-3 any time; WM-2 before Sprint 3. Art track starts in parallel.*

- [ ] **MO-2 · Shared transition kit** — [plan §4A]
  - CREATE `lib/ui/transitions/app_routes.dart` (`ZoneEntryRoute` scale-from-node, `SheetRoute` spring slide, `CelebrationRoute`). MOVE `lib/ui/widgets/transitions.dart` → `lib/ui/transitions/`.
  - MODIFY every `Navigator.push` call site using bespoke `PageRouteBuilder`s (grep `PageRouteBuilder` across `lib/`) to use the kit.
  - Done when: zero ad-hoc `PageRouteBuilder` outside `lib/ui/transitions/`.
- [ ] **MO-3 · Juice pass / Pressable** — [plan §4A]
  - CREATE `lib/ui/components/pressable.dart` (press scale 0.96 + shadow drop + optional haptic/sound, tokens from MO-1).
  - MODIFY `lib/ui/widgets/juicy_button.dart` (rebuild on Pressable), `animated_answer_option.dart` (press-down, correct-bounce, wrong-shake via tokens).
  - Done when: buttons/answers across literacy+numeracy screens share one behaviour.
  - Known debt from MO-1 (confirmed by grep, 2026-07-20): `AppMotion` (the static duration/curve consts in `app_theme.dart`, now doc-marked superseded) is still used in 10 files — `numeracy_game.dart`, `multiple_choice_game.dart`, `science_game.dart`, `responsive_quiz_layout.dart`, `animated_answer_option.dart`, `skill_widgets.dart`, `quiz_widgets.dart`, `juicy_button.dart`, `glowing_card.dart`, `animated_score_counter.dart`. Migrate these to `MotionTokens.of(context)` as part of this task.
- [ ] **WM-2 · WorldMapViewModel extraction** — [plan §4B]
  - CREATE `lib/features/world_map/models/{world_map_view_model,zone_view_state,quest_lens_model}.dart`, `services/map_scene_builder.dart`, `test/world_map/world_map_view_model_test.dart`.
  - MODIFY `lib/ui/screens/world_map_screen.dart` — monolith now *reads* the view model; all provider reads move to the top.
  - Done when: view model has zero Flutter imports; unlock/progress/recommendation logic unit-tested without widgets.
- [ ] **VS-2 (start) · Colour inventory** — [plan §4E]
  - CREATE `test/tools/color_inventory_test.dart` (counts `Color(0x`, `Colors.` per file; asserts per-file budget with a committed allowlist that only shrinks).
  - Done when: inventory report is in CI output; baseline recorded here: `_____ direct colours`.
  - Known debt from VS-1 (confirmed by grep, 2026-07-20): 58 occurrences of `AppColors.textPrimary`/`textSecondary`/`surface` across 13 files bypass brightness entirely, incl. `avatar_creator_screen.dart` (15), `world_map_screen.dart` (5), `skill_widgets.dart` (5), `animated_answer_option.dart` (5), `zone_detail_screen.dart` (4). These are exactly the call sites `SemanticColors`/`ZonePalettes` (VS-1) exist to replace.
- [ ] **WM-7 (start, art track) · Art bible + global asset set** — [3D spec §4–5]
  - CREATE `assets/art/PROMPTS.md`, first global assets under `assets/images/map/{islands,routes,sky}/`, `assets/map_manifest.json` (schema per 3D spec §4.4).
  - MODIFY `pubspec.yaml` (asset folders).
  - Done when: island bases ×3, gate pair, route stamps, clouds ×3 pass the 3D-spec §4.5 QA checklist. **Gate: Matt approves style.**

**Sprint exit:** all navigation uses the kit · map logic is pure and tested · art pipeline producing approved assets.

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
| 1 — Foundation | not started | | | |
| 2 — Feel + Model | not started | | | |
| 3 — Map Rebuild I | not started | | | |
| 4 — Map Rebuild II + Interactions I | not started | | | |
| 5 — Interactions II + Rewards | not started | | | |
| 6 — Completion | not started | | | |
| 7 — Harden + Ship | not started | | | |

**Standing rules:** WM-1 goldens before ANY map change · new UI code imports tokens, never raw colours/durations · every DELETE preceded by an import grep · art PRs = one zone each with the QA checklist pasted in · this file is updated in the same PR as the work.
