# BrightBound Adventures - Development Setup Guide

## Overview

BrightBound Adventures is a Flutter-based educational app for children aged 4–12, featuring Australian NAPLAN-aligned curriculum content, interactive mini-games, and engaging gamification.

### Tech Stack

- **Framework**: Flutter 3.38.5 (stable)
- **Language**: Dart 3.10.4
- **State Management**: Provider
- **Local Storage**: Hive + Shared Preferences
- **Audio**: AudioPlayers + Flutter TTS
- **UI Framework**: Material 3
- **Platforms**: Web (primary), Mobile (iOS/Android ready)

## Prerequisites

Before you begin, ensure you have the following installed:

### Required

1. **Flutter SDK** (≥3.0.0)
   ```bash
   flutter --version  # Should show 3.38.5+
   ```

2. **Dart SDK** (≥3.10.4)
   - Comes bundled with Flutter

3. **Android Studio** (for mobile development)
   - Download from [developer.android.com](https://developer.android.com/studio)
   - Install Android SDK tools

4. **Xcode** (for iOS development, macOS only)
   ```bash
   xcode-select --install
   ```

5. **Git**
   - Clone the repository

### Optional

- **VS Code** with Flutter extension for development
- **Chrome** for web development testing
- **Cloudflare CLI** (wrangler) for deployment

## Installation

### 1. Clone Repository

```bash
git clone https://github.com/theantipopau/brightbound_adventures.git
cd brightbound_adventures
```

### 2. Get Flutter Dependencies

```bash
flutter pub get
```

### 3. Run Code Generation (if needed)

```bash
flutter pub run build_runner build
```

### 4. Verify Setup

```bash
flutter doctor
```

Ensure all checks pass (❌ items are OK if marked as optional).

## Project Structure

```
lib/
├── core/                      # Business logic & services
│   ├── models/               # Data models
│   ├── services/             # AudioManager, LocalStorageService, etc.
│   └── utils/                # Utilities & word banks
├── features/                 # Feature modules
│   ├── literacy/            # Word Woods zone
│   ├── numeracy/            # Number Nebula zone
│   ├── mini_games/          # Memory Match, Pattern Puzzle, Word Search
│   ├── auth/                # Avatar creation
│   └── world_map/           # Main navigation
├── ui/                       # UI layer
│   ├── screens/             # Full-page widgets
│   ├── widgets/             # Reusable components
│   ├── themes/              # Theming & colors
│   └── dialogs/             # Dialog components
└── main.dart                # App entry point
```

## Running the App

### Web (Development)

```bash
flutter run -d chrome
```

### Web (Production Build)

```bash
flutter build web --release
```

Output: `build/web/`

### Mobile (Android)

```bash
flutter run -d android
```

### Mobile (iOS)

```bash
flutter run -d ios
```

## Common Development Tasks

### Add a New Package

```bash
flutter pub add package_name
```

### Update Dependencies

```bash
flutter pub upgrade
```

### Run Code Analysis

```bash
flutter analyze
```

### Format Code

```bash
dart format lib
```

### Run Tests

```bash
flutter test
```

### Generate Translations

If adding new languages:

```bash
flutter pub run intl_utils:generate
```

## Architecture Highlights

### Service Layer

Services provide core functionality:

- **AudioManager**: Music and SFX control
- **LocalStorageService**: Persistent data storage
- **StreakService**: Daily streak tracking
- **AchievementService**: Badge/trophy system
- **ShopService**: In-app cosmetic purchases

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed information.

### Responsive Design

The app uses adaptive layouts:

- **Mobile** (< 768dp): Single-column layout
- **Tablet** (768–1200dp): Split-panel layout
- **Desktop** (≥ 1200dp): Multi-column layout

### Asset Management

All assets are embedded in the Flutter app:

```
assets/
├── images/          # Zone backgrounds, UI elements
├── audio/          # Splash music, menu music, SFX
├── fonts/          # Custom fonts
└── animations/     # Lottie animations (if used)
```

## Debugging

### Enable Debug Logging

```dart
// In lib/main.dart or specific widget
debugPrint('Message here');
```

### Hot Reload

During development, use hot reload for faster iteration:

```bash
r  # Hot reload in terminal
R  # Hot restart
q  # Quit
```

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Then open in browser and connect your app.

### Performance Profiling

Use Flutter DevTools → Performance tab to:

- Monitor frame rendering
- Detect jank
- Profile CPU/memory
- Check widget rebuild counts

## Deployment

### Web (Cloudflare Pages)

```bash
# Build
flutter build web --release

# Deploy with wrangler
wrangler pages deploy build/web --project-name=playbrightbound
```

### Mobile (App Stores)

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for instructions.

## Troubleshooting

### Build Fails with "Dart2JS" Error

```bash
flutter clean
flutter pub get
flutter build web --release
```

### Hot Reload Not Working

```bash
flutter run --no-fast-start
```

### Dependencies Conflict

```bash
flutter pub upgrade --major-versions
flutter pub outdated
```

### Audio Not Playing

- Check browser autoplay policies (Chrome requires user interaction first)
- Verify audio files exist in assets
- Check AudioManager initialization in main.dart

### Layout Issues

- Use `flutter run -d chrome --web-renderer skwia` for alternative rendering
- Check device screen size with `MediaQuery.of(context).size`
- Test responsive layout with DevTools device emulation

## Code Style Guidelines

### Naming Conventions

- **Classes**: PascalCase (`MyWidget`)
- **Variables**: camelCase (`myVariable`)
- **Constants**: camelCase (`kDefaultPadding`)
- **Enums**: PascalCase (`MyEnum`)
- **Files**: snake_case (`my_widget.dart`)

### Code Format

- Use `dart format` before committing
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Max line length: 80 characters (configure in `analysis_options.yaml`)

### Comments

```dart
/// Documentation comment (shown in IDE)
// Regular comment
// TODO: Fix this later
// FIXME: Known issue
// NOTE: Important detail
```

## Continuous Integration

GitHub Actions automatically:

1. ✓ Runs `flutter analyze`
2. ✓ Builds web release
3. ✓ Deploys to Cloudflare Pages

See `.github/workflows/` for configurations.

## Git Workflow

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes
git add .
git commit -m "Add my feature"

# Push and create PR
git push origin feature/my-feature
```

## Performance Tips

1. **Use const constructors** - Reduces rebuild overhead
2. **Lazy load images** - Cache network images
3. **Debounce user input** - Especially for search/filters
4. **Use ListView.builder** - For large lists
5. **Profile regularly** - Use DevTools Performance tab

## Security Notes

- No sensitive data is stored in code
- All credentials come from environment variables
- Audio files are verified before playback
- User data is stored locally (not cloud)

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Provider State Management](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)
- [NAPLAN Curriculum](https://www.nap.edu.au/)

## Getting Help

- Check [ARCHITECTURE.md](ARCHITECTURE.md) for code organization
- Review existing code in `lib/` for patterns
- Ask in GitHub issues for bugs
- Check Flutter community forums for general questions

## Contributors

For contribution guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).

---

**Last Updated**: January 10, 2026  
**Flutter**: 3.38.5  
**Dart**: 3.10.4
