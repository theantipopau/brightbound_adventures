# BrightBound Adventures: Full Product, UX, Visual and Engineering Improvement Pass

You are Claude Code acting as a principal Flutter engineer, product designer, accessibility specialist, child-centred game UX designer, and QA lead. Work directly in this repository:

`theantipopau/brightbound_adventures`

Your job is not to produce another speculative roadmap. Audit the actual current checkout, validate existing documentation against the code, then implement a coherent, tested improvement pass. Preserve working functionality, local-first behaviour, saved player data, curriculum metadata and deployment paths.

## Product intent

BrightBound Adventures is a colourful, offline-first educational RPG for children aged 4-12. Its intended loop is:

`world map -> recommended quest -> practice -> feedback -> XP/stars/reward -> visible character/world progress -> next quest`

The app must feel like one polished game, not a collection of unrelated screens. Optimise first for child clarity, delight, accessibility, reliability and portrait mobile use. Australian English is required. Do not weaken existing ACARA/NAPLAN metadata or make unverified curriculum claims.

## Known areas requiring deep attention

The repository documentation and prior audit identify these likely risks. Treat them as hypotheses and verify them in the current code before changing anything:

- `lib/ui/screens/world_map_screen.dart` has previously been described as larger than 5,000 lines and mixing orchestration, layout, HUD, map, pawn, panels, painters and effects.
- Direct colours, independent gradients, radii, shadows and animation styles may bypass semantic theme tokens.
- The active map may be crowded, collision-prone under unusual aspect ratios or large text, asset-light, and insufficiently tested.
- `fantasy_map.dart` may be legacy or unused. Confirm before removing.
- Avatar-related code likely includes `avatar_creator_screen.dart`, `avatar_widgets.dart`, an avatar model/provider and persisted cosmetic selections. Verify end-to-end save, restore, equip and display behaviour.
- Profile/statistics routing was previously repaired, but the user reports that Player Profile still does not work. Reproduce the fault rather than assuming the route is the only issue.
- High-risk recently changed files may include `quiz_widgets.dart`, `animated_answer_option.dart`, the world map, avatar creator and mini-games.
- Existing docs claim both completed improvements and unresolved issues. Code, tests and a running build are the source of truth.
- The repository has used Fredoka, Comfortaa and Noto Emoji. Audit whether each font is bundled, declared, loaded and used consistently, and whether the typography system remains legible at 200% text scaling.
- Existing app settings may include light/dark/system theme, high contrast, larger text and reduced motion. All new work must honour them.

## Non-negotiable operating rules

1. Inspect first. Do not make broad changes until you understand architecture, state ownership, persistence, routes, assets, themes, breakpoints and test coverage.
2. Work from the current branch. Do not trust “complete” labels in old Markdown files.
3. Do not rewrite the app from scratch or replace Flutter.
4. Preserve Hive/shared-preferences data. If a schema changes, add a safe migration and tests for old records.
5. Do not delete code merely because it appears unused. Prove it with references, route tracing, analyser output and tests.
6. Avoid adding heavy dependencies. Justify every new package in the final report.
7. Do not use emoji as primary premium artwork. Emoji may remain as accessible fallback or supporting decoration.
8. Do not copy protected game art or imitate a specific commercial title. Create an original BrightBound storybook-diorama visual system.
9. Avoid excessive ambient animation. Motion must communicate selection, travel, feedback, reward or state change. Respect reduced motion.
10. Do not hide defects with clipping, ellipsis or arbitrary fixed heights. Fix constraints, wrapping, scrolling and ownership properly.
11. Never reduce accessibility semantics, focus support, keyboard support or touch target size to make layouts fit.
12. Keep app copy child-friendly, encouraging and specific. Never shame a learner for a wrong response.
13. Do not claim a task is complete unless formatting, analysis, tests and a release web build pass, or you document the exact blocker and evidence.
14. Make small, reviewable commits with conventional commit messages. Do not combine unrelated work.

## Phase 0: establish a truthful baseline

Before editing:

- Read `README.md`, `README_CODEX_AUDIT.md`, `CHANGELOG_CODEX.md`, `IMPLEMENTATION_CHECKLIST.md`, `docs/V2_1_PREMIUM_AUDIT_AND_ROADMAP.md`, `docs/ARCHITECTURE.md`, `docs/NEXT_STEPS.md`, setup/deployment docs and all existing design or asset guidance.
- Inventory `lib/`, `assets/`, `test/`, `web/`, `website/`, `brightbound-api/` and workers.
- Map the route graph from launch through onboarding, avatar creation, world map, quest/game, reward, profile, shop, trophy room, settings and parent dashboard.
- Trace the canonical models/providers/services for avatar, player stats, progression, quest history, themes/preferences and persistence.
- Search for `TODO`, `FIXME`, `HACK`, `placeholder`, `coming soon`, dead routes, duplicate models, hard-coded dimensions, raw colour literals, direct font declarations, swallowed exceptions and unsafe `!` usage.
- Run and capture:

```bash
flutter --version
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

- Launch the app and reproduce the reported Player Profile failure. Record route, device size, exception/log output, state before navigation and whether failure occurs on fresh and existing local data.
- Establish current screenshots at these logical CSS sizes and at text scale 1.0 and 2.0 where practical:
  - 360x800 phone portrait
  - 390x844 phone portrait
  - 412x915 large phone portrait
  - 800x1280 tablet portrait
  - 1024x768 tablet landscape
  - 1366x768 desktop
- Add an audit document at `docs/CURRENT_PRODUCT_AUDIT.md`. Separate verified defects, design debt, accessibility risks, performance risks and suggestions. Include file paths and evidence.

Do not stop after the audit. Continue into implementation.

## Phase 1: fix build, runtime and persistence defects

- Resolve compile/analyser errors before visual refactors.
- Fix the Player Profile end to end:
  - reachable from the intended UI;
  - route safe on web and mobile;
  - no crash with no history, partial history, migrated data or a newly created player;
  - reads from the canonical stats/history source rather than a parallel stale model;
  - updates after completing a quest without restarting;
  - loading, empty, normal and error states are distinct;
  - back/navigation behaviour is correct;
  - profile identity matches the avatar currently saved/equipped;
  - no fake statistics are shown.
- Audit avatar save/restore and cosmetic equip flows for asynchronous initialisation races, provider lifetime errors, type/key mismatches and stale cached state.
- Add focused regression tests before or alongside each fix.

## Phase 2: create one design system

Create or rationalise a semantic design-token layer rather than scattering constants. Reuse existing theme architecture when sound.

Required token groups:

- colour roles: canvas, surface, raised surface, scrim, outline, text primary/secondary, focus, success, caution, error, XP, stars and each world identity;
- spacing scale;
- corner-radius scale;
- elevation/shadow recipes designed for light and dark modes;
- typography roles;
- motion durations/curves with reduced-motion alternatives;
- minimum interactive sizes;
- layout widths, gutters and explicit responsive breakpoints.

### Colour requirements

- Keep BrightBound colourful but reduce uncontrolled saturation and gradient noise.
- Create intentional light, dark and high-contrast palettes. Do not derive dark mode merely by darkening light colours.
- Check meaningful text/icon combinations against WCAG contrast expectations. Include the measured ratios in the audit or test output where feasible.
- Do not use colour alone to communicate locked, selected, correct, incorrect, recommended, review-needed, boss-ready or mastered states.
- Replace direct `Color(...)` values in feature widgets with semantic roles unless the value is genuinely content data.

### Typography requirements

Audit Fredoka, Comfortaa and Noto Emoji usage. Prefer a restrained hierarchy:

- display/brand type for short headings only;
- highly legible UI/body type for questions, instructions, labels and statistics;
- tabular or stable-width number treatment where it improves counters;
- sensible line height and no tight tracking for young readers.

Verify font assets and `pubspec.yaml` declarations. Eliminate accidental platform-font fallbacks and excessive one-off `TextStyle` definitions. Test 200% text scaling without inaccessible truncation. Ellipsis is acceptable only for genuinely secondary single-line labels with an accessible full label.

Build shared components for buttons, cards, chips/badges, progress, empty states, modal/sheets, choice tiles and focus treatment. Migrate critical journeys first rather than mechanically replacing every widget.

## Phase 3: repair clipping and responsive layout

Perform a systematic clipping/overflow audit, especially in portrait mode.

- Inspect every `ClipRect`, `ClipRRect`, fixed `SizedBox`, `Positioned`, `Transform`, `FittedBox`, `AspectRatio`, `Stack`, `OverflowBox`, `maxLines`, `ellipsis` and hard-coded pixel offset in critical journeys.
- Remove clips used to conceal constraint bugs.
- Wrap page-level content in the correct scroll container without creating nested-scroll traps.
- Respect `SafeArea`, keyboard/view insets, browser resize, notches and bottom browser chrome.
- Use `LayoutBuilder`, constraints, slivers and adaptive composition rather than device-name detection.
- Avoid width-only breakpoints. Consider available width, height, orientation and text scale.
- Ensure all interactive content remains reachable at 360x800 and 200% text.
- Maintain at least 44x44 logical-pixel targets, preferably 48x48 for primary child interactions.
- Add debug overflow detection in tests and fail tests on Flutter overflow errors.

## Phase 4: avatar system and avatar creator

Improve both the creation experience and avatar rendering architecture.

### Flow

Create a clear, reversible flow that works on a single portrait screen:

1. choose companion;
2. customise colours/features;
3. choose starter outfit/accessory where allowed;
4. choose/name identity;
5. preview and save.

A compact stepper or segmented flow is acceptable, but the live preview must remain visible without crushing controls. Preserve edits when moving between steps. Make Save/Create explicit and prevent accidental loss.

### Avatar visual architecture

- Identify whether avatars are emoji, raster sprites, SVGs, custom painters or mixed. Consolidate into one deterministic layered renderer.
- Establish a layer contract such as silhouette/body, face, markings/hair, outfit, accessory, foreground effect.
- Use one shared avatar renderer in creator, map pawn, profile, shop and reward views to prevent visual mismatch.
- Define stable anchors, canvas/viewBox, padding and z-order so hats, ears, hair, wings and held items do not clip.
- Add golden tests for each companion at small, medium and large sizes, including representative accessories and dark mode.
- Improve companions so they are expressive and recognisable at small sizes. Vary silhouette, ears/tail/crest, face and idle pose, not merely colour.
- Add selected, locked, equipped and preview states with text/shape cues.
- Ensure colour swatches have semantic labels and visible selection/check treatment.
- Include a creator randomise option and undo/reset only if it can be implemented safely and accessibly.

### Asset specification

If existing avatar assets are insufficient, create `docs/ART_ASSET_BRIEF.md` and `assets/art_manifest.json` describing every required asset with:

- stable ID and intended file path;
- purpose and screen placements;
- pixel dimensions or SVG viewBox;
- transparent background requirement;
- safe padding and anchor points;
- light direction and perspective;
- palette and outline rules;
- layer/z-order;
- export format, compression and decoded-size budget;
- alt/semantic label;
- status: existing, needs redraw, missing or replacement candidate.

Do not generate empty placeholder boxes and call the asset work complete. If binary art cannot be professionally authored in this environment, implement the renderer, manifest and temporary clearly labelled development fallback, then list exact production assets needed.

## Phase 5: rebuild the “guy” as the player pawn/companion representation

Treat the “guy” as the player’s avatar-linked representation used during world navigation and reactions.

- Confirm which widget/model currently owns the map pawn.
- Render the saved avatar consistently rather than a generic unrelated figure.
- Preserve recognisability at map scale through a readable silhouette, outline, base/shadow and optional level badge.
- Correct clipping during bounce, travel, selection and route turns.
- Avoid animation controllers per map node. Use one deliberate animation owner and event states.
- Add reactions for quest selected, correct-answer streak, reward earned and level-up only where state wiring already supports it cleanly.
- Provide reduced-motion equivalents using opacity, colour, badge or instant state changes.
- Add semantics that describe player identity and current location.

## Phase 6: world map v2

Refactor the map into testable modules rather than continuing a monolithic screen. A reasonable target structure is:

```text
lib/features/world_map/
  models/
  controllers/
  layout/
  widgets/
  painters/
  screens/
```

Adapt this to the existing architecture. Do not duplicate core models or services.

### Composition

Use three explicit regions:

- Adventure bar: avatar identity, level/XP, stars, streak and settings/menu.
- Living board: zones, routes, player pawn, state effects and contextual labels.
- Quest lens: quest goal, difficulty, recommendation reason, reward preview and one primary action.

Responsive behaviour:

- desktop: map plus side quest lens;
- tablet portrait: map plus collapsible bottom lens;
- phone portrait: zoomable/pannable or scrollable map with a persistent compact quest sheet;
- secondary destinations move into an adventure menu rather than crowding the map.

Do not simply shrink the desktop map for portrait.

### Visual language

Create an original storybook-diorama board:

- tactile board edge;
- painted terrain and restrained texture;
- consistent isometric perspective and light direction;
- crisp game UI layered above art;
- one hero landmark and supporting props per zone;
- routes that remain legible in light/dark/high contrast;
- authored icons/illustrations as primary visuals rather than emoji.

Each zone must expose unmistakable states:

- locked;
- available;
- recommended;
- in progress;
- needs review;
- boss ready;
- mastered.

Communicate state through a combination of shape, icon/badge, label, tone and restrained motion. Add accessible descriptions.

### Navigation and geometry

- Separate zone data from layout data and renderers.
- Use normalised, constraint-aware placement or an explicit map coordinate system with tested transforms.
- Centralise zoom/pan bounds, hit testing and path geometry.
- Prevent labels, pawn, quest sheet and HUD from colliding.
- Ensure keyboard focus order follows a logical journey and remains visible after zoom/pan.
- Provide a “focus recommended quest” action and a reliable reset-view action.

### Motion

- idle: nearly static;
- selection: approximately 160-220 ms focus lift/quest-lens transition;
- travel: a concise anticipation, path movement and settle sequence;
- unlock: one-shot route/gate/landmark reveal;
- reward/mastery: one-shot celebration, not a permanent particle storm.

Use actual product tokens, not magic durations copied across widgets.

### Map tests

Add deterministic widget/golden coverage for all target viewports, themes, reduced motion and at least text scales 1.0 and 2.0. Test zone hit targets, selected state, recommendation focus, locked behaviour, zoom/reset and quest-sheet reachability.

## Phase 7: question and answer UI

Unify question presentation across literacy, numeracy, science, logic, storytelling, motor/mixed surfaces where interaction semantics permit.

### Required structure

- progress/context header;
- clear question card;
- optional stimulus/media area;
- read-aloud control where supported;
- answer region;
- feedback/explanation region;
- one obvious next action.

### Behaviour

- On narrow portrait layouts, use a single-column reading order and allow natural page scrolling.
- On sufficiently wide layouts, optionally use a question/stimulus column and answer column.
- Never use tiny type, ellipsis or a scaled-down whole page to fit a long question.
- Answer options must support multiline text, keyboard, touch and screen readers.
- Lock duplicate submission while feedback is active.
- Preserve selected option, response state and explanation during required transitions.
- Correct feedback should explain why. Incorrect feedback should be calm, specific and actionable.
- Ensure colour is not the only correctness cue. Use icon, border, label and semantics.
- Reduce visual competition from timers, counters, XP and decorative effects while a child is reading.
- Place hint and read-aloud actions consistently.
- If power-ups exist, keep them visibly secondary to learning actions.
- Audit question freshness/history integration but do not alter learning selection logic merely for visual goals.

Refactor duplicate quiz widgets only where behaviour and data contracts genuinely match. Prefer composition over a giant configurable widget.

Add tests for long question text, long answer text, four or more options, keyboard selection, read aloud semantics, correct/incorrect feedback, double-tap prevention, portrait screens and 200% text.

## Phase 8: Player Profile redesign after the bug fix

Once profile data is correct, redesign it as a useful learner-facing profile rather than a debug stats dump.

Recommended hierarchy:

1. avatar, player name, level and current XP;
2. current adventure progress and next meaningful goal;
3. strengths and “practise next” based only on real evidence;
4. recent quest history;
5. achievements/cosmetics;
6. settings or parent details via clearly separated navigation.

Requirements:

- no fabricated trends or recommendations;
- explain the basis for a recommendation in child-friendly language;
- accessible empty state for a new player;
- portrait-first card/sliver layout;
- facts and labels remain readable at 200% text;
- stats update immediately after a session;
- avatar edit action returns safely without losing profile state;
- parent-facing metrics remain behind the existing parent access controls and must not leak into the child profile.

## Phase 9: visual asset pipeline

Audit all raster, SVG, emoji, icon-font, custom-painted and generated visuals.

- Identify duplicates, obsolete files, inconsistent naming, oversized decoded assets, invalid references and assets present in the repository but absent from `pubspec.yaml`.
- Define naming and folder conventions by product domain, not “misc”.
- Prefer SVG for vector UI/landmarks when Flutter support is already available and reliable; otherwise use appropriately sized WebP/PNG variants.
- Avoid shipping source art, cache files and generated build artefacts in app bundles.
- Add asset-loading fallbacks that do not crash or create blank/invisible controls.
- Add tests or a script to validate manifest paths, duplicate IDs and missing files.
- Add an art direction section covering perspective, silhouette, texture density, outline weight, lighting, saturation, shadows and dark-mode treatment.
- Produce exact creation briefs for missing world landmarks, terrain tiles, route pieces, gates, mastery decorations, reward icons, companion layers, outfit/accessory layers, empty-state illustrations and profile headers.

## Phase 10: accessibility, performance and quality gates

### Accessibility

Verify critical journeys with:

- light, dark, system and high contrast;
- 200% text scaling;
- reduced motion;
- keyboard-only navigation;
- screen-reader semantics order and labels;
- touch targets;
- no colour-only state;
- visible focus;
- portrait orientation.

Do not block text scaling globally.

### Performance

- Profile map and avatar-heavy screens in profile/release mode.
- Remove unnecessary rebuilds, nested consumers/listeners, repeated asset decoding, avoidable saveLayer/opacity usage and off-screen animation.
- Isolate painters with repaint boundaries where profiling proves value.
- Give animation controllers clear ownership and disposal.
- Avoid rebuilding the whole map for HUD-only changes.
- Document before/after measurements if tooling permits. Never invent metrics.

### Automated gates

Add or strengthen CI so a clean checkout runs:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

Add deterministic golden testing only with a documented update command and stable fonts/assets. Do not commit environment-dependent noisy goldens.

## Required deliverables

Implement the work and leave the repository with:

1. working code, not just recommendations;
2. `docs/CURRENT_PRODUCT_AUDIT.md` with verified evidence;
3. `docs/DESIGN_SYSTEM.md` documenting tokens and component usage;
4. `docs/ART_ASSET_BRIEF.md` and `assets/art_manifest.json`;
5. updated architecture guidance for the map/avatar/profile boundaries;
6. migration notes if persisted data changes;
7. tests for Player Profile, avatar persistence/rendering, portrait clipping, question UI and map states;
8. updated README/current next steps that describe reality without “all complete” claims;
9. a final `docs/IMPLEMENTATION_REPORT.md` containing:
   - verified root causes;
   - files changed;
   - screenshots or golden locations;
   - tests run and exact results;
   - remaining limitations;
   - dependencies added with reasons;
   - manual device checks still required;
   - separate lists for completed work and recommended future work.

## Definition of done

The task is complete only when all of the following are true, or an exact blocker is documented:

- Player Profile opens, displays canonical live data and handles a new/empty player safely.
- Avatar creation, save, restore, edit and equip flows work after restart.
- The same saved avatar appears consistently in creator, world pawn, profile and relevant rewards/shop views.
- No Flutter overflow/clipping exceptions occur on critical journeys at the target portrait viewports.
- Critical journeys remain usable at 200% text.
- World map hierarchy is clear within three seconds: identity, current location, recommended quest, near reward and primary start action.
- Question UI handles long real content without shrinking, clipping or inaccessible truncation.
- Light, dark, high contrast and reduced motion are respected.
- All critical controls are keyboard accessible and have meaningful semantics.
- `dart format`, `flutter analyze`, `flutter test` and `flutter build web --release` pass.
- Existing saved data is preserved or safely migrated.
- No reachable placeholder or “coming soon” path remains unless deliberately gated and honestly labelled.
- Documentation matches the current implementation.

## Execution sequence and reporting style

Work in this order:

1. baseline and reproduction;
2. build/runtime/profile fixes;
3. persistence regression tests;
4. design tokens and shared primitives;
5. clipping/portrait fixes;
6. avatar renderer and creator;
7. player pawn;
8. map modularisation and redesign;
9. question UI;
10. profile visual redesign;
11. asset pipeline;
12. accessibility/performance pass;
13. full verification and documentation.

At the start, print a concise verified audit plan and the commands you will run. During work, report concrete findings with file paths and evidence. At the end, provide a concise summary grouped into:

- fixed;
- redesigned;
- tests added;
- assets created or specified;
- validation results;
- remaining blockers or manual checks.

Do not ask the user to decide routine engineering details. Make defensible choices, implement them, test them and document them.

---

# Repository-specific continuation: verification matrix and implementation controls

The current repository includes existing test areas for services, UI and world map, plus named tests including `profile_stats_screen_test.dart`, `startup_responsive_smoke_test.dart`, `quest_session_history_service_test.dart`, `shop_rpg_loop_test.dart`, `zone_id_normalization_test.dart`, `adaptive_difficulty_service_test.dart`, `enhanced_question_generator_test.dart` and `question_variation_helper_test.dart`. Read these before adding parallel test infrastructure. Extend their fixtures and conventions where sensible.

## Mandatory code-discovery report before the first refactor

Create `docs/TECHNICAL_DISCOVERY.md` containing verified answers to all of the following. Include exact file paths and symbols, not general descriptions.

### Application composition

- Where `runApp` occurs and which provider/service graph wraps the app.
- Router/navigation mechanism and every route relevant to onboarding, avatar creation, map, quiz, profile, shop and parent views.
- Which screens are reachable from production navigation and which are orphaned or historical.
- Startup initialisation order for Hive, shared preferences, audio, TTS, question data, player state and theme preferences.
- How recoverable initialisation failures are surfaced to the child or parent.

### Player and persistence model

- Canonical player identity model.
- Canonical progress/statistics model.
- Canonical avatar model, cosmetic inventory and equipped-item fields.
- Storage keys, box names, adapter/type IDs and serialisation versions.
- Every place player/profile/avatar state is read, written, copied or cached.
- Duplicate or competing sources of truth.
- What event causes UI listeners to refresh after a completed activity.
- What old-data shapes exist in tests, migration code or defensive readers.

### Visual architecture

- Active ThemeData construction and theme extensions.
- Existing semantic colour, typography, spacing and motion utilities.
- All custom painters used by world map and avatar visuals.
- All asset roots declared in `pubspec.yaml` and all runtime asset path constructors.
- Existing SVG/raster packages and their web limitations.
- Each place Fredoka, Comfortaa and Noto Emoji is declared or referenced.

### Responsive system

- Existing breakpoints and whether they differ between screens.
- Widgets relying on `MediaQuery.size`, `OrientationBuilder`, `LayoutBuilder` or fixed constants.
- Full-screen stacks and overlays most likely to overflow.
- Screens that disable or alter text scaling.
- Existing viewport helpers and smoke-test utilities.

## Change-risk grading

Before editing, assign each proposed change one risk grade:

- R1: visual token/component replacement with no state or persistence impact;
- R2: widget composition or responsive layout change;
- R3: navigation, provider or business-logic change;
- R4: persisted schema, question selection or progression change.

For R3 and R4 work, add regression tests before the refactor where the current behaviour can be captured. For R4, document migration and rollback behaviour. Never combine an R4 migration with an unrelated visual redesign commit.

## Player Profile diagnostic protocol

Do not accept a passing `profile_stats_screen_test.dart` as proof that the real profile works. Investigate these failure classes explicitly:

1. **Discovery/navigation**
   - Is the visible profile/HUD control wired to the expected route?
   - Is another widget intercepting its pointer hit region?
   - Does keyboard activation invoke the same action as touch?
   - Does browser URL/deep-link navigation initialise required providers?

2. **Construction/provider scope**
   - Does the profile use `watch`, `read`, `select`, a singleton or a manually constructed service?
   - Can it be pushed outside the provider scope that owns player history?
   - Is state read before asynchronous hydration completes?
   - Is a provider disposed or recreated during route transition?

3. **Data compatibility**
   - Fresh player with no sessions.
   - Existing player created by the oldest still-supported schema.
   - Missing optional avatar/cosmetic fields.
   - Corrupt or partially written local history.
   - Normalised versus historical zone IDs.
   - Empty achievements, streaks, shop inventory and mastery collections.

4. **Reactivity**
   - Complete a quest, return to profile and verify XP, stars, history and recommendations.
   - Equip a cosmetic and verify the profile avatar without app restart.
   - Change name or avatar and verify every relevant surface updates exactly once.

5. **Presentation**
   - No unbounded list inside another scroll view.
   - No chart relying on non-empty data.
   - No divide-by-zero percentage or invalid date formatting.
   - No misleading “0% weak skill” recommendation created from absence of evidence.

Add an integration-style widget test that pumps the real provider graph or the closest deterministic equivalent and navigates through the actual profile entry point.

## Portrait mobile acceptance scenarios

Create reusable viewport test helpers, then exercise these scenarios at 360x800 and 412x915, in light and dark modes. Run key scenarios at textScaleFactor 2.0 and reduced motion.

### Onboarding/avatar

- Start new profile.
- Move through every creator step.
- Select the option with the longest visible label.
- Open the keyboard for name entry.
- Dismiss it and save.
- Navigate back to edit and verify retained state.

### Map

- Fresh player with mostly locked zones.
- Existing player with multiple available states.
- Recommended quest selected.
- Quest lens expanded and collapsed.
- Zoom to minimum and maximum.
- Centre/focus recommended action.
- Open adventure menu and profile.
- Travel with reduced motion on and off.

### Question

- Longest available prompt from real content fixtures.
- Longest answer set.
- Media/stimulus question if supported.
- Incorrect response showing explanation.
- Correct response showing reward/progress.
- Software keyboard visible where an input answer is supported.

### Profile

- Brand-new empty profile.
- Player with one session.
- Player with enough varied history to show all real sections.
- Edited avatar.
- Parent-only navigation remains separated.

For every scenario, fail on framework overflow, uncaught exception, missing semantics label for primary controls or unreachable primary action.

## Screenshot comparison discipline

For meaningful UI changes:

- Capture a “before” image before modifying that screen.
- Capture “after” at the same viewport, theme, text scale and deterministic fixture.
- Store audit captures outside the runtime asset bundle under a documented screenshots/artifacts directory.
- Do not judge improvement purely by whether it looks more decorative. Judge hierarchy, readability, state clarity, reachability, consistency and child comprehension.
- In `docs/IMPLEMENTATION_REPORT.md`, include a compact before/after finding for each critical screen.

## Design-system migration order

Migrate in this order to minimise visual breakage:

1. typography primitives and text roles;
2. semantic colours and theme extensions;
3. buttons and focus treatment;
4. surfaces/cards/sheets;
5. status badges and progress indicators;
6. question components;
7. avatar creator controls;
8. profile cards;
9. map HUD and quest lens;
10. map world-state visuals.

During migration, support a temporary compatibility layer if required. Remove it once critical screens use the new system. Do not leave two competing “new” design systems.

## Suggested semantic typography roles

Use the existing bundled fonts where they pass legibility and loading checks. Implement roles rather than copying these names blindly:

- `displayLarge`: rare brand/celebration moments;
- `screenTitle`: concise screen identity;
- `sectionTitle`: card and panel headings;
- `questionText`: high-legibility learning prompt;
- `answerText`: multiline response option;
- `body`: instructions and explanations;
- `label`: controls and compact metadata;
- `number`: stable counters for XP, stars, streak and level;
- `caption`: secondary information only.

Do not use decorative display type for paragraph explanations or dense profile statistics. Keep the question and answer fonts visually stable between selection and feedback states so content does not jump.

## Suggested BrightBound colour strategy

Derive final values from existing brand assets and contrast testing. Structure, rather than these exact colours, is mandatory:

- one deep ink role for readable text;
- warm parchment/light canvas and intentional night canvas;
- one primary adventure accent;
- discrete reward gold, XP, success, caution and error roles;
- zone identity colours constrained by shared tonal and saturation rules;
- neutral surface hierarchy that lets world art remain colourful without making UI illegible.

Document permitted gradient recipes. Eliminate arbitrary screen-specific rainbow gradients unless a celebration explicitly calls for one. In high contrast, simplify texture and gradient treatments rather than amplifying them.

## Avatar asset naming contract

Use stable semantic IDs, not display names or array indexes. A possible convention:

```text
assets/art/avatar/base/<companion_id>/<variant>.svg
assets/art/avatar/face/<feature_id>.svg
assets/art/avatar/outfit/<item_id>.svg
assets/art/avatar/accessory/<item_id>.svg
assets/art/avatar/effect/<effect_id>.webp
assets/art/world/<zone_id>/landmark_<id>.webp
assets/art/world/<zone_id>/prop_<id>.webp
assets/art/world/shared/route_<state>.svg
assets/art/ui/reward_<id>.svg
```

Use the convention only if compatible with current packaging and runtime lookup. Add a path registry or generated manifest accessor rather than constructing fragile strings throughout UI code.

Each avatar layer entry should support or document:

- ID;
- category;
- asset path;
- unlock rule reference;
- anchor X/Y;
- scale;
- z-index;
- colourisation capability;
- compatible companion IDs;
- semantic label;
- fallback asset.

Validate that an incompatible item cannot be equipped through UI, migration or direct model restoration.

## World-map modularisation guardrails

The refactor must not merely split one giant file into arbitrary “part” files. Separate by responsibility:

- immutable zone/state/layout definitions;
- map projection and coordinate transforms;
- selection/travel/zoom controller;
- progression-to-visual-state adapter;
- responsive shell/composition;
- HUD;
- quest lens;
- zone landmark widget;
- route painter;
- player pawn;
- effects layer;
- accessibility/focus order.

Keep progression rules outside painters and view widgets. Painters should receive already resolved, immutable visual data. Add equality/repaint tests where useful and ensure `shouldRepaint` does not always return true without reason.

## Question UI content-safety checks

- Preserve the exact learning content and answer truth while refactoring presentation.
- Do not reorder answers after the child has selected one.
- If answer order is randomised, seed it in tests.
- Do not reveal correctness in accessibility labels before submission.
- Hide decorative imagery from semantics unless it conveys required learning information.
- Read-aloud must announce question content in a sensible order, not every decorative counter.
- Feedback animation must not shift the selected answer off-screen before the learner can understand it.
- “Continue” must not become enabled before required feedback/explanation is available.

## Completion audit queries

Immediately before final verification, repeat repository searches for:

```text
TODO
FIXME
HACK
placeholder
coming soon
Color(
fontFamily:
ClipRect
ClipRRect
OverflowBox
FittedBox
maxLines:
overflow: TextOverflow.ellipsis
MediaQuery.of(context).size
AnimationController(
shouldRepaint
catch (_)
catch (e)
!
```

Classify rather than blindly remove matches. For every remaining reachable placeholder or coming-soon result, provide its path, whether it is user-visible and the explicit decision: complete, gate, relabel or defer with reason.

## Final response contract for Claude Code

The final response must be evidence-based and include:

- exact successful verification commands and their outputs summarised without inventing results;
- any command that failed, with the first actionable failure and affected files;
- commit list grouped by purpose;
- migration behaviour and compatibility statement;
- critical before/after screenshots or their repository paths;
- count of remaining analyser errors only if obtained from the actual analyser output;
- count of tests only if obtained from the test runner output;
- known manual checks that automated tests cannot prove;
- explicit statement of what was not changed.

Do not finish with “the plan is ready”. Finish only after making the highest-value safe implementation changes possible in the current environment.

---

# Visual Asset Transformation Roadmap

This section is mandatory and expands the visual work into a production asset programme. The objective is not to add isolated attractive pictures. The objective is to establish a reusable BrightBound visual language whose characters, world, progression, rewards, profile and learning UI all look as though they belong to the same product.

## Visual north star

Use this visual proposition as the starting point, then validate it against current branding and the strongest existing assets:

> BrightBound Adventures is a warm, colourful storybook adventure board with tactile diorama environments, expressive companion characters and crisp, highly readable game UI.

The experience should combine:

- the warmth and imagination of a children's storybook;
- the physical readability of a tabletop adventure board;
- the responsiveness and clarity of a modern educational game;
- the attachment and collectability of a companion-led adventure.

It must not become:

- a generic AI-fantasy image collection;
- a clone or close stylistic imitation of a commercial game;
- an over-glossy casino-like mobile interface;
- a collection of unrelated illustration styles;
- emoji placed over procedural geometry as the main art direction;
- excessively detailed scenery that loses readability on a phone;
- a visual system dependent on colour alone;
- a permanently animated screen that competes with reading and learning.

## Mandatory visual principles

Establish and document these rules in `docs/ART_BIBLE.md`:

- one consistent three-quarter/isometric perspective for map assets;
- one documented light direction, preferably upper-left unless current art establishes another coherent direction;
- soft lower-right grounding shadows;
- rounded, slightly irregular storybook silhouettes;
- strong external silhouettes that remain identifiable at small display sizes;
- restrained internal texture and limited micro-detail;
- consistent outline hierarchy between characters, environment and UI;
- quieter terrain and backdrop saturation than interactive landmarks;
- brightest colour and strongest contrast reserved for the current task, player identity, rewards and feedback;
- no vital feature thinner than the minimum size established through small-scale testing;
- safe overscan around ears, hats, tails, wings, held items, route glows and celebration effects;
- meaningful, event-driven motion rather than constant visual noise;
- theme-aware shadows, outlines and contrast rather than simple colour inversion;
- high-contrast mode that simplifies texture and gradients;
- reduced-motion equivalents for every animated state;
- asset fallbacks that remain understandable and accessible.

## Visual audit outputs

Before replacing or adding assets, create:

1. `docs/ART_BIBLE.md`
2. `docs/VISUAL_ASSET_AUDIT.md`
3. `docs/ART_ASSET_BRIEF.md`
4. `assets/art_manifest.json`
5. `tool/validate_art_manifest.dart` or an equivalent repository-consistent validation utility
6. a documented folder for deterministic before/after captures that is excluded from the runtime application bundle

`docs/VISUAL_ASSET_AUDIT.md` must classify every current visual asset or generated visual path by:

- asset ID;
- current path;
- feature area;
- file format;
- source dimensions or SVG viewBox;
- decoded/display size where measurable;
- runtime display locations;
- current light/dark/high-contrast support;
- current state variants;
- anchor and safe-area status;
- semantic label or decorative status;
- quality status: retain, refine, redraw, replace, consolidate or remove;
- consistency risks;
- performance risks;
- licensing/provenance status if known from repository evidence;
- replacement priority;
- proposed destination path;
- implementation status.

Do not delete an asset solely because it is not directly referenced by a literal string. Check generated paths, manifests, asset registries, theme resolution and dynamic item IDs first.

# Specific repository review order

Review the following files and directories before the first visual implementation commit. The names below include paths confirmed by repository documentation and tests, plus repository areas that must be located by search where architecture has moved. If an exact path no longer exists, locate its replacement and record the mapping in `docs/TECHNICAL_DISCOVERY.md`. Do not recreate a historical file merely to satisfy this list.

## Tier 1: application and dependency truth

Review in depth:

- `pubspec.yaml`
- `pubspec.lock`
- `analysis_options.yaml`
- `README.md`
- `README_CODEX_AUDIT.md`
- `CHANGELOG_CODEX.md`
- `IMPLEMENTATION_CHECKLIST.md`
- `docs/V2_1_PREMIUM_AUDIT_AND_ROADMAP.md`
- `docs/ARCHITECTURE.md`
- `docs/NEXT_STEPS.md`
- `docs/DEV_SETUP.md`
- `docs/CONTRIBUTING.md`
- `.github/workflows/`
- `web/`
- `website/`

From `pubspec.yaml`, verify:

- every declared asset path;
- every declared font family and weight;
- whether folders are declared too broadly;
- SVG, image, animation and cache packages;
- packages that affect web rendering;
- bundled but undeclared resources;
- declared but missing resources;
- runtime assets that are unnecessarily included in release builds.

## Tier 2: critical visual and interaction implementation

Review line by line where present:

- `lib/ui/screens/world_map_screen.dart`
- `lib/ui/screens/avatar_creator_screen.dart`
- `lib/ui/screens/profile_stats_screen.dart`
- `lib/ui/widgets/avatar_widgets.dart`
- `lib/ui/widgets/quiz_widgets.dart`
- `lib/ui/widgets/animated_answer_option.dart`
- `lib/features/mini_games/memory_match_game.dart`
- `lib/features/mini_games/pattern_puzzle_game.dart`
- `lib/features/mini_games/word_search_game.dart`

For each file, document:

- responsibilities currently owned;
- direct colours, fonts, shadows, gradients and radii;
- hard-coded dimensions and offsets;
- clipping and transform behaviour;
- animation ownership and disposal;
- semantics and focus behaviour;
- asset references and fallback behaviour;
- dependencies on player/avatar/progression state;
- opportunities to extract reusable components;
- refactor risk grade;
- existing test coverage;
- exact replacement architecture.

## Tier 3: locate and review by symbol and responsibility

Search the complete `lib/` tree for the actual current files implementing:

- app entry point and `runApp`;
- root provider/service graph;
- route names, route generator, `Navigator`, router or deep-link configuration;
- active ThemeData builders and ThemeExtensions;
- typography declarations and all `fontFamily` usage;
- player model and provider;
- avatar model, provider, renderer and persistence adapter;
- cosmetic inventory, Star Shop and equip flow;
- profile/statistics aggregation;
- quest session history;
- XP, level, stars, streak, mastery and achievements;
- world zone definitions and zone ID normalisation;
- map projection, route geometry, zoom/pan and player travel;
- custom painters;
- audio, TTS and reduce-motion preferences;
- high-contrast and large-text settings;
- asset path registries or generated asset resolution;
- image precaching and error builders;
- question models, question generators and shared quiz preferences;
- reward reveal, celebration and next-quest recommendation logic;
- parent dashboard and parent-access controls.

Record concrete paths and symbol names. Resolve duplicate source-of-truth candidates before changing presentation.

## Tier 4: asset directories

Recursively inspect:

- `assets/`
- every asset directory declared in `pubspec.yaml`;
- font directories;
- any character/avatar directories;
- map/world/zone directories;
- reward, badge, icon and cosmetic directories;
- animation/audio directories where visuals are paired with feedback;
- source-art or documentation directories that may be accidentally bundled;
- generated caches such as `.wrangler/cache` and any inappropriate committed build output.

Produce inventories by extension and decoded size. Detect:

- duplicate binaries under different names;
- case-sensitive path mismatches that fail on web/Linux;
- assets with whitespace or inconsistent casing;
- very large images displayed at small sizes;
- missing density variants where relevant;
- transparent images with excessive empty canvas;
- inconsistent internal padding;
- assets whose visible silhouette touches or exceeds the canvas edge;
- mismatched light direction or perspective;
- unsupported or unreliable rendering paths;
- source files accidentally shipped in production;
- visual assets without documented provenance.

## Tier 5: testing truth

Review and extend, not blindly duplicate:

- `test/profile_stats_screen_test.dart`
- `test/startup_responsive_smoke_test.dart`
- `test/quest_session_history_service_test.dart`
- `test/shop_rpg_loop_test.dart`
- `test/zone_id_normalization_test.dart`
- `test/adaptive_difficulty_service_test.dart`
- `test/enhanced_question_generator_test.dart`
- `test/question_variation_helper_test.dart`
- `test/world_map/`
- `test/ui/`
- `test/services/`
- `test/tools/`

Locate avatar creator, avatar persistence, theme, accessibility and golden tests if their paths differ. Establish whether tests pump production provider composition or use simplified mocks that can conceal route and hydration failures.

# Art production strategy

## Use an asset-family approach

Do not create visual assets one screen at a time. Define reusable visual families first, then create the members of each family from one specification.

Required families:

1. companion/avatar family;
2. map-pawn family;
3. world-zone family;
4. terrain and route family;
5. progression-state family;
6. reward and achievement family;
7. learning-action icon family;
8. feedback/expression family;
9. profile and home-scene family;
10. empty/loading/offline/error-state family;
11. UI ornament and frame family;
12. optional seasonal/event family, gated until the core system is complete.

For every family, define:

- art owner and implementation owner;
- base grid or canvas;
- export sizes;
- perspective;
- outline rules;
- colour rules;
- shadow rules;
- texture rules;
- safe area;
- anchors;
- z-order;
- runtime states;
- theme variants;
- reduced-motion behaviour;
- semantic treatment;
- fallback treatment;
- performance budget;
- validation method.

# Priority Asset Pack 1: avatars and companions

## Required companion architecture

Determine the currently supported companion types from code and persisted data. Do not invent IDs that break old saves. For every supported companion, create or specify:

- base silhouette/body;
- face base;
- eye states;
- mouth/expression states;
- hair, fur marking, crest, horns, ears or equivalent identity layer;
- body colour and secondary colour masks where supported;
- starter outfit;
- outfit overlay contract;
- accessory contract;
- held-item contract where supported;
- back accessory such as wings or pack where supported;
- foreground effect contract;
- grounding shadow;
- selection/focus base;
- locked silhouette;
- small map-pawn representation;
- medium UI bust;
- large creator/profile rendering.

## Required expression set

Where character architecture permits, provide a deterministic expression set:

- neutral;
- happy;
- celebrating;
- thinking;
- encouraging;
- surprised;
- determined;
- gentle try-again.

Expressions must not radically change feature anchors or make equipped items move unpredictably. They must remain calm and supportive for incorrect-answer feedback.

## Shared coordinate and layer contract

Implement one canonical avatar rendering contract. Suggested conceptual order:

```text
back effect
back accessory
body/base
secondary markings
outfit lower
outfit upper
face
hair/ears/horns/crest foreground
front accessory
held item
foreground effect
selection/focus treatment outside avatar canvas
```

Adapt this to actual character anatomy. Define:

- one normalised canvas/viewBox;
- origin and grounding line;
- head, face, hand, back and top-of-head anchors;
- safe overscan;
- z-index;
- clipping policy;
- colourisation policy;
- compatibility rules;
- fallback layer behaviour.

The same canonical data must drive creator, map pawn, profile, shop preview, equip confirmation and reward reveal. Do not maintain screen-specific avatar composites.

## Avatar usability requirements

- The live preview remains visible in portrait mode without shrinking controls below accessible sizes.
- Child can undo or reset only if state safety is clear.
- A randomise function is allowed only if it creates valid compatible combinations and can be reversed before saving.
- Colour swatches expose meaningful spoken labels.
- Selection is communicated by check, outline and semantics, not colour alone.
- Locked, owned, equipped, selected and previewed states are distinct.
- Long labels wrap rather than forcing tiny type.
- Save is explicit and persisted before transitioning.
- Exiting with unsaved edits is handled safely.
- Existing saves with missing layers use deterministic defaults.

# Priority Asset Pack 2: the player map pawn

The map pawn is a purpose-designed small-scale derivative of the saved avatar, not merely the full portrait scaled down and not an unrelated generic figure.

Required characteristics:

- exaggerated readable silhouette;
- larger head-to-body ratio if needed for map legibility;
- simplified internal detail;
- strong theme-aware outline;
- stable oval grounding shadow;
- location or selection base rendered outside the avatar art;
- one or two recognisable equipped-item cues;
- no crucial face detail required below its minimum display size;
- no clipping during idle, focus, bounce, travel, route turns or celebration;
- deterministic reduced-motion state;
- semantic description including player identity and current zone.

Create or specify pawn states:

- idle;
- selected;
- travelling;
- arriving;
- quest ready;
- reward earned;
- level up;
- reduced-motion equivalents.

One controller/state owner should orchestrate pawn motion. Avoid independent animation controllers for every map node or asset layer.

# Priority Asset Pack 3: eight zone identity kits

Confirm the current zone IDs, routing and marketed names before binding assets. Preserve compatibility with historical IDs and zone normalisation.

Each active zone requires:

- one hero landmark;
- two or three medium supporting props;
- at least three small terrain decorations derived from a reusable zone kit;
- one entrance/gate treatment;
- one route treatment or shared route variant;
- one locked treatment;
- one recommendation motif;
- one boss-ready treatment if bosses apply;
- one mastery transformation/decorative reward;
- one badge;
- one quest-icon subset;
- one reward container or reward motif;
- one restrained ambient motif;
- a quiet terrain palette;
- an intentional dark-mode treatment;
- a simplified high-contrast treatment.

Use the following as creative direction to be validated against actual zone semantics, not as blindly fixed implementation:

- Word Woods: a giant book-tree, letter leaves and a lantern library;
- Number Nebula: an observatory among geometric planets;
- Math Facts: a bright mechanical numberworks or calculation foundry;
- Story Springs: an open storybook waterfall flowing into an ink-blue river;
- Science Explorers: a field laboratory with telescope, specimens and weather instruments;
- Creative Corner: a colourful workshop representing visual art, music and making;
- Puzzle Peaks: a mountain temple built around interlocking puzzle stones;
- Adventure Arena: a celebratory arena with restrained banners representing the connected worlds.

These concepts are suggestions. Maintain originality, child safety and curriculum appropriateness. Revise them when current game content indicates a better fit.

## World asset state programme

The map must visually communicate:

- locked;
- available;
- recommended;
- in progress;
- needs review;
- boss ready;
- mastered;
- current location;
- near reward where applicable.

Create a combination of reusable state assets and zone transformations:

- locked gate or seal;
- available landing marker;
- recommended beacon;
- in-progress route stamps or footprints;
- review ribbon/refresh marker;
- boss banner;
- mastery flag, crest or decoration;
- completed route treatment;
- current-location base;
- quest destination marker;
- reward-near indicator.

State communication must combine icon/shape, label or accessible text, tone and restrained motion. Colour alone is insufficient.

## Visible world transformation

Where progression data supports it, prefer visible one-time or persistent world changes such as:

- bridge repaired;
- lanterns illuminated;
- banner raised;
- gate opened;
- landmark restored;
- flowers, crystals or stars appearing;
- earned decoration placed near a zone;
- route becoming complete;
- mastery monument or flag appearing.

Do not invent progression data solely to animate scenery. Map existing progression safely into visual states.

# Priority Asset Pack 4: terrain, routes and board materials

Create a compact reusable diorama-board kit:

- board edge/cutaway;
- grass/ground base;
- water or void edge where required;
- cliffs/steps;
- bridges;
- route straight, curve, junction and endpoint geometry;
- route state overlays;
- quiet cloud/fog layer;
- rock, shrub and signpost families;
- landmark grounding patches;
- selection/focus rings;
- accessible high-contrast route mode.

Do not create dozens of unique terrain tiles unless the renderer genuinely needs them. Prefer a coherent modular kit with enough variation to avoid obvious repetition.

Test route readability beneath the player pawn, zone labels, focus rings and quest sheet. Paths should not depend on glow alone in light mode or colour alone in any mode.

# Priority Asset Pack 5: rewards and achievement language

Create one shared reward grammar for XP, stars, streaks, level-ups, quests, mastery, achievements, cosmetics and shop unlocks.

Required assets or visual components:

- star currency;
- XP spark/energy;
- streak flame or equivalent;
- quest-complete seal;
- level-up medallion;
- achievement badge frame system;
- mastery crest;
- boss key/ticket where supported;
- locked reward silhouette;
- newly unlocked frame/burst;
- treasure parcel/chest or original reward container;
- cosmetic rarity/collection frame if rarity exists in code;
- certificate seal;
- near-unlock progress treatment.

## Badge frame system

Avoid illustrating every achievement from scratch. Build a reusable badge framework:

- shared outer frame;
- category-specific inner treatment;
- central achievement symbol;
- locked state;
- earned state;
- mastered/upgraded state where supported;
- small simplified version;
- large reveal version;
- semantic label independent of the illustration.

Do not introduce manipulative rarity mechanics or misleading reward scarcity. Use the actual reward and shop data model.

# Priority Asset Pack 6: learning-action icon family

Create a coherent icon family for the actions actually present in the app. Candidate meanings include:

- listen;
- speak;
- read;
- spell;
- count;
- compare;
- sort;
- match;
- sequence;
- investigate;
- create;
- solve;
- check;
- hint;
- try again;
- explanation;
- continue.

First inventory the current interaction types and retain only relevant icons. Icons must share:

- base grid;
- stroke/fill style;
- corner language;
- optical weight;
- active, disabled, focused and high-contrast treatments;
- semantic labels;
- minimum-size testing.

Do not replace familiar platform actions with ambiguous decorative symbols. Text labels should remain where young users may not understand an icon alone.

# Priority Asset Pack 7: question feedback and instructional visuals

Use the companion system to deliver emotional continuity:

- neutral/attentive during the prompt;
- thinking for hint;
- encouraging for an incorrect attempt;
- celebrating for success;
- calm supportive state for explanation;
- reward reaction after learning feedback is understood.

Additional required visual components:

- stimulus frame;
- audio/read-aloud state;
- selected answer treatment;
- submitted/locked answer treatment;
- correct treatment;
- incorrect treatment;
- explanation card ornament;
- hint treatment;
- progress marker;
- next-action treatment.

Decorations must never distract from phonemes, words, equations, diagrams, scientific stimuli or answer choices. Preserve content truth and screen-reader order.

# Priority Asset Pack 8: Player Profile and learner home identity

Once profile functionality is fixed, add a coherent profile visual family:

- avatar portrait frame;
- player-name and level crest;
- XP progress visual;
- current-zone or home-camp backdrop;
- next-adventure illustrated card;
- achievement shelf or collection panel;
- recent-journey trail;
- equipped-item display;
- new-player welcome illustration;
- no-history state;
- no-achievement state;
- useful “practise next” visual grounded in real learner evidence.

Consider a small campsite/lookout scene for the profile header, derived from the world art system. Earned decorations may appear only when actual progression data supports them. Keep statistics readable and do not turn the screen into an illustration that obscures information.

# Priority Asset Pack 9: empty, loading, offline and error states

Create a reusable family for:

- no quests completed;
- no recent history;
- no achievements;
- no available shop items in a filtered category;
- content unavailable;
- visual asset failed to load;
- saving;
- loading adventure;
- offline/local mode;
- parent insights not yet available;
- recoverable data problem;
- unrecoverable startup problem with a safe action.

Use companions and world props rather than enlarged generic Material icons. Keep messages concise, honest and actionable. Differentiate loading from empty and error states.

# Format and implementation decisions

## SVG

Prefer for assets that benefit from scale, recolouring or state composition:

- UI icons;
- badges;
- route pieces;
- gates and seals;
- simple landmarks;
- avatar layers, only if the current Flutter/web renderer proves reliable for the required clipping, masks and colourisation.

Validate rendering, semantics, caching and web performance in the actual application. Do not adopt SVG universally on principle.

## WebP/PNG

Prefer for:

- painted terrain;
- complex landmarks;
- textured profile scenes;
- backdrop compositions;
- one-shot celebration frames/effects.

Use WebP where supported and verified in the release web build. Use PNG where alpha fidelity or compatibility makes it safer. Export close to intended maximum display size and document decoded-memory implications.

## Custom painters

Retain or introduce only where runtime state genuinely benefits:

- dynamic routes;
- progress rings;
- focus/selection outlines;
- mathematical/learning geometry;
- simple procedural effects;
- state-dependent connectors.

Do not use painters to avoid creating authored landmarks or character art. Painters should receive immutable resolved visual data, not query progression or providers directly.

## Animation formats

Inventory current animation dependencies before adding any. Prefer native Flutter transitions and small stateful effects where adequate. Any sprite, Rive, Lottie or equivalent addition requires:

- package and runtime justification;
- web compatibility proof;
- reduced-motion fallback;
- size budget;
- deterministic test strategy;
- no degradation of startup or map performance.

# Asset manifest schema

Implement `assets/art_manifest.json` with a documented schema. Each record should support fields equivalent to:

```json
{
  "id": "world.word_woods.landmark.book_tree",
  "family": "world_landmark",
  "featureArea": "world_map",
  "path": "assets/art/world/word_woods/landmark_book_tree.webp",
  "format": "webp",
  "status": "existing|refine|redraw|missing|approved",
  "themes": ["light", "dark", "high_contrast"],
  "states": ["available", "recommended", "mastered"],
  "sourceWidth": 1024,
  "sourceHeight": 1024,
  "safePadding": {"top": 48, "right": 48, "bottom": 64, "left": 48},
  "anchors": {"ground": [0.5, 0.86], "label": [0.5, 0.98]},
  "zIndex": 30,
  "semanticLabel": "Book Tree landmark",
  "decorative": false,
  "fallbackId": "world.shared.landmark_fallback",
  "budgetBytes": 250000,
  "compatibleIds": [],
  "provenance": "repository|commissioned|generated-and-reviewed|unknown",
  "notes": ""
}
```

Modify fields to fit repository conventions. Do not include misleading placeholder dimensions or provenance. Add validation for:

- unique IDs;
- valid paths;
- supported formats;
- valid normalised anchors;
- non-negative dimensions and budgets;
- fallback existence;
- compatible IDs;
- manifest paths present in `pubspec.yaml` coverage;
- missing semantic labels on non-decorative assets;
- accidental semantic labels on purely decorative layers;
- case-sensitive file matches.

# Suggested folder contract

Adopt only after reconciling current paths and migration cost:

```text
assets/art/
  avatar/
    base/<companion_id>/
    face/
    marking/
    outfit/
    accessory/
    held_item/
    effect/
    pawn/
  world/
    shared/
    <zone_id>/
      landmark/
      prop/
      terrain/
      gate/
      mastery/
  routes/
  rewards/
    currency/
    badges/
    mastery/
    reveal/
  learning/
    actions/
    feedback/
    stimulus/
  profile/
  states/
    empty/
    loading/
    offline/
    error/
  ui/
    frame/
    ornament/
    focus/
```

Do not undertake a destructive asset move without updating all references, testing case-sensitive web builds and providing a clean rollback commit.

# Asset creation briefs

For every missing or replacement asset, `docs/ART_ASSET_BRIEF.md` must provide a copy-ready brief containing:

- asset ID and destination path;
- feature and exact placements;
- narrative purpose;
- composition;
- camera/perspective;
- subject and supporting elements;
- background and transparency requirement;
- light direction;
- silhouette requirement;
- outline and texture rules;
- palette roles rather than arbitrary colours;
- intended source dimensions or viewBox;
- expected display sizes;
- safe padding;
- anchors;
- layer/z-order;
- required state/theme variants;
- whether text or numbers are prohibited inside the image;
- semantic label or decorative status;
- export format and compression target;
- decoded-size budget;
- acceptance checks;
- development fallback;
- production approval status.

Generated artwork must be considered draft production material until reviewed for:

- originality;
- child appropriateness;
- visual consistency;
- accidental symbols/text;
- anatomy and layer alignment;
- contrast;
- small-size readability;
- theme compatibility;
- licence/provenance requirements.

Never place important copy, labels, numbers or curriculum content inside raster artwork. Keep textual content live, localisable and accessible.

# Visual performance budgets

Measure before establishing final thresholds. Then document budgets for:

- maximum decoded dimensions by family;
- maximum compressed size by family;
- total initial route asset load;
- world-map initial load;
- avatar creator initial load;
- image-cache strategy;
- precache limits;
- simultaneous animated elements;
- repaint boundaries;
- shader/mask/filter usage.

Profile release builds. Do not report performance gains without measurements. Prefer loading the selected zone/companion assets over preloading the entire catalogue. Provide visible but attractive fallbacks during async asset loading.

# Visual accessibility gates

For every core visual family, verify:

- meaningful information has a text/semantic equivalent;
- decorative layers are excluded from semantics;
- colour is not the only state cue;
- focus remains visible against light and dark art;
- large text does not overlap illustrations;
- artwork does not sit behind critical text unless contrast is guaranteed by an overlay/surface;
- high-contrast mode remains understandable without texture or subtle glow;
- reduced motion does not remove required state change;
- screen-reader focus does not traverse every decorative map prop;
- tap targets are defined by accessible widgets, not transparent pixels in oddly shaped art;
- error and incorrect-answer states remain supportive and unambiguous.

# Visual QA matrix

For avatar, map, question UI and profile, record evidence at:

- 360x800 portrait;
- 390x844 portrait;
- 412x915 portrait;
- 800x1280 tablet portrait;
- 1024x768 tablet landscape;
- 1366x768 desktop;
- light theme;
- dark theme;
- high contrast;
- text scale 1.0;
- text scale 2.0;
- reduced motion on/off where relevant.

Include states that commonly expose defects:

- longest player name supported;
- largest ears/horns/hair;
- tallest hat;
- widest back accessory;
- held item plus foreground effect;
- long zone label;
- expanded quest lens;
- browser resize during map use;
- fresh/empty profile;
- profile with rich history;
- long question and answers;
- error fallback with missing asset;
- locked/recommended/boss/mastered zones on one map fixture.

Fail visual acceptance for:

- Flutter overflow errors;
- clipped identity-defining avatar features;
- critical controls covered by art;
- unreadable text caused by art;
- inconsistent companion appearance across screens;
- state communicated only through colour;
- missing fallback;
- asset-load exception;
- focus indicator hidden by illustration;
- primary action below an unreachable scroll region.

# Delivery milestones

## Milestone A: truth and foundations

- Complete technical and asset inventory.
- Reproduce profile and clipping failures.
- Establish baseline screenshots.
- Create art bible and manifest schema.
- Correct build/analyser/runtime blockers.
- Confirm canonical avatar/player/progression sources.

## Milestone B: design system and reliable composition

- Implement semantic tokens and typography.
- Create shared surfaces, controls, focus and state treatments.
- Fix portrait constraints before adding heavier art.
- Add missing/error fallbacks.
- Extend responsive tests.

## Milestone C: avatar vertical slice

- Implement canonical layered renderer.
- Migrate creator and persistence safely.
- Add one fully complete companion as the reference implementation.
- Render the same identity in creator, profile, shop/reward preview and map pawn.
- Add golden and regression tests.
- Only then scale the pipeline to remaining companions.

## Milestone D: one complete world vertical slice

- Select one representative zone.
- Implement hero landmark, props, gate, route, progression states, quest lens relationship and theme variants.
- Validate phone portrait through desktop.
- Establish performance and export budgets.
- Use this approved slice as the template for the remaining zones.

## Milestone E: full map and reward system

- Complete all active zone kits.
- Complete shared terrain/routes.
- Add visible progression transformations.
- Complete reward and achievement family.
- Modularise map code around immutable visual data and one motion hierarchy.

## Milestone F: learning and profile polish

- Complete learning-action icons.
- Complete companion feedback set.
- Refine question and explanation visuals.
- Complete profile/home scene and empty states.
- Validate state freshness and learner evidence.

## Milestone G: release proof

- Complete accessibility matrix.
- Complete performance profiling.
- Validate manifest and asset bundles.
- Run full format/analyse/test/release-build gates.
- Update documentation to current truth.
- Produce final before/after gallery and implementation report.

# Prioritisation framework

Use this order when trade-offs are required:

1. runtime correctness and saved-data safety;
2. child readability and accessibility;
3. portrait reachability and clipping;
4. consistent player identity;
5. map state comprehension;
6. question clarity and feedback;
7. visual cohesion;
8. delight and animation;
9. catalogue breadth;
10. optional seasonal content.

A smaller complete, coherent asset family is better than a large unfinished set. One fully implemented companion and zone should establish the pipeline before mass production.

# Expanded visual definition of done

Visual work is complete only when:

- `docs/ART_BIBLE.md`, `docs/VISUAL_ASSET_AUDIT.md`, `docs/ART_ASSET_BRIEF.md` and `assets/art_manifest.json` exist and reflect the implementation;
- asset validation passes;
- every active companion uses the same renderer contract;
- avatar save/restore/equip remains compatible with existing data;
- identity is consistent across creator, map pawn, profile and previews;
- identity-defining features do not clip in target states and dimensions;
- each active world has a distinct but system-consistent identity kit;
- locked, available, recommended, in-progress, review, boss-ready and mastered states are comprehensible without relying only on colour;
- rewards share a coherent visual language;
- learning-action icons use one system and retain text where required;
- profile, empty, loading, offline and error states are intentionally designed;
- light, dark and high-contrast treatments are intentional;
- reduced motion is supported;
- decorative assets are excluded from screen-reader traversal;
- no important text is embedded in artwork;
- missing assets resolve to tested, meaningful fallbacks;
- release bundles do not include accidental source art, caches or oversized unused assets;
- before/after evidence demonstrates improved hierarchy, readability, consistency and state clarity;
- critical viewports have no overflow or inaccessible clipping;
- full verification commands pass or exact blockers are documented with evidence.

# Final instruction

Treat visual assets as a product system, not decoration. Begin with verified code and asset discovery, build one complete avatar vertical slice and one complete world vertical slice, validate them in the running application, then scale the approved system across the repository. Do not claim success because new files exist. Success means the assets are integrated, responsive, accessible, performant, consistent with saved state and proven by tests and screenshots.
