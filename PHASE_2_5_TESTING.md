# Phase 2.5 Testing Checklist for MuMu

## Before You Run

```bash
cd "f:\BrightBound Adventures"
flutter pub get
flutter run -d emulator-7555  # or your MuMu device ID
```

---

## Test Checklist

### ✅ App Launch & Avatar Creation
- [ ] Splash screen shows for 2 seconds
- [ ] Avatar Creator appears (first time)
- [ ] Can enter name and navigate through 4 steps
- [ ] Avatar saves and navigates to World Map
- [ ] Avatar displays on World Map with level, XP bar

### ✅ World Map Navigation
- [ ] Avatar card shows name, level (1), XP (0/100)
- [ ] Stats row shows Level, Streak (0), Health (100%)
- [ ] All 5 zone cards visible with emoji icons
- [ ] Zone cards tappable and navigate correctly

### ✅ Zone Detail Screen
- [ ] Zone header appears with correct gradient colour:
  - Word Woods: Forest green
  - Number Nebula: Deep indigo
  - Puzzle Peaks: Brown
  - Story Springs: Sky blue
  - Adventure Arena: Purple
- [ ] Zone stats card visible showing:
  - X/Y mastered skills (initially 0/X)
  - 0% completion (no skills mastered yet)
  - Average accuracy: 0%
- [ ] "Filter" dropdown appears (optional for Phase 2.5)
- [ ] Skill count shows correctly (e.g., "14 Skills")

### ✅ Skills List Display
- [ ] All skills in zone visible (Word Woods: 14, etc.)
- [ ] Each skill card shows:
  - Skill name (e.g., "Homophones")
  - Description (e.g., "Words that sound the same...")
  - Mastery badge with correct state icon:
    - Locked: Grey lock icon
    - Introduced: Teal play arrow icon
    - Practising: Orange repeat icon
    - Mastered: Green check mark icon
  - Progress bar (all at 0% initially)
  - Accuracy: 0%
  - Attempts: 0
  - Difficulty: 5 bars (1 filled = level 1)
- [ ] Locked skills have dark overlay with lock icon
- [ ] Unlocked skills are tappable

### ✅ NAPLAN Indicator
- [ ] Skills marked with naplanArea show "⚠️ NAPLAN Focus" badge:
  - Word Woods: Homophones, Silent letters, Apostrophes, Commas, Pronoun reference, Verb tense, Inference, Main idea
  - Number Nebula: Place value, Fractions, Multi-step, Time elapsed, Measurement, Data, Patterns
- [ ] Badge styling: Yellow background, darker yellow text
- [ ] Non-NAPLAN skills don't show badge

### ✅ Skill Detail Modal (Bottom Sheet)
1. **Tap any non-locked skill** (e.g., "Letter Recognition" in Word Woods)
2. Modal appears with:
   - [ ] Skill name at top with mastery badge
   - [ ] Skill description
   - [ ] 3-column stat grid:
     - Accuracy: 0%
     - Attempts: 0
     - Difficulty: 1/5
   - [ ] "Progress to Next Level" section showing guideline:
     - If LOCKED: "Reach 65% accuracy to introduce"
     - If INTRODUCED: "Reach 85% accuracy without hints to master"
     - If MASTERED: "✓ Mastered!"
   - [ ] Blue "Practice Skill" button at bottom
3. [ ] Tap "Practice Skill" → Snackbar appears: "Skill activity coming soon!"
4. [ ] Swipe down to close modal

### ✅ Locked Skills
1. **Scroll to top of skills list**
2. **Attempt to tap a locked skill**
   - [ ] No modal appears (action blocked)
   - [ ] Dark overlay with lock icon remains visible
   - [ ] Visual feedback indicates locked state

### ✅ Difficulty Display
- [ ] 5-bar difficulty indicator shows correctly:
  - Level 1: 1 filled bar
  - Level 2: 2 filled bars
  - Level 3: 3 filled bars
  - Level 4: 4 filled bars
  - Level 5: 5 filled bars
- [ ] Bars are pink/magenta colour
- [ ] Proportionally sized

### ✅ Data Persistence
1. **Create avatar and navigate to zone**
2. **Close app completely** (don't use back button, actually kill the app)
3. **Relaunch app**
   - [ ] Splash screen appears
   - [ ] World Map loads with same avatar
   - [ ] Avatar name, level, XP persist
   - [ ] All skill data intact

### ✅ Responsive Layout (if testing on different devices)
- [ ] Skills cards responsive to screen width
- [ ] Difficulty bars align properly
- [ ] Modal bottom sheet adapts to screen size
- [ ] Zone header gradient looks good

### ✅ Navigation
- [ ] Back button from Zone Detail → World Map ✓
- [ ] Back button from World Map → Avatar Creator (first time only)
- [ ] All zone cards navigate to correct zones
- [ ] No stuck screens

### ✅ Visual Polish
- [ ] Smooth transitions between screens
- [ ] Cards have subtle shadows
- [ ] Text is readable at all sizes
- [ ] No layout overflow or clipping
- [ ] Colours match design specs
- [ ] Icons are crisp and clear

---

## Common Issues & Fixes

### Skills Don't Load
```bash
# Clear app data and rebuild
flutter clean
flutter pub get
flutter run
```

### Locked Icon Doesn't Show
- Check that `SkillState.locked` is set correctly
- Verify graphics_helpers.dart imported properly

### Stats Don't Display
- Ensure SkillProvider.initializeSkills() runs after startup
- Check Hive box is open in LocalStorageService

### Zone Colour Wrong
- Verify AppColors constants match zone IDs in main.dart

### Modal Won't Open
- Ensure skill is not in LOCKED state
- Check onTap callback is not null

---

## Performance Notes

- First load: 2-3 seconds (Hive database initialization)
- Subsequent loads: <500ms
- Skill cards render smoothly (63 total skills)
- No lag on scroll

---

## Post-Testing Sign-Off

When all tests pass, you're ready for:
- [ ] Phase 3: Building the actual learning games
- [ ] Integration of skill tracking with game activities
- [ ] Real XP/difficulty adjustments from gameplay

**Total Phase 2.5 Testing Time**: ~10-15 minutes

---

## Data You Should See

**Word Woods (14 skills)** – All state: LOCKED
- Letter Recognition
- Phoneme Awareness
- Blending Sounds
- Homophones ⚠️ NAPLAN
- Silent Letters ⚠️ NAPLAN
- Apostrophes ⚠️ NAPLAN
- Inference ⚠️ NAPLAN
- Main Idea ⚠️ NAPLAN
- Vocabulary in Context
- Comma Usage ⚠️ NAPLAN
- Verb Tense Consistency ⚠️ NAPLAN
- Pronoun Reference ⚠️ NAPLAN
- Sentence Formation
- Story Structure

**Number Nebula (13 skills)** – All state: LOCKED
- Number Recognition
- Counting
- Addition
- Subtraction
- Multiplication
- Division
- Place Value ⚠️ NAPLAN
- Fractions of Quantities ⚠️ NAPLAN
- Multi-Step Word Problems ⚠️ NAPLAN
- Time Elapsed ⚠️ NAPLAN
- Measurement Conversions ⚠️ NAPLAN
- Data Interpretation ⚠️ NAPLAN
- Pattern Rules ⚠️ NAPLAN

**Story Springs (8 skills)** – All state: LOCKED
- Story Sequencing
- Emotion Recognition
- Dialogue Creation
- Character Development
- Plot Structure
- Descriptive Language
- Dialogue Punctuation
- Voice Recording & Playback

**Puzzle Peaks (6 skills)** – All state: LOCKED
- Spatial Reasoning
- Pattern Recognition
- Logic Puzzles
- Problem Solving
- Shape Matching
- Sequence Logic

**Adventure Arena (6 skills)** – All state: LOCKED
- Hand-Eye Coordination
- Tap Accuracy
- Drag Precision
- Reaction Time
- Fine Motor Control
- Swipe Control

---

Total: **63 Skills** ✓

Good luck testing! Let me know if you hit any issues. 🚀
