# VS Code Problems Triage

VS Code previously reported **318 problems**. After using the explicit Flutter SDK path at `F:\Flutter\flutter`, the command-line analyzer is clean.

This file remains as the repeatable workflow for future analyzer regressions.

## First Pass: Separate Errors from Warnings

Run these once Flutter/Dart are available on PATH:

```powershell
dart format lib test
flutter analyze
```

Or run with the explicit SDK path:

```powershell
& 'F:\Flutter\flutter\bin\dart.bat' format lib test
& 'F:\Flutter\flutter\bin\flutter.bat' analyze
```

Then group problems into:

- Compile errors
- Missing imports
- API/version mismatches
- Deprecated APIs
- Unused imports, variables, fields, and methods
- Lints/style warnings
- Generated-file issues
- Test-only issues

Fix in that order.

## Files to Check First

These files changed most heavily during the visual and gameplay upgrade pass:

- `lib/ui/widgets/quiz_widgets.dart`
- `lib/ui/widgets/animated_answer_option.dart`
- `lib/ui/widgets/juicy_button.dart`
- `lib/ui/themes/app_theme.dart`
- `lib/ui/screens/world_map_screen.dart`
- `lib/ui/screens/avatar_creator_screen.dart`
- `lib/features/mini_games/memory_match_game.dart`
- `lib/features/mini_games/pattern_puzzle_game.dart`
- `lib/features/mini_games/word_search_game.dart`
- `lib/core/controllers/game_session_controller.dart`

## Likely High-Value Fix Patterns

### Dart Type Issues

Common examples:

```dart
final value = someDouble.clamp(0.0, 1.0).toDouble();
```

Use `.toDouble()` when assigning `clamp` output into a `double`.

### Const Context Issues

If a `const` widget contains a non-constant color or object, remove `const` from the parent and keep it only on children that are truly constant.

### Missing Imports

Keyboard/focus features usually require:

```dart
import 'package:flutter/services.dart';
```

Shared visual tokens require:

```dart
import 'package:brightbound_adventures/ui/themes/index.dart';
```

### Unused Imports

After refactors, remove stale imports. VS Code often counts each unused import as a problem.

## Verification Checklist

After each group of fixes:

- `dart format lib test`
- `flutter analyze`
- Run the app on at least one phone-sized viewport and one desktop/web viewport.
- Smoke-test:
  - avatar creation flow,
  - world map navigation,
  - one numeracy quiz,
  - one literacy quiz,
  - Memory Match,
  - Pattern Puzzle,
  - Word Search.

## Target Outcome

The first goal is **0 compile errors**. Warnings can be reduced after the app runs cleanly.

Current command-line result:

- `flutter analyze`: no issues found.
- `flutter test`: all tests passed.
