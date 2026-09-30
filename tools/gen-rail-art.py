#!/usr/bin/env python3
"""Gloom's Hub — the TOOL RAIL's art (the owner's Figma "Frame 614", 2026-09-30).

A column of small vertical tabs beside a tool's selector window, one per tool:
Sansation Regular 9, capitals, reading bottom to top; 4 units of padding across
the text and 8 along it; the OUTER corners (the left) rounded 6. WoW cannot
rotate a FontString, so each label is drawn here, white, to be tinted in game —
lilac-white on violet, dark purple on lime for the open tool.

  Media/ui/rail-<id>-bg.png    the tab's shape, white, 18 x h units at 4 texels a unit
  Media/ui/rail-<id>-text.png  the label, white, same size, already turned

h = the label's width at Sansation 9 + 16 (the mock: 47, 40, 76, 64, 46).
"""
import os
from PIL import Image, ImageDraw, ImageFont

HUB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(HUB, "Media", "ui")
FONT = os.path.join(HUB, "Media", "fonts", "Sansation-Regular.ttf")
T = 4                           # texels per unit
TABS = [("auras", "AURAS", 47), ("bars", "BARS", 40), ("unitframes", "UNIT FRAMES", 76),
        ("overlays", "OVERLAYS", 64), ("media", "MEDIA", 46)]
W = 18
font = ImageFont.truetype(FONT, 9 * T)
for key, label, h in TABS:
    # the tab UNTURNED: h wide, 18 tall, its top corners round — turned a
    # quarter counter-clockwise, the top becomes the left
    bg = Image.new("L", (h * T, W * T), 0)
    ImageDraw.Draw(bg).rounded_rectangle([0, 0, h * T - 1, W * T + 6 * T], radius=6 * T, fill=255)
    txt = Image.new("L", (h * T, W * T), 0)
    d = ImageDraw.Draw(txt)
    l, t, r, b = d.textbbox((0, 0), label, font=font)
    d.text(((h * T - (r - l)) / 2 - l, (W * T - (b - t)) / 2 - t), label, font=font, fill=255)
    for name, a in (("bg", bg), ("text", txt)):
        a = a.transpose(Image.ROTATE_90)          # counter-clockwise: reads bottom to top
        im = Image.new("RGBA", a.size, (255, 255, 255, 0)); im.putalpha(a)
        im.save(os.path.join(OUT, f"rail-{key}-{name}.png"))
print("wrote", len(TABS) * 2, "files")
