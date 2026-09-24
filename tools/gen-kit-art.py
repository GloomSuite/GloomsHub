#!/usr/bin/env python3
"""Art for the second Suite redesign (GloomSuite UI 2, 2026-09-23). Re-run after any change here.

  python3 tools/gen-kit-art.py

1. PILL END-CAPS — Media/ui/pill/cap<H>-fill.png and cap<H>-rim.png, one pair per pill height.
   The mocks' pills are CSS `rounded-[1000px]` with `border-l border-r` only: a full-height
   semicircle each end, and a border that is 1px thick at the middle of each end and TAPERS TO
   NOTHING at top and bottom (the inner edge of a left/right-only border is an ellipse whose
   horizontal radius is one pixel shorter than the outer circle's; its vertical radius is not).
   The fill is the whole outer shape (background-clip defaults to border-box).
   A pill in the kit is three pieces, so nothing is ever stretched and no nine-slice is involved:
   the left cap, a plain colour rectangle between the caps, the right cap (the same file with
   its texcoords flipped). Fill and rim are separate files so the kit can give them different
   alpha (the fill at 10%, the rim at 100%).
   Canvas is 16x32 (power of two); the cap sits in the top-left W x H corner, W = ceil(H/2), and
   the kit crops to it with SetTexCoord. For an odd H the last column is the cap's straight edge,
   filled solid, so the middle rectangle starts on a whole pixel.

3. SMALL MARKS (white, tinted in Lua) — Media/ui/check.png (the checkbox's tick, the mock's
   "Vector" in node 719:… Frame 319, 16x16 box), circle.png (a colour swatch), circle-dash.png
   (the swatch with NO colour set: a dashed ring), dial-ticks.png (the dark dial's 21 ticks,
   1px wide at a 5px pitch, 12 tall — the mock's Frame 305, 101 wide).

2. THE WINDOW WORDMARK — Media/ui/suite-wordmark.png: "gloom" white + "SUITE" in the mock's
   horizontal gradient (Figma node 691:14145). A FontString can take one colour per character,
   not a gradient, so the mark is art. Drawn at 2x for crispness; the printed numbers are the
   texcoords and display size the Shell uses.
"""
import math, os
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
UI = os.path.join(ROOT, "Media", "ui")
SS = 16                       # supersample factor for the caps
PILL_HEIGHTS = (22, 25)       # the mocks' two pill heights: 22 (small row), 25 (standard)


def cap(h):
    w = math.ceil(h / 2)
    r = h / 2.0
    big_w, big_h = w * SS, h * SS
    fill = Image.new("L", (big_w, big_h), 0)
    rim = Image.new("L", (big_w, big_h), 0)
    fp, rp = fill.load(), rim.load()
    for yy in range(big_h):
        y = (yy + 0.5) / SS
        dy = y - r
        for xx in range(big_w):
            x = (xx + 0.5) / SS
            dx = x - r                       # circle centre at (r, r)
            if dx >= 0:                      # past the centre: the straight body of the pill
                fp[xx, yy] = 255
                continue
            in_outer = dx * dx + dy * dy <= r * r
            if not in_outer:
                continue
            fp[xx, yy] = 255
            rx = r - 1.0                     # the border's inner edge: horizontal radius r-1, vertical r
            in_inner = rx > 0 and (dx * dx) / (rx * rx) + (dy * dy) / (r * r) <= 1.0
            if not in_inner:
                rp[xx, yy] = 255
    fill = fill.resize((w, h), Image.LANCZOS)
    rim = rim.resize((w, h), Image.LANCZOS)
    out = []
    for mask in (fill, rim):
        canvas = Image.new("RGBA", (16, 32), (255, 255, 255, 0))
        white = Image.new("RGBA", (w, h), (255, 255, 255, 255))
        white.putalpha(mask)
        canvas.paste(white, (0, 0))
        out.append(canvas)
    return w, out


def pills():
    d = os.path.join(UI, "pill")
    os.makedirs(d, exist_ok=True)
    for h in PILL_HEIGHTS:
        w, (fill, rim) = cap(h)
        fill.save(os.path.join(d, "cap%d-fill.png" % h))
        rim.save(os.path.join(d, "cap%d-rim.png" % h))
        print("pill H=%d  cap W=%d  texcoords (0, %.6f, 0, %.6f)" % (h, w, w / 16.0, h / 32.0))


def lerp(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))


# The mock's stops, as fractions of the whole wordmark's width (see the note in wordmark()).
STOPS = [(0.47115, (225, 75, 75)), (0.64423, (234, 148, 56)), (0.84135, (79, 198, 103)), (1.0, (19, 160, 247))]


def grad_at(t):
    if t <= STOPS[0][0]:
        return STOPS[0][1]
    for (t0, c0), (t1, c1) in zip(STOPS, STOPS[1:]):
        if t <= t1:
            return lerp(c0, c1, (t - t0) / (t1 - t0))
    return STOPS[-1][1]


def wordmark():
    font = ImageFont.truetype(os.path.join(ROOT, "Media", "fonts", "Michroma-Regular.ttf"), 44)   # 22px at 2x
    a, b = "gloom", "SUITE"
    wa = font.getlength(a)
    full = a + b
    l, t, r_, btm = font.getbbox(full)
    W, H = 512, 64
    im = Image.new("RGBA", (W, H), (255, 255, 255, 0))
    ox, oy = -l + 1, -t + 1
    # "gloom" white
    ImageDraw.Draw(im).text((ox, oy), a, font=font, fill=(255, 255, 255, 255))
    # "SUITE" as a mask, then the gradient through it
    mask = Image.new("L", (W, H), 0)
    ImageDraw.Draw(mask).text((ox + wa, oy), b, font=font, fill=255)
    # ⚠ Figma measures a text-range gradient across the WHOLE text layer, not the range it is
    # applied to — so the stops are fractions of "gloomSUITE"'s width. (Measured against the
    # SUITE span alone, S and U both land in the solid red and the mark reads as stepped.)
    x0 = ox
    fw = font.getlength(full)
    grad = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gp = grad.load()
    for x in range(W):
        tt = min(1.0, max(0.0, (x - x0) / fw))
        c = grad_at(tt)
        for y in range(H):
            gp[x, y] = c + (255,)
    im.paste(grad, (0, 0), mask)
    ink_w, ink_h = int(math.ceil(r_ - l + 2)), int(math.ceil(btm - t + 2))
    im.save(os.path.join(UI, "suite-wordmark.png"))
    print("wordmark ink %dx%d on %dx%d  → display %.1f x %.1f, texcoords (0, %.6f, 0, %.6f)"
          % (ink_w, ink_h, W, H, ink_w / 2, ink_h / 2, ink_w / W, ink_h / H))


def white(mask):
    im = Image.new("RGBA", mask.size, (255, 255, 255, 0)); im.putalpha(mask); return im


def marks():
    S = 32
    # the tick: the mock's check runs (2.6, 6.4) → (5.6, 12.3) → (13.1, 3.6) in a 16px box
    big = Image.new("L", (16 * S, 16 * S), 0)
    d = ImageDraw.Draw(big)
    pts = [(2.9, 6.6), (5.65, 11.9), (12.9, 3.8)]
    d.line([(x * S, y * S) for x, y in pts], fill=255, width=int(1.55 * S), joint="curve")
    for x, y in (pts[0], pts[-1]):
        r = 0.775 * S; d.ellipse([x * S - r, y * S - r, x * S + r, y * S + r], fill=255)
    white(big.resize((16, 16), Image.LANCZOS)).save(os.path.join(UI, "check.png"))
    # a solid disc and a dashed ring, both 32x32 (drawn 20x20 in the kit)
    n = 32 * S
    disc = Image.new("L", (n, n), 0); ImageDraw.Draw(disc).ellipse([S, S, n - S, n - S], fill=255)
    white(disc.resize((32, 32), Image.LANCZOS)).save(os.path.join(UI, "circle.png"))
    ring = Image.new("L", (n, n), 0); dr = ImageDraw.Draw(ring)
    c, r, w = n / 2.0, n / 2.0 - 1.5 * S, 1.6 * S
    for i in range(12):                       # 12 dashes, half the circumference inked
        a0 = i * 30.0; dr.arc([c - r, c - r, c + r, c + r], a0, a0 + 15, fill=255, width=int(w))
    white(ring.resize((32, 32), Image.LANCZOS)).save(os.path.join(UI, "circle-dash.png"))
    # the dark dial's ticks: 21 columns at x = 0, 5, …, 100, 12 tall, on a 128x16 canvas
    t = Image.new("L", (128, 16), 0); tp = t.load()
    for i in range(21):
        for y in range(12): tp[i * 5, y] = 255
    white(t).save(os.path.join(UI, "dial-ticks.png"))
    print("marks: check.png circle.png circle-dash.png dial-ticks.png")


if __name__ == "__main__":
    pills()
    wordmark()
    marks()
