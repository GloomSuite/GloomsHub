#!/usr/bin/env python3
"""Gloom's Hub — the BAR-shape family's generated art (Shapes.lua, BAR_SHAPE_DEF).

Writes Media/art/barshapes/<key>-base.png (the mask), -base-s.png (quarter size,
anti-aliased edge, for small draws) and -rim.png (the outline), and prints the
catalog rows with each silhouette's measured FOOTPRINT. Re-run after changing a
shape; paste the printed rows into Shapes.lua.

The bracket SET: three concentric bands, same thickness, same gap, tips cut
along the same radial angle (option B, the owner's pick 2026-09-21), drawn as
one composition and exported one band per file on the shared 512×1024 canvas —
so three bars wearing outer / middle / inner at the same size and position nest.
"""
import math, os
from PIL import Image, ImageDraw, ImageFilter

OUT = os.path.join(os.path.dirname(__file__), "..", "Media", "art", "barshapes")
S = 4                                   # supersample

def save(name, alpha):
    w, h = alpha.size
    Image.merge("RGBA", [Image.new("L", (w, h), 255)] * 3 + [alpha]).save(os.path.join(OUT, name))

RIM_WIDTHS = { "thin": 256, "": 64, "thick": 32 }      # suffix → the short side divided by this = stroke px
# thin lands at 1–2 px on screen at the sizes bars are drawn (the owner, 2026-09-21);
# "" (medium) is the width the first outline shipped with; thick is twice that.

def rims_from(key, a):
    """Three outline widths from a finished (anti-aliased) base mask, at native resolution."""
    from PIL import ImageChops
    short = min(a.size)
    for suffix, div in RIM_WIDTHS.items():
        r = max(1, short // div // 2)                          # half-width; kernel is 2r+1
        rim = ImageChops.subtract(a.filter(ImageFilter.MaxFilter(2 * r + 1)), a.filter(ImageFilter.MinFilter(2 * r + 1)))
        save(f"{key}-rim{('-' + suffix) if suffix else ''}.png", rim)

def finish(key, big):
    """big: supersampled L mask. Writes base, base-s and the three rims; returns the footprint."""
    w, h = big.size[0] // S, big.size[1] // S
    base = big.resize((w, h), Image.LANCZOS)
    save(f"{key}-base.png", base)
    small = base.resize((w // 4, h // 4), Image.LANCZOS).filter(ImageFilter.GaussianBlur(0.7))
    save(f"{key}-base-s.png", small)
    rims_from(key, base)
    bb = base.point(lambda v: 255 if v > 24 else 0).getbbox()   # ignore the resampling halo
    return (w, h, bb[0], bb[1], bb[2], bb[3])

def band_mask(W, H, cx, cy, R, t, theta):
    """A left-side arc band of outer radius R, thickness t, centred (cx, cy), tips
    cut along the radial lines at ±theta from the leftward axis. Supersampled."""
    big = Image.new("L", (W * S, H * S), 0)
    d = ImageDraw.Draw(big)
    d.ellipse([(cx - R) * S, (cy - R) * S, (cx + R) * S, (cy + R) * S], fill=255)
    d.ellipse([(cx - R + t) * S, (cy - R + t) * S, (cx + R - t) * S, (cy + R - t) * S], fill=0)
    # keep the wedge between the two radial cut lines (a polygon through the centre)
    far = 4 * R
    ax, ay = cx - far * math.cos(theta), cy - far * math.sin(theta)
    bx, by = cx - far * math.cos(theta), cy + far * math.sin(theta)
    keep = Image.new("L", big.size, 0)
    ImageDraw.Draw(keep).polygon([(cx * S, cy * S), (ax * S, ay * S), (bx * S, by * S)], fill=255)
    return Image.composite(big, Image.new("L", big.size, 0), keep)

rows = []
os.makedirs(OUT, exist_ok=True)

# --- Orb and Pill (the two simple shapes), regenerated here so every file has one source
W = 512
big = Image.new("L", (W * S, W * S), 0); ImageDraw.Draw(big).ellipse([128 * S, 128 * S, 384 * S, 384 * S], fill=255)
rows.append(("orb", "Orb") + finish("orb", big))
big = Image.new("L", (W * S, 768 * S), 0); ImageDraw.Draw(big).rounded_rectangle([128 * S, 128 * S, 384 * S, 640 * S], radius=128 * S, fill=255)
rows.append(("pill", "Pill") + finish("pill", big))

# --- The bracket set
W, H = 512, 1024
theta = math.radians(40)
t, gap = 56, 40
R = 448 / math.sin(theta)               # the outer band's tips at ±448 from the middle
cx = 64 + R                             # the outer band's leftmost point at x = 64
cy = H / 2
for i, name in enumerate(["outer", "middle", "inner"]):
    r = R - i * (t + gap)
    big = band_mask(W, H, cx, cy, r, t, theta)
    rows.append((f"bracket-{name}", f"Bracket · {name}") + finish(f"bracket-{name}", big) + ("bracket",))

# --- IMPORTED art: the owner's files, kept as <key>-base.png in Media. The
# outline and the small variant are derived here AT NATIVE RESOLUTION (the
# files are 1024², already finer than the generated art's supersample); the
# base is left as drawn except for a one-texel anti-aliasing pass on its edge
# (the files arrive with a binary edge, and a big canvas drawn three times
# smaller aliases).
IMPORTED = [
    ("tallcrescent-large",  "Tall crescent · large",  "tallcrescent"),
    ("tallcrescent-medium", "Tall crescent · medium", "tallcrescent"),
    ("tallcrescent-small",  "Tall crescent · small",  "tallcrescent"),
]
for key, label, setname in IMPORTED:
    src = os.path.join(OUT, f"{key}-base.png")
    if not os.path.exists(src):
        print(f"-- {key}: no {key}-base.png in Media/art/barshapes, skipped"); continue
    a = Image.open(src).convert("RGBA").split()[-1]
    if len(set(a.getdata())) <= 3:                     # binary edge → soften once
        a = a.filter(ImageFilter.GaussianBlur(0.8))
        save(f"{key}-base.png", a)
    w, h = a.size
    small = a.resize((w // 4, h // 4), Image.LANCZOS).filter(ImageFilter.GaussianBlur(0.7))
    save(f"{key}-base-s.png", small)
    rims_from(key, a)
    bb = a.point(lambda v: 255 if v > 24 else 0).getbbox()
    rows.append((key, label, w, h) + bb + (setname,))

print("-- paste into Shapes.lua BAR_SHAPE_DEF: { key, label, canvasW, canvasH, x0, y0, x1, y1 [, set] }")
for r in rows:
    key, label, w, h, x0, y0, x1, y1 = r[:8]
    extra = f', set = "{r[8]}"' if len(r) > 8 else ""
    print(f'    {{ "{key}", "{label}", {w}, {h}, {x0}, {y0}, {x1}, {y1}{extra} }},')
