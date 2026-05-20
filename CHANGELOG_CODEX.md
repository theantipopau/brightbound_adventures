# BrightBound Adventures - Systematic Changelog

This document tracks the production improvements made during the Codex audit and enhancement pass. It is intentionally implementation-focused so future work can continue from a clear baseline.

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
