"""Generate clay/toy-style isometric zone sprites (v2.1 task A2 + A8 dust puff).

Produces, per the V2_1_3D_VISUAL_DIRECTION.md art bible (top-left light,
soft shadows bottom-right, rounded edges, no outlines, transparent
background, subtle rim light):

  assets/images/zones/<zone_id>/zone_<zone_id>_tile_base.png   (2:1 iso base)
  assets/images/zones/<zone_id>/zone_<zone_id>_landmark.png    (XL hero)
  assets/images/zones/<zone_id>/zone_<zone_id>_path.png        (path segment)
  assets/images/zones/<zone_id>/zone_<zone_id>_accent.png      (accent prop)

plus assets/images/zones/effects/zone_dust_puff_1.png / _2.png for A8.

Sprites are drawn at 4x supersampling and Lanczos-downsampled. All colours
come from the zone hue families in WorldTokens, sun-washed 20% lighter.
Run: python tool/generate_zone_sprites.py
"""
import math
import os

from PIL import Image, ImageDraw, ImageFilter

S = 4  # supersample factor

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'images', 'zones')
EFFECTS = os.path.join(OUT, 'effects')

# zone-id: (primary, secondary) hue family (from WorldTokens, as the badges).
ZONES = {
    'word-woods':         ((0x2D, 0x7D, 0x32), (0x66, 0xBB, 0x6A), (0x8D, 0x6E, 0x63)),
    'number-nebula':      ((0x39, 0x49, 0xAB), (0x7E, 0x57, 0xC2), (0x26, 0xC6, 0xDA)),
    'math-facts':         ((0xE5, 0x39, 0x35), (0xF9, 0xA8, 0x25), (0xBF, 0x8F, 0x30)),
    'story-springs':      ((0x15, 0x65, 0xC0), (0x26, 0xA6, 0x9A), (0x64, 0xB5, 0xF6)),
    'science-explorers':  ((0x00, 0x69, 0x5C), (0x8B, 0xC3, 0x4A), (0x26, 0xA6, 0x9A)),
    'creative-corner':    ((0xE6, 0x51, 0x00), (0xEC, 0x40, 0x7A), (0xFF, 0xB7, 0x4D)),
    'puzzle-peaks':       ((0x6A, 0x1B, 0x9A), (0x90, 0xA4, 0xAE), (0xF9, 0xA8, 0x25)),
    'adventure-arena':    ((0xC6, 0x28, 0x28), (0xF9, 0xA8, 0x25), (0x8D, 0x6E, 0x63)),
}


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def lighten(c, t):
    return lerp(c, (255, 255, 255), t)


def darken(c, t):
    return lerp(c, (20, 14, 24), t)


def wash(c, t=0.20):
    """Sun-washed mid-tone: lifts toward white and slightly warm."""
    r, g, b = lighten(c, t)
    return (min(255, r + 6), min(255, g + 3), b)


def rounded_diamond(d, cx, cy, hw, hh, fill):
    """Chunky 2:1 iso diamond with softened corners (clay edge rule)."""
    d.polygon([
        (cx, cy - hh), (cx + hw, cy), (cx, cy + hh), (cx - hw, cy),
    ], fill=fill)


def glaze(img):
    """Baked soft top-left light: warm screen-lift upper-left, cool shade
    lower-right, subtle blur. Gets called on the final sprite alpha."""
    w, h = img.size
    hi = Image.new('L', (max(w, 8), max(h, 8)), 0)
    hd = ImageDraw.Draw(hi)
    hd.ellipse([w * 0.10, h * 0.06, w * 0.85, h * 0.72], fill=52)
    hi = hi.filter(ImageFilter.GaussianBlur(max(w, h) * 0.10))
    warm = Image.new('RGB', (w, h), (255, 244, 214))
    sh = Image.new('L', (w, h), 0)
    sd = ImageDraw.Draw(sh)
    sd.ellipse([w * 0.30, h * 0.40, w * 1.0, h * 1.05], fill=44)
    sh = sh.filter(ImageFilter.GaussianBlur(max(w, h) * 0.11))
    cool = Image.new('RGB', (w, h), (150, 168, 210))

    rgb = img.convert('RGB')
    rgb = Image.composite(warm, rgb, hi)
    rgb = Image.composite(cool, rgb, sh)
    out = rgb.convert('RGBA')
    out.putalpha(img.split()[3])
    return out


def soft_ellipse_shadow(size_w, size_h, cx, cy, rx, ry, strength=0.35,
                        blur_factor=0.6):
    sh = Image.new('RGBA', (size_w, size_h), (0, 0, 0, 0))
    d = ImageDraw.Draw(sh)
    d.ellipse([cx - rx, cy - ry, cx + rx, cy + ry], fill=(30, 22, 14, 160))
    sh = sh.filter(ImageFilter.GaussianBlur(
        max(1, int(min(rx, ry) / 2 * blur_factor))))
    a = sh.split()[3].point(lambda v: int(v * strength))
    sh.putalpha(a)
    return sh


# ─────────────────────────────────────────────────────────────────────────────
# Tile base — floating iso platform with earthen thickness
# ─────────────────────────────────────────────────────────────────────────────
def make_tile_base(primary):
    W, H = 200 * S, 130 * S
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = W // 2, int(H * 0.42)
    hw, hh = 88 * S, 44 * S
    thick = 16 * S  # visible earthen side — sells the diorama 3D

    # Ground AO shadow.
    img.alpha_composite(soft_ellipse_shadow(W, H, cx, cy + hh + thick * 0.9,
                                            hw * 0.8, hh * 0.8, 0.30))

    # Side/underside (darker, warm clay soil by zone).
    soil = darken(wash(primary, 0.08), 0.45)
    d.polygon([
        (cx - hw, cy), (cx, cy + hh), (cx, cy + hh + thick),
        (cx - hw, cy + thick),
    ], fill=darken(soil, 0.1))
    d.polygon([
        (cx + hw, cy), (cx, cy + hh), (cx, cy + hh + thick),
        (cx + hw, cy + thick),
    ], fill=soil)

    # Top face: sun-washed gradient via per-scanline tint.
    top = wash(primary, 0.30)
    grad = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(grad)
    for y in range(hh * 2):
        t = y / (hh * 2)
        gd.line([(cx - hw, cy - hh + y), (cx + hw, cy - hh + y)],
                fill=lerp(lighten(top, 0.18), darken(top, 0.12), t),
                width=S)
    mask = Image.new('L', (W, H), 0)
    md = ImageDraw.Draw(mask)
    rounded_diamond(md, cx, cy, hw - 2, hh - 1, 255)
    img.paste(grad, (0, 0), mask)

    # Clay rounded rim: light top-left edges, shaded bottom-right.
    rim_top = [(cx, cy - hh), (cx - hw, cy)]
    rim_bot = [(cx, cy + hh), (cx + hw, cy)]
    d.line(rim_top, fill=lighten(top, 0.45), width=2 * S)
    d.line(rim_bot, fill=darken(top, 0.25), width=2 * S)

    return glaze(img)


# ─────────────────────────────────────────────────────────────────────────────
# Landmarks — XL hero per zone (chunky rounded silhouettes)
# ─────────────────────────────────────────────────────────────────────────────
def _plinth(d, c, u, fill):
    """Shared chunky stone plinth every landmark stands on."""
    d.rounded_rectangle([c - 62 * u, 190 * u, c + 62 * u, 230 * u],
                        radius=16 * u, fill=fill)


def make_landmark(zone, primary, secondary, wood):
    W = 256 * S
    H = 256 * S
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    u = S
    c = W // 2

    base_plinth = wash(lighten(primary, 0.5), 0.4)
    stone = wash(lerp(primary, (210, 210, 220), 0.75), 0.10)

    if zone == 'word-woods':
        # Giant storybook tree: trunk + stacked puffy canopy + tiny door.
        dx = primary
        d.rounded_rectangle([c - 11 * u, 108 * u, c + 11 * u, 214 * u],
                            radius=9 * u, fill=wash(dx, 0.12))
        # canopy: three wide ellipses, lit top-left
        for (ew, eh, ey) in ((62, 40, 78), (48, 34, 48), (34, 24, 26)):
            d.ellipse([c - ew * u, (ey - eh / 2) * u, c + ew * u,
                       (ey + eh / 2) * u], fill=wash(dx, 0.30))
        d.ellipse([c - 50 * u, 66 * u, c + 18 * u, 106 * u],
                  fill=lighten(wash(dx, 0.42), 0.10))
        # open book canopy highlight
        d.rounded_rectangle([c - 34 * u, 44 * u, c + 8 * u, 62 * u],
                            radius=6 * u, fill=wash((250, 247, 240), 0.0))
        # treehouse door
        d.rounded_rectangle([c - 7 * u, 152 * u, c + 7 * u, 172 * u],
                            radius=6 * u, fill=darken(wash(dx, 0.05), 0.35))
        # letter toadstool prop
        d.ellipse([c + 40 * u, 196 * u, c + 58 * u, 214 * u],
                  fill=wash((235, 87, 87), 0.18))
        d.rectangle([c + 45 * u, 214 * u, c + 53 * u, 228 * u],
                    fill=wash((245, 241, 235), 0.05))
    elif zone == 'number-nebula':
        # Mini observatory on a crescent hill + ringed planet above.
        hill = wash(lerp(primary, (140, 120, 200), 0.5), 0.16)
        d.polygon([(c - 78 * u, 224 * u), (c + 78 * u, 224 * u),
                   (c + 30 * u, 168 * u), (c - 44 * u, 176 * u)], fill=hill)
        # dome observatory
        d.rounded_rectangle([c - 26 * u, 172 * u, c + 26 * u, 208 * u],
                            radius=8 * u, fill=wash(secondary, 0.14))
        d.pieslice([c - 26 * u, 140 * u, c + 26 * u, 192 * u], 180, 360,
                   fill=wash(secondary, 0.26))
        d.ellipse([c - 44 * u, 42 * u, c - 6 * u, 80 * u],
                  fill=wash((0xFB, 0x8C, 0x00), 0.10))
        d.arc([c - 58 * u, 46 * u, c + 8 * u, 92 * u], 40, 215,
              fill=wash((0xFF, 0xE0, 0x82), 0.05), width=4 * u)
        star = wash((0xFF, 0xD5, 0x4F), 0.0)
        for sx, sy in ((c + 44, 70), (c + 64, 120), (c - 66, 150)):
            d.ellipse([sx * u - 4 * u, sy * u - 4 * u, sx * u + 4 * u,
                       sy * u + 4 * u], fill=star)
    elif zone == 'math-facts':
        # Abacus fortress: bead-rail wall + clock-face door.
        wall = wash(lerp(primary, (200, 150, 90), 0.55), 0.12)
        d.rounded_rectangle([c - 58 * u, 120 * u, c + 58 * u, 224 * u],
                            radius=14 * u, fill=wall)
        d.rounded_rectangle([c - 58 * u, 120 * u, c - 20 * u, 224 * u],
                            radius=14 * u, fill=lighten(wall, 0.15))
        for ry in (148, 182, 214):
            d.line([c - 46 * u, ry * u, c + 46 * u, ry * u],
                   fill=wash((147, 113, 60), 0.05), width=3 * u)
            for bx, col in ((-30, secondary), (-12, wash(secondary, 0.2)),
                            (12, secondary), (30, lighten(secondary, 0.3))):
                d.ellipse([c + bx * u - 7 * u, ry * u - 9 * u,
                           c + bx * u + 7 * u, ry * u + 9 * u], fill=col)
        clock = wash((0xFF, 0xF8, 0xE1), 0.05)
        d.ellipse([c - 16 * u, 124 * u, c + 16 * u, 156 * u], fill=clock)
        d.line([c, 140 * u, c, 132 * u], fill=(60,), width=2 * u)
        d.line([c, 140 * u, c + 7 * u, 140 * u], fill=(60,), width=2 * u)
    elif zone == 'story-springs':
        # Waterfall spring pouring over a floating open-book bridge.
        cliff = wash(lerp(primary, (120, 200, 220), 0.4), 0.15)
        d.rounded_rectangle([c - 60 * u, 150 * u, c + 40 * u, 226 * u],
                            radius=16 * u, fill=cliff)
        # cascade: light-aqua pillar with soft bands
        d.rounded_rectangle([c + 2 * u, 158 * u, c + 30 * u, 224 * u],
                            radius=10 * u, fill=wash((178, 235, 242), 0.05))
        for by in (176, 198):
            d.line([c + 4 * u, by * u, c + 28 * u, by * u],
                   fill=wash((224, 247, 250), 0.02), width=3 * u)
        # open book bridge
        book = wash((0xFF, 0xFA, 0xF0), 0.03)
        d.rounded_rectangle([c - 56 * u, 128 * u, c + 8 * u, 168 * u],
                            radius=10 * u, fill=book)
        d.polygon([(c - 56 * u, 128 * u), (c - 56 * u, 168 * u),
                   (c - 24 * u, 178 * u), (c + 40 * u, 168 * u),
                   (c + 40 * u, 128 * u), (c + 8 * u, 138 * u)], fill=book)
        d.line([c - 24 * u, 140 * u, c - 24 * u, 172 * u],
               fill=(200, 190, 180, 255), width=2 * u)
        # floating story lantern
        d.rounded_rectangle([c + 46 * u, 150 * u, c + 66 * u, 190 * u],
                            radius=10 * u,
                            fill=wash((0xFF, 0xF1, 0x76), 0.08))
    elif zone == 'science-explorers':
        # Greenhouse dome lab with bubbling flask chimney.
        dome = wash(lerp(primary, (170, 220, 200), 0.55), 0.14)
        d.rounded_rectangle([c - 58 * u, 140 * u, c + 58 * u, 224 * u],
                            radius=14 * u, fill=dome)
        d.pieslice([c - 58 * u, 84 * u, c + 58 * u, 200 * u], 180, 360,
                   fill=wash(secondary, 0.22))
        for px in (-40, -12, 16, 44):
            d.line([c + px * u, 112 * u, c + px * u, 200 * u],
                   fill=lighten(dome, 0.25), width=2 * u)
        # flask chimney with bubbles
        d.rounded_rectangle([c - 8 * u, 96 * u, c + 12 * u, 130 * u],
                            radius=4 * u, fill=wash((0x80, 0xCB, 0xC4), 0.05))
        for bx, by, br in ((c - 6, 84, 5), (c + 12, 76, 4), (c + 2, 64, 3)):
            d.ellipse([bx * u - br * u, by * u - br * u, bx * u + br * u,
                       by * u + br * u],
                      fill=wash((0xB2, 0xEB, 0xF2), 0.05))
    elif zone == 'creative-corner':
        # Windmill easel with paintbrush sails + splash pond.
        post = wash(wood, 0.10)
        d.polygon([(c - 12 * u, 226 * u), (c + 12 * u, 226 * u),
                   (c + 6 * u, 120 * u), (c - 6 * u, 120 * u)], fill=post)
        cap = wash(secondary, 0.14)
        d.ellipse([c - 20 * u, 92 * u, c + 20 * u, 132 * u], fill=cap)
        for ang in (20, 110, 200, 290):
            a = math.radians(ang)
            bx, by = c + math.cos(a) * 36, 112 + math.sin(a) * 36
            d.rounded_rectangle(
                [min(c, bx) - 4 * u, min(112, by) - 4 * u,
                 max(c, bx) + 4 * u, max(112, by) + 4 * u],
                radius=4 * u, fill=wash((0xFF, 0xE0, 0x82), 0.10))
        # paint splash pond
        for sx, sy, sr, col in ((c - 44, 218, 9, secondary),
                                (c - 58, 226, 6, (0x26, 0xA6, 0x9A)),
                                (c + 44, 222, 7, (0x5C, 0x6B, 0xC0))):
            d.ellipse([sx * u - sr * u, sy * u - sr * u * 0.6,
                       sx * u + sr * u, sy * u + sr * u * 0.6], fill=col)
    elif zone == 'puzzle-peaks':
        # Mountain of interlocking puzzle-piece strata + gear summit.
        rock = wash(lerp(primary, (150, 160, 175), 0.75), 0.12)
        d.polygon([(c - 70 * u, 224 * u), (c + 70 * u, 224 * u),
                   (c + 18 * u, 120 * u), (c - 8 * u, 128 * u)], fill=rock)
        d.polygon([(c - 8 * u, 128 * u), (c + 18 * u, 120 * u),
                   (c + 6 * u, 88 * u), (c - 12 * u, 96 * u)], fill=lighten(rock, 0.12))
        # keyhole cave door
        d.rounded_rectangle([c - 6 * u, 190 * u, c + 6 * u, 216 * u],
                            radius=4 * u, fill=darken(rock, 0.34))
        d.ellipse([c - 6 * u, 178 * u, c + 6 * u, 192 * u],
                  fill=darken(rock, 0.34))
        # gear summit
        gear = wash(wood, 0.06)
        d.ellipse([c - 10 * u, 66 * u, c + 10 * u, 86 * u], fill=gear)
        for a in range(0, 360, 60):
            ang = math.radians(a)
            gx, gy = c + math.cos(ang) * 13, 76 + math.sin(ang) * 13
            d.rectangle([gx - 2.5 * u, gy - 2.5 * u, gx + 2.5 * u,
                         gy + 2.5 * u], fill=gear)
    elif zone == 'adventure-arena':
        # Colosseum entry with banner rings + torches.
        arena = wash(lerp(primary, (220, 180, 160), 0.55), 0.14)
        d.rounded_rectangle([c - 62 * u, 130 * u, c + 62 * u, 226 * u],
                            radius=18 * u, fill=arena)
        d.rounded_rectangle([c - 40 * u, 158 * u, c + 40 * u, 226 * u],
                            radius=16 * u, fill=darken(arena, 0.25))
        d.rounded_rectangle([c - 16 * u, 172 * u, c + 16 * u, 226 * u],
                            radius=10 * u, fill=wash((0x8D, 0x6E, 0x63), 0.06))
        d.ellipse([c - 14 * u, 160 * u, c + 14 * u, 184 * u],
                  fill=wash((0x8D, 0x6E, 0x63), 0.06))
        # banners (gold/zone accent)
        for bx in (-50, 34):
            d.rounded_rectangle([c + bx * u, 128 * u, c + bx * u + 16 * u,
                                 172 * u], radius=3 * u,
                                fill=wash(secondary, 0.10))
            d.polygon([(c + bx * u, 172 * u), (c + bx * u + 16 * u, 172 * u),
                       (c + bx * u + 8 * u, 184 * u)],
                      fill=wash(secondary, 0.10))
        # torch flames
        for tx in (-62, 54):
            d.rounded_rectangle([c + tx * u, 200 * u, c + tx * u + 10 * u,
                                 222 * u], radius=3 * u,
                                fill=wash((0x59, 0x46, 0x36), 0.04))
            d.ellipse([c + tx * u + 1 * u, 190 * u, c + tx * u + 9 * u,
                       204 * u], fill=wash((0xFF, 0xB7, 0x4D), 0.05))

    _plinth(d, c, u, base_plinth)
    return glaze(img)


# ─────────────────────────────────────────────────────────────────────────────
# Path segment + accent prop
# ─────────────────────────────────────────────────────────────────────────────
def make_path(zone, primary):
    W, H = 120 * S, 70 * S
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = W // 2, int(H * 0.46)
    hw, hh = 48 * S, 24 * S

    img.alpha_composite(soft_ellipse_shadow(W, H, cx, cy + hh, hw * 0.75,
                                            hh * 0.75, 0.28))
    stone = wash(lerp(primary, (214, 208, 200), 0.72), 0.14)
    thick = 7 * S
    for pts in ([(cx - hw, cy), (cx, cy + hh), (cx, cy + hh + thick),
                 (cx - hw, cy + thick)],
                [(cx + hw, cy), (cx, cy + hh), (cx, cy + hh + thick),
                 (cx + hw, cy + thick)]):
        d.polygon(pts, fill=darken(stone, 0.38))

    mask = Image.new('L', (W, H), 0)
    md = ImageDraw.Draw(mask)
    rounded_diamond(md, cx, cy, hw - 2, hh - 1, 255)

    grad = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(grad)
    for y in range(hh * 2):
        t = y / (hh * 2)
        gd.line([(0, cy - hh + y), (W, cy - hh + y)],
                fill=lerp(lighten(stone, 0.2), darken(stone, 0.1), t), width=S)
    img.paste(grad, (0, 0), mask)

    # Zone motif on top face.
    d2 = ImageDraw.Draw(img)
    motif = darken(stone, 0.30)
    if zone == 'word-woods':        # vine dots
        for mx in (cx - 24, cx, cx + 24):
            d2.ellipse([mx * S - 4 * S, cy * S - 2 * S, mx * S + 4 * S,
                        cy * S + 2 * S], fill=motif)
    elif zone == 'number-nebula':   # star dust
        for mx, my in ((cx - 20, cy - 6), (cx + 4, cy + 2), (cx + 22, cy - 4)):
            d2.ellipse([mx * S - 2 * S, my * S - 2 * S, mx * S + 2 * S,
                        my * S + 2 * S],
                       fill=wash((0xFF, 0xD5, 0x4F), 0.05))
    elif zone == 'math-facts':      # gear mark
        d2.ellipse([cx * S - 6 * S, cy * S - 3 * S, cx * S + 6 * S,
                    cy * S + 3 * S], outline=motif, width=2 * S)
    elif zone == 'story-springs':   # lily pad
        d2.ellipse([cx * S - 10 * S, cy * S - 5 * S, cx * S + 10 * S,
                    cy * S + 5 * S], fill=wash((0xA5, 0xD6, 0xA7), 0.08))
    elif zone == 'science-explorers':  # circuit tick
        d2.line([cx * S - 12 * S, cy * S, cx * S + 12 * S, cy * S],
                fill=motif, width=2 * S)
        d2.ellipse([cx * S - 4 * S, cy * S - 4 * S, cx * S + 4 * S,
                    cy * S + 4 * S], fill=motif)
    elif zone == 'creative-corner':  # splatter
        d2.ellipse([cx * S - 8 * S, cy * S - 4 * S, cx * S + 4 * S,
                    cy * S + 4 * S], fill=wash(secondary_hue(zone), 0.05))
    elif zone == 'puzzle-peaks':    # crack
        d2.line([cx * S - 12 * S, cy * S + 2 * S, cx * S - 2 * S, cy * S - 3 * S,
                 cx * S + 10 * S, cy * S + 3 * S], fill=motif, width=2 * S)
    elif zone == 'adventure-arena':  # cobble band
        for mx in (cx - 22, cx - 6, cx + 10):
            d2.ellipse([mx * S - 5 * S, cy * S - 3 * S, mx * S + 5 * S,
                        cy * S + 3 * S], fill=motif)

    d2.line([(cx, cy - hh), (cx - hw, cy)],
            fill=lighten(stone, 0.4), width=2 * S)
    d2.line([(cx, cy + hh), (cx + hw, cy)], fill=darken(stone, 0.24),
            width=2 * S)
    return glaze(img)


def secondary_hue(zone):
    return ZONES[zone][1]


def make_accent(zone, primary, secondary, wood):
    W = 128 * S
    img = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = W // 2
    u = S

    img.alpha_composite(soft_ellipse_shadow(W, W, c, int(W * 0.88),
                                            int(W * 0.22), int(W * 0.08), 0.3))

    if zone == 'word-woods':  # glowing word-sign post
        d.rounded_rectangle([c - 3 * u, int(W * 0.55), c + 3 * u, int(W * 0.88)],
                            radius=3 * u, fill=wash(wood, 0.06))
        d.rounded_rectangle([c - 22 * u, int(W * 0.44), c + 22 * u, int(W * 0.58)],
                            radius=6 * u, fill=wash(wood, 0.12))
        d.rounded_rectangle([c - 14 * u, int(W * 0.48), c + 14 * u, int(W * 0.54)],
                            radius=3 * u,
                            fill=wash((0xFF, 0xF1, 0x76), 0.06))
    elif zone == 'number-nebula':  # floating number crystal
        poly = [(c, int(W * 0.30)), (c + 16 * u, int(W * 0.52)),
                (c, int(W * 0.75)), (c - 16 * u, int(W * 0.52))]
        d.polygon(poly, fill=wash(secondary, 0.16))
        d.polygon([poly[0], poly[3], poly[2]], fill=wash(secondary, 0.30))
        d.line([c, int(W * 0.30), c, int(W * 0.75)],
               fill=lighten(wash(secondary, 0.3), 0.3), width=2 * u)
    elif zone == 'math-facts':  # neon score counter
        d.rounded_rectangle([c - 24 * u, int(W * 0.38), c + 24 * u, int(W * 0.64)],
                            radius=10 * u, fill=wash(secondary, 0.08))
        d.rounded_rectangle([c - 18 * u, int(W * 0.43), c + 18 * u, int(W * 0.59)],
                            radius=6 * u, fill=(0x10, 0x08, 0x18, 255))
        for seg_x in (c - 12, c - 2, c + 8):
            d.rounded_rectangle([seg_x * u, int(W * 0.48), seg_x * u + 4 * u,
                                 int(W * 0.54)], radius=1 * u,
                                fill=(0x64, 0xFF, 0xDA, 255))
    elif zone == 'story-springs':  # floating story lantern
        d.rounded_rectangle([c - 14 * u, int(W * 0.34), c + 14 * u, int(W * 0.66)],
                            radius=12 * u, fill=wash((0xFF, 0xF1, 0x76), 0.10))
        d.ellipse([c - 8 * u, int(W * 0.44), c + 8 * u, int(W * 0.58)],
                  fill=wash((0xFF, 0xFF, 0xFF), 0.28))
    elif zone == 'science-explorers':  # floating atom cluster
        for a in (0, 60, 120):
            ang = math.radians(a)
            rx, ry = 26 * u, 9 * u
            d.ellipse([c - rx, int(W * 0.5) - ry, c + rx, int(W * 0.5) + ry],
                      outline=wash(secondary, 0.08), width=3 * u)
            d.ellipse([int(W * 0.5) + rx - 3 * u, int(W * 0.5) - ry,
                       int(W * 0.5) + rx + 3 * u, int(W * 0.5) + ry],
                      fill=wash(secondary, 0.25))
        d.ellipse([c - 6 * u, int(W * 0.5) - 6 * u, c + 6 * u, int(W * 0.5) + 6 * u],
                  fill=wash(primary, 0.18))
    elif zone == 'creative-corner':  # floating colour bubble
        d.ellipse([c - 20 * u, int(W * 0.32), c + 20 * u, int(W * 0.72) + 8 * u],
                  fill=wash(secondary, 0.12))
        d.ellipse([c - 7 * u, int(W * 0.38), c + 1 * u, int(W * 0.50)],
                  fill=wash((0xFF, 0xFF, 0xFF), 0.45))
    elif zone == 'puzzle-peaks':  # hovering puzzle piece
        d.rounded_rectangle([c - 16 * u, int(W * 0.38), c + 16 * u, int(W * 0.70)],
                            radius=8 * u, fill=wash(secondary, 0.18))
        d.ellipse([c - 8 * u - 6 * u, int(W * 0.38) - 6 * u, c - 8 * u + 6 * u,
                   int(W * 0.38) + 6 * u], fill=wash(secondary, 0.18))
        d.rectangle([c + 10 * u, int(W * 0.5), c + 22 * u, int(W * 0.56)],
                    fill=wash(secondary, 0.18))
    elif zone == 'adventure-arena':  # floating trophy cup
        d.ellipse([c - 14 * u, int(W * 0.36), c + 14 * u, int(W * 0.60)],
                  fill=wash((0xFF, 0xD5, 0x4F), 0.10))
        d.rectangle([c - 4 * u, int(W * 0.60), c + 4 * u, int(W * 0.70)],
                    fill=wash((0xFF, 0xD5, 0x4F), 0.14))
        d.rounded_rectangle([c - 10 * u, int(W * 0.70), c + 10 * u, int(W * 0.80)],
                            radius=3 * u, fill=wash(secondary, 0.12))

    return glaze(img)


def make_dust_puff(frame):
    """A8 landing dust: 2-frame, small, transparent, clay-coloured."""
    W = 48 * S
    img = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    spec = ((14, 6, 3), (22, 9, 5))[frame - 1]
    col = (198, 178, 148, 190)
    for _ in range(spec[2]):
        rx, ry = (6, 4) if frame == 1 else (4, 3)
        d.ellipse([W / 2 - spec[0] * S / 2, W / 2 - spec[1] * S / 2,
                   W / 2 + spec[0] * S / 2, W / 2 + spec[1] * S / 2],
                  fill=col)
    img = img.filter(ImageFilter.GaussianBlur(2 * S))
    return img


def main():
    os.makedirs(EFFECTS, exist_ok=True)
    for zone, (primary, secondary, wood) in ZONES.items():
        zdir = os.path.join(OUT, zone)
        os.makedirs(zdir, exist_ok=True)
        make_tile_base(primary).save(os.path.join(
            zdir, f'zone_{zone}_tile_base.png'))
        make_landmark(zone, primary, secondary, wood).save(os.path.join(
            zdir, f'zone_{zone}_landmark.png'))
        make_path(zone, primary).save(os.path.join(zdir,
                                                   f'zone_{zone}_path.png'))
        make_accent(zone, primary, secondary, wood).save(os.path.join(
            zdir, f'zone_{zone}_accent.png'))
        print(f'{zone}: 4 sprites')
    make_dust_puff(1).save(os.path.join(EFFECTS, 'zone_dust_puff_1.png'))
    make_dust_puff(2).save(os.path.join(EFFECTS, 'zone_dust_puff_2.png'))
    print('effects: 2 dust puff frames')


if __name__ == '__main__':
    main()
