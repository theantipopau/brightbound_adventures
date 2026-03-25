# Phase 5 — Master Plan: From MVP to World-Class

> Tracks every remaining task. Mark ✅ when done.

---

## 🔴 CRITICAL BUGS (ship-blockers)

- [x] ~~Duplicate `puzzle_peaks` key in `player_stats.dart`~~ ✅
- [x] ~~`/math-facts` route missing from `main.dart` — crashes when Math Facts zone is reached~~ ✅
- [x] ~~`settings_screen.dart` completely unreachable (not exported, no route, no import)~~ ✅
- [x] ~~`onboarding_screen.dart` orphaned — not accessible from anywhere~~ ✅ (exported, routable)
- [x] ~~`profile_stats_screen.dart` orphaned — not accessible from anywhere~~ ✅ (exported, routable)

---

## 🟠 HIGH PRIORITY — UX & Navigation

- [x] ~~Wire FadeSlidePageRoute to ALL named route transitions (currently only 3 screens use it)~~ ✅
- [x] ~~Add Settings button to world map HUD (route to SettingsScreen)~~ ✅
- [x] ~~Add Profile/Stats button to world map HUD (route to ProfileStatsScreen)~~ ✅
- [ ] Add Onboarding re-play option in Settings
- [x] ~~Parent dashboard: allow PIN change (not hardcoded 1234)~~ ✅ (SharedPreferences + change dialog)
- [ ] Parent dashboard: Full stats (zone accuracy graphs, 7-day activity feed, goal setting)
- [ ] Fix `ShopScreen` and `TrophyRoomScreen` — confirm they are routed from world map

---

## 🟡 SOUND & HAPTICS

- [ ] Wire `AudioManager` SFX calls on correct/incorrect answers (currently using placeholder `SoundEffectsService`)
- [ ] Play zone-specific ambient music when entering a zone
- [ ] Play menu music on world map
- [ ] Add sound effect asset files to `assets/sounds/` (correct.mp3, incorrect.mp3, levelup.mp3, tap.mp3)
- [x] ~~Ensure settings Sound Effects toggle actually mutes `AudioManager`~~ ✅
- [x] ~~Ensure settings Music toggle actually mutes `AudioManager`~~ ✅
- [ ] Wire `HapticService` on correct/incorrect answers in all 6 game widgets

---

## 🟡 VISUAL POLISH

- [x] ~~Apply `FadeSlidePageRoute` to ALL route pushes app-wide~~ ✅
- [ ] Zone-themed loading state (replace white screens with animated loaders)
- [ ] Page transition polish — consistent fade+slide everywhere
- [ ] Desktop side-by-side quiz layout (question left, answers right on >900px width)
- [ ] `responsive_quiz_layout.dart` — confirm it's used in all quiz widgets; apply where missing
- [ ] World map keyboard navigation — already partially implemented; audit completeness
- [ ] Consistent empty-state illustrations (no plain Icons.school grey fallbacks)

---

## 🟠 GAMEPLAY FEATURES

- [x] ~~Hint system — confirmed already implemented in all 6 game widgets~~ ✅
- [ ] 50/50 power-up — eliminates 2 wrong options in multiple-choice
- [x] ~~Boss Battle — Adventure Arena zone: mixed-skill 10-question gauntlet~~ ✅
- [ ] Practice Mode vs Challenge Mode split on skill selection
- [ ] Timed challenge option for ages 8-12 (optional countdown per question)

---

## 🟡 CONTENT EXPANSION

- [ ] 20+ additional questions per skill (all zones, bulk pass)
- [ ] New question type: Matching Pairs widget
- [ ] New question type: Cloze fill-in-the-blank widget
- [ ] New question type: Sequence/Ordering widget
- [ ] ACARA standard tag applied to all 418 existing questions
- [ ] Higher-order (Evaluate+Create) questions: increase from ~5% to 10%+ of pool

---

## 🔵 PROGRESSION & REWARDS

- [ ] Avatar emotional expressions (happy, proud, thinking, sad) reacting to performance
- [ ] Level-up full-screen animation with reward reveal
- [ ] Seasonal question sets placeholder (structure only)
- [ ] Spaced repetition: SM-2 scheduling service — flag skills for review at 2/5/14/30 days
- [ ] Visual skill tree on zone detail screen

---

## 🔵 ACCESSIBILITY

- [x] ~~Semantics labels on world map HUD buttons~~ ✅
- [ ] High contrast mode toggle in settings
- [ ] Reduce motion toggle in settings (disables particle effects, parallax)
- [ ] Dyslexia-friendly font toggle (OpenDyslexic)
- [ ] WCAG 2.1 Level AA — colour contrast audit on all text

---

## 🔵 TECHNICAL HYGIENE

- [x] ~~`dart fix --apply` to clear lint warnings~~ ✅ (12 auto-fixes applied)
- [ ] Fix remaining lint issues that `dart fix` can't auto-resolve
- [x] ~~Add missing `math-facts` feature (or map zone to existing numeracy content)~~ ✅
- [ ] Unit tests: `SkillProvider`, `AdaptiveDifficultyService`, `PlayerStats` serialisation
- [ ] PWA install prompt surfaced to users ("Add to Home Screen")
- [ ] Bundle size audit — lazy-load heavy zone assets

---

## 🟢 PLATFORM

- [ ] Mobile build config (Android/iOS) — `flutter build apk` / `flutter build ipa`
- [ ] Tablet layout (distinct from phone + desktop)
- [ ] Touch gesture: swipe left/right between questions

---

*Legend: 🔴 Critical | 🟠 High | 🟡 Medium | 🔵 Low/Nice-to-have | 🟢 Platform expansion*
