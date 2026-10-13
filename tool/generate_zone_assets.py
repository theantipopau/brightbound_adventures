"""Generate BrightBound zone badges + wordmark (2026-10-10 art pass).

Procedurally draws, at 4x supersampling and downsamples with Lanczos:
  * assets/images/zones/<zone-id>.png  - circular zone badge, radial zone
    gradient, gloss, ring, and a white emblem silhouette (mask-based so
    emblems can have true cut-outs).
  * assets/images/wordmark.png         - "BrightBound ADVENTURES" wordmark in
    the app's bundled Fredoka/Comfortaa fonts, white with navy stroke.

Colors mirror WorldTokens in lib/ui/themes/app_theme.dart exactly.
Run:  python tool/generate_zone_assets.py
"""
import math
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

S = 4                      # supersample factor
BADGE = 256 * S            # badge diameter on the supersampled canvas
CANVAS = BADGE + 32 * S    # room for the drop shadow

OUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'images')
ZONE_DIR = os.path.join(OUT_DIR, 'zones')
FONTS = os.path.join(os.path.dirname(__file__), '..', 'assets', 'fonts')

# zone-id: (primary, secondary) from WorldTokens.
ZONES = {
    'word-woods':         ((0x2D, 0x7D, 0x32), (0x1B, 0x5E, 0x20)),
    'number-nebula':      ((0x39, 0x49, 0xAB), (0x1A, 0x23, 0x7E)),
    'math-facts':         ((0xE5, 0x39, 0x35), (0xB7, 0x1C, 0x1C)),
    'story-springs':      ((0x15, 0x65, 0xC0), (0x0D, 0x47, 0xA1)),
    'science-explorers':  ((0x00, 0x69, 0x5C), (0x00, 0x4D, 0x40)),
    'creative-corner':    ((0xE6, 0x51, 0x00), (0xBF, 0x36, 0x0C)),
    'puzzle-peaks':       ((0x6A, 0x1B, 0x9A), (0x4A, 0x14, 0x8C)),
    'adventure-arena':    ((0xF9, 0xA8, 0x25), (0xF5, 0x7F, 0x17)),
}


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def badge_gradient(primary, secondary):
    """Vertical gradient with a soft radial lift toward the top center."""
    base = Image.new('RGB', (BADGE, BADGE))
    d = ImageDraw.Draw(base)
    for y in range(BADGE):
        t = y / (BADGE - 1)
        d.line([(0, y), (BADGE, y)], fill=lerp(primary, secondary, t ** 1.15))

    # Small radial highlight, built at 48px and upscaled (cheap + smooth).
    hi = Image.new('L', (48, 48), 0)
    hd = ImageDraw.Draw(hi)
    hd.ellipse([6, 2, 42, 26], fill=70)
    hi = hi.resize((BADGE, BADGE), Image.BILINEAR).filter(
        ImageFilter.GaussianBlur(BADGE // 12))
    base = Image.composite(
        Image.new('RGB', (BADGE, BADGE), (255, 255, 255)), base, hi)
    return base


def emblem_mask(zone):
    """White silhouette as an 'L' mask; 0 = cut out, 255 = solid."""
    m = Image.new('L', (BADGE, BADGE), 0)
    d = ImageDraw.Draw(m)
    u = BADGE / 256.0  # draw in 256-space units
    c = BADGE / 2

    def box(x0, y0, x1, y1):
        return [c + (x0 - 128) * u, c + (y0 - 128) * u,
                c + (x1 - 128) * u, c + (y1 - 128) * u]

    if zone == 'word-woods':
        # Trunk + three stacked pine triangles.
        d.rectangle(box(120, 168, 136, 196), fill=255)
        for i, (half, base_y, tip_y) in enumerate(
                ((46, 172, 96), (38, 146, 76), (30, 120, 58))):
            d.polygon([c, c + (tip_y - 128) * u,
                       c - half * u, c + (base_y - 128) * u,
                       c + half * u, c + (base_y - 128) * u], fill=255)
    elif zone == 'number-nebula':
        # Ringed planet + two sparkles.
        d.ellipse(box(88, 88, 168, 168), fill=255)
        ring = Image.new('L', (BADGE, BADGE), 0)
        rd = ImageDraw.Draw(ring)
        rd.ellipse(box(62, 110, 194, 146), outline=255, width=int(9 * u))
        d.ellipse(box(88, 88, 168, 168), fill=255)
        m.paste(255, (0, 0), ring)
        d = ImageDraw.Draw(m)
        for (sx, sy, sr) in ((70, 70, 7), (190, 178, 9), (64, 180, 5)):
            d.ellipse(box(sx - sr, sy - sr, sx + sr, sy + sr), fill=255)
        return m
    elif zone == 'math-facts':
        # Plus, minus, multiply, equals - bold operator grid.
        w = int(14 * u)
        for (ox, oy) in ((96, 96), (160, 96), (96, 160), (160, 160)):
            cx, cy = c + (ox - 128) * u, c + (oy - 128) * u
            s = 20 * u
            if (ox, oy) == (96, 96):    # +
                d.line([(cx - s, cy), (cx + s, cy)], fill=255, width=w)
                d.line([(cx, cy - s), (cx, cy + s)], fill=255, width=w)
            elif (ox, oy) == (160, 96):  # -
                d.line([(cx - s, cy), (cx + s, cy)], fill=255, width=w)
            elif (ox, oy) == (96, 160):  # x
                k = s * 0.72
                d.line([(cx - k, cy - k), (cx + k, cy + k)], fill=255, width=w)
                d.line([(cx - k, cy + k), (cx + k, cy - k)], fill=255, width=w)
            else:                        # =
                d.line([(cx - s, cy - s * 0.45), (cx + s, cy - s * 0.45)],
                       fill=255, width=w)
                d.line([(cx - s, cy + s * 0.45), (cx + s, cy + s * 0.45)],
                       fill=255, width=w)
    elif zone == 'story-springs':
        # Open book: two pages tilting up to a raised spine.
        for side in (-1, 1):
            page = Image.new('L', (BADGE, BADGE), 0)
            pd = ImageDraw.Draw(page)
            x0 = c + side * 10 * u
            pd.polygon([
                (x0, c - 40 * u),                      # spine top
                (x0 + side * 74 * u, c - 18 * u),      # outer top
                (x0 + side * 74 * u, c + 38 * u),      # outer bottom
                (x0, c + 58 * u)], fill=255)           # spine bottom
            m.paste(255, (0, 0), page)
        d = ImageDraw.Draw(m)
        # Spine block.
        d.polygon([c - 10 * u, c - 46 * u, c + 10 * u, c - 46 * u,
                   c + 10 * u, c + 62 * u, c - 10 * u, c + 62 * u], fill=255)
        # Tilted text-line cut-outs following each page's slope.
        for side in (-1, 1):
            for ly in (-18, -2, 14, 30):
                d.line([c + side * 22 * u, c + ly * u,
                        c + side * 62 * u, c + (ly + 9) * u],
                       fill=0, width=int(5 * u))
    elif zone == 'science-explorers':
        # Erlenmeyer flask with bubbles.
        d.polygon([c - 10 * u, c - 56 * u,
                   c + 10 * u, c - 56 * u,
                   c + 10 * u, c - 16 * u,
                   c + 48 * u, c + 46 * u,
                   c + 40 * u, c + 60 * u,
                   c - 40 * u, c + 60 * u,
                   c - 48 * u, c + 46 * u,
                   c - 10 * u, c - 16 * u], fill=255)
        d.rounded_rectangle(box(114, 58, 142, 70), radius=int(5 * u), fill=255)
        for (bx, by, br) in ((96, 118, 8), (150, 100, 6), (158, 138, 5)):
            d.ellipse(box(bx - br, by - br, bx + br, by + br), fill=255)
    elif zone == 'creative-corner':
        # Palette with thumb hole + brush.
        d.ellipse(box(58, 84, 198, 172), fill=255)
        d.ellipse(box(138, 132, 166, 160), fill=0)
        d.polygon([c + 44 * u, c - 10 * u,
                   c + 84 * u, c - 78 * u,
                   c + 96 * u, c - 68 * u,
                   c + 58 * u, c + 4 * u], fill=255)
    elif zone == 'puzzle-peaks':
        # Classic puzzle piece: top bump out, right socket cut.
        d.rounded_rectangle(box(72, 78, 184, 190), radius=int(14 * u), fill=255)
        d.ellipse(box(106, 48, 150, 92), fill=255)
        d.ellipse(box(160, 116, 204, 160), fill=0)
    elif zone == 'adventure-arena':
        # Trophy cup with handles, stem, base, star cut-out.
        d.ellipse(box(80, 58, 176, 96), fill=255)
        d.polygon([c - 48 * u, c - 4 * u,
                   c + 48 * u, c - 4 * u,
                   c + 34 * u, c + 44 * u,
                   c - 34 * u, c + 44 * u], fill=255)
        for side in (-1, 1):
            h = Image.new('L', (BADGE, BADGE), 0)
            hd = ImageDraw.Draw(h)
            hd.arc([c + (side * 34 - 34) * u, c - 4 * u,
                    c + (side * 34 + 34) * u, c + 38 * u],
                   start=270 if side > 0 else 90,
                   end=90 if side > 0 else 270, fill=255, width=int(9 * u))
            m.paste(255, (0, 0), h)
        d = ImageDraw.Draw(m)
        d.rectangle(box(118, 44, 138, 118), fill=255)
        d.rounded_rectangle(box(88, 118, 168, 142), radius=int(8 * u), fill=255)
        # Star cut-out in the cup.
        star = []
        for i in range(10):
            ang = -math.pi / 2 + i * math.pi / 5
            r = (17 if i % 2 == 0 else 7.5) * u
            star.append((c + math.cos(ang) * r, c - 14 * u + math.sin(ang) * r))
        d.polygon(star, fill=0)
    return m


def build_badge(zone, primary, secondary):
    canvas = Image.new('RGBA', (CANVAS, CANVAS), (0, 0, 0, 0))
    off = (CANVAS - BADGE) // 2

    # Drop shadow.
    shadow = Image.new('RGBA', (CANVAS, CANVAS), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse([off + 6 * S, off + 14 * S, off + BADGE + 6 * S,
                off + BADGE + 14 * S], fill=(0, 0, 0, 96))
    shadow = shadow.filter(ImageFilter.GaussianBlur(10 * S))
    canvas.alpha_composite(shadow)

    # Gradient disc.
    disc = badge_gradient(primary, secondary).convert('RGBA')
    mask = Image.new('L', (BADGE, BADGE), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, BADGE - 1, BADGE - 1], fill=255)
    canvas.paste(disc, (off, off), mask)

    # Rim + inner ring + gloss.
    rim = Image.new('RGBA', (CANVAS, CANVAS), (0, 0, 0, 0))
    rd = ImageDraw.Draw(rim)
    rd.ellipse([off, off, off + BADGE - 1, off + BADGE - 1],
               outline=(255, 255, 255, 70), width=int(3 * S))
    rd.ellipse([off + 10 * S, off + 10 * S, off + BADGE - 10 * S,
                off + BADGE - 10 * S],
               outline=(255, 255, 255, 110), width=int(2 * S))
    gloss = Image.new('RGBA', (CANVAS, CANVAS), (0, 0, 0, 0))
    gd = ImageDraw.Draw(gloss)
    gd.pieslice([off + 12 * S, off + 8 * S, off + BADGE - 12 * S,
                 off + BADGE - 60 * S], start=195, end=345,
                fill=(255, 255, 255, 42))
    canvas.alpha_composite(rim)
    canvas.alpha_composite(gloss)

    # Emblem (white, with mask cut-outs), slight shadow for lift.
    mask = emblem_mask(zone)
    em_shadow = Image.new('RGBA', (BADGE, BADGE), (0, 0, 0, 255))
    shadow_alpha = mask.filter(ImageFilter.GaussianBlur(4 * S))
    shadow_alpha = shadow_alpha.point(lambda a: a * 90 // 255)
    em_shadow.putalpha(shadow_alpha)
    canvas.alpha_composite(em_shadow, (off, off + 4 * S))
    emblem = Image.new('RGBA', (BADGE, BADGE), (255, 255, 255, 255))
    emblem.putalpha(mask)
    canvas.alpha_composite(emblem, (off, off))

    return canvas.resize((CANVAS // S, CANVAS // S), Image.LANCZOS)


def build_wordmark():
    w, h = 1600, 620
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    fredoka = os.path.join(FONTS, 'Fredoka-SemiBold.ttf')
    comfortaa = os.path.join(FONTS, 'Comfortaa-Bold.ttf')

    title_font = ImageFont.truetype(fredoka, 190)
    sub_font = ImageFont.truetype(comfortaa, 64)

    title = 'BrightBound'
    tb = d.textbbox((0, 0), title, font=title_font, stroke_width=10)
    tx, ty = (w - (tb[2] - tb[0])) / 2 - tb[0], 70 - tb[1]

    # Soft drop shadow.
    sh = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    sd = ImageDraw.Draw(sh)
    sd.text((tx, ty + 10), title, font=title_font, fill=(0, 0, 0, 120),
            stroke_width=10, stroke_fill=(0, 0, 0, 60))
    sh = sh.filter(ImageFilter.GaussianBlur(8))
    img.alpha_composite(sh)

    d.text((tx, ty), title, font=title_font, fill=(255, 255, 255, 255),
           stroke_width=10, stroke_fill=(26, 35, 126, 255))

    # Letterspaced subtitle.
    sub = 'A D V E N T U R E S'
    sb = d.textbbox((0, 0), sub, font=sub_font)
    sx = (w - (sb[2] - sb[0])) / 2 - sb[0]
    d.text((sx, 340 - sb[1] + 80), sub, font=sub_font,
           fill=(255, 215, 64, 255), stroke_width=3,
           stroke_fill=(26, 35, 126, 255))
    return img


def main():
    os.makedirs(ZONE_DIR, exist_ok=True)
    for zone, (primary, secondary) in ZONES.items():
        out = os.path.join(ZONE_DIR, f'{zone}.png')
        build_badge(zone, primary, secondary).save(out)
        print('wrote', out)
    wm = os.path.join(OUT_DIR, 'wordmark.png')
    build_wordmark().save(wm)
    print('wrote', wm)


if __name__ == '__main__':
    main()
