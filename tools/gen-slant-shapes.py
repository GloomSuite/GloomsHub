#!/usr/bin/env python3
"""The SLANTED button shapes — `slant-r` ("/") and `slant-l` ("\\") — for the
Hub's silhouette catalog (Shapes.lua, Media/art/shapes/).

The owner, 2026-09-30: two shapes "that mimic the same angle" as Gloom's Unit
Frames' slanted bar ends, "in a basically square shape". So: a square skewed
by that angle — top and bottom edges as long as the shape is tall, the slanted
sides crossing HALF the height sideways over the full height (the Angled fill
end, gloomsunitframes tools/gen-fill-art.py: a 64 x 128 piece, run = H / 2).
The owner widened it on 2026-10-01 (Figma): the same slant, the flat top and
bottom 40 longer (296 at a height of 256), so the footprint is 424 x 256
(aspect 1.65625) on a 680 x 512 canvas — the usual half-height (128) margin
on every side, which is what GrowAnchor assumes.

The catalog's other button shapes were drawn outside this repo and no
generator survives, so every PART is reproduced from the SQUARE's own art:
each part's alpha (and colour) is read off square-<part>.png as a function of
the signed distance to the square's edge (its centre row, where that distance
is exact), then laid over the parallelogram's exact signed distance. The
glows, rim, line and fill therefore fall off exactly as every other shape's.
  base    binary silhouette (as all base art)     680 x 512
  base-s  the anti-aliased quarter-size copy       170 x 128
  outer / inner / rim / line   the square's falloffs   680 x 512
  swipe   the silhouette at alpha 0.8, the footprint stretched to 256 x 256
          (as square32w's: the engine stretches it back over the footprint)

  python3 tools/gen-slant-shapes.py        (from the repo root)
"""
import os
import numpy as np
from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "Media", "art", "shapes")
CW, CH = 680, 512                 # canvas: the footprint + 128 on every side
X0, Y0, FW, FH = 128, 128, 424, 256   # the footprint on it (flat edges 296)
RUN = FH / 2                      # the slant's sideways run over the full height

def corners(lean):
    """The parallelogram, clockwise from top-left, in canvas px (y down)."""
    if lean == "r":   # "/" — the top shifted right
        return [(X0 + RUN, Y0), (X0 + FW, Y0), (X0 + FW - RUN, Y0 + FH), (X0, Y0 + FH)]
    return [(X0, Y0), (X0 + FW - RUN, Y0), (X0 + FW, Y0 + FH), (X0 + RUN, Y0 + FH)]  # "\"

def sdf(px, py, poly):
    """Exact signed distance to a convex polygon: negative inside."""
    d = np.full(px.shape, np.inf)
    inside = np.ones(px.shape, bool)
    n = len(poly)
    for i in range(n):
        ax, ay = poly[i]; bx, by = poly[(i + 1) % n]
        ex, ey = bx - ax, by - ay
        wx, wy = px - ax, py - ay
        t = np.clip((wx * ex + wy * ey) / (ex * ex + ey * ey), 0, 1)
        dx, dy = wx - ex * t, wy - ey * t
        d = np.minimum(d, np.hypot(dx, dy))
        # clockwise in y-down screen space: inside is to the RIGHT of each edge
        inside &= (ex * wy - ey * wx) >= 0
    return np.where(inside, -d, d)

def profile(part, scale=1):
    """The square's part as (distance → RGBA), from its centre row."""
    im = np.asarray(Image.open(os.path.join(ROOT, f"square-{part}.png")).convert("RGBA")).astype(float)
    h, w = im.shape[:2]
    row = im[h // 2, : w // 2]                   # left half: edge at w/4
    edge = w / 4
    dist = (edge - np.arange(w // 2)) * scale   # + outside, - inside (full-size px)
    order = np.argsort(dist)
    return dist[order], row[order]

def paint(d, prof):
    dist, rgba = prof
    out = np.zeros(d.shape + (4,))
    for c in range(4):
        out[..., c] = np.interp(d, dist, rgba[:, c])
    return Image.fromarray(np.clip(out + 0.5, 0, 255).astype(np.uint8), "RGBA")

def grid(w, h, sx=1.0, sy=1.0, ox=0.0, oy=0.0):
    ys, xs = np.mgrid[0:h, 0:w].astype(float)
    return (xs + 0.5) * sx + ox, (ys + 0.5) * sy + oy

def make(lean):
    key = f"slant-{lean}"
    poly = corners(lean)
    px, py = grid(CW, CH)
    d = sdf(px, py, poly)
    # base: binary
    a = np.where(d <= 0, 255, 0).astype(np.uint8)
    base = np.zeros((CH, CW, 4), np.uint8); base[..., :3] = 255; base[..., 3] = a
    Image.fromarray(base, "RGBA").save(os.path.join(ROOT, f"{key}-base.png"))
    # the falloff parts
    for part in ("outer", "inner", "rim", "line"):
        paint(d, profile(part)).save(os.path.join(ROOT, f"{key}-{part}.png"))
    # base-s: quarter size, sampled at full-size distances
    qx, qy = grid(CW // 4, CH // 4, 4, 4)
    paint(sdf(qx, qy, poly), profile("base-s", 4)).save(os.path.join(ROOT, f"{key}-base-s.png"))
    # swipe: the footprint stretched onto 256 x 256, alpha 0.8, 4x supersampled
    S = 4
    sx, sy = grid(256 * S, 256 * S, FW / (256 * S), FH / (256 * S), X0, Y0)
    inside = (sdf(sx, sy, poly) <= 0).astype(float)
    cov = inside.reshape(256, S, 256, S).mean(axis=(1, 3))
    sw = np.zeros((256, 256, 4), np.uint8); sw[..., :3] = 255
    sw[..., 3] = np.clip(cov * 204 + 0.5, 0, 255).astype(np.uint8)
    Image.fromarray(sw, "RGBA").save(os.path.join(ROOT, f"{key}-swipe.png"))
    print("wrote", key)

for lean in ("r", "l"):
    make(lean)
