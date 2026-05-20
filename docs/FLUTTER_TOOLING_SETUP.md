# Flutter Tooling Setup

The Flutter SDK is installed locally at:

```text
F:\Flutter\flutter
```

The issue was that `flutter` and `dart` were not available on PATH. Commands can be run directly through the SDK path.

## What Is Needed

1. Install the Flutter SDK.
2. Add Flutter's `bin` folder to PATH.
3. Restart VS Code and all terminals.
4. Run:

```powershell
flutter doctor
flutter pub get
dart format lib test
flutter analyze
```

## Windows PATH Example

For this machine, Flutter is installed at:

```text
F:\Flutter\flutter
```

Add this to the user PATH:

```text
F:\Flutter\flutter\bin
```

Then open a new PowerShell terminal and confirm:

```powershell
flutter --version
dart --version
```

## Android/Web Checks

For Android builds:

```powershell
flutter doctor --android-licenses
```

For web builds:

```powershell
flutter devices
flutter run -d chrome
```

## VS Code

Install or enable:

- Dart extension
- Flutter extension

Then confirm VS Code is using the same Flutter SDK path as the terminal. If it is not, set:

```json
{
  "dart.flutterSdkPath": "F:\\Flutter\\flutter"
}
```

Adjust the path to match the actual Flutter install location.

## After Tooling Works

Use the triage guide:

- `docs/VS_CODE_PROBLEMS_TRIAGE.md`

Start with compile errors before lints. The reported 318 VS Code problems will likely include a mix of true errors, formatting fallout, unused imports, deprecated API warnings, and analyzer hints.

## Current Verification

Using the explicit SDK path:

```powershell
& 'F:\Flutter\flutter\bin\flutter.bat' pub get
& 'F:\Flutter\flutter\bin\dart.bat' format lib test
& 'F:\Flutter\flutter\bin\flutter.bat' analyze
& 'F:\Flutter\flutter\bin\flutter.bat' test
```

Current status:

- `flutter analyze`: no issues found.
- `flutter test`: all tests passed.
