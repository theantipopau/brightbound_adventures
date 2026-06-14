# BrightBound Adventures - Current Next Steps

**Updated:** June 2026
**Current health:** `flutter analyze` and `flutter test` were clean before the latest map-layout pass. Re-run the verification commands below after the sandbox allows Flutter commands again.

## Current Focus

The app has most major systems in place: world map, zones, skills, daily challenges, streaks, achievements, parent dashboard, shop, cosmetics, accessibility settings, and spaced repetition. The next phase is not broad feature expansion. It is tightening the core loop so it feels like one polished mini RPG:

`world map -> quest -> practice -> rewards -> character/item progress -> parent insight`

## Immediate Sprint: RPG Loop Stabilization

1. Stabilize the dirty worktree
   - Review the large pending `forum/` deletion separately.
   - Keep app changes, API config changes, and documentation updates in separate commits.
   - Do not mix product work with cleanup-only changes.

2. Make the world map the central hub
   - Keep map controls, quest board, shop, achievements, daily challenges, and mini-games reachable from the map.
   - Keep zone coordinates inside a safe field that avoids the right quest board and bottom action dock.
   - Keep the top-left player HUD useful: character identity, level, XP, and a clear path to character rewards.
   - Manually verify map layout at desktop, tablet landscape, tablet portrait, and phone sizes.
   - Add a world-map smoke test once the visual layout settles.

3. Connect rewards to the character
   - Practice completion should clearly award XP/stars.
   - Stars should feed the Star Shop.
   - Purchased outfits/accessories should unlock on the avatar and be visible where supported.
   - Zone completion and level milestones should preview the next item reward.

4. Strengthen test coverage
   - Keep existing numeracy, tracing, and zone-ID tests.
   - Add tests for shop purchase behavior and avatar reward ID consistency.
   - Add widget smoke tests for map rendering, shop route access, avatar creator flow, and parent dashboard access.

5. Refresh documentation
   - Treat older `PHASE_*` and session docs as historical.
   - Keep this file and `CHANGELOG_CODEX.md` as the current operational guide.
   - Update docs after each coherent sprint, not after every tiny edit.

## Next Product Layer

After the RPG loop is stable:

- Parent weekly summaries, weak-skill recommendations, and goals.
- Certificate export/share support.
- Better shop inventory/equip UI.
- More narrative quests per zone.
- More manual accessibility checks: screen reader, high contrast, reduced motion, and keyboard-only navigation.

## Verification Commands

Use the explicit SDK path if Flutter is not on `PATH`:

```powershell
& 'F:\Flutter\flutter\bin\dart.bat' format lib test
& 'F:\Flutter\flutter\bin\flutter.bat' analyze
& 'F:\Flutter\flutter\bin\flutter.bat' test
& 'F:\Flutter\flutter\bin\flutter.bat' build web --release
```
