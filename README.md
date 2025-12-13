# BrightBound Adventures

A fully offline, child-safe, avatar-driven educational adventure app for children aged 4–12, designed to strengthen skills aligned with ACARA v9.0 and NAPLAN.

## 🚀 Project Status - Phase 1 Complete

### Phase 1: Project Scaffolding & Setup ✅

**Completed:**
- Flutter project structure with proper folder hierarchy
- `pubspec.yaml` with core dependencies (provider, hive, uuid, equatable, intl)
- Material 3 theme with vibrant, child-friendly colour palette
- Core models: `Skill`, `Avatar`, `GameProgress`
- Learning engine with difficulty scaling and progression logic
- Local storage service with Hive for offline persistence
- Constants, utilities, and string formatting helpers
- Basic routing structure with splash screen
- Avatar creator screen (stub)
- World map hub with zone cards
- Placeholder zone screens (Word Woods, Number Nebula, Puzzle Peaks, Story Springs, Adventure Arena)
- Web PWA setup: `manifest.json`, `index.html`
- Analysis options and `.gitignore`

**Stubbed (extensible):**
- Avatar customisation (character selection, cosmetics)
- Zone-specific learning modules
- Individual games and activities
- Learning progression tracking (database initialized, ready for data)

---

## 📁 Project Structure

```
/lib
  /core
    /models          # Data models (Skill, Avatar, GameProgress)
    /services        # Learning engine, storage service
    /storage         # Local database setup
    /pwa             # PWA utilities (ready for service worker)
    /utils           # Constants, helpers, validators
  /ui
    /themes          # Material 3 theme, colours, typography
    /widgets         # Reusable widgets (to be built)
    /screens         # Main screens (splash, avatar creator, world map, zones)
  /features
    /avatar          # Avatar customisation (stub)
    /world_map       # Map interaction logic (stub)
    /storytelling    # Story sequencing games (stub)
    /literacy        # Word Woods activities (stub)
    /numeracy        # Number Nebula activities (stub)
    /hand_eye        # Adventure Arena games (stub)

/assets
  /images           # Ready for zone art, avatar sprites
  /sounds           # Ready for audio effects, voice recordings
  /fonts            # Comfortaa, Fredoka (ready for TTF files)

/web
  /icons            # PWA icons (192x192, 512x512, maskable variants)
  manifest.json     # PWA configuration
  index.html        # Web entry point with service worker setup
```

---

## 🎯 Core Systems

### 1. Skill State Model
```
LOCKED → INTRODUCED (at ~65% accuracy) → PRACTISING → MASTERED (at ~85% without hints)
```

Each skill tracks:
- Accuracy (0.0–1.0)
- Attempt count
- Hint usage
- Last practice date
- Current difficulty (1–5)
- ACARA strand & NAPLAN area (if applicable)

### 2. Adaptive Difficulty Scaling
Difficulty adjusts across:
- Cognitive load (single → multi-step)
- Language complexity
- Number of distractors
- Time pressure
- Response types

### 3. Avatar System
- Base character selection (bear, fox, rabbit, deer — expandable)
- Skin colour customisation
- Unlockable outfits & accessories
- Experience points & levelling
- Cosmetics unlock on skill mastery

### 4. Local Storage
- **Hive database** for offline persistence
- No network calls
- PIN-protected parent dashboard (ready)
- Settings and preferences

---

## 🧪 Running the App

### Prerequisites
- Flutter SDK (stable channel)
- Dart 3.0+

### Setup
```bash
cd "f:\BrightBound Adventures"
flutter pub get
```

### Android
```bash
flutter run -d emulator-5554
```

### Web (PWA)
```bash
flutter config --enable-web
flutter run -d chrome
```

### Test Offline PWA
1. Run the app in Chrome
2. Open DevTools > Application > Service Workers
3. Check "Offline" and refresh
4. App should work fully offline

---

## 🎨 Design Tokens

### Colours
- **Primary**: #FF6B9D (Hot pink)
- **Secondary**: #4ECDC4 (Teal)
- **Tertiary**: #FFA500 (Orange)
- **Success**: #06A77D
- **Error**: #E63946

### Fonts
- **Fredoka**: Headlines, UI labels (modern, friendly)
- **Comfortaa**: Body text (rounded, soft)

### Zone Colours
- Word Woods: #2D5016 (Forest green)
- Number Nebula: #1B1F3B (Deep indigo)
- Puzzle Peaks: #8B4513 (Brown)
- Story Springs: #4A90E2 (Sky blue)
- Adventure Arena: #9B59B6 (Purple)

---

## 📚 Next Phases

### Phase 2: Core Navigation & Avatar System
- Functional avatar creator with cosmetics
- Avatar display on world map
- XP & levelling display
- Cosmetics unlock logic

### Phase 2.5: Learning Engine & Difficulty Scaling
- Skill database seeding (ACARA/NAPLAN-aligned)
- Progression tracking persistence
- Performance dashboard for parent PIN access

### Phase 3: Educational Modules
- **Word Woods**: Literacy games (homophones, apostrophes, comprehension, etc.)
- **Number Nebula**: Numeracy games (fractions, word problems, place value, etc.)
- **Story Springs**: Storytelling (drag-and-drop sequencing, dialogue, recording)
- Multi-step scaffolding with hint system

### Phase 4: Mini-Games & Coordination
- **Puzzle Peaks**: Logic games (pattern recognition, spatial reasoning)
- **Adventure Arena**: Coordination games (tap-the-colour, shape matching, tracing, swipe challenges)

### Phase 5: PWA Polish & Offline Validation
- Service worker caching
- Responsive layouts (phone → tablet → desktop)
- Offline fallback screens
- Cloudflare Pages deployment

---

## 🔒 Safety & Privacy

✅ **Offline-First**: No network access required  
✅ **No Analytics**: Zero tracking  
✅ **No Ads**: Ad-free experience  
✅ **No Accounts**: No sign-up, no email  
✅ **Local-Only Storage**: All data saved locally  
✅ **Parent Control**: PIN-protected parent dashboard  

---

## 📖 ACARA & NAPLAN Alignment

### Literacy (High-Risk Areas)
- Homophones
- Silent letters
- Apostrophes & punctuation
- Pronoun reference & verb tense
- Inference & main idea
- Comprehension & author intent

### Numeracy (High-Risk Areas)
- Multi-step word problems
- Fractions & quantities
- Place value reasoning
- Time elapsed & measurement
- Data interpretation
- Pattern rules

---

## 🛠️ Code Quality

- Modular, composition-based architecture
- Clear separation of concerns
- Equatable models for state comparison
- Type-safe error handling
- Extensible design patterns
- No god files or tight coupling

---

## 📝 License

© 2025 BrightBound Adventures. All rights reserved.

---

**Status**: Phase 1 scaffolding complete. Ready for Phase 2 development.  
**Last Updated**: 13 December 2025
