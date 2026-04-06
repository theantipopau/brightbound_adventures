# BrightBound Adventures - Architecture Guide

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                   Flutter App (UI Layer)                 │
│  ├─ Screens (World Map, Zone Detail, Games)            │
│  ├─ Widgets (Reusable UI Components)                    │
│  └─ Dialogs (Settings, Achievements, Shop)              │
├─────────────────────────────────────────────────────────┤
│              Provider (State Management)                 │
│  ├─ AvatarProvider (Character customization)            │
│  ├─ SkillProvider (Progress tracking)                   │
│  ├─ AchievementService (Badges/trophies)               │
│  └─ ShopService (Cosmetic purchases)                    │
├─────────────────────────────────────────────────────────┤
│              Services Layer (Business Logic)             │
│  ├─ AudioManager (Music + SFX)                          │
│  ├─ LocalStorageService (Data persistence)              │
│  ├─ StreakService (Daily tracking)                      │
│  └─ ServiceRegistry (Dependency injection)              │
├─────────────────────────────────────────────────────────┤
│                 Data Layer (Models)                      │
│  ├─ Avatar (Character data)                             │
│  ├─ Skill (Learning progress)                           │
│  ├─ Achievement (Unlocked rewards)                      │
│  └─ ShopItem (Cosmetics)                                │
├─────────────────────────────────────────────────────────┤
│              Persistence Layer (Storage)                 │
│  ├─ Hive (Fast local database)                          │
│  ├─ Shared Preferences (Simple key-value)               │
│  └─ File system (Assets + cache)                        │
└─────────────────────────────────────────────────────────┘
```

## Folder Structure

### Core (`lib/core/`)

Contains business logic, models, and utilities.

```
core/
├── models/
│   ├── avatar.dart              # Character definition
│   ├── skill.dart               # Learning skill + progress
│   ├── achievement.dart         # Badge/trophy
│   ├── shop_item.dart           # Cosmetic item
│   └── game_result.dart         # Quiz/game outcome
├── services/
│   ├── index.dart               # Service exports
│   ├── audio_manager.dart       # 🔊 Music + SFX control
│   ├── local_storage_service.dart  # 💾 Persistence
│   ├── achievement_service.dart # 🏆 Badge system
│   ├── shop_service.dart        # 🛍️  Cosmetics
│   ├── streak_service.dart      # 🔥 Daily streaks
│   ├── adaptive_difficulty.dart # 📊 Dynamic difficulty
│   └── service_registry.dart    # Dependency injection
└── utils/
    ├── australian_naplan_questions.dart  # 📝 Curriculum
    ├── literacy_word_bank.dart           # 📚 Words
    ├── math_word_problem_bank.dart       # 🔢 Math
    └── constants.dart                    # ⚙️  Config
```

### Features (`lib/features/`)

Feature modules organized by zone/function.

```
features/
├── auth/
│   ├── screens/
│   │   └── avatar_creator.dart  # Character creation
│   └── widgets/
│       └── avatar_customizer.dart
├── literacy/
│   ├── screens/
│   │   └── literacy_zone.dart
│   ├── widgets/
│   │   ├── multiple_choice_game.dart
│   │   ├── word_matching_game.dart
│   │   └── spelling_challenge.dart
│   └── games/
│       └── literacy_games.dart
├── numeracy/
│   ├── screens/
│   │   └── numeracy_zone.dart
│   ├── widgets/
│   │   └── math_games.dart
│   └── games/
│       ├── addition_subtraction.dart
│       ├── multiplication_division.dart
│       └── fractions_decimals.dart
├── mini_games/
│   ├── memory_match_game.dart    # Card matching
│   ├── pattern_puzzle_game.dart  # Logic puzzles
│   ├── word_search_game.dart     # Word finding
│   └── mini_game_launcher.dart
├── world_map/
│   ├── screens/
│   │   ├── world_map_screen.dart
│   │   ├── zone_detail_screen.dart
│   │   └── world_entry_screen.dart
│   └── widgets/
│       └── zone_card.dart
└── settings/
    ├── screens/
    │   └── settings_screen.dart
    └── widgets/
        └── audio_settings.dart
```

### UI (`lib/ui/`)

User interface components and theming.

```
ui/
├── screens/
│   ├── splash_screen.dart       # Launch animation
│   ├── world_map_screen.dart    # Hub/navigation
│   ├── zone_detail_screen.dart  # Zone entry
│   ├── parent_dashboard_screen.dart  # Parent analytics
│   └── settings_screen.dart     # User preferences
├── widgets/
│   ├── index.dart               # Exports
│   ├── enhanced_zone_header.dart      # Zone intro
│   ├── modern_shop_item_card.dart     # Cosmetic card
│   ├── mastery_certificate.dart       # Achievement cert
│   ├── quiz_results_celebration.dart  # Victory screen
│   ├── reward_animations.dart         # Star burst, XP
│   ├── streak_widget.dart             # Streak display
│   ├── skill_widgets.dart             # Skill cards
│   └── transitions.dart               # Page routes
├── themes/
│   ├── index.dart               # Theme exports
│   ├── app_theme.dart           # Material theme
│   ├── app_colors.dart          # Color palette
│   └── typography.dart          # Text styles
└── dialogs/
    ├── settings_dialog.dart
    ├── achievement_dialog.dart
    └── shop_dialog.dart
```

## Data Flow

### User Interaction → Screen Update

```
User Interaction (Tap/Swipe)
    ↓
Widget Event Handler
    ↓
Call Service/Provider Method
    ↓
Update ChangeNotifier State
    ↓
Listeners Notified (via Provider)
    ↓
Widgets Rebuild
    ↓
Updated UI Displayed
```

### Example: Answering a Question

```dart
// 1. User taps answer button
onAnswerTap(answer) {
  // 2. Calculate result
  bool isCorrect = answer == question.correctAnswer;
  
  // 3. Update skill progress
  skillProvider.updateSkillProgress(skillId, isCorrect);
  
  // 4. Award stars if correct
  if (isCorrect) {
    achievementService.awardStars(starCount);
  }
  
  // 5. Update streak
  streakService.updateStreak();
  
  // 6. Show feedback animation
  showRewardAnimation();
  
  // 7. Provider notifies listeners → UI updates
}
```

## State Management (Provider Pattern)

### Service Registry (Dependency Injection)

```dart
// Initialization in main.dart
final registry = ServiceRegistry();
await registry.initializeAll();

MultiProvider(
  providers: [
    Provider<AudioManager>.value(value: registry.audioManager),
    ChangeNotifierProvider<AchievementService>.value(
      value: registry.achievements
    ),
    // ... more services
  ],
  child: MyApp(),
)
```

### Using Services in Widgets

```dart
// Read-only access
final audioManager = context.read<AudioManager>();
audioManager.playMenuMusic();

// Listen for changes
Consumer<StreakService>(
  builder: (context, streakService, _) {
    return Text('Streak: ${streakService.currentStreak}');
  },
)

// Watch with selector (optimization)
Selector<SkillProvider, int>(
  selector: (context, provider) => provider.masteredSkills,
  builder: (context, masteredCount, _) {
    return Text('Mastered: $masteredCount');
  },
)
```

## Game Architecture

### Quiz Game Flow

```
┌─ Initialize Quiz ─┐
│  - Load questions │
│  - Set timer      │
│  - Track progress │
└─────────┬─────────┘
          ↓
┌─ Display Question ─┐
│  - Show content     │
│  - Render options   │
│  - Start animations │
└─────────┬─────────┘
          ↓
┌─ Handle Answer ─────────┐
│  - Validate input       │
│  - Play feedback sound  │
│  - Show celebration     │
│  - Update statistics    │
└─────────┬───────────────┘
          ↓
┌─ Progress Quiz ─────────┐
│  - Move to next question│
│  - Update score         │
│  - Check completion     │
└─────────┬───────────────┘
          ↓
    More Questions?
          ├─ YES → Display Question
          └─ NO → Show Results
```

### Mini-Game: Memory Match

```
Setup:
  - Create card pairs: [A, B, C, A, B, C] → Shuffle
  - Initialize state: flipped=[], matched=[]

Player Turn:
  - Flip card 1 → Update UI
  - Flip card 2 → Update UI
  
Check Match:
  - If cards match → Mark as matched
  - If not → Flip back after delay

Win Condition:
  - All pairs matched → Show celebration → Exit

Score:
  - Award stars based on move count
  - Faster = more stars
```

## Audio System

### AudioManager Singleton

```dart
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  
  // Music control
  Future<void> playSplashMusic()   // App startup
  Future<void> playMenuMusic()     // Main navigation
  Future<void> stopMusic()
  
  // SFX control
  Future<void> playCorrectSound()  // Right answer
  Future<void> playIncorrectSound() // Wrong answer
  Future<void> playLevelUpSound()   // Achievement
  
  // Settings
  void setMusicVolume(double volume)
  void setSFXVolume(double volume)
  void toggleMusic(bool enabled)
  void toggleSFX(bool enabled)
}
```

### Integration Points

```
main.dart
  ↓ [Initialize in main()]
AudioManager (Singleton)
  ↓
Services registered in MultiProvider
  ↓
Widgets access via context.read<AudioManager>()
  ├─ SplashScreen → playSplashMusic()
  ├─ WorldMapScreen → playMenuMusic()
  ├─ QuizGame → playCorrectSound() / playIncorrectSound()
  └─ Achievement → playLevelUpSound()
```

## Responsive Design

### Breakpoints

```dart
// mobile.dart
if (MediaQuery.of(context).size.width < 768) {
  return MobileLayout();
}

// tablet.dart
if (width >= 768 && width < 1200) {
  return TabletLayout();
}

// desktop.dart
if (width >= 1200) {
  return DesktopLayout();
}
```

### Layout Adaptation

| Breakpoint | Layout | Columns |
|-----------|--------|---------|
| < 768dp   | Single | 1       |
| 768–1200  | Split  | 2       |
| ≥ 1200    | Multi  | 3+      |

**Example**: Quiz game

- **Mobile**: Full-width question + options stacked vertically
- **Tablet**: Question left (60%), hint panel right (40%)
- **Desktop**: Question center (50%), hint + stats panels on sides

## Persistence Layer

### Hive Database

```dart
// Models are stored as Hive boxes
final avatarBox = Hive.box<Avatar>('avatars');
final skillBox = Hive.box<Skill>('skills');
final achievementBox = Hive.box<Achievement>('achievements');

// CRUD operations
avatarBox.put('current_avatar', newAvatar);
final avatar = avatarBox.get('current_avatar');
await avatarBox.delete('current_avatar');
```

### Shared Preferences

```dart
// Simple key-value storage
final prefs = SharedPreferences.getInstance();

// User settings
await prefs.setBool('music_enabled', true);
await prefs.setDouble('music_volume', 0.8);

// Progress
await prefs.setInt('current_streak', 5);
await prefs.setInt('highest_score', 250);
```

## Curriculum Integration

### NAPLAN Questions

```dart
// Australian curriculum aligned
AustralianNAPLANQuestions.generateYear1Numeracy(
  topic: 'addition',
  difficulty: 1,
)
// Returns: {
//   'question': 'Anna has 3 apples...',
//   'answer': 7,
//   'theme': 'shopping',
//   'type': 'word_problem',
//   ...
// }
```

### Word Banks

```dart
// Australian English words
LiteracyWordBank.australianSpelling
// → { 'color': 'colour', 'favorite': 'favourite', ... }

LiteracyWordBank.getRandomAustralianWord('animals')
// → 'kangaroo', 'koala', 'wombat', etc.
```

## Performance Considerations

1. **Lazy Loading**: Zones load content on-demand
2. **Image Caching**: Network images cached automatically
3. **List Optimization**: Use `ListView.builder` for long lists
4. **Widget Rebuild**: Use `const` constructors, `Selector`
5. **Audio Preloading**: Music cached at app startup

## Error Handling

```dart
// Try-catch for critical operations
try {
  await localStorageService.saveProgress();
} catch (e, stackTrace) {
  print('Error saving progress: $e');
  // Show user-friendly error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unable to save progress')),
  );
}
```

## Testing Strategy

```dart
// Unit tests
test('Avatar creation sets correct values', () {
  final avatar = Avatar(name: 'Alex', skinColor: 'tan');
  expect(avatar.name, 'Alex');
});

// Widget tests
testWidgets('Quiz displays question', (tester) async {
  await tester.pumpWidget(QuizScreen());
  expect(find.text('What is 2 + 2?'), findsOneWidget);
});

// Integration tests (app-wide workflows)
testWidgets('User can create avatar and start game', (tester) async {
  // Full user journey
});
```

## Deployment Pipeline

```
Code Push (GitHub)
      ↓
GitHub Actions Trigger
      ├─ flutter analyze
      ├─ flutter build web --release
      └─ deploy to Cloudflare Pages
      ↓
Live at playbrightbound.pages.dev
```

## Future Architecture Improvements

- [ ] Add analytics (Firebase)
- [ ] Backend sync (Cloud Firestore)
- [ ] Multiplayer features
- [ ] Custom AI difficulty scaling
- [ ] More mini-game types
- [ ] Internationalization (i18n)
- [ ] Offline-first sync

---

**Last Updated**: January 10, 2026  
**Architecture Version**: 2.0
