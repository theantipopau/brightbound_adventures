# BrightBound Adventures v2.1 - Premium Product Audit & Roadmap

**Audit date:** 19 June 2026  
**Proposed release:** v2.1 "Living World"  
**Status:** implementation-ready product and engineering plan  
**Objective:** turn a broad feature set into one coherent, premium, replayable learning adventure.

## Executive verdict

BrightBound has a strong foundation: a real multi-zone Flutter app, a substantial local learning engine, onboarding and avatar creation, progression systems, parent-facing surfaces, accessibility preferences, a Star Shop, a bespoke isometric map, and useful automated tests.

It is not yet premium-release complete. The main risk is fragmentation. Visual languages, bespoke screens, animation approaches, content completeness, theme behaviour, and documentation claims have accumulated faster than a single product system has been enforced.

v2.1 should be a **cohesion and completion release**, led by a major world-map rebuild:

`map -> purposeful quest -> varied practice -> meaningful reward -> visible world/character change -> trusted next recommendation`

## Audit method

This code/repository audit reviewed routes, themes, the active world map, services, content fallbacks, tests, assets, website, API project, roadmaps, and changelog. It does not replace child usability studies, educator review, physical-device screen-reader checks, production analytics, or measured GPU profiling; those are roadmap deliverables.

## Product health scorecard

| Dimension | Rating | Finding |
|---|---:|---|
| Product concept | 4/5 | Distinctive learning-RPG proposition |
| Feature foundation | 4/5 | Most major systems exist |
| Core-loop cohesion | 2/5 | History, rewards, recommendations, and world change are not yet one loop |
| World map | 2/5 | Ambitious but crowded, monolithic, asset-light, and under-tested |
| Visual consistency | 2/5 | Strong moments; too many independent gradients, shadows, radii, and colours |
| Light/dark parity | 2/5 | Global themes exist; bespoke screens often bypass semantic theme tokens |
| Motion quality | 3/5 | Considerable polish; animation ownership remains fragmented |
| Content completeness | 2/5 | Explicit coming-soon and generator fallback paths remain |
| Accessibility | 3/5 | Good settings foundation; systematic proof is missing |
| Performance | 3/5 | Recent optimisations; no enforced budgets/profiling baseline |
| Automated quality | 3/5 | Healthy baseline; critical map/theme/visual journeys are under-tested |
| Documentation truth | 2/5 | Overlapping "complete" reports obscure current truth |
| Release operations | 2/5 | Deploy configs exist; release, monitoring, and rollback proof need consolidation |

## What is already realised

- Guided splash, onboarding, avatar creation, world entry, and responsive startup tests.
- Eight map destinations with progressive unlocks and animated travel.
- Literacy, numeracy, science, logic, storytelling, motor, mixed, and mini-game surfaces.
- XP, stars, streaks, achievements, daily challenges, bosses, mastery, certificates, cosmetics, and shop.
- Parent dashboard and profile statistics.
- Adaptive difficulty, spaced repetition, question variation/freshness, and local quest-session history.
- Cloudflare Pages, marketing website, and Worker/D1 projects.
- Fredoka, Comfortaa, Noto Emoji, shared game UI, custom painters, and reduced-motion work.
- Unit and widget tests for important learning, progression, shop, viewport, and empty-state behaviour.

## Confirmed gaps

### Reachable incompleteness

The code still contains user-visible "coming soon" or empty-content paths in literacy, numeracy, storytelling, and logic practice. `PlaceholderZoneScreen` remains exported. Audio contains web placeholder behaviour; the AI assistant is a backend scaffold; achievement motion and the literacy audit script retain placeholder markers.

Each gap must be completed, intentionally hidden, or honestly labelled before v2.1. Blanket "feature complete" language is not supported.

### Replayability

Session history and freshness statistics are captured, but the map does not yet transform them into daily, review, challenge, and boss recommendations derived from learner history.

### Rewards

Stars, XP, shop items, outfits, achievements, and mastery exist, but the reward moment is distributed. A shared reward transaction must answer what was earned, why, where it appeared, what is nearly unlocked, and what to play next.

### Parent trust

The parent experience needs weekly trends, weak-skill reasoning, evidence-backed recommendations, session history, and clear local-data explanations.

### Content quality

There is no release-wide evidence matrix proving depth per skill, interaction variety, reading-age fit, explanation quality, repeat distance, and educator approval. Curriculum and NAPLAN claims need maintained evidence.

## Release priorities

### P0 - release blockers

1. Remove, complete, gate, or honestly label every reachable dead end.
2. Pass light, dark, system, high-contrast, and 200% text checks on critical journeys.
3. Add deterministic map widget/golden coverage for phone, tablet, and desktop.
4. Prove every advertised core zone has sufficient valid content and safe fallback behaviour.
5. Verify child-safety, privacy, curriculum, platform, testimonial, and marketing claims.
6. Make clean-checkout format, analyze, test, build, and deploy reproducible.

### P1 - required for "premium"

1. Rebuild the map composition and navigation hierarchy.
2. Establish semantic design tokens and shared components.
3. Add unified quest recommendation and reward-reveal loops.
4. Add authored zone identity assets with an art pipeline.
5. Replace ambient motion noise with meaningful event-driven motion.
6. Complete evidence-based weekly parent insight.
7. Add learning interactions that fit their learning objectives.

### P2 - follow-up

Companions/pets, earned world decorations, responsible seasonal content, teacher tools after trust architecture, and optional family-controlled cloud sync.

## World map audit

### Strengths

- It reads as a game hub, not a generic menu.
- Unlocks, travel, quest panel, player identity, rewards, and progress are represented.
- Custom painters and isometric helpers create a distinct signature without a 3D engine.
- Recent work limits ambient motion for web, compact, short, and reduced-motion layouts.

### Problems

1. `world_map_screen.dart` exceeds five thousand lines and mixes orchestration, responsiveness, HUD, panels, zone UI, pawn, and painters.
2. Player HUD, title, quest board, controls, action dock, zones, particles, clouds, terrain, and rewards compete for attention.
3. Normalised coordinates help, but fixed overlays and breakpoint flags remain collision-prone under text scaling and unusual aspect ratios.
4. Procedural shapes and emoji cannot carry all premium art direction; landmarks, terrain, icons, materials, and rewards need authored consistency.
5. Locked, available, recommended, active, review-needed, boss-ready, and mastered states are not unmistakable.
6. Direct colour constants weaken theme parity.
7. Several controllers/effects exist without one motion hierarchy.
8. No dedicated map test protects the most complex layout.
9. Exported legacy `fantasy_map.dart` is not used by the active route and adds maintenance noise.


## World map v2 specification

### Three-second experience goal

A child should immediately understand who they are, where they are, which quest is recommended, what reward is close, and how to start.

### Responsive composition

Use three explicit regions:

1. **Adventure bar** - player identity, level/XP, stars, streak, settings.
2. **Living board** - zones, routes, avatar, state effects, and contextual labels.
3. **Quest lens** - goal, difficulty, reason, reward preview, and one primary action.

Desktop uses board plus side lens. Tablet portrait uses a collapsible bottom lens. Phone uses a zoomable/scrollable map with a persistent compact quest sheet. Secondary destinations move into an adventure menu instead of a crowded action dock.

### Art direction

- Adopt a storybook-diorama language: painted terrain, tactile board edges, restrained texture, and crisp UI.
- Create an art bible for silhouette, perspective, light direction, outline, texture scale, shadow, saturation, and icon geometry.
- Give every zone one hero landmark, two supporting props, a route treatment, ambient motif, reward set, and light/dark palette.
- Replace emoji as primary world art with authored icons/illustrations; retain them only as supporting/fallback content.
- Use a documented atlas, export, compression, ownership, and decoded-size budget.

### Zone state language

| State | Visual treatment | Motion | Accessible cue |
|---|---|---|---|
| Locked | Desaturated terrain and closed gate | None | Lock + requirement |
| Available | Full colour and landing pad | One entry reveal | "Available" |
| Recommended | Warm beacon and route emphasis | Slow, limited beacon | Reason badge |
| In progress | Route stamps and progress ring | Return reaction | Percentage/count |
| Needs review | Cool review ribbon | One gentle pulse | Review reason |
| Boss ready | Transformed landmark and banner | One-shot fanfare | "Boss ready" |
| Mastered | Gold trim, flag, decoration | One-shot celebration | Mastery seal |

### Motion choreography

- **Idle:** almost static; optional low-frequency cloud/parallax on capable layouts.
- **Selection:** 160-220 ms focus lift and quest-lens transition.
- **Travel:** 700-1,000 ms anticipation, path movement, and settle.
- **Unlock:** route draws once, gate opens, landmark gains colour, reward lands.
- **Mastery:** one authored sequence followed by persistent static world change.
- **Reduced motion:** cross-fades/immediate changes; no orbiting, pulsing, bobbing, or forced camera travel.

### Engineering refactor

```text
world_map/
|- models/       map state, zone state, quest-lens view model
|- services/     recommendation, progression, scene configuration
|- screens/      responsive shell
|- widgets/      adventure bar, viewport, quest lens, node, pawn
|- painters/     terrain, routes, highlights, effects
|- tokens/       metrics, breakpoints, palettes, motion
```

Create a pure `WorldMapViewModel` from avatar, skill progress, session history, daily challenge, and reward state. Painters receive immutable scene data. Avoid provider reads inside low-level scene widgets. Isolate repaint layers and permit no wall-clock reads in paint.

### Map acceptance criteria

- No overlap/clipping at 360x640, 390x844, 768x1024, 1024x768, 1366x768, and 1440x900.
- Primary play action remains usable at 200% text scale.
- Correct light, dark, high-contrast, keyboard, semantics, and reduced-motion rendering.
- All seven zone states have golden coverage in both themes.
- Idle/travel meet agreed frame budgets on low-end web and Android targets.
- No decorative continuous ticker without documented purpose and performance proof.

## Premium visual system

### Semantic tokens

Create theme extensions for semantic colours, zone palettes, radii, shadows, spacing, motion, and typography. Dark mode should use tonal separation rather than simply adding black blur. Zone colours may remain expressive, but readable surfaces and on-colours must be semantic.

### Component kit

Build an adventure scaffold, responsive frame, standard controls, standard/feature/reward/quest/modal surfaces, badges, progress, stat/reward chips, and shared empty/loading/error/interaction states. Deprecate one-off variants after migration.

### Typography and assets

Keep Fredoka for headings/numerals and use Comfortaa selectively. Define minimum sizes, line heights, wrapping, and long-label behaviour; test at 200% text.

Create eight zone landmarks, terrain/board materials, unified zone/quest/reward icons, avatar thumbnails, parent-report art, and event effects. Every asset needs ownership, export sizes, compression, dark proof, semantic treatment, and fallback.

## Light and dark theme programme

`MaterialApp` supplies light/dark themes, but bespoke widgets frequently use direct constants, white/black, gradients, and shadow colours. Global theme setup therefore does not guarantee correct presentation.

Required work:

1. Inventory and classify direct colours.
2. Move semantic UI into theme extensions.
3. Provide light/dark zone palettes and verified on-colours.
4. Remove white-text assumptions and tune elevation separately for dark mode.
5. Ensure high contrast composes with both themes.
6. Test startup, map, quest, results, shop, profile, parent dashboard, and settings.

Acceptance requires WCAG 2.2 AA contrast, visible focus, non-colour feedback, distinguishable disabled states, live system-theme updates, and compatible high-contrast/reduced-motion modes.


## Animation and interaction

Motion must explain state, celebrate effort, or preserve spatial continuity. Allow one dominant animation per moment; make loops exceptional; provide reduced-motion alternatives; and keep touch, pointer, keyboard, and assistive outcomes equivalent.

Prioritise authored sequences for map travel, quest entry, answer feedback, results/rewards, chest/equip, and zone unlock/mastery. Centralise timing and transition primitives.

## Learning and content

### Machine-readable inventory

Track curriculum code/year band, generator/static source, prompt templates, interaction types, difficulty, hint/explanation coverage, validation, repeat distance, and educator approval per skill.

### Content release gates

- No advertised skill reaches a coming-soon screen.
- Correct answers are unambiguous and options unique.
- Explanations teach a concept or strategy.
- Reading level/instruction length fit the intended age.
- Core skills support several sessions without obvious repeats.
- Error/empty states recover without inventing progress.
- Curriculum claims link to maintained evidence.

### Interaction variety

Prioritise number lines, visual fractions, clock/money manipulation, sentence completion, tap-the-evidence comprehension, story ordering, vocabulary matching, science classification, patterns/spatial rotation, and forgiving typed answers. Build one polished reusable framework before multiplying content.

## Replayability, rewards, and progression

### Recommendation service

Generate explainable quests from session history:

- **Continue:** recent momentum.
- **Review:** weak concept due for repetition.
- **Challenge:** strong skill at higher difficulty.
- **Daily:** rotating cross-zone goal.
- **Boss:** mastery check after prerequisites.

Each returns a reason, goal, duration, interaction mix, reward preview, and source evidence. The same model powers map and parent views.

### Atomic rewards

Create one idempotent reward transaction: base/bonus stars, XP/level delta, streak/daily progress, achievements, mastery, cosmetic/chest drops, and next-unlock proximity. Persist first, then animate confirmed results. Revisiting results must never duplicate rewards.

Document earning rates, prices, unlock cadence, duplicate protection, and time-to-reward. Reward early without manipulative scarcity.

## Parent, teacher, privacy, and trust

v2.1 parent scope:

- Seven/thirty-day summaries.
- Improving and review-due skills with evidence.
- Session history: duration, activity, hints, accuracy, freshness.
- Simple local goals and celebration suggestions.
- Plain-language storage/online-service explanation.
- Export only after metrics are trustworthy.

Teacher models/services exist, but classroom tools should not be marketed complete before consent, ownership, roster lifecycle, deletion/export, offline conflicts, recovery, and security are designed and tested.

Audit aggregate ratings, testimonials, counts, platform availability, "free forever," curriculum alignment, and tracking claims. Support, qualify, or remove them.

## Accessibility

- Complete keyboard journeys and predictable focus restoration.
- Label custom-painted zones, progress, locks, and rewards semantically.
- Test TalkBack, VoiceOver, and browser screen readers on target devices.
- Verify 200% text, landscape, and short-height layouts.
- Offer calm/no-timer alternatives.
- Respect platform accessibility preferences where available.
- Require non-colour feedback and minimum target sizes.

## Performance and reliability

### Budgets

- No artificial startup delay.
- No unnecessary idle-map rebuilds.
- Answer feedback begins within one frame under normal load.
- Images decode near display size and are compressed.
- Track web bundle, fonts, and largest assets per release.
- No unbounded timers, tickers, particles, or post-dispose callbacks.

### Verification suite

- Unit: recommendations, rewards, progression, migrations, content validation.
- Widget: critical screens across theme - viewport - text-scale.
- Golden: map states, components, palettes, reward frames.
- Integration: first run - quest - reward - shop/equip - parent insight.
- Performance: map, answer submit, rewards, shop, avatar creator.
- Web: service-worker update, offline reload, cache migration, API failure fallback.

## Architecture and repository

1. Split map domain, presentation, painters, and shell.
2. Remove/archive unused legacy exports after confirming consumers.
3. Consolidate audio abstractions and document web/native differences.
4. Separate current truth from historical completion reports.
5. Generate audit output in CI; do not treat old logs as evidence.
6. Keep `node_modules` out of repository history.
7. Add dependency, license, secret, and vulnerability checks.
8. Version persistence schemas and test migrations.
9. Define privacy-preserving error reporting.
10. Formalise release, deployment, rollback, and production smoke checks.

## Delivery plan

### Phase 0 - Truth and baseline (1 sprint)

Run clean verification; inventory reachable routes/content; verify claims; capture theme/viewport screenshots; baseline performance/bundle/assets; classify historical docs.

**Exit:** known issues are reproducible, prioritised, owned, and honestly documented.

### Phase 1 - Design system and theme parity (2 sprints)

Ship semantic extensions, zone palettes, shared components, typography/spacing/elevation/motion tokens, critical-screen migration, and theme/text-scale matrices.

**Exit:** new UI needs no hard-coded semantic colour or bespoke control state.

### Phase 2 - World map rebuild (3 sprints)

Ship pure view model, responsive three-region shell, modular layers, zone states, first authored asset family, motion choreography, and visual/semantic/performance tests.

**Exit:** the map is the clearest, most beautiful, and most reliable screen.

### Phase 3 - Quest and reward loop (2 sprints)

Ship explainable recommendations, goals/modifiers, previews, atomic rewards, reveal, shop/equip/collection improvements, and one complete zone reward set.

**Exit:** every quest visibly changes progress, character/world state, and recommendation.

### Phase 4 - Content and interaction completion (3-4 sprints)

Ship inventory/review workflow, no reachable dead ends, CI validation, four reusable non-MCQ interactions, and sufficient reviewed content.

**Exit:** every promoted zone offers complete, varied, age-appropriate sessions.

### Phase 5 - Trust and release hardening (2 sprints)

Ship weekly insight, accessibility device audit, privacy/security/dependency/license/migration review, deployment/rollback runbook, regression/performance/offline/production smoke.

**Exit:** all definition-of-done gates pass.

## Prioritised backlog

### Now

- Record clean verification evidence.
- Add map viewport/theme/state/semantics/golden fixtures.
- Inventory direct colours and reachable content dead ends.
- Produce map art bible and responsive wireframes.
- Prototype Word Woods in complete light/dark direction.

### Next

- Extract the map view model and responsive metrics.
- Implement recommendation contracts and atomic rewards.
- Migrate critical journeys to semantic components.
- Create the first production zone asset family.
- Test the prototype with children/parents before scaling.

### Later

- Complete interaction frameworks/content depth.
- Weekly parent insight.
- Earned world decoration, pets, and responsible seasonal packs.
- Teacher/cloud scope only after trust architecture is ready.

## Definition of done for v2.1

The release is complete only when:

- all advertised routes are complete and recover safely;
- clean-checkout format, analyze, test, and release build pass;
- critical journeys pass phone/tablet/desktop, 200% text, light/dark/high-contrast, reduced-motion, keyboard/touch, and screen-reader checks;
- the map meets visual, responsive, semantic, and performance criteria;
- recommendations use real session evidence and explain why;
- rewards are atomic, idempotent, visible, and connected to avatar/world change;
- content meets depth and educator-review thresholds;
- every marketing/privacy/curriculum claim has evidence;
- bundle, assets, and runtime meet agreed budgets;
- migrations, deployment, production smoke, and rollback are proven;
- documentation describes the shipped product, not intended work.

## Recommended first sprint

1. Add map fixtures and baseline goldens before refactoring.
2. Introduce semantic theme extensions and migrate the map shell/HUD/quest lens.
3. Extract a pure map view model and responsive metrics.
4. Design three-region wireframes and seven zone-state treatments.
5. Generate content/dead-end and direct-colour inventories in CI.
6. Prototype Word Woods with authored light/dark assets.
7. Test with children and parents before scaling the art system.
