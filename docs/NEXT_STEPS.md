# BrightBound Adventures - Current Next Steps

**Updated:** 20 July 2026
**Source of truth:** [v2.1 Roadmap & File Tracker](V2_1_ROADMAP_TRACKER.md) — the working document with per-task file lists and checkboxes. It is backed by the [Release Execution Plan](V2_1_RELEASE_EXECUTION_PLAN.md) (task definitions, owners), the [3D & Game-Visual Direction Spec](V2_1_3D_VISUAL_DIRECTION.md) (art + rendering detail), and the [Premium Audit](V2_1_PREMIUM_AUDIT_AND_ROADMAP.md) (rationale, acceptance criteria).

Start with the Sprint 1 tasks in the execution plan: MO-1 (motion tokens), VS-1 (semantic theme extensions), WM-1 (map safety-net tests), RE-1 (atomic rewards), CO-4 (CI pipeline). A3D-7 (procedural 3D extrusion of the map painters, per the [3D & Game-Visual Direction Spec](V2_1_3D_VISUAL_DIRECTION.md)) can also start immediately for a fast visual win.

## Immediate priority

The next release is a cohesion and completion release:

1. Establish fresh clean-checkout verification evidence.
2. Add world-map viewport, theme, state, semantics, and golden coverage.
3. Introduce semantic design/theme tokens and remove hard-coded UI colours from critical journeys.
4. Refactor the monolithic map into testable state, layout, widgets, and painter layers.
5. Turn session history into explainable daily, review, challenge, and boss recommendations.
6. Unify reward application/reveal so completion visibly changes the character and world.
7. Remove or intentionally gate every reachable coming-soon/placeholder path.
8. Verify marketing, curriculum, privacy, accessibility, and platform claims.

The full audit defines the world-map v2 experience, light/dark requirements, asset and motion programmes, delivery phases, and release acceptance criteria.

## Current product loop

`world map - quest - practice - rewards - character/world progress - parent insight`

## Verification baseline

Recent work recorded passing format, analyzer, tests, and release web build, with a known third-party `flutter_tts_web` Wasm dry-run warning. Re-run from a clean checkout before treating that record as current evidence:

```powershell
& 'E:\Flutter\flutter\bin\dart.bat' format --output=none --set-exit-if-changed lib test
& 'E:\Flutter\flutter\bin\flutter.bat' analyze
& 'E:\Flutter\flutter\bin\flutter.bat' test
& 'E:\Flutter\flutter\bin\flutter.bat' build web --release
```

Older `PHASE_*`, session, completion, and roadmap documents are historical context, not current product truth.
