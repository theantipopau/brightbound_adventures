# v2.1 — 3D & Game-Visual Direction Spec

**Created:** 20 July 2026
**Audience:** an implementing agent (Claude Code / Codex session) with no prior context. Read this top to bottom before touching code.
**Parent plan:** [V2_1_RELEASE_EXECUTION_PLAN.md](V2_1_RELEASE_EXECUTION_PLAN.md) — this spec details tasks **WM-7 / WM-8** (art) and adds a new **A3D** task series (3D rendering upgrades).
**Goal:** make BrightBound *look and feel* like a 3D children's game — a tactile, storybook board-game diorama — without adopting a runtime 3D engine.

---

## 1. Strategic decision: pre-rendered 2.5D, not a 3D engine

**Decision: stay in Flutter, render "3D" through pre-rendered isometric sprite assets + layered 2.5D techniques.** Do not introduce Unity/Godot/three.js/Flame-3D.

Why:

1. **The hard part already exists.** `lib/core/utils/isometric_engine.dart` provides `IsometricPosition` (x, y, z grid coords), grid→screen projection, depth sorting, an animated `IsometricMovementController`, and A* pathfinding. `lib/core/utils/world_map_isometric_helper.dart` binds it to the map (10×10 grid, 100×50 px tiles, 2:1 dimetric projection). This is exactly the architecture Clash of Clans-era isometric games use.
2. **Pre-rendered beats realtime for this product.** Target devices include low-end school tablets and the web build. Pre-rendered sprites give AAA-looking lighting/materials at zero runtime GPU cost.
3. **The existing props prove the style works.** `assets/images/` already contains 13 pre-rendered, 3D-looking props (chest, crystals, potion, gold pile, scroll…) with soft shading and transparent backgrounds. The whole world should look like it belongs with those props. **They are the style seed — every new asset must sit convincingly next to `chest_closed.PNG`.**
4. **Offline-first and bundle-size constraints** favour a curated sprite atlas over engine payloads.

The illusion of 3D comes from five stacked techniques, all specified below: (a) isometric projection with depth sorting, (b) pre-rendered volumetric sprites, (c) elevation + drop shadows, (d) parallax camera layers, (e) light/perspective motion tricks (hover lift, hop arcs, matrix tilts).

---

## 2. The visual target: "Storybook Board-Game Diorama"

A child looks at the map and sees a **hand-crafted toy world on a table**: floating island zones with visible thickness, chunky landmarks with real volume, a little character pawn that hops between them, soft afternoon light from the top-left, and gentle depth haze toward the back.

### Reference pillars (for whoever generates/authors assets)

- **World structure:** *Mario Party* boards / *Fall Guys* menus — chunky, readable islands and paths.
- **Material feel:** *Clay/toy render* — soft plastic & clay materials, rounded edges, subtle subsurface warmth. NOT flat vector, NOT realistic PBR.
- **Charm details:** *Animal Crossing* — slightly oversized props, friendly proportions (door bigger than physics allows, trees like lollipops).
- **Colour:** saturated but sun-washed; every zone owns a hue family (see §5.4).

### Non-negotiable style rules

| Rule | Value |
|---|---|
| Projection | 2:1 dimetric ("isometric"), matching the engine: `screenX=(gx-gy)*50`, `screenY=(gx+gy)*25 - gz*50` |
| Light direction | **Top-left, ~45° elevation** in every single asset. Shadows fall bottom-right |
| Outline | None (no cartoon stroke). Form reads through shading + rim light on the top-left edge |
| Edges | Everything rounded/bevelled. No hard 90° corner anywhere |
| Silhouette | Each landmark identifiable as a black silhouette at 64 px |
| Ground contact | Every object gets a soft ambient-occlusion ellipse where it meets the ground (baked for static parts, runtime for movers) |
| Islands | Zones are **floating diorama islands** with visible earthen thickness/underside — this alone sells 3D |
| Saturation | 60–85% saturation mid-tones; avoid pure #FFF or #000 in albedo |

---

## 3. World geometry & camera rules (runtime)

These bind art and code together. Constants live in `world_map_isometric_helper.dart` (extend, don't fork).

- **Tile:** 100×50 logical px (2:1). Grid 10×10. Zone elevation via `gridZ` (each z-step = 50 px lift). Give back-row zones `z=0` and select feature zones `z=1` so the board reads as terraced.
- **Depth sort:** render order = `(gridX + gridY)` ascending, then `gridZ`. Already implemented — all new scene layers must respect it. The pawn sorts with props (it can walk *behind* a landmark).
- **Camera:** the board becomes a pannable/zoomable surface (phone especially). Use `InteractiveViewer` (constrained: minScale 0.8, maxScale 1.6) or a custom transform layer. All screen-position math must flow through one camera transform — never bake pan offsets into widgets.
- **Parallax:** 3 depth bands moving at different rates under camera pan: sky/haze ×0.2, mid clouds ×0.5, board ×1.0. Subtle (max ~12 px drift); disabled under reduced motion.
- **Depth haze:** zones with higher `(gx+gy)` (further back) get a very subtle cool overlay (`Color.lerp` toward theme haze colour, max 8% at the back row). Cheap and dramatically deepens the scene.

---

## 4. Asset pipeline (how to produce every image)

### 4.1 Production route

Two acceptable routes — both must hit the same export spec:

**Route A — AI generation (fastest, recommended to start).** Generate with an image model, then clean up (background removal, edge cleanup, palette nudge). Use this master prompt template and *keep it in the repo* as `assets/art/PROMPTS.md`, appending the exact prompt used per asset:

```text
isometric game asset, [SUBJECT], 3D render in soft clay/toy style,
2:1 isometric angle (30 degree dimetric), single object centered,
lit from top-left 45 degrees, soft shadows and ambient occlusion,
rounded chunky child-friendly proportions, vibrant [ZONE HUE] palette,
matte plastic and clay materials, subtle top-left rim light,
plain flat background for removal, no text, no watermark, no ground beyond
a small circular base
```

Consistency tricks: generate each zone's full family (landmark + props) in one session/seed; always state the light direction; reject any output whose light or angle deviates — regeneration is cheaper than inconsistency.

**Route B — Blender (highest quality, for hero assets later).** One shared `.blend` scene checked into `assets/art/`: camera at true dimetric (rotation X 60°, Z 45°, orthographic), sun key light top-left 45° + soft fill, Filmic/AgX view transform, transparent film. Render at 2× export size, downscale. All landmarks rendered from this one scene so lighting never drifts.

### 4.2 Export specification

| Property | Spec |
|---|---|
| Format | PNG-32 with alpha (source), optionally compressed to WebP lossless at build if pipeline added later |
| Padding | ≥12 px transparent padding on all sides (for glow/hover effects) |
| Resolution tiers | Author at 2× and place under `assets/images/map/2.0x/…`; provide 1× base via downscale. Flutter's resolution-aware asset loading handles selection |
| Colour | sRGB, no embedded colour profile weirdness |
| Background | Fully transparent, alpha edges anti-aliased (no white fringing — check on dark background) |
| Anchor | Every asset's **logical anchor is bottom-centre of its ground-contact point**, recorded in the manifest (§4.4). This is where the sprite meets its iso tile |

**Size classes (1× logical px):**

| Class | Canvas | Used for |
|---|---|---|
| XL | 512×512 | Zone hero landmarks |
| L | 256×256 | Supporting props, island bases |
| M | 128×128 | Small props, rewards, route decorations, pawn frames |
| S | 64×64 | Icons, route stamps, particles |

### 4.3 Directory & naming convention

```text
assets/images/map/
  islands/        island_{zone_id}.png          # floating base with thickness
  landmarks/      landmark_{zone_id}.png        # hero building/feature
  landmarks/      landmark_{zone_id}_boss.png   # boss-ready transformed variant (P2)
  props/          prop_{zone_id}_{name}.png     # 2+ per zone
  routes/         route_node.png, route_stamp.png, gate_closed.png, gate_open.png
  pawn/           pawn_{direction}_{frame}.png  # see §6.3
  effects/        fx_{name}_{frame}.png         # sparkle, unlock burst, mastery flag
  sky/            haze_gradient.png, cloud_{1..3}.png
assets/art/
  PROMPTS.md      # exact generation prompts per asset (append-only)
  brightbound_iso.blend  # if/when Route B starts
```

`zone_id` values (from the codebase): `word_woods`, `number_nebula`, `math_facts`, `story_springs`, `science_explorers`, `creative_corner`, `puzzle_peaks`, `adventure_arena`.

### 4.4 Asset manifest (required)

Create `assets/map_manifest.json` + a typed loader (`lib/features/world_map/services/map_asset_manifest.dart`):

```json
{
  "landmark_word_woods": {
    "path": "assets/images/map/landmarks/landmark_word_woods.png",
    "sizeClass": "XL",
    "anchor": [0.5, 0.92],
    "footprintTiles": 2,
    "hasDarkVariant": false
  }
}
```

`anchor` is the fractional (x, y) of the ground-contact point. The renderer positions sprites by anchor on the iso tile — never by top-left. Missing assets must resolve to the current procedural/emoji rendering as fallback (never a broken image).

### 4.5 Per-asset QA checklist (gate before commit)

- [ ] Light from top-left; shadow mass bottom-right
- [ ] Reads as a silhouette at 64 px
- [ ] No white/dark alpha fringing on both light and dark backgrounds
- [ ] Sits convincingly next to `chest_closed.PNG` (style match)
- [ ] Decoded size ≤ 4× its largest on-screen display size
- [ ] Anchor recorded in manifest; renders on its tile without floating/sinking
- [ ] Looks correct in dark theme (see §5.5)

### 4.6 Budgets

- Total new map imagery ≤ **6 MB** compressed for all 8 zones (≈ 60 assets). Track per-release in CI.
- Any single asset > 300 KB needs justification in the PR.
- Decode near display size: use `Image(cacheWidth: …)`/`ResizeImage` for anything shown below its native size.

---

## 5. The art bible (per-zone content to produce)

### 5.1 Global set (build FIRST — everything depends on it)

| Asset | Class | Notes |
|---|---|---|
| Island base ×3 shapes | L | Rounded iso platforms with visible earth/rock underside ~30 px thick, grass/sand/rock top variants. Zones tint them |
| Route node / stamp | S | Footprint-style path markers laid along A* routes |
| Gate closed / open | M | Locked-zone gate. Opening is the unlock moment |
| Cloud ×3 | L | Soft volumetric puffs for parallax band |
| Haze gradient | — | Vertical sky gradient, light + dark variants |
| Mastery flag | M | Planted on mastered zones (one-shot animation, then static) |
| Sparkle/unlock burst frames | S ×6 | Effect sheet |

### 5.2 Pawn (the player token) — see §6.3 for animation spec

### 5.3 Per-zone family (8 zones × the same recipe)

Each zone gets: **1 island tint + 1 hero landmark (XL) + 2 props (L/M) + route treatment recolour**. Landmark concepts (Matt may swap any concept; keep the material/silhouette rules):

| Zone | Hue family | Hero landmark | Props |
|---|---|---|---|
| Word Woods | Leaf green / warm bark | Giant storybook tree — open book canopy, treehouse library door | Letter toadstools; hanging alphabet lanterns |
| Number Nebula | Deep violet / star gold | Mini observatory on a crescent hill, ringed planet overhead | Counting-star cluster; telescope |
| Math Facts | Sunny orange / brass | Abacus fortress — bead-rail walls, clock-face door | Giant dice; stacked number blocks |
| Story Springs | Aqua / sunset pink | Waterfall spring pouring over a floating open book bridge | Campfire story circle; quill-and-ink rock |
| Science Explorers | Teal / lime | Greenhouse dome lab with bubbling flask chimney | Mini volcano; magnifying-glass flower |
| Creative Corner | Magenta / rainbow accents | Windmill with paintbrush sails, paint-splash pond | Giant crayon fence; easel signpost |
| Puzzle Peaks | Cool blue / slate | Mountain of interlocking puzzle-piece strata, gear summit | Rolling gear boulder; keyhole cave door |
| Adventure Arena | Crimson / gold | Round banner-ringed colosseum with torch gates | Trophy plinth; crossed foam-sword rack |

### 5.4 Zone palettes

For each zone define in code (theme extension, task VS-1): `primary`, `secondary`, `glow`, `routeColor`, each with light and dark values. Landmark albedo lives in the asset; *UI around it* (labels, lens, badges) uses these tokens.

### 5.5 Dark theme treatment

Do **not** author 8 duplicate night assets initially. Runtime treatment: scene haze shifts to dusk blue, saturation −10% via a `ColorFilter` matrix on the board layer, and each landmark gets a small pre-authored **emissive overlay** (`landmark_{zone}_glow.png`, windows/lanterns lit) composited additively in dark mode. This gives a magical nighttime world for one extra S/M asset per zone.

### 5.6 Zone-state visual treatments (runtime, no extra art needed beyond gate/flag)

| State | Treatment (applied to authored sprites) |
|---|---|
| Locked | Greyscale ColorFilter ~70% + gate sprite in front + no glow overlay |
| Available | Full colour, AO shadow, landing pad ring |
| Recommended | Warm beacon glow (radial gradient behind landmark) + route emphasis, slow 3 s pulse (static under reduced motion) |
| In progress | Route stamps along the path + progress ring on the island edge |
| Needs review | Cool ribbon banner overlay on landmark |
| Boss ready | Banner + torch glow (later: `_boss` landmark variant) |
| Mastered | Gold trim tint pass + mastery flag planted + subtle sparkle on entry only |

---

## 6. Runtime rendering upgrades (the A3D task series)

These are code tasks. They make the world *feel* 3D and are worth doing **before** assets arrive (they work with procedural art too) — they slot into the execution plan after WM-3 (map split).

### A3D-1 — Scene layer stack (S, after WM-3)

Rebuild the board as explicit layers, each in its own `RepaintBoundary`:

```text
1 SkyLayer        haze gradient + parallax clouds       (×0.2 / ×0.5 pan rate)
2 BoardLayer      island bases + terrain painter        (×1.0)
3 RouteLayer      paths, stamps, gates                  (×1.0)
4 SceneLayer      depth-sorted: landmarks, props, PAWN  (×1.0, single sorted list)
5 EffectsLayer    one-shot celebrations only
6 HudLayer        adventure bar / quest lens (screen-space, never pans)
```

Rule: the pawn and props live in ONE sorted list (`gx+gy` then `gz`) so the pawn passes behind/in front of scenery correctly. No wall-clock reads inside `paint()`.

### A3D-2 — `IsoSprite` widget (S, with A3D-1)

One widget renders every manifest asset: takes manifest id + grid position, resolves screen position via the helper, applies anchor, elevation offset (`z * 50`), scale-by-zoom, optional state ColorFilter, and an AO shadow ellipse beneath (width ≈ 0.7 × sprite width, alpha 0.25, blurred). Falls back to the current procedural/emoji node when the asset is missing.

### A3D-3 — Elevation & hover physics (S)

- Zones lift **+6 px with shadow growing softer/larger** on hover/focus (the shadow separating from the object is what sells the lift). 180 ms, motion tokens.
- Selected zone: +10 px lift + glow. Everything eases back on blur.
- Reduced motion: swap lift for a highlight ring, no translation.

### A3D-4 — Pawn v2 (M)

Replace the emoji `RpgCharacter` on the map with a sprite pawn:

- **Frames:** 4 directions (S, N, E; W = mirrored E) × walk 4 frames + idle 2 frames + hop 3 frames, 128 px class M. (Generate via Route A as a consistent character turnaround, or render from one model via Route B.)
- **Travel:** existing `IsometricMovementController` drives position along the A* path; add a **hop arc** (parabolic `z` offset, squash 0.9× on landing) per tile step, footstep dust puff (S sprite, 3 frames) on landing.
- **Shadow:** runtime ellipse that shrinks/lightens at hop apex — the single most effective 3D cue on a moving object.
- Idle: 2-frame breathe at 0.5 Hz; static frame under reduced motion.

### A3D-5 — Camera & parallax (M)

Pannable/zoomable board per §3, parallax bands, depth haze. Travel moments auto-pan the camera to keep the pawn in the middle third (700–1000 ms, motion tokens; instant under reduced motion).

### A3D-6 — Perspective tilt for cards & panels (S, app-wide)

The signature "2.5D UI" trick for non-map screens (quest cards, shop items, results):

```dart
Transform(
  alignment: FractionalOffset.center,
  transform: Matrix4.identity()
    ..setEntry(3, 2, 0.0012)          // perspective
    ..rotateX(tiltY) ..rotateY(tiltX), // ≤ 0.05 rad, from hover/press position
  child: card,
)
```

Wrap as `TiltCard` in the component kit (VS-3): pointer-follow tilt on desktop/web, press-tilt on touch, plus a moving specular highlight (translated radial gradient). Cap tilt ≤ 3°, 150 ms ease-out, disabled under reduced motion. Apply to: shop item cards, zone detail header, reward chest reveal, achievement cards.

### A3D-7 — Procedural 3D upgrade of current painters (S, do IMMEDIATELY — no assets needed)

Until authored art lands, upgrade `lib/ui/painters/terrain_painter.dart` from flat rhombus+glow to **extruded iso platforms**: top face (light), left face (−25% lightness), right face (−40% lightness), 24 px extrusion, rounded corners via path arcs, soft AO ellipse below the floating island, and a slightly darker rim inset on the top face. Same treatment for path nodes. This is ~1 day of pure painter code and makes the map read 3D instantly.

### A3D-8 — Golden + perf coverage for the scene (S, with WM-5)

Goldens: one composed scene per theme per breakpoint with manifest assets present AND with fallbacks (asset-missing mode). Perf: idle map ≤ 2% CPU repaint activity (RepaintBoundary check via timeline), travel ≥ 55 fps on the low-end web profile.

---

## 7. Implementation order for the assigned agent

Work top to bottom; each step is committable alone:

1. **A3D-7** procedural extrusion upgrade (instant visual win, zero asset dependency)
2. **A3D-1 + A3D-2** layer stack + `IsoSprite` + manifest loader with fallbacks (do during/after WM-3 split)
3. **A3D-3** hover/elevation physics
4. **Global asset set** (§5.1) produced via Route A → wire islands/routes/gates through `IsoSprite`
5. **Word Woods family** (§5.3) end-to-end — the template zone; get Matt's sign-off on style BEFORE producing other zones
6. **A3D-4** pawn v2 · **A3D-5** camera/parallax
7. **Remaining 7 zone families**, one PR per zone, QA checklist per asset
8. **§5.5 dark treatment + §5.6 state treatments** wired to zone states (WM-5)
9. **A3D-6** TiltCard rollout to shop/results/zone-detail
10. **A3D-8** goldens + perf proof

**Decision gates for Matt:** (a) approve the Word Woods family before step 7; (b) approve landmark concepts table §5.3 (swap any concept now, not after generation); (c) choose Route A vs B per asset class.

---

## 8. Do / Don't

**Do:** keep one light direction everywhere · anchor every sprite at its ground contact · pair every lift with a shadow change · make celebrations one-shot · ship fallbacks for every asset · run every new visual under dark + reduced-motion before commit.

**Don't:** add a 3D engine or WebGL dependency · mix outlined and non-outlined art · use emoji as primary world art (fallback only) · animate anything continuously without a documented reason · hard-code colours (use VS-1 tokens) · bake pan/zoom offsets outside the camera transform · exceed the 6 MB map-imagery budget.

---

## 9. Definition of done for this spec

- Map renders authored islands, landmarks, props, routes, gates, and pawn through the manifest + `IsoSprite`, with working fallbacks.
- All 8 zones have complete families passing the §4.5 checklist; dark emissive overlays wired.
- Pawn travels with hop arcs, dynamic shadow, and camera follow.
- Hover lift, TiltCard, parallax, and depth haze live and reduced-motion-safe.
- Goldens cover composed scenes (both themes, three breakpoints, asset + fallback modes); perf budgets recorded.
- `PROMPTS.md` documents how every asset was made; the manifest is the single source of truth for placement.
