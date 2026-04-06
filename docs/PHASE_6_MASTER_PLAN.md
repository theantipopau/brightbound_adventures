# Phase 6 — "Alive & Immersive"

> Theme: Make the game feel *alive*, tell a *story*, and *react* to every student.
> The previous phase fixed the bones. This phase gives it a heartbeat.

---

## Why Phase 6?

An audit against the "great educational game for ages 5–12" standard revealed:

| Gap | Impact | Status |
|-----|--------|--------|
| Questions can't be read aloud (TTS ready but unwired) | 🔴 Critical | ✅ DONE |
| Zones have zero narrative — just skill lists | 🔴 Critical | ✅ DONE |
| Daily challenge is buried in a menu | 🟠 High | ✅ DONE |
| Correct answers have modest celebration (+40 particles, 2s) | 🟠 High | ✅ DONE |
| Streak milestones not celebrated with a modal | 🟠 High | ✅ DONE |
| No +XP / +Stars float animation — rewards are invisible | 🟠 High | ✅ DONE |
| Avatar is emotionally inert (no reactions to performance) | 🟡 Medium | Not done |
| Onboarding doesn't teach interaction — just describes it | 🟡 Medium | Not done |

**The single biggest truth for ages 5–12:** children learn through *story, sound, and emotion* — not through lists of skill names.

---

## 🔴 PRIORITY 1 — Read Aloud (TTS)

> Every child should be able to hear the question. Without this, the app excludes 5–7 year olds and emergent readers entirely.

- [x] `TtsService` already exists (`lib/core/services/tts_service.dart`) — speech rate 0.4, kid-friendly pitch ✅
- [x] `TtsSpeakerButton` widget created — `lib/ui/widgets/quiz_widgets.dart` ✅
- [x] Speaker button wired into `multiple_choice_game.dart` header ✅
- [x] Speaker button wired into `numeracy_game.dart` header ✅
- [x] Speaker button wired into `science_game.dart` header ✅
- [x] Speaker button wired into `logic_game.dart` header ✅
- [x] Speaker button wired into `story_game.dart` header ✅
- [x] Auto-read toggle in settings screen ✅
- [x] "Auto-read questions aloud" setting stored in SharedPreferences ✅

---

## 🔴 PRIORITY 2 — Zone Guardians & Narrative

> Zones need a character who gives context, quest framing, and celebrates progress.
> No graphics needed — emoji character + text already makes this magical for kids.

Each zone gets a **guardian NPC** with:
- A name, emoji avatar, and one-liner quest hook
- Short encouragement messages during play
- A "zone complete" message when all skills mastered

| Zone | Guardian | Quest Hook |
|------|----------|------------|
| 🌲 Word Woods | Wise Owl 🦉 "Quill" | "The dark forest has scrambled all our letters! Help me restore them!" |
| 🌌 Number Nebula | Luna the Comet 🌟 "Luna" | "My stars have gone dark! Answer number puzzles to reignite them!" |
| 🧠 Puzzle Peaks | Rock Giant 🗿 "Grumble" | "My mountain is crumbling! Solve my riddles to hold it together!" |
| 📖 Story Springs | Ink Fairy 🧚 "Pip" | "The Story Spring has dried up! Bring back the words to make stories flow!" |
| 🏟️ Adventure Arena | Champion Dragon 🐉 "Blaze" | "Challenge yourself across all zones — only the bravest earns the Champion Crown!" |
| 🔬 Science Explorers | Robot Explorer 🤖 "Sparks" | "My sensor arrays are offline! Complete science missions to reboot them!" |
| 🎨 Creative Corner | Rainbow Sprite 🌈 "Chroma" | "All the colours have faded from the world! Create and restore them!" |

**Implementation:**
- [x] `ZoneGuardian` model + `zone_guardian_data.dart` — `lib/core/data/zone_guardian_data.dart` ✅
- [x] `ZoneGuardianBanner` widget — `lib/ui/widgets/zone_guardian_banner.dart` ✅
- [x] Guardian banner added to `ZoneDetailScreen` above skills list ✅
- [ ] Show guardian dialogue line when a skill is completed
- [ ] Show guardian "celebrate" message when zone mastered

---

## 🟠 PRIORITY 3 — Daily Challenge on World Map HUD

> The daily challenge is the best habit-formation mechanic in the app — but it's buried in a menu. It needs to be the first thing a student sees every day.

- [x] Add **Daily Quest HUD widget** to world map — shows 🎯 badge + "X/5 today" progress ✅
- [x] When complete: badge shows 🏆 with gold styling ✅
- [x] Tap to navigate directly to daily challenge screen ✅
- [ ] When incomplete: badge pulses gently to draw attention (animation enhancement)
- [ ] Show "New quests available!" animation when challenges reset at midnight

---

## 🟠 PRIORITY 4 — Streak Milestone Celebrations

> Hitting a 7-day or 30-day streak should feel like a **celebration**, not a silent stat change.

- [x] `StreakMilestoneModal` — full-screen overlay on milestone days (3, 7, 14, 30, 50, 100) ✅
- [x] Shows big emoji + streak count + confetti burst (120 particles) + bonus stars ✅
- [x] `StreakService.recordPlay()` wired into all 5 practice screens ✅
- [x] Milestone modal shows automatically when a milestone is crossed ✅
- [x] Add subtle "Streak at risk" banner: "Last day to keep your 🔥 X-day streak!" shown when student hasn't played by 5pm ✅

---

## 🟠 PRIORITY 5 — Rich Correct Answer Celebration

> Correct answers should feel *amazing*. Currently: 40 particles, 2 seconds. Children's games industry standard: 100–200 particles, XP float, 3+ seconds.

- [x] Increase confetti burst to **120 particles** with 3-second duration ✅
- [x] Add `FloatingRewardText` widget — "+10 ⭐" animates upward, fades out ✅
- [x] `showFloatingReward()` wired into all 5 game correct-answer handlers ✅
- [ ] On streak milestone answers (5× streak): play **super confetti** (200 particles, bigger burst)
- [ ] Make the "correct!" feedback text bigger and more joyful (Fredoka font, 28px+)

---

## 🟠 PRIORITY 6 — Avatar Emotional Reactions

> Kids bond with characters that *react* to them. The avatar should show happiness, encouragement, and empathy.

- [ ] Add `AvatarEmotion` enum: `happy`, `thinking`, `sad`, `proud`, `surprised`
- [ ] Update `Avatar` model with optional `emotion` field
- [ ] `AvatarProvider.setEmotion(emotion)` method
- [ ] On correct answer → `setEmotion(happy)` → avatar shows 😄
- [ ] On wrong answer → `setEmotion(sad)` → avatar shows 😟 then `thinking`
- [ ] On level up → `setEmotion(proud)` → avatar shows 🤩
- [ ] Mini-avatar in quiz header bottom-left corner (32×32 emoji-style)
- [ ] World map avatar reacts to daily streak status

---

## 🟡 PRIORITY 7 — Onboarding Interactive Tutorial

> Currently onboarding explains the game but doesn't *teach* it. After 5 slides, kids still don't know "what do I tap?"

- [ ] Add **Page 6** to onboarding: "Choose Your Hero" — shows 3 avatar emojis; tapping one selects it (routes to avatar creator)
- [ ] Add **Page 7** to onboarding: "Complete Quests Daily" — explains streak + daily challenges
- [ ] After avatar creation: **first-time world map overlay** — glowing arrow points to a zone with "Tap a zone to begin your adventure!"
- [ ] Suppress overlay after first zone entry — store in SharedPreferences

---

## 🟡 PRIORITY 8 — Question Variety & New Types

> Quiz fatigue is real. Young learners need stimulus variety every ~30 seconds.

- [ ] **Matching Pairs** widget — drag emoji/word to matching partner
- [ ] **Cloze fill-in-the-blank** widget — tap missing word from word bank
- [ ] **Sequence/Ordering** widget — drag items into correct order
- [ ] Mix 20% new question types into each skill session
- [ ] Add 20+ new questions per existing skill (bulk content pass)

---

## 🔵 PRIORITY 9 — Parent Dashboard Enhancements

> Parents need a "at a glance" summary that builds confidence in the app.

- [ ] 7-day activity chart (simple bar chart) — days played this week
- [ ] Zone accuracy breakdown (which areas need help)
- [ ] "Today's session summary" — questions answered, time spent, stars earned
- [ ] Weekly email/notification digest (future — needs backend)

---

## 🔵 PRIORITY 10 — Spaced Repetition (SM-2)

> The most powerful learning science tool. Flag skills for review at scientifically-optimal intervals.

- [ ] `SpacedRepetitionService` — SM-2 algorithm: review interval starts at 1 day
- [ ] Skills answered incorrectly reset to 1-day review
- [ ] Skills answered correctly: interval × 2.5 (SM-2 ease factor)
- [ ] `ReviewQueue` shown on world map: "3 skills ready for review today"
- [ ] Integrate with `SkillProvider.updateSkillProgress()`

---

## Implementation Order

```
Week 1: TTS + Zone Guardians (biggest impact for youngest learners)
Week 2: Daily Challenge HUD + Streak Modal (habit formation)
Week 3: Celebration upgrade + Avatar emotions (feel amazing)
Week 4: Onboarding tutorial + Matching Pairs question type
Week 5: Parent dashboard + content expansion
Week 6: Spaced Repetition + Ship
```

---

## Success Metrics

A 7-year-old should be able to:
1. ✅ Hear every question read aloud on tap
2. ✅ Understand why they're in a zone (guardian quest context)
3. ✅ Know what to do every day (daily challenge HUD visible)
4. ✅ Feel celebrated when they get answers right
5. ✅ Watch their avatar react to them

---

*Previous phase: PHASE_5_MASTER_PLAN.md*
