# Phase 7 — Visual World & Game Feel Master Plan

> Theme: Turn the world map from a functional selector into a magical, readable, high-feedback game world.
> Focus: 3D depth clarity, visual identity, tactile interaction, progression readability, and celebration moments.

---

## Why This Phase

Phase 6 improved engagement mechanics (TTS, streaks, guardians, reward text). Phase 7 should make the map itself feel like a game, not a menu.

Primary goals:
- Make 3D depth instantly readable for ages 5-12
- Make every interaction feel tactile and rewarding
- Make progression and unlock state obvious at a glance
- Keep performance smooth on low-end devices

---

## Current Snapshot (Visual/Game Audit)

Top issues to solve first:
- 3D shadows too subtle; islands feel flatter than intended
- Zone click/press feedback is too quiet
- Zone biome textures are hard to perceive at normal zoom
- Path progression lines are low contrast
- Zone unlock moments are under-celebrated
- Some map layers are expensive to repaint continuously

Core files:
- `lib/ui/screens/world_map_screen.dart`
- `lib/ui/painters/shadow_painter.dart`
- `lib/ui/painters/terrain_painter.dart`
- `lib/ui/painters/path_painter.dart`

---

## Wave Plan (8 Weeks)

## Wave 1 (Weeks 1-2) — Foundation: Readable 3D & State Clarity

- [ ] Enhance island shadow stack in `shadow_painter.dart` (multi-layer depth + stronger elevation cues)
- [ ] Improve locked-zone clarity in `world_map_screen.dart` (overlay + lock badge + star requirement)
- [ ] Strengthen path contrast in `path_painter.dart` (thicker strokes, clearer locked/unlocked contrast)
- [ ] Introduce background paint optimization in `world_map_screen.dart` and painter layers (cache static layers where possible)

Acceptance criteria:
- Zones feel visually elevated from the terrain at first glance
- Locked zones are unmistakably non-enterable
- Progress paths are readable on phone and desktop
- No noticeable frame drops during idle map animation

---

## Wave 2 (Weeks 3-4) — Delight: Tactile Interaction & Celebration

- [ ] Add press-state interaction to zone islands (scale-down + ripple + rebound)
- [ ] Add selected-zone glow pulse and hover/selection intensity improvements
- [ ] Add zone unlock celebration event (toast + particle burst + sound + haptic)
- [ ] Add star-counter gain pop animation in top HUD when total stars increase

Acceptance criteria:
- Taps feel immediate and physical
- Unlocks create a clear "I achieved something" moment
- Reward counters visibly react to progress changes

---

## Wave 3 (Weeks 5-6) — Depth: Biome Identity & Progress Storytelling

- [ ] Enhance biome texture readability in `terrain_painter.dart` (larger motifs, zone-specific pattern contrast)
- [ ] Improve zone spotlight panel hierarchy and CTA emphasis in `world_map_screen.dart`
- [ ] Upgrade quick zone rail to communicate progression and current location more clearly
- [ ] Add richer map-to-zone transition continuity (arrival pulse before navigation)

Acceptance criteria:
- Each zone has distinct visual personality without reading text
- Spotlight panel increases confidence to enter selected zone
- Children can explain "where they are" and "where they can go next"

---

## Wave 4 (Weeks 7-8) — Finish: Performance, Accessibility, Device Polish

- [ ] Add reduced-motion support for map animations
- [ ] Verify keyboard/semantics behavior for all map interactions
- [ ] Tune animation budgets for low-end Android and older tablets
- [ ] Test phone/tablet/desktop layout edge cases and orientation changes

Acceptance criteria:
- Smooth map interaction on target low-end devices
- Accessibility behaviors remain intact with new effects
- No visual regressions across form factors

---

## Quick Wins (Do First, Low Risk)

1. [x] Locked zone overlay with lock icon and required-stars badge ✅
2. [x] Current zone highlight upgrade in quick zone rail ✅
3. [x] Star gain pop animation for HUD counter ✅
4. [x] Selected-zone glow pulse in map ✅
5. [x] Path stroke thickness and contrast bump ✅

Estimated total for quick wins: 1-2 dev days.

---

## Technical Guardrails

- Keep interactions performant: avoid per-frame expensive allocations in painters
- Keep touch targets large: minimum ~48x48 logical pixels for interactive controls
- Keep visual cues redundant: color + icon + text for locked/unlocked/progress states
- Respect user comfort: support reduced motion and avoid high-frequency flashes

---

## Definition of Done (Phase 7)

- [ ] 3D depth cues are visually obvious and consistent
- [ ] Zone state (locked/current/selected/unlocked) is clear in under 2 seconds
- [ ] Every reward event has a visible feedback response
- [ ] Performance target met on low-end devices (no sustained jank in world map)
- [ ] Accessibility checks pass after animation/painter changes

---

## Suggested Execution Order

1. Implement all 5 quick wins
2. Complete Wave 1 depth + state clarity
3. Ship Wave 2 delight features
4. Add Wave 3 biome/UX depth
5. Finish with Wave 4 hardening and QA

---

## Handoff Notes

This phase is intentionally visual-first and should be validated with short user sessions (kids + parents) every week.
Record before/after clips for each wave to verify perceived improvement, not just code completion.
