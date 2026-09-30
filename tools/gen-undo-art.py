#!/usr/bin/env python3
"""Gloom's Hub — the UNDO / REDO icons (2026-09-30): a curved arrow, white, to
be tinted in game. 64 x 64 (a 16-unit icon at 4 texels a unit), anti-aliased by
drawing 4x and reducing.  Media/ui/g-undo.png (turning back, to the left) and
g-redo.png (its mirror)."""
import os, math
from PIL import Image, ImageDraw

HUB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(HUB, "Media", "ui")
S, N = 4, 64
im = Image.new("L", (N * S, N * S), 0)
d = ImageDraw.Draw(im)
cx, cy, r, w = 36 * S, 36 * S, 20 * S, 6 * S
# an arc over the top from the right (0°) round to the left (180°), open at the bottom-left
d.arc([cx - r, cy - r, cx + r, cy + r], start=180, end=360 + 60, fill=255, width=w)
# the head: a triangle at the arc's left end, pointing down
tip = (cx - r + w / 2, cy + 16 * S)
d.polygon([(cx - r - 10 * S + w / 2, cy - 2 * S), (cx - r + 10 * S + w / 2, cy - 2 * S), tip], fill=255)
im = im.resize((N, N), Image.LANCZOS)
def save(name, a):
    o = Image.new("RGBA", a.size, (255, 255, 255, 0)); o.putalpha(a); o.save(os.path.join(OUT, name))
save("g-undo.png", im)
save("g-redo.png", im.transpose(Image.FLIP_LEFT_RIGHT))
print("wrote g-undo.png, g-redo.png")
