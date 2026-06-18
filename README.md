# BrightBound Adventures

BrightBound Adventures is an offline-first Flutter learning game for children aged 4-12. It combines curriculum-aligned practice, a board-game style world map, avatar progression, daily challenges, achievements, a Star Shop, and parent insight tools.

## What Is In The App

- Avatar-driven onboarding and character customisation.
- Premium first-run flow with responsive splash, onboarding, avatar creation, and world-entry screens.
- World map hub with unlockable learning zones.
- Literacy, numeracy, logic, storytelling, motor, science, and mixed challenge flows.
- Daily challenges, streaks, achievements, XP, stars, and shop rewards.
- Local replayability history for completed quest sessions, including freshness/repeat tracking for question sets.
- Parent dashboard and profile/stat screens.
- Accessibility settings for high contrast, larger text, and reduced motion.
- Cloudflare Worker API project in `brightbound-api`.

## Current Product Direction

The current focus is tightening the core RPG loop:

```text
world map -> quest -> practice -> rewards -> character/item progress -> parent insight
```

See [docs/NEXT_STEPS.md](docs/NEXT_STEPS.md) for the current operating plan and [CHANGELOG_CODEX.md](CHANGELOG_CODEX.md) for implementation notes from recent Codex passes.

## Local Development

Use the Flutter SDK available on your machine, or the explicit SDK path used in this workspace:

```powershell
& 'F:\Flutter\flutter\bin\flutter.bat' pub get
& 'F:\Flutter\flutter\bin\flutter.bat' run
```

Useful checks:

```powershell
& 'F:\Flutter\flutter\bin\dart.bat' format lib test
& 'F:\Flutter\flutter\bin\flutter.bat' analyze
& 'F:\Flutter\flutter\bin\flutter.bat' test
& 'F:\Flutter\flutter\bin\flutter.bat' build web --release
```

Focused first-run viewport smoke test:

```powershell
& 'F:\Flutter\flutter\bin\flutter.bat' test test/startup_responsive_smoke_test.dart
```

## Cloudflare

The repository contains two Cloudflare configurations:

- Root `wrangler.toml`: Flutter web / Pages deployment for `playbrightbound`.
- `brightbound-api/wrangler.toml`: Cloudflare Worker API with D1 binding `brightbound_db`.

API deploy:

```powershell
cd brightbound-api
npm.cmd run deploy
```

Flutter web deploy should only be run from a clean, intentional app state:

```powershell
& 'F:\Flutter\flutter\bin\flutter.bat' build web --release
wrangler pages deploy build/web --project-name=playbrightbound
```

## Repository Notes

- The `docs/` folder contains historical phase notes, audits, deployment guides, and planning documents.
- Treat `docs/NEXT_STEPS.md` and `CHANGELOG_CODEX.md` as the current lightweight guideposts.
- Keep API, app UI, and documentation changes separated where practical unless intentionally publishing a broad sync.
