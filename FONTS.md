# Font Setup Instructions

BrightBound Adventures uses two custom fonts for a friendly, accessible design:

## Fonts to Download

### 1. Fredoka
- **Use**: Headlines, labels, UI text
- **Files needed**:
  - `Fredoka-Regular.ttf`
  - `Fredoka-Medium.ttf`
  - `Fredoka-SemiBold.ttf`
- **Download**: https://www.google.com/fonts (free)

### 2. Comfortaa
- **Use**: Body text, storytelling content
- **Files needed**:
  - `Comfortaa-Regular.ttf`
  - `Comfortaa-Bold.ttf`
- **Download**: https://www.google.com/fonts (free)

## Installation

1. Download the font files (TTF format) from Google Fonts
2. Place them in: `assets/fonts/`
3. Structure should be:
   ```
   assets/
     fonts/
       Fredoka-Regular.ttf
       Fredoka-Medium.ttf
       Fredoka-SemiBold.ttf
       Comfortaa-Regular.ttf
       Comfortaa-Bold.ttf
   ```
4. The `pubspec.yaml` is already configured to use these fonts
5. Run `flutter pub get` after adding files
6. Fonts will be available as `fontFamily: 'Fredoka'` and `fontFamily: 'Comfortaa'`

## Fallback

If fonts are not available, the app will use system defaults (San Francisco on iOS, Roboto on Android/web).
