# BrightBound Adventures - Codebase Structure Overview

**Last Updated:** March 21, 2026  
**Project Version:** 2.0.0

---

## 1. PROJECT ORGANIZATION

### Root-Level lib/ Directory Structure
```
lib/
├── main.dart                 # App entry point with service initialization
├── core/                     # Core business logic & services
├── features/                 # Feature modules organized by skill area
└── ui/                       # Shared UI components, themes, and screens
```

---

## 2. CORE DIRECTORY (`lib/core/`)

### **Controllers** (`lib/core/controllers/`)
- `game_session_controller.dart` - Manages game session state during quiz/game play

### **Data** (`lib/core/data/`)
- **JSON question files:**
  - `acara_curriculum_mapping.json` - ACARA curriculum alignment data
  - `naplan_year3_numeracy.json` - NAPLAN-aligned numeracy questions
  - `science_explorers_questions.json` - Science content questions

### **Models** (`lib/core/models/`)
Core data structures used throughout the app:

| Model | Purpose |
|-------|---------|
| `achievement.dart` | Achievement/badge definitions |
| `avatar.dart` | Player avatar data (character, color, name) |
| `skill.dart` | Learning skill definitions with difficulty levels |
| `skill_database.dart` | Complete skill hierarchy & progression |
| `zone_data.dart` | World map zone definitions |
| `cosmetics.dart` | Avatar customization items |
| `cosmetic_item.dart` | Individual cosmetic item data |
| `daily_challenge.dart` | Daily challenge event definitions |
| `game_progress.dart` | Player progress tracking |
| `player_stats.dart` | Player statistics (XP, level, streaks) |
| `question_metadata.dart` | Enhanced question metadata (NAPLAN, Bloom's) |
| `shop_item.dart` | Shop item definitions |
| `naplan/` | NAPLAN-specific models |

### **Services** (`lib/core/services/`)
Application services managing business logic:

| Service | Responsibility |
|---------|-----------------|
| `service_registry.dart` | Service lifecycle management & dependency injection |
| `local_storage_service.dart` | Hive-based offline data persistence |
| `audio_manager.dart` | Background music & ambient audio |
| `sound_effects_service.dart` | Sound effect playback (correct/incorrect) |
| `tts_service.dart` | Text-to-speech for accessibility |
| `haptic_service.dart` | Haptic feedback (vibration) |
| `achievement_service.dart` | Achievement tracking & unlocking |
| `shop_service.dart` | Shop & cosmetic purchases |
| `streak_service.dart` | Daily streak tracking |
| `streak_enhanced_service.dart` | Enhanced streak mechanics |
| `daily_challenge_service.dart` | Daily challenge management |
| `cosmetic_unlock_service.dart` | Cosmetic item unlock logic |
| `adaptive_difficulty_service.dart` | Dynamic difficulty adjustment |
| `animation_service.dart` | Animation utilities & particle generation |
| `avatar_provider.dart` | Avatar state management (Provider pattern) |
| `skill_provider.dart` | Skill progression state management |
| `question_loader_service.dart` | Question loading from files/generators |
| `question_audit_service.dart` | Question validation & auditing |
| `learning_engine.dart` | Core learning mechanics & spaced repetition |
| `stats_service.dart` | Player statistics calculations |
| `keyboard_navigation_service.dart` | Keyboard navigation support |

### **Storage** (`lib/core/storage/`)
Hive-based local persistence layer (empty folder - implementations in service_registry)

### **Utils** (`lib/core/utils/`)
Generator & utility modules for question content:

| Util | Purpose |
|------|---------|
| `word_woods_generator.dart` | Literacy skill questions |
| `number_nebula_generator.dart` | Numeracy questions |
| `puzzle_peaks_generator.dart` | Logic puzzle questions |
| `story_springs_generator.dart` | Storytelling content |
| `adventure_arena_generator.dart` | Adventure zone content |
| `science_quest_generator.dart` | Science questions |
| `enhanced_question_generator.dart` | Meta-generator for advanced question creation |
| `literacy_skill_questions.dart` | Reusable literacy question banks |
| `literacy_word_bank.dart` | Word lists for literacy |
| `math_word_problem_bank.dart` | Word problems for numeracy |
| `question_metadata_generator.dart` | Metadata generation for questions |
| `question_variation_helper.dart` | Question variation/randomization |
| `story_springs_questions.dart` | Story-based questions |
| `australian_naplan_questions.dart` | NAPLAN-aligned questions |
| `isometric_engine.dart` | 3D isometric rendering engine |
| `world_map_isometric_helper.dart` | World map isometric positioning |
| `responsive_helper.dart` | Responsive design utilities |
| `constants.dart` | App-wide constants |

---

## 3. FEATURES DIRECTORY (`lib/features/`)

Each feature module has the same structure pattern:
```
feature/
├── models/          # Feature-specific models
├── screens/         # Feature screens
├── widgets/         # Feature widgets
└── index.dart       # Barrel exports
```

### **Avatar Feature** (`lib/features/avatar/`)
- **Status:** Empty folder (avatar creation in UI screens)
- **Purpose:** Avatar system placeholder

### **Literacy** (`lib/features/literacy/`)
**Models:**
- `question.dart` - LiteracyQuestion class with question banks:
  - `HomophoneQuestions` - their/there/they're distinctions
  - `ApostropheQuestions` - Possessive & contraction use
  - `PunctuationQuestions` - Punctuation rules

**Screens:**
- `skill_practice_screen.dart` - Skill practice interface
  - Loads skill-specific questions
  - Displays results dashboard
  - Tracks accuracy & hintsUsed

**Widgets:**
- `multiple_choice_game.dart` - Interactive multiple choice quiz
- `quiz_results_screen.dart` - Results & feedback display

### **Numeracy** (`lib/features/numeracy/`)
**Similar structure to literacy:**

**Screens:**
- `numeracy_practice_screen.dart` - Numeracy practice interface

**Widgets:**
- `numeracy_game.dart` - Interactive numeracy game
- `numeracy_results_screen.dart` - Results display

### **Logic** (`lib/features/logic/`)
**Screens:**
- `logic_practice_screen.dart` - Logic puzzle practice

**Widgets:**
- `logic_game.dart` - Logic puzzle game
- `logic_results_screen.dart` - Results display

### **Mini Games** (`lib/features/mini_games/`)
**Models:**
- `mini_game.dart` - Base mini game model

**Games Implemented:**
- `word_search_game.dart` - Find hidden words in grid
- `memory_match_game.dart` - Match pairs game
- `pattern_puzzle_game.dart` - Pattern recognition game

### **Other Features** (`lib/features/`)
- **storytelling/** - Creative story writing activities
- **motor/** - Motor skill activities
- **hand_eye/** - Hand-eye coordination games
- **science/** - Science learning content
- **student/** - Student user management (models/)
- **teacher/** - Teacher dashboard (models/, services/)
- **world_map/** - World map feature (empty - UI in screens)

---

## 4. UI DIRECTORY (`lib/ui/`)

### **Themes** (`lib/ui/themes/`)

**`app_theme.dart`** - Complete theme system:

**Color Palette:**
```dart
// Primary & Secondary
primary: #FF6B9D (Hot Pink)
secondary: #4ECDC4 (Teal)
tertiary: #FFA500 (Orange)

// Zone-Specific Colors
wordWoodsColor: #2D5016 (Forest Green) - Literacy
numberNebulaColor: #1B1F3B (Deep Indigo) - Numeracy
puzzlePeaksColor: #8B4513 (Brown) - Logic
storyspringsColor: #4A90E2 (Sky Blue) - Storytelling
adventureArenaColor: #9B59B6 (Purple) - Adventure
```

**Typography System:**
- **Fonts:**
  - `Fredoka` - Primary font (headlines, titles)
  - `Comfortaa` - Body font (readable, friendly)
  - `NotoEmoji` - Emoji font (consistent emoji rendering)

- **Text Styles:** displayLarge/Medium/Small, headlineLarge/Medium/Small, titleLarge/Medium/Small, bodyLarge/Medium/Small, labelLarge/Medium/Small

**Material 3 Components:**
- ElevatedButton, OutlinedButton, TextButton themes
- AppBar, Card, InputDecoration themes
- Custom border radius (12-16dp)

### **Screens** (`lib/ui/screens/`)

| Screen | Purpose | Key Features |
|--------|---------|--------------|
| **SplashScreen** | App launch screen | Loading animation, branding |
| **AvatarCreatorScreen** | Avatar customization | Character selection, color picker, name input, animations |
| **WorldMapScreen** | Main world navigation | 6 zones, isometric 3D terrain, avatar path movement |
| **WorldEntryScreen** | Zone selection intro | Zone details, entry animation |
| **ZoneDetailScreen** | Skill/content browsing | Skill grid, progression tracking |
| **SkillPracticeScreen** | Skill-based quizzes | Question generation, results |
| **DailyChallengeScreen** | Daily challenges | Time-limited quests, rewards |
| **MiniGamesScreen** | Mini game hub | Word search, memory match, pattern puzzle |
| **ShopScreen** | Cosmetic shop | Item browsing, purchase logic |
| **TrophyRoomScreen** | Achievement gallery | Badge display, unlock info |
| **ProfileStatsScreen** | Player statistics | XP, levels, streaks, time played |
| **ParentDashboardScreen** | Parent controls | Child progress insights, settings |
| **SettingsScreen** | App preferences | Sound, accessibility, language |
| **OnboardingScreen** | First-time setup | Tutorial flow |
| **PlaceholderZoneScreen** | Coming soon areas | Teaser content |

### **Widgets** (`lib/ui/widgets/`)

#### **Core Responsive Components:**
- `responsive_wrapper.dart` - Responsive layout wrapper (1280x800 baseline)
- `responsive_quiz_layout.dart` - Question/answer responsive layout

#### **Animation Widgets:**
- `animated_character.dart` - RPG-style character animations (idle, walking, jumping, celebrating, thinking)
- `transitions.dart` - FadeSlidePageRoute for screen transitions, BrightBoundLoading spinner
- `reward_animations.dart` - StarBurstAnimation for correct answers
- `confetti_burst.dart` - ConfettiBurst particles (celebration effect)
- `level_up_dialog.dart` - Level up notification animation
- `achievement_notification.dart` - Achievement unlock popup

#### **Game Widgets:**
- `achievement_card.dart` - Badge/achievement display
- `daily_challenge_card.dart` - Daily challenge card
- `modern_shop_item_card.dart` - Shop item display
- `skill_widgets.dart` - Skill cards & progress indicators
- `streak_widget.dart` - Streak display with animation
- `tracing_widget.dart` - Line tracing/drawing widget
- `xp_widgets.dart` - XP bar & level display
- `mastery_certificate.dart` - Skill mastery certificate

#### **Character & Avatar:**
- `avatar_widgets.dart` - Avatar display components
- `rpg_character.dart` - RPG character rendering
- `animated_character.dart` - Character animation controller (idle, walking, jumping, celebrating)

#### **UI Effects:**
- `fantasy_map.dart` - Decorative map visualization
- `quiz_results_celebration.dart` - Results celebration animation
- `graphics_helpers.dart` - Drawing utilities
- `loading_screen.dart` - Loading state UI
- `enhanced_zone_header.dart` - Zone header component
- `visual_effects/` folder:
  - `animated_cloud_background.dart` - Parallax cloud animation
  - `particle_background.dart` - Particle effect backgrounds
  - `adventure_pattern_overlay.dart` - Pattern overlay effects
  - `screen_shaker.dart` - Screen shake animation

#### **Index:**
- `index.dart` - Barrel exports for all widgets

### **Painters** (`lib/ui/painters/`)
Custom Canvas painters for complex graphics:
- `shadow_painter.dart` - Shadow rendering
- `terrain_painter.dart` - Terrain visualization
- `path_painter.dart` - Path drawing

---

## 5. ANIMATION FRAMEWORK

### **Built-In Animation Types**

#### **1. Transition Animations**
```dart
FadeSlidePageRoute  // Fade + slide combo for screen navigation
- Fade: Curves.easeInOut
- Slide: Curves.easeOutCubic (from offset)
- Duration: 300ms
```

#### **2. Loading Animation**
```dart
BrightBoundLoading  // Star rotation + scale + glow pulsing
- Rotation: Continuous (2000ms cycle)
- Scale: Pulse (easeInOut)
- Glow: Pulsing effect
- Duration: 2000ms
```

#### **3. Character Animations**
```dart
AnimatedCharacter  // State-based character with multiple animation modes
- idle: Bounce animation (1200ms cycle)
- walking: Sway & leg animation (400ms cycle)
- jumping: Scale animation
- celebrating: Rotation + scale
- thinking: Head rotation
- sleeping: Fade animation
- Particle effects: Configurable
```

#### **4. Reward Animations**
```dart
StarBurstAnimation  // Explosion of particles radiating outward
- Burst: Scale elasticOut (1500ms)
- Particles: 12 per star, random angles
- Opacity: Fade out (easeOut)
- Rotation: Per-particle spin
```

#### **5. Confetti Animation**
```dart
ConfettiBurst  // Falling confetti particles
- Count: Configurable (default 40)
- Duration: 2000ms
- Physics: Gravity simulation
- CustomPainter: ConfettiPainter
```

#### **6. Level Up Animation**
```dart
LevelUpDialog  // Celebration dialog with animation
- Entry: Scale + fade-in
- Content: Bounce effects
- Exit: Scale + fade-out
```

#### **7. Achievement Animation**
```dart
AchievementNotification  // Pop-in notification
- Entry: Slide + fade
- Display: Timed
- Exit: Slide out
```

### **Animation Service**
```dart
AnimationService
- generateConfetti()  // Creates ConfettiParticle list
- Particle generation with physics
```

### **Visual Effects**
```dart
visual_effects/
├── AnimatedCloudBackground     // Parallax scrolling clouds
├── ParticleBackground          // Generalized particle system
├── AdventurePatternOverlay     // Pattern overlays
└── ScreenShaker                // Screen shake effect
```

### **Animation Controller Patterns**
All animations use standard Flutter patterns:
- `TickerProvider` mixins for multiple controllers
- `AnimatedBuilder` or `AnimationBuilder` for UI updates
- `CurvedAnimation` for easing
- `TweenSequence` for complex sequences
- Controllers disposed in `dispose()` method

---

## 6. WIDGET HIERARCHY FOR MAJOR SCREENS

### **Splash Screen**
```
SplashScreen
├── Loading animation
├── Branding/Logo
└── Transition to AvatarCreator or WorldMap
```

### **Avatar Creator Screen**
```
AvatarCreatorScreen (with TickerProvider)
├── PageView (multi-step wizard)
│   ├── Step 1: Character Selection
│   │   └── Grid of AnimatedCharacter widgets
│   ├── Step 2: Color Customization
│   │   └── Color picker
│   └── Step 3: Name Entry
│       └── TextField + confirmation
├── AnimationControllers
│   ├── _backgroundController
│   ├── _sparkleController
│   └── _characterShowcaseController
└── CharacterAnimation preview
```

### **World Map Screen**
```
WorldMapScreen (with TickerProvider)
├── Background
│   ├── AnimatedCloudBackground
│   ├── ParticleBackground
│   └── AdventurePatternOverlay
├── Painters
│   ├── ShadowPainter
│   ├── TerrainPainter
│   └── PathPainter
├── Zone Cards (6 total)
│   ├── Color by zone (wordWoods, numberNebula, etc.)
│   ├── Isometric positioning (IsometricEngine)
│   └── Tap to enter
├── Avatar Widget (animated path movement)
├── AnimationControllers
│   ├── _entranceController
│   ├── _floatController
│   ├── _pathController
│   └── _avatarMoveController
└── Bottom Navigation
    ├── Trophy Room
    ├── Daily Challenges
    ├── Mini Games
    ├── Shop
    └── Settings
```

### **Zone Detail / Skill Practice Screen**
```
ZoneDetailScreen / SkillPracticeScreen
├── Header (zone color, zone name)
│   └── EnhancedZoneHeader
├── Skill Grid
│   └── SkillCards (with progress indicators)
├── When skill selected → SkillPracticeScreen
│   ├── Question/Game Widget
│   │   ├── MultipleChoice game (literacy)
│   │   ├── Numeracy game
│   │   └── Logic game
│   ├── Results Display
│   │   ├── QuizResultsCelebration
│   │   ├── Score, Accuracy, Hints Used
│   │   └── RewardAnimations (stars, confetti)
│   └── AnimationControllers
│       └── Result celebration effects
```

### **Mini Games Screen**
```
MiniGamesScreen
├── Game Selection Grid
│   ├── WordSearchGame
│   │   └── 8x8 to 12x12 letter grid
│   ├── MemoryMatchGame
│   │   └── Card flip grid
│   └── PatternPuzzleGame
│       └── Pattern recognition grid
└── Game instance with scoring
```

### **Shop/Cosmetics Screen**
```
ShopScreen
├── Tab navigation (characters, accessories, etc.)
├── Grid of ModernShopItemCard
│   ├── Item preview
│   ├── Price (coins/gems)
│   ├── Purchase button
│   └── Ownership indicator
└── Currency display
```

### **Trophy Room**
```
TrophyRoomScreen
├── Achievement grid
├── AchievementCards
│   ├── Badge icon
│   ├── Name & description
│   ├── Unlock criteria
│   └── Locked/unlocked state
└── Filter/tabs by category
```

---

## 7. STATE MANAGEMENT

### **Provider Pattern**
```dart
BrightBoundApp setup:
├── LocalStorageService (Provider) - data persistence
├── SoundEffectsService (Provider) - audio
├── AchievementService (ChangeNotifier) - tracking
├── ShopService (ChangeNotifier) - purchases
├── AdaptiveDifficultyService (ChangeNotifier) - difficulty
├── AudioManager (ChangeNotifier) - music/sfx
├── CosmeticUnlockService (ChangeNotifier) - cosmetics
├── StreakService (ChangeNotifier) - streaks
├── AvatarProvider (ChangeNotifier) - player avatar
├── SkillProvider (ChangeNotifier) - skill progression
├── DailyChallengeService (ChangeNotifier) - daily quests
└── HapticService (Provider) - vibration
```

**State Flow:**
1. ServiceRegistry initializes all services
2. MultiProvider wraps in BrightBoundApp
3. Screens access via `Provider.of()` or `context.read/watch()`
4. Services notify listeners on state changes

---

## 8. STYLING APPROACH

### **Design System**
1. **Centralized Theme** - `AppTheme.lightTheme()` in main.dart
2. **Color Constants** - AppColors enum with named colors
3. **Typography** - AppTypography with 12 styles
4. **Responsive Design** - ResponsiveWrapper with 1280x800 baseline
5. **Component Theming** - Material 3 button/card/input themes

### **Animation Style**
- **Curves:** easeInOut, easeOutCubic, elasticOut, linear
- **Durations:** 300ms (transitions), 400-1200ms (character), 1500-2000ms (effects)
- **Colors:** Primary (#FF6B9D), Zone-specific colors
- **Particles:** 12-40 per effect, random physics

### **Responsive Breakpoints**
- **Baseline:** 1280x800 (landscape tablet/desktop)
- **Adaptation:** Phone vs tablet detection
- **UI Scale:** Adjusts based on device

---

## 9. KEY FILE DEPENDENCIES

### **Import Order Pattern**
```dart
1. dart imports (math, convert, etc.)
2. flutter imports (material, services, etc.)
3. package imports (provider, hive, etc.)
4. local model imports (core/models)
5. local service imports (core/services)
6. local UI imports (ui/themes, ui/widgets)
7. local feature imports (features/...)
```

### **Barrel Exports**
Major feature modules use `index.dart` for clean imports:
- `features/literacy/index.dart`
- `features/numeracy/index.dart`
- `ui/themes/index.dart`
- `ui/widgets/index.dart`
- `core/services/index.dart`

---

## 10. KEY OBSERVATIONS FOR ENHANCEMENT

### **Strengths**
✅ Clean feature-based architecture  
✅ Comprehensive animation framework (transitions, particles, effects)  
✅ Well-organized theme system with zone-specific colors  
✅ Service registry pattern for DI  
✅ Responsive design wrapper  
✅ Extensive question generators for all skill areas  
✅ NAPLAN & curriculum alignment infrastructure  

### **Enhancement Opportunities**
📌 Animation framework can be unified in `AnimationService` more  
📌 More visual polish on transitions between screens  
📌 Additional micro-interactions on quiz elements  
📌 Enhanced particle effects for larger celebrations  
📌 More elaborate zone introduction animations  
📌 Character animation states could expand  
📌 Visual feedback for all interactive elements  

---

## 11. ASSET STRUCTURE

### **Images** (`assets/images/`)
- Zone backgrounds
- Character sprites/emojis
- UI icons
- Decorative graphics

### **Sounds** (`assets/sounds/`)
- Background music
- SFX (correct/incorrect)
- Ambient sounds
- UI sounds

### **Fonts** (`assets/fonts/`)
- Fredoka (primary)
- Comfortaa (body)
- NotoEmoji (emoji rendering)

---

## Summary

**BrightBound Adventures** uses a **feature-based architecture** with:
- **6 main learning zones** (literacy, numeracy, logic, storytelling, motor skills, science)
- **Rich animation framework** with transitions, particles, and character states
- **Comprehensive theming** with zone-specific colors
- **Offline-first** storage via Hive
- **Adaptive difficulty** and spaced repetition learning
- **Rich visual effects** using CustomPaint and particle systems
- **Responsive design** supporting phone to tablet
- **Service-based state management** with Provider pattern

All screens follow consistent widget hierarchies with clear separation between business logic (services), data (models), and presentation (UI layers).
