#!/usr/bin/env python3
"""Art for the GLASS design (the third Suite redesign, 2026-09-25). Re-run after any change here.

  python3 tools/gen-glass-art.py

1. ICONS (white, tinted in Lua) — Media/ui/g-close.png (the window's close: a disc with the X cut
   out, 23px), g-x.png (a row's remove X, 9px), g-eye.png (14x9), g-warn.png (12x11). Traced from
   the owner's own SVGs, exported by the Figma server and kept in tools/glass-svg/. There is no SVG
   rasteriser on this Mac, so macOS Quick Look draws them (on OPAQUE white — LESSONS § "Reading the
   Figma mocks"): every fill is forced black, the SVG is scaled up x20 so Quick Look draws it large,
   then darkness becomes alpha and the ink is downsampled to its display size.
   ★ Everything is drawn at 4x its display size (2026-09-26): the game shows one UI unit as
   1.8-3 screen pixels, and art drawn at 1x was being ENLARGED (soft); at 4x it is only ever
   shrunk (crisp). Canvases scale by 4 too, so every texcoord in Skin.lua is unchanged.
   Also at 4x: g-check.png (the checkbox's tick, from the mock's Frame 319, placed in its 16px
   box — boxed, not cropped), g-tri.png (the kit's ▾/▸/▲, an equilateral triangle pointing DOWN),
   g-disc.png / g-disc-dash.png (a colour swatch; the dashed ring = no colour set).

2. THE DIAL'S TICKS — Media/ui/g-ticks.png: 21 ticks, 1px wide at a 5px pitch (x = 0, 5 … 100),
   10 tall — the mocks' "Frame 305", 101 x 10 — on a 128x16 canvas. ⚠ No longer drawn by the
   glass dial (2026-09-26): it draws each tick as its own 1-unit rectangle, which lands exactly
   on the pixel grid at the window's whole-pixel scales. Kept for reference.

3. THE SHARED BACKGROUND — only with `bg`:

     python3 tools/gen-glass-art.py bg ["<folder>"]   (default ~/Desktop/Glooms BGs)

   The owner's ONE export of the window's background (shared_bg.png, 2x: 2120 x 1480, nothing
   but the background showing), cut NOT RESAMPLED into four power-of-two tiles,
   Media/glass/shared-a|b|c|d.png — a 2048 x 1024 (the top left), 72 x 1024 on a 128 canvas (top
   right), 2048 x 456 on a 512 canvas (bottom left), 72 x 456 on 128 x 512 (bottom right) — which
   the Shell lays edge to edge (GLASS_TILES). At 2 pixels a unit they land pixel for pixel.
   ★ 2026-09-26: this used to cut ONE export PER PAGE with its glass panels baked in. The owner
   made the panels solid; the tools now list them (`panels`) and the Shell draws them (UI.gPanel).

4. THE PANELS' CORNER — Media/ui/g-corner.png (also `corner` alone): a white quarter disc of
   radius 20 units, at 4x (80px) on a 128 canvas, anti-aliased. UI.gPanel flips it for all four.
"""
import math, os, re, subprocess, sys, tempfile
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
UI = os.path.join(ROOT, "Media", "ui")
SRC = os.path.join(ROOT, "tools", "glass-svg")
K = 4   # every mark is drawn at 4x its display size
ICONS = {"close": (23 * K, 23 * K, 32 * K), "x": (9 * K, 9 * K, 16 * K), "eye": (14 * K, 9 * K, 16 * K),
         "warn": (12 * K, 12 * K, 16 * K)}   # max w, max h, canvas

def icon(name, w, h, canvas, tmp):
    s = open(os.path.join(SRC, name + ".svg")).read()
    s = re.sub(r'fill="(#[0-9A-Fa-f]{6}|white)"', 'fill="#000000"', s)
    s = re.sub(r' fill-opacity="[^"]*"', "", s)
    s = re.sub(r'stroke="(#[0-9A-Fa-f]{6}|white)"', 'stroke="#000000"', s)   # line art (the v3 pop-out icons)
    s = re.sub(r'preserveAspectRatio="none" overflow="visible" style="display: block;" ', "", s)
    s = re.sub(r'(width|height)="([0-9.]+)"', lambda m: '%s="%g"' % (m.group(1), float(m.group(2)) * 20), s, count=2)
    p = os.path.join(tmp, name + ".svg"); open(p, "w").write(s)
    subprocess.run(["qlmanage", "-t", "-s", "512", "-o", tmp, p], capture_output=True)
    im = Image.open(p + ".png").convert("L").point(lambda v: 255 - v)
    im = im.crop(im.getbbox())
    k = min(w / im.size[0], h / im.size[1])
    a = im.resize((max(1, round(im.size[0] * k)), max(1, round(im.size[1] * k))), Image.LANCZOS)
    out = Image.new("RGBA", (canvas, canvas), (255, 255, 255, 0))
    ink = Image.new("RGBA", a.size, (255, 255, 255, 0)); ink.putalpha(a)
    out.paste(ink, (0, 0))
    out.save(os.path.join(UI, "g-" + name + ".png"))
    print("g-%s.png  %dx%d on %d" % (name, a.size[0], a.size[1], canvas))

def boxed(name, px, tmp):
    """Render an SVG's whole viewBox (the mark keeps its place in its box) at px x px."""
    s = open(os.path.join(SRC, name + ".svg")).read()
    s = re.sub(r'fill="(#[0-9A-Fa-f]{6}|white)"', 'fill="#000000"', s)
    s = re.sub(r'(width|height)="([0-9.]+)"', lambda m: '%s="%g"' % (m.group(1), float(m.group(2)) * 20), s, count=2)
    p = os.path.join(tmp, name + ".svg"); open(p, "w").write(s)
    subprocess.run(["qlmanage", "-t", "-s", "512", "-o", tmp, p], capture_output=True)
    a = Image.open(p + ".png").convert("L").point(lambda v: 255 - v).resize((px, px), Image.LANCZOS)
    out = Image.new("RGBA", (px, px), (255, 255, 255, 0)); out.putalpha(a)
    out.save(os.path.join(UI, "g-" + name + ".png")); print("g-%s.png  %dx%d (boxed)" % (name, px, px))

def drawn():
    SS = 8
    # the triangle, pointing DOWN, equilateral, centred in a 64 canvas
    n = 64 * SS; im = Image.new("L", (n, n), 0); d = ImageDraw.Draw(im)
    h = n * math.sqrt(3) / 2; top = (n - h) / 2
    d.polygon([(0, top), (n, top), (n / 2, top + h)], fill=255)
    tri = Image.new("RGBA", (64, 64), (255, 255, 255, 0)); tri.putalpha(im.resize((64, 64), Image.LANCZOS))
    tri.save(os.path.join(UI, "g-tri.png")); print("g-tri.png  64x64")
    # the swatch disc and the dashed ring (no colour): the mock's 15px circle; the
    # ring's stroke is one unit (15px shown -> 128/15 of the canvas)
    n = 128 * SS; im = Image.new("L", (n, n), 0); d = ImageDraw.Draw(im); d.ellipse([0, 0, n - 1, n - 1], fill=255)
    disc = Image.new("RGBA", (128, 128), (255, 255, 255, 0)); disc.putalpha(im.resize((128, 128), Image.LANCZOS))
    disc.save(os.path.join(UI, "g-disc.png")); print("g-disc.png  128x128")
    im = Image.new("L", (n, n), 0); d = ImageDraw.Draw(im)
    w = n / 15.0
    for i in range(12):                                   # 12 dashes, half the circumference each
        a0 = i * 30; d.arc([w / 2, w / 2, n - w / 2, n - w / 2], a0, a0 + 15, fill=255, width=int(w))
    ring = Image.new("RGBA", (128, 128), (255, 255, 255, 0)); ring.putalpha(im.resize((128, 128), Image.LANCZOS))
    ring.save(os.path.join(UI, "g-disc-dash.png")); print("g-disc-dash.png  128x128")

def ticks():
    im = Image.new("RGBA", (128, 16), (255, 255, 255, 0))
    px = im.load()
    for i in range(21):
        for y in range(10):
            px[i * 5, y] = (255, 255, 255, 255)
    im.save(os.path.join(UI, "g-ticks.png")); print("g-ticks.png  101x10 on 128x16")

TILES = [("a", 0, 0, 2048, 1024, 2048, 1024), ("b", 2048, 0, 72, 1024, 128, 1024),
         ("c", 0, 1024, 2048, 456, 2048, 512), ("d", 2048, 1024, 72, 456, 128, 512)]   # name, x, y, w, h, canvas w, h
GLASS_DIR = os.path.join(ROOT, "Media", "glass")

def backgrounds(folder):
    src = os.path.join(folder, "shared_bg.png")
    if not os.path.exists(src):
        print("missing:", src); return
    im = Image.open(src).convert("RGBA")
    if im.size != (2120, 1480):
        print("NOT 2x (2120 x 1480):", im.size); return
    os.makedirs(GLASS_DIR, exist_ok=True)
    for t, x, y, w, h, cw, ch in TILES:
        out = Image.new("RGBA", (cw, ch), (0, 0, 0, 255))
        out.paste(im.crop((x, y, x + w, y + h)), (0, 0))
        out.save(os.path.join(GLASS_DIR, "shared-%s.png" % t), optimize=True)
    print("Media/glass/shared-a|b|c|d.png")

def corner():
    """The panels' 20-unit rounded corner: a white quarter disc (the TOP-LEFT corner; the Shell
    flips its texcoords for the other three), drawn at 4x (80px) on a 128 canvas, edge
    anti-aliased by 8x8 supersampling."""
    R, SS = 20 * K, 8
    im = Image.new("RGBA", (128, 128), (255, 255, 255, 0))
    px = im.load()
    for y in range(R):
        for x in range(R):
            n = 0
            for sy in range(SS):
                for sx in range(SS):
                    dx, dy = R - (x + (sx + .5) / SS), R - (y + (sy + .5) / SS)
                    if dx * dx + dy * dy <= R * R: n += 1
            px[x, y] = (255, 255, 255, round(255 * n / (SS * SS)))
    im.save(os.path.join(UI, "g-corner.png")); print("g-corner.png  80x80 quarter disc on 128x128")

def v3art(tmp):
    """The two-window design's marks (2026-09-27, the Figma page "GloomSuite UI 3"). All at 4x, white.
    g-popout.png / g-popin.png: a section's pop-out and pop-in icons (8.5 units, 34px on 64), traced
    from the mock's own SVGs. g-pill-*.png: a color pill's LEFT end (the pill is 16 units tall, so an
    end is 8 x 16 = 32 x 64 px): -fill a half disc, -ring its 1-unit outline, -dash that outline
    dashed; flipped for the right end. g-dash.png: a 1-unit dashed line, 2 on / 2 off, tiled."""
    icon("popout", 34, 34, 64, tmp)
    icon("popin", 34, 34, 64, tmp)
    SS, R = 8, 32
    def cap(name, ring, dashed):
        im = Image.new("RGBA", (32, 64), (255, 255, 255, 0)); px = im.load()
        for y in range(64):
            for x in range(32):
                n = 0
                for sy in range(SS):
                    for sx in range(SS):
                        fx, fy = x + (sx + .5) / SS, y + (sy + .5) / SS
                        dx, dy = R - fx, R - fy
                        d = math.hypot(dx, dy)
                        if d > R: continue
                        if ring and d < R - 4: continue
                        if dashed:
                            ang = math.atan2(dy, dx)            # 0 at the far left, +-pi/2 top/bottom
                            arc = (ang + math.pi / 2) * (R - 2)     # distance along the arc
                            if (arc // 8) % 2 == 1: continue    # 2 units on, 2 off (8 px each at 4x)
                        n += 1
                px[x, y] = (255, 255, 255, round(255 * n / (SS * SS)))
        im.save(os.path.join(UI, "g-pill-%s.png" % name)); print("g-pill-%s.png  32x64" % name)
    cap("fill", False, False); cap("ring", True, False); cap("dash", True, True)
    d = Image.new("RGBA", (16, 4), (255, 255, 255, 0)); dp = d.load()
    for x in range(8):
        for y in range(4): dp[x, y] = (255, 255, 255, 255)
    d.save(os.path.join(UI, "g-dash.png")); print("g-dash.png  16x4 (2 units on, 2 off)")

def dots():
    """The EMPTY-color marks as DOTS (the owner, 2026-09-27: "they WERE 2px dashes,
    now they're just 1px dots"): one-unit dots, three units apart (1 on, 2 off).
    g-pill-dash.png: a pill's LEFT end (8 x 16 units at 4x = 32 x 64), the dots
    spread evenly round its half circle on the stroke's centre line (the straight
    runs are drawn by UI.gPill itself). g-disc-dash.png: the 15-unit round swatch
    (128px), its ring as 15 dots."""
    SS = 8
    def disc_dots(size, cx, cy, r, d, angles):
        n = size[0] * SS, size[1] * SS
        im = Image.new("L", n, 0); dr = ImageDraw.Draw(im)
        for a in angles:
            x, y = (cx + r * math.cos(a)) * SS, (cy - r * math.sin(a)) * SS
            dr.ellipse([x - d * SS / 2, y - d * SS / 2, x + d * SS / 2, y + d * SS / 2], fill=255)
        out = Image.new("RGBA", size, (255, 255, 255, 0)); out.putalpha(im.resize(size, Image.LANCZOS))
        return out
    # pill end: centre (32, 32), stroke centre 30 px out (R 32 - half a unit), dot 4 px
    arc = math.pi * 7.5                               # units along the half circle
    n = max(1, round(arc / 3))
    angs = [math.pi / 2 + (k + 0.5) / n * math.pi for k in range(n)]
    disc_dots((32, 64), 32, 32, 30, 4, angs).save(os.path.join(UI, "g-pill-dash.png")); print("g-pill-dash.png  32x64 (%d dots)" % n)
    # round swatch: 128 px for 15 units, stroke centre at 7 units, dot 1 unit
    u = 128 / 15.0
    disc_dots((128, 128), 64, 64, 7 * u, u, [k / 15 * 2 * math.pi for k in range(15)]).save(os.path.join(UI, "g-disc-dash.png")); print("g-disc-dash.png  128x128 (15 dots)")

if len(sys.argv) > 1 and sys.argv[1] == "dots":
    dots(); sys.exit(0)
if len(sys.argv) > 1 and sys.argv[1] == "v3":
    with tempfile.TemporaryDirectory() as tmp:
        v3art(tmp)
    sys.exit(0)
if len(sys.argv) > 1 and sys.argv[1] == "bg":
    backgrounds(sys.argv[2] if len(sys.argv) > 2 else os.path.expanduser("~/Desktop/Glooms BGs"))
elif len(sys.argv) > 1 and sys.argv[1] == "corner":
    corner()
else:
    corner()
    with tempfile.TemporaryDirectory() as tmp:
        for n, (w, h, c) in ICONS.items():
            icon(n, w, h, c, tmp)
        boxed("check", 16 * K, tmp)
    drawn()
    ticks()
