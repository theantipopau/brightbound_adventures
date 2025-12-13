# Getting Started

## Prerequisites
- Flutter SDK (stable channel)
- Dart 3.0+
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- Chrome (for web development)

## Installation

### 1. Clone & Setup
```bash
cd "f:\BrightBound Adventures"
flutter pub get
```

### 2. Add Fonts
See [FONTS.md](FONTS.md) for instructions on downloading and adding custom fonts.

### 3. Run the App

**Android Emulator:**
```bash
flutter run -d emulator-5554
```

**Web (PWA):**
```bash
flutter config --enable-web
flutter run -d chrome
```

**iOS (requires macOS):**
```bash
flutter run -d "iPhone 15 Pro"
```

## Project Structure Overview

- **`/lib/core`** – Models, services, utilities, storage
- **`/lib/ui`** – Themes, widgets, screens
- **`/lib/features`** – Zone-specific modules (avatar, storytelling, literacy, numeracy, etc.)
- **`/assets`** – Images, sounds, fonts (create as needed)
- **`/web`** – PWA configuration, manifest, icons

## Development Workflow

1. **Feature Development**: Add new screens/widgets in `/lib/ui/screens` or `/lib/features`
2. **State Management**: Use Provider for shared state across the app
3. **Storage**: Use `LocalStorageService` for persisting data
4. **Styling**: Reference `AppTheme`, `AppColors`, `AppTypography`
5. **Testing**: Run on Android, web, and iOS before committing

## Useful Commands

```bash
# Run with verbose output
flutter run -v

# Run with hot reload disabled
flutter run --no-hot

# Build for web
flutter build web

# Run tests
flutter test

# Lint code
flutter analyze

# Check Flutter doctor
flutter doctor
```

## Architecture Principles

1. **Modular**: Each feature is self-contained
2. **Offline-First**: All data stored locally, no network calls
3. **Adaptive**: Learning difficulty scales based on performance
4. **Child-Safe**: No external APIs, no analytics, no ads
5. **Accessible**: Large touch targets, high contrast, clear feedback

## Phase Status

**Phase 1** ✅ Scaffolding complete. Ready for Phase 2.

See [README.md](README.md) for detailed project overview and phase roadmap.
