# BrightBound Adventures - Systematic Changelog

This document tracks the production improvements made during the Codex audit and enhancement pass. It is intentionally implementation-focused so future work can continue from a clear baseline.

## 2026-08-02 - Synced `main` with Sprint 2 work (MO-3, WM-2 pt.1, VS-2); fixed a real CI format/lint failure

- Fast-forward merged `codex/rpg-map-ui-loop` into `main` (clean ancestor, 0 behind/5 ahead) and pushed, bringing MO-3, WM-2 part 1, and VS-2 onto the default branch.
- Watching the resulting CI run surfaced a real failure: 3 files (`world_map_view_model.dart`, `color_inventory_test.dart`, `world_map_view_model_test.dart`) were committed without running `dart format`, failing the `Format check` step. A follow-up commit ran `dart format` on all three, and separately cleaned up two lint warnings (unused `dart:ui show Tristate` imports left over from simplifying disabled-button semantics assertions in `pressable_test.dart`/`juicy_button_test.dart`, and a dead `tapped` variable in the latter, replaced with a real tap+`takeException` assertion).
- Re-ran the workflow after the fix: **Analyze, Test, and Build Web all pass.** Only `Deploy Website to Cloudflare Pages` and `Deploy Flutter Game to Cloudflare Pages` fail, and only because `CLOUDFLARE_API_TOKEN`/`CLOUDFLARE_ACCOUNT_ID` repo secrets are still unset (confirmed via `gh secret list` — empty) — not a code or workflow defect. Setting those secrets requires repo admin access to GitHub Settings → Secrets and variables → Actions; not something fixable from code.
- Attempted a local `wrangler pages deploy` as an alternative path and found the local Windows environment's `PATH` has a malformed entry (`C:\Program Files\nodejs"` — a literal stray trailing quote), which breaks `cmd.exe`'s resolution of `node` when `npm`/`npx` spawn install scripts as subprocesses. Every attempt to install `wrangler` locally (`npx wrangler`, `npm install -g wrangler`) failed partway through for this reason. Did not attempt to fix the system `PATH` directly (an environment/system-settings change, left for the user). Local wrangler deploy remains blocked until either the PATH is corrected or the CI secrets are set and the GitHub Actions path is used instead.

## 2026-07-28 - Colour inventory CI check (VS-2, start)

- Added `test/tools/color_inventory_test.dart`: counts every direct `Color(0x...)` / `Colors.foo` usage under `lib/`, per file, and asserts each stays within a committed allowlist. The allowlist is shrinking-only by design — a count is allowed to drop (as call sites migrate to `SemanticColors`/`ZonePalettes`/`ShapeTokens` from VS-1) but never silently rise, and any new file with direct color usage that isn't already in the allowlist fails the test outright, forcing a deliberate reviewed addition rather than quiet drift.
- **Baseline recorded 2026-07-28: 2506 direct colours across 87 files.** The three largest offenders are `world_map_screen.dart` (295 — mostly its own zone/HUD styling, a WM-3/WM-4 rebuild target), `app_theme.dart` (158 — largely legitimate, it's the token-definition file itself), and `fantasy_map.dart` (126).
- Deliberately did **not** exempt `app_theme.dart`/`semantic_colors.dart`/`zone_palettes.dart` from counting even though they're the token *definitions* and legitimately need literal colors — the test's job is total visibility, not letting any file opt out; their ceilings just aren't expected to shrink much.
- This is the CI-visibility half of VS-2. The actual migration of the 58 `AppColors.textPrimary`/`textSecondary`/`surface` call sites flagged in MO-3/VS-1 notes (bypassing light/dark entirely) is separate follow-on work — this task's job was making regressions in that debt visible and blocked, not fixing it in one pass.

## 2026-07-28 - WorldMapViewModel extraction foundation (WM-2, part 1)

- Created `lib/features/world_map/models/world_map_view_model.dart`: pure model logic extracted from the 5570-line `world_map_screen.dart`, zero Flutter imports. Methods: `calculateTotalStars()`, `isZoneUnlocked()`, `recommendedZoneIndex()`, `zoneProgressFraction()`, `zoneMoodText()`, `zoneFeatureTags()`. All are unit-testable pure functions.
- Created `test/world_map/world_map_view_model_test.dart`: 8 tests covering zone unlock logic (boundary conditions, star requirements), progress calculation, and flavor text. All passing.
- **Scope note:** This is the foundation layer of WM-2. The monolithic `world_map_screen.dart` still contains the view model logic; next step is to refactor the screen to *read* the extracted ViewModel instead of implementing that logic inline. That refactoring (modifying world_map_screen.dart to use the new ViewModel) is a separate followup — this commit extracts the pure logic and proves it's testable.
- All 91 tests passing (84 existing + 8 new, - 1 from ViewModel test naming).

## 2026-07-28 - Pressable component + JuicyButton rebuild (MO-3)

- Added `lib/ui/components/pressable.dart`: headless interaction primitive owns a single `AnimationController` driving press-scale, keyboard activation (Enter/Space), hover/focus tracking, and optional haptic feedback — but draws nothing itself. Callers provide a `builder` to render decoration (gradient, shadow, border) driven by `PressableState` (scale/isPressed/isHovered/isFocused/enabled). This exists so all pressable surfaces in the app (buttons, cards, answer options, zone nodes) share one interaction implementation instead of hand-rolling separate `GestureDetector` + `AnimationController` + focus logic.
- Rebuilt `lib/ui/widgets/juicy_button.dart` on top of `Pressable`: removed dual `AnimationController`s (press + shimmer), kept shimmer as a separate 2s loop, and derived tilt from the shared press scale (`tilt = -(1.0 - state.scale) * 0.3` to preserve the 0.9 press-scale feel). Uses `MotionTokens.of(context).quick` for the AnimatedContainer's color/shadow transitions instead of hard-coded 200ms.
- Tests for both: `test/ui/components/pressable_test.dart` (6 tests covering tap, disabled semantics, press animation, reduced motion, long press) and `test/ui/widgets/juicy_button_test.dart` (8 baseline safety-net tests — label/emoji render, tap trigger, disabled state, loading indicator, press without throw, label ellipsis, shimmer, factories). All 70+ tests passing; JuicyButton rebuild verified backward-compatible by the safety-net suite.
- Updated `lib/ui/components/` and `test/ui/components/` as new directories, mirroring the existing `widgets/` structure for reusable interaction primitives.

## 2026-07-21 - Shared transition kit (MO-2)

- Added `lib/ui/transitions/app_routes.dart`: `ZoneEntryRoute` (scale-up entry, from a tapped element's `originRect` if given, else center), `SheetRoute` (modal-feeling slide-up with a spring overshoot), `CelebrationRoute` (bigger playful scale+fade, for reward reveals). All three read `MotionTokens.of(context)` from the pushing context, so reduced motion is handled automatically. Tests in `test/ui/transitions/app_routes_test.dart` (4 tests) cover navigation for each route plus a reduced-motion completion case.
- Moved `lib/ui/widgets/transitions.dart` to `lib/ui/transitions/transitions.dart`. While moving it, deleted two confirmed-dead classes it contained: `AnswerFeedbackAnimation` and a duplicate `ResponsiveHelper` (a same-named, unrelated class already exists and is actively used at `lib/core/utils/responsive_helper.dart`) — grepped the whole of `lib/` first to confirm neither had any consumer.
- Migrated every real ad-hoc `PageRouteBuilder` and semantically-fitting `FadeSlidePageRoute` call site to the new kit: the one true ad-hoc route (`mini_games_screen.dart`'s game launch) and 9 `FadeSlidePageRoute` call sites across `world_map_screen.dart`/`zone_detail_screen.dart` — modal-feeling navigations (profile, settings, parent dashboard, achievements) to `SheetRoute`; activity/quest entries (boss battle, practice screens, mini-games menu, daily challenges) to `ZoneEntryRoute`.
- Left `main.dart`'s `onGenerateRoute` catch-all on `FadeSlidePageRoute`: it has no `BuildContext` to resolve `MotionTokens` from (`onGenerateRoute: (settings) => ...` doesn't receive one), and mixes both zone-entry and modal-style destinations in one generic handler. `FadeSlidePageRoute` now lives in the transitions folder, so this still satisfies "no ad-hoc `PageRouteBuilder` outside `lib/ui/transitions/`" — it just isn't using a *semantic* route yet.

## 2026-07-21 - Synced `main` with Sprint 1 work; fixed real CI failures found by watching it run

- Fast-forward merged `codex/rpg-map-ui-loop` into `main` (main was 19 commits behind, cleanly ancestor-of, no divergence) and pushed, so the GitHub repo's default branch/README now reflects the rebuilt README, all v2.1 planning docs, and Sprint 1's code changes instead of the pre-audit state.
- Watching the resulting `Build & Deploy` Actions run surfaced two real, previously-failing issues (the two most recent runs on `main` before this had also failed, for the same reasons — not something this session introduced, just newly visible):
  1. `actions/upload-artifact@v3`/`download-artifact@v3` are hard-blocked by GitHub now ("automatically failed because it uses a deprecated version"), not just deprecated — this was failing the `Build Web`/`Build Android`/`Build iOS` jobs outright. Bumped all to `@v4` in `.github/workflows/build-deploy.yml`.
  2. `wrangler` requires Node >= 20; the workflow's `setup-node` steps were pinned to `'18'`. Bumped to `'20'` (and `setup-node` itself from `@v3` to `@v4`).
  3. `Format check` had been failing on `main` prior to this session (`dart format --set-exit-if-changed lib`, no `test/`) — already fixed by the CO-4 change in this session's Sprint 1 work; confirmed the `Analyze` job now passes on the real runner.
- **Still failing, not fixable from code:** `Deploy Website to Cloudflare Pages` fails because `CLOUDFLARE_API_TOKEN`/`CLOUDFLARE_ACCOUNT_ID` repo secrets are empty. `Deploy Flutter Game` will hit the same wall. These need to be set in the repo's Settings -> Secrets and variables -> Actions by someone with admin access; not something fixable in this session.
- Verified the rebuilt README's links resolve: the live-demo badge (`playbrightbound.matthurley.dev`) loads, and the `docs/V2_1_PREMIUM_AUDIT_AND_ROADMAP.md`/`CHANGELOG_CODEX.md` relative links resolve correctly on GitHub's `main` branch view.

## 2026-07-20 - Procedural 3D map painter upgrade (A3D-7) + stale SDK path fix

- Upgraded `lib/ui/painters/terrain_painter.dart`: each zone island is now an extruded isometric platform (24px thickness) with two shaded side faces (HSL lightness -16%/-26%, faking a top-left light source), a rounded bottom seam, a tight ambient-occlusion ellipse under the extrusion, and a darker rim inset on the top face — replacing the previous flat rhombus-plus-glow look. Zero new assets required.
- Polished `lib/ui/painters/path_painter.dart`'s animated travel dots with a drop shadow + top-left highlight (glossy "bead" look).
- Could not capture a before/after screenshot: the app served correctly (`flutter run -d web-server`, clean console/server logs, 200s on all asset requests) but the available screenshot tooling timed out in this environment, reproducing on a fresh tab. Confidence instead comes from `flutter analyze` being clean, the full 66-test suite passing (including the WM-1 structural tests that exercise this painter through `WorldMapScreen`), and the extrusion being straightforward vertex geometry.
- Fixed a stale documented Flutter SDK path: `docs/`, `README.md` said `F:\Flutter\flutter`; the SDK is actually at `E:\Flutter\flutter` on this machine now. Updated all current-instruction docs (README, NEXT_STEPS, the roadmap tracker, FLUTTER_TOOLING_SETUP, VS_CODE_PROBLEMS_TRIAGE) to the correct path; left the historical changelog entry from when `F:\` was correct untouched.
- Added `.claude/launch.json` (`flutter run -d web-server --web-port 5959`) so a future session can preview the app via the Browser pane without rediscovering the SDK location.

## 2026-07-20 - Atomic reward transaction service (RE-1, foundation only)

- Added `lib/core/services/reward_transaction_service.dart`: `RewardTransactionService.apply(QuestOutcome) -> RewardResult` applies XP/level, stars (via `ShopService`), streak (via `StreakService`), and achievement/cosmetic unlock detection as one operation, idempotent by `outcomeId`. Persists to SharedPreferences *before* returning, so a killed-and-relaunched app replays the same result instead of re-earning anything — verified directly in `test/services/reward_transaction_test.dart` by constructing a second service instance against the same prefs.
- Modified `ShopService.awardStarsForActivity` to return the star count awarded (`Future<int>`, was `Future<void>`); confirmed backward-compatible (all 3 existing callers discard the return value).
- Registered via `ServiceRegistry`/`main.dart` alongside the other app-lifetime services.
- **Explicitly not done in this pass:** rerouting existing quest-completion call sites to use the new service. Attempted to migrate the literacy results screen and discovered `skill_practice_screen.dart` and `quiz_results_screen.dart` each run their *own independent* achievement/streak/daily-challenge tracking for the same quiz completion — two divergent fragmented paths, not one. Reconciling both safely is real work that deserves its own focused pass with proper before/after verification, not a bolt-on to this task. Tracked as part of Sprint 5's IN-7/MO-4, which already touch these screens for session pacing and reward reveal.

## 2026-07-20 - World map safety-net tests + real bug fixes found by them (WM-1)

- Added `test/world_map/world_map_regression_test.dart`: 18 tests (3 viewports x 2 themes x 3 checks) covering `WorldMapScreen` renders without exceptions, shows HUD/zone/quest content, and exposes accessible zone semantics. Recorded *before* the WM-2..WM-6 map rebuild so that work has a regression net.
- Scope note: does not use `matchesGoldenFile` pixel comparison — CI runs on ubuntu-latest while this suite was authored on Windows, and font/AA differences would likely fail a Windows-baselined golden on first CI run for reasons unrelated to real regressions. Pixel goldens should be baselined from the CI runner as a fast-follow.
- Writing this test surfaced and fixed a real crash: `_ZoneIslandState`'s keyboard-navigation focus halo used `Container(margin: EdgeInsets.all(-(16 * pulse)))`, which is *always* negative and therefore always fails `Container`'s `margin.isNonNegative` assertion — the app would crash in debug mode any time a zone had keyboard focus (which happens on initial map load via autofocus). Fixed by replacing the negative margin with `Transform.scale` (`world_map_screen.dart`).
- Fixed two real `RenderFlex` overflows: `JuicyButton`'s label wasn't `Flexible` (`juicy_button.dart`), and the "Quest reward" preview row's label wasn't `Flexible` (`world_map_screen.dart`) — both now ellipsize instead of overflowing when their container is narrow.
- Shaved two small fixed gaps (6px→4px) in the zone-card icon column that were causing sub-2px `RenderFlex` bottom overflows at certain viewport/scale combinations.
- Two pre-existing overflows remain, explicitly allowlisted in the test by exact size + message (so anything new or larger still fails):
  1. A 1.00px hairline overflow at the 1366x768 desktop breakpoint (non-compact layout branch) — debug-assertion-only, invisible in release builds, not worth patching blindly without knowing which of many Columns is 1px too tall.
  2. A ~176px overflow in the top HUD Row at the 360x640 phone breakpoint — the top HUD packs a player chip, 3 nav buttons, and 4 stat badges into one non-`Flexible` Row with no width budget. This is not a small patch; it is *exactly* the P0 acceptance criterion ("no overlap/clipping at 360x640") that task **WM-4** (three-region responsive shell) exists to fix properly. Redesigning the HUD ahead of that rebuild risks new bugs in a screen about to be replaced. This allowlist entry should be deleted the moment WM-4 lands.
- Fixed an unrelated test-scaffolding bug found while building the harness: `CosmeticUnlockService` is a process-wide singleton (`factory` constructor); providing it via `ChangeNotifierProvider(create: ...)` instead of `.value(value: ...)` caused Provider to call `dispose()` on the shared singleton when the first test's tree unmounted, permanently poisoning it for every test that ran afterward in the same process. This is a trap any test touching `CosmeticUnlockService` or `AudioManager` (also a singleton) can hit.

## 2026-07-20 - Semantic theme extensions (VS-1)

- Added `lib/ui/themes/semantic_colors.dart`: `SemanticColors` `ThemeExtension` with light/dark values for success/warning/info/reward, text tones, correct/incorrect feedback, and subtle/disabled surfaces. Dark values are tonally separated (own dark palette), not the light palette darkened by alpha.
- Added `lib/ui/themes/zone_palettes.dart`: `ZonePalettes` `ThemeExtension` with light/dark primary/secondary/glow/route colours for all 8 zones, keyed by the snake_case zone ids already used by `skill_database.dart`/`player_stats.dart`/`daily_challenge.dart` (`word_woods`, `number_nebula`, ...). `forZone()` normalizes kebab-case input too.
- Added `lib/ui/themes/shape_tokens.dart`: `ShapeTokens` extension mirroring the existing `AppBorders`/`AppSpacing` constants, so the future component kit (VS-3) can read radii/spacing/elevation the same way it reads colours.
- Registered all three extensions on both `AppTheme.lightTheme()` and `darkTheme()`.
- Marked `AppColors`, `AppMotion`, and `WorldTokens` in `app_theme.dart` with doc comments pointing at their replacements; a grep confirms 58 existing call sites still read `AppColors.textPrimary`/`textSecondary`/`surface` directly, bypassing brightness — that migration is scoped to VS-2 (Sprint 2+), not this task.
- Discovered `AppMotion` was already in active use in 10 files; it cannot be reduced-motion-aware (static consts, no `BuildContext`), which is exactly why `MotionTokens` (MO-1) exists. Call-site migration is scoped to MO-2/MO-3.

## 2026-07-20 - Motion tokens (MO-1)

- Added `lib/ui/themes/motion_tokens.dart`: named durations (instant/quick/standard/emphasised/celebration), named curves (standard/enter/exit/bounce/elastic), and press/hover distances, all resolved via `MotionTokens.of(context)`.
- Reduced motion is resolved through the existing `MediaQuery.disableAnimations` flag (already combines platform preference and the in-app accessibility toggle in `main.dart`) rather than re-reading `VisualAccessibilityService` directly, so there is exactly one source of truth.
- Celebration timing intentionally collapses to `standard` (not zero) under reduced motion, since reward-reveal sequences carry information, not just decoration.
- New animation code should consume these tokens instead of hard-coding `Duration`/`Curve` literals; this is the foundation the transition kit, juice pass, and reward reveal (MO-2..4) build on.

## 2026-07-20 - CI: test gate and full-branch coverage (CO-4)

- `build-deploy.yml`: format check now covers `test/` as well as `lib/`, matching the local verification commands.
- Added a dedicated `test` job (`flutter test`) that gates the web build; `build-web` now depends on `test` passing, not just `analyze`.
- Pull requests from any branch now trigger CI (previously only `main`/`develop` PRs did), so feature branches get the same signal before merge.
- Regenerated `.dart_tool/package_config.json` via `flutter pub get`; it had stale absolute paths from a different machine/user (`Charlotte Hurley` profile) that broke `dart format`/`analyze` locally.

## 2026-07-20 - v2.1 Release Planning Suite

- Added `docs/V2_1_RELEASE_EXECUTION_PLAN.md`: workstreams, task IDs, owners, and a 7-sprint roadmap for the v2.1 "Living World" release.
- Added `docs/V2_1_3D_VISUAL_DIRECTION.md`: a self-contained 3D/game-visual spec — pre-rendered 2.5D isometric art direction, asset pipeline, per-zone art bible, and 8 runtime rendering tasks (A3D-1..8) building on the existing `isometric_engine.dart`.
- Added `docs/V2_1_ROADMAP_TRACKER.md`: the working checklist mapping every sprint task to exact files to create/modify/delete, plus the target end-state directory structure.
- Repointed `docs/NEXT_STEPS.md` at the tracker as the day-to-day source of truth.

## 2026-06-19 - GitHub README and v2.1 Premium Audit

- Rebuilt the GitHub README with current positioning, colourful badges, live/documentation links, asset galleries, status tables, architecture, verification, deployment, and honest release status.
- Added `docs/V2_1_PREMIUM_AUDIT_AND_ROADMAP.md`, covering unfinished functionality, a major world-map redesign, visual system, assets, motion, themes, accessibility, content, progression, parent trust, performance, architecture, delivery phases, and acceptance criteria.
- Designated the audit as the current source of truth in `docs/NEXT_STEPS.md`.
- Prioritised reachable placeholders, map test gaps, partial semantic-theme adoption, and the active map's monolithic structure as release risks.

## 2026-06-19 - Profile Progress Empty-State Fix

- Fixed `ProfileStatsScreen` so it clears loading when no avatar exists instead of showing a spinner indefinitely.
- Added a centered empty state that explains how progress begins once an avatar and quest exist.
- Made the profile header title ellipsize safely on narrow screens.
- Added `test/profile_stats_screen_test.dart` to lock the no-avatar empty state without touching Hive storage.

## 2026-06-18 - First-Run Interaction and Viewport Smoke Tests

- Added a `Surprise me` avatar creator action that randomizes character, color, starter outfit, and preview animation.
- Added a visible onboarding Back control to match the existing keyboard back navigation.
- Added an `Enter now` world-entry action so users can skip the timed intro handoff.
- Fixed world-entry badge/loading row constraints found by viewport smoke testing.
- Reworked `AnimatedCharacter` blink scheduling from uncancelable `Future.delayed` calls to a cancelable `Timer`, preventing pending animation timers after disposal.
- Added `test/startup_responsive_smoke_test.dart` covering splash, onboarding, avatar creator, and world-entry at phone portrait, tablet portrait, and laptop sizes.
- Updated `README.md` with the current first-run/replayability state and the focused viewport smoke-test command.

## 2026-06-18 - Startup, Onboarding, and Avatar GUI Polish

- Turned `ResponsiveWrapper` into a real app-level interaction wrapper with reading-order focus traversal and mouse/touch/stylus/trackpad drag support.
- Made the splash screen scroll-safe, centered, max-width constrained, and less cluttered on cramped portrait/short viewports.
- Added keyboard navigation to onboarding, centered the onboarding frame, and made static/interactive onboarding pages scroll and scale for phones, portrait tablets, and laptop windows.
- Smoothed avatar creation with a centered max-width wizard frame, trimmed two-letter name validation, reduced-motion-aware page changes, and reduced particle work.
- Changed avatar character selection to use a vertical grid on narrow portrait devices while preserving the wider paged selector.
- Shortened and centered the world-entry handoff, added reduced-motion handling for its looping animations, and constrained the intro stage for tablet/desktop readability.
- Verification: `dart format lib test`, `flutter analyze`, `flutter test`, and `flutter build web --release` pass. The release build still reports known third-party `flutter_tts_web.dart` Wasm dry-run warnings.

## 2026-06-18 - Replayability Data Spine

- Completed the Phase 0 verification loop: `dart format lib test`, `flutter analyze`, `flutter test`, and `flutter build web --release` all pass.
- Added `QuestSessionSummary` and `QuestSessionHistoryService` for local, privacy-first session history.
- Registered quest session history through `ServiceRegistry` and the app provider tree.
- Wired Numeracy, Literacy, and Science quiz completions to record session summaries with zone, skill, score, accuracy, hints used, difficulty, question IDs, and fresh/repeated question counts.
- Added `QuestionVariationHelper.buildSessionQuestionSetWithStats` so replayability systems can track novelty during question selection without breaking existing callers.
- Added tests for quest session history and question freshness stats.
- Verification: release web build successful. Remaining Wasm dry-run warnings are from third-party `flutter_tts_web.dart`.

## 2026-06-18 - Replayable RPG Roadmap

- Added `docs/REPLAYABLE_RPG_POLISH_ROADMAP.md` as the current product/engineering roadmap for replayability, RPG progression, customization, interaction variety, visual polish, parent insight, and performance hardening.
- Updated `docs/NEXT_STEPS.md` to point at the new roadmap and align the next product layer around quest replayability, reward visibility, interaction variety, and cosmetic collection loops.

## 2026-06-18 - Quiz Responsiveness, Motion, and Question Quality Pass

- Made the shared quiz layout choose side-by-side mode only when both width and height can support it, with scrollable columns to avoid clipped question/answer content.
- Reduced hover/card shadow work in shared responsive quiz controls and made those transitions respect reduced-motion preferences.
- Lightened shared answer-option shadows, skipped decorative entrance/shake effects in reduced-motion mode, and allowed longer answer labels.
- Updated the shared question card so longer prompts are no longer truncated and the card is cheaper to paint.
- Changed adaptive difficulty to start new skills at level 3 and adjust more steadily based on recent performance.
- Hardened enhanced question helpers so shuffled options are unique, correct answers are always included, and plausible wrong-answer generation cannot stall in tight ranges.
- Reworked generated homophone questions into sentence-completion prompts with meaningful distractors and explanations.
- Added focused tests for adaptive difficulty and enhanced question helper behavior.

## 2026-06-14 - Responsiveness and Animation Optimisation

- Stopped Star Shop item cards from running continuous idle pulse animations while the grid is static.
- Reduced Mini Games idle animation work by disabling always-on card floating and only pulsing the game timer during the final 10 seconds.
- Capped web particle counts and wrapped particle/cloud painters in repaint boundaries to limit background repaint cost.
- Disabled world-map ambient float/path animations on compact layouts while preserving travel and interaction animations.

## 2026-06-14 - Repository Sync and GitHub README

- Added a root `README.md` for GitHub with app overview, current product direction, local development commands, Cloudflare deployment notes, and links to current planning docs.
- Prepared the remaining local worktree changes for an intentional broad GitHub sync after the RPG map/shop branch work.
- Added a Star Shop gear summary strip using existing inventory/chest/gold visual assets to surface owned rewards, current outfit, and star balance.
- Upgraded the world-map quest reward card with cosmetic reward progress, tappable reward previews, and direct Avatar/Star Shop actions.
- Replaced the mixed legacy root `wrangler.toml` with a minimal Cloudflare Pages config using `pages_build_output_dir`.

## 2026-06-14 - RPG Loop Stabilization Start

- Added `/shop` as a first-class app route and surfaced the Star Shop from the world-map action dock.
- Added a Star Shop shortcut to the world-map avatar info sheet so character progression and item rewards are easier to discover.
- Connected successful shop outfit/accessory purchases to `AvatarProvider` unlocks.
- Added shop outfit IDs to `CosmeticsLibrary.defaultOutfits` so purchased shop outfits can resolve to visible avatar/map-pawn styling.
- Reworked the world-map safe field so zones and the avatar avoid the right quest board and bottom action dock.
- Replaced the sparse top-left HUD badge with a compact character card showing avatar, level, and XP.
- Aligned the map control rail to the quest board dimensions and spread the world positions across the playable map area.
- Updated Star Shop item details with reward-impact previews and direct outfit equip actions.
- Made purchased shop outfits auto-equip so the reward is immediately visible on the map character.
- Replaced the stale Phase 6 `docs/NEXT_STEPS.md` with a current RPG-loop stabilization plan.
- Added `test/shop_rpg_loop_test.dart` coverage for shop purchase behavior and shop outfit/avatar visual ID consistency.

## 2026-05-21 - Zone Routing and Progression Consistency Pass

- Fixed the `/number-nebula` and `/math-facts` routes so each opens the correct zone skill set.
- Added canonical zone ID normalization to `SkillProvider`, accepting route-style kebab IDs, curriculum snake IDs, display names, and emoji-prefixed names.
- Changed zone skill lookup to use `SkillDatabase` skill IDs rather than broad strand filters, preventing unrelated communication skills from leaking between Word Woods and Story Springs.
- Normalized zone IDs when launching skill practice screens so progress metadata and guardian/result flows receive consistent IDs.
- Updated literacy/creative practice AI prefetching to use the active zone instead of always prefetching Word Woods.
- Hardened `SkillDatabase` zone lookups, names, and descriptions for kebab-case route IDs, Math Facts, Science Explorers, and Creative Corner.
- Added regression coverage for zone ID normalization and the Math Facts subset.
- Verification: `dart format` successful, `flutter analyze` clean, `flutter test` passing, and `flutter build web --release` successful. Remaining Wasm dry-run warnings are from third-party `flutter_tts_web.dart`.

## 2026-05-21 - Zone Detail Flow and World Token Functionality Pass

- Fixed `WorldTokens.fromZoneId` so snake_case route IDs, kebab-case token IDs, display names, and subject strings resolve to the correct zone identity instead of falling back to Word Woods.
- Passed canonical zone IDs into `ZoneProgressCard` so each zone progress panel now uses the right themed colors and progress styling.
- Added a zone-detail `Recommended Next` card that chooses an unlocked, not-yet-mastered skill and offers direct start/details actions.
- Added skill sorting controls for recommended order, progress, difficulty, and fewest attempts.
- Added a proper empty-filter state with a reset action when a selected filter has no matching skills.
- Verification: `dart format` successful, `flutter analyze` clean, `flutter test` passing, and `flutter build web --release` successful. Remaining Wasm dry-run warnings are from third-party `flutter_tts_web.dart`.

## 2026-05-21 - Zone Detail and Skill Progression Visual Step

- Upgraded skill cards with richer layered surfaces, asset-backed state watermarks, clearer status pills, stronger progress bars, improved mini stats, and more premium play/lock actions.
- Refreshed the zone progress card with quest artwork, stronger percentage typography, themed progress coloring, and a cleaner summary layout.
- Enhanced the zone header avatar presentation with a larger dimensional character frame and more polished name badge styling.
- Verification: covered by the follow-up `dart format`, `flutter analyze`, `flutter test`, and `flutter build web --release` run. Remaining Wasm dry-run warnings are from third-party `flutter_tts_web.dart`.

## 2026-05-21 - Visual System, Map, Player, and Quiz GUI Pass

- Tightened global typography tokens by removing stray letter spacing from core display, label, and button styles for cleaner Fredoka/Comfortaa rendering.
- Upgraded shared answer options with stronger card depth, rounder option badges, clearer selected/correct/incorrect surfaces, larger answer text, and smoother visual hierarchy.
- Reworked the shared `QuestionCard` with richer gradients, a scroll asset motif, improved question metadata chips, and larger Fredoka question text.
- Polished Numeracy, Science, Puzzle Peaks, and Story Springs question panels with consistent Fredoka question typography and cleaner compact labels.
- Improved the shared `AnimatedCharacter` renderer with brighter head rings, dimensional body gradients, outfit highlights, and more finished leg styling.
- Enhanced the world map static backdrop with a sun glow, soft clouds, and meadow contour lines for reduced-motion/static layouts.
- Refined the board-game world-map avatar pawn with a stronger base, dimensional body, brighter character frame, and consistent nameplate typography.
- Verification: `flutter analyze` clean, `flutter test` passing, and `flutter build web --release` successful. Remaining Wasm dry-run warnings are from third-party `flutter_tts_web.dart`.

## 2026-05-21 - Reduced-Motion and Animation Stability Sweep

- Added reduced-motion handling to Numeracy, Puzzle Peaks, Adventure Arena, and Story Springs result screens so celebratory animations render immediately and stop looping when calmer motion is requested.
- Hardened delayed result-screen animation callbacks so they do not resume after disposal or after reduced-motion mode has been enabled.
- Removed wall-clock sampling from Story Game floating background elements, using controller progress instead for deterministic repaint behavior.
- Updated shared `AnimatedCharacter` to stop bounce, walk, blink, and particle loops in reduced-motion mode, giving avatar and guide visuals a static presentation across the app.
- Verification: `flutter analyze` clean and `flutter test` passing.

## 2026-05-20 - Science Lab Visual Polish and Motion Cleanup

- Replaced plain Science Explorers loading, error, and empty-question states with branded lab cards, themed progress, retry/back actions, and clearer child-facing copy.
- Updated the new Science Explorers results screen to respect reduced-motion mode by stopping the looping pulse and rendering the score summary immediately.
- Made Story Springs floating result decorations deterministic from their animation controller instead of sampling wall-clock time during paint.
- Verification: `flutter analyze` clean and `flutter test` passing.

## 2026-05-20 - End-to-End Gameplay Completion Sweep

- Added a dedicated Science Explorers results screen so science sessions now finish with accuracy, stars, XP, retry, and back-to-zone actions instead of immediately popping out of the activity.
- Connected Science Explorers completion to skill progress, spaced repetition, avatar XP, star rewards, achievements, daily challenges, streak milestones, and zone mastery checks.
- Passed the selected science skill name through from the zone detail route into the science game and results flow.
- Hardened literacy, numeracy, and science answer selection so keyboard Enter cannot submit an invalid answer index before a choice is selected.
- Fixed the app-side web Wasm dry-run warning in Settings by removing explicit `double`/`int` runtime checks from setting persistence.
- Verification: `flutter analyze` clean, `flutter test` passing, and `flutter build web --release` successful. The remaining Wasm dry-run warnings are in the third-party `flutter_tts_web.dart` package code.

## 2026-05-20 - Avatar Creator, Unlocks, and Touch Scaling Pass

- Expanded avatar creation with four additional companions: Quinn Quokka, Perry Platypus, Tara Turtle, and Nova Dragon.
- Added renderer/color support for the new companion IDs in `AnimatedCharacter`.
- Added two extra starter outfits, `Sky Scout` and `Garden Hero`, and made avatar creation persist the selected starter outfit.
- Added an outfit selector directly into the style step so customization is more than just color choice.
- Added a visible unlock preview strip showing starter styles and future level-based outfit/accessory rewards.
- Reworked the character picker into a horizontal, swipe-friendly grid with larger touch cards to reduce unintuitive vertical scrolling on touch devices.
- Repaired and verified the mini-games card semantic/tool-tip polish from the previous pass.
- Verification: `flutter analyze` clean and `flutter test` passing.

## 2026-05-20 - Premium World Map Board-Game Pass

- Added a raised board-game base under the world islands with layered side depth, soft shadowing, route track glow, and per-world landing pads.
- Added a central `World Select` banner that reflects the currently selected world and makes zone selection feel more intentional.
- Reworked the map avatar into a pseudo-3D board-game pawn with pedestal, body, character head, nameplate, and level badge.
- Tied the pawn visual identity to the avatar's selected outfit color so avatar creation choices carry into the world map.
- Kept the implementation in Flutter's existing isometric map stack rather than introducing a full 3D engine, preserving performance and maintainability for mobile/web/tablet.
- Verification: `flutter analyze` clean.

## 2026-05-20 - Clipping and UI Lag Stabilization Pass

- Preserved Copilot/user edits in `world_map_screen.dart` and built on the existing short-viewport/static-effects direction.
- Added world-map ambient animation gating so floating/path animations stop on web, short viewports, and reduced-motion mode.
- Replaced expensive static world-map background fallback with a lightweight non-repainting painter.
- Reduced world-map particle load on animated layouts and removed it from static/performance layouts.
- Updated shared `AnimatedCloudBackground` to stop its ticker when animations are disabled and to repaint only when time changes.
- Updated shared `ParticleBackground` to stop its ticker in reduced-motion mode, use deterministic animation progress instead of wall-clock time in paint, and repaint only when input/progress changes.
- Reworked the mini-games hub grid so cards use stable scrollable sizing instead of being squeezed into short viewports.
- Made mini-game cards internally responsive so icon, text, and play button scale down instead of clipping.
- Verification: `flutter analyze` clean and `flutter test` passing.

## 2026-05-19 - Technical, Gameplay, UI, UX, and Safety Upgrade Pass

### Architecture and Data Flow

- Added `QuizPreferencesService` to centralize quiz preference loading for auto-read, AI hints, AI explanations, and AI cloud mode.
- Exported quiz preferences through the core services index.
- Replaced duplicated SharedPreferences quiz preference loading across numeracy, literacy, science, logic, and storytelling game widgets.
- Added `ZoneData.skillZoneId` as the canonical conversion point from route/map kebab-case IDs to curriculum snake_case IDs.
- Updated world map and zone detail skill routing to use the canonical skill zone ID mapping.
- Added explicit `math_facts` skill database and route handling so Math Facts opens the correct numeracy flow.
- Fixed `science_explorers` skill grouping so science progression resolves to the science strand instead of an unrelated fallback.

### Performance and Runtime Stability

- Reduced splash delay from a forced 3 seconds to a shorter minimum delay after avatar loading.
- Reworked `AudioManager` sound effects to use a small reusable SFX player pool instead of allocating temporary players per sound.
- Converted Memory Match timer logic to a cancellable `Timer` and ensured it is cancelled on dispose, win, and exit.
- Removed noisy avatar/local-storage debug logs that could expose player profile details.
- Kept game visual layers such as terrain, paths, shadows, and map objects behind `RepaintBoundary` where already established by the map architecture.

### Question and Answer Systems

- Added `GameSessionController.lastPointsEarned` so feedback reflects the actual score awarded rather than estimated values.
- Added `lastTimeBonus`, `lastAnswerCorrect`, `accuracy`, and `streakLabel` to support richer feedback and summary UI.
- Updated numeracy, literacy, and science feedback flows to use actual points earned.
- Added a reusable `AnswerFeedbackPanel` for consistent feedback with explanation, points, speed bonus, and streak chips.
- Improved `QuestionCard` visual hierarchy with semantic labels, clearer question context, a “Choose one answer” affordance, and richer card styling.
- Upgraded `TtsSpeakerButton` with keyboard activation, hover/focus styling, larger touch target handling, semantics, and stop/read toggle behavior.
- Improved `AnimatedAnswerOption` with focus, hover, semantics, keyboard activation, stronger selected/correct/incorrect visuals, and larger touch targets.

### Mini-Games

- Fixed Pattern Puzzle easy shape option generation so it reliably produces four distinct choices.
- Added keyboard navigation to Pattern Puzzle: arrow keys move answer focus, Enter/Space submits.
- Added visible selected answer styling and semantics to Pattern Puzzle options.
- Added keyboard navigation to Memory Match: arrow keys move card focus, Enter/Space flips.
- Added visible focus rings and semantic hints to Memory Match cards.
- Added keyboard navigation to Word Search: arrows move the active cell, Space selects, Enter checks, Escape clears.
- Improved Word Search selection validation so selected letters must form a straight line.
- Added reversed-word matching to Word Search.
- Improved Word Search, Pattern Puzzle, and Memory Match stat rows with wrapping layouts for small screens.

### World Map

- Added asset-backed landmarks to zone islands using existing project assets such as crystals, scrolls, keys, chests, quest art, logs, and gold.
- Added map zoom state and controls.
- Added keyboard zoom shortcuts.
- Added previous/next zone map controls.
- Added a recommended “Next Quest” route and quick action.
- Fixed numeric keyboard shortcuts so zones 1-8 are reachable instead of only zones 1-5.
- Scaled terrain, paths, shadows, and map object layers together during zoom.
- Added stronger visual identity to zone spotlight and island affordances.

### Avatar and Character Creation

- Added keyboard navigation across avatar character choices.
- Added keyboard navigation across color choices.
- Added Escape/back and Enter/Space continue/create behavior where appropriate.
- Added asset props to character cards and the color preview area.
- Improved character card visual presentation with richer gradients, stronger selection states, semantic labels, and clearer character identity.
- Improved color swatch semantics and touch/keyboard affordances.

### Backend and Worker Safety

- Added request validation to the question generation worker for zone, skill, age group, count, difficulty, and length/character constraints.
- Added `ALLOWED_AGE_GROUPS` validation to the worker.
- Added timing-safe password comparison to the API.
- Added minimum password length checks for registration and password change paths where available.
- Verified JavaScript syntax for `workers/question-gen/index.js` and `brightbound-api/src/index.js` when tooling was available.

### Accessibility and Child UX

- Added semantics to answer options, Memory Match cards, Pattern Puzzle options, Word Search cells, avatar cards, color swatches, map controls, and zone islands.
- Added larger touch targets and focus rings for shared buttons and question controls.
- Added keyboard flows for mouse/keyboard users across major quiz and mini-game interactions.
- Improved mobile responsiveness of repeated stat bars by replacing fragile fixed rows with wrapping layouts.
- Improved visual feedback for correct answers, incorrect answers, streaks, score gains, and selected/focused controls.

### Known Verification Limits

- `flutter` and `dart` were not available on PATH in the current environment, so `flutter analyze`, `dart format`, and Flutter test runs could not be executed locally.
- Later command execution was blocked by the environment usage/approval gate, so final shell verification of the last patch set could not be completed.
- VS Code reports 318 problems. These should be triaged with `flutter analyze` once Flutter SDK access is restored.

### Documentation Added

- Added this systematic changelog.
- Added `README_CODEX_AUDIT.md` as a concise audit summary and handoff note.
- Updated `README.md` with links to the changelog, audit note, and VS Code triage guide.
- Added `docs/VS_CODE_PROBLEMS_TRIAGE.md` with a repeatable plan for reducing the reported 318 VS Code problems.

### Follow-Up Enhancement Pass

- Hardened `GameSessionController.submitAnswer` and timeout handling so answers cannot be submitted while the game is not actively playing.
- Added score-change callback support for normal correct answers.
- Added `hasPerfectRun` and `isOnFinalQuestion` summary flags for result and feedback screens.
- Added `QuizStatusStrip`, a reusable status component for question progress, score, lives, streak, and timer display.
- Added `LearningFeedbackHelper` for consistent child-friendly encouragement, mastery messages, hint prompts, and adaptive difficulty delta suggestions.
- Surfaced `LearningFeedbackHelper` through `GameSessionController` with `encouragement`, `masteryMessage`, and `suggestedDifficultyDelta` getters.
- Added `docs/FLUTTER_TOOLING_SETUP.md` with the exact Flutter/Dart setup needed to run formatting, analysis, and builds locally.

### Analyzer and Test Cleanup

- Confirmed Flutter SDK is installed at `F:\Flutter\flutter`.
- Ran `flutter pub get` successfully using the explicit SDK path.
- Fixed analyzer-blocking syntax in `question_variation_engine.dart`.
- Fixed shuffled numeracy variation questions so `correctIndex` matches the shuffled option position.
- Removed invalid `@override` annotations from static variation-generator methods.
- Used the literacy variation context/reference pools so they are no longer dead fields.
- Removed unused AI cloud-mode fields from quiz widgets where the preference is applied through `QuizPreferencesService`.
- Removed an unused confetti data class from literacy results.
- Fixed async `BuildContext` usage in startup navigation.
- Ran `dart format lib test`.
- Fixed remaining curly-brace lints surfaced after formatting.
- Made `NumeracyGame` tolerant of missing `AvatarProvider` for standalone widget tests and embedded usage.
- Updated the numeracy widget test expectation to match the actual scored-points feedback.
- Verification:
  - `flutter analyze`: no issues found.
  - `flutter test`: all tests passed.

### Premium Polish Pass

- Improved the shared loading screen to use BrightBound avatar character IDs instead of generic fantasy archetypes.
- Made loading tips scroll-safe on smaller screens and aligned typography with app theme tokens.
- Reworked the loading background painter so animated shapes are deterministic per frame instead of mutating `Random` state during paint.
- Added keyboard focus activation and stronger focus visuals to shared `HoverCard` and `HoverButton` components.
- Added semantics wrappers to shared hover cards/buttons so desktop, web, and assistive-technology users get clearer affordances.

Verification for this last polish pass was not rerun because the command environment hit the usage/approval limit immediately afterward. The previous verified baseline was:

- `flutter analyze`: no issues found.
- `flutter test`: all tests passed.

## Recommended Next Triage

1. Run `dart format lib test` after restoring Dart/Flutter SDK access.
2. Run `flutter analyze` and group the 318 problems into:
   - compile errors from syntax/API mismatches,
   - deprecations,
   - lint/style issues,
   - missing imports,
   - dead code or unused members,
   - package/version incompatibilities.
3. Fix all compile errors before continuing feature polish.
4. Add golden/widget smoke tests for:
   - world map rendering,
   - avatar creator step flow,
   - shared question card,
   - answer option keyboard activation,
   - mini-game keyboard paths.
# Visual Accessibility & Premium Polish Pass

- Added `VisualAccessibilityService` for persistent Reduce Motion, High Contrast, and Larger Text preferences.
- Registered the service in `ServiceRegistry` and the app-level provider tree so visual preferences are available globally.
- Applied Larger Text and Reduce Motion through the root `MediaQuery`, allowing screens and widgets to respect a single app-wide accessibility signal.
- Added a high-contrast theme transform for stronger surfaces, focus/highlight colors, and readable color roles.
- Extended Settings with child/parent-facing toggles for High Contrast, Larger Text, and Reduce Motion.
- Updated `LoadingScreen` to respect reduced-motion preferences by stopping bounce/background loops and rendering a calmer static presentation.
- Began tightening the Mini Games hub for reduced-motion behavior and stronger semantic/tool-tip affordances on play cards.
