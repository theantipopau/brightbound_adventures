# v2.1 "Living World" — Release Execution Plan

**Created:** 20 July 2026
**Companion documents:** [V2_1_PREMIUM_AUDIT_AND_ROADMAP.md](V2_1_PREMIUM_AUDIT_AND_ROADMAP.md) (the *why*) · [V2_1_ROADMAP_TRACKER.md](V2_1_ROADMAP_TRACKER.md) (the *working checklist* — per-task file lists and progress boxes) · [V2_1_3D_VISUAL_DIRECTION.md](V2_1_3D_VISUAL_DIRECTION.md) (art/3D detail). This document defines tasks, owners, and the schedule.
**Release theme:** from learning **app** to learning **game**. More interactive, more playful, smoother, and visually coherent.

---

## 1. Where the product is today (July 2026 code review)

Grounded in the current `codex/rpg-map-ui-loop` branch, not historical reports:

| Area | Current state | Evidence |
|---|---|---|
| Feature breadth | Strong — 8 zones, XP/stars/streaks, bosses, mastery, shop, daily challenges, parent dashboard, adaptive difficulty, spaced repetition | `lib/core/services/` (30+ services), `lib/features/` |
| Game feel | Weak — the "game" is mostly a themed quiz. Learning interactions are overwhelmingly tap-an-option MCQ; only motor/tracing and word search use gestures | `Draggable`/drag gestures appear in only 6 feature files |
| World map | The one screen that feels like a game, but it is a 5,541-line monolith mixing HUD, panels, zones, pawn, painters, and responsiveness | `lib/ui/screens/world_map_screen.dart` |
| Animation | Fragmented. Ad-hoc `AnimationController`s per widget, one custom particle system (`animation_service.dart`), a handful of visual-effect widgets, and a single shared page transition (`transitions.dart`). No shared duration/curve tokens, no motion hierarchy | `lib/ui/widgets/visual_effects/`, `lib/core/services/animation_service.dart` |
| Visual system | No semantic design tokens. Two theme files (`lib/ui/themes/app_theme.dart`); bespoke screens hard-code colours, gradients, radii, and shadows, breaking dark-mode parity | v2.1 audit §"Light and dark theme programme" |
| Completeness | Reachable "coming soon"/placeholder paths in literacy, numeracy, storytelling, logic practice + exported `placeholder_zone_screen.dart` | grep confirms 5 files |
| Tests | 11 test files; solid for services, near-zero for the map, themes, motion, and visual regressions | `test/` |
| Delivery | Cloudflare Pages + Worker/D1 deploys work; no CI gates for format/analyze/test/build | `wrangler.toml`, `brightbound-api/` |

**One-line verdict:** all the *systems* of a game exist, but the *feel* of a game — direct manipulation, juicy feedback, choreographed motion, one coherent art language — does not yet.

---

## 2. Release definition

**v2.1 "Living World"** is a game-feel, cohesion, and completion release. Success is a child saying "I'm playing BrightBound", not "I'm doing my quiz app".

### The four pillars (in priority order)

1. **Game-first interactivity** — replace passive MCQ-only practice with direct-manipulation interactions (drag, drop, drag-to-order, number lines, tap-the-evidence), and make the map/quest/reward loop feel like play.
2. **Motion system** — one motion language: shared tokens (durations, curves), choreographed sequences for the moments that matter (travel, quest entry, answer feedback, reward reveal, unlock, mastery), reduced-motion parity, and removal of ambient noise.
3. **Visual system** — semantic theme tokens, a shared component kit, authored zone art direction, and true light/dark parity.
4. **Truth and completeness** — no reachable dead end, real tests on the critical journeys, reproducible release pipeline.

### Explicitly out of scope for v2.1

Pets/companions, seasonal content, teacher classroom tools, cloud sync, new curriculum areas. (These are v2.2+ candidates and are already flagged P2 in the audit.)

---

## 3. Owners

| Tag | Who | Responsibilities |
|---|---|---|
| **Matt** | Product owner | Decisions, art direction sign-off, asset sourcing/creation, playtesting with kids, release approval |
| **Agent** | AI dev sessions (Claude Code / Codex) | Implementation, refactoring, tests, tooling, doc upkeep |
| **Matt+Agent** | Pairing | Design-heavy work where Matt decides and the agent executes iterations |

Each task below has an ID so a session can be pointed at it directly ("do WM-2").

---

## 4. Workstreams and tasks

### Workstream A — Motion & Game Feel Foundation *(do first; everything else builds on it)*

| ID | Task | Owner | Size | Depends on |
|---|---|---|---|---|
| MO-1 | **Motion tokens.** Create `lib/ui/themes/motion_tokens.dart`: named durations (instant 100ms, quick 180ms, standard 250ms, emphasised 400ms, celebration 700–1000ms), named curves (standard, enter, exit, bounce, elastic), and a `reducedMotion` resolver that collapses everything to fades/instant. All new animation code must consume these. | Agent | S (1–2 d) | — |
| MO-2 | **Shared transition kit.** Extend `transitions.dart` into a route + hero policy: zone entry (scale-up from map node), modal sheets (spring slide), results (celebration push). Replace bespoke `PageRouteBuilder`s across screens. | Agent | M (3–4 d) | MO-1 |
| MO-3 | **Juice pass on core controls.** One shared pressable behaviour (scale + shadow + optional haptic/sound) applied via `juicy_button.dart` rework; kill per-screen variants. Answer options get press-down, correct-bounce, wrong-shake with the shared tokens. | Agent | M (3 d) | MO-1 |
| MO-4 | **Choreographed reward reveal.** One authored sequence for quest completion: stars count up → XP bar fills → level/streak/achievement callouts queue one at a time → "what's next" card. Backed by the atomic reward transaction (RE-1). Never two celebrations at once. | Agent | L (1 wk) | MO-1, RE-1 |
| MO-5 | **Ambient motion cull.** Audit every looping ticker/particle/pulse (`visual_effects/`, map clouds). Keep at most one subtle idle layer on capable layouts; everything else becomes event-driven. Document the motion hierarchy: idle < feedback < selection < travel < celebration. | Agent | S (2 d) | MO-1 |
| MO-6 | **Reduced-motion + performance proof.** Verify all of the above under reduced motion and on a low-end profile (web + Android). No animation may drop the map below the agreed frame budget. | Agent | S (2 d) | MO-2..5 |

### Workstream B — World Map v2 *(the flagship screen)*

> Detailed art direction, asset pipeline, and 3D rendering spec for WM-7/WM-8 and the A3D task series: [V2_1_3D_VISUAL_DIRECTION.md](V2_1_3D_VISUAL_DIRECTION.md).

| ID | Task | Owner | Size | Depends on |
|---|---|---|---|---|
| WM-1 | **Safety net first.** Widget + golden tests for the *current* map at 360×640, 768×1024, 1366×768, light/dark, before refactoring. | Agent | M (3 d) | — |
| WM-2 | **Extract `WorldMapViewModel`.** Pure model built from avatar, skill progress, session history, daily challenge, reward state. No provider reads in scene widgets; painters receive immutable scene data. | Agent | L (1 wk) | WM-1 |
| WM-3 | **Split the monolith.** Break `world_map_screen.dart` into `lib/features/world_map/{models,services,screens,widgets,painters,tokens}` per the audit spec: adventure bar, living board, quest lens, zone node, pawn, terrain/route painters. Target: no file over ~600 lines. | Agent | L (1.5 wk) | WM-2 |
| WM-4 | **Three-region responsive shell.** Adventure bar / living board / quest lens. Desktop: board + side lens. Tablet portrait: collapsible bottom lens. Phone: pannable board + persistent compact quest sheet. Secondary destinations move into an adventure menu (kill the crowded action dock). | Agent | L (1 wk) | WM-3 |
| WM-5 | **Zone state language.** Implement the 7 states (locked, available, recommended, in-progress, needs-review, boss-ready, mastered) exactly as specified in the audit's state table, each with visual + motion + accessible cue. Golden coverage for all 7 in both themes. | Agent | L (1 wk) | WM-3, MO-1 |
| WM-6 | **Travel choreography.** Pawn travel: anticipation → path movement along the route → settle → zone door opens (700–1000 ms, from motion tokens). Unlock: route draws once, gate opens, landmark gains colour. | Agent | M (4 d) | WM-3, MO-2 |
| WM-7 | **Map art direction v1.** Implement per the [3D & Game-Visual Direction Spec](V2_1_3D_VISUAL_DIRECTION.md): art bible, asset pipeline, manifest, global asset set, and the first authored zone (Word Woods). Emoji demoted to fallback. | Matt+Agent | L (2 wk, parallel) | — |
| WM-8 | **Remaining 7 zone asset families** rolled out on the WM-7 template (spec §5.3), one PR per zone. | Matt+Agent | L (2 wk, parallel) | WM-7 |
| WM-10 | **A3D rendering series.** Scene layer stack, `IsoSprite` + manifest, elevation/hover physics, sprite pawn with hop arcs, camera/parallax/depth haze, `TiltCard`, procedural extrusion interim upgrade — tasks A3D-1..A3D-8 in the [3D spec §6](V2_1_3D_VISUAL_DIRECTION.md). A3D-7 can start immediately; the rest follow WM-3. | Agent | L (2 wk) | WM-3 (except A3D-7) |
| WM-9 | **Retire legacy.** Remove/archive `fantasy_map.dart` and `placeholder_zone_screen.dart` exports once nothing routes to them. | Agent | S (0.5 d) | WM-4 |

### Workstream C — Interactive Learning (the "game, not quiz" pillar)

| ID | Task | Owner | Size | Depends on |
|---|---|---|---|---|
| IN-1 | **Interaction framework.** One reusable engine for direct-manipulation question types: shared scaffold (prompt, canvas, feedback, hint, submit), drag/drop primitives, snap targets, forgiving hit areas for small hands, keyboard/switch-access equivalents, TTS hooks. Built once, themed everywhere. | Agent | L (1.5 wk) | MO-1, MO-3 |
| IN-2 | **Interaction #1: drag-to-order.** Story/sentence sequencing (storytelling + literacy). | Agent | M (4 d) | IN-1 |
| IN-3 | **Interaction #2: number line & quantity drag.** Place numbers/fractions on a line; drag counters into groups (numeracy). | Agent | M (4 d) | IN-1 |
| IN-4 | **Interaction #3: sort-into-bins.** Classification for science (living/non-living, materials) and literacy (word sorts). | Agent | M (4 d) | IN-1 |
| IN-5 | **Interaction #4: tap-the-evidence.** Tap the word/sentence in a passage that answers the question (reading comprehension). | Agent | M (3 d) | IN-1 |
| IN-6 | **Wire interactions into generators.** Question loader/variation engines emit the new interaction types with sensible MCQ fallback; adaptive difficulty and freshness services treat them as first-class. | Agent | M (1 wk) | IN-2..5 |
| IN-7 | **Session pacing.** Break the flat question march into quest beats: intro beat (goal framing), 3–5 question beats with a mid-quest surprise (chest/character moment), boss beat option, results beat. Uses MO-2 transitions. | Agent | M (4 d) | MO-2, RE-1 |

### Workstream D — Quest & Reward Loop

| ID | Task | Owner | Size | Depends on |
|---|---|---|---|---|
| RE-1 | **Atomic reward transaction.** Single idempotent service applying stars/XP/level/streak/daily/achievement/mastery/cosmetic outcomes; persist first, then animate confirmed results. Revisiting results never duplicates. Unit-tested heavily. | Agent | L (1 wk) | — |
| RE-2 | **Recommendation service.** Explainable quest suggestions from session history: Continue / Review / Challenge / Daily / Boss, each with a reason string, goal, duration, and reward preview. Powers the map quest lens and parent view. | Agent | L (1 wk) | WM-2 |
| RE-3 | **Visible world/character change.** Completing quests changes something the child can see: zone decoration tier, avatar flair, map flags on mastery. Uses cosmetic unlock service; no new economy. | Agent | M (1 wk) | RE-1, WM-5 |
| RE-4 | **Near-miss visibility.** "2 more stars for the fox hat" style next-unlock proximity in results and shop. | Agent | S (2 d) | RE-1 |

### Workstream E — Visual System & Theme Parity

| ID | Task | Owner | Size | Depends on |
|---|---|---|---|---|
| VS-1 | **Semantic theme extensions.** `ThemeExtension`s for semantic colours, zone palettes (light + dark variants), radii, elevation, spacing. Zone accent colours resolve through the extension, never constants. | Agent | M (4 d) | — |
| VS-2 | **Direct-colour inventory + burn-down.** Script that greps/reports `Color(0x...)`, `Colors.*` usage per file; migrate critical journeys (map, quest, results, shop, settings, parent) first. Inventory count becomes a tracked release metric → 0 on critical screens. | Agent | L (1.5 wk) | VS-1 |
| VS-3 | **Component kit.** Adventure scaffold, surface cards (standard/feature/reward/quest/modal), badges, progress bars, stat chips, empty/loading/error states. Deprecate one-off variants as screens migrate. | Agent | L (1.5 wk) | VS-1 |
| VS-4 | **Dark mode as a first-class composition.** Tonal separation rather than darkened light theme; verified on-colours; elevation tuned separately; high-contrast composes with both. | Agent | M (4 d) | VS-1, VS-2 |
| VS-5 | **Typography & text-scale hardening.** Minimum sizes, wrap behaviour, 200% text pass on critical journeys. | Agent | M (3 d) | VS-3 |

### Workstream F — Completion, Trust & Release Hardening

| ID | Task | Owner | Size | Depends on |
|---|---|---|---|---|
| CO-1 | **Dead-end elimination.** Complete, gate, or honestly label every reachable "coming soon" path (5 files confirmed). No advertised skill hits a placeholder. | Agent | M (1 wk) | IN-6 helps |
| CO-2 | **Content evidence matrix.** Machine-readable inventory per skill: source, interaction types, difficulty span, explanation coverage, repeat distance. CI check fails on gaps for advertised zones. | Agent | M (1 wk) | — |
| CO-3 | **Parent weekly insight.** 7/30-day trends, improving vs review-due skills with evidence, session history, plain-language data explanation. Shares RE-2's model. | Agent | M (1 wk) | RE-2 |
| CO-4 | **CI pipeline.** GitHub Actions (or equivalent): format, analyze, test, web release build on every PR; golden diffs uploaded as artifacts. | Agent | M (3 d) | — |
| CO-5 | **Accessibility device pass.** Keyboard journeys, semantics on custom-painted zones, TalkBack/VoiceOver spot checks, reduced-motion audit, minimum touch targets. | Matt+Agent | M (1 wk) | WM-5, MO-6 |
| CO-6 | **Claims audit.** Verify or soften marketing/curriculum/privacy claims in app, README, and website. | Matt | S (2 d) | — |
| CO-7 | **Release runbook + smoke.** Documented deploy, rollback, service-worker update behaviour, offline reload, production smoke checklist. | Agent | S (2 d) | CO-4 |
| CO-8 | **Playtest rounds.** Two structured sessions with kids (target age band) — one after the map rebuild, one before release. Observed friction becomes tickets. | Matt | S (per round) | WM-4, then all |

---

## 5. Roadmap

Assumes part-time cadence with agent-driven implementation; ~14 weeks wall-clock. Sprints are 2 weeks. Parallel tracks: **engineering** (agent) and **art** (Matt+agent) run side by side from Sprint 2.

```text
Sprint 1  (wk 1–2)   FOUNDATION
  MO-1 motion tokens · VS-1 theme extensions · WM-1 map safety-net tests
  RE-1 atomic rewards · CO-4 CI pipeline
  Gate: tokens exist, CI green, map goldens recorded

Sprint 2  (wk 3–4)   FEEL + MODEL
  MO-2 transitions · MO-3 juice pass · WM-2 map view model
  VS-2 colour burn-down starts · WM-7 art bible + Word Woods starts (art track)
  Gate: every screen navigates through shared transitions; map logic is pure

Sprint 3  (wk 5–6)   MAP REBUILD I
  WM-3 split monolith · WM-4 responsive shell · MO-5 ambient cull
  RE-2 recommendations · art track continues
  Gate: three-region map shell on all form factors, old monolith deleted

Sprint 4  (wk 7–8)   MAP REBUILD II + INTERACTIONS I
  WM-5 zone states · WM-6 travel choreography · WM-9 retire legacy
  IN-1 interaction framework · WM-8 zone assets roll out (art track)
  Gate: 7 zone states golden-tested both themes; CO-8 playtest #1

Sprint 5  (wk 9–10)  INTERACTIONS II + REWARD LOOP
  IN-2..5 four interaction types · MO-4 reward reveal · RE-3 world change · RE-4 near-miss
  Gate: a full quest uses ≥2 non-MCQ interactions and ends in the new reveal

Sprint 6  (wk 11–12) COMPLETION
  IN-6 generator wiring · IN-7 session pacing · CO-1 dead ends · CO-2 evidence matrix
  VS-3/VS-4/VS-5 component kit + dark + text scale finish
  Gate: zero reachable placeholders; colour inventory = 0 on critical screens

Sprint 7  (wk 13–14) HARDEN + SHIP
  CO-3 parent insight · CO-5 accessibility pass · CO-6 claims · CO-7 runbook
  MO-6 motion/perf proof · CO-8 playtest #2 · release candidate → deploy
```

### Milestone demos (keep motivation honest)

- **End of Sprint 3:** new map shell demo video, phone + desktop, light + dark.
- **End of Sprint 5:** one complete "game loop" capture — map → recommended quest → drag interactions → reward reveal → visible world change.
- **End of Sprint 7:** release candidate on playbrightbound.matthurley.dev.

---

## 6. Definition of done (v2.1 ships when…)

1. A new player's first 10 minutes contain zero placeholder screens and at least three non-MCQ interactions.
2. The map meets the audit's acceptance criteria: no overlap at the six target viewports, 200% text usable, all 7 zone states golden-tested in both themes, frame budgets met on low-end web/Android.
3. All motion flows through motion tokens; reduced-motion collapses to fades; no undocumented looping animation.
4. Zero hard-coded semantic colours on critical journeys; dark mode is a designed composition.
5. Rewards are atomic and idempotent; every quest completion visibly changes character or world state.
6. Recommendations cite real session evidence ("You missed fractions twice — let's review").
7. Clean checkout: `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`, `flutter build web --release` all pass in CI.
8. Both playtest rounds completed with findings triaged.
9. Docs updated: README, NEXT_STEPS, this plan marked complete; historical phase docs untouched but clearly historical.

---

## 7. How to run this plan

- **Point a session at a task ID.** Each task is scoped to be a single focused session or a short series ("Implement MO-1 per the execution plan").
- **Order matters early:** Sprint 1 tasks unblock everything; do not start WM-3 before WM-1/WM-2, and do not build interactions (IN-2+) before IN-1.
- **Branch policy:** feature branches off `main` per task ID (`feat/mo-1-motion-tokens`), PR into `main` with CI green. The current `codex/rpg-map-ui-loop` branch should be merged or closed first.
- **Track status in this file** — flip the task tables' status by appending a ✅ and date to the task row. This document supersedes `IMPLEMENTATION_CHECKLIST.md` and the "Now/Next/Later" list in the audit for scheduling purposes.
