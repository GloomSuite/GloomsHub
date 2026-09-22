-- ============================================================
-- Shapes.lua — Gloom's Hub: the SUITE's silhouette catalog.
--
-- One catalog, one set of art, for every tool that wants to draw
-- something shaped: Gloom's Bars masks its action buttons with
-- these, Gloom's Auras masks aura icons and traces shaped glows
-- with the same keys and the same files.
--
-- ★ WHY THIS LIVES HERE. The art and the catalog were GB's until
-- 2026-08-25 — reasonably, since GB was the only thing that drew
-- a shape. Once GA wanted the same silhouettes the choice was to
-- duplicate 136 files or to give them one home, and the suite's
-- standing rule is that a shared fact has exactly ONE home. GB
-- still owns which shape a button wears and how its glows are
-- triggered; what moved is the art and the vocabulary, nothing
-- about how either tool decides to use them.
--
-- ⚠ THE FILES ARE THE CONTRACT. `key` and `part` index real files
-- in Media\art\shapes\. Adding a shape means adding its art AND
-- its row here; renaming a key orphans every saved profile that
-- stored it. Treat both as append-only.
-- ============================================================

GloomsHub = GloomsHub or {}
_G.GloomsHub = GloomsHub

-- The path root is a local literal rather than GloomsHub.MEDIA so this file has
-- no load-order coupling to Skin.lua (which is what sets that alias).
local ART = "Interface\\AddOns\\GloomsHub\\Media\\art\\shapes\\"

-- { key, aspect, orient, label } in picker order. aspect = width:height of the
-- silhouette's footprint; orient groups the picker and tells the plate-extension
-- option in GB which shapes may carry it.
local SHAPE_DEF = {
    -- 1:1 footprint
    { "circle",        1,   "square",    "Circle" },
    { "square",        1,   "square",    "Square" },
    { "roundsq1",      1,   "square",    "Rounded 1" },
    { "roundsq2",      1,   "square",    "Rounded 2" },
    { "roundsq3",      1,   "square",    "Rounded 3" },
    { "hexagon",       1,   "square",    "Hexagon" },
    { "diamond",       1,   "square",    "Diamond" },
    { "tombstone",     1,   "square",    "Tombstone" },
    { "tombstone-inv", 1,   "square",    "Tombstone (inv.)" },
    -- portrait-elongated (3:2 & 2:1) — these carry the plate-extension option
    { "pill32",        1.5, "portrait",  "Pill 3:2" },
    { "pill21",        2,   "portrait",  "Pill 2:1" },
    { "square32",      1.5, "portrait",  "Tall square 3:2" },
    { "square21",      2,   "portrait",  "Tall square 2:1" },
    { "roundsq1-32",   1.5, "portrait",  "Tall rounded 1 · 3:2" },
    { "roundsq1-21",   2,   "portrait",  "Tall rounded 1 · 2:1" },
    { "roundsq2-32",   1.5, "portrait",  "Tall rounded 2 · 3:2" },
    { "roundsq2-21",   2,   "portrait",  "Tall rounded 2 · 2:1" },
    { "roundsq3-32",   1.5, "portrait",  "Tall rounded 3 · 3:2" },
    { "roundsq3-21",   2,   "portrait",  "Tall rounded 3 · 2:1" },
    -- landscape-elongated (3:2 & 2:1) — no plate extension
    { "square32w",     1.5, "landscape", "Wide square 3:2" },
    { "square21w",     2,   "landscape", "Wide square 2:1" },
}

GloomsHub.SHAPES      = {}   -- key → { aspect, orient, label }
GloomsHub.SHAPE_ORDER = {}   -- ordered keys (picker order)
for _, d in ipairs(SHAPE_DEF) do
    GloomsHub.SHAPES[d[1]] = { aspect = d[2], orient = d[3], label = d[4] }
    GloomsHub.SHAPE_ORDER[#GloomsHub.SHAPE_ORDER + 1] = d[1]
end

-- Grouped for a thumbnail-grid picker.
GloomsHub.SHAPE_GROUPS = {
    { title = "1:1", keys = { "circle", "square", "roundsq1", "roundsq2", "roundsq3",
                              "hexagon", "diamond", "tombstone", "tombstone-inv" } },
    { title = "Portrait", keys = { "pill32", "pill21", "square32", "square21",
                                   "roundsq1-32", "roundsq1-21", "roundsq2-32", "roundsq2-21",
                                   "roundsq3-32", "roundsq3-21" } },
    { title = "Landscape", keys = { "square32w", "square21w" } },
}

-- The parts every shape ships:
--   base   — the solid silhouette. The icon MASK, and the mask for area effects.
--   outer  — the outward bloom, drawn UNDER the icon so only its falloff shows.
--   inner  — the interior-edge tint, drawn OVER the icon, fading to a clean centre.
--   rim    — the outline band. Masks edge-tracing effects (rim flash, comets).
--   line   — a dashed version of the rim, for marching-ants effects.
--   swipe  — the cooldown sweep art cut to the silhouette.
-- All are white and tintable: one pair serves procs / hover / cast / finish,
-- differing only by the colour they are given.
GloomsHub.SHAPE_PARTS = { "base", "outer", "inner", "rim", "line", "swipe" }

-- The five 2:1 portraits additionally ship a SPLIT swipe (`swipe-t` / `swipe-b`)
-- for sweeping the two halves of a plate independently. Nothing else has one, so
-- ask before reaching for it — a missing texture path draws nothing at all, in
-- silence, which is a miserable thing to debug.
local SPLIT_SWIPE = {
    ["pill21"] = true, ["roundsq1-21"] = true, ["roundsq2-21"] = true,
    ["roundsq3-21"] = true, ["square21"] = true,
}
function GloomsHub:HasSplitSwipe(key) return SPLIT_SWIPE[key] == true end

-- The path to one shape's art. Returns nil for an unknown key rather than a path
-- that cannot resolve, so callers can fall back instead of drawing nothing.
function GloomsHub:ShapeAsset(key, part)
    if not (key and GloomsHub.SHAPES[key]) then return nil end
    return ART .. key .. "-" .. (part or "base") .. ".png"
end

-- Metadata for a key, falling back to circle so callers never nil-index.
function GloomsHub:ShapeInfo(key)
    return (key and GloomsHub.SHAPES[key]) or GloomsHub.SHAPES.circle
end

-- Anchor `tex` to a rect grown outward from `icon`, the way every shaped glow and
-- effect in the suite expects: at grow = 0 the span is the icon plus min(w, h) on
-- each axis, centred, so the bloom has room without the silhouette drifting. `grow`
-- adds the border clearance, distributed by aspect so an elongated shape grows
-- proportionally rather than smearing along its long axis.
--
-- THE one copy (since 2026-09-20). GloomsBars' `hgAnchor` — its layout engine's
-- anchor for every icon / plate / border mask and glow — delegates here, as do
-- GloomsHub.Effects' modules and Gloom's Auras. Change the formula and every
-- shaped thing in the suite moves together; there is no second copy to keep in step.
function GloomsHub:GrowAnchor(tex, icon, grow)
    grow = grow or 0
    local w, h = icon:GetWidth(), icon:GetHeight()
    local m0 = 0.5 * math.min(w, h)
    local aspect = math.max(w, h) / math.max(1, math.min(w, h))
    local addS, addL = 2 * grow, grow * (aspect + 1) / aspect
    local mx = m0 + (w <= h and addS or addL)
    local my = m0 + (h < w and addS or addL)
    tex:ClearAllPoints()
    tex:SetPoint("TOPLEFT", icon, "TOPLEFT", -mx, my)
    tex:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", mx, -my)
end

-- ============================================================
-- BAR SHAPES — Gloom's Unit Frames' silhouettes (2026-09-21).
-- A SEPARATE family on the same mechanism. The owner: the button shapes
-- above are not to be offered to a unit frame — "they are fundamentally
-- different things" — so this list and its art (Media\art\barshapes\) are
-- their own, and the two never mix in a picker.
-- Parts: base (the mask), base-s (a quarter-size copy with an anti-aliased
-- edge — the base art's edge is binary and a 24 px shard drew it jagged)
-- and rim (the outline). No glow parts: nothing animates a unit frame.
-- Each row records its CANVAS and the silhouette's FOOTPRINT on it, in px:
-- a bar sizes itself to the footprint and places the mask so the footprint
-- lands on the bar. That is what lets a nested SET — three brackets drawn
-- as one composition, exported as three files on one canvas — line up by
-- simply sharing a size and a position: each member's footprint is where
-- it was drawn, off-centre or not.
--   { key, label, canvasW, canvasH, x0, y0, x1, y1 [, set = "name"] }
-- ============================================================
local BAR_ART = "Interface\\AddOns\\GloomsHub\\Media\\art\\barshapes\\"
-- Generated by tools/gen-barshapes.py, which also prints these rows.
local BAR_SHAPE_DEF = {
    { "orb",            "Orb",              512, 512,  128, 128, 385, 385 },
    { "pill",           "Pill",             512, 768,  128, 128, 385, 641 },
    -- the bracket SET: one composition, three files; wear all three at one
    -- size and position and they nest (option B — concentric, tips on the
    -- same radial angle — the owner's pick 2026-09-21)
    { "bracket-outer",  "Bracket · outer",  512, 1024,  64,  64, 270, 960, set = "bracket" },
    { "bracket-middle", "Bracket · middle", 512, 1024, 160, 126, 344, 899, set = "bracket" },
    { "bracket-inner",  "Bracket · inner",  512, 1024, 256, 187, 417, 837, set = "bracket" },
    -- the TALL CRESCENT set — the owner's art (2026-09-21), imported by the
    -- generator: three true crescents, largest on the right, one canvas
    { "tallcrescent-large",  "Tall crescent · large",  1024, 1024, 558,  41, 844, 982, set = "tallcrescent" },
    { "tallcrescent-medium", "Tall crescent · medium", 1024, 1024, 347, 136, 574, 887, set = "tallcrescent" },
    { "tallcrescent-small",  "Tall crescent · small",  1024, 1024, 179, 231, 347, 792, set = "tallcrescent" },
}
GloomsHub.BAR_SHAPES      = {}
GloomsHub.BAR_SHAPE_ORDER = {}
for _, d in ipairs(BAR_SHAPE_DEF) do
    GloomsHub.BAR_SHAPES[d[1]] = { label = d[2], canvas = { d[3], d[4] }, footprint = { d[5], d[6], d[7], d[8] }, set = d.set }
    GloomsHub.BAR_SHAPE_ORDER[#GloomsHub.BAR_SHAPE_ORDER + 1] = d[1]
end
-- A set's members share ONE scale: `setFootprint` is the union of the
-- members' footprints, and a bar's Size measures THAT short side, so the
-- same Size on every member keeps them nested. A lone shape scales by its own.
do
    local union = {}
    for _, info in pairs(GloomsHub.BAR_SHAPES) do
        if info.set then
            local u, f = union[info.set], info.footprint
            if not u then union[info.set] = { f[1], f[2], f[3], f[4] }
            else u[1], u[2], u[3], u[4] = math.min(u[1], f[1]), math.min(u[2], f[2]), math.max(u[3], f[3]), math.max(u[4], f[4]) end
        end
    end
    for _, info in pairs(GloomsHub.BAR_SHAPES) do
        if info.set then info.setFootprint = union[info.set] end
    end
end
function GloomsHub:BarShapeAsset(key, part)
    if not (key and GloomsHub.BAR_SHAPES[key]) then return nil end
    return BAR_ART .. key .. "-" .. (part or "base") .. ".png"
end
function GloomsHub:BarShapeInfo(key)
    return (key and GloomsHub.BAR_SHAPES[key]) or GloomsHub.BAR_SHAPES.orb
end
