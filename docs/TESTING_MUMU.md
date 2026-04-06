# Testing with MuMu Android Emulator

## Setup & Installation

### 1. Connect MuMu to Flutter
MuMu uses ADB (Android Debug Bridge). First, verify it's accessible:

```bash
# List connected devices
flutter devices

# Or check ADB devices
adb devices
```

### 2. MuMu Configuration

**Default MuMu Location:**
- Windows: `C:\Program Files\Netease\MuMu Player\emulator\nemu\vmonitor`

**Enable ADB Debugging:**
1. Open MuMu
2. Click **Settings** (⚙️ icon)
3. Navigate to **Developer Options**
4. Enable **USB Debugging**

### 3. Connect via ADB

```bash
# If MuMu doesn't appear, connect manually:
adb connect 127.0.0.1:7555

# Verify connection:
adb devices
# Output should show: emulator-7555 (or similar)
```

---

## Running the App

### Build & Run
```bash
cd "f:\BrightBound Adventures"

# Get dependencies
flutter pub get

# Run on MuMu
flutter run

# Or specify device:
flutter run -d emulator-7555
```

### Hot Reload During Development
Once app is running:
- Press `r` for hot reload
- Press `R` for full restart
- Press `q` to quit

---

## Testing Checklist

### Avatar Creation (First Launch)
- [ ] Splash screen appears for 2 seconds
- [ ] Avatar Creator loads (4-step wizard)
- [ ] Name input accepts text
- [ ] Character selection highlights on tap
- [ ] Colour picker shows live preview
- [ ] Review screen displays choices
- [ ] Create button saves and navigates to World Map

### Data Persistence
- [ ] Avatar appears on World Map after creation
- [ ] Kill app (back button or task switcher)
- [ ] Relaunch app → Avatar still visible
- [ ] Avatar name, character, level visible

### UI Responsiveness
- [ ] Landscape orientation works
- [ ] Text readable at small sizes
- [ ] Touch targets (60px+) are easy to tap
- [ ] No layout overflow warnings

### Navigation
- [ ] Zone cards tap and navigate to placeholders
- [ ] Settings icon appears (ready for parent dashboard)

---

## Troubleshooting

### Device Not Found
```bash
# Kill and restart ADB
adb kill-server
adb start-server
adb connect 127.0.0.1:7555
```

### App Crashes
```bash
# View detailed logs
flutter run -v

# Check Logcat
adb logcat | grep flutter
```

### Hot Reload Fails
```bash
# Full rebuild
flutter clean
flutter pub get
flutter run
```

### MuMu Not Responding
- Restart MuMu emulator
- Check if port 7555 is available: `netstat -ano | findstr :7555`
- Try different ADB port: `adb connect 127.0.0.1:7585`

---

## Performance Tips

- **Reduce Animations**: For testing, disable 2-second splash screen delay in code
- **Hot Restart**: Use `R` instead of `r` for faster full reloads
- **Verbose Mode**: `flutter run -v` shows real-time build progress

---

## Next Steps

After confirming app runs on MuMu:
1. Test avatar creation workflow end-to-end
2. Verify data persists after app restart
3. Test all zone card navigation
4. Ready for Phase 2.5 learning module implementation

**You're good to go!** 🚀
