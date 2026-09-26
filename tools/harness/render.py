"""Draw a dump of the Suite window (from dump.lua) the way WoW would lay it out.

  python3 render.py dump-<page>.jsonl out.png [scale]

Anchors are resolved into window coordinates; textures, colour fills, gradients and text are
drawn in WoW's layer order (frame level, then BACKGROUND < BORDER < ARTWORK < OVERLAY), clipped
by ScrollFrames. An icon ID (a number) draws as a grey square: the client's art is not here.
Font widths are PIL's, so text measured by the stand-in (wow.lua) can differ by a few pixels."""
import json, sys, math, os, re
HERE = os.path.dirname(os.path.abspath(__file__))
HUB = os.path.dirname(os.path.dirname(HERE))          # …/GloomsHub
SUITE = os.path.dirname(HUB)                           # the folder the suite repos sit in
from PIL import Image, ImageDraw, ImageFont
objs, root = {}, None
for line in open(sys.argv[1]):
    d = json.loads(line)
    if "root" in d: root = d["root"]; continue
    objs[d["id"]] = d
out = sys.argv[2]; S = float(sys.argv[3]) if len(sys.argv) > 3 else 1.0
WIN_W, WIN_H = 1060, 740
FONTS = {"Saira-Regular": os.path.join(HUB, "Media", "fonts", "Saira-Regular.ttf"),
         "Saira-Bold": os.path.join(HUB, "Media", "fonts", "Saira-Bold.ttf"),
         "Saira-Medium": os.path.join(HUB, "Media", "fonts", "Saira-Medium.ttf"),
         "Michroma-Regular": os.path.join(HUB, "Media", "fonts", "Michroma-Regular.ttf"),
         "Play-Regular": os.path.join(HUB, "Media", "fonts", "Play-Regular.ttf"),
         "Play-Bold": os.path.join(HUB, "Media", "fonts", "Play-Bold.ttf"),
         "GeneralSans-Regular": os.path.join(HUB, "Media", "fonts", "GeneralSans-Regular.ttf"),
         "GeneralSans-Medium": os.path.join(HUB, "Media", "fonts", "GeneralSans-Medium.ttf"),
         "GeneralSans-Semibold": os.path.join(HUB, "Media", "fonts", "GeneralSans-Semibold.ttf"),
         "Khand-SemiBold": os.path.join(HUB, "Media", "fonts", "Khand-SemiBold.ttf"),
         "Khand-Medium": os.path.join(HUB, "Media", "fonts", "Khand-Medium.ttf")}
_fc = {}
def font(o):
    f = o.get("font") or ["Saira-Regular", 12]
    name = os.path.splitext(os.path.basename(str(f[0]).replace("\\", "/")))[0]
    path = FONTS.get(name, FONTS["Saira-Regular"])
    size = max(1, int(round(float(f[1]) * S)))
    k = (path, size)
    if k not in _fc: _fc[k] = ImageFont.truetype(path, size)
    return _fc[k], float(f[1])
def strip(t): return re.sub(r"\|c[0-9a-fA-F]{8}|\|r", "", t or "")
def segments(t, base):
    out, col, i = [], base, 0
    for m in re.finditer(r"\|c([0-9a-fA-F]{8})|\|r", t):
        if m.start() > i: out.append((t[i:m.start()], col))
        if m.group(1): h = m.group(1)[2:]; col = (int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255, 1)
        else: col = base
        i = m.end()
    if i < len(t): out.append((t[i:], col))
    return out
def eff_scale(o):
    s, x = 1.0, o
    while x and x["id"] != root:
        s *= float(x.get("scale") or 1); x = objs.get(x["parent"])
    return s
rects = {}
def textw(o):
    f, _ = font(o); return f.getlength(strip(o.get("text") or "")) / S
def rect(oid):
    if oid in rects: return rects[oid]
    o = objs.get(oid)
    if not o or oid == root: return (0.0, 0.0, float(WIN_W), float(WIN_H))
    rects[oid] = None
    par = objs.get(o["parent"])
    # a scroll child sits at its scroll frame's top-left, moved up by the scroll
    if par and par.get("child") == oid:
        pr = rect(par["id"]); s = eff_scale(o)
        r = (pr[0], pr[1] - float(par.get("vscroll") or 0) * s, pr[0] + float(o["w"]) * s, pr[1] - float(par.get("vscroll") or 0) * s + float(o["h"]) * s)
        rects[oid] = r; return r
    s = eff_scale(o)
    w, h = float(o["w"] or 0) * s, float(o["h"] or 0) * s
    if o["kind"] == "FontString":
        if w <= 0: w = textw(o) * s
        if h <= 0: h = font(o)[1] * 1.25 * s
    L = R_ = T = B = CX = CY = None
    for p, rel, rp, x, y in (o.get("points") or []):
        tr = rect(rel) if rel else rect(o["parent"])
        if tr is None: continue
        ax = tr[0] if "LEFT" in rp else (tr[2] if "RIGHT" in rp else (tr[0] + tr[2]) / 2)
        ay = tr[1] if "TOP" in rp else (tr[3] if "BOTTOM" in rp else (tr[1] + tr[3]) / 2)
        ax += float(x) * s; ay -= float(y) * s
        if "LEFT" in p: L = ax
        elif "RIGHT" in p: R_ = ax
        else: CX = ax
        if "TOP" in p: T = ay
        elif "BOTTOM" in p: B = ay
        else: CY = ay
    if L is None and R_ is None and CX is None: return None
    if L is not None and R_ is not None: pass
    elif L is not None: R_ = L + w
    elif R_ is not None: L = R_ - w
    else: L, R_ = CX - w / 2, CX + w / 2
    if T is not None and B is not None: pass
    elif T is not None: B = T + h
    elif B is not None: T = B - h
    elif CY is not None: T, B = CY - h / 2, CY + h / 2
    else: return None
    r = (L, T, R_, B); rects[oid] = r; return r
def visible(o):
    x = o
    while x:
        if not x.get("shown", True): return False
        if x["id"] == root: return True
        x = objs.get(x["parent"])
    return False
def alpha(o):
    a, x = 1.0, o
    while x:
        a *= float(x.get("alpha") if x.get("alpha") is not None else 1)
        if x["id"] == root: break
        x = objs.get(x["parent"])
    return a
def clip(o):
    c, x = None, objs.get(o["parent"])
    while x:
        if x["kind"] == "ScrollFrame":
            r = rect(x["id"])
            if r: c = r if c is None else (max(c[0], r[0]), max(c[1], r[1]), min(c[2], r[2]), min(c[3], r[3]))
        if x["id"] == root: break
        x = objs.get(x["parent"])
    return c
LAYER = {"BACKGROUND": 0, "BORDER": 1, "ARTWORK": 2, "OVERLAY": 3, "HIGHLIGHT": 4}
def frame_level(o):
    x = objs.get(o["parent"]) if o["kind"] in ("Texture", "FontString", "MaskTexture") else o
    return float((x or o).get("level") or 0)
def texfile(t):
    if not isinstance(t, str): return None
    p = t.replace("\\", "/")
    for pre, base in [("Interface/AddOns/%s/" % r, os.path.join(SUITE, r) + "/") for r in ("GloomsHub", "GloomsAuras", "GloomsBars", "GloomsUnitFrames", "GloomsOverlays", "GloomsPortraits")]:
        if p.startswith(pre):
            f = base + p[len(pre):]
            if not os.path.splitext(f)[1]: f += ".png" if os.path.exists(f + ".png") else ".tga"
            return f if os.path.exists(f) else None
    return None
canvas = Image.new("RGBA", (int(WIN_W * S), int(WIN_H * S)), (0, 0, 0, 255))
items = [o for o in objs.values() if o["kind"] in ("Texture", "FontString", "EditBox") and visible(o)]
items.sort(key=lambda o: (frame_level(o), LAYER.get(o.get("layer") or "ARTWORK", 2), float(o.get("sub") or 0), o["id"]))
_img = {}
for o in items:
    r = rect(o["id"])
    if not r: continue
    a = alpha(o)
    if a <= 0.001: continue
    L, T, R_, B = [v * S for v in r]
    w, h = int(round(R_ - L)), int(round(B - T))
    if w <= 0 or h <= 0: continue
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    if o["kind"] == "Texture":
        vc = o.get("vc") or [1, 1, 1, 1]
        f = texfile(o.get("tex"))
        if o.get("fill") and not f:
            c = o["fill"]; col = [c[0] * vc[0], c[1] * vc[1], c[2] * vc[2], (c[3] if len(c) > 3 else 1) * vc[3]]
            if o.get("grad"):
                g = o["grad"]; c1, c2 = g[1], g[2]
                px = layer.load()
                for yy in range(h):
                    for xx in range(w):
                        t = (1 - yy / max(1, h - 1)) if g[0] == "VERTICAL" else xx / max(1, w - 1)
                        cc = [c1[i] + (c2[i] - c1[i]) * t for i in range(4)]
                        px[xx, yy] = tuple(int(255 * max(0, min(1, v))) for v in (cc[0] * col[0], cc[1] * col[1], cc[2] * col[2], cc[3] * col[3]))
            else:
                layer.paste(tuple(int(255 * max(0, min(1, v))) for v in col), (0, 0, w, h))
        elif f:
            if f not in _img: _img[f] = Image.open(f).convert("RGBA")
            src = _img[f]
            tc = o.get("tc")
            if tc and len(tc) >= 4:
                l_, r2, t_, b_ = tc[0], tc[1], tc[2], tc[3]
                flip = l_ > r2
                if flip: l_, r2 = r2, l_
                src = src.crop((int(l_ * src.width), int(t_ * src.height), max(int(l_ * src.width) + 1, int(r2 * src.width)), max(int(t_ * src.height) + 1, int(b_ * src.height))))
                if flip: src = src.transpose(Image.FLIP_LEFT_RIGHT)
            rot = o.get("rot") or 0
            if abs(rot) > 0.01: src = src.rotate(math.degrees(rot), expand=False)
            im = src.resize((w, h), Image.LANCZOS)
            ch = im.split()
            layer = Image.merge("RGBA", [ch[i].point(lambda v, k=vc[i]: int(v * k)) for i in range(4)])
        elif o.get("tex") is not None:
            layer.paste((110, 110, 120, int(255 * vc[3])), (0, 0, w, h))   # an icon ID: grey stand-in
        else:
            continue
    else:
        text = o.get("text") or ""
        if not text: continue
        f, _ = font(o)
        base = tuple((o.get("tcolor") or [1, 1, 1, 1])[:3]) + (1,)
        segs = segments(text, base)
        total = sum(f.getlength(s) for s, _ in segs)
        ins = o.get("insets") or [0, 0]
        jh = o.get("jh") or ("LEFT" if o["kind"] == "EditBox" else "CENTER")
        x0 = float(ins[0]) * S if jh == "LEFT" else (w - total - float(ins[1] or 0) * S if jh == "RIGHT" else (w - total) / 2)
        asc, desc = f.getmetrics()
        y0 = (h - (asc + desc)) / 2
        d = ImageDraw.Draw(layer)
        for s_, c in segs:
            d.text((x0, y0), s_, font=f, fill=tuple(int(255 * v) for v in c[:3]) + (255,))
            x0 += f.getlength(s_)
    if a < 0.999:
        layer.putalpha(layer.split()[3].point(lambda v: int(v * a)))
    cl = clip(o)
    if cl:
        cL, cT, cR, cB = [v * S for v in cl]
        x0c, y0c, x1c, y1c = max(0, cL - L), max(0, cT - T), min(w, cR - L) - 1, min(h, cB - T) - 1
        if x1c < x0c or y1c < y0c: continue            # scrolled wholly out of view
        mask = Image.new("L", layer.size, 0)
        ImageDraw.Draw(mask).rectangle([x0c, y0c, x1c, y1c], fill=255)
        layer.putalpha(Image.composite(layer.split()[3], Image.new("L", layer.size, 0), mask))
    canvas.alpha_composite(layer, (int(round(L)), int(round(T))))
canvas.save(out); print(out)
