# BrightBound Adventures - Current Next Steps

**Updated:** 20 July 2026
**Source of truth:** [v2.1 Roadmap & File Tracker](V2_1_ROADMAP_TRACKER.md) — the working document with per-task file lists and checkboxes. It is backed by the [Release Execution Plan](V2_1_RELEASE_EXECUTION_PLAN.md) (task definitions, owners), the [3D & Game-Visual Direction Spec](V2_1_3D_VISUAL_DIRECTION.md) (art + rendering detail), and the [Premium Audit](V2_1_PREMIUM_AUDIT_AND_ROADMAP.md) (rationale, acceptance criteria).

Start with the Sprint 1 tasks in the execution plan: MO-1 (motion tokens), VS-1 (semantic theme extensions), WM-1 (map safety-net tests), RE-1 (atomic rewards), CO-4 (CI pipeline). A3D-7 (procedural 3D extrusion of the map painters, per the [3D & Game-Visual Direction Spec](V2_1_3D_VISUAL_DIRECTION.md)) can also start immediately for a fast visual win.

## Immediate priority

**Updated 7 October 2026.** The core loop slice landed on 6 October (quest intro → taught feedback → single atomic reward → premium reveal → persisted world change → explained next recommendation, literacy/Word Woods route), and on 7 October **every zone's results screen** (science, numeracy, logic, storytelling, motor) was migrated onto the same `SessionCompletion.completeSession` → `RewardTransactionService.apply()` → `RewardReveal` path, with per-zone tests. See `docs/CURRENT_STATE_AUDIT.md` and `CHANGELOG_CODEX.md`. Also on 7 October the world map got its **game-feel board pass** (part 1 of the visual pass): shared `BoardPath` route geometry, a pawn that actually walks the route frame-by-frame with a hop per island, Mario-Party-style board spaces with a gold NAPLAN question space per hop, NAPLAN identity chips on the quest intro / question card / quest lens, and the cold-start skill-hydration fix. **186/186 tests, format/analyze clean, release web build green.** On **8 October** part 2 landed - the **screens game-feel pass**: a shared extruded-slab `ExtrudedCard` on every subject question card (plus a perspective flip-up entrance), `PunchIn` feedback entrances, the avatar creator's extruded preview banner + character pedestal, and sphere-shaded characters with specular + soft AO. **192/192 tests, colour inventory down to 2,444.** Also on 8 October: **all five remaining practice screens gained the quest-intro beat** (shared `ZoneQuestIntro`, questions/configs generated once per session), every "coming soon" placeholder was replaced with an honest empty state and locked behind a guard test, and the phone-width bugs those tests exposed were fixed (logic/motor header overflows, story opacity overshoot assert, motor countdown timer leak). **198/198 tests, inventory 2,443/89, deployed to Cloudflare Pages (`playbrightbound`) for testing.**

Next release remains a cohesion and completion release, now with these first:

1. ~~Finish the game-feel visual pass started 7 October~~ **DONE 8 October** - board pass (7 Oct) + screens pass (8 Oct: extruded question cards, punch-in feedback, avatar pedestal, character volumes; `CHANGELOG_CODEX.md` 2026-10-08). Next from the 3D spec: authored island/landmark assets (sections 4-5) and the A3D-6 `TiltCard` rollout to shop/results/zone-detail.
2. ~~Finish the reward migration~~ **DONE 7 October** — all six zones share `SessionCompletion` + `RewardTransactionService` + `RewardReveal`. ~~Quest intro into the other five practice screens~~ **DONE 8 October** (shared `ZoneQuestIntro`). Still open from this item: the *taught feedback* half — ensure numeracy and science feedback panels surface authored `question.explanation` the way literacy/logic/story do.
3. ~~Kill the remaining placeholder paths~~ **DONE 8 October** — every "coming soon" surface replaced with an honest state, `placeholder_zone_screen.dart` deleted, locked by `test/tools/no_placeholder_text_test.dart` (CO-1).
4. **Author the missing explanations** — Story Springs (~46) and the NAPLAN bank (~42 prompts, no hints) — now that explanations actually render (`docs/CONTENT_QUALITY_REPORT.md`).
5. **Extend the slice across zones**: quest intro + taught feedback into the other five practice screens; second non-MCQ interaction (IN-3 number line or IN-4 sort-into-bins).
6. Refactor the monolithic map into testable state, layout, widgets, and painter layers (WM-3/WM-4).
7. Audit audio: `assets/sounds/` ships **no** audio files, so every sound effect and music cue logs "asset not bundled" at startup — either bundle the assets or hide the controls.
8. Establish fresh clean-checkout verification evidence; verify marketing, curriculum, privacy, accessibility, and platform claims (CO-6).
9. Add world-map viewport, theme, state, semantics, and golden coverage; finish the colour burn-down on critical journeys (VS-2).

The full audit defines the world-map v2 experience, light/dark requirements, asset and motion programmes, delivery phases, and release acceptance criteria.

## Current product loop

`world map - quest - practice - rewards - character/world progress - parent insight`

## Verification baseline

Recent work recorded passing format, analyzer, tests, and release web build, with a known third-party `flutter_tts_web` Wasm dry-run warning. Re-run from a clean checkout before treating that record as current evidence:

```powershell
& 'E:\Flutter\flutter\bin\dart.bat' format --output=none --set-exit-if-changed lib test
& 'E:\Flutter\flutter\bin\flutter.bat' analyze
& 'E:\Flutter\flutter\bin\flutter.bat' test
& 'E:\Flutter\flutter\bin\flutter.bat' build web --release
```

Older `PHASE_*`, session, completion, and roadmap documents are historical context, not current product truth.
