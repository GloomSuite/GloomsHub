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

3. THE PAGES' GLASS — only with `bg`:

     python3 tools/gen-glass-art.py bg ["<folder of exports>"]   (default ~/Desktop/Glooms BGs)

   The owner exports each screen from Figma at 2x (2120 x 1480) with only the background and
   the glass panels showing (the panels' contents at 0% opacity, everything else hidden), named
   as the screen is. ★ NOT RESAMPLED (2026-09-26): the export's own 2120 x 1480 pixels are cut
   into four power-of-two tiles, <tool>/Media/glass/<page>-a|b|c|d.png — a 2048 x 1024 (the top
   left), 72 x 1024 on a 128 canvas (top right), 2048 x 456 on a 512 canvas (bottom left),
   72 x 456 on 128 x 512 (bottom right) — which the Shell lays edge to edge (GLASS_TILES). At the
   window's 2-pixels-per-unit scale they land on the screen pixel for pixel. (The first cut
   squeezed each export to 2048 wide, and the game then stretched it back up: soft.)
   Re-export ONE screen after a layout change and re-run this.
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

SUITE = os.path.dirname(ROOT)
GLASS = {   # the export's name (Figma's screen name) → (repo, page id)
    "Glass Auras, Aura Triggers": ("GloomsAuras", "triggers"),
    "Glass Auras, Appearance, SIze and Position": ("GloomsAuras", "appearance"),
    "Glass Auras, Bar Fill & Readouts": ("GloomsAuras", "bar"),
    "Glass Auras, Text": ("GloomsAuras", "text"),
    "Glass Auras, Effects Motion & Sound": ("GloomsAuras", "effects"),
    "Glass Auras, Aura Load Conditions": ("GloomsAuras", "load"),
    "Glass Bars, Icon Size & Shape": ("GloomsBars", "shape"),
    "Glass Bars, Decoration Layers": ("GloomsBars", "deco"),
    "Glass Bars, Text": ("GloomsBars", "text"),
    "Glass Bars, Glows & Animations": ("GloomsBars", "glows"),
    "Glass Bars, Casts & Channels": ("GloomsBars", "casts"),
    "Glass Bars, Cooldowns & Availability": ("GloomsBars", "cooldowns"),
    "Glass Bars, Bar Visibility Layout & Presets": ("GloomsBars", "layout"),
}

TILES = [("a", 0, 0, 2048, 1024, 2048, 1024), ("b", 2048, 0, 72, 1024, 128, 1024),
         ("c", 0, 1024, 2048, 456, 2048, 512), ("d", 2048, 1024, 72, 456, 128, 512)]   # name, x, y, w, h, canvas w, h

def backgrounds(folder):
    for name, (repo, page) in GLASS.items():
        src = os.path.join(folder, name + ".png")
        if not os.path.exists(src):
            print("missing:", name); continue
        im = Image.open(src).convert("RGBA")
        if im.size != (2120, 1480):
            print("NOT 2x (2120 x 1480):", name, im.size); continue
        base = os.path.join(SUITE, repo, "Media", "glass")
        os.makedirs(base, exist_ok=True)
        old = os.path.join(base, page + ".png")
        if os.path.exists(old): os.remove(old)          # the first cut's single squeezed file
        for t, x, y, w, h, cw, ch in TILES:
            out = Image.new("RGBA", (cw, ch), (0, 0, 0, 255))
            out.paste(im.crop((x, y, x + w, y + h)), (0, 0))
            out.save(os.path.join(base, "%s-%s.png" % (page, t)), optimize=True)
        print(repo + "/Media/glass/" + page + "-a|b|c|d.png")

if len(sys.argv) > 1 and sys.argv[1] == "bg":
    backgrounds(sys.argv[2] if len(sys.argv) > 2 else os.path.expanduser("~/Desktop/Glooms BGs"))
else:
    with tempfile.TemporaryDirectory() as tmp:
        for n, (w, h, c) in ICONS.items():
            icon(n, w, h, c, tmp)
        boxed("check", 16 * K, tmp)
    drawn()
    ticks()
