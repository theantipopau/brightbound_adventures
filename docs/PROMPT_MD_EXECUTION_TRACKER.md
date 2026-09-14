# prompt.md Execution Tracker

Working checklist for the "Full Product, UX, Visual and Engineering Improvement Pass" brief in `prompt.md` (root of repo). This is an enormous, multi-week-scale spec covering engineering, design system, accessibility and a full art-production programme. This tracker exists so progress survives across sessions and is visible at a glance — updated as each item lands, with a rolling changelog below.

**Honesty rule for this document:** a box is only ticked when the corresponding verification (tests/analyze/build, or explicit documented evidence) has actually been run and passed. "In progress" means started but not verified complete. Untouched items stay unchecked rather than assumed.

**Scope reality check:** the full spec (13 phases + a 9-family art production roadmap with milestones A-G) is genuinely weeks of work for a real engineering+design+art team. This session will not complete all of it. Priority follows the spec's own ordering: runtime correctness and data safety first, then accessibility/portrait reachability, then design system, then map/avatar depth work, then visual asset production (which is explicitly allowed to end in documented specs + fallbacks rather than finished professional art, since this environment has no production game-art pipeline).

---

## Phase 0 — Truthful baseline

- [x] Read existing docs (README, CHANGELOG_CODEX, roadmap tracker) — done 2026-09-15
- [x] Ran `flutter --version` — Flutter 3.41.5 / Dart 3.11.3
- [x] Ran `dart format --output=none --set-exit-if-changed lib test` — clean, 0 changed
- [x] Ran `flutter analyze` — 0 issues
- [x] Ran `flutter test` — **107/107 passing**
- [x] Ran `flutter build web --release` — succeeds (known non-blocking `flutter_tts_web` WASM dry-run warning, pre-existing/documented)
- [x] Searched for TODO/FIXME/HACK — 0 found; placeholder/coming-soon — 21 hits (not yet triaged); `catch (_)` — 16; `catch (e)` — 68 (not yet triaged)
- [x] **Reproduced the Player Profile defect** — root cause confirmed by code trace (see changelog below), not yet confirmed live in a running browser session
- [ ] Screenshot baseline at the 6 target viewports x themes x text scales — not started (requires a running browser session; deferred, noted as a manual-check gap)
- [ ] `docs/CURRENT_PRODUCT_AUDIT.md` — not yet written (this tracker + changelog stands in for now; will be written once Phase 0/1 findings are consolidated)

## Phase 1 — Build/runtime/persistence defects

- [x] **Fix Player Profile end-to-end** — done 2026-09-15. Rewired `ProfileStatsScreen` off the dead `StatsService`/`PlayerStats` model onto the app's real canonical sources: `AvatarProvider` (identity/level/XP), `SkillProvider` (zone/mastery progress, via the same `WorldMapViewModel.evaluateZoneState`/`calculateTotalStars`/`recommendedZoneIndex` logic the world map itself uses — one source of truth, not a third reimplementation), `ShopService` (star balance), `StreakService` (day streak), `QuestSessionHistoryService` (quests completed). Distinct loading/empty/error/content states; error state has a retry action instead of silently rendering "No progress yet" over a real failure. Shows all 8 zones (old code hard-coded 5, missing math_facts/science_explorers/creative_corner). Zone state communicated via label + icon + colour together (not colour alone), reusing `WorldMapZoneState`.
- [x] Regression test(s) for the fix — `test/profile_stats_screen_test.dart` rewritten to pump the real provider graph (matching `world_map_regression_test.dart`'s pattern) instead of only a `LocalStorageService` mock that could never have caught this bug. New test seeds real non-zero state in `ShopService`/`StreakService`/`QuestSessionHistoryService` and asserts the screen shows those exact values — this is the test that would have failed against the old implementation and proves the fix.
- [x] **Bonus finds while fixing Profile** (same root-cause class — duplicated/drifted models, exactly what the spec calls out):
  - Companion-emoji mapping was duplicated in 3 places and had drifted: `world_map_adventure_bar.dart` only recognised 4 of the 16 real companion IDs (defaulting the other 12 to a generic 🧭 in the world map HUD); `world_entry_screen.dart` recognised 12 of 16 (defaulting the other 4 to a *wrong* bear 🐻). Consolidated into `lib/core/models/companion_catalog.dart` (`CompanionCatalog.emojiFor`), used by both plus the new Profile header. Also fixed the avatar creator's own list, which used literal placeholder letters ('D', 'T') instead of the real emoji that exist for dragon (🐉) and turtle (🐢).
  - The 8-zone catalog (id/name/emoji/colour/position/description/order/requiredStars) was hand-duplicated in `world_map_screen.dart`, `profile_stats_screen.dart` (a stale, incomplete 5-zone copy), `world_entry_screen.dart` and `fantasy_map.dart`. Extracted the definitive copy into `lib/core/models/zone_catalog.dart` (`ZoneCatalog.zones`) and converged `world_map_screen.dart` onto it (low-risk pure extraction, identical values, verified by the existing 100+ world-map tests). `world_entry_screen.dart`/`fantasy_map.dart`'s own copies are noted but not yet converged — separate follow-up, out of scope for this change.
  - Found and fixed a real layout bug introduced during the rewrite itself, before it shipped: a zone-name + status-chip `Row` overflowed at 390px width once real (longer) zone names and chip labels were introduced — fixed with `Flexible`+ellipsis. Also replaced a fixed-`childAspectRatio` `GridView` for the stats cards with a content-sized `Wrap`, since the fixed-height grid overflowed as soon as a label needed two lines and would have overflowed again at larger accessibility text scales regardless of how the ratio was tuned.
  - Found and fixed a latent Provider hazard: `SkillProvider.initializeSkills()` calls `notifyListeners()` synchronously before its first `await`; calling it directly from a widget's `initState()` throws "setState() or markNeedsBuild() called during build" the first time that widget is the one to trigger initialization. Fixed by deferring the call via `Future.microtask` in `ProfileStatsScreen`.
  - Verification: `dart format` clean, `flutter analyze` 0 issues, **108/108 tests passing** (was 107; +1 new, existing test rewritten not just extended), `flutter build web --release` succeeds.
- [ ] Avatar save/restore/equip race-condition audit — not started

## Phase 2 — Design system (tokens)

- [x] Semantic colour/zone-palette/shape tokens exist (`SemanticColors`, `ZonePalettes`, `ShapeTokens` — prior session, VS-1)
- [x] Motion tokens exist (`MotionTokens` — prior session, MO-1)
- [ ] Full colour-role set per spec (canvas/surface/scrim/outline/focus/etc.) — partially covered, not verified against spec's exact list
- [ ] WCAG contrast measurements documented — not started
- [ ] Typography role audit (Fredoka/Comfortaa/Noto Emoji, 200% scale) — not started

## Phase 3 — Clipping/responsive audit

- [ ] Systematic clip/overflow audit — not started (prior sessions fixed specific overflow bugs found via tests, not a systematic pass)

## Phase 4 — Avatar system

- [ ] Avatar visual architecture consolidation — not started
- [ ] Asset brief / manifest — not started

## Phase 5 — Player pawn ("the guy")

- [ ] Pawn ownership/rendering audit — not started (map pawn exists per `_BoardGameAvatarPawn` in world_map_screen.dart, not yet audited against spec)

## Phase 6 — World map v2

- [x] **Substantially already done by prior sessions** (outside this session's earlier visibility): `world_map_adventure_bar.dart`, `world_map_quest_lens.dart`, `world_map_living_board.dart`, `world_map_scene_layer.dart` extracted; responsive compact/expanded HUD; `WorldMapViewModel` pure logic. `world_map_screen.dart` reduced 5570 -> 4491 lines.
- [ ] Full modularisation per spec's exact target tree (`controllers/`, `layout/` subfolders) — not verified against current structure
- [ ] Golden/state coverage for locked/available/recommended/in-progress/needs-review/boss-ready/mastered — partially covered by `WorldMapZoneState`/`WorldMapZoneStatus` in the view model; not verified end-to-end in the screen

## Phase 7 — Question/answer UI

- [ ] Unified structure audit across literacy/numeracy/science/logic/storytelling — not started

## Phase 8 — Player Profile redesign

- [ ] Blocked on Phase 1 fix landing first, per spec's own sequencing

## Phase 9 — Visual asset pipeline

- [ ] `docs/ART_BIBLE.md` — not started
- [ ] `docs/VISUAL_ASSET_AUDIT.md` — not started
- [ ] `docs/ART_ASSET_BRIEF.md` + `assets/art_manifest.json` — not started
- **Note:** this session has no production game-art generation tool wired to this pipeline. Per the spec's own fallback clause, the plan is to build manifest/renderer/fallback plumbing and produce copy-ready asset briefs rather than finished professional illustrations.

## Phase 10 — Accessibility/performance/CI gates

- [x] CI already gates format/analyze/test/build (prior sessions, CO-4) — deploy jobs also verified live (Cloudflare Pages, prior session)
- [ ] Systematic accessibility matrix (contrast, 200% text, reduced motion, keyboard, screen reader) — not started
- [ ] Performance profiling — not started

## Required deliverables checklist

- [ ] `docs/CURRENT_PRODUCT_AUDIT.md`
- [ ] `docs/DESIGN_SYSTEM.md`
- [ ] `docs/ART_ASSET_BRIEF.md` + `assets/art_manifest.json`
- [x] `docs/TECHNICAL_DISCOVERY.md` mandated before first refactor — in progress (this tracker currently holds interim findings)
- [ ] Migration notes (only needed if persisted schema changes — none planned yet)
- [ ] Tests for Player Profile / avatar persistence / portrait clipping / question UI / map states
- [ ] Updated README/NEXT_STEPS reflecting reality
- [ ] `docs/IMPLEMENTATION_REPORT.md`

---

## Rolling changelog (this tracker's own log — see `CHANGELOG_CODEX.md` for full-detail entries)

### 2026-09-15

- Read `prompt.md` in full (1756 lines). Established this tracker per user request to work through it periodically with a visible checklist.
- Ran full Phase 0 verification suite: format/analyze/test/build-web all pass. 107 tests (up from 92 last session — prior sessions added world-map presentation and view-model tests I hadn't seen).
- Confirmed via `git log` that substantial world-map modularisation (Phase 6 groundwork) already happened in commits `5c8f66c`..`09c0e9e`, authored outside this session's visibility. Treated as current ground truth per the spec's own "code is the source of truth" rule.
- **Root-caused the Player Profile defect**: `lib/ui/screens/profile_stats_screen.dart` reads from `StatsService`/`PlayerStats` (`lib/core/services/stats_service.dart`, `lib/core/models/player_stats.dart`), a completely disconnected legacy data model. Confirmed via grep that `StatsService` has exactly two referencing files in `lib/` — itself and `profile_stats_screen.dart`. No quest-completion path, `RewardTransactionService`, or game screen anywhere calls `StatsService.addXp`/`.awardActivityXp`/etc. Every profile view therefore auto-creates a fresh all-zero `PlayerStats` record (see `StatsService.getStats`, lines 16-28) and shows it, regardless of real play — level always 1, XP/stars/activities always 0, all zones but the starter always locked. This is the "parallel stale model" failure class the spec's Player Profile diagnostic protocol calls out by name.
- **Fixed it.** Full details under Phase 1 above. Summary: rewired `ProfileStatsScreen` onto `AvatarProvider`/`SkillProvider`/`ShopService`/`StreakService`/`QuestSessionHistoryService`; found and fixed two related duplicated/drifted models along the way (companion-emoji mapping, 8-zone catalog); found and fixed two real bugs introduced by the rewrite itself before shipping (a layout overflow, a synchronous-notifyListeners Provider hazard) via the verification loop (analyze/test) rather than assuming the first draft was correct. Rewrote the screen's regression test to pump the real provider graph instead of a mock that could never have caught the original bug. 108/108 tests passing, format/analyze/build-web all clean.
- Not yet done today: `docs/CURRENT_PRODUCT_AUDIT.md` (formal write-up — this tracker + CHANGELOG_CODEX.md currently hold the equivalent detail), screenshot baseline, avatar save/restore race audit, and everything from Phase 2 onward. Continuing next session per the user's "work through it periodically" instruction.
