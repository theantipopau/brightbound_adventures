# BrightBound Adventures — v2.1 Full Improvement Agent Prompt
> **For:** Claude Code / Codex Agent  
> **Project:** `theantipopau/brightbound_adventures`  
> **Scope:** Visual / 3D / Art immersion + Question backend overhaul  
> **Discipline:** Evidence-first. Read before you touch. Preserve everything working.

---

## ⛔ MANDATORY PRE-WORK — READ ALL OF THESE FIRST

Before writing a single line of code or modifying any file, you MUST read and internalise the following documents in this exact order. Do not skip any. Do not proceed to tasks until all are read.

```
/docs/V2_1_3D_VISUAL_DIRECTION.md          ← Style bible. Every visual decision must honour this.
/docs/V2_1_RELEASE_EXECUTION_PLAN.md       ← Current roadmap and task assignments (WM-7, WM-8, A3D series)
/docs/COMPREHENSIVE_AUDIT.md               ← Full gap analysis. Know what is broken before touching it.
/docs/AUDIT_AND_IMPROVEMENT_REPORT.md      ← Specific fixes already applied. Do not re-apply.
/docs/AUSTRALIAN_NAPLAN_COMPLETE.md        ← ACARA alignment rules. Every question must pass this.
/docs/COMPLETE_IMPLEMENTATION_SUMMARY.md   ← Quick-win inventory. Check what is already code-ready.
/lib/core/utils/isometric_engine.dart      ← The 3D engine. Understand it before adding visuals.
/lib/core/utils/world_map_isometric_helper.dart ← Map bindings. 10×10 grid, 100×50px tiles, 2:1 dimetric.
/lib/core/data/naplan_year3_numeracy.json  ← The JSON question schema prototype. All new questions use this.
/assets/images/                            ← List all existing props. Every new asset must match their style.
```

After reading, write a brief internal summary (in a comment block or scratchpad note) confirming:
- The visual style target (clay/toy render, rounded edges, subsurface warmth, soft top-left light)
- The 10×10 isometric grid tile dimensions
- Which zones currently have no question sets
- The JSON question schema fields (id, difficulty, hint, topic, ACARA code)

**Only then begin the tasks below.**

---

## ⚙️ GLOBAL CONSTRAINTS (apply to every task)

1. **Do not refactor working systems.** If it builds and passes tests, leave the structure alone.
2. **Preserve all existing question IDs** in `AustralianNAPLANQuestions.dart` and any JSON files. Never reassign or delete an ID.
3. **Do not introduce Unity, Godot, three.js, Flame-3D, or any runtime 3D engine.** Stay in Flutter with pre-rendered sprites. The decision is documented in `V2_1_3D_VISUAL_DIRECTION.md` and is final.
4. **All new assets must match the existing prop style** (chest, crystals, potion, gold pile, scroll in `/assets/images/`). Clay/toy render. Rounded edges. Transparent background. Soft shadow included in sprite.
5. **All new questions must align with ACARA v9.0** and use Australian English spelling throughout (colour, favourite, organise, etc.).
6. **Never install new packages without first checking `pubspec.yaml`** to confirm they are not already present.
7. **Run `flutter analyze` and `flutter test` after every task group.** Fix all warnings and errors before proceeding.
8. **Do not touch `pubspec.lock`** unless you have added a dependency to `pubspec.yaml` and run `flutter pub get`.
9. **Each task has a verification gate.** Do not mark a task complete unless its gate passes.

---

## 🎨 PART A — VISUAL / 3D / ART & IMMERSION

### A1 — Activate Parallax Camera Layers on World Map

**Why:** The audit confirmed this is the highest-impact single visual addition. Two stacked layers (background haze + midground zone islands) massively elevate depth perception with zero runtime GPU cost.

**Files to read first:** `/lib/core/utils/isometric_engine.dart`, `/lib/features/world_map/`

**Task:**
1. Read the existing `IsometricMovementController` and depth-sort logic fully.
2. Add a `ParallaxMapLayer` widget that accepts a scroll/drag offset and applies a configurable parallax multiplier.
   - Layer 0 (sky/haze): multiplier `0.15` — slow drift
   - Layer 1 (midground islands): multiplier `0.4` — moderate drift
   - Layer 2 (foreground / active tile): multiplier `1.0` — no change (current map)
3. Wire it to the existing `IsometricMovementController`'s pan offset.
4. For now, Layer 0 can use a soft gradient or the nearest matching existing asset. Do NOT block on new art being generated.
5. Ensure parallax is disabled when `MediaQuery.disableAnimations` is true (reduced motion accessibility).

**Verification gate:** Drag the world map on desktop and mobile. Background drifts visibly slower than foreground. Reduced-motion mode shows no parallax drift.

---

### A2 — Author Zone Art for All Eight Worlds

**Why:** The isometric engine works. The zones display as coloured cards, not worlds. This is the largest visual gap.

**Style rules (from `V2_1_3D_VISUAL_DIRECTION.md` — non-negotiable):**
- Clay/toy render — soft plastic and clay materials, rounded edges, subtle subsurface warmth
- NOT flat vector. NOT realistic PBR.
- Soft afternoon light from top-left
- Transparent background PNG sprites
- Must sit convincingly next to the existing chest, crystals, potion props in `/assets/images/`

**Asset targets per zone (create a sprite for each — isometric perspective, 2:1 dimetric):**

| Zone | Tile Theme | Landmark Sprite | Path Style | Accent Prop |
|------|-----------|-----------------|------------|-------------|
| Word Woods | Enchanted forest, mossy green | Giant stone book arch | Vine-covered stone | Glowing word-sign post |
| Number Nebula | Deep space, indigo/violet | Ringed planet platform | Star-dust bridge | Floating number crystal |
| Math Facts | Clockwork arcade, brass/gold | Giant abacus tower | Gear-track path | Neon score counter |
| Story Springs | Waterfall meadow, aqua/green | Cascading scroll waterfall | Lily-pad stepping stones | Floating story lantern |
| Science Explorers | Lab/jungle hybrid, teal/orange | Oversized test-tube tree | Circuit-board path | Floating atom cluster |
| Creative Corner | Art studio, rainbow pastels | Giant palette easel | Paint-splatter path | Floating colour bubble |
| Puzzle Peaks | Mountain ruins, grey/amber | Stone temple puzzle gate | Broken flagstone path | Hovering puzzle piece |
| Adventure Arena | Stadium arena, red/gold | Champion banner tower | Cobblestone arena path | Floating trophy cup |

**For each zone, produce:**
- `zone_[name]_tile_base.png` — isometric base tile (100×50px render area, 2:1 dimetric)
- `zone_[name]_landmark.png` — hero landmark sprite (transparent bg, soft shadow baked in)
- `zone_[name]_path.png` — connecting path segment tile
- `zone_[name]_accent.png` — small accent prop (matches existing prop style)

**Output location:** `/assets/images/zones/[zone_name]/`

**Register all new assets in** `pubspec.yaml` under `flutter > assets`.

**Verification gate:** All 8 zones display their authored tile art on the world map with no missing asset errors. Assets visually match the clay/toy style of the existing chest and crystal props.

---

### A3 — Companion Emotion Animations Wired to Quiz Feedback

**Why:** The audit flags this as missing. Children need emotional feedback — a companion that reacts builds empathy and motivation.

**Files to read first:** `/lib/features/avatar/`, `/lib/features/quiz/` or equivalent quiz screen, existing companion rendering code.

**Task:**
1. Identify the companion character rendering widget.
2. Add the following animation states if not already present:
   - `idle` — gentle float/breathe loop (already partially done per changelog — verify)
   - `celebrate` — bounce + spin, 0.6s, triggered on correct answer
   - `encourage` — gentle droopy then recover, 0.5s, triggered on wrong answer
   - `level_up` — full-screen hop + glow, 1.2s, triggered on XP level-up
   - `mastered` — star burst pose, 1.0s, triggered on skill mastery
3. Connect `celebrate` and `encourage` to the answer evaluation callback in the quiz loop (currently in `MultipleChoiceGame.dart` — haptic is already there, add animation alongside it).
4. Ensure animations respect `MediaQuery.disableAnimations`.
5. Companion must return to `idle` cleanly after any animation completes.

**Verification gate:** Answer a question correctly — companion celebrates. Answer wrongly — companion droops. Level up — full `level_up` animation fires once and returns to idle.

---

### A4 — Sound Effects and Zone Ambient Audio

**Why:** Audio infrastructure exists (`AudioManager`, `SoundEffectsService`) but no actual audio files are wired. The audit confirmed this is a +20% immersion gain.

**Files to read first:** `/lib/core/services/audio_manager.dart`, `/lib/core/services/sound_effects_service.dart`

**Task:**

**Step 1 — Source audio files (free, licence-compatible):**
- Use [freesound.org](https://freesound.org) (Creative Commons 0 / CC-BY) or [Zapsplat](https://www.zapsplat.com) for:
  - `correct_answer.mp3` — upbeat chime/sparkle (short, <1s)
  - `wrong_answer.mp3` — soft thud/wobble (short, <1s)
  - `level_up.mp3` — fanfare, 2s
  - `skill_mastered.mp3` — triumphant jingle, 3s
  - `button_tap.mp3` — soft click, <0.3s
  - `zone_unlock.mp3` — discovery shimmer, 1.5s
  - `streak_milestone.mp3` — celebration burst, 2s

- Zone ambient loops (16–30s looping, very quiet — children's focus audio):
  - `ambient_word_woods.mp3` — gentle forest, birdsong
  - `ambient_number_nebula.mp3` — soft space hum, subtle synth
  - `ambient_math_facts.mp3` — light clockwork ticking ambience
  - `ambient_story_springs.mp3` — water stream, soft meadow
  - `ambient_science_explorers.mp3` — light laboratory hum
  - `ambient_creative_corner.mp3` — upbeat playful strings
  - `ambient_puzzle_peaks.mp3` — light cave echo, wind
  - `ambient_adventure_arena.mp3` — low crowd murmur, distant fanfare

**Step 2 — Wire to existing services:**
- Add audio file references to `SoundEffectsService`.
- Trigger `correct_answer`, `wrong_answer` from the quiz answer callback (where haptic already fires).
- Trigger `level_up`, `skill_mastered`, `zone_unlock`, `streak_milestone` from their respective event handlers.
- Start zone ambient when entering a zone screen; stop/fade on exit.
- Respect the existing audio toggle setting in Settings screen.

**Output location:** `/assets/audio/sfx/` and `/assets/audio/ambient/`

**Register all audio assets in** `pubspec.yaml`.

**Verification gate:** All 8 sound effects play at correct moments. Zone ambient music starts on zone entry, fades on exit. Audio toggle in settings mutes all audio correctly.

---

### A5 — Button Juice and Interaction Polish

**Why:** Documented quick-win in `/docs/COMPLETE_IMPLEMENTATION_SUMMARY.md`. Estimated +5% polish perception.

**Task:**
1. Find all `JuicyButton` or equivalent interactive button widgets.
2. Update animation scale from `1.05` → `1.12`.
3. Add slight rotation effect (`±2°`) with press.
4. Change easing curve to `Curves.elasticOut` on release.
5. Ensure all zone card taps, answer option taps, and navigation buttons use this updated animation.
6. Apply `button_tap.mp3` (from A4) on every button press.
7. Ensure reduced-motion mode skips the scale and rotation (show instant state change only).

**Verification gate:** Tap any button — it scales to 1.12 with elastic bounce and slight tilt. Reduced-motion mode shows no animation.

---

### A6 — Lottie Animations for Level-Up and Badge Unlock

**Why:** `reward_animations.dart` exists but is bare. These are the highest-emotion moments in the game loop.

**Files to read first:** `/lib/features/rewards/reward_animations.dart`

**Task:**
1. Check if `lottie` package is in `pubspec.yaml`. If not, add `lottie: ^3.x` (check pub.dev for current version).
2. Source two Lottie animations from [LottieFiles.com](https://lottiefiles.com) (free licence):
   - A star burst / confetti explosion — for Level Up
   - A badge/medal reveal — for Badge/Achievement Unlock
3. Save as `/assets/lottie/level_up.json` and `/assets/lottie/badge_unlock.json`.
4. Implement `LevelUpOverlay` widget using the Lottie file — full-screen overlay, auto-dismisses after animation completes (~2s).
5. Implement `BadgeUnlockOverlay` widget similarly.
6. Wire `LevelUpOverlay` to the XP level-up event.
7. Wire `BadgeUnlockOverlay` to the achievement/badge unlock event.
8. Both overlays must be dismissible by tap and must respect reduced-motion (show static frame only if `MediaQuery.disableAnimations`).

**Verification gate:** Level up triggers — Lottie animation plays full screen, then auto-dismisses. Badge unlock triggers — badge animation plays. Reduced-motion shows static reward image, no motion.

---

### A7 — Desktop Side-by-Side Quiz Layout

**Why:** The audit confirms desktop is 60% complete. Quiz on desktop shows a mobile stacked layout wasting significant whitespace at 1920×1080.

**Files to read first:** `/lib/ui/layouts/responsive_quiz_layout.dart` (or equivalent)

**Task:**
1. Read the existing `ResponsiveQuizLayout` fully.
2. For screen widths ≥ 900px (tablet/desktop breakpoint), implement a **two-column layout**:
   - Left column (60% width): question text, question image (if any), hint area
   - Right column (40% width): answer options, streamed vertically
3. For screen widths < 900px (mobile): keep existing stacked layout unchanged.
4. Add mouse hover effects to answer option tiles on desktop — subtle background highlight (`Colors.white.withOpacity(0.12)`) on hover.
5. Add tooltip on zone cards showing zone name + unlock requirement on hover.
6. Verify keyboard navigation (Arrow keys, Enter, Space, ESC) still works correctly in the new layout.

**Verification gate:** On a 1920×1080 browser window, quiz shows two-column layout. On mobile viewport (<900px), layout is unchanged. Hover highlighting works. Keyboard nav works.

---

### A8 — World Map Companion Hop Arc Polish

**Why:** The hop arc animation between zones works but lacks squash-and-stretch, reducing game feel.

**Task:**
1. Find the companion pawn movement animation between tiles.
2. Add squash-and-stretch:
   - On take-off: quick vertical stretch (scaleY 1.2, scaleX 0.85), 80ms
   - At peak arc: return to normal scale, 150ms
   - On landing: horizontal squash (scaleY 0.8, scaleX 1.2), 100ms
   - Bounce recovery: return to normal, 120ms, `Curves.elasticOut`
3. Add a subtle dust puff sprite (`zone_dust_puff.png` — small, 2-frame, transparent bg) that plays on landing tile.
4. Ensure the arc still depth-sorts correctly over/under tiles during transit.

**Verification gate:** Companion hops to a new zone — visibly stretches on take-off, squashes on landing, recovers elastically. Dust puff plays on landing tile.

---

## 🧠 PART B — QUESTION BACKEND OVERHAUL

### B1 — Expand Core Question Pool to 1,000+ Total Questions

**Why:** The comprehensive audit found ~250 total generated questions. After 50 attempts, children see repeats. This is the single highest-impact educational retention fix.

**Files to read first:** `/lib/core/data/`, `/lib/features/literacy/`, `/lib/features/numeracy/`, `AustralianNAPLANQuestions.dart`, `enhanced_question_generator.dart`, `math_word_problem_bank.dart`, `literacy_word_bank.dart`

**Current state (do not modify existing IDs or structures):**

| Topic | Current Scenarios | Target |
|-------|------------------|--------|
| Addition | 5 | 30 |
| Subtraction | 5 | 30 |
| Multiplication | 5 | 30 |
| Division | ~5 | 25 |
| Fractions | ~10 | 25 |
| Place value | ~10 | 20 |
| Measurement | ~10 | 20 |
| Money | ~10 | 25 |
| Time elapsed | ~5 | 20 |
| Literacy homophones | existing | +20 |
| Literacy vocabulary | existing | +30 |
| Reading comprehension | ~5 passages | +15 passages |
| Spelling Australian English | existing | +30 |
| Grammar punctuation | ~10 | +25 |

**Rules for all new questions:**
- All contexts must use Australian English (colour, favourite, organise, etc.)
- Cultural contexts MUST draw from the existing word bank: lamingtons, pavlova, cricket, AFL, kookaburra, Great Barrier Reef, Bondi Beach, wombat, kangaroo, paddle pop, Vegemite, etc.
- Money questions must use amounts rounding to the nearest 10c (5c coins no longer in circulation in Australia)
- Each scenario must be unique — no near-duplicates with different names
- Wrong answer distractors at difficulty levels 3–5 must be **plausible error types**, not random numbers (e.g., for multiplication, common errors like confusing ×6 with ×7; for spelling, common misspellings)
- All new questions must include ACARA strand code reference in comments

**Task:**
1. Add scenarios to each topic's generator/bank file to hit the targets above.
2. Do not delete existing scenarios — append only.
3. Preserve all existing function signatures.
4. After expansion, run the generator in test mode and confirm total question output ≥ 1,000 unique questions (write a test that counts this if one doesn't exist).

**Verification gate:** `flutter test` passes. A dedicated count test confirms ≥ 1,000 unique questions generated across all topics. No duplicate question text across the same topic at the same difficulty level.

---

### B2 — Add Year 5–6 Question Sets (Currently Missing Entirely)

**Why:** The app markets to ages 4–12 but question content stops at Year 4 (age ~9). Children aged 10–12 have no appropriate challenge.

**ACARA Year 5–6 alignment required for all new content.**

**Create new files:**
```
/lib/core/data/questions/y5_6_numeracy.dart
/lib/core/data/questions/y5_6_literacy.dart
/assets/questions/science_explorers/y5_6.json
/assets/questions/creative_corner/y5_6.json
```

**Year 5–6 Numeracy topics to implement (minimum 20 questions each):**

| Topic | ACARA Code | Notes |
|-------|-----------|-------|
| Fractions, decimals, percentages | AC9M5N02, AC9M6N01 | Real-world contexts (sale prices, cooking portions) |
| Probability and chance | AC9M5P01, AC9M6P01 | Simple events using Australian sports/games |
| Area and perimeter | AC9M5M01, AC9M6M01 | Using metric units (m², cm²) |
| Algebra foundations (patterns, rules) | AC9M5A01, AC9M6A01 | Number pattern rules |
| Negative numbers | AC9M6N03 | Temperature, sea level, money debt contexts |
| Long multiplication / division | AC9M5N03 | Multi-step word problems |
| Data interpretation (graphs, averages) | AC9M5ST01, AC9M6ST01 | Australian datasets (rainfall, population) |

**Year 5–6 Literacy topics to implement (minimum 15 questions each):**

| Topic | ACARA Code | Notes |
|-------|-----------|-------|
| Complex inference | AC9E5LY01 | Longer passages (4–6 sentences minimum) |
| Author's purpose and perspective | AC9E5LY02 | Persuasive vs informative identification |
| Text structure analysis | AC9E5LY03 | Identify introduction, body, conclusion |
| Figurative language | AC9E5LA02 | Simile, metaphor, personification identification |
| Persuasive writing techniques | AC9E5LY04 | Identify rhetorical questions, emotive language |
| Advanced punctuation | AC9E6LA01 | Semicolons, colons, dashes, parentheses |
| Vocabulary in context | AC9E5LA03 | Meaning from surrounding text |

**Reading comprehension passages for Y5–6 must be:**
- Minimum 4–6 sentences (not the 1–2 sentence Y1–2 passages)
- Australian topics: Great Barrier Reef, Indigenous astronomy, Australian exploration, bushfire ecology, Olympic history, etc.
- 3–4 questions per passage (literal, inferential, vocabulary, author's purpose)

**Verification gate:** `flutter test` passes. A quiz session filtered to Y5–6 produces questions from every topic above with appropriate difficulty. No Y1–2 content appears in a Y5–6 filtered session.

---

### B3 — Migrate Questions to JSON Architecture

**Why:** The audit recommends this. Hardcoded Dart questions cannot be updated by non-developers and cannot be validated by CI.

**Schema (match existing prototype at `/lib/core/data/naplan_year3_numeracy.json`):**
```json
{
  "id": "ww_hom_001",
  "zone": "word_woods",
  "topic": "homophones",
  "year_level": "1-2",
  "acara_code": "ACELA1458",
  "difficulty": 1,
  "question": "Which word fits? 'The _____ hopped across the paddock.'",
  "options": ["hair", "hare", "here", "her"],
  "correct_index": 1,
  "hint": "Think about an animal with long ears.",
  "explanation": "'Hare' is an animal. 'Hair' grows on your head.",
  "australian_context": true
}
```

**Migration plan — do not do all at once. Follow this order:**
1. Create `/assets/questions/word_woods/y1_2.json` — migrate Word Woods Y1–2 questions from Dart to JSON (start with this zone as the pilot)
2. Create a `JsonQuestionLoader` service in `/lib/core/services/` that loads questions from JSON at runtime using `rootBundle.loadString()`
3. Ensure `QuestionFreshnessService` and `QuestionVariationEngine` work with JSON-loaded questions (they should — confirm by test)
4. Update the Word Woods quiz to use `JsonQuestionLoader` for Y1–2 content instead of hardcoded Dart
5. Confirm everything works, then migrate one additional zone's questions to JSON
6. Do not migrate all zones in one session — two zones fully migrated and tested is a complete deliverable for this task

**Validation requirements:**
- Write a JSON schema validator test that confirms every question JSON file has all required fields (id, zone, topic, year_level, acara_code, difficulty, question, options, correct_index, hint)
- Add the schema validator to CI (`/.github/workflows/`)

**Verification gate:** Word Woods Y1–2 questions load from JSON with no errors. `flutter test` passes. JSON schema validator test passes. No regression in question delivery to the quiz screen.

---

### B4 — Implement and Validate Adaptive Difficulty

**Why:** The five-level difficulty system and SM-2 spaced repetition foundations exist but are flagged as "not well-tested." A broken adaptive system undermines the educational core.

**Files to read first:** `/lib/core/services/` — find `SkillProgressionService`, spaced repetition logic, and difficulty level definitions. Read all fully before writing any tests.

**Task:**

**Step 1 — Map the current system:**
Write a comment block (do not commit it — it's for your working understanding) identifying:
- Where the 65% INTRODUCED threshold is checked
- Where the 85% MASTERED threshold is checked
- Where SM-2 interval calculation happens
- Where difficulty level (1–5) is selected for the next question
- Where session-level difficulty ramping (within a single sitting) is handled separately from long-term spaced repetition

**Step 2 — Write integration tests:**
Create `/test/core/services/skill_progression_test.dart` with the following test cases:
```
[ ] A child answering correctly 6/8 times (75%) stays at PRACTISING, not promoted to MASTERED
[ ] A child answering correctly 9/10 times (90%) without hints is promoted to MASTERED
[ ] A child answering correctly 7/10 times (70%) is promoted from LOCKED to INTRODUCED (≥65%)
[ ] A child in MASTERED who drops to 70% accuracy across next session is demoted to PRACTISING
[ ] SM-2 interval increases correctly after consecutive correct answers (day 1 → 6 → review cycle)
[ ] A hint usage during an answer does NOT count toward the 85% mastery threshold
[ ] Session-level difficulty: after 3 consecutive correct answers, next question is difficulty+1 (if not at max)
[ ] Session-level difficulty: after 2 consecutive wrong answers, next question is difficulty-1 (if not at min)
```

**Step 3 — Fix any failures:**
If any test above fails, identify and fix the bug in the service logic. Do not change the test to pass — fix the implementation.

**Step 4 — Improve distractor quality at high difficulty:**
In `enhanced_question_generator.dart` (or equivalent), ensure that at difficulty levels 4–5:
- Numeracy wrong answers are common student error types (e.g., for 7×8=56, distractors are 54, 58, 63 — not 12, 100, 3)
- Literacy wrong answers are plausible misspellings or near-synonyms, not random words
- Add a `distractor_strategy` field to the JSON schema: `"random"` (levels 1–2) or `"plausible_error"` (levels 3–5)

**Verification gate:** All 8 integration tests pass. `flutter analyze` shows zero warnings in modified files. A Y3–4 quiz session demonstrably increases question difficulty after 3 consecutive correct answers.

---

### B5 — Implement Science Explorers and Creative Corner Question Sets

**Why:** Both zones are listed in the README and world map but have zero questions. Children who unlock these zones hit a dead end.

**Science Explorers — create `/lib/core/data/questions/science_explorers.dart` or JSON equivalent:**

Minimum 15 questions per year band:

| Year Band | Topics | ACARA Codes |
|-----------|--------|-------------|
| Y1–2 (Ages 5–7) | Living things, weather, materials, senses | AC9S1U01, AC9S2U01 |
| Y3–4 (Ages 7–9) | Life cycles, states of matter, forces, Earth and space | AC9S3U01, AC9S4U01 |
| Y5–6 (Ages 9–12) | Classification, ecosystems, physical sciences, Earth systems | AC9S5U01, AC9S6U01 |

Example questions:
- Y1: "A tadpole grows into a ___." Options: [frog ✓, fish, bird, snake]
- Y3: "What do we call it when water turns to gas?" Options: [evaporation ✓, condensation, precipitation, freezing]
- Y5: "Which layer of the atmosphere contains most of Earth's weather?" Options: [troposphere ✓, stratosphere, mesosphere, thermosphere]

All contexts should use Australian examples where possible (Great Barrier Reef, Australian animals, local weather patterns, Indigenous land management).

**Creative Corner — create `/lib/core/data/questions/creative_corner.dart` or JSON equivalent:**

This zone supports storytelling, creative expression, and visual arts literacy.

| Year Band | Topics | ACARA Codes |
|-----------|--------|-------------|
| Y1–2 | Story sequencing, character feelings, colour/art vocabulary | AC9E1LY01 |
| Y3–4 | Story elements (plot, setting, character), descriptive language | AC9E3LY01 |
| Y5–6 | Narrative perspective, imagery, genre features | AC9E5LY01 |

Example questions:
- Y1: "Put these in order: [The bear woke up. / The bear ate honey. / The bear found a beehive.]" (drag-to-sequence)
- Y3: "What is the SETTING of a story?" Options: [Where and when it happens ✓, Who it is about, What happens, Why it happens]
- Y5: "A story told by a character using 'I' is written in which perspective?" Options: [First person ✓, Second person, Third person, Fourth person]

**Verification gate:** Both zones have question sets covering all three year bands. A quiz session in Science Explorers and Creative Corner produces questions. `flutter test` passes.

---

## ✅ DELIVERY CHECKLIST

Before declaring this session complete, confirm all of the following:

### Visual / Art
- [ ] Parallax layers active on world map — 3 layers, motion matches multipliers
- [ ] Zone art authored and displayed for all 8 zones (tile, landmark, path, accent)
- [ ] All zone art assets registered in `pubspec.yaml`
- [ ] Companion emotion animations wired: celebrate, encourage, level_up, mastered
- [ ] All SFX wired and playing correctly (7 effects)
- [ ] Zone ambient music playing on zone entry, stopping on exit
- [ ] Button juice scale 1.12 + elasticOut + rotation applied globally
- [ ] Lottie level-up overlay fires and auto-dismisses
- [ ] Lottie badge-unlock overlay fires and auto-dismisses
- [ ] Desktop side-by-side quiz layout active at ≥900px
- [ ] Mobile layout unchanged
- [ ] Hover effects on desktop answer options and zone cards
- [ ] Companion hop squash-and-stretch polished with dust puff

### Question Backend
- [ ] Total unique question count ≥ 1,000 (test confirms)
- [ ] Year 5–6 content implemented across all 7 numeracy and 7 literacy topics
- [ ] Reading comprehension passages for Y5–6 are 4–6 sentences minimum
- [ ] Science Explorers questions: 15+ per year band (Y1–2, Y3–4, Y5–6)
- [ ] Creative Corner questions: 15+ per year band
- [ ] Word Woods Y1–2 questions migrated to JSON and loading correctly
- [ ] `JsonQuestionLoader` service implemented and tested
- [ ] JSON schema validator test written and passing in CI
- [ ] All 8 adaptive difficulty integration tests pass
- [ ] Distractor quality improved at difficulty 4–5
- [ ] No existing question IDs modified or deleted
- [ ] All new questions use Australian English spelling
- [ ] No 5c coin amounts in money questions

### Code Quality
- [ ] `flutter analyze` — zero errors, zero warnings
- [ ] `flutter test` — all tests pass
- [ ] `flutter build web` — clean build
- [ ] No new packages added without `pubspec.yaml` update
- [ ] Reduced-motion mode respected by all new animations

---

## 🚫 DO NOT DO

- Do not introduce a runtime 3D engine (Unity, Godot, three.js, Flame-3D)
- Do not delete or reassign any existing question ID
- Do not modify any working quiz delivery flow — add to it, do not replace it
- Do not use US English spelling in any question, UI string, or comment visible to users
- Do not include 5c coin denominations in money questions
- Do not change `pubspec.lock` manually
- Do not create speculation or fabricated ACARA codes — use the real strand codes from the Australian Curriculum website (v9.0)
- Do not migrate ALL question zones to JSON in one session — pilot with two zones and verify

---

*End of agent prompt. Read every source document listed in the pre-work section before beginning.*
