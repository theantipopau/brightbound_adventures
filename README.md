<div align="center">
  <img src="assets/images/logo.png" alt="BrightBound Adventures logo" width="210" />

  # BrightBound Adventures

  **A colourful, offline-first learning RPG for children aged 4-12.**

  [![Flutter](https://img.shields.io/badge/Flutter-3.x-54C5F8?logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
  [![Play](https://img.shields.io/badge/Play-Web-7C3AED)](https://playbrightbound.matthurley.dev)
  ![Offline](https://img.shields.io/badge/Offline-first-16A34A)
  ![Themes](https://img.shields.io/badge/Themes-Light%20%7C%20Dark%20%7C%20System-F59E0B)

  [Play now](https://playbrightbound.matthurley.dev) | [v2.1 roadmap](docs/V2_1_PREMIUM_AUDIT_AND_ROADMAP.md) | [Changelog](CHANGELOG_CODEX.md)
</div>

---

## Learn, explore, collect

```text
world map -> quest -> practise -> XP and stars -> visible rewards -> next quest
```

Children create a companion, explore an isometric board-game world, practise literacy, numeracy, science, logic, storytelling, and motor skills, then spend earned stars on cosmetic rewards.

<div align="center">
  <img src="assets/images/questsandtasks.PNG" alt="Quest scroll" width="120" />
  <img src="assets/images/chest_closed.PNG" alt="Reward chest" width="120" />
  <img src="assets/images/goldpile.PNG" alt="Gold reward" width="120" />
  <img src="assets/images/pinkcrystal.PNG" alt="Collectible crystal" width="120" />
</div>

## What is playable

| Area | Experience |
|---|---|
| Adventure | Eight unlockable zones, avatar travel, quest board, and game shortcuts |
| Learning | Literacy, numeracy, science, logic, storytelling, motor activities, and mini-games |
| Interaction | Story Springs includes a structured drag-to-order activity with drag handles and keyboard-equivalent controls |
| Character | Companion creation, outfits, levels, cosmetic unlocks, and equip flows |
| Motivation | XP, stars, streaks, daily challenges, achievements, bosses, mastery, and Star Shop |
| Replayability | Session history, question freshness, variation, and spaced-repetition foundations |
| Insight | Profile statistics and parent dashboard |
| Comfort | Light/dark/system themes, high contrast, larger text, reduced motion, keyboard and touch |

> [!NOTE]
> BrightBound is feature-rich but not yet at the next premium release bar. The June 2026 audit found unfinished content paths, fragmented styling, world-map maintainability and theme gaps, and missing release-level visual/performance tests. See the [v2.1 Premium Audit & Roadmap](docs/V2_1_PREMIUM_AUDIT_AND_ROADMAP.md).

> [!TIP]
> The latest v2.1 work rebuilds the core loop end to end on one route (quest intro → taught feedback → one atomic reward → premium reveal → a map that visibly changed → an explained next quest) and then migrates **every** zone's results screen onto that same shared, idempotent reward transaction and reveal. The map is still on the path toward the planned three-region responsive rebuild.

## Eight learning worlds

| Word Woods | Number Nebula | Math Facts | Story Springs |
|---|---|---|---|
| Reading and spelling | Number sense | Arithmetic fluency | Stories and language |

| Science Explorers | Creative Corner | Puzzle Peaks | Adventure Arena |
|---|---|---|---|
| Discovery | Creative expression | Logic and patterns | Mixed challenges |

## Visual direction

BrightBound bundles Fredoka, Comfortaa, Noto Emoji, distinct zone palettes, layered surfaces, reward art, and event-driven celebrations. v2.1 focuses on a cohesive token system, authored zone art, a rebuilt map, and equally intentional light and dark compositions.

<div align="center">
  <img src="assets/images/bluecrystal.PNG" alt="Blue crystal" width="84" />
  <img src="assets/images/greencrystal.PNG" alt="Green crystal" width="84" />
  <img src="assets/images/goldkey.PNG" alt="Golden key" width="84" />
  <img src="assets/images/potion.PNG" alt="Potion" width="84" />
  <img src="assets/images/scroll.PNG" alt="Scroll" width="84" />
</div>

## Privacy, accessibility, and platforms

- Offline-first Hive/shared-preferences storage; no advertising or social feed.
- Responsive Flutter UI for web, phone, and tablet.
- Light, dark, system, high-contrast, larger-text, and reduced-motion modes.
- Mouse, touch, stylus, trackpad, keyboard, text-to-speech, and optional sound foundations.

Accessibility and theme parity are v2.1 release gates, including contrast, focus, 200% text, reduced motion, and target viewports.

## Architecture

```text
lib/core       services, learning logic, models, data, utilities
lib/features   literacy, numeracy, science, logic, storytelling, motor, teacher
lib/ui         screens, widgets, themes, painters, effects
test           unit and responsive/widget smoke tests
website        public marketing site
brightbound-api Cloudflare Worker API and D1 configuration
```

State uses `provider`; persistence uses Hive and shared preferences. Optional online capabilities live behind the Worker project.

## Run and verify

```powershell
flutter pub get
flutter run
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

If Flutter is not on `PATH`, this workspace has used `E:\Flutter\flutter\bin\flutter.bat`. The web build may report a known third-party `flutter_tts_web` Wasm dry-run warning.

## Deploy

Root `wrangler.toml` targets Flutter Pages; `website/` contains the marketing site; `brightbound-api/` contains the Worker/D1 API.

```powershell
flutter build web --release
wrangler pages deploy build/web --project-name=playbrightbound
cd brightbound-api
npm.cmd run deploy
```

## Project status

Current version: `2.0.0+2`. Proposed milestone: **v2.1 Living World**.

Latest verified local baseline: `dart format`, `flutter analyze`, the full Flutter test suite (**198 tests**), colour inventory, and `flutter build web --release` all pass. The release build retains a known third-party `flutter_tts_web` Wasm dry-run warning; the normal web bundle succeeds.

The current v2.1 slice delivers one complete, tested core loop on the Word Woods route: a quest introduction (objective, why-now reason, reward preview), a learner-paced encounter that shows the authored explanation after every answer, a single idempotent reward transaction, a choreographed reward reveal that explains what was earned and why, a persisted world change on return (quest flag + Quest Lens acknowledgement), and an evidence-based "up next" recommendation. The Story Springs drag-to-order prototype, semantic world-map zone states, responsive Quest Lens and compact adventure bar remain in place. Reachable placeholder paths outside literacy, audio assets, the full map shell split, and broader non-MCQ interaction coverage remain open roadmap work — see [Current state audit](docs/CURRENT_STATE_AUDIT.md) and [Content quality report](docs/CONTENT_QUALITY_REPORT.md).

- [Premium Audit & Roadmap](docs/V2_1_PREMIUM_AUDIT_AND_ROADMAP.md) - source of truth.
- [Current next steps](docs/NEXT_STEPS.md) | [Changelog](CHANGELOG_CODEX.md)
- [Architecture](docs/ARCHITECTURE.md) | [Developer setup](docs/DEV_SETUP.md) | [Contributing](docs/CONTRIBUTING.md)

Older phase/session/completion documents are historical snapshots; validate their claims against the app, tests, and current roadmap.

---

<div align="center"><strong>Built to make practice feel like a place children want to return to.</strong></div>
