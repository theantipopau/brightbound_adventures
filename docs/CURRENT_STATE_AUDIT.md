# BrightBound — Current-State Audit & Implementation Plan

**Recorded:** 6 October 2026
**Method:** repository inspection, code tracing of the full user journey, and a clean local verification run.
**Validation baseline (this machine, Flutter 3.47.5 / Dart 3.13.4):**

| Command | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | ✅ 244 files, 0 changed |
| `flutter analyze` | ⚠️ 1 pre-existing `info`: `onReorder` deprecated in `drag_to_order.dart` (local SDK 3.47.5; CI is pinned to 3.41.5 where this does not fire). Not introduced by this work. |
| `flutter test` | ✅ **138/138 passing** (baseline) → **164/164 passing** (after the literacy slice, 6 Oct) → **168/168 passing** (after all-zone reward migration, 7 Oct) -> **186/186 passing** (after the board game-feel pass, 7 Oct) -> **192/192 passing** (after the screens game-feel pass, 8 Oct) -> **198/198 passing** (after the quest-briefing + honesty pass, 8 Oct) |
| `flutter build web --release` | ✅ succeeds; known third-party `flutter_tts_web` Wasm dry-run warning unchanged |
| Live browser run (`flutter run -d web-server`, port 5959) | ✅ app boots: Hive boxes open, fonts/images load, **no console exceptions**. ⚠️ Screenshot evidence **not captured** — the preview browser cannot composite Flutter/CanvasKit frames in this environment (`preview_screenshot`: "produced no frames"), the same limitation a prior session recorded. Visual behaviour was verified through widget tests instead (3 viewports, 200% text, reduced motion). Remains a manual-check gap. |

---

## 1. Mapped user journey (launch → parent dashboard)

| Step | Entry point | State found |
|---|---|---|
| Launch | `lib/main.dart` splash → `_checkAppState()` | Works; avatar load hardened 2026-09-15 (corrupt record no longer hangs splash). |
| Onboarding | `ui/screens/onboarding_screen.dart` | Reachable, tested at 3 viewports × 200% text (`startup_responsive_smoke_test.dart`). |
| Avatar creation | `ui/screens/avatar_creator_screen.dart` (2,400 lines) | Reachable; dark-mode field fix + 200% overflow fix landed 2026-09-15/16. |
| World entry | `ui/screens/world_entry_screen.dart` | Reachable; "Enter now" confirmed reachable by scroll at 200%. |
| World map | `ui/screens/world_map_screen.dart` (4,427 lines) + 4 extracted seams in `ui/screens/world_map/` | Strongest screen; responsive quest lens + compact adventure bar live; zone state badges live. |
| Quest selection | Quest Lens `onPrimaryAction` → `_moveToZone()` → `ui/screens/zone_detail_screen.dart` → skill list → practice screen | Reachable, but the lens primary action **moves the pawn only**; the child must then find the skill card. No quest-intro beat anywhere. |
| Activity | `features/<domain>/screens/*_practice_screen.dart` → game widget | Reachable; overwhelmingly MCQ. **Authored `question.explanation` is never displayed** — feedback is a praise banner plus an AI explanation only when the AI toggle is on. Auto-advance fires at 1.5 s (correct) / 2 s (incorrect), i.e. the child is rushed past feedback they never see. |
| Reward presentation | `features/literacy/widgets/quiz_results_screen.dart` (638 lines) | **Migrated 6–7 Oct.** All six zones now award through `SessionCompletion.completeSession` → one idempotent `RewardTransactionService.apply()` → `RewardReveal`; the former dual divergent paths (results screen + practice screen) were removed. Tested in `literacy_session_flow_test.dart` and `zone_session_flow_test.dart`. |
| Progression update | `SkillProvider.updateSkillProgress`, `SpacedRepetitionService.recordSession`, `CosmeticUnlockService` | Persisted and working; zone status/badges derive from it. |
| Return to map | `onExit` → `Navigator.pop()` → zone detail (second pop to reach map) | **No acknowledgement.** The map never knows a quest just finished; no "you completed this" cue, no next-quest reason beyond the generic `"Recommended for your next quest."`. |
| Parent dashboard | `ui/screens/parent_dashboard_screen.dart` (1,510 lines) | Reachable, reads real session history (charts landed earlier). |

### Inventory highlights

- **Playable learning modes:** literacy (MCQ), numeracy (MCQ + generators), science (MCQ + sorting), logic (MCQ/pattern), storytelling (MCQ + one tested drag-to-order), motor (tracing), mini-games (word search, pattern puzzle…), boss battles, daily challenges, Star Shop.
- **Question sources:** static banks (`core/utils/*_questions.dart`, `literacy_skill_questions.dart`, `science_question_bank.dart`, `puzzle_peaks_question_bank.dart`), procedural generators (`word_woods_generator`, `number_nebula_generator`, `enhanced_question_generator`, `creative_corner_generator`, `science_quest_generator`), optional `AiQuestionService` (network; offline-first fallbacks exist).
- **Reward systems:** `RewardTransactionService` (idempotent, tested — **now called by every zone via `SessionCompletion.completeSession`**), `ShopService.awardStarsForActivity`, `AvatarProvider.addExperience`, `StreakService.recordPlay`, `AchievementService` (two divergent APIs in use), `DailyChallengeService`, `CosmeticUnlockService`, mastery (`SkillProvider`).
- **Motion:** `MotionTokens` (MO-1), `AppMotion` (legacy, still used in 10 files), `Pressable`/`JuicyButton` (MO-3), semantic routes (MO-2), per-widget `AnimationController`s.
- **Design tokens:** `SemanticColors`, `ZonePalettes`, `ShapeTokens` (VS-1) exist; **58 call sites across 13 files still read raw `AppColors`** bypassing brightness (VS-2 debt, tracked). Colour inventory test enforces a shrinking budget (2,443 usages / 89 files, 8 Oct).
- **Reachable dead ends (CO-1 debt, still open):** "Questions coming soon!" empty state in `skill_practice_screen.dart` and `numeracy_practice_screen.dart`; a **fake fallback question** ("This skill is coming soon! Would you like to practice anyway?") returned when a generator throws in those same two files (removed from the literacy route this session, **still present in numeracy**); `🚀 Coming Soon!` in `story_practice_screen.dart` and `logic_practice_screen.dart`; `Coming soon!` in `shop_screen.dart`; exported `placeholder_zone_screen.dart`.
- **Audio is non-functional in practice:** `assets/sounds/` contains only `.keep` and `AUDIO_ASSETS_GUIDE.md`. At startup `AudioManager` logs "21/21 expected audio assets are missing" and falls back silently, so every sound control in Settings currently does nothing. Either bundle the assets or hide the controls (WORKSTREAM 11 rule) — flagged, not silently left.
- **Dead code found:** `AnswerFeedbackPanel` in `lib/ui/widgets/quiz_widgets.dart` is a fully-built reusable feedback panel (explanation + points + `onContinue`) with **zero references** anywhere in the repo. It overlaps with the feedback panel added to `multiple_choice_game.dart` this session; consolidate or delete in a dedicated pass rather than mid-slice.
- **Accessibility:** light/dark/system themes, high contrast, reduced motion, 200% text (clamp raised to 2.0 on 2026-09-16), semantics on zone cards, keyboard activation on `Pressable`.

### Confirmed gaps this plan addresses

1. **No shared session loop.** There is no quest-introduction beat, no shared completion/reveal sequence, and no orchestration layer — each of the 6 practice screens improvises.
2. **Rewards are not atomic in practice.** The tested `RewardTransactionService` is never called; XP/stars/streak/achievements are awarded by two different screens per session.
3. **Feedback does not teach.** Authored explanations and hint scaffolding are invisible; pacing is timer-driven.
4. **The map has no memory of the session that just happened** and cannot say *why* a quest is recommended beyond a generic string.
5. **Reachable placeholder paths** remain in advertised core journeys.

---

## 2. Prioritised implementation sequence (this slice)

Vertical slice: **recommended map quest → quest intro → learning encounter → instructional feedback → reward transaction → premium reveal → persisted world change → next recommendation.**

| # | Work | Files | Risk |
|---|---|---|---|
| 1 | `RewardReveal` component: sequenced stars → XP → level → unlocks → next-quest card, consuming `RewardResult`; reduced-motion = static equivalent | **CREATE** `lib/ui/components/reward_reveal.dart` | Low (new file) |
| 2 | Route the literacy completion through `RewardTransactionService.apply()`; delete the duplicate XP/star/streak/achievement awarding in `quiz_results_screen.dart` + `skill_practice_screen.dart` | MODIFY both | **High** — reward regression; covered by new tests first |
| 3 | Quest-intro beat (objective, why-now reason, reward preview, one Start action) before the activity | **CREATE** `lib/ui/components/quest_intro.dart`, MODIFY `skill_practice_screen.dart` | Medium |
| 4 | Instructional feedback: show the authored explanation after every answer, learner-paced Continue instead of a blind timer | MODIFY `multiple_choice_game.dart` | Medium — changes pacing |
| 5 | Explainable recommendation (`continue` / `review` / `challenge` / `new`) from real session history | **CREATE** `lib/features/world_map/services/recommendation_service.dart` | Low |
| 6 | Persisted world change: quest-complete flag on the zone island, derived from persisted session history | MODIFY `world_map_screen.dart` (`_ZoneIsland`), `world_map_quest_lens.dart` | Medium — flagship screen |
| 7 | Tests for 1–6; dead-end audit of the touched path | **CREATE** `test/ui/components/reward_reveal_test.dart`, `test/ui/components/quest_intro_test.dart`, `test/features/recommendation_service_test.dart`, `test/features/literacy_session_test.dart` | — |

### Regression risks

- **Reward double-award or lost award** (mitigated: `RewardTransactionService` is idempotent by `outcomeId` and already unit-tested; new tests assert exactly-once at the UI level).
- **Pacing change in the encounter** (`Continue` replaces auto-advance) — must not break the existing quiz flows or leave the session unable to finish; guarded by a widget test that plays a full session.
- **World-map regression** — the existing 46-test map suite (`world_map_regression_test.dart`, `world_map_presentation_test.dart`) must stay green.
- **Colour-inventory budget** — new files must not add raw colours beyond the committed per-file allowance (`test/tools/color_inventory_test.dart`).

### Validation requirements

`dart format` · `flutter analyze` · `flutter test` · `flutter build web --release`, plus targeted widget tests that walk map → quest → activity → feedback → reward → map and assert the world changed.

---

## 3. Deferred (recorded, not silently dropped)

- Full three-region responsive map shell (WM-3/WM-4) and the map monolith split beyond the seams already taken.
- CO-1 dead-end elimination for the *other* practice screens (story/logic/numeracy/science) and shop.
- VS-2 colour burn-down (58 raw `AppColors` sites), VS-4 dark composition, authored zone art (WM-7/WM-8 — no art pipeline in this environment).
- Non-MCQ interaction rollout beyond the tested Story Springs drag-to-order slice.
- Audio completion (assets directory contains only `AUDIO_ASSETS_GUIDE.md`).
