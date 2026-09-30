-- ============================================================
-- Skin.lua — Gloom's Hub
-- The body of LibGloomSkin-1.0: the shared design tokens +
-- widget toolkit for the whole suite, registered via LibStub
-- (Phase C). GloomsHub is the canonical shipper; GB/GA consume
-- the lib instead of hand-maintaining their own copies.
-- GloomsHub.COLOR/.FONT/.UI stay as the Hub-side aliases.
-- The exported surface is pinned in docs/CONTRACTS.md §4 —
-- change it THERE and every consumer in the same session.
-- ============================================================

local MAJOR, MINOR = "LibGloomSkin-1.0", 18  -- MINOR 18 (2026-09-27): no mouse wheel on UI.dial / UI.gDial (it only scrolls the window now); their number box steps with ↑/↓, Shift ×10; tooltips wait 1 s (UI.TIP_DELAY) and reach inside switches, dials and colors; UI.confirm and UI.nameDialog in the two-window design (the list plate, Sansation, the kit buttons; coral only for a destroying accept). MINOR 17 (2026-09-27): "Use Class Color" in every two-window color control (UI.ClassRGB, UI.CLASS_SOURCE, UI.ClassColorValue, UI.StampClassColors, UI.pickColorWithClass); gList `font` + dividers with space; gLabel 10; label→control 15. MINOR 16 (2026-09-27, the TWO-WINDOW design, Figma "GloomSuite UI 3"): Sansation everywhere (FONT.sa/saM/saB → Sansation), every glass widget restyled and STRETCHED to its column (gButton/gSwitch/gDrop/gField/gDial/gCheck/gColor → the pill, gList), UI.gPill, UI.gRounded (gradient + per-corner), UI.gCloseDisc, UI.gSectionHead, UI.gScrollArea (fades + bar), UI.gWindow (tab · body · close · resize grip · drag anywhere), UI.gSnap, UI.gProfileBlock, UI.G_POPOUT/G_POPIN. MINOR 15 (2026-09-26, glass → solid panels): COLOR.panel, UI.G_CORNER, UI.gPanel (the rounded panel), UI.gHair/gHairRefresh (a line ONE SCREEN PIXEL thick at any scale), UI.gOutline,  every glass-kit outline and rule is a hairline; UI.gSwitch's segments abut (Figma's 0.5 strokes, inside). MINOR 14 (2026-09-25, the THIRD redesign, "Glass"): THE GLASS KIT — COLOR.lime/slate/deep/list, FONT.saM, UI.gTitle/gLabel/gButton/gSwitch/gList/gDrop/gField/gDial/gCheck/gColor/gX/gScroll/gProfileBar, UI.dial `glass` + `nobox`, UI.colorDot `dot` + `gap`. MINOR 13 (2026-09-23, the SECOND redesign, "GloomSuite UI 2"): THE DARK KIT — COLOR.void/sky/jade/coral/flame, FONT.sa/saB (Saira), UI.accentOf, UI.pill, UI.pillPick, UI.profileStack, and UI.openList (the kit list, openable from any button), the dark UI.dial, UI.plate/rule/text/box/colorDot/toggle2/pillField/xbtn/scrollPane. MINOR 12 (2026-09-21, redesign stages 2–3): UI.chip (the colour chip), the picker's colour SOURCES (selected, committed by OK), the SHORT and BARE dials, UI.cell, the revised dropdown list, the kit popover. MINOR 11: THE KIT — the redesign's tokens (COLOR.plate/ink/violet/…, FONT.ui/uiB/mark) and widgets (UI.button · segments · toggleBar · check · field · label · pick · sectionHeader · dial · wordmark · profileRow); the old widgets stay for tabs not yet migrated
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if lib then

-- ------------------------------------------------------------
-- Tokens
-- ------------------------------------------------------------

local function color(hex)
  local r = tonumber(hex:sub(1, 2), 16) / 255
  local g = tonumber(hex:sub(3, 4), 16) / 255
  local b = tonumber(hex:sub(5, 6), 16) / 255
  return { r = r, g = g, b = b, hex = hex }
end

lib.COLOR = {
  purple = color("936bff"),  -- bright purple — accents, selection, buttons
  heroic = color("8031ff"),  -- deep purple
  green  = color("20ba56"),  -- confirm green
  red    = color("c41e3a"),  -- destructive
  orange = color("ff7729"),  -- warning / accent / active state
  -- Panel base: pre-compensated so #060714 lands on screen.
  dark   = { r = 18/255, g = 19/255, b = 31/255, a = 1 },
  -- ★ THE TRANSITION (2026-09-21, redesign stage 1): the Suite window is
  -- light grey now, and every tab not yet rebuilt from the mocks still draws
  -- with THESE tokens — so `rim`, `text` and `mute` flipped to read on the
  -- light plate (they were white-ish for the near-black one), `skinPlate`
  -- paints the light plate, and the old widgets choose their text colour by
  -- how strong their fill is. The owner could not read a word of the Unit
  -- Frames tab's old sections otherwise, and the same went for every tool.
  -- All of this goes away with the last migrated tab (stage 5).
  rim    = { r = 0, g = 0, b = 0, a = 0.18 },
  -- Promoted from GB Config.lua locals (TEXT/MUTE) — now tokens.
  text   = { r = 0.16, g = 0.16, b = 0.19 },   -- body text
  mute   = { r = 0.40, g = 0.40, b = 0.45 },   -- hints / secondary

  -- ★ THE KIT (MINOR 11, 2026-09-21) — the redesign's palette, read off the
  -- PRIMITIVES frame of the owner's Figma mocks (BACKLOG 16). The nine chips,
  -- named by colour; the ROLE each plays in the mocks is the comment, and the
  -- backlog is explicit that the roles are a starting point, not a law.
  -- Everything above stays for the tabs that have not migrated yet.
  plate  = color("d2d2d2"),  -- the window
  chip   = color("d9d9d9"),  -- the lightest chip (unused in the mocks so far)
  ink    = color("444444"),  -- ACTION buttons, field labels, dial ticks
  violet = color("6c2fe6"),  -- PERSISTING STATE: active tab, chosen option, ON segment, section headers
  lilac  = color("a881f8"),  -- the tool's name in a wordmark (gloomUNIT)
  indigo = color("3b1684"),  -- an open list's plate; the picker's rim
  amber  = color("ffa04e"),  -- DESTRUCTIVE, the dial's value tick, the highlighted list row
  night  = color("110628"),  -- the colour picker's plate (the one dark surface left)
  paper  = color("ffffff"),  -- inputs
  -- The two translucent greys: #3e3e3e at 50% (a segment track, an unselected
  -- checkbox, the X, the inactive Player/Target) and at 20% (scrollbar track,
  -- Bars' side rail).
  dim    = { r = 62/255, g = 62/255, b = 62/255, a = 0.5 },
  faint  = { r = 62/255, g = 62/255, b = 62/255, a = 0.2 },
  black  = { r = 0, g = 0, b = 0 },
}

-- The lib's assets live in the Hub's folder — a locked decision: the
-- GloomsHub path is permanent, so the lib may hardcode it even when
-- embedded in a sibling addon.
lib.MEDIA = "Interface\\AddOns\\GloomsHub\\Media\\"
local FONT_DIR = lib.MEDIA .. "fonts\\"

lib.FONT = {
  title = FONT_DIR .. "Khand-SemiBold.ttf",
  head  = FONT_DIR .. "Khand-Medium.ttf",
  body  = FONT_DIR .. "GeneralSans-Regular.ttf",
  bodyM = FONT_DIR .. "GeneralSans-Medium.ttf",
  label = FONT_DIR .. "GeneralSans-Semibold.ttf",
  -- THE KIT (MINOR 11): Play for everything that is read (11 regular for
  -- buttons and inputs, 12 bold for labels, 14 bold for section headers) and
  -- Michroma for the wordmarks and the big Player/Target buttons. Both OFL,
  -- licences beside the files. ⚠ A NEW FONT LOADS AT CLIENT LAUNCH — a /reload
  -- is not enough the first time (CLAUDE.md working agreement 4).
  ui    = FONT_DIR .. "Play-Regular.ttf",
  uiB   = FONT_DIR .. "Play-Bold.ttf",
  mark  = FONT_DIR .. "Michroma-Regular.ttf",
}

local COLOR, FONT = lib.COLOR, lib.FONT
local DEFAULT_FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"

-- ------------------------------------------------------------
-- Widget toolkit
-- ------------------------------------------------------------

local UI = {}
lib.UI = UI

UI.CARET = lib.MEDIA .. "ui\\caret.png"   -- right-pointing source art
UI.CARET_DOWN = -math.pi / 2              -- rotation for "open"
UI.COG = lib.MEDIA .. "ui\\cog.png"       -- the sub-settings cog (MINOR 9); white, tint it
-- The kit's art (MINOR 11) — all white on transparent, tinted in place:
UI.ROUND  = lib.MEDIA .. "ui\\round4.png"  -- 16×16, 4px corners — the ONE nine-slice (margins 5)
UI.DOT    = lib.MEDIA .. "ui\\dot.png"     -- a disc (the checkbox's mark)
UI.TRI    = lib.MEDIA .. "ui\\tri.png"     -- a triangle pointing DOWN; +90° = right
UI.DIAL   = lib.MEDIA .. "ui\\dial.png"    -- the scrub dial's tick strip, 141×16 (13 used): 2 posts + 45 ticks, 2px gaps
UI.DIAL_C = lib.MEDIA .. "ui\\dial-c.png"  -- … with the fixed centre mark (zero), tick 22 at x=69-71
UI.DIAL_S = lib.MEDIA .. "ui\\dial-s.png"  -- the SHORT strip (MINOR 12), 78×16: 2 posts + 24 ticks, same 3px pitch
UI.PILL   = lib.MEDIA .. "ui\\pill.png"    -- 8×16 capsule (slice top/bottom 5) — the kit scrollbar

-- ★ SetFont RAISES on a missing font asset — it does NOT return false. Proven
-- in-client 2026-07-26 (FINDINGS §2): pcall(fs.SetFont, fs, "<dead path>", 14, "")
-- → false, "Invalid font asset (…): file not found". The old
-- `if not fs:SetFont(...)` guard here was written on the opposite assumption, so
-- the fallback never ran and the raise escaped into the caller — which took the
-- whole media catalog down with it (see Media.lua's RegisterAll). pcall is the
-- only guard that works. Returns true if the requested face applied, false if
-- the fallback was used — Media.lua reads that to name a broken font entry.
function UI.setFont(fs, path, size, flags)
  flags = flags or ""
  local ok, applied = pcall(fs.SetFont, fs, path, size, flags)
  if ok and applied ~= false then return true end   -- nil counts as success; only an explicit false is a refusal
  pcall(fs.SetFont, fs, DEFAULT_FONT, size, flags)  -- guarded too: this helper must never raise, whatever it is handed
  return false
end

function UI.newText(parent, font, size, cc, justify)
  local fs = parent:CreateFontString(nil, "OVERLAY")
  UI.setFont(fs, font, size)
  if cc then fs:SetTextColor(cc.r, cc.g, cc.b) end
  fs:SetJustifyH(justify or "LEFT")
  return fs
end

-- Four 1px edge textures forming a squared border. Returns a handle exposing
-- .top/.bottom/.left/.right + :SetColor(c, a?) — GA's richer variant (MINOR 2);
-- callers that ignore the return (GB, the Hub) are unaffected.
function UI.addEdges(f, cc, thick)
  thick = thick or 1
  local e = {}
  local function edge(p1, p2, w, h)
    local t = f:CreateTexture(nil, "OVERLAY")
    t:SetColorTexture(cc.r, cc.g, cc.b, cc.a or 1)
    t:SetPoint(p1); t:SetPoint(p2)
    if w then t:SetWidth(w) end
    if h then t:SetHeight(h) end
    return t
  end
  e.top    = edge("TOPLEFT", "TOPRIGHT", nil, thick)
  e.bottom = edge("BOTTOMLEFT", "BOTTOMRIGHT", nil, thick)
  e.left   = edge("TOPLEFT", "BOTTOMLEFT", thick, nil)
  e.right  = edge("TOPRIGHT", "BOTTOMRIGHT", thick, nil)
  function e:SetColor(c, a)
    for _, t in pairs({ self.top, self.bottom, self.left, self.right }) do
      t:SetColorTexture(c.r, c.g, c.b, a or c.a or 1)
    end
  end
  return e
end

-- The plate fill. ★ Since the transition (see the tokens) this is the LIGHT
-- plate, so every pre-kit panel, menu and drawer matches the window it sits
-- in and the flipped text tokens read on it. It used to be the near-black
-- navy (COLOR.dark, still there for anything that wants it).
function UI.skinPlate(f)
  local base = f:CreateTexture(nil, "BACKGROUND")
  base:SetAllPoints()
  base:SetColorTexture(COLOR.plate.r, COLOR.plate.g, COLOR.plate.b, 1)
  return base
end

-- 1px rim line (horizontal divider by default); caller anchors it.
function UI.hLine(parent)
  local t = parent:CreateTexture(nil, "ARTWORK")
  t:SetColorTexture(COLOR.rim.r, COLOR.rim.g, COLOR.rim.b, COLOR.rim.a or 0.1)
  t:SetHeight(1)
  return t
end

-- Flat, alpha-driven button. Opacity is the only state: _base (50%) vs active
-- (100%); hover brightens. Colour stays fully opaque.
-- ★ Consistent button state colour: PURPLE when off/unselected, ORANGE when
-- on/selected — for EVERY flatButton. The off colour is the button's own
-- creation colour (all are purple-family: heroic/purple); active repaints ORANGE.
function UI.flatButton(parent, w, h, cc, label, size)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(w, h)
  b._base, b._active = 0.5, false
  b._offColor = cc                       -- restored when inactive
  b.fill = b:CreateTexture(nil, "BACKGROUND")
  b.fill:SetAllPoints(); b.fill:SetColorTexture(cc.r, cc.g, cc.b, 1); b.fill:SetAlpha(b._base)
  b.text = UI.newText(b, FONT.bodyM, size or 12, { r = 1, g = 1, b = 1 }, "CENTER")
  b.text:SetPoint("CENTER")
  b:SetFontString(b.text)
  if label then b.text:SetText(label) end
  local function level() return b._active and 1 or b._base end
  local function paint()   -- fill colour follows state: orange active, off-colour otherwise
    local c = b._active and COLOR.orange or b._offColor
    b.fill:SetColorTexture(c.r, c.g, c.b, 1); b.fill:SetAlpha(level())
    -- The transition: white text on a strong fill, the dark text token on a
    -- faint one (a 20% purple over the light plate is pale lavender).
    if level() >= 0.5 then b.text:SetTextColor(1, 1, 1)
    else b.text:SetTextColor(COLOR.text.r, COLOR.text.g, COLOR.text.b) end
  end
  b:SetScript("OnEnter", function(self) if self:IsEnabled() and not self._active then self.fill:SetAlpha(math.min(1, self._base + 0.25)) end end)
  b:SetScript("OnLeave", function(self) paint() end)
  b:SetScript("OnDisable", function(self) self.fill:SetAlpha(0.2); self.text:SetTextColor(0.5, 0.5, 0.5) end)
  b:SetScript("OnEnable", function(self) paint() end)
  function b:SetActive(a) self._active = a and true or false; paint() end
  function b:SetBase(a) self._base = a; paint() end
  return b
end

-- Sliding on/off toggle — 40x20, white-10% track, square purple knob that snaps
-- flush-left (off) / flush-right (on). Position is the only state signal.
function UI.makeToggle(parent, get, set)
  local t = CreateFrame("Button", nil, parent)
  t:SetSize(40, 20)
  local track = t:CreateTexture(nil, "BACKGROUND"); track:SetAllPoints(); track:SetColorTexture(0, 0, 0, 0.12)   -- the transition: reads on the light plate
  local knob = t:CreateTexture(nil, "ARTWORK"); knob:SetSize(20, 20)
  knob:SetColorTexture(COLOR.purple.r, COLOR.purple.g, COLOR.purple.b, 1)
  function t:refresh() knob:ClearAllPoints(); knob:SetPoint(get() and "RIGHT" or "LEFT", 0, 0) end
  t:SetScript("OnClick", function() set(not get()); t:refresh() end)
  t:refresh()
  return t
end

-- Flat text input (the family pattern): no Blizzard template, faint purple
-- fill + brighter fill on focus, no border.
--
-- KEYBOARD (MINOR 10, the owner 2026-09-20). Every box the lib makes joins
-- one registry, so no tab wires anything:
--   Tab / Shift-Tab  → focus the next / previous box that is VISIBLE and
--     shares this box's top-level frame (the Suite window, or an open popover
--     / dialog — each is its own ring), ordered by screen position, top to
--     bottom then left to right; wraps. Losing focus is what commits a box's
--     value in every consumer, so tabbing away applies. The box tabbed into
--     selects its text, so typing replaces.
--   Up / Down → step the number in the box by 1 (Shift: 10). Default: edits
--     the TEXT only (the consumer's Enter / focus-lost commit applies it).
--     A consumer that wants the value applied LIVE while the box keeps focus
--     sets `e.stepper = function(e, delta) … end` and owns the whole step
--     (clamp, apply, refresh the text). A box whose text is not a number
--     ignores the arrows.
local editBoxes = setmetatable({}, { __mode = "k" })

-- The ring is one WINDOW's boxes: the nearest two-window-kit window (UI.gWindow
-- marks itself `_gWin`), else the frame just under UIParent (the first design).
local function topLevel(f)
  if f._gWin then return f end
  local p = f:GetParent()
  while p and p ~= UIParent do
    f = p
    if f._gWin then return f end
    p = f:GetParent()
  end
  return f
end

local function tabRing(from)
  local root, ring = topLevel(from), {}
  for e in pairs(editBoxes) do
    if e:IsVisible() and e:IsEnabled() and e:GetTop() and topLevel(e) == root then ring[#ring + 1] = e end
  end
  table.sort(ring, function(a, b)
    local ta, tb = a:GetTop(), b:GetTop()
    if math.abs(ta - tb) > 2 then return ta > tb end
    return a:GetLeft() < b:GetLeft()
  end)
  return ring
end

-- ★ Tab / Shift-Tab moves to the next / previous box. Every edit box in the
-- kit joins: the first design's (MINOR 10) and, since 2026-09-30, the later
-- kits' fields and dial number boxes (the owner: "I thought we made it
-- possible to tab through fields" — the new widgets had never joined).
function UI.tabbable(e)
  e:SetScript("OnTabPressed", function(self)
    local ring = tabRing(self)
    local n = #ring
    if n < 2 then return end
    local at = 1
    for i, b in ipairs(ring) do if b == self then at = i; break end end
    local nxt = ring[((at - 1 + (IsShiftKeyDown() and -1 or 1)) % n) + 1]
    self:ClearFocus()          -- commits, via the consumer's focus-lost hook
    nxt:SetFocus(); nxt:HighlightText()
  end)
  editBoxes[e] = true
  -- a committed or stepped value is an UNDO step (the Hub's Undo.lua sets UI.afterEdit)
  e:HookScript("OnEditFocusLost", function() if UI.afterEdit then UI.afterEdit() end end)
  e:HookScript("OnArrowPressed", function() if UI.afterEdit then UI.afterEdit() end end)
end

function UI.flatEditBox(parent, w, h)
  local e = CreateFrame("EditBox", nil, parent)
  e:SetSize(w, h); e:SetAutoFocus(false)
  UI.setFont(e, FONT.body, 12); e:SetTextColor(COLOR.text.r, COLOR.text.g, COLOR.text.b)
  e:SetTextInsets(6, 6, 0, 0)
  local bg = e:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints()
  bg:SetColorTexture(COLOR.purple.r, COLOR.purple.g, COLOR.purple.b, 0.10)
  e.bg = bg   -- exposed so the kit's `UI.field` can reskin the same box (MINOR 11)
  e:SetScript("OnEditFocusGained", function(self) if self.onFocus then self.onFocus(self, true) else bg:SetColorTexture(COLOR.purple.r, COLOR.purple.g, COLOR.purple.b, 0.22) end end)
  e:SetScript("OnEditFocusLost",  function(self) if self.onFocus then self.onFocus(self, false) else bg:SetColorTexture(COLOR.purple.r, COLOR.purple.g, COLOR.purple.b, 0.10) end end)
  UI.tabbable(e)
  e:SetScript("OnArrowPressed", function(self, key)
    if key ~= "UP" and key ~= "DOWN" then return end
    local delta = (key == "UP" and 1 or -1) * (IsShiftKeyDown() and 10 or 1)
    if self.stepper then self.stepper(self, delta); return end
    local v = tonumber(self:GetText())
    if v then self:SetText(tostring(v + delta)); self:SetCursorPosition(#self:GetText()) end
  end)
  editBoxes[e] = true
  return e
end

-- A labelled slider row: label (left) + value (right) over a thin purple-bar
-- thumb on a heroic-20 track (the family look). get/set drive it live; fmt
-- renders the value text; `sub` adds a muted sub-label (taller row). Returns
-- { refresh, setEnabled, SetShown }. Lifted verbatim from GB Config.lua.
function UI.sliderRow(parent, yTop, labelText, minV, maxV, step, get, set, fmt, sub)
  local lab = UI.newText(parent, FONT.body, 12, COLOR.text, "LEFT"); lab:SetPoint("TOPLEFT", 18, yTop); lab:SetText(labelText)
  local val = UI.newText(parent, FONT.label, 11, COLOR.text, "RIGHT"); val:SetPoint("TOPRIGHT", -18, yTop)
  -- Optional muted sub-label under the title — when present the slider drops
  -- below it (taller row).
  local subLab
  local sliderY = yTop - 15
  if sub then
    subLab = UI.newText(parent, FONT.body, 10.5, COLOR.mute, "LEFT")
    subLab:SetPoint("TOPLEFT", 18, yTop - 15); subLab:SetText(sub)
    sliderY = yTop - 30
  end
  -- The Slider FRAME is a tall, full-width hit area (easy to grab); the visible
  -- track is a thin bar centered in it, so the look is unchanged but the grab
  -- target isn't just the 5px thumb (the owner QA 2026-07-19).
  local sl = CreateFrame("Slider", nil, parent)
  sl:SetPoint("TOPLEFT", 18, sliderY); sl:SetPoint("TOPRIGHT", -18, sliderY); sl:SetHeight(16)
  sl:EnableMouse(true)
  sl:SetOrientation("HORIZONTAL"); sl:SetMinMaxValues(minV, maxV); sl:SetValueStep(step); sl:SetObeyStepOnDrag(true)
  local track = sl:CreateTexture(nil, "BACKGROUND")
  track:SetPoint("LEFT"); track:SetPoint("RIGHT"); track:SetHeight(6)   -- thin visual bar, vertically centered
  track:SetColorTexture(COLOR.heroic.r, COLOR.heroic.g, COLOR.heroic.b, 0.20)
  local thumb = sl:CreateTexture(nil, "ARTWORK"); thumb:SetColorTexture(COLOR.purple.r, COLOR.purple.g, COLOR.purple.b, 1)
  thumb:SetSize(5, 20); sl:SetThumbTexture(thumb)
  local applying = false
  local function show(v) val:SetText(fmt and fmt(v) or tostring(v)) end
  sl:SetScript("OnValueChanged", function(_, v) if not applying then set(v) end; show(v) end)
  -- Click / drag ANYWHERE on the row seeks the value (map cursor X → min..max,
  -- snap to step) — so you never have to land on the thin thumb.
  local function seek(self)
    local left, w = self:GetLeft(), self:GetWidth()
    if not (left and w and w > 0) then return end
    local frac = (GetCursorPosition() / self:GetEffectiveScale() - left) / w
    frac = math.max(0, math.min(1, frac))
    local v = minV + frac * (maxV - minV)
    if step and step > 0 then v = minV + math.floor((v - minV) / step + 0.5) * step end
    self:SetValue(v)
  end
  -- A drag STARTING ON THE THUMB belongs to the native slider alone: with our
  -- seek also writing every frame, the two quantize the cursor differently
  -- near step boundaries and the value flickers between neighbours (the owner:
  -- "blurs" — worst on wide ranges like Gap's 0–64). Off-thumb, seek owns it.
  sl:SetScript("OnMouseDown", function(self)
    if not self:IsEnabled() then return end
    local left, w = self:GetLeft(), self:GetWidth()
    if left and w and w > 0 then
      local cx = GetCursorPosition() / self:GetEffectiveScale()
      local mn, mx = self:GetMinMaxValues()
      local tx = left + ((self:GetValue() - mn) / math.max(mx - mn, 1e-6)) * w
      if math.abs(cx - tx) <= 8 then return end   -- on the thumb → native drag
    end
    self._seek = true; seek(self)
  end)
  sl:SetScript("OnMouseUp", function(self) self._seek = false end)
  sl:SetScript("OnUpdate", function(self)
    if self._seek then
      if self:IsEnabled() and IsMouseButtonDown("LeftButton") then seek(self) else self._seek = false end
    end
  end)
  local row = {}
  function row:refresh() applying = true; local v = get() or minV; sl:SetValue(v); show(v); applying = false end
  function row:setEnabled(on) sl:SetEnabled(on); sl:SetAlpha(on and 1 or 0.35) end
  function row:SetShown(on) lab:SetShown(on); val:SetShown(on); sl:SetShown(on); if subLab then subLab:SetShown(on) end end
  row:refresh()
  return row
end

-- Color swatch — a solid button opening the suite's own UI.colorPicker (MINOR 6;
-- it drove Blizzard's ColorPickerFrame before that, the last piece of native
-- chrome anywhere in the suite). get() → {r,g,b[,a]} array; set(c) writes it.
-- `withAlpha` adds the Opacity row to the picker and a 4th component to `c`.
-- `label` (MINOR 6) names the element this controls — "Bars › Border color" —
-- and is what the palette's tooltip lists as WHERE a color is in use. Optional:
-- an unlabelled swatch still works, it just never shows up in that list.
-- Returns { swatch, refresh }.
function UI.colorSwatch(parent, get, set, withAlpha, label)
  local sw = CreateFrame("Button", nil, parent); sw:SetSize(28, 20)
  local tex = sw:CreateTexture(nil, "ARTWORK"); tex:SetAllPoints()
  UI.addEdges(sw, COLOR.rim, 1)
  -- The swatch shows the hue at full opacity (its alpha lives on the target, e.g.
  -- the border) so a near-transparent colour stays visible/clickable here.
  -- Every refresh also tells the palette this color is live on an element. This
  -- is the whole harvest: no tool had to be taught anything.
  local function update()
    local c = get()
    UI.NoteColor(c)
    c = c or { 1, 1, 1 }
    tex:SetColorTexture(c[1] or 1, c[2] or 1, c[3] or 1, 1)
  end
  sw:SetScript("OnClick", function()
    UI.colorPicker({
      color = get() or { 1, 1, 1 },
      hasAlpha = withAlpha,
      owner = sw,
      onChange = function(c) set(c); update() end,
    })
  end)
  update()
  UI.RegisterColorSource(sw, get, label)
  local row = { swatch = sw }
  function row:refresh() update() end
  return row
end

-- A 4-way direction picker: label (left) + Up/Down/Left/Right buttons (right),
-- the current one highlighted (flatButton active = full opacity). get() returns
-- "up"|"down"|"left"|"right"; set(dir) writes it. Returns { refresh, setEnabled }.
local DIR_CHOICES = { { "up", "Up" }, { "down", "Down" }, { "left", "Left" }, { "right", "Right" } }
function UI.dirRow(parent, yTop, labelText, get, set)
  local lab = UI.newText(parent, FONT.body, 12, COLOR.text, "LEFT"); lab:SetPoint("TOPLEFT", 18, yTop); lab:SetText(labelText)
  local btns, prev = {}, nil
  for i = #DIR_CHOICES, 1, -1 do            -- lay out right-to-left so Up is leftmost
    local d = DIR_CHOICES[i]
    local b = UI.flatButton(parent, 40, 22, COLOR.heroic, d[2], 11)
    if prev then b:SetPoint("TOPRIGHT", prev, "TOPLEFT", -4, 0)
    else b:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -18, yTop + 1) end
    b:SetScript("OnClick", function() set(d[1]); for _, e in ipairs(btns) do e.b:SetActive(e.d == get()) end end)
    btns[#btns + 1] = { b = b, d = d[1] }
    prev = b
  end
  local row = {}
  function row:refresh() local cur = get(); for _, e in ipairs(btns) do e.b:SetActive(e.d == cur) end end
  function row:setEnabled(on) for _, e in ipairs(btns) do e.b:SetEnabled(on) end; lab:SetAlpha(on and 1 or 0.35) end
  row:refresh()
  return row
end

-- A thin custom scrollbar for a ScrollFrame (family look; no Blizzard widget)
-- with the ORANGE thumb. Track + draggable thumb + click/drag-anywhere-on-the-
-- track to jump + wheel over the bar. The thumb auto-sizes to the live scroll
-- range via OnUpdate — which pauses while the parent is hidden. `place(sb)`
-- lets the caller anchor + inset the bar. Returns the bar with :Sync().
-- `opts.kit` (MINOR 11) draws the KIT's scrollbar instead: an 8px faint
-- capsule track with a 6px dim capsule thumb (the PRIMITIVES frame). Same
-- behaviour either way — click-to-jump, drag, wheel.
function UI.makeScrollbar(parent, scroll, place, opts)
  local kit = opts and opts.kit
  local sb = CreateFrame("Frame", nil, parent)
  place(sb); sb:SetWidth(kit and 8 or 4)
  local track = sb:CreateTexture(nil, "BACKGROUND"); track:SetAllPoints()
  local thumb = CreateFrame("Button", nil, sb); thumb:SetWidth(kit and 6 or 4); thumb:SetPoint("TOP", 0, 0)
  local thumbTex = thumb:CreateTexture(nil, "ARTWORK"); thumbTex:SetAllPoints()
  local ALPHA = kit and 1 or 0.85   -- the kit's alpha lives in its vertex colour; hover leaves it alone
  if kit then
    for _, t in ipairs({ track, thumbTex }) do
      t:SetTexture(UI.PILL); t:SetTextureSliceMargins(0, 5, 0, 5)
      t:SetTextureSliceMode((Enum.UITextureSliceMode and Enum.UITextureSliceMode.Stretched) or 0)
    end
    track:SetVertexColor(COLOR.faint.r, COLOR.faint.g, COLOR.faint.b, COLOR.faint.a)
    thumbTex:SetVertexColor(COLOR.dim.r, COLOR.dim.g, COLOR.dim.b, COLOR.dim.a)
  else
    track:SetColorTexture(1, 1, 1, 0.06)
    thumbTex:SetColorTexture(COLOR.orange.r, COLOR.orange.g, COLOR.orange.b, ALPHA)
  end
  thumb:SetScript("OnEnter", function() thumbTex:SetAlpha(1) end)
  thumb:SetScript("OnLeave", function() thumbTex:SetAlpha(ALPHA) end)

  local function syncThumb()
    local range = scroll:GetVerticalScrollRange()
    local trackH = sb:GetHeight()
    if range <= 0.5 or trackH <= 0 then thumb:Hide(); return end
    thumb:Show()
    local visible = scroll:GetHeight()
    local th = math.max(24, trackH * visible / (visible + range))
    thumb:SetHeight(th)
    local scrolled = math.min(range, math.max(0, scroll:GetVerticalScroll()))
    thumb:ClearAllPoints(); thumb:SetPoint("TOP", sb, "TOP", 0, -(scrolled / range) * (trackH - th))
  end
  -- Map the cursor's Y within the track → scroll fraction (click-to-jump).
  local function seek()
    local range = scroll:GetVerticalScrollRange()
    local top, trackH = sb:GetTop(), sb:GetHeight()
    if range <= 0 or not top or trackH <= 0 then return end
    local _, cy = GetCursorPosition(); cy = cy / sb:GetEffectiveScale()
    scroll:SetVerticalScroll(math.max(0, math.min(1, (top - cy) / trackH)) * range)
  end

  sb:EnableMouse(true); sb:EnableMouseWheel(true)
  sb:SetScript("OnMouseWheel", function(_, delta)
    local range = scroll:GetVerticalScrollRange()
    scroll:SetVerticalScroll(math.max(0, math.min(range, scroll:GetVerticalScroll() - delta * 42)))
  end)
  sb:SetScript("OnMouseDown", function(self) self._seeking = true; seek() end)
  sb:SetScript("OnMouseUp", function(self) self._seeking = false end)
  sb:SetScript("OnUpdate", function(self)
    if self._seeking then
      if IsMouseButtonDown("LeftButton") then seek() else self._seeking = false end
    end
    syncThumb()
  end)

  thumb:SetScript("OnMouseDown", function(self)
    local _, cy = GetCursorPosition()
    self.grabY, self.grabScroll, self.grabbing = cy, scroll:GetVerticalScroll(), true
  end)
  thumb:SetScript("OnMouseUp", function(self) self.grabbing = false end)
  thumb:SetScript("OnUpdate", function(self)
    if not self.grabbing then return end
    if not IsMouseButtonDown("LeftButton") then self.grabbing = false; return end
    local range = scroll:GetVerticalScrollRange()
    local usable = sb:GetHeight() - self:GetHeight()
    if usable <= 0 or range <= 0 then return end
    local _, cy = GetCursorPosition()
    local dy = (self.grabY - cy) / sb:GetEffectiveScale()
    scroll:SetVerticalScroll(math.max(0, math.min(range, self.grabScroll + (dy / usable) * range)))
  end)

  sb.Sync = syncThumb
  return sb
end

-- ------------------------------------------------------------
-- Dropdown (MINOR 3) — the family's "pick from a list": a flat button showing
-- the current value with an orange caret, opening a flyout of rows. A
-- full-screen catcher behind the flyout closes it on any outside click. Lifted
-- from GB Config.lua's animDropdown/openAnimFlyout (the pattern the owner picked as
-- correct, 2026-07-24) and generalized; the flyout scrolls past FLY_ROWS rows.
--   getLabel()   → the button's text
--   getOptions() → { { value =, label = }, … }
--   getCurrent() → the selected value (rendered purple in the list)
--   onPick(value)
-- ------------------------------------------------------------
local FLY_ROWS, FLY_ROW_H = 12, 22
local flyout

local function flyoutFrame()
  if flyout then return flyout end
  local catcher = CreateFrame("Button", nil, UIParent)
  catcher:SetFrameStrata("FULLSCREEN"); catcher:SetAllPoints(UIParent); catcher:Hide()
  catcher:SetFrameLevel(20)   -- above a popover's catcher (0) and panel (5), so a list opened inside one closes on its own
  local fly = CreateFrame("Frame", nil, catcher)
  fly:SetFrameStrata("FULLSCREEN_DIALOG")
  UI.skinPlate(fly); UI.addEdges(fly, COLOR.rim, 1)
  local scroll = CreateFrame("ScrollFrame", nil, fly)
  scroll:SetPoint("TOPLEFT", 3, -3); scroll:SetPoint("BOTTOMRIGHT", -3, 3)
  scroll:EnableMouseWheel(true)
  local child = CreateFrame("Frame", nil, scroll); child:SetSize(10, 10)
  scroll:SetScrollChild(child)
  scroll:SetScript("OnMouseWheel", function(self, delta)
    local range = math.max(0, child:GetHeight() - self:GetHeight())
    self:SetVerticalScroll(math.max(0, math.min(range, self:GetVerticalScroll() - delta * FLY_ROW_H)))
  end)
  catcher:SetScript("OnClick", function() catcher:Hide() end)
  fly.catcher, fly.scroll, fly.child, fly.rows = catcher, scroll, child, {}
  flyout = fly
  return fly
end

-- The shared flyout frame, built on demand. Exposed so a consumer can observe
-- the open list: GB keeps the selected bar pulsing while its Preset flyout is
-- up, and clears the pulse on the flyout's OnHide.
function UI.flyout() return flyoutFrame() end

function UI.dropdown(parent, w, getLabel, getOptions, getCurrent, onPick)
  local b = UI.flatButton(parent, w, 22, COLOR.heroic, "", 11)
  b:SetBase(0.2); b.text:SetWordWrap(false)
  -- Inset the label so long names truncate instead of running under the caret
  -- (the owner: "Gloomfury - Stormrage" collided). Justify stays centered.
  b.text:ClearAllPoints()
  b.text:SetPoint("LEFT", 8, 0); b.text:SetPoint("RIGHT", -18, 0); b.text:SetJustifyH("CENTER")
  local car = b:CreateTexture(nil, "ARTWORK"); car:SetTexture(UI.CARET)
  car:SetVertexColor(COLOR.orange.r, COLOR.orange.g, COLOR.orange.b)
  car:SetSize(8, 8); car:SetPoint("RIGHT", -8, 0); car:SetRotation(UI.CARET_DOWN)

  function b:refresh() self.text:SetText(getLabel() or "?") end

  b:SetScript("OnClick", function()
    local fly = flyoutFrame()
    local options, current = getOptions() or {}, getCurrent()
    local y = 0
    for i, opt in ipairs(options) do
      local row = fly.rows[i]
      if not row then
        row = CreateFrame("Button", nil, fly.child); row:SetHeight(FLY_ROW_H)
        row.hl = row:CreateTexture(nil, "BACKGROUND"); row.hl:SetAllPoints()
        row.hl:SetColorTexture(0, 0, 0, 0.07); row.hl:Hide()
        row:SetScript("OnEnter", function(self) self.hl:Show() end)
        row:SetScript("OnLeave", function(self) self.hl:Hide() end)
        row.text = UI.newText(row, FONT.body, 12, COLOR.text, "LEFT")
        row.text:SetPoint("LEFT", 8, 0); row.text:SetPoint("RIGHT", -8, 0); row.text:SetWordWrap(false)
        fly.rows[i] = row
      end
      row:ClearAllPoints()
      row:SetPoint("TOPLEFT", 0, y); row:SetPoint("TOPRIGHT", 0, y)
      row.text:SetText(opt.label)
      if opt.value == current then row.text:SetTextColor(COLOR.purple.r, COLOR.purple.g, COLOR.purple.b)
      else row.text:SetTextColor(COLOR.text.r, COLOR.text.g, COLOR.text.b) end
      row:SetScript("OnClick", function() fly.catcher:Hide(); onPick(opt.value); b:refresh() end)
      row:Show()
      y = y - FLY_ROW_H
    end
    for i = #options + 1, #fly.rows do fly.rows[i]:Hide() end

    local shown = math.min(#options, FLY_ROWS)
    local cw = math.max(b:GetWidth(), 150)
    fly.child:SetSize(cw - 6, math.max(10, #options * FLY_ROW_H))
    fly:SetSize(cw, shown * FLY_ROW_H + 6)
    fly.scroll:SetVerticalScroll(0)
    fly:ClearAllPoints(); fly:SetPoint("TOPRIGHT", b, "BOTTOMRIGHT", 0, -2)
    -- The flyout outlives its anchor's frame otherwise: close it if the tab (or
    -- the whole Suite window) goes away underneath it.
    if not b._flyHooked then
      b._flyHooked = true
      b:HookScript("OnHide", function() if flyout then flyout.catcher:Hide() end end)
    end
    fly.catcher:Show()
  end)

  b:refresh()
  return b
end

-- ------------------------------------------------------------
-- Shared modal dialogs (MINOR 3). The family's replacement for
-- StaticPopupDialogs (native chrome, and its editBox/EditBox field name shifts
-- between clients). GB and GA each hand-maintained a near-identical copy of the
-- name dialog before this; there is now exactly one.
-- ------------------------------------------------------------
local nameDlg, confirmDlg, pickerDlg

-- The scrim behind them (the owner, 2026-07-25). Both dialogs are plates in the
-- same near-black navy as the panel they open over, so without this they read as
-- part of the tab rather than on top of it. One scrim serves both: it dims
-- everything below and eats the clicks, which is what makes them actually modal.
-- Clicking it does NOT dismiss — the family answer is always an explicit choice
-- (OK / Cancel / ESC), never a click-somewhere-else that silently drops the edit.
local scrim

-- ★ The scrim dims the SUITE WINDOW, not the screen (the owner, 2026-09-21:
-- "the rest of the addon" recedes; the game stays bright). It is anchored to
-- the window each time a dialog opens, and the dialog is centred on it. With
-- no window on screen (nothing opens a dialog from anywhere else today) it
-- falls back to the whole screen.
local function scrimShow(dlg)
  if not scrim then
    scrim = CreateFrame("Frame", nil, UIParent)
    scrim:SetFrameStrata("FULLSCREEN_DIALOG")
    scrim:EnableMouse(true)
    local t = scrim:CreateTexture(nil, "BACKGROUND")
    t:SetAllPoints(scrim)
    t:SetColorTexture(0, 0, 0, 0.6)
    scrim:Hide()
  end
  local host = _G.GloomsSuiteWindow
  if not (host and host:IsShown()) then host = UIParent end
  scrim:ClearAllPoints(); scrim:SetAllPoints(host)
  dlg:ClearAllPoints(); dlg:SetPoint("CENTER", host, "CENTER", 0, 0)
  -- Sit just under whatever level the dialog's own Raise() settled on, so the
  -- scrim covers the shell (DIALOG strata) without ever covering the dialog.
  local lvl = dlg:GetFrameLevel()
  if lvl < 10 then dlg:SetFrameLevel(10); lvl = 10 end
  scrim:SetFrameLevel(lvl - 5)
  scrim:Show()
end

-- Hooked to both dialogs' OnHide, so EVERY close path is covered — OK, Cancel,
-- and the UISpecialFrames ESC that never runs our own handlers.
local function scrimHide()
  if not scrim then return end
  if (nameDlg and nameDlg:IsShown()) or (confirmDlg and confirmDlg:IsShown()) then return end
  scrim:Hide()
end

-- The first redesign's dialog plate (MINOR 11): the night plate with the
-- indigo rim. Still worn by the color picker and the other pickers until the
-- owner mocks them; the name and confirm dialogs moved to the plate below.
local function kitDialogPlate(f)
  local plate = f:CreateTexture(nil, "BACKGROUND"); plate:SetAllPoints()
  plate:SetColorTexture(COLOR.night.r, COLOR.night.g, COLOR.night.b, 1)
  UI.addEdges(f, COLOR.indigo, 1)
end

-- ★ The two-window design's DIALOG (MINOR 18, 2026-09-27 — the owner: "not
-- the correct font or button style"): the kit's list plate (#0f051d, opaque,
-- in a violet hairline — the "Dropdown/Popup Menu" mock), a Sansation 14
-- white title 20 in, a Sansation 10 body or the kit's field 26 under it, and
-- the kit's buttons (16 tall, Sansation 10) 20 from the bottom-left. The
-- accept button is CORAL only when it destroys (Delete / Remove / Clear);
-- Copy, Reset and OK are the plain violet button. It wears the Suite windows'
-- scale (the Addon UI Scale), like the lists. Built on first use: the kit's
-- pieces (UI.gTitle, UI.gButton, UI.gField, UI.gOutline) are defined further
-- down this file.
local DLG_W = 340
local function gDialogFrame(name)
  local f = CreateFrame("Frame", name, UIParent)
  f:SetSize(DLG_W, 120); f:SetPoint("CENTER"); f:SetFrameStrata("FULLSCREEN_DIALOG"); f:EnableMouse(true)
  local plate = f:CreateTexture(nil, "BACKGROUND"); plate:SetAllPoints()
  plate:SetColorTexture(COLOR.panel.r, COLOR.panel.g, COLOR.panel.b, 1)
  UI.gOutline(f, COLOR.violet)
  f.title = UI.gTitle(f, "", 14); f.title:SetPoint("TOPLEFT", 20, -20)
  return f
end
local function gDialogScale(f)
  local root = _G.GloomsSuiteWindows
  local es = (root and root:IsShown()) and root:GetEffectiveScale() or UIParent:GetEffectiveScale()
  f:SetScale(es / UIParent:GetEffectiveScale())
  if UI.gHairRefresh then UI.gHairRefresh() end
end
local function gDialogButton(f, label)
  return UI.gButton(f, label, { h = 16, pad = 10, size = 10 })
end

-- Text entry. onAccept(name) fires on OK / Enter; Cancel and ESC drop it.
function UI.nameDialog(titleText, initial, onAccept)
  if not nameDlg then
    local f = gDialogFrame("GloomSkinNameDialog")
    f.box = UI.gField(f, DLG_W - 40); f.box:SetPoint("TOPLEFT", 20, -46)
    local okB = gDialogButton(f, "OK"); okB:SetPoint("BOTTOMLEFT", 20, 20)
    local noB = gDialogButton(f, "Cancel"); noB:SetPoint("LEFT", okB, "RIGHT", 6, 0)
    f:SetHeight(46 + 16 + 20 + 16 + 20)
    local function accept()
      -- Trimmed here, once, for every caller: a stray leading/trailing space made
      -- a second profile that LOOKED identical to the first in the dropdown.
      local name = (f.box:GetText() or ""):match("^%s*(.-)%s*$")
      local cb = f.onAccept; f.onAccept = nil
      f:Hide()
      if cb then cb(name) end
    end
    local function cancel() f.onAccept = nil; f:Hide() end
    okB:SetScript("OnClick", accept)
    noB:SetScript("OnClick", cancel)
    f.box:SetScript("OnEnterPressed", accept)
    f.box:SetScript("OnEscapePressed", cancel)
    f.box:SetScript("OnEditFocusLost", nil)   -- the kit field commits on focus loss; a dialog does not
    tinsert(UISpecialFrames, "GloomSkinNameDialog")   -- ESC closes it
    f:HookScript("OnHide", scrimHide)
    f:Hide()
    nameDlg = f
  end
  nameDlg.onAccept = onAccept
  nameDlg.title:SetText(titleText or "Name")
  nameDlg.box:SetText(initial or ""); nameDlg.box:SetCursorPosition(0)
  gDialogScale(nameDlg)
  nameDlg:Show(); nameDlg:Raise(); scrimShow(nameDlg)
  nameDlg.box:SetFocus(); nameDlg.box:HighlightText()
  return nameDlg
end

-- Yes/no confirm for destructive actions. ALWAYS used for deletes: a
-- self-arming "click twice" button has no way to back out once armed
-- (the owner 2026-07-24) — this does, via Cancel or ESC. `acceptLabel`
-- defaults to "Delete": ★ a confirm that does anything else MUST name its
-- button ("Copy", "Reset") — an unnamed one asked to Delete a copy (2026-09-27).
local DANGER = { Delete = true, Remove = true, Clear = true, ["Clear All"] = true }
function UI.confirm(bodyText, onYes, acceptLabel, titleText)
  if not confirmDlg then
    local f = gDialogFrame("GloomSkinConfirm")
    f.body = UI.newText(f, FONT.sa, 10, COLOR.paper, "LEFT")
    f.body:SetPoint("TOPLEFT", 20, -46); f.body:SetWidth(DLG_W - 40); f.body:SetJustifyH("LEFT")
    f.body:SetWordWrap(true)
    f.yes = gDialogButton(f, "Delete"); f.yes:SetPoint("BOTTOMLEFT", 20, 20)
    local noB = gDialogButton(f, "Cancel"); noB:SetPoint("LEFT", f.yes, "RIGHT", 6, 0)
    f.yes:SetScript("OnClick", function()
      local cb = f.onYes; f.onYes = nil; f:Hide(); if cb then cb() end
    end)
    noB:SetScript("OnClick", function() f.onYes = nil; f:Hide() end)
    tinsert(UISpecialFrames, "GloomSkinConfirm")   -- ESC cancels
    f:HookScript("OnHide", scrimHide)
    f:Hide()
    confirmDlg = f
  end
  confirmDlg.onYes = onYes
  confirmDlg.title:SetText(titleText or "Are you sure?")
  confirmDlg.body:SetText(bodyText or "")
  -- The plate grows with its body (a profile delete may list the characters
  -- using it): 46 above the text, 20 under it, the 16 buttons, 20 below.
  confirmDlg:SetHeight(46 + math.ceil(confirmDlg.body:GetStringHeight()) + 20 + 16 + 20)
  local label = acceptLabel or "Delete"
  confirmDlg.yes._danger = DANGER[label] or nil
  confirmDlg.yes:SetLabel(label)
  confirmDlg.yes:paint()
  gDialogScale(confirmDlg)
  confirmDlg:Show(); confirmDlg:Raise(); scrimShow(confirmDlg)
  return confirmDlg
end

-- ------------------------------------------------------------
-- UI.colorPicker (MINOR 6) — the suite's ONE color picker.
--
-- Everything else in the suite had been reskinned; this was the last native
-- Blizzard frame a user could still be shown (the owner, 2026-07-26). Family
-- plate and OK/Cancel, carrying an HSV field, a hue strip, a hex box, the suite
-- palette, and an OPACITY slider (the shared UI.sliderRow, so it is the same
-- control as every other opacity in the suite) when the caller asks for one.
--
-- ★★ It is NOT a modal, and that is deliberate (the owner, 2026-07-26): unlike
-- nameDialog and confirm it CHANGES SOMETHING ON SCREEN WHILE IT IS OPEN, so
-- dimming the rest of the screen would hide the very thing you are judging.
-- Two consequences, and the second is not optional:
--   · it takes NO scrim, so you can see (and reach) what it is tinting; and
--   · it is DRAGGABLE by its plate, because a fixed centre-screen panel will
--     always end up sitting on top of whatever you are trying to look at.
-- The scrim was also what separated these dialogs from the tab underneath —
-- they are the same near-black navy as the panel they open over. A PURPLE RIM
-- does that job here instead, without dimming anything.
--
--   opts.color     { r, g, b [, a] }   the starting color (defaults white)
--   opts.hasAlpha  show the Opacity row and return a 4th component
--   opts.title     dialog title (defaults "COLOR")
--   opts.onChange(c)  LIVE, on every change — same contract as Blizzard's
--                     swatchFunc, so consumers keep their live previews
--   opts.onAccept(c)  OK only
--   opts.onCancel()   after the original has been restored via onChange
--   opts.sources / opts.source / opts.onSource(v)   MINOR 12 — see the kit's picker note
--   opts.owner        the frame the picker belongs to (the swatch). When that
--                     goes away — tab switch, Suite window closed — the picker
--                     closes and CANCELS, rather than floating there editing a
--                     control nobody can see. Being non-modal is what makes
--                     that reachable; UI.colorSwatch passes it for you.
--
-- ★ It applies LIVE and restores on cancel. Every close path that is not an
-- explicit OK — Cancel, ESC, the frame being hidden underneath it — puts
-- opts.color back through onChange. Blizzard's picker only did that if you
-- passed a cancelFunc, and NOTHING in the suite did, so cancelling used to
-- leave the last color you dragged over applied.
-- ------------------------------------------------------------

-- SetGradient needs a real TEXTURE under it, not a SetColorTexture fill — this
-- is the pairing that is demonstrably live in this client (12.0.7).
local WHITE8X8 = "Interface\\BUTTONS\\WHITE8X8"

local function hsv2rgb(h, s, v)
  if s <= 0 then return v, v, v end
  h = (h % 1) * 6
  local i = math.floor(h)
  local f = h - i
  local p, q, t = v * (1 - s), v * (1 - s * f), v * (1 - s * (1 - f))
  if     i == 0 then return v, t, p
  elseif i == 1 then return q, v, p
  elseif i == 2 then return p, v, t
  elseif i == 3 then return p, q, v
  elseif i == 4 then return t, p, v
  else                return v, p, q end
end

local function rgb2hsv(r, g, b)
  local mx, mn = math.max(r, g, b), math.min(r, g, b)
  local d, h = mx - mn, 0
  if d > 0 then
    if mx == r then h = ((g - b) / d) % 6
    elseif mx == g then h = (b - r) / d + 2
    else h = (r - g) / d + 4 end
    h = h / 6
  end
  return h, (mx > 0 and d / mx or 0), mx
end

-- "#RRGGBB" / "RRGGBB" / "#RRGGBBAA" → r,g,b[,a]; nil on anything else.
local function hex2rgb(str)
  str = strtrim(str or ""):gsub("^#", "")
  if (#str ~= 6 and #str ~= 8) or str:match("%X") then return nil end
  local a = #str == 8 and tonumber(str:sub(7, 8), 16) / 255 or nil
  return tonumber(str:sub(1, 2), 16) / 255,
         tonumber(str:sub(3, 4), 16) / 255,
         tonumber(str:sub(5, 6), 16) / 255, a
end

local function byte255(x) return math.floor((x or 0) * 255 + 0.5) end

-- Two-tone backdrop behind the preview, so a part-transparent color reads as
-- TRANSPARENT rather than as a darker color. Four blocks is plenty at this size.
local function checkerboard(parent, w, h)
  for i = 0, 1 do
    for j = 0, 1 do
      local t = parent:CreateTexture(nil, "BACKGROUND")
      local s = ((i + j) % 2 == 0) and 0.20 or 0.11
      t:SetColorTexture(s, s, s + 0.02, 1)
      t:SetSize(w / 2, h / 2)
      t:SetPoint("TOPLEFT", (w / 2) * i, -(h / 2) * j)
    end
  end
end

-- ------------------------------------------------------------
-- The palette row — the colors that are on the USER'S OWN elements.
--
-- ★ Not the suite's design tokens. The first cut of this row WAS the token set,
-- and that was the wrong basis (the owner, 2026-07-26): "Gloom Suite is a lot of
-- purple and orange, and those colors shouldn't necessarily be in the palette if
-- the end user isn't using them on live elements in their own UI." What belongs
-- here is what they have put on their bars, auras and overlays.
--
-- ★ No tool needed a single edit for this. EVERY color control in the suite
-- already goes through UI.colorSwatch or UI.colorPicker, and every one of them
-- drives a user-facing element — the chrome's own colors are hardcoded tokens
-- that never pass through here. So the lib already sees exactly the right set,
-- and only the lib had to change.
--
-- Two tiers, because they answer different questions:
--   APPLIED — the user picked it on purpose. Bumped to newest on every pick,
--             and evicted only once every SEEN entry is gone.
--   SEEN    — it is merely what an element wears right now, including a default
--             they never touched. Fills free slots; never evicts anything.
--
-- Storage is GloomsHubDB.palette = { { hex, n, applied }, … }. The lib may reach
-- for the Hub's SavedVariable because there is exactly one of each: the Hub is a
-- HARD dependency of all three tools, and per-tool embedding of this lib was
-- DROPPED (see ARCHIVE). Without a Hub the row degrades to empty, never errors.
-- ------------------------------------------------------------
local PALETTE_MAX = 12

local function paletteList()
  if type(GloomsHubDB) ~= "table" then return nil end
  if type(GloomsHubDB.palette) ~= "table" then GloomsHubDB.palette = {} end
  return GloomsHubDB.palette
end

-- Colors the user has right-clicked away. This has to be REMEMBERED, not just
-- removed: a color that is still live on an element would otherwise be
-- re-harvested by the very next swatch refresh and reappear a second later.
local function paletteHidden()
  if type(GloomsHubDB) ~= "table" then return nil end
  if type(GloomsHubDB.paletteHidden) ~= "table" then GloomsHubDB.paletteHidden = {} end
  return GloomsHubDB.paletteHidden
end

local function hexOf(c) return ("%02x%02x%02x"):format(byte255(c[1]), byte255(c[2]), byte255(c[3])) end

-- Right-click removal. Not routed through UI.confirm despite the destructive-
-- action rule: nothing is lost, the row is a convenience view, and picking the
-- color again un-hides it. A modal to drop one swatch would be worse than the
-- mistake it prevents.
function UI.ForgetColor(hex)
  local list = paletteList()
  if not (list and hex) then return end
  for i, rec in ipairs(list) do
    if rec.hex == hex then table.remove(list, i); break end
  end
  local hidden = paletteHidden()
  if hidden then hidden[hex] = true end
end

-- Record a color as in use. `applied` means the user just PICKED it, as opposed
-- to it merely being what some element already wears.
function UI.NoteColor(c, applied)
  local list = paletteList()
  if not (list and c and c[1]) then return end
  -- ★ Nothing is harvested while the picker is open. Consumers refresh their
  -- swatch on every live change, so a single drag across the field would
  -- otherwise pour ~60 intermediate colors a second into the row and bury every
  -- real one. What the drag SETTLES on is recorded by OK, which is the point.
  if not applied and pickerDlg and pickerDlg:IsShown() then return end
  local key = hexOf(c)
  local hidden = paletteHidden()
  if hidden and hidden[key] then
    -- Stays gone while it is merely SEEN. Deliberately picking it again is an
    -- unambiguous "I want this after all", so that lifts the removal.
    if not applied then return end
    hidden[key] = nil
  end
  for _, rec in ipairs(list) do
    if rec.hex == key then
      if applied then
        rec.applied = true
        GloomsHubDB.paletteSeq = (GloomsHubDB.paletteSeq or 0) + 1
        rec.n = GloomsHubDB.paletteSeq
      end
      return
    end
  end
  -- A passive sighting takes a free slot or nothing at all: an element's
  -- untouched default must never push out a color the user chose.
  if not applied and #list >= PALETTE_MAX then return end
  GloomsHubDB.paletteSeq = (GloomsHubDB.paletteSeq or 0) + 1
  list[#list + 1] = { hex = key, n = GloomsHubDB.paletteSeq, applied = applied or nil }
  while #list > PALETTE_MAX do
    local vi = 1
    for i = 2, #list do
      local rec, best = list[i], list[vi]
      -- most evictable first: unchosen before chosen, then oldest
      if (not rec.applied and best.applied)
         or ((not rec.applied) == (not best.applied) and rec.n < best.n) then
        vi = i
      end
    end
    table.remove(list, vi)
  end
end

-- ------------------------------------------------------------
-- Provenance — WHERE each palette color is being used.
--
-- ★ Deliberately NOT stored. The obvious implementation records a label next to
-- the hex as it is harvested, and it lies: harvesting only ever reports what a
-- swatch IS, never what it stopped being, so a color you moved away from keeps
-- claiming its old element forever. Instead every colorSwatch registers its
-- `get`, and this walks them on each open and asks. Derived, so it cannot go
-- stale — the price is a table walk per open, which is ~23 closure calls.
--
-- ⚠ HONEST LIMIT, and the tooltip has to say so: tabs build LAZILY, so a tool
-- whose tab you have not opened this session has registered nothing and can
-- never be listed. "Not seen" here does NOT mean "not used".
-- ------------------------------------------------------------
local colorSources = {}   -- swatch frame → { get, label }

-- Keyed BY FRAME, so a rebuilt row overwrites its own entry rather than
-- stacking. A genuinely new frame for the same control still leaves a twin, but
-- twins carry identical label text and collapse in the dedup below.
function UI.RegisterColorSource(frame, get, label)
  if not (frame and get and label) then return end
  colorSources[frame] = { get = get, label = label }
end

-- ★ A tool that owns MANY elements of the same kind — every aura, every overlay
-- — registers a PROVIDER instead of relying on its swatches. Its editor has ONE
-- Recolor control that re-points at whatever is selected, so a per-control
-- getter can only ever report the SELECTION: recolor forty auras and the tooltip
-- still names one (the owner, 2026-07-26, on the case that exposed it). A
-- provider walks the tool's own config and reports every element BY NAME. Only
-- the tool knows how to make that walk, which is why it lives there.
--   fn() → { { color = {r,g,b}, label = "Auras › Recolor (Kill Shot)" }, … }
-- GB needs none: its colors are one-per-PROFILE (GB.db.styleData), not per-bar.
local colorProviders = {}

function UI.RegisterColorProvider(key, fn)
  if not (key and fn) then return end
  colorProviders[key] = fn      -- keyed, so a re-register replaces rather than stacks
end

local function walkProviders(cb)
  for _, fn in pairs(colorProviders) do
    local ok, out = pcall(fn)   -- a tool's walk must never take the picker down
    if ok and type(out) == "table" then
      for _, e in ipairs(out) do
        if type(e) == "table" and type(e.color) == "table" and e.color[1] and e.label then cb(e) end
      end
    end
  end
end

local PROV_MAX = 8   -- past this the tooltip is a wall of text; the rest are counted

local function provenance()
  local map = {}
  local function add(key, label)
    local at = map[key]
    if not at then at = {}; map[key] = at end
    for _, l in ipairs(at) do if l == label then return end end
    at[#at + 1] = label
  end
  walkProviders(function(e) add(hexOf(e.color), e.label) end)
  for _, src in pairs(colorSources) do
    -- pcall: a closure left behind by a rebuilt row can reference a bar or aura
    -- that no longer exists. A dead source must not take the tooltip down.
    local ok, c = pcall(src.get)
    if ok and type(c) == "table" and c[1] then add(hexOf(c), src.label) end
  end
  for _, at in pairs(map) do table.sort(at) end
  return map
end

-- What the row draws: everything known, ordered by HUE. Recency decides what
-- SURVIVES, never where it sits — a row that reshuffles every time you pick a
-- color is a row you can never build any muscle memory on.
local function paletteShown()
  local out = {}
  for _, rec in ipairs(paletteList() or {}) do
    local r = tonumber(rec.hex:sub(1, 2), 16) / 255
    local g = tonumber(rec.hex:sub(3, 4), 16) / 255
    local b = tonumber(rec.hex:sub(5, 6), 16) / 255
    local h, s, v = rgb2hsv(r, g, b)
    out[#out + 1] = { r = r, g = g, b = b, hex = rec.hex, h = h, s = s, v = v }
  end
  local function grey(e) return e.s < 0.08 end
  table.sort(out, function(a, b)
    if grey(a) ~= grey(b) then return grey(b) end      -- greys have no hue: park them last
    if grey(a) then return a.v < b.v end
    if math.abs(a.h - b.h) > 1e-4 then return a.h < b.h end
    return a.v < b.v
  end)
  return out
end

-- ★ The KIT's picker (MINOR 11, 2026-09-21) — the one redesigned control in
-- the PRIMITIVES frame: 440 wide, the night plate with the indigo rim, a
-- 380px column at a 30/20 inset: "Choose Color" · the field (250) + hue
-- strip + preview · "Hex Value" and its white box (the Opacity dial takes
-- the row's right end when the colour has alpha) · "Colors in Use" · OK /
-- CANCEL. The mock's "Use Class Color" button is a colour SOURCE (MINOR 12):
-- `opts.sources = { { value = "class", label = "Use Class Color" }, … }` draws
-- (a source's `color()` → r, g, b seeds the field when it is picked) —
-- one dark button per source at the hex row's right end (on the OK row when
-- the Opacity dial holds that spot); `opts.source` names the one in force
-- (drawn violet). Clicking one SELECTS it — the button lights and the
-- consumer previews it through onChange(value), exactly as a drag previews a
-- colour — and any colour edit after that unselects it. OK then fires
-- `opts.onSource(value)` instead of onAccept; Cancel restores as ever. (The
-- owner, 2026-09-21: a source "shouldn't select and close the picker … the
-- user should still need to click OK".) UI.chip is the consumer.
local PICK_W, SV_W, SV_H = 440, 250, 188
local PICK_X, HUE_X, PRV_X, PRV_W = 30, 289, 330, 80
local PICK_H_PLAIN, PICK_H_ALPHA = 410, 410
local PICK_TOP = 56                      -- the field's top; the title sits above it
local PAL_Y, PAL_SZ, PAL_GAP = 325, 26, 6

function UI.colorPicker(opts)
  opts = opts or {}

  if not pickerDlg then
    local f = CreateFrame("Frame", "GloomSkinColorPicker", UIParent)
    f:SetSize(PICK_W, PICK_H_PLAIN); f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG"); f:EnableMouse(true)
    -- Standing in for the scrim: with nothing dimmed behind it, this rim is the
    -- only thing telling the panel apart from the tab it floats over.
    kitDialogPlate(f)

    -- Drag it by the plate. Every control on it eats its own clicks, so the
    -- empty chrome — the title strip, the margins — is what moves the panel.
    f:SetMovable(true); f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
      self:StopMovingOrSizing()
      -- Re-anchor from the TOP-left: the panel changes height when the Opacity
      -- row comes and goes, and centred anchoring would make it grow upward
      -- into the cursor. Anchored this way it always grows downward.
      local x, y = self:GetLeft(), self:GetTop()
      self:ClearAllPoints()
      self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
    end)

    f.title = UI.newText(f, FONT.uiB, 14, COLOR.paper, "LEFT")
    f.title:SetPoint("TOPLEFT", PICK_X, -20)

    -- ---- saturation / value field --------------------------------------
    -- Solid hue underneath, white→clear left-to-right for SATURATION, then
    -- clear→black top-to-bottom for VALUE. (WoW's "VERTICAL" gradient runs
    -- min at the BOTTOM, max at the top.)
    local sv = CreateFrame("Frame", nil, f)
    sv:SetSize(SV_W, SV_H); sv:SetPoint("TOPLEFT", PICK_X, -PICK_TOP); sv:EnableMouse(true)
    local hueFill = sv:CreateTexture(nil, "BACKGROUND")
    hueFill:SetAllPoints(); hueFill:SetColorTexture(1, 0, 0, 1)
    local satTex = sv:CreateTexture(nil, "BORDER")
    satTex:SetAllPoints(); satTex:SetTexture(WHITE8X8)
    satTex:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(1, 1, 1, 0))
    local valTex = sv:CreateTexture(nil, "ARTWORK")
    valTex:SetAllPoints(); valTex:SetTexture(WHITE8X8)
    valTex:SetGradient("VERTICAL", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 0))
    UI.addEdges(sv, COLOR.rim, 1)

    -- A white square inside a black one: the only marker that stays legible
    -- over BOTH ends of the field. It is a Frame so it draws above the
    -- gradients regardless of texture layer.
    local mark = CreateFrame("Frame", nil, sv)
    mark:SetSize(12, 12); mark:SetFrameLevel(sv:GetFrameLevel() + 2)
    UI.addEdges(mark, { r = 0, g = 0, b = 0, a = 0.85 }, 1)
    local markIn = CreateFrame("Frame", nil, mark)
    markIn:SetPoint("TOPLEFT", 1, -1); markIn:SetPoint("BOTTOMRIGHT", -1, 1)
    UI.addEdges(markIn, { r = 1, g = 1, b = 1, a = 1 }, 1)

    -- ---- hue strip ------------------------------------------------------
    local hue = CreateFrame("Frame", nil, f)
    hue:SetSize(18, SV_H); hue:SetPoint("TOPLEFT", HUE_X, -PICK_TOP); hue:EnableMouse(true)
    local STOPS = { {1,0,0}, {1,1,0}, {0,1,0}, {0,1,1}, {0,0,1}, {1,0,1}, {1,0,0} }
    local segH = SV_H / 6
    for i = 1, 6 do
      local seg = hue:CreateTexture(nil, "ARTWORK")
      seg:SetSize(18, segH); seg:SetPoint("TOPLEFT", 0, -(i - 1) * segH)
      seg:SetTexture(WHITE8X8)
      local hi, lo = STOPS[i], STOPS[i + 1]
      seg:SetGradient("VERTICAL", CreateColor(lo[1], lo[2], lo[3], 1),
                                  CreateColor(hi[1], hi[2], hi[3], 1))
    end
    UI.addEdges(hue, COLOR.rim, 1)
    local hueMark = hue:CreateTexture(nil, "OVERLAY", nil, 2)
    hueMark:SetColorTexture(1, 1, 1, 1); hueMark:SetSize(24, 3)   -- overhangs, so it reads

    -- ---- preview: new on top, original below (click it to go back) ------
    local prv = CreateFrame("Frame", nil, f)
    prv:SetSize(PRV_W, SV_H); prv:SetPoint("TOPLEFT", PRV_X, -PICK_TOP)
    checkerboard(prv, PRV_W, SV_H)
    UI.addEdges(prv, COLOR.rim, 1)
    local newSw = prv:CreateTexture(nil, "ARTWORK")
    newSw:SetPoint("TOPLEFT"); newSw:SetPoint("TOPRIGHT"); newSw:SetHeight(SV_H / 2)
    local oldB = CreateFrame("Button", nil, prv)
    oldB:SetPoint("BOTTOMLEFT"); oldB:SetPoint("BOTTOMRIGHT"); oldB:SetHeight(SV_H / 2)
    f.oldSw = oldB:CreateTexture(nil, "ARTWORK"); f.oldSw:SetAllPoints()
    local seam = prv:CreateTexture(nil, "OVERLAY", nil, 2)
    seam:SetColorTexture(COLOR.rim.r, COLOR.rim.g, COLOR.rim.b, 0.35)
    seam:SetHeight(1); seam:SetPoint("LEFT"); seam:SetPoint("RIGHT")
    UI.attachTip(oldB, "Original", "The color you started with. Click to go back to it.")

    -- ---- hex --------------------------------------------------------------
    local hexY = PICK_TOP + SV_H + 20
    local hexLab = UI.newText(f, FONT.uiB, 12, COLOR.paper, "LEFT")
    hexLab:SetPoint("TOPLEFT", PICK_X, -(hexY + 2)); hexLab:SetText("Hex Value")
    f.hex = UI.field(f, 70)
    f.hex:SetPoint("LEFT", hexLab, "RIGHT", 6, 0)
    f.hex:SetMaxLetters(9)

    -- ---- palette ----------------------------------------------------------
    -- A fixed pool, repainted on every open — its contents change as the user's
    -- own UI does, so it cannot be built once like the rest of the dialog.
    f.palLab = UI.newText(f, FONT.uiB, 12, COLOR.paper, "LEFT")
    f.palLab:SetPoint("TOPLEFT", PICK_X, -(PAL_Y - 24)); f.palLab:SetText("Colors in Use")
    f.palBtns = {}
    for i = 1, PALETTE_MAX do
      local b = CreateFrame("Button", nil, f)
      b:SetSize(PAL_SZ, PAL_SZ); b:SetPoint("TOPLEFT", PICK_X + (i - 1) * (PAL_SZ + PAL_GAP), -PAL_Y)
      b.tex = b:CreateTexture(nil, "ARTWORK"); b.tex:SetAllPoints()
      UI.addEdges(b, COLOR.black, 1)
      b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
      b:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
          UI.ForgetColor(self.hex)
          f:RefreshPalette()
        else
          f:SetRGB(self.r, self.g, self.b)
        end
      end)
      -- Function tips: the swatch under the cursor changes between opens.
      UI.attachTip(b, "In use", function()
        local at = f.prov and f.prov[b.hex]
        local where
        if at and at[1] then
          local list = {}
          for i = 1, math.min(#at, PROV_MAX) do list[i] = "· " .. at[i] end
          if #at > PROV_MAX then list[#list + 1] = ("· +%d more"):format(#at - PROV_MAX) end
          where = table.concat(list, "\n")
        else
          -- Says "haven't looked", not "isn't there" — see the provenance note.
          where = "· not on anything in the tabs you've\n  opened this session"
        end
        return "#" .. (b.hex or ""):upper() .. "\n\n" .. where
            .. "\n\nClick to use it.\nRight-click to remove it."
      end)
      b:Hide()
      f.palBtns[i] = b
    end

    function f:RefreshPalette()
      -- Harvest from the providers first. Swatch harvesting only ever sees the
      -- SELECTED element, so without this an aura you recolored months ago would
      -- never reach the row unless you happened to click it again. Runs before
      -- Show(), which is what keeps it out of NoteColor's open-picker guard.
      walkProviders(function(e) UI.NoteColor(e.color) end)
      local shown = paletteShown()
      self.prov = provenance()   -- recomputed per open, never remembered
      for i, b in ipairs(self.palBtns) do
        local e = shown[i]
        if e then
          b.r, b.g, b.b, b.hex = e.r, e.g, e.b, e.hex
          b.tex:SetColorTexture(e.r, e.g, e.b, 1)
        end
        b:SetShown(e ~= nil)
      end
      self.palLab:SetShown(shown[1] ~= nil)
    end

    -- ---- opacity ----------------------------------------------------------
    -- The kit's dial, at the hex row's right end, only for a colour with alpha.
    f.alphaRow = UI.dial(f, { label = "Opacity", min = 0, max = 100, step = 1, unit = "%",
      get = function() return math.floor((f.a or 1) * 100 + 0.5) end,
      set = function(v) f.a = math.floor(v + 0.5) / 100; f:Emit() end })
    f.alphaRow:SetPoint("TOPLEFT", PICK_X + 380 - 194, -(hexY - 18))
    f.alphaRow.label:SetTextColor(1, 1, 1)
    f.alphaBlock = f.alphaRow
    UI.tint(f.alphaRow.ticks, COLOR.paper, 0.7)

    -- ---- buttons ----------------------------------------------------------
    f.ok = UI.button(f, "OK", { kind = "action" })
    f.ok:SetPoint("BOTTOMLEFT", PICK_X, 20)
    f.cancel = UI.button(f, "Cancel", { kind = "action" })
    f.cancel:SetPoint("LEFT", f.ok, "RIGHT", 6, 0)

    -- ---- colour sources (MINOR 12) ------------------------------------------
    -- A pool of buttons, right-aligned on the hex row (the mock: "Use Class
    -- Color", 131 wide, at x=249 of the 380 column); the OK row when the
    -- Opacity dial has the hex row's end. Picking one is an ACCEPT.
    f.srcBtns = {}
    function f:LaySources(list, current)
      local prev
      self.srcList, self.source = list, current
      for i = #self.srcBtns, 1, -1 do self.srcBtns[i]:Hide() end
      for i = #(list or {}), 1, -1 do
        local src = list[i]
        local b = self.srcBtns[i]
        if not b then
          b = UI.button(self, "", { kind = "action" })
          b:SetScript("OnClick", function(bt)
            f:LaySources(f.srcList, bt.value)
            -- The field, hex and preview take the source's colour (silently —
            -- an edit would unselect it), then the consumer previews it live.
            local r, g, bb
            if bt.src.color then r, g, bb = bt.src.color() end
            if r then f.silent = true; f:SetRGB(r, g, bb); f.silent = false end
            if f.onChange then f.onChange(bt.value) end
          end)
          self.srcBtns[i] = b
        end
        b.value, b.src = src.value, src
        b:SetLabel(src.label or tostring(src.value))
        b:SetActive(src.value == current)
        b:ClearAllPoints()
        if prev then b:SetPoint("RIGHT", prev, "LEFT", -6, 0)
        elseif self.hasAlpha then b:SetPoint("RIGHT", self, "BOTTOMRIGHT", -PICK_X, 20 + 8)
        else b:SetPoint("RIGHT", self, "TOPRIGHT", -PICK_X, -(hexY + 8)) end
        b:Show()
        prev = b
      end
    end

    -- ---- state ------------------------------------------------------------
    function f:Color()
      if self.hasAlpha then return { self.r, self.g, self.b, self.a } end
      return { self.r, self.g, self.b }
    end

    -- Repaint everything from (h, s, v, a), then push the color out live.
    function f:Emit()
      local r, g, b = hsv2rgb(self.h, self.s, self.v)
      self.r, self.g, self.b = r, g, b
      hueFill:SetColorTexture(hsv2rgb(self.h, 1, 1))
      mark:ClearAllPoints()
      mark:SetPoint("CENTER", sv, "BOTTOMLEFT", self.s * SV_W, self.v * SV_H)
      hueMark:ClearAllPoints()
      hueMark:SetPoint("CENTER", hue, "TOP", 0, -self.h * SV_H)
      newSw:SetColorTexture(r, g, b, self.hasAlpha and self.a or 1)
      if not self.hex:HasFocus() then
        self.hex:SetText(("#%02X%02X%02X"):format(byte255(r), byte255(g), byte255(b)))
      end
      if not self.silent and self.source then self:LaySources(self.srcList, nil) end   -- an edit means a fixed colour again
      if self.onChange and not self.silent then self.onChange(self:Color()) end
    end

    function f:SetRGB(r, g, b, a)
      self.h, self.s, self.v = rgb2hsv(r, g, b)
      if a then self.a = a end
      self:Emit()
      self.alphaRow:refresh()
    end

    -- ---- dragging ---------------------------------------------------------
    local function trackSV(self)
      local left, bottom = self:GetLeft(), self:GetBottom()
      if not (left and bottom) then return end
      local scale = self:GetEffectiveScale()
      local mx, my = GetCursorPosition()
      f.s = math.max(0, math.min(1, (mx / scale - left) / SV_W))
      f.v = math.max(0, math.min(1, (my / scale - bottom) / SV_H))
      f:Emit()
    end
    local function trackHue(self)
      local top = self:GetTop()
      if not top then return end
      local scale = self:GetEffectiveScale()
      local _, my = GetCursorPosition()
      f.h = math.max(0, math.min(1, (top - my / scale) / SV_H))
      f:Emit()
    end
    -- Drag-anywhere, same shape as UI.sliderRow's seek: press and hold keeps
    -- tracking until the button comes up, wherever the cursor goes.
    local function draggable(frame, track)
      frame:SetScript("OnMouseDown", function(self) self._drag = true; track(self) end)
      frame:SetScript("OnMouseUp", function(self) self._drag = false end)
      frame:SetScript("OnUpdate", function(self)
        if self._drag then
          if IsMouseButtonDown("LeftButton") then track(self) else self._drag = false end
        end
      end)
    end
    draggable(sv, trackSV)
    draggable(hue, trackHue)

    oldB:SetScript("OnClick", function()
      local o = f.orig
      if o then f:SetRGB(o[1], o[2], o[3], o[4]) end
    end)

    -- ---- hex entry --------------------------------------------------------
    -- Commit on focus LOSS, so Enter, Tab and clicking OK all land the same
    -- way. HookScript, because flatEditBox owns OnEditFocusLost for its fill.
    f.hex:HookScript("OnEditFocusLost", function(self)
      local r, g, b, a = hex2rgb(self:GetText())
      if r then f:SetRGB(r, g, b, f.hasAlpha and a or nil) end
      f:Emit()   -- rewrites the text canonically, or restores it after a typo
    end)
    f.hex:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    f.hex:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- ---- close paths ------------------------------------------------------
    f.ok:SetScript("OnClick", function()
      f.accepted = true
      if f.source then
        local cb, v = f.onSource, f.source
        f:Hide()
        if cb then cb(v) end
        return
      end
      local cb, c = f.onAccept, f:Color()
      UI.NoteColor(c, true)   -- OK, and only OK, counts as a deliberate pick
      f:Hide()
      if cb then cb(c) end
    end)
    f.cancel:SetScript("OnClick", function() f:Hide() end)

    -- Every close path lands here — OK, Cancel, and the UISpecialFrames ESC
    -- that never runs our own handlers. Anything that is not an explicit OK
    -- puts the original color back, because this picker applies LIVE.
    f:HookScript("OnHide", function()
      local cancelled, restore, onCancel = not f.accepted, f.onChange, f.onCancel
      f.onChange, f.onAccept, f.onCancel, f.onSource, f.accepted = nil, nil, nil, nil, false
      if cancelled then
        if restore and f.orig then restore(f.orig) end
        if onCancel then onCancel() end
      end
    end)

    tinsert(UISpecialFrames, "GloomSkinColorPicker")   -- ESC cancels
    f:Hide()
    pickerDlg = f
  end

  local f = pickerDlg
  -- Now that nothing is dimmed, clicking a SECOND swatch while the picker is
  -- open is reachable. Close the first session properly first, so its consumer
  -- gets the cancel-restore it is owed instead of silently keeping whatever was
  -- dragged over it. (The scrim used to make this case impossible.)
  if f:IsShown() then f:Hide() end

  -- Hook each owner once (the UI.dropdown _flyHooked pattern), then let the
  -- handler check whether it is still the LIVE session's owner before closing.
  f.owner = opts.owner
  if opts.owner and not opts.owner._gsPickerHooked then
    opts.owner._gsPickerHooked = true
    opts.owner:HookScript("OnHide", function(self)
      if pickerDlg and pickerDlg:IsShown() and pickerDlg.owner == self then pickerDlg:Hide() end
    end)
  end

  local c = opts.color or { 1, 1, 1 }
  f.hasAlpha = opts.hasAlpha and true or false
  f.orig = { c[1] or 1, c[2] or 1, c[3] or 1, f.hasAlpha and (c[4] or 1) or nil }
  f.a = f.hasAlpha and (c[4] or 1) or 1
  f.onChange, f.onAccept, f.onCancel, f.onSource = opts.onChange, opts.onAccept, opts.onCancel, opts.onSource
  f.accepted = false
  f:LaySources(opts.sources, opts.source)
  f.title:SetText(opts.title or "Choose Color")
  f.oldSw:SetColorTexture(f.orig[1], f.orig[2], f.orig[3], f.hasAlpha and f.a or 1)
  f.alphaBlock:SetShown(f.hasAlpha)
  f:SetHeight(f.hasAlpha and PICK_H_ALPHA or PICK_H_PLAIN)
  f:RefreshPalette()

  -- Seed the widgets WITHOUT firing onChange: opening a picker must not count
  -- as an edit (it would kick every consumer's live-preview work for nothing).
  f.silent = true
  f:SetRGB(f.orig[1], f.orig[2], f.orig[3])
  f.silent = false

  -- No scrimShow: see the header. Raise still matters — it has to sit above the
  -- Suite window it was opened from.
  f:Show(); f:Raise()
  return f
end

-- ------------------------------------------------------------
-- profileBlock (MINOR 3) — the suite's ONE profile/preset management control.
-- the owner, 2026-07-24: "for this mechanism (selecting a profile/preset, creating
-- a new one, copying, renaming, deleting) they should all be using the same
-- thing." GB's rail block was the correct shape; its one flaw — a Delete that
-- self-armed to "Sure?" with no way to cancel — is fixed here by routing every
-- delete through UI.confirm.
--
-- The tool supplies only its data plumbing; the widget owns all of the UI,
-- wording and confirm flow, so the mechanism is identical in every tab:
--   api.noun      "profile" | "preset"  (dialog + message wording)
--   api.names()   → { name, … }         (already ordered)
--   api.active()  → name
--   api.switch(name)
--   api.create(name)  → ok, err
--   api.copy(name)    → ok, err          -- OPTIONAL; omit for a 3-across row
--   api.rename(name)  → ok, err
--   api.delete()      → ok, err          -- deletes the ACTIVE one
--   api.onChange()                       -- OPTIONAL; after any success
--   api.title     header text            -- OPTIONAL; defaults to noun:upper()
--   api.accent    button colour token     -- OPTIONAL; defaults to COLOR.heroic.
--                                         -- Set it when TWO blocks share one rail
--                                         -- and must not read as the same control
--                                         -- (GB's rail: purple profile, orange preset).
--   api.tips      { dropdown=, new=, copy=, rename=, delete= }
--                                        -- OPTIONAL; per-tool hover-help bodies
-- `err` is shown verbatim in the inline note line; ok=false with no err is silent.
-- Returns { frame, refresh, note, height }.
-- ------------------------------------------------------------
-- The four actions, shared by the rail block below and the kit's footer row
-- (`UI.profileRow`, MINOR 11): each returns a click handler; `after(ok, err)`
-- is the block's own "refresh or show the error" step.
local function profileActions(api, after)
  local noun = api.noun or "profile"
  -- The delete gate (the owner, 2026-09-20: "the following characters are
  -- using this profile, are you sure?"). `api.users(name)` returns the keys of
  -- every character bound to it — "Name-Realm" or "Name - Realm", the tool's
  -- own format; this trims each to the character's name and leaves out the
  -- character you are on, who is always on the active profile.
  local function others(name)
    if not api.users then return nil end
    local me, out = UnitName("player"), {}
    for _, key in ipairs(api.users(name) or {}) do
      local char = tostring(key):match("^%s*([^-]-)%s*%-") or tostring(key)
      if char ~= me then out[#out + 1] = char end
    end
    table.sort(out)
    return out
  end
  local A = {}
  function A.new()
    UI.nameDialog("New " .. noun, "", function(name)
      if not name or name == "" then return end
      after(api.create(name))
    end)
  end
  function A.copy()
    UI.nameDialog("Copy " .. noun, (api.active() or "") .. " copy", function(name)
      if not name or name == "" then return end
      after(api.copy(name))
    end)
  end
  function A.rename()
    UI.nameDialog("Rename " .. noun, api.active() or "", function(name)
      if not name or name == "" then return end
      after(api.rename(name))
    end)
  end
  function A.delete()
    local active = api.active()
    if not active then return end
    local list = others(active)
    local body
    if list and #list > 0 then
      local names = #list == 1 and list[1]
        or (table.concat(list, ", ", 1, #list - 1) .. " and " .. list[#list])
      body = ("Delete the %s \"%s\"?\n\nBesides this character, it's in use by |cffffffff%s|r — %s fall back to another %s.\n\nThis can't be undone.")
        :format(noun, active, names, #list == 1 and "that character will" or "they'll", noun)
    else
      body = ("Delete the %s \"%s\"?  This can't be undone."):format(noun, active)
    end
    UI.confirm(body, function() after(api.delete()) end)
  end
  return A
end

-- The hover-help for the four buttons + dropdown, shared the same way.
local function profileTips(api, dd, bNew, bCopy, bRen, bDel)
  local noun = api.noun or "profile"
  local Noun = noun:sub(1, 1):upper() .. noun:sub(2)
  local tips = api.tips or {}
  UI.attachTip(dd, Noun, tips.dropdown or ("The active " .. noun .. ". Click to switch."))
  UI.attachTip(bNew, "New " .. noun, tips.new or ("Creates a new " .. noun .. " and switches to it."))
  if bCopy then
    UI.attachTip(bCopy, "Copy " .. noun,
      tips.copy or ("Duplicates this " .. noun .. " under a new name and switches to the copy."))
  end
  UI.attachTip(bRen, "Rename " .. noun, tips.rename or ("Renames this " .. noun .. "."))
  UI.attachTip(bDel, "Delete " .. noun,
    tips.delete or ("Deletes this " .. noun .. ". Asks you to confirm first."))
end

function UI.profileBlock(parent, w, api)
  local noun = api.noun or "profile"
  local hasCopy = type(api.copy) == "function"
  local block = { }

  local f = CreateFrame("Frame", nil, parent)
  f:SetSize(w, hasCopy and 112 or 88)
  block.frame = f

  local head = UI.newText(f, FONT.head, 12, COLOR.mute, "LEFT")
  head:SetPoint("TOPLEFT", 0, 0); head:SetText(api.title or noun:upper())

  -- Orange, not mute: this line only ever carries failures ("name already
  -- exists", "can't delete the last one") and read as decoration in grey.
  local note = UI.newText(f, FONT.body, 10.5, COLOR.orange, "LEFT")
  note:SetPoint("TOPLEFT", 0, hasCopy and -94 or -70); note:SetWidth(w)
  note:SetWordWrap(true)
  function block:note(text) note:SetText(text or "") end

  local dd
  local function after(ok, err)
    if ok then
      block:note("")
      dd:refresh()
      if api.onChange then api.onChange() end
    else
      block:note(err or "")
    end
  end

  dd = UI.dropdown(f, w,
    function() return api.active() end,
    function()
      local out = {}
      for _, name in ipairs(api.names() or {}) do out[#out + 1] = { value = name, label = name } end
      return out
    end,
    function() return api.active() end,
    function(v) block:note(""); api.switch(v); if api.onChange then api.onChange() end end)
  dd:SetPoint("TOPLEFT", 0, -18)
  block.dropdown = dd

  local accent = api.accent or COLOR.heroic
  local function btn(x, y, bw, label)
    local b = UI.flatButton(f, bw, 20, accent, label, 11)
    b:SetBase(0.2); b:SetPoint("TOPLEFT", x, y)
    return b
  end

  local bNew, bCopy, bRen, bDel
  if hasCopy then
    local bw = (w - 4) / 2                      -- 2×2 grid
    bNew  = btn(0, -46, bw, "New")
    bCopy = btn(bw + 4, -46, bw, "Copy")
    bRen  = btn(0, -70, bw, "Rename")
    bDel  = btn(bw + 4, -70, bw, "Delete")
  else
    local bw = (w - 8) / 3                      -- 3-across row
    bNew = btn(0, -46, bw, "New")
    bRen = btn(bw + 4, -46, bw, "Rename")
    bDel = btn(2 * (bw + 4), -46, bw, "Delete")
  end

  local act = profileActions(api, after)
  bNew:SetScript("OnClick", act.new)
  if bCopy then bCopy:SetScript("OnClick", act.copy) end
  bRen:SetScript("OnClick", act.rename)
  bDel:SetScript("OnClick", act.delete)
  profileTips(api, dd, bNew, bCopy, bRen, bDel)

  function block:refresh() dd:refresh() end
  block.height = f:GetHeight()
  return block
end

-- ------------------------------------------------------------
-- Font pre-warmer. WoW rasterizes a (font file, size) pair the first time it
-- is DRAWN in a client session — and the first draw of a cold pair can render
-- blank text (QA'd 2026-07-24: cold start → blank catalog names; /reload in
-- the same session → fine, because the pairs were warm by then; next cold
-- start → blank again). So right after login we draw every pair the suite UI
-- uses once, imperceptibly (1px frame, alpha 0.01, bottom-left), so the real
-- UI — built lazily later — only ever touches warm pairs.
--
-- Two entry points (CONTRACTS §4):
--   UI.RegisterWarmPairs{ {path,size}, … } — any suite tool queues its extra
--     pairs at file load; they warm with the batch at PLAYER_ENTERING_WORLD.
--     Called after the batch already ran (late/on-demand load), it warms
--     immediately instead — registration is always safe.
--   UI.WarmFonts(extraPairs) — the Hub calls this ONCE at PEW (Media.lua's
--     RegisterAll); it draws the base list + everything registered + the arg.
-- Each (path, size) pair is drawn at most once per session.
-- Both return `dead` — a `path → true` map of every pair whose face would not
-- load, or nil if all were fine. Media.lua uses it to name a broken catalog
-- entry; callers that don't care can ignore it.
-- ------------------------------------------------------------
local WARM = {   -- the Hub's own pairs (Shell + Media tab + the lib's own widgets)
  { "title", { 17, 21 } },          -- 17: nameDialog / confirm titles (MINOR 3)
  { "head",  { 12, 16 } },          -- 12: profileBlock header (MINOR 3)
  { "body",  { 10.5, 11, 12, 13 } },
  { "bodyM", { 11, 12, 13 } },
  { "label", { 11 } },              -- sliderRow's value text — a LIB widget, so the
                                    -- base list owes it (MINOR 6, when colorPicker's
                                    -- Opacity row made the lib draw one itself).
  -- The kit (MINOR 11): buttons/inputs 11 · labels 12 · section headers 14 ·
  -- wordmarks 12 (footer) / 14 (banner, Player/Target) / 22 (the window).
  { "ui",    { 11 } },
  { "uiB",   { 12, 14 } },
  { "mark",  { 12, 14, 18, 22 } },  -- 18: the glass panels' titles (MINOR 14)
  -- The dark and glass kits (MINOR 13-14): Saira 10 (buttons, dropdowns, small
  -- notes) · 11 (values, switches, rows) · 12 (labels) · 14 (the aura header);
  -- Bold 11/12 (the aura list, group titles); Medium 10 (buttons, dropdowns, lists).
  { "sa",    { 10, 11, 12, 14 } },
  { "saB",   { 11, 12, 14 } },
  { "saM",   { 10 } },
}
local warmer, warmRan
local pendingPairs = {}   -- registered before the PEW batch
local warmedKeys = {}     -- "(path)@(size)" → true; never draw a pair twice

-- Returns true if the face actually applied. Because every catalog font is
-- warmed here before anything else uses it, this doubles as the one cheap
-- existence check the client allows us — WoW exposes no filesystem API, so a
-- failed draw is the only way to learn that a saved filename is a typo or that
-- its .ttf has been deleted.
local function drawPair(path, size)
  if not path or not size then return true end
  local key = tostring(path) .. "@" .. tostring(size)
  local cached = warmedKeys[key]
  if cached ~= nil then return cached end
  local fs = warmer:CreateFontString(nil, "OVERLAY")
  local ok = UI.setFont(fs, path, size)
  warmedKeys[key] = ok
  fs:SetPoint("BOTTOMLEFT", 0, 0)
  fs:SetText("Ag")
  return ok
end

-- ⚠ THE FIRST DRAW OF A COLD PAIR IS NOT A VERDICT. This whole file exists
-- because a cold pair's first draw misbehaves — the comment at the top of the
-- section records it: "cold start -> blank catalog names; /reload in the same
-- session -> fine, because the pairs were warm by then". The probe was reading
-- that first, unreliable draw as proof the FILE was missing, which made it
-- self-defeating: the very act performed to warm a font was the act it judged.
--
-- TESTED 2026-09-08 (FINDINGS §5): the owner's two drop-in catalog fonts were
-- named as missing on every cold client start, never on /reload, and a manual
-- SetFont on the same path and size returned true moments later. The files were
-- present, correctly named, and valid TrueType the entire time. The Hub's own
-- bundled faces never tripped it because its UI has already touched them.
--
-- So a failure is now only a CANDIDATE. `onVerified` gets the paths that still
-- fail on a second draw, once the first has had a chance to load the file. A
-- genuinely missing or misnamed file fails both passes, so the real signal —
-- catching a typo'd filename or a deleted .ttf — survives intact.
local function warmBatch(pairs, onVerified)
  if not warmer then
    warmer = CreateFrame("Frame", nil, UIParent)
    warmer:SetPoint("BOTTOMLEFT", 0, 0); warmer:SetSize(1, 1)
    warmer:SetFrameStrata("BACKGROUND")
    warmer:SetAlpha(0.01)
  end
  local dead        -- path → true, for every pair whose face would not apply
  local suspects    -- the (path, size) pairs behind those, for the second pass
  for _, pair in ipairs(pairs or {}) do
    if not drawPair(pair[1], pair[2]) then
      dead = dead or {}
      dead[pair[1]] = true
      suspects = suspects or {}
      suspects[#suspects + 1] = pair
    end
  end
  warmer:Show()
  C_Timer.After(2, function() warmer:Hide() end)   -- 2s on screen = safely rasterized

  if onVerified then
    if not suspects then
      onVerified(nil)
    else
      -- Same 2s the warmer stays up for, and for the same reason: by then the
      -- first draw has been rasterized and the face is loaded if it can be.
      C_Timer.After(2, function()
        local still
        for _, pair in ipairs(suspects) do
          -- Clear the cached COLD answer, or drawPair just repeats it.
          warmedKeys[tostring(pair[1]) .. "@" .. tostring(pair[2])] = nil
          if not drawPair(pair[1], pair[2]) then
            still = still or {}
            still[pair[1]] = true
          end
        end
        onVerified(still)
      end)
    end
  end
  return dead   -- first-pass result; unchanged for callers that don't pass onVerified
end

function UI.RegisterWarmPairs(list)
  if warmRan then
    return warmBatch(list)
  else
    for _, pair in ipairs(list or {}) do pendingPairs[#pendingPairs + 1] = pair end
  end
end

-- `onVerified(stillDead)` (MINOR 8, optional) fires ~2s later with only the
-- paths that failed a SECOND draw — the trustworthy answer. The synchronous
-- return value is the first-pass guess and must not be used to accuse a file.
function UI.WarmFonts(extraPairs, onVerified)
  warmRan = true
  local all = {}
  for _, entry in ipairs(WARM) do
    for _, size in ipairs(entry[2]) do all[#all + 1] = { FONT[entry[1]], size } end
  end
  for _, pair in ipairs(pendingPairs) do all[#all + 1] = pair end
  for _, pair in ipairs(extraPairs or {}) do all[#all + 1] = pair end
  return warmBatch(all, onVerified)
end

-- The hover tooltip. One shared frame; attachTip(frame, title, body) wires
-- OnEnter/OnLeave via HookScript so it coexists with existing hover scripts.
-- ★ Restyled for the kit (MINOR 11): the mocks draw no tooltip, so this is
-- DERIVED from the colour picker — the night plate with the indigo rim, Play
-- Bold 12 title in lilac, Play 11 body in white.
local tipFrame, tipTitle, tipBody
local function showTip(owner, title, body)
  if not tipFrame then
    tipFrame = CreateFrame("Frame", nil, UIParent)
    tipFrame:SetFrameStrata("TOOLTIP")
    local plate = tipFrame:CreateTexture(nil, "BACKGROUND"); plate:SetAllPoints()
    plate:SetColorTexture(COLOR.night.r, COLOR.night.g, COLOR.night.b, 1)
    UI.addEdges(tipFrame, COLOR.indigo, 1)
    tipTitle = UI.newText(tipFrame, FONT.uiB, 12, COLOR.lilac, "LEFT")
    tipTitle:SetPoint("TOPLEFT", 10, -8)
    tipBody = UI.newText(tipFrame, FONT.ui, 11, COLOR.paper, "LEFT")
    tipBody:SetPoint("TOPLEFT", 10, -26); tipBody:SetWidth(220); tipBody:SetJustifyH("LEFT")
  end
  tipTitle:SetText(title or "")
  tipBody:SetText(body or "")
  tipFrame:ClearAllPoints()
  tipFrame:SetPoint("BOTTOMRIGHT", owner, "TOPRIGHT", 0, 4)
  tipFrame:SetSize(240, 34 + tipBody:GetStringHeight())
  tipFrame:Show()
end
-- title/body may be FUNCTIONS, resolved at hover time — for a widget whose
-- content changes under a tip that can only be hooked once (colorPicker's
-- palette pool). Plain strings behave exactly as before.
-- ★ MINOR 18 (2026-09-27, the owner): a tooltip waits UI.TIP_DELAY (1 s) of
-- hovering before it shows, so tips on every setting never get in the way.
-- And it reaches INSIDE the kit's composite controls — a switch's segments, a
-- dial's ticks and box, a color's pill and checkbox — which take the mouse
-- themselves: a tip hooked on their outer frame never fired.
UI.TIP_DELAY = 1
local tipTimer
function UI.attachTip(f, title, body)
  if not f then return end
  local parts = {}
  if rawget(f, "segs") then for _, sg in ipairs(f.segs) do parts[#parts + 1] = sg end end
  if rawget(f, "strip") then parts[#parts + 1] = f.strip end
  if rawget(f, "box") and f.box.HookScript then parts[#parts + 1] = f.box end
  if rawget(f, "pill") then parts[#parts + 1] = f.pill end
  if rawget(f, "check") and f.check.HookScript then parts[#parts + 1] = f.check end
  if #parts == 0 then parts[1] = f end
  for _, part in ipairs(parts) do
    part:HookScript("OnEnter", function()
      if tipTimer then tipTimer:Cancel(); tipTimer = nil end
      local function show()
        tipTimer = nil
        if not part:IsVisible() or (part.IsMouseOver and not part:IsMouseOver()) then return end
        showTip(part, type(title) == "function" and title() or title,
                      type(body)  == "function" and body()  or body)
      end
      if C_Timer and C_Timer.NewTimer and (UI.TIP_DELAY or 0) > 0 then tipTimer = C_Timer.NewTimer(UI.TIP_DELAY, show)
      else show() end
    end)
    part:HookScript("OnLeave", function()
      if tipTimer then tipTimer:Cancel(); tipTimer = nil end
      if tipFrame then tipFrame:Hide() end
    end)
  end
end

-- ------------------------------------------------------------
-- UI.tabHeader (MINOR 4) — the suite's standard TAB HEADER: the owning
-- tool's square mark beside its wordmark, with a divider underneath.
--
-- The owner, 2026-07-25: he saw this on the Overlays tab ("a small copy of
-- the header next to the name") and wants it on every tab. Overlays built
-- it inline first; this promotes that exact geometry into the lib so the
-- four tabs cannot drift apart. Overlays now CONSUMES this instead.
--
-- Sized for the 2026-07-25 square art (512×512, transparent, no baked-in
-- name text). The default 26px matches the shell title bar's 28px mark at
-- tab scale; the divider sits at -48, the family constant the shell's own
-- title divider uses.
--
--   opts = { texture (required), label (required),
--            x = 14, y = -12, size = 26, gap = 9, fontSize = 17,
--            divY = -48, rightInset = x }
--
-- Returns { logo, text, divider, bottom }, where BOTTOM is the y offset the
-- caller should anchor its first row below (divY, so content clears it).
-- ------------------------------------------------------------
function UI.tabHeader(parent, opts)
  opts = opts or {}
  local x    = opts.x or 14
  local size = opts.size or 26
  local divY = opts.divY or -48
  local h = {}

  h.logo = parent:CreateTexture(nil, "ARTWORK")
  h.logo:SetTexture(opts.texture)
  h.logo:SetSize(size, size)          -- square: the art is 1:1, never stretch it
  h.logo:SetPoint("TOPLEFT", x, opts.y or -12)

  h.text = UI.newText(parent, FONT.title, opts.fontSize or 17, COLOR.text, "LEFT")
  h.text:SetPoint("LEFT", h.logo, "RIGHT", opts.gap or 9, 0)
  h.text:SetText(opts.label or "")

  h.divider = UI.hLine(parent)
  h.divider:SetPoint("TOPLEFT", x, divY)
  h.divider:SetPoint("TOPRIGHT", -(opts.rightInset or x), divY)

  h.bottom = divY
  return h
end

-- ------------------------------------------------------------
-- UI.grid (MINOR 9) — the two-column placer. The owner, 2026-09-19: EUI "compacts
-- the settings panels into dropdowns and side-by-side display, whereas you tend
-- to just stack things endlessly." A grid lays cells two per line (label +
-- control each), full-width rows where a control needs the room, and restacks
-- when a cell is hidden — no gaps, no fixed y arithmetic in the tab.
--
--   local g = UI.grid(parent, yTop, { cols = 2, gutter = 0, x = 0, rightInset = 0 })
--                     cols = 1 makes every cell a full row (a popover's stack).
--   g:cell(h, build)  → a half-width Frame; build(cell) fills it. Two per line.
--   g:row(h, build)   → a full-width Frame (a half-filled line is closed first).
--   g:gap(px)         → vertical space.
--   g:endLine()       → close a half-filled line (the next cell starts a new one).
--   g:show(f, on)     → hide/show a cell or row; a line whose cells are all
--                       hidden collapses. Call g:layout() afterwards.
--   g:layout()        → restack; sets g.height (yTop → bottom, positive).
--
-- Cells anchor by the parent's edges and centre, so they follow the parent's
-- width with no numbers of their own. Widgets inside a cell keep their usual
-- insets (sliderRow's 18px), so the outer margin is the family's and the two
-- columns get a 36px gutter for free. Set `gutter` to widen it.
-- ------------------------------------------------------------
function UI.grid(parent, yTop, opts)
  opts = opts or {}
  local g = { parent = parent, top = yTop or 0, lines = {}, height = 0, cols = opts.cols or 2,
              gutter = opts.gutter or 0, x = opts.x or 0, rightInset = opts.rightInset or 0 }
  local open   -- the current half-filled line, if any

  local function newLine() local l = { cells = {}, h = 0 }; g.lines[#g.lines + 1] = l; return l end
  local function place(f, l, col)
    f:ClearAllPoints()
    local y = l.y or 0
    if col == "full" then
      f:SetPoint("TOPLEFT", parent, "TOPLEFT", g.x, y)
      f:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -g.rightInset, y)
    elseif col == 1 then
      f:SetPoint("TOPLEFT", parent, "TOPLEFT", g.x, y)
      f:SetPoint("TOPRIGHT", parent, "TOP", -g.gutter / 2, y)
    else
      f:SetPoint("TOPLEFT", parent, "TOP", g.gutter / 2, y)
      f:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -g.rightInset, y)
    end
  end

  function g:cell(h, build)
    if self.cols == 1 then return self:row(h, build) end   -- a one-column grid: every cell is a row
    local l = open
    if not l then l = newLine(); open = l end
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(h); f.gridH, f.gridLine = h, l
    l.cells[#l.cells + 1] = f
    if #l.cells == 2 then open = nil end
    if build then build(f) end
    return f
  end
  function g:row(h, build)
    open = nil
    local l = newLine()
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(h); f.gridH, f.gridLine, f.gridFull = h, l, true
    l.cells[1] = f
    if build then build(f) end
    return f
  end
  function g:gap(px) open = nil; local l = newLine(); l.gap = px end
  function g:endLine() open = nil end   -- the next cell starts a new line even if this one is half full
  function g:show(f, on)
    f.gridHidden = not on
    f:SetShown(on and true or false)
  end
  function g:layout()
    local y = self.top
    for _, l in ipairs(self.lines) do
      if l.gap then
        y = y - l.gap
      else
        local h, any = 0, false
        for _, f in ipairs(l.cells) do
          if not f.gridHidden then any = true; if f.gridH > h then h = f.gridH end end
        end
        l.y = y
        for i, f in ipairs(l.cells) do
          place(f, l, f.gridFull and "full" or i)
          f:SetShown(not f.gridHidden)
        end
        if any then y = y - h end
      end
    end
    self.height = self.top - y
    return self.height
  end
  return g
end

-- ------------------------------------------------------------
-- UI.popover (MINOR 9) — a small anchored panel for a control's SUB-SETTINGS:
-- the shield tint behind the health ring's "Tint while shielded", an effect's
-- own parameters behind its dropdown. The family plate with the color picker's
-- purple rim (no scrim: you are judging the thing it changes), hanging off its
-- owner's bottom-right corner, clamped to the screen. Closes on any click
-- outside it (a full-screen catcher, as the dropdown flyout), on its owner
-- hiding, or when another popover opens. Built lazily, once, on first open.
--
--   local p = UI.popover({ owner = <frame>, w = 300, title = "SHIELD TINT",
--                          build = function(content) … return contentHeight end,
--                          onOpen = function(content) … end })   -- refresh, each open;
--                                        -- may return a new content height
--   p:open() · p:close() · p:toggle() · p:isOpen() · p.frame (nil until first open)
--
-- Layering: the catcher sits at FULLSCREEN level 0 and the panel just above
-- it; the dropdown flyout's catcher is raised above BOTH, so a list opened from
-- inside a popover dismisses cleanly, and the color picker (FULLSCREEN_DIALOG)
-- floats over everything as it already does.
-- ------------------------------------------------------------
local POP_TITLE_H, POP_PAD = 48, 20   -- the kit title sits at y=20; content starts under it
local popCatcher, popOpen

local function popCatcherFrame()
  if popCatcher then return popCatcher end
  local c = CreateFrame("Button", nil, UIParent)
  c:SetFrameStrata("FULLSCREEN"); c:SetFrameLevel(0); c:SetAllPoints(UIParent); c:Hide()
  c:SetScript("OnClick", function() if popOpen then popOpen:close() end end)
  c:SetScript("OnHide", function() if popOpen then popOpen:close() end end)
  popCatcher = c
  return c
end

function UI.popover(opts)
  opts = opts or {}
  local p = { opts = opts }

  local function build()
    local c = popCatcherFrame()
    local f = CreateFrame("Frame", nil, c)
    f:SetFrameStrata("FULLSCREEN"); f:SetFrameLevel(5)
    f:EnableMouse(true); f:SetClampedToScreen(true)
    -- The kit's dialog family (MINOR 12, 2026-09-21): the picker's night plate
    -- and indigo rim, the title Play Bold 14 white at the picker's inset.
    kitDialogPlate(f)
    f.title = UI.newText(f, FONT.uiB, 14, COLOR.paper, "LEFT")
    f.title:SetPoint("TOPLEFT", 30, -20); f.title:SetText((opts.title or ""):upper())
    f.content = CreateFrame("Frame", nil, f)
    f.content:SetPoint("TOPLEFT", 0, -POP_TITLE_H); f.content:SetPoint("TOPRIGHT", 0, -POP_TITLE_H)
    local h = opts.build and opts.build(f.content) or 100
    f.content:SetHeight(h)
    f:SetSize(opts.w or 300, POP_TITLE_H + h + POP_PAD)
    p.frame = f
    if opts.owner then
      opts.owner:HookScript("OnHide", function() if popOpen == p then p:close() end end)
    end
    return f
  end

  function p:isOpen() return popOpen == self end
  function p:close()
    if popOpen ~= self then return end
    popOpen = nil
    if self.frame then self.frame:Hide() end
    popCatcherFrame():Hide()
    if opts.onClose then opts.onClose(self.frame and self.frame.content) end
  end
  function p:open()
    if popOpen and popOpen ~= self then popOpen:close() end
    local f = self.frame or build()
    if opts.onOpen then
      local h = opts.onOpen(f.content)   -- may return a new content height
      if h then f.content:SetHeight(h); f:SetHeight(POP_TITLE_H + h + POP_PAD) end
    end
    f:ClearAllPoints()
    if opts.owner then f:SetPoint("TOPRIGHT", opts.owner, "BOTTOMRIGHT", 0, -4)
    else f:SetPoint("CENTER") end
    popOpen = self
    popCatcherFrame():Show(); f:Show()
  end
  function p:toggle() if self:isOpen() then self:close() else self:open() end end
  return p
end

-- UI.cog (MINOR 9) — the little gear that opens a popover of sub-settings; sits
-- beside the control it belongs to. `opts` are UI.popover's, with the cog as
-- the owner. Purple at rest, orange while its popover is open. Returns the
-- button, with `.popover`.
function UI.cog(parent, opts)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(16, 16)
  local tex = b:CreateTexture(nil, "ARTWORK"); tex:SetAllPoints(); tex:SetTexture(UI.COG)
  local function paint(hover)
    local c = (b.popover and b.popover:isOpen() or hover) and COLOR.orange or COLOR.purple
    tex:SetVertexColor(c.r, c.g, c.b)
  end
  opts = opts or {}; opts.owner = b
  local inner = opts.onClose
  opts.onClose = function(...) paint(false); if inner then inner(...) end end
  b.popover = UI.popover(opts)
  b:SetScript("OnClick", function() b.popover:toggle(); paint(false) end)
  b:SetScript("OnEnter", function() paint(true) end)
  b:SetScript("OnLeave", function() paint(false) end)
  if opts.tip then UI.attachTip(b, opts.tip[1], opts.tip[2]) end
  paint(false)
  return b
end

-- ------------------------------------------------------------
-- ★ THE KIT (MINOR 11, 2026-09-21) — the redesign's widgets, built from the
-- PRIMITIVES frame of the owner's Figma mocks (BACKLOG 16, stage 1).
--
-- The rules the mocks set, and that every widget here keeps:
--   · light grey window; 4px corners on everything, from ONE nine-slice
--   · buttons are 17px tall, Play 11 UPPERCASE, 20px side padding, 6px apart;
--     DARK = an action, VIOLET = a persisting state (a tab, a chosen option),
--     AMBER = destructive, 50% alpha = unavailable. Hover/pressed are quiet.
--   · labels are Play Bold 12 in ink; section headers Play Bold 14 in violet
--   · inputs are white; the scrub DIAL replaces every slider
-- The pre-kit widgets above stay callable until the last tab has migrated.
-- ------------------------------------------------------------

local SLICE = 5   -- round4.png is 16×16 with 4px corners; 5 keeps the anti-aliasing intact
local STRETCHED = (Enum.UITextureSliceMode and Enum.UITextureSliceMode.Stretched) or 0

-- A rounded texture, white, for the caller to tint. `anchored` = fill the parent.
local function roundTex(parent, layer, anchored)
  local t = parent:CreateTexture(nil, layer or "BACKGROUND")
  t:SetTexture(UI.ROUND)
  t:SetTextureSliceMargins(SLICE, SLICE, SLICE, SLICE)
  t:SetTextureSliceMode(STRETCHED)
  if anchored then t:SetAllPoints() end
  return t
end
function UI.roundFill(parent, layer) return roundTex(parent, layer, true) end
function UI.tint(t, c, a) t:SetVertexColor(c.r, c.g, c.b, a or c.a or 1) end

local function hexOf(c)
  return c.hex or ("%02x%02x%02x"):format(math.floor(c.r * 255 + 0.5), math.floor(c.g * 255 + 0.5), math.floor(c.b * 255 + 0.5))
end

-- The four button kinds. `state` is also what any kind becomes while active.
local KIND = {
  action = { fill = "ink",    text = "paper" },
  state  = { fill = "violet", text = "paper" },
  warn   = { fill = "amber",  text = "black" },
  quiet  = { fill = "dim",    text = "paper" },
  paper  = { fill = "paper",  text = "black" },
}

-- UI.button(parent, label, opts?) → Button with .text, :SetLabel(s), :SetActive(on),
-- :SetKind(k), :paint(). Width follows the label (+2×padX) unless `w` is given.
--   opts = { kind = "action"|"state"|"warn"|"quiet"|"paper", w, h = 17, size = 11,
--            padX = 20, font = FONT.ui, caps = true, active, onClick }
function UI.button(parent, label, opts)
  opts = opts or {}
  local b = CreateFrame("Button", nil, parent)
  b:SetHeight(opts.h or 17)
  b.fill = roundTex(b, "BACKGROUND", true)
  b.hover = roundTex(b, "BORDER", true); b.hover:SetVertexColor(1, 1, 1, 0.10); b.hover:Hide()
  b.text = UI.newText(b, opts.font or FONT.ui, opts.size or 11, COLOR.paper, "CENTER")
  b.text:SetPoint("CENTER", 0, 0)
  b:SetFontString(b.text)
  b._kind, b._active, b._caps = opts.kind or "action", opts.active and true or false, opts.caps ~= false
  b._padX, b._fixedW = opts.padX or 20, opts.w
  function b:paint()
    local k = KIND[self._active and "state" or self._kind] or KIND.action
    UI.tint(self.fill, COLOR[k.fill])
    local tc = COLOR[k.text]; self.text:SetTextColor(tc.r, tc.g, tc.b)
    self:SetAlpha(self:IsEnabled() and 1 or 0.5)
  end
  function b:SetLabel(txt)
    txt = tostring(txt or "")
    self.text:SetText(self._caps and txt:upper() or txt)
    self:SetWidth(self._fixedW or (self.text:GetStringWidth() + 2 * self._padX))
  end
  function b:SetActive(on) self._active = on and true or false; self:paint() end
  function b:SetKind(k) self._kind = k; self:paint() end
  b:SetScript("OnEnter", function(self) if self:IsEnabled() then self.hover:Show() end end)
  b:SetScript("OnLeave", function(self) self.hover:Hide() end)
  b:SetScript("OnMouseDown", function(self) if self:IsEnabled() then self.hover:SetVertexColor(0, 0, 0, 0.12) end end)
  b:SetScript("OnMouseUp", function(self) self.hover:SetVertexColor(1, 1, 1, 0.10) end)
  b:SetScript("OnEnable", function(self) self:paint() end)
  b:SetScript("OnDisable", function(self) self:paint() end)
  if opts.onClick then b:SetScript("OnClick", opts.onClick) end
  b:SetLabel(label or "")
  b:paint()
  return b
end

-- UI.label(parent, text) → the field label: Play Bold 12, ink.
function UI.label(parent, text)
  local fs = UI.newText(parent, FONT.uiB, 12, COLOR.ink, "LEFT")
  fs:SetText(text or "")
  return fs
end

-- UI.segments(parent, options, get, set, opts?) → the segmented bar: one violet
-- segment on a dim track. options = { { value =, label = }, … }. Returns the
-- Frame with :refresh(), :setEnabled(on), .segs. `opts.segW` makes every
-- segment that wide (the mocks size most by their label).
function UI.segments(parent, options, get, set, opts)
  opts = opts or {}
  local f = CreateFrame("Frame", nil, parent)
  f:SetHeight(opts.h or 17)
  f.track = roundTex(f, "BACKGROUND", true); UI.tint(f.track, COLOR.dim)
  f.segs = {}
  local prev, total = nil, 0
  for i, opt in ipairs(options) do
    local sg = UI.button(f, opt.label, { kind = "quiet", h = opts.h, padX = opts.padX, w = opts.segW })
    sg.value = opt.value
    sg.paint = function(self)   -- a segment is transparent until it is the choice: the TRACK shows through
      if self._active then UI.tint(self.fill, COLOR.violet) else self.fill:SetVertexColor(0, 0, 0, 0) end
      self.text:SetTextColor(1, 1, 1)
      self:SetAlpha(self:IsEnabled() and 1 or 0.5)
    end
    sg:paint()
    -- A TWO-way bar flips when its current side is clicked (the owner,
    -- 2026-09-21: "a natural expectation … frustrating every time").
    sg:SetScript("OnClick", function(self)
      local v = self.value
      if #options == 2 and self._active then v = options[i == 1 and 2 or 1].value end
      set(v); f:refresh()
    end)
    if prev then sg:SetPoint("LEFT", prev, "RIGHT", 0, 0) else sg:SetPoint("LEFT", 0, 0) end
    total = total + sg:GetWidth()
    prev = sg
    f.segs[i] = sg
  end
  f:SetWidth(total)
  function f:refresh()
    local cur = get()
    for _, sg in ipairs(self.segs) do sg:SetActive(sg.value == cur) end
  end
  function f:setEnabled(on)
    for _, sg in ipairs(self.segs) do sg:SetEnabled(on) end
    -- ★ Not Texture:SetAlpha — on a texture that REPLACES the vertex alpha the
    -- dim tint carries (0.5), and the track went solid #3e3e3e (2026-09-21).
    UI.tint(self.track, COLOR.dim, COLOR.dim.a * (on and 1 or 0.5))
  end
  f:refresh()
  return f
end

-- UI.toggleBar(parent, get, set, opts?) → OFF | ON — the two-segment case.
function UI.toggleBar(parent, get, set, opts)
  return UI.segments(parent, { { value = false, label = "Off" }, { value = true, label = "On" } },
    function() return get() and true or false end, set, opts)
end

-- UI.check(parent, label, get, set) → the checkbox: a dim 17px box with a
-- violet dot, Play Bold 12 label. Returns the Button with :refresh().
function UI.check(parent, label, get, set)
  local b = CreateFrame("Button", nil, parent)
  b:SetHeight(17)
  local box = roundTex(b, "BACKGROUND"); box:SetSize(17, 17); box:SetPoint("LEFT", 0, 0); UI.tint(box, COLOR.dim)
  local dot = b:CreateTexture(nil, "ARTWORK"); dot:SetTexture(UI.DOT); dot:SetSize(13, 13)
  dot:SetPoint("CENTER", box, "CENTER", 0, 0); UI.tint(dot, COLOR.violet)
  b.text = UI.newText(b, FONT.uiB, 12, COLOR.black, "LEFT")
  b.text:SetPoint("LEFT", box, "RIGHT", 6, 0); b.text:SetText(label or "")
  b:SetWidth(23 + b.text:GetStringWidth())
  b.box, b.dot = box, dot
  function b:refresh() self.dot:SetShown(get() and true or false) end
  b:SetScript("OnClick", function(self) set(not get()); self:refresh() end)
  b:SetScript("OnEnable", function(self) self:SetAlpha(1) end)
  b:SetScript("OnDisable", function(self) self:SetAlpha(0.5) end)
  b:refresh()
  return b
end

-- UI.field(parent, w, opts?) → the white text input (Play 11, black), 17 tall.
-- It IS a flatEditBox underneath, so it joins the Tab ring and steps numbers
-- with the arrows; the consumer rules in CONTRACTS §4 apply unchanged.
--   opts = { h = 17, justify = "LEFT" }
function UI.field(parent, w, opts)
  opts = opts or {}
  local e = UI.flatEditBox(parent, w, opts.h or 17)
  e.bg:SetTexture(UI.ROUND)
  e.bg:SetTextureSliceMargins(SLICE, SLICE, SLICE, SLICE)
  e.bg:SetTextureSliceMode(STRETCHED)
  UI.tint(e.bg, COLOR.paper)
  UI.setFont(e, FONT.ui, 11); e:SetTextColor(0, 0, 0)
  e:SetTextInsets(6, 6, 0, 0)
  e:SetJustifyH(opts.justify or "LEFT")
  -- Selected text sits on the light purple (the owner, 2026-09-21: the stock
  -- dark-grey highlight is hard to read on white).
  e:SetHighlightColor(COLOR.lilac.r, COLOR.lilac.g, COLOR.lilac.b, 0.6)
  e.onFocus = function() end   -- the mocks give a focused field no second look; the caret is the signal
  return e
end

-- ------------------------------------------------------------
-- UI.pick — the kit's dropdown. Two faces, one list:
--   kind = "state"  a violet button carrying the choice, UPPERCASE; with no
--                   `w` it is as wide as its WIDEST option ("width based on
--                   widest item inside"), so it never changes size when picked
--   kind = "field"  a white field with a violet triangle — the profile picker
-- The open list (the owner's REVISED look, Figma "Dropdown" 682:14067,
-- 2026-09-21 — the indigo plate with amber rows was disliked): the window's
-- own plate grey with a dim 1px rim on the left, right and bottom (none on
-- top — it hangs off the button), 14px rows of Play 11 black UPPERCASE, the
-- current row a 20% violet band, 4px above the first row and 6 below the
-- last; as wide as its widest item + 11 each side, centred under the button;
-- scrolls past 20. Same closing rules as UI.dropdown: any outside click, the
-- owner hiding, another list opening.
--   UI.pick(parent, w, getLabel, getOptions, getCurrent, onPick, opts?)
-- Returns the button with :refresh().
-- ------------------------------------------------------------
local PICK_ROWS, PICK_ROW_H, PICK_PAD_T, PICK_PAD_B, PICK_INSET = 20, 14, 4, 6, 11
local pickFly

local function pickFlyout()
  if pickFly then return pickFly end
  local catcher = CreateFrame("Button", nil, UIParent)
  catcher:SetFrameStrata("FULLSCREEN"); catcher:SetAllPoints(UIParent); catcher:Hide()
  catcher:SetFrameLevel(20)
  local fly = CreateFrame("Frame", nil, catcher)
  fly:SetFrameStrata("FULLSCREEN_DIALOG")
  local plate = fly:CreateTexture(nil, "BACKGROUND"); plate:SetAllPoints()
  plate:SetColorTexture(COLOR.plate.r, COLOR.plate.g, COLOR.plate.b, 1)
  local rim = UI.addEdges(fly, COLOR.dim, 1); rim.top:Hide()
  local scroll = CreateFrame("ScrollFrame", nil, fly)
  scroll:SetPoint("TOPLEFT", 0, -PICK_PAD_T); scroll:SetPoint("BOTTOMRIGHT", 0, PICK_PAD_B)
  scroll:EnableMouseWheel(true)
  local child = CreateFrame("Frame", nil, scroll); child:SetSize(10, 10)
  scroll:SetScrollChild(child)
  scroll:SetScript("OnMouseWheel", function(self, delta)
    local range = math.max(0, child:GetHeight() - self:GetHeight())
    self:SetVerticalScroll(math.max(0, math.min(range, self:GetVerticalScroll() - delta * PICK_ROW_H)))
  end)
  catcher:SetScript("OnClick", function() catcher:Hide() end)
  fly.catcher, fly.scroll, fly.child, fly.rows = catcher, scroll, child, {}
  pickFly = fly
  return fly
end

-- UI.openList(anchor, options, current, onPick) — MINOR 13: the kit list on its
-- own, openable from any button (UI.pick is one caller; the Suite window's tool
-- switcher and UI.pillPick are the others). options = { {value, label, disabled?}, … };
-- the row whose value == current wears the band; picking closes it first. A
-- `disabled` row greys and ignores its click — for a choice that exists but
-- cannot work for this selection (a sound timing the spell never emits).
function UI.openList(anchor, options, current, onPick)
  local fly = pickFlyout()
  local y, widest = 0, 0
  for i, opt in ipairs(options) do
    local row = fly.rows[i]
    if not row then
      row = CreateFrame("Button", nil, fly.child); row:SetHeight(PICK_ROW_H)
      -- the current row's band: violet at 20%, 13 of the row's 14px
      row.cur = row:CreateTexture(nil, "BACKGROUND"); row.cur:SetPoint("TOPLEFT", 0, 0); row.cur:SetPoint("BOTTOMRIGHT", 0, 1)
      row.cur:SetColorTexture(COLOR.violet.r, COLOR.violet.g, COLOR.violet.b, 0.2); row.cur:Hide()
      row.hl = row:CreateTexture(nil, "BORDER"); row.hl:SetPoint("TOPLEFT", 0, 0); row.hl:SetPoint("BOTTOMRIGHT", 0, 1)
      row.hl:SetColorTexture(0, 0, 0, 0.08); row.hl:Hide()
      row:SetScript("OnEnter", function(self) self.hl:Show() end)
      row:SetScript("OnLeave", function(self) self.hl:Hide() end)
      row.text = UI.newText(row, FONT.ui, 11, COLOR.black, "LEFT")
      row.text:SetPoint("LEFT", PICK_INSET, 0); row.text:SetPoint("RIGHT", -PICK_INSET, 0); row.text:SetWordWrap(false)
      fly.rows[i] = row
    end
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, y); row:SetPoint("TOPRIGHT", 0, y)
    row.text:SetText(tostring(opt.label or ""):upper())
    row.text:SetAlpha(opt.disabled and 0.4 or 1)
    widest = math.max(widest, row.text:GetStringWidth())
    row.cur:SetShown(opt.value == current)
    row:SetScript("OnClick", function()
      if opt.disabled then return end
      fly.catcher:Hide(); onPick(opt.value)
    end)
    row:Show()
    y = y - PICK_ROW_H
  end
  for i = #options + 1, #fly.rows do fly.rows[i]:Hide() end
  local shown = math.min(#options, PICK_ROWS)
  local cw = math.ceil(widest) + 2 * PICK_INSET
  fly.child:SetSize(cw, math.max(10, #options * PICK_ROW_H))
  fly:SetSize(cw, shown * PICK_ROW_H + PICK_PAD_T + PICK_PAD_B)
  fly.scroll:SetVerticalScroll(0)
  fly:ClearAllPoints(); fly:SetPoint("TOP", anchor, "BOTTOM", 0, 0)
  -- The owner hiding (a tab switch, the window closing) takes the list with it.
  if not anchor._flyHooked then
    anchor._flyHooked = true
    anchor:HookScript("OnHide", function() if pickFly then pickFly.catcher:Hide() end end)
  end
  fly.catcher:Show()
end

function UI.pick(parent, w, getLabel, getOptions, getCurrent, onPick, opts)
  opts = opts or {}
  local field = opts.kind == "field"
  local b = UI.button(parent, "", { kind = field and "paper" or "state", w = w, caps = not field })
  b.text:SetWordWrap(false)
  if field then
    b.text:ClearAllPoints(); b.text:SetPoint("LEFT", 6, 0); b.text:SetPoint("RIGHT", -20, 0); b.text:SetJustifyH("LEFT")
    local tri = b:CreateTexture(nil, "ARTWORK"); tri:SetTexture(UI.TRI); tri:SetSize(9, 9)
    tri:SetPoint("RIGHT", -6, 0); UI.tint(tri, COLOR.violet)
    b.tri = tri
  end
  -- Width by the widest option, measured once per refresh with a hidden string.
  local measure
  function b:refresh()
    if not w and not field then
      measure = measure or UI.newText(self, FONT.ui, 11, nil, "LEFT")
      if measure then measure:Hide() end
      local widest = 0
      for _, opt in ipairs(getOptions() or {}) do
        measure:SetText(tostring(opt.label or ""):upper())
        widest = math.max(widest, measure:GetStringWidth())
      end
      self._fixedW = widest + 2 * self._padX
    end
    self:SetLabel(getLabel() or "?")
  end

  b:SetScript("OnClick", function()
    UI.openList(b, getOptions() or {}, getCurrent(), function(v) onPick(v); b:refresh() end)
  end)

  b:refresh()
  return b
end

-- UI.sectionHeader(parent, text, opts?) → a violet triangle + Play Bold 14 violet
-- UPPERCASE title; the whole line is the click target. :SetOpen(on) turns the
-- triangle (down = open, right = closed). opts = { open, onToggle(open) }
function UI.sectionHeader(parent, text, opts)
  opts = opts or {}
  local b = CreateFrame("Button", nil, parent)
  b:SetHeight(16)
  local tri = b:CreateTexture(nil, "ARTWORK"); tri:SetTexture(UI.TRI); tri:SetSize(10, 10)
  tri:SetPoint("LEFT", 0, 0); UI.tint(tri, COLOR.violet)
  b.text = UI.newText(b, FONT.uiB, 14, COLOR.violet, "LEFT")
  b.text:SetPoint("LEFT", tri, "RIGHT", 10, 0); b.text:SetText(tostring(text or ""):upper())
  b:SetWidth(20 + b.text:GetStringWidth())
  b.tri = tri
  function b:SetOpen(on) self._open = on and true or false; self.tri:SetRotation(self._open and 0 or math.pi / 2) end
  b:SetScript("OnClick", function(self) if opts.onToggle then opts.onToggle(not self._open) end end)
  b:SetOpen(opts.open)
  return b
end

-- ------------------------------------------------------------
-- UI.dial — the SCRUB dial, the kit's replacement for every slider. The
-- owner's definition (2026-09-21, after two wrong builds — a slider with
-- ticks, then a jog wheel):
--   · the tick strip is FIXED; the thick centre tick exists only for a range
--     with zero in the middle (offsets, angles) and never moves;
--   · the value's place in the range is shown by turning the NEAREST TICK
--     amber — the whole tick, post or centre mark included, never a separate
--     needle "riding on top" (the owner, 2026-09-21) — live as you drag;
--   · the drag is NOT one-to-one with the cursor ("that would just make it a
--     slider"): the whole range takes a long motion — `dragPx` pixels end to
--     end, 900 by default, Shift ×10 — from wherever you press, and you may
--     keep going off the strip; the wheel steps it; click the box to type.
-- The white box is the readout, with the caller's unit. ★ It sizes itself to
-- the WIDEST value it can be asked to show: the mock's 42px fits "46px", and
-- an edit box shows the END of text that overflows — so "-700px" in 42px
-- read "0px", which cost an evening (2026-09-21).
--   opts = { label, min, max, step = 1, get, set, unit = "", centre = false,
--            w = 194, dragPx = 900, fmt(v)?, short = false, bare = false }
-- `bare` (MINOR 12) drops the label — a TABLE row's dial, under a column
-- header (the Glows mock): the strip sits at the frame's top, 17 tall.
-- `short` (MINOR 12) is the mocks' compact form — a 78px strip of 24 ticks
-- and the same box, 133 wide (the Health panel's Gradient Angle and Track
-- Opacity). Same behaviour in every respect; never centred.
-- `dark` (MINOR 13) is the SECOND redesign's dial (GloomSuite UI 2, e.g. Opacity
-- in node 724:1226): Saira 12 label; 21 ticks in the accent, 1px at a 5px pitch,
-- 12 tall; the value is a small light-grey ▲ UNDER the ticks (the mock's Polygon
-- 5), not an amber tick; a 54 × 21 box of the accent at 30% with Saira 11 white,
-- 10 right of the ticks. 164 wide, 40 tall. Same behaviour in every respect.
-- Returns the Frame with :refresh(), :setEnabled(on), .label, .box, .strip.
-- ------------------------------------------------------------
UI.DIAL_D = lib.MEDIA .. "ui\\dial-ticks.png"   -- MINOR 13: 21 ticks, x = 0,5..100, 12 tall, on 128x16

function UI.dial(parent, opts)
  local minV, maxV, step = opts.min or 0, opts.max or 100, opts.step or 1
  local unit = opts.unit or ""
  local dragPx = opts.dragPx or 900
  local decimals = 0
  do local s = step; while s % 1 ~= 0 and decimals < 3 do s = s * 10; decimals = decimals + 1 end end
  local function fmt(v)
    if opts.fmt then return opts.fmt(v) end
    return decimals == 0 and tostring(math.floor(v + 0.5)) or ("%." .. decimals .. "f"):format(v)
  end
  local function snap(v)
    v = math.max(minV, math.min(maxV, v))
    if step > 0 then v = minV + math.floor((v - minV) / step + 0.5) * step end
    return math.max(minV, math.min(maxV, v))
  end

  local short, bare = opts.short and true or false, opts.bare and true or false
  -- `glass` (MINOR 14) is the third design's dial — UI.gDial's; it is the dark
  -- dial with shorter ticks (10), a 16-tall box and the glass palette.
  local glass = opts.glass and true or false
  local dark = (opts.dark or glass) and true or false
  local ac = dark and (opts.accent or UI.accentOf(parent)) or nil
  if glass then ac = COLOR.violet end
  local TOP = bare and 0 or (glass and 23 or (dark and 19 or 18))
  local f = CreateFrame("Frame", nil, parent)
  f:SetSize(opts.w or (dark and 164 or (short and 133 or 194)), bare and (glass and 18 or (dark and 21 or 17)) or (glass and 41 or (dark and 40 or 35)))
  if dark then
    f.label = UI.newText(f, FONT.sa, 12, COLOR.paper, "LEFT"); f.label:SetText(bare and "" or (opts.label or ""))
  else
    f.label = UI.label(f, bare and "" or opts.label)
  end
  f.label:SetPoint("TOPLEFT", 0, 0)

  local WIN_W = dark and 101 or (short and 78 or 141)   -- the strip art: posts at 0-1 and W-2..W-1, ticks at 4+3i (45, or 24 short), the centre one at 69-71
  local TICKS = dark and 21 or (short and 26 or 47)     -- positions the mark can take: post, the ticks, post
  local strip = CreateFrame("Frame", nil, f)
  strip:SetPoint("TOPLEFT", 0, -TOP); strip:SetSize(WIN_W, glass and 18 or (dark and 21 or 17))
  strip:EnableMouse(true)
  local ticks = strip:CreateTexture(nil, "ARTWORK")
  local mark = strip:CreateTexture(nil, "OVERLAY")
  if glass then
    -- ★ 21 separate 1-unit rectangles, not a texture: at the Suite window's
    -- whole-pixel scales each lands exactly on the screen's pixels (2026-09-26).
    ticks:Hide()
    for i = 0, 20 do
      local t = strip:CreateTexture(nil, "ARTWORK")
      t:SetPoint("TOPLEFT", i * 5, 0); t:SetSize(1, 10)
      t:SetColorTexture(COLOR.lilac.r, COLOR.lilac.g, COLOR.lilac.b, 1)
    end
    mark:SetTexture(UI.G_TRI); mark:SetRotation(math.pi)
    mark:SetSize(6, 5); mark:SetVertexColor(0xd9 / 255, 0xd9 / 255, 0xd9 / 255, 1)
  elseif dark then
    ticks:SetTexture(UI.DIAL_D); ticks:SetTexCoord(0, 101 / 128, 0, 12 / 16)
    ticks:SetSize(101, 12); ticks:SetPoint("TOPLEFT", 0, -0.5); UI.tint(ticks, ac)
    mark:SetTexture(UI.TRI); mark:SetRotation(math.pi)   -- tri.png points down; turned, it points up at the tick
    mark:SetSize(6, 6); mark:SetVertexColor(0xd9 / 255, 0xd9 / 255, 0xd9 / 255, 1)
  else
    ticks:SetTexture(short and UI.DIAL_S or (opts.centre and UI.DIAL_C or UI.DIAL))
    ticks:SetSize(WIN_W, 16); ticks:SetPoint("TOPLEFT", 0, -2); UI.tint(ticks, COLOR.ink)
    -- the amber tick, shaped like the one it replaces
    mark:SetColorTexture(COLOR.amber.r, COLOR.amber.g, COLOR.amber.b, 1)
    mark:SetSize(1, 13)
  end
  f.strip, f.ticks, f.mark = strip, ticks, mark
  -- Which tick is amber for a value: index 0 is the left post, 46 the right,
  -- 1..45 the thin ticks; the centre one (23) is 3px wide on a centred dial.
  -- A dark dial's pointer sits under tick `idx`, 2px below the strip's ticks.
  local function markAt(idx)
    if dark then
      mark:ClearAllPoints(); mark:SetPoint("TOP", strip, "TOPLEFT", idx * 5 + 0.5, glass and -12 or -14)
      return
    end
    local x, w
    if idx <= 0 then x, w = 0, 2
    elseif idx >= TICKS - 1 then x, w = WIN_W - 2, 2
    elseif opts.centre and not short and idx == 23 then x, w = 69, 3
    else x, w = 4 + 3 * (idx - 1), 1 end
    mark:SetSize(w, 13)
    mark:ClearAllPoints(); mark:SetPoint("TOPLEFT", x, -2)
  end

  -- The box: at least the mock's 42, wider if the range's extremes need it.
  -- A dark dial's box is the accent at 30% under Saira 11 white, 54 wide at least.
  local box
  if dark then
    box = CreateFrame("EditBox", nil, f); box:SetAutoFocus(false); box:SetHeight(glass and 16 or 21)
    UI.setFont(box, FONT.sa, 11); box:SetTextColor(1, 1, 1); box:SetJustifyH("CENTER")
    local bbg = box:CreateTexture(nil, "BACKGROUND"); bbg:SetAllPoints(); bbg:SetColorTexture(ac.r, ac.g, ac.b, 0.3)
  else
    box = UI.field(f, 42, { justify = "CENTER" })
  end
  box:SetTextInsets(4, 4, glass and 2 * UI.G_NUDGE or 0, 0)
  do
    local m = UI.newText(f, dark and FONT.sa or FONT.ui, 11, nil, "LEFT"); m:Hide()
    local widest = 0
    for _, v in ipairs({ minV, maxV, -maxV }) do
      m:SetText(fmt(v) .. unit); widest = math.max(widest, m:GetStringWidth())
    end
    local minBox = dark and 54 or 42
    box:SetWidth(math.max(minBox, math.ceil(widest) + 10))
    f:SetWidth(math.max(opts.w or (dark and 164 or (short and 133 or 194)), WIN_W + (dark and 9 or 10) + box:GetWidth()))   -- the frame grows, never the gap shrinks
  end
  if dark then box:SetPoint("TOPLEFT", f, "TOPLEFT", 110, -TOP)
  else box:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -TOP) end
  f.box = box
  if opts.nobox then box:Hide(); f:SetWidth(WIN_W) end

  local cur, enabled = snap(opts.get() or minV), true
  local editing, dragging = false, false   -- our own flags; HasFocus() proved unreliable mid-drag
  local function paint()
    local frac = (maxV > minV) and ((cur - minV) / (maxV - minV)) or 0
    markAt(math.floor(frac * (TICKS - 1) + 0.5))
    if not editing then box:SetText(fmt(cur) .. unit); box:SetCursorPosition(0) end
  end
  local function apply(v)
    v = snap(v)
    if v ~= cur then cur = v; opts.set(v) end
    paint()
  end

  -- A box that was clicked into keeps keyboard focus until something takes
  -- it (WoW edit boxes ignore outside clicks). The strip takes it WITHOUT
  -- committing the box's text, so a stale number never overwrites a drag.
  local function dropBoxFocus()
    if editing then editing = false; box._abandon = true; box:ClearFocus() end
  end

  -- The strip: press anywhere and pull; the mark follows live.
  strip:SetScript("OnMouseDown", function(self)
    if not enabled then return end
    dropBoxFocus()
    dragging = true
    self._drag = { x = GetCursorPosition() / self:GetEffectiveScale(), v = cur }
    paint()
  end)
  local function endDrag(self)
    if not dragging then return end
    dragging = false; self._drag = nil
    paint()
  end
  strip:SetScript("OnMouseUp", endDrag)
  strip:SetScript("OnUpdate", function(self)
    local d = self._drag
    if not d then return end
    if not IsMouseButtonDown("LeftButton") then endDrag(self); return end
    local x = GetCursorPosition() / self:GetEffectiveScale()
    local units = (x - d.x) * ((maxV - minV) / dragPx) * (IsShiftKeyDown() and 10 or 1)
    apply(d.v + units)
  end)
  -- ★ NO mouse wheel on a dial (the owner, 2026-09-27): scrolling the window
  -- past one changed its value by accident. The wheel only ever scrolls; with
  -- it off here, it falls through to the scroll area underneath. Stepping is
  -- the arrow keys in the number box (Shift ×10).
  strip:EnableMouseWheel(false); box:EnableMouseWheel(false)
  -- ↑ / ↓ in the number box: from the number TYPED, if there is one
  box:SetScript("OnArrowPressed", function(self, key)
    if not enabled or (key ~= "UP" and key ~= "DOWN") then return end
    local typed = tonumber((self:GetText() or ""):match("[-%d%.]+"))
    apply((typed or cur) + (key == "UP" and 1 or -1) * step * (IsShiftKeyDown() and 10 or 1))
    self:SetText(fmt(cur)); self:HighlightText()
  end)
  UI.attachTip(strip, opts.label or "", "Press anywhere on the ticks and pull — keep going past them if you like; the full range is a long drag, Shift is ×10. Click the number to type one; the arrow keys step it there (Shift ×10).")

  -- The box: click to type. Enter or leaving commits; Escape puts it back.
  box:SetScript("OnEditFocusGained", function(self) editing = true; self:SetText(fmt(cur)); self:HighlightText() end)
  box:SetScript("OnEditFocusLost", function(self)
    editing = false
    if self._abandon then self._abandon = nil; paint(); return end
    local v = tonumber((self:GetText() or ""):match("[-%d%.]+"))
    if v then apply(v) else paint() end
  end)
  box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  UI.tabbable(box)
  box:SetScript("OnEscapePressed", function(self) self:SetText(fmt(cur)); self:ClearFocus() end)

  function f:refresh() cur = snap(opts.get() or minV); paint() end
  function f:setEnabled(on)
    enabled = on and true or false
    box:SetEnabled(enabled)
    self:SetAlpha(enabled and 1 or 0.5)
  end
  paint()
  return f
end

-- ------------------------------------------------------------
-- UI.chip — the kit's colour control (MINOR 12): a 20×17 rounded swatch and,
-- at x=26, one word of Play 11 — "(Remove)" on an optional colour that is
-- set, "None" on one that is not, the SOURCE's word when the chip holds a
-- source ("Class"), nothing on a required fixed colour. The mock's
-- PRIMITIVES chip. Click the swatch (or "None") for the picker; click
-- "(Remove)" to clear. ★ A chip holds a fixed colour OR a source (the
-- backlog's decision, 2026-09-21 — the "use class colour" toggles are gone):
-- get() returns {r,g,b[,a]}, a source's `value` string, or nil; set(v) is
-- handed the same three shapes back. The picker applies LIVE through set and
-- a cancel puts back exactly what the chip held, source included.
--   opts = { get, set, hasAlpha, optional = false, label ("Unit Frames › Health color" —
--            the palette's provenance), title, sources = { { value, label, word, color() } },
--            fixed(), text }
-- `text` (the Cast mock's interrupt rows) is a DESCRIPTION drawn after the
-- swatch in ink, with the "(Remove)" link after it: the chip reads
-- "▪ Can't be interrupted" / "▪ Interrupt available before the cast ends (Remove)".
-- `fixed()` returns the FIXED colour the consumer keeps under a source, so a
-- cancelled picker session that began on a source puts it back too (the
-- picker's restore goes through set(colour) before onCancel runs).
-- A source's `color()` returns r, g, b for the swatch (nil → violet); `word`
-- is the chip's text for it (default: the label's last word). Returns the
-- Frame with :refresh(), :setEnabled(on), .swatch, .text. ★ The swatch is
-- SQUARE — the one kit surface without the 4px corners (the owner,
-- 2026-09-21) — and "(Remove)" is violet: links and actions are purple.
-- ------------------------------------------------------------
function UI.chip(parent, opts)
  opts = opts or {}
  local f = CreateFrame("Frame", nil, parent)
  f:SetSize(74, 17)
  local sw = CreateFrame("Button", nil, f)
  sw:SetSize(20, 17); sw:SetPoint("LEFT", 0, 0)
  sw.fill = sw:CreateTexture(nil, "ARTWORK"); sw.fill:SetAllPoints(); sw.fill:SetColorTexture(1, 1, 1, 1)
  sw.empty = UI.addEdges(sw, COLOR.dim, 1)   -- the "None" look: an outlined, unfilled box
  local enabled = true
  local desc
  if opts.text then
    desc = UI.newText(f, FONT.ui, 11, COLOR.ink, "LEFT")
    desc:SetPoint("LEFT", sw, "RIGHT", 6, 0); desc:SetText(opts.text)
  end
  local txt = CreateFrame("Button", nil, f)
  if desc then txt:SetPoint("LEFT", desc, "RIGHT", 4, 0) else txt:SetPoint("LEFT", sw, "RIGHT", 6, 0) end
  txt:SetSize(48, 17)
  txt.text = UI.newText(txt, FONT.ui, 11, COLOR.ink, "LEFT")
  txt.text:SetPoint("LEFT", 0, 0); txt:SetFontString(txt.text)
  f.swatch, f.text, f.desc = sw, txt, desc

  local function sourceOf(v)
    if type(v) ~= "string" then return nil end
    for _, src in ipairs(opts.sources or {}) do if src.value == v then return src end end
  end
  local function paint()
    local v = opts.get()
    local src = sourceOf(v)
    if src then
      local r, g, b
      if src.color then r, g, b = src.color() end   -- (not `x and f()` — that keeps ONE return)
      if r then sw.fill:SetVertexColor(r, g, b, 1) else UI.tint(sw.fill, COLOR.violet) end
      sw.fill:Show(); sw.empty:SetColor(COLOR.dim, 0)
      txt.text:SetText(src.word or tostring(src.label or src.value):match("(%S+)$") or "")
      txt.mode = "source"
    elseif type(v) == "table" then
      UI.NoteColor(v)
      sw.fill:SetVertexColor(v[1] or 1, v[2] or 1, v[3] or 1, 1)
      sw.fill:Show(); sw.empty:SetColor(COLOR.dim, 0)
      txt.text:SetText(opts.optional and "(Remove)" or "")
      txt.mode = opts.optional and "remove" or nil
    else
      sw.fill:Hide(); sw.empty:SetColor(COLOR.dim, 1)
      txt.text:SetText(desc and "" or "None")   -- with a description the empty box is the whole cue
      txt.mode = "none"
    end
    txt:SetWidth(math.max(1, txt.text:GetStringWidth()))
    f:SetWidth(26 + (desc and (desc:GetStringWidth() + 4) or 0) + txt:GetWidth())
    local lc = txt.mode == "remove" and COLOR.violet or COLOR.ink
    txt.text:SetTextColor(lc.r, lc.g, lc.b)
  end

  local function open()
    local held = opts.get()
    local heldFixed = opts.fixed and opts.fixed()
    local src = sourceOf(held)
    local start = type(held) == "table" and held or nil
    if src and src.color then local r, g, b = src.color(); if r then start = { r, g, b } end end   -- (a plain call: all three returns)
    local list, cur = {}, src and src.value or nil
    for _, s2 in ipairs(opts.sources or {}) do list[#list + 1] = { value = s2.value, label = s2.label, color = s2.color } end
    UI.colorPicker({
      color = start or { 1, 1, 1 },
      hasAlpha = opts.hasAlpha,
      owner = sw,
      title = opts.title,
      onChange = function(c) opts.set(c); paint() end,
      onCancel = function()   -- the source, or nil, comes back exactly — and the fixed colour under it
        if heldFixed then opts.set(heldFixed) end
        opts.set(held); paint()
      end,
      sources = list[1] and list or nil,
      source = cur,
      onSource = function(v) opts.set(v); paint() end,
    })
  end
  sw:SetScript("OnClick", function() if enabled then open() end end)
  txt:SetScript("OnClick", function(self)
    if not enabled then return end
    if self.mode == "remove" then opts.set(nil); paint()
    elseif self.mode ~= nil then open() end
  end)
  txt:SetScript("OnEnter", function(self) if self.mode and enabled then self.text:SetTextColor(COLOR.lilac.r, COLOR.lilac.g, COLOR.lilac.b) end end)
  txt:SetScript("OnLeave", function(self) paint() end)
  UI.RegisterColorSource(sw, opts.get, opts.label)
  function f:refresh() paint() end
  function f:setEnabled(on) enabled = on and true or false; self:SetAlpha(enabled and 1 or 0.5) end
  paint()
  return f
end

-- UI.cell(parent, labelText, make) → the mocks' 35px LABELLED CELL (MINOR 12):
-- a Play Bold 12 label with the control 18 under it. `make(cell)` returns the
-- control (a segments bar, a chip, a pick, a field…). The cell has :refresh()
-- (→ the control's), :show(on) and :setEnabled(on) — disabled BY ANOTHER
-- SETTING = 50%, never hidden (the owner, 2026-09-21); hide only what another
-- mode's face lacks. A kit button dims itself, so only its label dims here.
function UI.cell(parent, labelText, make)
  local cell = CreateFrame("Frame", nil, parent)
  cell:SetSize(10, 35)
  cell.label = UI.label(cell, labelText); cell.label:SetPoint("TOPLEFT", 0, 0)
  cell.control = make(cell)
  cell.control:SetPoint("TOPLEFT", 0, -18)
  function cell:refresh() if self.control.refresh then self.control:refresh() end end
  function cell:show(on) self:SetShown(on ~= false) end
  function cell:setEnabled(on)
    on = on and true or false
    if self.control.setEnabled then self.control:setEnabled(on); self.label:SetAlpha(on and 1 or 0.5)
    elseif self.control.paint then self.control:SetEnabled(on); self.label:SetAlpha(on and 1 or 0.5)
    else self:SetAlpha(on and 1 or 0.5); if self.control.SetEnabled then self.control:SetEnabled(on) end end
  end
  return cell
end

-- UI.wordmark(parent, suffix, size, opts?) → "gloom" + SUFFIX in Michroma, as
-- ONE FontString with inline colours. The window wears black + violet (SUITE),
-- a banner all white, the footer black + lilac (the tool).
--   opts = { prefix = "gloom", prefixColor = COLOR.black, suffixColor = COLOR.violet, justify }
-- Returns the FontString with :SetMark(suffix, suffixColor?).
function UI.wordmark(parent, suffix, size, opts)
  opts = opts or {}
  local fs = UI.newText(parent, FONT.mark, size or 14, nil, opts.justify or "LEFT")
  fs._prefix, fs._pc, fs._sc = opts.prefix or "gloom", opts.prefixColor or COLOR.black, opts.suffixColor or COLOR.violet
  function fs:SetMark(suf, sc)
    if sc then self._sc = sc end
    self:SetText(("|cff%s%s|r|cff%s%s|r"):format(hexOf(self._pc), self._prefix, hexOf(self._sc), suf or ""))
  end
  fs:SetMark(suffix)
  return fs
end

-- UI.profileRow(parent, api, mark) → the kit's FOOTER profile control, the row
-- form of UI.profileBlock: "gloomUNIT profile:" · a white 250px picker · NEW
-- COPY RENAME DELETE (DELETE amber — it destroys). Same `api` as the block,
-- same dialogs, same delete gate; an error shows in amber after the buttons.
-- `mark` is the tool's wordmark suffix ("UNIT"). Returns { frame, refresh, note }.
function UI.profileRow(parent, api, mark)
  local noun = api.noun or "profile"
  local hasCopy = type(api.copy) == "function"
  local row = {}
  local f = CreateFrame("Frame", nil, parent)
  f:SetHeight(17)
  row.frame = f

  -- "gloomUNIT" (Michroma 12, tool in lilac) then " profile:" (Play 12) — right-aligned to x=128.
  local who = UI.newText(f, FONT.ui, 12, COLOR.black, "RIGHT")
  who:SetPoint("RIGHT", f, "LEFT", 128, 0); who:SetText(" " .. noun .. ":")
  local wm = UI.wordmark(f, mark or "", 12, { suffixColor = COLOR.lilac, justify = "RIGHT" })
  wm:SetPoint("RIGHT", who, "LEFT", 0, 0)
  row.wordmark = wm

  local note = UI.newText(f, FONT.ui, 11, COLOR.amber, "LEFT")
  function row:note(text) note:SetText(text or "") end

  local dd
  local function after(ok, err)
    if ok then row:note(""); dd:refresh(); if api.onChange then api.onChange() end
    else row:note(err or "") end
  end
  dd = UI.pick(f, 250,
    function() return api.active() end,
    function()
      local out = {}
      for _, name in ipairs(api.names() or {}) do out[#out + 1] = { value = name, label = name } end
      return out
    end,
    function() return api.active() end,
    function(v) row:note(""); api.switch(v); if api.onChange then api.onChange() end end,
    { kind = "field" })
  dd:SetPoint("LEFT", 142, 0)
  row.dropdown = dd

  local act = profileActions(api, after)
  local prev = dd
  local function btn(label, kind, handler, gap)
    local b = UI.button(f, label, { kind = kind, onClick = handler })
    b:SetPoint("LEFT", prev, "RIGHT", gap or 6, 0)
    prev = b
    return b
  end
  local bNew = btn("New", "action", act.new, 11)
  local bCopy = hasCopy and btn("Copy", "action", act.copy) or nil
  local bRen = btn("Rename", "action", act.rename)
  local bDel = btn("Delete", "warn", act.delete)
  note:SetPoint("LEFT", bDel, "RIGHT", 12, 0); note:SetPoint("RIGHT", f, "RIGHT", 0, 0)
  profileTips(api, dd, bNew, bCopy, bRen, bDel)

  function row:refresh() dd:refresh() end
  return row
end

-- ------------------------------------------------------------
-- ★ THE DARK KIT (MINOR 13, 2026-09-23) — the SECOND redesign (Figma page
-- "GloomSuite UI 2"). The window went near-black, the type went to Saira, and
-- every tool wears its own ACCENT: Auras green, Bars and Unit Frames their own,
-- everything else the suite blue. A colour does not mean the same thing in two
-- tools — the owner, 2026-09-23: "just accept the inconsistency."
-- The first redesign's kit above stays for the tabs that have not moved yet.
--
-- ACCENT BY ANCESTRY: a dark-kit widget takes `opts.accent`, or else the accent
-- of the nearest ancestor carrying `_gloomAccent` (the Suite window sets it on a
-- tool's container), or else the suite blue. So a tool never passes its colour
-- to every widget, and a widget moved between tools cannot keep a stale one.
-- ------------------------------------------------------------
COLOR.void  = color("0c0d11")   -- the window
COLOR.sky   = color("13a0f7")   -- the suite blue: the default accent, the foot of the sidebar's gradient
COLOR.jade  = color("4fc667")   -- Auras' accent
COLOR.coral = color("e14b4b")   -- destructive: Delete, Delete Aura
COLOR.flame = color("ea9438")   -- Auras' highlight: the selected aura, a visible eye

-- ⚠ NEW FONTS LOAD AT CLIENT LAUNCH — the first time these ship, a /reload is not
-- enough (CLAUDE.md working agreement 4). Both are the static builds, OFL.
FONT.sa  = FONT_DIR .. "Saira-Regular.ttf"   -- ★ re-pointed one weight lighter below (2026-09-26)
FONT.saB = FONT_DIR .. "Saira-Bold.ttf"

function UI.accentOf(frame)
  local f = frame
  while f do
    if f._gloomAccent then return f._gloomAccent end
    f = f.GetParent and f:GetParent()
  end
  return COLOR.sky
end

-- UI.pill — the dark kit's button. A pill of 1000px radius with a border on the
-- LEFT and RIGHT only, which is why the stroke is a crescent at each end that
-- tapers to nothing at the top and bottom (the mocks' `border-l border-r`), and
-- a fill of the same colour at 10% under all of it.
-- Built from three pieces so nothing is ever stretched: a left cap, a plain
-- rectangle, the right cap (the left one's texcoords flipped). The caps are
-- generated per height by tools/gen-kit-art.py — 22 (the small row) and 25 (the
-- standard); any other height falls back to 25.
--   UI.pill(parent, label, opts?) → Button with .text, :SetLabel(s),
--     :SetSelected(on), :SetAccent(c), :paint()
--   opts = { h = 25|22, size (11 for 25, 9 for 22), padX = 11, w (fixed width),
--            accent, danger (coral), selected (fill 30% instead of 10%),
--            paper (the white field: no rim, dark text), font, onClick,
--            rim = "both"|"left"|"right"|"none" (which ends carry the stroke),
--            solid = {r,g,b} (an OPAQUE fill instead of the accent at 10% — for a
--              pill that sits on something it must hide, like the "Choose" at
--              the end of a white field) }
UI.PILL_DIR = lib.MEDIA .. "ui\\pill\\"
local PILL_CAP = { [22] = 11, [25] = 13 }   -- cap width per height: ceil(h / 2)

function UI.pill(parent, label, opts)
  opts = opts or {}
  local h = PILL_CAP[opts.h or 25] and (opts.h or 25) or 25
  local cw = PILL_CAP[h]
  local b = CreateFrame("Button", nil, parent)
  b:SetHeight(h)
  local u, v = cw / 16, h / 32
  local function capTex(kind, layer, right)
    local t = b:CreateTexture(nil, layer)
    t:SetTexture(UI.PILL_DIR .. "cap" .. h .. "-" .. kind .. ".png")
    t:SetSize(cw, h)
    if right then t:SetTexCoord(u, 0, 0, v); t:SetPoint("RIGHT", 0, 0)
    else t:SetTexCoord(0, u, 0, v); t:SetPoint("LEFT", 0, 0) end
    return t
  end
  b.fillL, b.fillR = capTex("fill", "BACKGROUND"), capTex("fill", "BACKGROUND", true)
  b.fillM = b:CreateTexture(nil, "BACKGROUND")
  b.fillM:SetPoint("TOPLEFT", cw, 0); b.fillM:SetPoint("BOTTOMRIGHT", -cw, 0)
  b.fillM:SetColorTexture(1, 1, 1, 1)
  b.rimL, b.rimR = capTex("rim", "BORDER"), capTex("rim", "BORDER", true)
  b.text = UI.newText(b, opts.font or FONT.sa, opts.size or (h == 22 and 9 or 11), nil, "CENTER")
  b.text:SetPoint("CENTER", 0, 0); b.text:SetWordWrap(false)
  b:SetFontString(b.text)
  b._padX, b._fixedW = opts.padX or 11, opts.w
  b._accent, b._danger, b._paper = opts.accent, opts.danger, opts.paper
  b._sel, b._hot = opts.selected and true or false, false
  b._rim, b._solid = opts.rim or "both", opts.solid

  function b:paint()
    local c = self._danger and COLOR.coral or self._accent or UI.accentOf(self:GetParent())
    local fa, ra, tc
    local fc = c
    if self._paper then
      fc, fa, ra, tc = COLOR.paper, self._hot and 0.88 or 1, 0, COLOR.void
    elseif self._solid then
      fc, fa, ra, tc = self._solid, 1, 1, COLOR.paper
      if self._hot then fc = { r = math.min(1, fc.r + 0.06), g = math.min(1, fc.g + 0.06), b = math.min(1, fc.b + 0.06) } end
    else
      fa = (self._sel and 0.3 or 0.1) + (self._hot and 0.1 or 0)
      ra, tc = 1, COLOR.paper
    end
    for _, t in ipairs({ self.fillL, self.fillR, self.fillM }) do t:SetVertexColor(fc.r, fc.g, fc.b, fa) end
    local r = self._rim
    self.rimL:SetVertexColor(c.r, c.g, c.b, (r == "both" or r == "left") and ra or 0)
    self.rimR:SetVertexColor(c.r, c.g, c.b, (r == "both" or r == "right") and ra or 0)
    self.text:SetTextColor(tc.r, tc.g, tc.b)
    self:SetAlpha(self:IsEnabled() and 1 or 0.5)   -- unavailable = 50%, never hidden
  end
  function b:SetLabel(txt)
    self.text:SetText(tostring(txt or ""))
    self:SetWidth(self._fixedW or (math.ceil(self.text:GetStringWidth()) + 2 * self._padX))
  end
  function b:SetSelected(on) self._sel = on and true or false; self:paint() end
  function b:SetAccent(c) self._accent = c; self:paint() end
  b:SetScript("OnEnter", function(self) if self:IsEnabled() then self._hot = true; self:paint() end end)
  b:SetScript("OnLeave", function(self) self._hot = false; self:paint() end)
  b:SetScript("OnEnable", function(self) self:paint() end)
  b:SetScript("OnDisable", function(self) self._hot = false; self:paint() end)
  if opts.onClick then b:SetScript("OnClick", opts.onClick) end
  b:SetLabel(label or "")
  b:paint()
  return b
end

-- UI.pillPick — the dark kit's dropdown: a pill carrying the choice that opens
-- the kit list (UI.openList). `paper` = the white field with a dark triangle and
-- the label on the left (the profile picker); otherwise an accent pill with the
-- label centred, as the mocks draw every other picker.
--   UI.pillPick(parent, w, getLabel, getOptions, getCurrent, onPick, opts?)
--   opts = the UI.pill opts. Returns the pill with :refresh().
function UI.pillPick(parent, w, getLabel, getOptions, getCurrent, onPick, opts)
  opts = opts or {}
  opts.w = w
  local b = UI.pill(parent, "", opts)
  if opts.paper then
    b.text:ClearAllPoints(); b.text:SetPoint("LEFT", 6, 0); b.text:SetPoint("RIGHT", -20, 0); b.text:SetJustifyH("LEFT")
    local tri = b:CreateTexture(nil, "ARTWORK"); tri:SetTexture(UI.TRI); tri:SetSize(8, 8)
    tri:SetPoint("RIGHT", -8, 0); UI.tint(tri, COLOR.void)
    b.tri = tri
  end
  function b:refresh() self:SetLabel(getLabel() or "?") end
  b:SetScript("OnClick", function(self)
    UI.openList(self, getOptions() or {}, getCurrent(), function(val) onPick(val); self:refresh() end)
  end)
  b:refresh()
  return b
end

-- UI.profileStack(parent, api, mark, accent?) → the dark kit's profile control,
-- stacked for the Suite window's sidebar (GloomSuite UI 2, node 718:40), 210 wide:
--   "gloomAURAS profile:" (Saira 12, the tool's name in its accent)
--   the white 210px picker, 25 tall, 22 below the label
--   New · Copy · Rename · Delete — small pills (22 tall, Saira 9), Delete coral
-- Same `api` as UI.profileBlock / UI.profileRow, same dialogs, same delete gate.
-- An error shows in coral ABOVE the label (there is no room beside the buttons).
-- Returns { frame, refresh, note }.
function UI.profileStack(parent, api, mark, accent)
  local noun = api.noun or "profile"
  local hasCopy = type(api.copy) == "function"
  local ac = accent or UI.accentOf(parent)
  local st = {}
  local f = CreateFrame("Frame", nil, parent)
  f:SetSize(210, 79)
  st.frame = f

  local who = UI.newText(f, FONT.sa, 12, COLOR.paper, "LEFT")
  who:SetPoint("TOPLEFT", 0, 0)
  who:SetText(("gloom|cff%s%s|r %s:"):format(hexOf(ac), mark or "", noun))

  local note = UI.newText(f, FONT.sa, 11, COLOR.coral, "LEFT")
  note:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 6); note:SetWidth(210); note:SetWordWrap(true)
  function st:note(text) note:SetText(text or "") end

  local dd
  local function after(ok, err)
    if ok then st:note(""); dd:refresh(); if api.onChange then api.onChange() end
    else st:note(err or "") end
  end
  dd = UI.pillPick(f, 210,
    function() return api.active() end,
    function()
      local out = {}
      for _, name in ipairs(api.names() or {}) do out[#out + 1] = { value = name, label = name } end
      return out
    end,
    function() return api.active() end,
    function(val) st:note(""); api.switch(val); if api.onChange then api.onChange() end end,
    { paper = true })
  dd:SetPoint("TOPLEFT", 0, -22)
  st.dropdown = dd

  local act = profileActions(api, after)
  local prev
  local function btn(label, handler, danger)
    local b = UI.pill(f, label, { h = 22, accent = ac, danger = danger, onClick = handler })
    if prev then b:SetPoint("LEFT", prev, "RIGHT", 6, 0) else b:SetPoint("TOPLEFT", 0, -57) end
    prev = b
    return b
  end
  local bNew = btn("New", act.new)
  local bCopy = hasCopy and btn("Copy", act.copy) or nil
  local bRen = btn("Rename", act.rename)
  local bDel = btn("Delete", act.delete, true)
  profileTips(api, dd, bNew, bCopy, bRen, bDel)

  function st:refresh() dd:refresh() end
  return st
end

-- ------------------------------------------------------------
-- The dark kit's smaller pieces (MINOR 13), each read off the GloomSuite UI 2
-- mocks. All take their colour from UI.accentOf(parent) unless told otherwise,
-- and all return objects with :refresh() / :setEnabled(on) where they hold a
-- value, so a tool can drive them from one refresh loop. Disabled = 50%, never
-- hidden (the suite's rule).
-- ------------------------------------------------------------
UI.CHECK   = lib.MEDIA .. "ui\\check.png"         -- the tick, white, 16x16
UI.DISC    = lib.MEDIA .. "ui\\circle.png"        -- a colour swatch, white, 32x32
UI.DISC_NO = lib.MEDIA .. "ui\\circle-dash.png"   -- the swatch with no colour set

local function mix(a, b, t) return { r = a.r + (b.r - a.r) * t, g = a.g + (b.g - a.g) * t, b = a.b + (b.b - a.b) * t } end

-- UI.plate(parent, title?) → a section plate: the accent at 10%, square, with an
-- optional Saira Bold 14 white title 16 in and 10 down (the mocks' APPEARANCE,
-- POSITION, …). A plate inside a plate adds another 10% on its own. Size it.
function UI.plate(parent, title, accent)
  local ac = accent or UI.accentOf(parent)
  local f = CreateFrame("Frame", nil, parent)
  f.bg = f:CreateTexture(nil, "BACKGROUND"); f.bg:SetAllPoints()
  f.bg:SetColorTexture(ac.r, ac.g, ac.b, 0.1)
  if title then
    f.title = UI.newText(f, FONT.saB, 14, COLOR.paper, "LEFT")
    f.title:SetPoint("TOPLEFT", 16, -10); f.title:SetText(title)
  end
  return f
end

-- UI.rule(parent) → the mocks' divider: 1px of the accent at 30%. Anchor it.
function UI.rule(parent, accent)
  local ac = accent or UI.accentOf(parent)
  local t = parent:CreateTexture(nil, "ARTWORK"); t:SetHeight(1)
  t:SetColorTexture(ac.r, ac.g, ac.b, 0.3)
  return t
end

-- UI.text(parent, text, size?, bold?) → Saira white, the dark kit's label.
function UI.text(parent, text, size, bold)
  local fs = UI.newText(parent, bold and FONT.saB or FONT.sa, size or 12, COLOR.paper, "LEFT")
  fs:SetText(text or "")
  return fs
end

-- UI.box(parent, label?, get, set) → the checkbox: a 16px square, the accent at
-- 10% inside a 1px accent line, a white tick when on; the label in Saira 12 at
-- x=26. The whole row is the click target.
function UI.box(parent, label, get, set, accent)
  local ac = accent or UI.accentOf(parent)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(16, 16)
  local fill = b:CreateTexture(nil, "BACKGROUND"); fill:SetPoint("TOPLEFT"); fill:SetSize(16, 16)
  fill:SetColorTexture(ac.r, ac.g, ac.b, 0.1)
  local edge = CreateFrame("Frame", nil, b); edge:SetPoint("TOPLEFT"); edge:SetSize(16, 16)
  b.edges = UI.addEdges(edge, { r = ac.r, g = ac.g, b = ac.b, a = 1 }, 1)
  local tick = b:CreateTexture(nil, "ARTWORK"); tick:SetTexture(UI.CHECK); tick:SetPoint("TOPLEFT"); tick:SetSize(16, 16)
  b.tick = tick
  if label and label ~= "" then
    b.label = UI.text(b, label, 12); b.label:SetPoint("LEFT", b, "LEFT", 26, 0)
    b:SetWidth(26 + math.ceil(b.label:GetStringWidth()))
    -- the hit area is the row, but the art stays a 16px square at the left
  end
  local enabled = true
  function b:refresh() tick:SetShown(get() and true or false) end
  function b:setEnabled(on) enabled = on and true or false; self:SetAlpha(enabled and 1 or 0.5) end
  b:SetScript("OnClick", function(self)
    if not enabled then return end
    set(not get()); self:refresh()
  end)
  b:refresh()
  return b
end

-- ------------------------------------------------------------
-- CLASS COLOR (the owner, 2026-09-27). Every two-window color control offers
-- "Use Class Color" in its picker (a SOURCE, see the picker note): the field
-- jumps to the class's color and, left there, the color FOLLOWS the class of
-- whichever character is logged in; moving or editing it disconnects it into a
-- plain color. Saved as an ordinary color table carrying `class = true` — so
-- every consumer still reads c[1..3] and needs no change — and re-stamped with
-- the current class's color by UI.StampClassColors, which each tool runs over
-- its SavedVariables at PLAYER_LOGIN before it applies anything.
-- ------------------------------------------------------------
function UI.ClassRGB()
  local _, tok = UnitClass("player")
  local c = tok and ((C_ClassColor and C_ClassColor.GetClassColor and C_ClassColor.GetClassColor(tok))
    or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[tok]))
  if c then return c.r, c.g, c.b end
end
UI.CLASS_SOURCE = { value = "class", label = "Use Class Color", word = "Class", color = UI.ClassRGB }
-- A class color value, keeping `prev`'s opacity.
function UI.ClassColorValue(prev)
  local r, g, b = UI.ClassRGB(); if not r then return nil end
  return { r, g, b, prev and prev[4] or nil, class = true }
end
local function isClassColor(t)
  return t.class == true and type(t[1]) == "number" and type(t[2]) == "number" and type(t[3]) == "number"
end
-- Re-color every class-marked color anywhere under `root` (a whole SavedVariables
-- table: every profile, every character) to the logged-in class. Returns the count.
function UI.StampClassColors(root)
  local r, g, b = UI.ClassRGB()
  if not (r and type(root) == "table") then return 0 end
  local seen, n = {}, 0
  local function walk(t)
    if seen[t] then return end
    seen[t] = true
    if isClassColor(t) then t[1], t[2], t[3] = r, g, b; n = n + 1; return end
    for _, v in pairs(t) do if type(v) == "table" then walk(v) end end
  end
  walk(root)
  return n
end
-- Open the picker for a color control that offers the class color. `opts` is the
-- control's { get, set, hasAlpha, title }; `refresh` repaints it. A Cancel puts
-- back EXACTLY what was saved (the class mark included, or unset).
-- A tool with sources of its OWN (Unit Frames: the UNIT's class, its power
-- type, the class resource — resolved live by the tool, not stamped) passes
-- `opts.sources` = { { value, label, color() } } with `opts.getSource()` (the
-- value in force, or nil) and `opts.setSource(value)`; `set(color)` then means
-- a plain color and must clear the tool's source.
function UI.pickColorWithClass(opts, owner, title, refresh)
  local orig = opts.get()
  local custom = opts.sources
  local origSrc = custom and opts.getSource and opts.getSource() or nil
  local function take(v)
    if type(v) == "string" then
      if custom then opts.setSource(v) else opts.set(UI.ClassColorValue(orig)) end
    else opts.set(v) end
    refresh()
  end
  UI.colorPicker({
    color = orig or { 1, 1, 1 },
    hasAlpha = opts.hasAlpha,
    title = title,
    owner = owner,
    sources = custom or { UI.CLASS_SOURCE },
    source = custom and origSrc or ((orig and orig.class) and "class" or nil),
    onChange = take,
    onSource = take,
    onCancel = function()
      if origSrc then opts.setSource(origSrc) else opts.set(orig) end
      refresh()
    end,
  })
end

-- UI.colorDot(parent, opts) → a colour control, the mocks' "Frame 320": a
-- checkbox (the colour is ON), an optional label, and a 20px circle of the
-- colour — a dashed ring when none is set. Click the circle for the suite
-- picker; unticking clears the colour (set(nil)), ticking opens the picker.
-- `required` drops the checkbox (a colour that must always have a value).
--   opts = { get, set, label?, title ("TEXT COLOR", the picker's), hasAlpha,
--            required, accent }
function UI.colorDot(parent, opts)
  local f = CreateFrame("Frame", nil, parent)
  f:SetHeight(22)
  local x = 0
  local chk
  local function openPicker() end
  local ds = opts.dot or 20
  if not opts.required then
    chk = UI.box(f, nil, function() return opts.get() ~= nil end, function(on)
      if on then openPicker() else opts.set(nil); f:refresh() end
    end, opts.accent)
    chk:SetPoint("LEFT", 0, 0)
    x = opts.gap or 26
  end
  if opts.label then
    local lbl = UI.text(f, opts.label, 12); lbl:SetPoint("LEFT", x, 0)
    x = x + math.ceil(lbl:GetStringWidth()) + 10
    f.label = lbl
  end
  local dot = CreateFrame("Button", nil, f); dot:SetSize(ds, ds); dot:SetPoint("LEFT", x, 0)
  local disc = dot:CreateTexture(nil, "ARTWORK"); disc:SetAllPoints()
  f:SetWidth(x + ds)
  if opts.dot then f:SetHeight(16) end
  f.check = chk
  f.dot = dot

  local enabled = true
  function f:refresh()
    local c = opts.get()
    if c then
      if UI.NoteColor then UI.NoteColor(c) end   -- it is live somewhere: it belongs in the palette
      disc:SetTexture(opts.disc or UI.DISC); disc:SetVertexColor(c[1] or 1, c[2] or 1, c[3] or 1, 1)
    else
      disc:SetTexture(opts.discNo or UI.DISC_NO); disc:SetVertexColor(1, 1, 1, 0.5)
    end
    if chk then chk:refresh() end
  end
  -- A cancel must be able to put an UNSET colour back: the picker restores what
  -- it opened with, and "unset" is not a colour it can hold (GA's MakeColor rule).
  openPicker = function()
    if not enabled then return end
    if opts.classSource then
      UI.pickColorWithClass(opts, dot, (opts.title or opts.label or "Color"):upper(), function() f:refresh() end)
      return
    end
    local wasUnset = opts.get() == nil
    UI.colorPicker({
      color = opts.get() or { 1, 1, 1 },
      hasAlpha = opts.hasAlpha,
      title = (opts.title or opts.label or "Color"):upper(),
      owner = dot,
      onChange = function(c) opts.set(c); f:refresh() end,
      onCancel = function() if wasUnset then opts.set(nil) end; f:refresh() end,
    })
  end
  dot:SetScript("OnClick", openPicker)
  function f:setEnabled(on)
    enabled = on and true or false
    if chk then chk:setEnabled(enabled) end
    dot:SetEnabled(enabled)
    self:SetAlpha(enabled and 1 or 0.5)
    if chk then chk:SetAlpha(1) end   -- the frame's own alpha already dims it
  end
  f:refresh()
  return f
end

-- UI.toggle2(parent, choices, get, set) → the mocks' two-part switch ("Off | On",
-- "Enabled | Disabled"): one pill cut in two with a 1px line of the accent
-- between the halves; the CHOSEN half at 30%, the other at 10%. Each half is as
-- wide as its word + 11 each side. choices = { {value, label}, {value, label} }.
function UI.toggle2(parent, choices, get, set, accent)
  local ac = accent or UI.accentOf(parent)
  local h, cw = 25, PILL_CAP[25]
  local u, v = cw / 16, h / 32
  local f = CreateFrame("Frame", nil, parent); f:SetHeight(h)
  local halves = {}
  local x = 0
  for i, ch in ipairs(choices) do
    local b = CreateFrame("Button", nil, f)
    b.text = UI.newText(b, FONT.sa, 11, COLOR.paper, "CENTER"); b.text:SetText(ch[2])
    local w = math.ceil(b.text:GetStringWidth()) + 22
    b:SetSize(w, h); b:SetPoint("LEFT", x, 0); b.text:SetPoint("CENTER", 0, 0)
    local left = (i == 1)
    local capF = b:CreateTexture(nil, "BACKGROUND"); capF:SetTexture(UI.PILL_DIR .. "cap25-fill.png"); capF:SetSize(cw, h)
    local capR = b:CreateTexture(nil, "BORDER");     capR:SetTexture(UI.PILL_DIR .. "cap25-rim.png");  capR:SetSize(cw, h)
    local mid = b:CreateTexture(nil, "BACKGROUND"); mid:SetColorTexture(1, 1, 1, 1)
    if left then
      capF:SetTexCoord(0, u, 0, v); capF:SetPoint("LEFT"); capR:SetTexCoord(0, u, 0, v); capR:SetPoint("LEFT")
      mid:SetPoint("TOPLEFT", cw, 0); mid:SetPoint("BOTTOMRIGHT", 0, 0)
      local line = b:CreateTexture(nil, "BORDER"); line:SetWidth(1)
      line:SetPoint("TOPRIGHT", 0, 0); line:SetPoint("BOTTOMRIGHT", 0, 0)
      line:SetColorTexture(ac.r, ac.g, ac.b, 1)
    else
      capF:SetTexCoord(u, 0, 0, v); capF:SetPoint("RIGHT"); capR:SetTexCoord(u, 0, 0, v); capR:SetPoint("RIGHT")
      mid:SetPoint("TOPLEFT", 0, 0); mid:SetPoint("BOTTOMRIGHT", -cw, 0)
    end
    capR:SetVertexColor(ac.r, ac.g, ac.b, 1)
    b.fills = { capF, mid }
    b.value = ch[1]
    halves[i] = b
    x = x + w
  end
  f:SetWidth(x)
  local enabled, hot = true, nil
  function f:refresh()
    local cur = get()
    for _, b in ipairs(halves) do
      local a = ((b.value == cur) and 0.3 or 0.1) + ((hot == b) and 0.1 or 0)
      for _, t in ipairs(b.fills) do t:SetVertexColor(ac.r, ac.g, ac.b, a) end
    end
  end
  function f:setEnabled(on) enabled = on and true or false; self:SetAlpha(enabled and 1 or 0.5) end
  for _, b in ipairs(halves) do
    b:SetScript("OnEnter", function(self) if enabled then hot = self; f:refresh() end end)
    b:SetScript("OnLeave", function() hot = nil; f:refresh() end)
    b:SetScript("OnClick", function(self)
      if not enabled or get() == self.value then return end
      set(self.value); f:refresh()
    end)
  end
  f:refresh()
  return f
end

-- UI.pillField(parent, w, opts) → the white field: a 25-tall white pill with
-- Saira 11 in the window's near-black, 6 in from the left. `button` hangs a
-- "Choose" on its right end — an opaque dark-accent pill with the stroke on
-- its right end only (the mocks' Icon/Art field).
--   opts = { placeholder, numeric, justify, commit(text) — on Enter AND on
--            losing focus, button = { label, onClick }, accent }
-- Returns the EditBox; :SetText as usual; .button when there is one.
function UI.pillField(parent, w, opts)
  opts = opts or {}
  local ac = opts.accent or UI.accentOf(parent)
  local h, cw = 25, PILL_CAP[25]
  local u, v = cw / 16, h / 32
  local e = CreateFrame("EditBox", nil, parent)
  e:SetSize(w, h); e:SetAutoFocus(false)
  UI.setFont(e, FONT.sa, 11); e:SetTextColor(COLOR.void.r, COLOR.void.g, COLOR.void.b)
  e:SetJustifyH(opts.justify or "LEFT")
  if opts.numeric then e:SetNumeric(true) end
  local capL = e:CreateTexture(nil, "BACKGROUND"); capL:SetTexture(UI.PILL_DIR .. "cap25-fill.png")
  capL:SetSize(cw, h); capL:SetTexCoord(0, u, 0, v); capL:SetPoint("LEFT")
  local capR = e:CreateTexture(nil, "BACKGROUND"); capR:SetTexture(UI.PILL_DIR .. "cap25-fill.png")
  capR:SetSize(cw, h); capR:SetTexCoord(u, 0, 0, v); capR:SetPoint("RIGHT")
  local mid = e:CreateTexture(nil, "BACKGROUND"); mid:SetColorTexture(1, 1, 1, 1)
  mid:SetPoint("TOPLEFT", cw, 0); mid:SetPoint("BOTTOMRIGHT", -cw, 0)
  local right = 6
  if opts.button then
    local b = UI.pill(e, opts.button.label or "Choose", { accent = ac, rim = "right",
      solid = mix(COLOR.void, ac, 0.2), onClick = opts.button.onClick })
    b:SetPoint("RIGHT", 0, 0)
    e.button = b
    right = b:GetWidth() + 4
  end
  e:SetTextInsets(6, right, 0, 0)
  if opts.placeholder then
    local ph = UI.newText(e, FONT.sa, 11, COLOR.void, opts.justify or "LEFT"); ph:SetAlpha(0.4)
    ph:SetPoint("LEFT", 6, 0); ph:SetPoint("RIGHT", -right, 0); ph:SetText(opts.placeholder); ph:SetWordWrap(false)
    local function upd() ph:SetShown((e:GetText() or "") == "") end
    e:HookScript("OnTextChanged", upd); e:HookScript("OnShow", upd)
    -- Text set from CODE must hide it too, without leaning on OnTextChanged
    -- firing for a programmatic SetText.
    local set = e.SetText
    function e:SetText(t) set(self, t); upd() end
    e.placeholder = ph
  end
  e:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  e:SetScript("OnEscapePressed", function(self) self._escape = true; self:ClearFocus() end)
  e:SetScript("OnEditFocusLost", function(self)
    if self._escape then self._escape = nil; if opts.revert then opts.revert(self) end; return end
    if opts.commit then opts.commit(self:GetText() or "") end
  end)
  UI.tabbable(e)
  function e:setEnabled(on)
    self:SetEnabled(on and true or false)
    if self.button then self.button:SetEnabled(on and true or false) end
    self:SetAlpha(on and 1 or 0.5)
  end
  return e
end

-- UI.xbtn(parent, onClick) → the mocks' small X: 24 x 21, the accent solid with
-- 4px corners, "X" in Saira Bold 11 near-black.
function UI.xbtn(parent, onClick, accent)
  local ac = accent or UI.accentOf(parent)
  local b = CreateFrame("Button", nil, parent); b:SetSize(24, 21)
  local bg = UI.roundFill(b, "BACKGROUND"); UI.tint(bg, ac)
  local t = UI.newText(b, FONT.saB, 11, COLOR.void, "CENTER"); t:SetPoint("CENTER", 0, 0); t:SetText("X")
  b:SetScript("OnEnter", function() bg:SetVertexColor(math.min(1, ac.r + 0.12), math.min(1, ac.g + 0.12), math.min(1, ac.b + 0.12), 1) end)
  b:SetScript("OnLeave", function() UI.tint(bg, ac) end)
  if onClick then b:SetScript("OnClick", onClick) end
  return b
end

-- UI.scrollPane(parent, opts) → a ScrollFrame whose bar exists only while the
-- content is taller than the pane (the owner, 2026-09-23: "I do NOT want the
-- scrollbar present when/if the content doesn't require it"). A 4px bar in the
-- accent, `barGap` right of the pane; the wheel scrolls 40 at a time.
--   opts = { w, barGap = 6, accent } → pane with .child, :SetContentHeight(h),
--   :ScrollTo(y)
function UI.scrollPane(parent, opts)
  opts = opts or {}
  local ac = opts.accent or UI.accentOf(parent)
  local sf = CreateFrame("ScrollFrame", nil, parent)
  local child = CreateFrame("Frame", nil, sf); child:SetSize(opts.w or 10, 10)
  sf:SetScrollChild(child); sf.child = child
  sf:EnableMouseWheel(true)
  local track = CreateFrame("Frame", nil, parent); track:SetWidth(4)
  track:SetPoint("TOPLEFT", sf, "TOPRIGHT", opts.barGap or 6, 0)
  track:SetPoint("BOTTOMLEFT", sf, "BOTTOMRIGHT", opts.barGap or 6, 0)
  local tt = track:CreateTexture(nil, "BACKGROUND"); tt:SetAllPoints(); tt:SetColorTexture(ac.r, ac.g, ac.b, 0.1)
  local thumb = CreateFrame("Button", nil, track); thumb:SetWidth(4); thumb:EnableMouse(true)
  local th = thumb:CreateTexture(nil, "ARTWORK"); th:SetAllPoints(); th:SetColorTexture(ac.r, ac.g, ac.b, 0.7)
  track:Hide()
  local contentH, maxS = 10, 0
  local function place()
    local view = sf:GetHeight() or 1
    local v = sf:GetVerticalScroll() or 0
    if maxS <= 0 then return end
    local hgt = math.max(24, view * view / contentH)
    thumb:SetHeight(hgt)
    thumb:ClearAllPoints(); thumb:SetPoint("TOPLEFT", track, "TOPLEFT", 0, -(view - hgt) * (v / maxS))
  end
  function sf:ScrollTo(y)
    y = math.max(0, math.min(maxS, y or 0))
    self:SetVerticalScroll(y); place()
  end
  function sf:SetContentHeight(h)
    contentH = math.max(1, h or 1)
    child:SetHeight(contentH)
    maxS = math.max(0, contentH - (self:GetHeight() or 0))
    track:SetShown(maxS > 0)
    self:ScrollTo(self:GetVerticalScroll() or 0)
  end
  sf:SetScript("OnSizeChanged", function(self) self:SetContentHeight(contentH) end)
  sf:SetScript("OnMouseWheel", function(self, d) self:ScrollTo((self:GetVerticalScroll() or 0) - d * 40) end)
  local dragging, startY, startS = false, 0, 0
  thumb:SetScript("OnMouseDown", function(self)
    dragging = true; startS = sf:GetVerticalScroll() or 0
    local _, cy = GetCursorPosition(); startY = cy / self:GetEffectiveScale()
  end)
  thumb:SetScript("OnMouseUp", function() dragging = false end)
  thumb:SetScript("OnUpdate", function(self)
    if not dragging then return end
    if not IsMouseButtonDown("LeftButton") then dragging = false; return end
    local view = sf:GetHeight() or 1
    local range = view - self:GetHeight()
    if range <= 0 then return end
    local _, cy = GetCursorPosition()
    local moved = startY - cy / self:GetEffectiveScale()
    sf:ScrollTo(startS + moved / range * maxS)
  end)
  return sf
end

-- ------------------------------------------------------------
-- ★ THE GLASS KIT (MINOR 14, 2026-09-25) — the THIRD redesign ("Glass", 13
-- screens on the Figma page "GloomSuite UI 2", named "Glass Auras, …" and
-- "Glass Bars, …"). The second design's per-tool accent is GONE: one palette
-- for the whole suite (the owner, 2026-09-25: "All pages are going to use this
-- same palette"). The glass itself is ART — each page's background with its
-- glass panels already composited, exported by the owner from Figma and drawn
-- by the Suite window behind the page (WoW has no backdrop blur; the panels
-- never move, so baking them is exact). Everything here draws ON the glass.
--
-- Read off the mocks (every number below is a mock's):
--   · violet #6c2fe6 — every outline, the checkbox, a row's marker square
--   · lilac  #a881f8 — a button's word, a picked outline, the dial's ticks
--   · lime   #28d65c — the tool's name in the switcher, "+ ADD NEW AURA", a
--                      visible eye, the chosen page's ▸
--   · slate  #464646 — a destructive button at rest (DELETE, DELETE AURA)
--   · fills are violet at 10% (a switch's unpicked half), 20% (a row, a
--     picked button), 30% (a switch's picked half, a field, a dial's box),
--     50% (the chosen page)
--   · type: Saira 12 labels, Saira 11 values, Saira MEDIUM 10 capitals on
--     buttons and dropdowns, Michroma 18 panel titles / 14 sub-titles
-- Every control is 16 tall. Disabled = 50%, never hidden (the suite's rule).
-- ------------------------------------------------------------
COLOR.violet = COLOR.violet or color("6c2fe6")
COLOR.lilac  = COLOR.lilac or color("a881f8")
COLOR.lime   = color("28d65c")
COLOR.slate  = color("464646")
COLOR.deep   = color("110034")    -- a row nested in a trigger group (at 75%)
COLOR.list   = color("150a26")    -- the dropdown list's plate (not mocked yet)
COLOR.panel  = color("0f051d")    -- a page's panel, at 90% (2026-09-26: the glass became solid)

-- The mocks' buttons and dropdowns are Saira MEDIUM (shipped 2026-09-25).
-- ⚠ NEW FONTS LOAD AT CLIENT LAUNCH — the first time it ships, a /reload is not
-- enough (CLAUDE.md working agreement 4).
FONT.saM = FONT_DIR .. "Saira-Medium.ttf"
-- ★★ SANSATION (2026-09-27): the two-window design is set in Sansation and
-- NOTHING else (the owner: "Sansation should be used exclusively"). The glass
-- tokens are re-pointed at it, so every widget of this kit draws it. (Saira,
-- the tokens' earlier face, was drawn one weight lighter than the mocks on the
-- owner's call of 2026-09-26; that has NOT been judged for Sansation — /gloom
-- fonttest shows Regular against Light.) Google Fonts' static files, Version
-- 1.301, OFL (Media/fonts/FONT-LICENSES.md).
FONT.sn  = FONT_DIR .. "Sansation-Regular.ttf"
FONT.snB = FONT_DIR .. "Sansation-Bold.ttf"
FONT.snL = FONT_DIR .. "Sansation-Light.ttf"
FONT.sa, FONT.saM, FONT.saB = FONT.sn, FONT.sn, FONT.snB

-- ★ The marks are drawn at 4x their display size (tools/gen-glass-art.py): one UI
-- unit is 1.8-3 screen pixels in the game, so 1x art was being ENLARGED, and soft.
-- The texcoords below are fractions of the canvas, so they did not change.
UI.G_TICKS = lib.MEDIA .. "ui\\g-ticks.png"   -- 21 ticks, 101 x 10 on 128 x 16 (no longer drawn — see UI.dial)
UI.G_CLOSE = lib.MEDIA .. "ui\\g-close.png"   -- the window's close disc, 23 on 32 (x4)
UI.G_X     = lib.MEDIA .. "ui\\g-x.png"       -- a row's remove X, 9 on 16 (x4)
UI.G_EYE   = lib.MEDIA .. "ui\\g-eye.png"     -- 14 x 8.5 on 16 (x4)
UI.G_WARN  = lib.MEDIA .. "ui\\g-warn.png"    -- 12 x 11.5 on 16 (x4)
UI.G_TRI   = lib.MEDIA .. "ui\\g-tri.png"     -- the ▾ (points DOWN; +90° = right), 64 x 64
UI.G_CHECK = lib.MEDIA .. "ui\\g-check.png"   -- the checkbox's tick in its 16px box, 64 x 64
UI.G_DISC  = lib.MEDIA .. "ui\\g-disc.png"    -- a colour swatch, 128 x 128
UI.G_DISC_NO = lib.MEDIA .. "ui\\g-disc-dash.png"   -- the swatch with no colour set
UI.G_CORNER = lib.MEDIA .. "ui\\g-corner.png"  -- a panel's 20-unit corner: a TOP-LEFT quarter disc, 80 on 128
UI.G_POPOUT = lib.MEDIA .. "ui\\g-popout.png"  -- a section's pop-out icon, 8.5 (34 on 64)
UI.G_POPIN  = lib.MEDIA .. "ui\\g-popin.png"   -- … and the pop-in, in a popped-out window

local function rgba(t, c, a) t:SetColorTexture(c.r, c.g, c.b, a or 1) end

-- ★ TEXT IN A BOX SITS 1.5 UNITS LOW (2026-09-26). The owner's in-game screenshot
-- (OBSERVED, one screenshot, 4K at 2 px a unit): capitals inside every glass
-- button, switch and dropdown sat ~1.5 units ABOVE centre — ~3 units of space
-- over them, ~6 under. Saira's own metrics centre its capitals to within 0.02
-- em, so the offset is how WoW places a line of text in its FontString, not the
-- font. 1.5 is a whole number of pixels at the window's 2-px scale. Every text
-- that sits inside a glass box is anchored this much lower.
-- ★ A control that can't apply right now DIMS to 30% (the owner, 2026-09-27 —
-- the two-window mocks' opacity-30; it was 50%). Never hides.
UI.G_DIM = 0.3
local DIM = UI.G_DIM
UI.G_NUDGE = 0   -- 1.5 for Saira (measured, one screenshot). Sansation needs NONE: measured on the owner's screenshot 2026-09-27, with the old 1-unit nudge a switch's capitals had 11 px above and 6 below in a 30 px box (~1.3 units low); with 0 they sit within half a pixel of center.
local NUDGE = UI.G_NUDGE

-- ★ HAIRLINES (2026-09-26). The owner set every line in the mocks to 0.5: at
-- the window's 2-pixel scale that is ONE screen pixel, and a 1-unit line (two
-- pixels) "universally appears too thick". So a glass line is not a size in
-- units but one real pixel at whatever scale it is drawn: 768 / the screen's
-- physical height / the region's effective scale. Every hairline is kept in a
-- weak registry and re-sized by UI.gHairRefresh() — the Shell calls it after any
-- scale change (the window's UI Scale, the game's, the screen's).
local hairs = setmetatable({}, { __mode = "k" })
local function hairSize(r)
  local _, ph = GetPhysicalScreenSize()
  local es = r and r.GetEffectiveScale and r:GetEffectiveScale()
  if not (ph and ph > 0 and es and es > 0) then return 0.5 end
  return 768 / ph / es
end
local function sizeHair(t, axis)
  local h = hairSize(t)
  if axis == "w" then t:SetWidth(h) else t:SetHeight(h) end
end
-- UI.gHair(texture, "w"|"h") — make a line one screen pixel wide ("w", a
-- vertical line) or tall ("h"). Returns the texture.
function UI.gHair(t, axis)
  hairs[t] = axis
  sizeHair(t, axis)
  return t
end
function UI.gHairRefresh()
  for t, axis in pairs(hairs) do sizeHair(t, axis) end
end

-- A hairline outline that can change colour: four OVERLAY textures INSIDE the
-- frame's edges (Figma draws its 0.5 strokes inside). Same handle as
-- UI.addEdges: .top/.bottom/.left/.right + :SetColor(c, a?).
local function outline(f, c, a)
  local e = {}
  local function edge(p1, p2, axis)
    local t = f:CreateTexture(nil, "OVERLAY")
    t:SetPoint(p1); t:SetPoint(p2)
    return UI.gHair(t, axis)
  end
  e.top    = edge("TOPLEFT", "TOPRIGHT", "h")
  e.bottom = edge("BOTTOMLEFT", "BOTTOMRIGHT", "h")
  e.left   = edge("TOPLEFT", "BOTTOMLEFT", "w")
  e.right  = edge("TOPRIGHT", "BOTTOMRIGHT", "w")
  function e:SetColor(cc, aa)
    for _, t in pairs({ self.top, self.bottom, self.left, self.right }) do
      t:SetColorTexture(cc.r, cc.g, cc.b, aa or cc.a or 1)
    end
  end
  function e:SetShown(on) for _, t in pairs({ self.top, self.bottom, self.left, self.right }) do t:SetShown(on) end end
  e:SetColor(c, a)
  return e
end
UI.gOutline = outline

-- UI.gPanel(host, layer?, sublevel?) — a page's PANEL as the mocks draw it since
-- the glass became solid (2026-09-26): COLOR.panel at 90%, 20-unit round
-- corners, no outline. Seven textures on `host` (four corners from one quarter
-- disc, three rectangles that never overlap, so the 90% stays even). Returns
-- a handle: :Place(x, y, w, h) in `host`'s top-left units, :SetShown(on),
-- :SetColor(c, a).
local CR, CT = 20, 80 / 128     -- the corner in units; its share of the canvas
function UI.gPanel(host, layer, sub)
  layer = layer or "BACKGROUND"
  local p = { parts = {} }
  local function tex(file)
    local t = host:CreateTexture(nil, layer, nil, sub or 0)
    if file then t:SetTexture(file) end
    p.parts[#p.parts + 1] = t
    return t
  end
  p.tl, p.tr, p.bl, p.br = tex(UI.G_CORNER), tex(UI.G_CORNER), tex(UI.G_CORNER), tex(UI.G_CORNER)
  p.tl:SetTexCoord(0, CT, 0, CT); p.tr:SetTexCoord(CT, 0, 0, CT)
  p.bl:SetTexCoord(0, CT, CT, 0); p.br:SetTexCoord(CT, 0, CT, 0)
  p.top, p.mid, p.bot = tex(), tex(), tex()
  function p:SetColor(c, a)
    for _, t in ipairs({ self.tl, self.tr, self.bl, self.br }) do t:SetVertexColor(c.r, c.g, c.b, a or 1) end
    for _, t in ipairs({ self.top, self.mid, self.bot }) do t:SetColorTexture(c.r, c.g, c.b, a or 1) end
  end
  function p:Place(x, y, w, h)
    local function at(t, tx, ty, tw, th)
      t:ClearAllPoints(); t:SetPoint("TOPLEFT", host, "TOPLEFT", tx, -ty); t:SetSize(tw, th)
    end
    at(self.tl, x, y, CR, CR);               at(self.tr, x + w - CR, y, CR, CR)
    at(self.bl, x, y + h - CR, CR, CR);      at(self.br, x + w - CR, y + h - CR, CR, CR)
    at(self.top, x + CR, y, w - 2 * CR, CR); at(self.bot, x + CR, y + h - CR, w - 2 * CR, CR)
    at(self.mid, x, y + CR, w, h - 2 * CR)
  end
  function p:SetShown(on) for _, t in ipairs(self.parts) do t:SetShown(on) end end
  p:SetColor(COLOR.panel, 0.9)
  return p
end

-- The small ▾ every dropdown ends with: 9px box, a 7-wide triangle, violet.
local function caret(parent, c)
  local t = parent:CreateTexture(nil, "ARTWORK")
  t:SetTexture(UI.G_TRI); t:SetSize(7, 6); UI.tint(t, c or COLOR.violet)
  return t
end
UI.gCaret = caret

-- ============================================================
-- ★ THE TWO-WINDOW KIT (MINOR 16, 2026-09-27) — the owner's Figma page
-- "GloomSuite UI 3". The Suite is no longer one big window: a tool shows a
-- SELECTOR window (its list or preview) and a SETTINGS window (its sections,
-- one open at a time), and any section can POP OUT into its own window. Every
-- widget below was restyled to those mocks:
--   · SANSATION everywhere (the owner: "Sansation should be used exclusively"):
--     labels 12, a section's title 14, controls 9-10.
--   · a labelled control is 33 tall: its label (13) and, 4 under it, the
--     16-tall control. Controls STRETCH to the width they are given (the
--     settings' two columns are 170 wide, 20 apart; a three-column row is
--     107 · 106 · 107).
--   · every outline is a hairline (one screen pixel).
-- ============================================================

-- UI.gTitle(parent, text, size?) → Sansation, white; 14 = a section's title.
function UI.gTitle(parent, text, size)
  local fs = UI.newText(parent, FONT.sa, size or 14, COLOR.paper, "LEFT")
  fs:SetText(text or ""); fs:SetWordWrap(false)
  return fs
end

-- UI.gLabel(parent, text, size?, color?) → Sansation 10 white (a control's label;
-- 12 until the owner took the mocks' labels to 10, 2026-09-27).
function UI.gLabel(parent, text, size, c)
  local fs = UI.newText(parent, FONT.sa, size or 10, c or COLOR.paper, "LEFT")
  fs:SetText(text or ""); fs:SetWordWrap(false)
  return fs
end

-- UI.gButton(parent, label, opts?) — the mocks' button: a violet hairline, the
-- word in Sansation 9 lilac, 4 (+ the line) each side, 15 tall. SELECTED fills
-- violet 30% with a white word; DANGER (Delete) is coral, word and line, at
-- rest too (the mocks). Under the mouse: violet 20% (coral 15% for danger).
--   opts = { w, h (15), pad (4), size (9), selected, danger, onClick, upper }
function UI.gButton(parent, label, opts)
  opts = opts or {}
  local b = CreateFrame("Button", nil, parent)
  b:SetHeight(opts.h or 15)
  b.fill = b:CreateTexture(nil, "BACKGROUND"); b.fill:SetAllPoints()
  b.edge = outline(b, COLOR.violet)
  b.text = UI.newText(b, FONT.sa, opts.size or 9, COLOR.lilac, "CENTER")
  b.text:SetPoint("CENTER", 0, -NUDGE); b.text:SetWordWrap(false)
  b._w, b._sel, b._danger, b._hot = opts.w, opts.selected and true or false, opts.danger, false
  b._pad = opts.pad or 4
  b._upper = opts.upper == true
  function b:paint()
    local on = self:IsEnabled()
    local ec, tc, fc, fa = COLOR.violet, COLOR.lilac, COLOR.violet, 0
    if self._danger then ec, tc, fc = COLOR.coral, COLOR.coral, COLOR.coral end
    if self._sel then fa, tc = 0.3, COLOR.paper end
    if self._hot and on then fa = math.max(fa, self._danger and 0.15 or 0.2) + (self._sel and 0.1 or 0) end
    rgba(self.fill, fc, fa)
    self.edge:SetColor(ec)
    self.text:SetTextColor(tc.r, tc.g, tc.b)
    self:SetAlpha(on and 1 or DIM)
  end
  function b:SetLabel(s)
    s = tostring(s or "")
    self.text:SetText(self._upper and s:upper() or s)
    self:SetWidth(self._w or (math.ceil(self.text:GetStringWidth()) + 2 * self._pad + 1))
  end
  function b:SetSelected(on) self._sel = on and true or false; self:paint() end
  function b:setEnabled(on) self:SetEnabled(on and true or false); self:paint() end
  b:SetScript("OnEnter", function(self) self._hot = true; self:paint() end)
  b:SetScript("OnLeave", function(self) self._hot = false; self:paint() end)
  b:SetScript("OnEnable", function(self) self:paint() end)
  b:SetScript("OnDisable", function(self) self._hot = false; self:paint() end)
  if opts.onClick then b:SetScript("OnClick", opts.onClick) end
  b:SetLabel(label)
  b:paint()
  return b
end

-- UI.gSwitch(parent, choices, get, set, opts?) — the segmented switch (Off | On,
-- Up | Down | Left | Right …): EQUAL segments stretched across `w`, 16 tall, a
-- violet hairline round the whole and between them; the PICKED one violet 30%
-- with a white word, the rest a lilac word (Sansation 9). `accent` recolors
-- the lines and the pick (Bars' lime bar picker).
--   choices = { {value, label}, … }; opts = { w, accent, size, h (16), widths = { … } (each
--   segment's own width, instead of equal ones — Bars' 1…8 · PET · STANCE) }
--   → Frame with :refresh(), :setEnabled(on), :setChoiceEnabled(value, on)
function UI.gSwitch(parent, choices, get, set, opts)
  opts = opts or {}
  local ac = opts.accent or COLOR.violet
  local SH = opts.h or 16
  local f = CreateFrame("Frame", nil, parent); f:SetHeight(SH)
  local n = #choices
  local segs = {}
  for i, ch in ipairs(choices) do
    local s = CreateFrame("Button", nil, f)
    s.text = UI.newText(s, FONT.sa, opts.size or 9, COLOR.lilac, "CENTER")
    s.text:SetText(tostring(ch[2] or ch[1])); s.text:SetPoint("CENTER", 0, -NUDGE); s.text:SetWordWrap(false)
    s.fill = s:CreateTexture(nil, "BACKGROUND"); s.fill:SetAllPoints()
    s.value, s.enabled = ch[1], true
    segs[i] = s
  end
  local W = opts.w
  if not W then
    W = 0
    for _, s in ipairs(segs) do W = W + math.ceil(s.text:GetStringWidth()) + 20 end
  end
  -- whole-unit widths, the remainder spread from the left
  local base = math.floor(W / n); local extra = W - base * n
  local x = 0
  for i, s in ipairs(segs) do
    local w = (opts.widths and opts.widths[i]) or (base + ((i <= extra) and 1 or 0))
    s:SetSize(w, SH); s:SetPoint("TOPLEFT", x, 0)
    x = x + w
  end
  if opts.widths then W = x end
  f:SetWidth(W)
  outline(f, ac)
  for i = 2, n do
    local j = f:CreateTexture(nil, "BORDER")
    j:SetPoint("TOPLEFT", segs[i], "TOPLEFT", 0, 0); j:SetPoint("BOTTOMLEFT", segs[i], "BOTTOMLEFT", 0, 0)
    rgba(j, ac); UI.gHair(j, "w")
  end
  local enabled, hot = true, nil
  function f:refresh()
    local cur = get()
    for _, s in ipairs(segs) do
      local on = (s.value == cur)
      local a = (on and 0.3 or 0) + ((hot == s and not on and s.enabled and enabled) and 0.15 or 0)
      rgba(s.fill, ac, a)
      local tc = on and COLOR.paper or COLOR.lilac
      s.text:SetTextColor(tc.r, tc.g, tc.b)
      s:SetAlpha(s.enabled and 1 or DIM)
    end
  end
  function f:setEnabled(on) enabled = on and true or false; self:SetAlpha(enabled and 1 or DIM) end
  function f:setChoiceEnabled(value, on)
    for _, s in ipairs(segs) do if s.value == value then s.enabled = on and true or false end end
    self:refresh()
  end
  for _, s in ipairs(segs) do
    s:SetScript("OnEnter", function(self) hot = self; f:refresh() end)
    s:SetScript("OnLeave", function() hot = nil; f:refresh() end)
    s:SetScript("OnClick", function(self)
      if not enabled or not self.enabled or get() == self.value then return end
      set(self.value); f:refresh()
    end)
  end
  f.segs = segs
  f:refresh()
  return f
end

-- ------------------------------------------------------------
-- UI.gList(anchor, options, current, onPick, opts?) — the kit's list, for every
-- dropdown and every right-click menu: the owner's "Dropdown/Popup Menu" mock
-- (2026-09-27) — #0f051d, opaque, in a violet hairline, 10 of padding, lines of
-- Sansation 10 white 14 tall. (Not in the mock, kept from before: the hovered
-- line violet 20%, the current one violet 30% with a lilac word, a danger line
-- coral, a divider as a violet hairline with 4 of space either side (the owner,
-- 2026-09-27: flush against its lines it "looks too compressed").) A line with
-- `font` is drawn in that face (a font list previews its fonts). At least as
-- wide as the anchor; past 16 lines it scrolls. Closes on any outside
-- click, on the anchor hiding, on another list. Words as given (the mocks are
-- sentence case now); `upper = true` capitalizes.
--   options = { {value, label, disabled?, danger?, divider?, font?} , … }
--   opts = { cursor = true (open at the mouse — a context menu), upper, minW }
-- ------------------------------------------------------------
local GL_ROWS, GL_ROW_H, GL_PAD, GL_DIV = 16, 14, 10, 9   -- GL_DIV: 4 · the hairline · 4
local gFly
local function gFlyout()
  if gFly then return gFly end
  local catcher = CreateFrame("Button", nil, UIParent)
  catcher:SetFrameStrata("FULLSCREEN"); catcher:SetAllPoints(UIParent); catcher:Hide()
  catcher:SetFrameLevel(20)
  catcher:RegisterForClicks("AnyUp")
  local fly = CreateFrame("Frame", nil, catcher)
  fly:SetFrameStrata("FULLSCREEN_DIALOG"); fly:EnableMouse(true)
  local plate = fly:CreateTexture(nil, "BACKGROUND"); plate:SetAllPoints(); rgba(plate, COLOR.panel, 1)
  outline(fly, COLOR.violet)
  local scroll = CreateFrame("ScrollFrame", nil, fly)
  scroll:SetPoint("TOPLEFT", 1, -GL_PAD); scroll:SetPoint("BOTTOMRIGHT", -1, GL_PAD)
  scroll:EnableMouseWheel(true)
  local child = CreateFrame("Frame", nil, scroll); child:SetSize(10, 10)
  scroll:SetScrollChild(child)
  scroll:SetScript("OnMouseWheel", function(self, delta)
    local range = math.max(0, child:GetHeight() - self:GetHeight())
    self:SetVerticalScroll(math.max(0, math.min(range, self:GetVerticalScroll() - delta * GL_ROW_H * 2)))
  end)
  catcher:SetScript("OnClick", function() catcher:Hide() end)
  fly.catcher, fly.scroll, fly.child, fly.rows = catcher, scroll, child, {}
  gFly = fly
  return fly
end
function UI.gListClose() if gFly then gFly.catcher:Hide() end end
-- The list's own frame, so a caller can scale it with the window.
function UI.gListFrame() return gFlyout() end

function UI.gList(anchor, options, current, onPick, opts)
  opts = opts or {}
  local fly = gFlyout()
  -- ★ The scale FIRST, then measure (2026-09-29, the owner: the first menu
  -- after a /reload read "Rena…", later ones were fine). The list wears the
  -- anchor's effective scale; set after the rows were measured, the FIRST
  -- list was measured at scale 1 and drawn at the Addon UI Scale, where the
  -- same text renders a little wider than the width it was given.
  local es = anchor and anchor:GetEffectiveScale() or 1
  fly:SetScale(es / UIParent:GetEffectiveScale())
  local y, widest, shownH = 0, 0, 0
  for i, opt in ipairs(options) do
    if opt.divider and i > 1 then y = y - GL_DIV end
    local row = fly.rows[i]
    if not row then
      row = CreateFrame("Button", nil, fly.child); row:SetHeight(GL_ROW_H)
      row.fill = row:CreateTexture(nil, "BACKGROUND"); row.fill:SetAllPoints()
      row.rule = row:CreateTexture(nil, "BORDER")
      row.rule:SetPoint("TOPLEFT", 10, 5); row.rule:SetPoint("TOPRIGHT", -10, 5); rgba(row.rule, COLOR.violet, 0.6)
      UI.gHair(row.rule, "h")
      row.text = UI.newText(row, FONT.sa, 10, COLOR.paper, "LEFT")
      row.text:SetPoint("LEFT", 9.5, 0); row.text:SetPoint("RIGHT", -9.5, 0); row.text:SetWordWrap(false)
      row:SetScript("OnEnter", function(self) if not self._off then self._hot = true; self:paintRow() end end)
      row:SetScript("OnLeave", function(self) self._hot = false; self:paintRow() end)
      function row:paintRow()
        local a = self._cur and 0.3 or (self._hot and 0.2 or 0)
        rgba(self.fill, COLOR.violet, a)
        local tc = self._danger and COLOR.coral or (self._cur and COLOR.lilac or COLOR.paper)
        self.text:SetTextColor(tc.r, tc.g, tc.b)
        self.text:SetAlpha(self._off and DIM or 1)
      end
      fly.rows[i] = row
    end
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, y); row:SetPoint("TOPRIGHT", 0, y)
    local lbl = tostring(opt.label or opt.value or "")
    UI.setFont(row.text, opt.font or FONT.sa, 10)
    row.text:SetText(opts.upper and lbl:upper() or lbl)
    widest = math.max(widest, row.text:GetStringWidth())
    row._cur = (current ~= nil and opt.value == current)
    row._off, row._danger, row._hot = opt.disabled and true or false, opt.danger, false
    row.rule:SetShown((opt.divider and i > 1) and true or false)
    row:paintRow()
    row:SetScript("OnClick", function()
      if opt.disabled then return end
      fly.catcher:Hide(); onPick(opt.value)
    end)
    row:Show()
    y = y - GL_ROW_H
    if i <= GL_ROWS then shownH = -y end
  end
  for i = #options + 1, #fly.rows do fly.rows[i]:Hide() end
  local w = math.max(math.ceil(widest) + 21, opts.minW or 0, (not opts.cursor and anchor and anchor:GetWidth()) or 0)
  fly.child:SetSize(w - 2, math.max(10, -y))
  fly:SetSize(w, shownH + 2 * GL_PAD)
  fly.scroll:SetVerticalScroll(0)
  -- (The list lives on UIParent and wears the anchor's effective scale so it
  -- lines up with a scaled window — set at the top, before the measuring.)
  UI.gHairRefresh()   -- its lines are one pixel at the scale it now wears
  fly:ClearAllPoints()
  if opts.cursor then
    local cx, cy = GetCursorPosition()
    local s = fly:GetEffectiveScale()
    fly:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", cx / s, cy / s)
  else
    fly:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
  end
  if anchor and not anchor._gFlyHooked then
    anchor._gFlyHooked = true
    anchor:HookScript("OnHide", function() if gFly then gFly.catcher:Hide() end end)
  end
  fly.catcher:Show()
end

-- The dropdown's ▾: the mocks' 9px box with a violet triangle 7 wide.
local function caret(parent, c)
  local t = parent:CreateTexture(nil, "ARTWORK")
  t:SetTexture(UI.G_TRI); t:SetSize(7, 5.5); UI.tint(t, c or COLOR.violet)
  return t
end
UI.gCaret = caret

-- UI.gDrop(parent, w, getLabel, getOptions, getCurrent, onPick, opts?) — the
-- mocks' dropdown: a violet hairline box, 16 tall, the value in Sansation 9
-- white 4 in from the left (or `placeholder`, "Choose", in lilac while there is
-- none), the ▾ at the right. `onClick` replaces the list (a picker that opens
-- its own window).
--   opts = { placeholder, onClick(self, button), upper }
function UI.gDrop(parent, w, getLabel, getOptions, getCurrent, onPick, opts)
  opts = opts or {}
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(w, 16)
  b.fill = b:CreateTexture(nil, "BACKGROUND"); b.fill:SetAllPoints()
  b.edge = outline(b, COLOR.violet)
  b.text = UI.newText(b, FONT.sa, 9, COLOR.paper, "LEFT")
  b.text:SetPoint("LEFT", 4.5, -NUDGE); b.text:SetPoint("RIGHT", -16, -NUDGE); b.text:SetWordWrap(false)
  b.tri = caret(b); b.tri:SetPoint("RIGHT", -5.5, -0.5)
  local enabled, hot = true, false
  function b:refresh()
    local s = getLabel and getLabel()
    local empty = (s == nil or s == "")
    if empty then s = opts.placeholder or "Choose" end
    s = tostring(s)
    self.text:SetText(opts.upper and s:upper() or s)
    local tc = empty and COLOR.lilac or COLOR.paper
    self.text:SetTextColor(tc.r, tc.g, tc.b)
    rgba(self.fill, COLOR.violet, hot and enabled and 0.2 or 0)
  end
  function b:setEnabled(on) enabled = on and true or false; self:SetAlpha(enabled and 1 or DIM) end
  b:SetScript("OnEnter", function(self) hot = true; self:refresh() end)
  b:SetScript("OnLeave", function(self) hot = false; self:refresh() end)
  b:SetScript("OnClick", function(self, btn)
    if not enabled then return end
    if opts.onClick then opts.onClick(self, btn); return end
    UI.gList(self, (getOptions and getOptions()) or {}, getCurrent and getCurrent(), function(v)
      onPick(v); self:refresh()
    end)
  end)
  b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  b:refresh()
  return b
end

-- UI.gField(parent, w, opts?) — the mocks' text field: violet 30%, Sansation 10
-- white, 6 in from the left, 16 tall. Commits on Enter AND on losing focus;
-- Escape puts it back (opts.revert). `placeholder` shows at 40% while empty.
--   opts = { placeholder, numeric, justify, commit(text), revert(self), maxLetters }
function UI.gField(parent, w, opts)
  opts = opts or {}
  local e = CreateFrame("EditBox", nil, parent)
  e:SetSize(w, 16); e:SetAutoFocus(false)
  UI.setFont(e, FONT.sa, 10); e:SetTextColor(1, 1, 1)
  e:SetJustifyH(opts.justify or "LEFT"); e:SetTextInsets(6, 4, NUDGE, 0)
  if opts.numeric then e:SetNumeric(true) end
  if opts.maxLetters then e:SetMaxLetters(opts.maxLetters) end
  e:SetHighlightColor(COLOR.lilac.r, COLOR.lilac.g, COLOR.lilac.b, 0.5)
  local bg = e:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); rgba(bg, COLOR.violet, 0.3)
  e.bg = bg   -- recolorable (Unit Frames' row being edited is lime 30%)
  if opts.placeholder then
    local ph = UI.newText(e, FONT.sa, 10, COLOR.paper, opts.justify or "LEFT"); ph:SetAlpha(0.4)
    ph:SetPoint("LEFT", 6, -NUDGE); ph:SetPoint("RIGHT", -4, -NUDGE); ph:SetText(opts.placeholder); ph:SetWordWrap(false)
    local function upd() ph:SetShown((e:GetText() or "") == "") end
    e:HookScript("OnTextChanged", upd); e:HookScript("OnShow", upd)
    local set = e.SetText
    function e:SetText(t) set(self, t); upd() end
    e.placeholder = ph
  end
  e:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  e:SetScript("OnEscapePressed", function(self) self._escape = true; self:ClearFocus() end)
  e:SetScript("OnEditFocusLost", function(self)
    if self._escape then self._escape = nil; if opts.revert then opts.revert(self) end; return end
    if opts.commit then opts.commit(self:GetText() or "") end
  end)
  UI.tabbable(e)
  function e:setEnabled(on) self:SetEnabled(on and true or false); self:SetAlpha(on and 1 or DIM) end
  -- a caller that re-insets the field keeps the nudge
  local si = e.SetTextInsets
  function e:SetTextInsets(l, r) si(self, l, r, NUDGE, 0) end
  return e
end

-- UI.gDial(parent, opts) — the mocks' dial: a Sansation 10 label, and 4 under it
-- 21 violet ticks, 1 wide and 16 tall at a pitch of 5 — the one nearest the
-- value WHITE — then, 10 on, the value box (violet 30%, Sansation 10 white)
-- filling the rest of `w` (170, a column). 31 tall; 16 with `bare` (no label).
-- Same behavior as every dial in the suite: press on the ticks and pull (keep
-- going past them), Shift ×10, click the number to type (↑/↓ step it there).
--   opts = { get, set, min, max, step, unit, fmt, dragPx, label, bare, w, nobox }
function UI.gDial(parent, opts)
  local minV, maxV, step = opts.min or 0, opts.max or 100, opts.step or 1
  local unit = opts.unit or ""
  local dragPx = opts.dragPx or 900
  local decimals = 0
  do local s = step; while s % 1 ~= 0 and decimals < 3 do s = s * 10; decimals = decimals + 1 end end
  local function fmt(v)
    if opts.fmt then return opts.fmt(v) end
    return decimals == 0 and tostring(math.floor(v + 0.5)) or ("%." .. decimals .. "f"):format(v)
  end
  local function snap(v)
    v = math.max(minV, math.min(maxV, v))
    if step > 0 then v = minV + math.floor((v - minV) / step + 0.5) * step end
    return math.max(minV, math.min(maxV, v))
  end
  local bare = opts.bare and true or false
  local W = opts.w or 170
  local TOP = bare and 0 or 15   -- the label's box (11) + 4
  local f = CreateFrame("Frame", nil, parent)
  f:SetSize(W, TOP + 16)
  f.label = UI.gLabel(f, bare and "" or (opts.label or "")); f.label:SetPoint("TOPLEFT", 0, 0)
  local strip = CreateFrame("Frame", nil, f)
  strip:SetPoint("TOPLEFT", 0, -TOP); strip:SetSize(101, 16)
  strip:EnableMouse(true)
  local ticks = {}
  for i = 0, 20 do
    local t = strip:CreateTexture(nil, "ARTWORK")
    t:SetPoint("TOPLEFT", i * 5, 0); t:SetSize(1, 16)
    ticks[i] = t
  end
  f.strip = strip
  local box = CreateFrame("EditBox", nil, f); box:SetAutoFocus(false); box:SetHeight(16)
  UI.setFont(box, FONT.sa, 10); box:SetTextColor(1, 1, 1); box:SetJustifyH("CENTER")
  local bbg = box:CreateTexture(nil, "BACKGROUND"); bbg:SetAllPoints(); rgba(bbg, COLOR.violet, 0.3)
  box:SetTextInsets(4, 4, NUDGE, 0)
  box:SetPoint("TOPLEFT", f, "TOPLEFT", 111, -TOP); box:SetWidth(math.max(20, W - 111))
  f.box = box
  if opts.nobox then box:Hide(); f:SetWidth(101) end

  local cur, enabled = snap(opts.get() or minV), true
  local editing, dragging = false, false
  local function paint()
    local frac = (maxV > minV) and ((cur - minV) / (maxV - minV)) or 0
    local idx = math.floor(frac * 20 + 0.5)
    for i = 0, 20 do
      local c = (i == idx) and COLOR.paper or COLOR.violet
      ticks[i]:SetColorTexture(c.r, c.g, c.b, 1)
    end
    if not editing then box:SetText(fmt(cur) .. unit); box:SetCursorPosition(0) end
  end
  local function apply(v)
    v = snap(v)
    if v ~= cur then cur = v; opts.set(v) end
    paint()
  end
  local function dropBoxFocus()
    if editing then editing = false; box._abandon = true; box:ClearFocus() end
  end
  strip:SetScript("OnMouseDown", function(self)
    if not enabled then return end
    dropBoxFocus()
    dragging = true
    self._drag = { x = GetCursorPosition() / self:GetEffectiveScale(), v = cur }
    paint()
  end)
  local function endDrag(self)
    if not dragging then return end
    dragging = false; self._drag = nil
    paint()
  end
  strip:SetScript("OnMouseUp", endDrag)
  strip:SetScript("OnUpdate", function(self)
    local d = self._drag
    if not d then return end
    if not IsMouseButtonDown("LeftButton") then endDrag(self); return end
    local x = GetCursorPosition() / self:GetEffectiveScale()
    local units = (x - d.x) * ((maxV - minV) / dragPx) * (IsShiftKeyDown() and 10 or 1)
    apply(d.v + units)
  end)
  -- ★ NO mouse wheel on a dial (the owner, 2026-09-27): scrolling the window
  -- past one changed its value by accident. The wheel only ever scrolls; with
  -- it off here, it falls through to the scroll area underneath. Stepping is
  -- the arrow keys in the number box (Shift ×10).
  strip:EnableMouseWheel(false); box:EnableMouseWheel(false)
  -- ↑ / ↓ in the number box: from the number TYPED, if there is one
  box:SetScript("OnArrowPressed", function(self, key)
    if not enabled or (key ~= "UP" and key ~= "DOWN") then return end
    local typed = tonumber((self:GetText() or ""):match("[-%d%.]+"))
    apply((typed or cur) + (key == "UP" and 1 or -1) * step * (IsShiftKeyDown() and 10 or 1))
    self:SetText(fmt(cur)); self:HighlightText()
  end)
  UI.attachTip(strip, opts.label or "", "Press anywhere on the ticks and pull — keep going past them if you like; the full range is a long drag, Shift is ×10. Click the number to type one; the arrow keys step it there (Shift ×10).")
  box:SetScript("OnEditFocusGained", function(self) editing = true; self:SetText(fmt(cur)); self:HighlightText() end)
  box:SetScript("OnEditFocusLost", function(self)
    editing = false
    if self._abandon then self._abandon = nil; paint(); return end
    local v = tonumber((self:GetText() or ""):match("[-%d%.]+"))
    if v then apply(v) else paint() end
  end)
  box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  UI.tabbable(box)
  box:SetScript("OnEscapePressed", function(self) self:SetText(fmt(cur)); self:ClearFocus() end)

  function f:refresh() cur = snap(opts.get() or minV); paint() end
  function f:setEnabled(on)
    enabled = on and true or false
    box:SetEnabled(enabled)
    self:SetAlpha(enabled and 1 or DIM)
  end
  paint()
  return f
end

-- UI.gCheck(parent, label?, get, set, size?) — the checkbox: 16 square, violet
-- 10% inside a violet hairline, a white tick; the label (Sansation 10, or
-- `size`) 8 right of the box. The whole row is the hit area.
function UI.gCheck(parent, label, get, set, size)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(16, 16)
  local fill = b:CreateTexture(nil, "BACKGROUND"); fill:SetPoint("TOPLEFT"); fill:SetSize(16, 16)
  rgba(fill, COLOR.violet, 0.1)
  local box = CreateFrame("Frame", nil, b); box:SetPoint("TOPLEFT"); box:SetSize(16, 16)
  b.edges = outline(box, COLOR.violet)
  local tick = b:CreateTexture(nil, "ARTWORK"); tick:SetTexture(UI.G_CHECK); tick:SetPoint("TOPLEFT"); tick:SetSize(16, 16)
  b.tick = tick
  if label and label ~= "" then
    b.label = UI.gLabel(b, label, size); b.label:SetPoint("LEFT", b, "LEFT", 24, 0)
    b:SetWidth(24 + math.ceil(b.label:GetStringWidth()))
  end
  local enabled = true
  function b:refresh() tick:SetShown(get() and true or false) end
  function b:setEnabled(on) enabled = on and true or false; self:SetAlpha(enabled and 1 or DIM) end
  b:SetScript("OnClick", function()
    if not enabled then return end
    set(not get()); b:refresh()
  end)
  b:refresh()
  return b
end

-- UI.gPill(parent, w) — a color PILL (the mocks' swatch): `w` wide, 16 tall,
-- round ends, the color inside a 1-unit white 40% line; with no color it is
-- just that line, DOTTED. :SetColor(c | nil).
local PILL_FILL = lib.MEDIA .. "ui\\g-pill-fill.png"
local PILL_RING = lib.MEDIA .. "ui\\g-pill-ring.png"
local PILL_DASH = lib.MEDIA .. "ui\\g-pill-dash.png"
function UI.gPill(parent, w)
  local p = CreateFrame("Button", nil, parent); p:SetSize(w, 16)
  local function piece(layer, file, left)
    local t = p:CreateTexture(nil, layer); t:SetTexture(file); t:SetSize(8, 16)
    if left then t:SetPoint("TOPLEFT", 0, 0); t:SetTexCoord(0, 1, 0, 1)
    else t:SetPoint("TOPRIGHT", 0, 0); t:SetTexCoord(1, 0, 0, 1) end
    return t
  end
  p.fl, p.fr = piece("BACKGROUND", PILL_FILL, true), piece("BACKGROUND", PILL_FILL, false)
  p.fm = p:CreateTexture(nil, "BACKGROUND"); p.fm:SetPoint("TOPLEFT", 8, 0); p.fm:SetPoint("BOTTOMRIGHT", -8, 0)
  p.rl, p.rr = piece("BORDER", PILL_RING, true), piece("BORDER", PILL_RING, false)
  p.dl, p.dr = piece("BORDER", PILL_DASH, true), piece("BORDER", PILL_DASH, false)
  local function line(top)
    local t = p:CreateTexture(nil, "BORDER"); t:SetHeight(1)
    t:SetPoint(top and "TOPLEFT" or "BOTTOMLEFT", 8, 0); t:SetPoint(top and "TOPRIGHT" or "BOTTOMRIGHT", -8, 0)
    return t
  end
  p.lt, p.lb = line(true), line(false)
  -- The straight runs of the dotted line (the owner, 2026-09-27: 1-unit DOTS,
  -- were 2-unit dashes): one 1 x 1 square per dot, 3 apart, the first and last
  -- 3 on from the end caps' last dots (1.5 units before the cap meets the run).
  -- A tiled texture stretched its marks in game, so nothing here tiles.
  p.dashes = { p.dl, p.dr }
  local span = math.max(0, w - 19)                    -- first dot's centre (9.5) to the last's
  local n = math.floor(span / 3) + 1
  local x0 = 9 + (span - 3 * (n - 1)) / 2             -- the first dot's left edge
  for i = 0, n - 1 do
    for _, top in ipairs({ true, false }) do
      local t = p:CreateTexture(nil, "BORDER"); t:SetSize(1, 1)
      t:SetPoint(top and "TOPLEFT" or "BOTTOMLEFT", x0 + 3 * i, 0)
      t:SetColorTexture(1, 1, 1, 0.4)
      p.dashes[#p.dashes + 1] = t
    end
  end
  function p:SetColor(c)
    local has = c ~= nil
    for _, t in ipairs({ self.fl, self.fr, self.fm, self.rl, self.rr, self.lt, self.lb }) do t:SetShown(has) end
    for _, t in ipairs(self.dashes) do t:SetShown(not has) end
    if has then
      local r, g, b = c[1] or c.r or 1, c[2] or c.g or 1, c[3] or c.b or 1
      self.fl:SetVertexColor(r, g, b, 1); self.fr:SetVertexColor(r, g, b, 1); self.fm:SetColorTexture(r, g, b, 1)
      self.rl:SetVertexColor(1, 1, 1, 0.4); self.rr:SetVertexColor(1, 1, 1, 0.4)
      self.lt:SetColorTexture(1, 1, 1, 0.4); self.lb:SetColorTexture(1, 1, 1, 0.4)
    else
      self.dl:SetVertexColor(1, 1, 1, 0.4); self.dr:SetVertexColor(1, 1, 1, 0.4)
    end
  end
  p:SetColor(nil)
  return p
end

-- UI.gColor(parent, opts) — a color control as the mocks draw it: the checkbox
-- and, 8 right of it, the PILL stretched to the rest of `w` (170). Ticking opens
-- the picker; unticking clears the color; clicking the pill opens the picker.
-- `required` drops the checkbox. `dot` draws the old 15px disc instead of the
-- pill (the Glows table keeps its small discs).
--   opts = { get, set, title, hasAlpha, w, required, dot }
function UI.gColor(parent, opts)
  if opts.dot then
    opts.accent, opts.dot, opts.gap, opts.classSource = COLOR.violet, 15, 24, true
    opts.disc, opts.discNo = UI.G_DISC, UI.G_DISC_NO
    local f = UI.colorDot(parent, opts)
    local se = f.setEnabled
    function f:setEnabled(on) se(self, on); self:SetAlpha(on and 1 or DIM) end
    if f.check then
      f.check.tick:SetTexture(UI.G_CHECK)
      local e = f.check.edges
      if e then UI.gHair(e.top, "h"); UI.gHair(e.bottom, "h"); UI.gHair(e.left, "w"); UI.gHair(e.right, "w") end
    end
    return f
  end
  local W = opts.w or 170
  local f = CreateFrame("Frame", nil, parent); f:SetSize(W, 16)
  local chk
  local openPicker
  local x = 0
  if not opts.required then
    chk = UI.gCheck(f, nil, function() return opts.get() ~= nil end, function(on)
      if on then openPicker() else opts.set(nil); f:refresh() end
    end)
    chk:SetPoint("TOPLEFT", 0, 0)
    x = 24
  end
  local pill = UI.gPill(f, W - x); pill:SetPoint("TOPLEFT", x, 0)
  f.check, f.pill = chk, pill
  local enabled = true
  function f:refresh()
    local c = opts.get()
    if c and UI.NoteColor then UI.NoteColor(c) end
    pill:SetColor(c)
    if chk then chk:refresh() end
  end
  openPicker = function()
    if not enabled then return end
    UI.pickColorWithClass(opts, pill, (opts.title or "Color"):upper(), function() f:refresh() end)
  end
  pill:SetScript("OnClick", openPicker)
  function f:setEnabled(on)
    enabled = on and true or false
    if chk then chk:setEnabled(enabled); chk:SetAlpha(1) end
    pill:SetEnabled(enabled)
    self:SetAlpha(enabled and 1 or DIM)
  end
  f:refresh()
  return f
end

-- UI.gX(parent, onClick) — a row's remove X: a 9px violet X in a 23 x 23 hit
-- area; lilac under the mouse.
function UI.gX(parent, onClick)
  local b = CreateFrame("Button", nil, parent); b:SetSize(23, 23)
  local t = b:CreateTexture(nil, "ARTWORK"); t:SetTexture(UI.G_X); t:SetTexCoord(0, 9 / 16, 0, 9 / 16)
  t:SetSize(9, 9); t:SetPoint("CENTER", 0, 0); UI.tint(t, COLOR.violet)
  b:SetScript("OnEnter", function() UI.tint(t, COLOR.lilac) end)
  b:SetScript("OnLeave", function() UI.tint(t, COLOR.violet) end)
  if onClick then b:SetScript("OnClick", onClick) end
  b.icon = t
  return b
end

-- UI.gScroll(parent, opts) — UI.scrollPane in the glass palette (the bar exists
-- only while the content overflows).
function UI.gScroll(parent, opts)
  opts = opts or {}
  opts.accent = COLOR.violet
  return UI.scrollPane(parent, opts)
end

-- UI.gProfileBar(parent, api, mark) — the top bar's profile control (the mocks'
-- "Frame 414"): "gloom" + the tool's name in lilac + " profile:" in Michroma
-- 12; 10 on, a 210 x 18 picker (near-black, a violet 30% outline, Saira 11,
-- the violet ▾); 10 on, NEW · COPY · RENAME · DELETE, 10 apart. Same `api`,
-- dialogs and delete gate as every other profile control. An error shows in
-- coral under the row. Returns { frame, refresh, note, dropdown }.
function UI.gProfileBar(parent, api, mark)
  local noun = api.noun or "profile"
  local st = {}
  local f = CreateFrame("Frame", nil, parent); f:SetSize(600, 18)
  st.frame = f
  local who = UI.newText(f, FONT.mark, 12, COLOR.paper, "LEFT")
  who:SetPoint("LEFT", 0, 0)
  who:SetText(("gloom|cff%s%s|r %s:"):format(hexOf(COLOR.lilac), mark or "", noun))
  local note = UI.newText(f, FONT.sa, 11, COLOR.coral, "LEFT")
  note:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, -4)
  function st:note(text) note:SetText(text or "") end

  local dd = CreateFrame("Button", nil, f); dd:SetSize(210, 18)
  dd:SetPoint("LEFT", who, "RIGHT", 10, 0)
  local dbg = dd:CreateTexture(nil, "BACKGROUND"); dbg:SetAllPoints(); rgba(dbg, COLOR.void)
  local dhl = dd:CreateTexture(nil, "BORDER"); dhl:SetAllPoints(); rgba(dhl, COLOR.violet, 0.15); dhl:Hide()
  outline(dd, COLOR.violet, 0.3)
  dd.text = UI.newText(dd, FONT.sa, 11, COLOR.paper, "LEFT")
  dd.text:SetPoint("LEFT", 6, -NUDGE); dd.text:SetPoint("RIGHT", -18, -NUDGE); dd.text:SetWordWrap(false)
  local tri = caret(dd); tri:SetSize(9, 7); tri:SetPoint("RIGHT", -6, 0)
  function dd:refresh() self.text:SetText(api.active() or "") end
  dd:SetScript("OnEnter", function() dhl:Show() end)
  dd:SetScript("OnLeave", function() dhl:Hide() end)
  local function after(ok, err)
    if ok then st:note(""); dd:refresh(); if api.onChange then api.onChange() end
    else st:note(err or "") end
  end
  dd:SetScript("OnClick", function(self)
    local out = {}
    for _, name in ipairs(api.names() or {}) do out[#out + 1] = { value = name, label = name } end
    UI.gList(self, out, api.active(), function(val)
      st:note(""); api.switch(val); self:refresh(); if api.onChange then api.onChange() end
    end, { upper = false })
  end)
  st.dropdown = dd

  local act = profileActions(api, after)
  local prev = dd
  local function btn(label, handler, danger)
    local b = UI.gButton(f, label, { onClick = handler, danger = danger })
    b:SetPoint("LEFT", prev, "RIGHT", 10, 0)
    prev = b
    return b
  end
  local bNew = btn("New", act.new)
  local bCopy = (type(api.copy) == "function") and btn("Copy", act.copy) or nil
  local bRen = btn("Rename", act.rename)
  local bDel = btn("Delete", act.delete, true)
  profileTips(api, dd, bNew, bCopy, bRen, bDel)
  function st:refresh() dd:refresh() end
  dd:refresh()
  return st
end


-- ============================================================
-- THE TWO-WINDOW KIT, part 2 — the windows themselves (MINOR 16).
-- ============================================================

-- UI.gRounded(host, opts) — a rounded rectangle drawn from the corner art: four
-- quarter discs and three rectangles that never overlap, so a translucent fill
-- stays even. Any corner can be square (`corners`), and the fill can be a
-- VERTICAL GRADIENT (`top`/`bottom` colors, each {r,g,b,a}): every piece gets the
-- slice of the ramp it covers, so the corners blend exactly. Returns a handle:
-- :Place(x, y, w, h) in host units from its top-left, :SetShown(on).
--   opts = { radius (20), layer, sub, color = {r,g,b,a} | top/bottom,
--            corners = { tl, tr, bl, br } (all true by default) }
local function mix(a, b, t)
  return a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t, (a[4] or 1) + ((b[4] or 1) - (a[4] or 1)) * t
end
function UI.gRounded(host, opts)
  opts = opts or {}
  local R = opts.radius or 20
  local layer, sub = opts.layer or "BACKGROUND", opts.sub or 0
  local top = opts.top or opts.color or { 0, 0, 0, 1 }
  local bot = opts.bottom or opts.color or top
  local cn = opts.corners or { tl = true, tr = true, bl = true, br = true }
  local h = { parts = {} }
  local function tex(round)
    local t = host:CreateTexture(nil, layer, nil, sub)
    if round then t:SetTexture(UI.G_CORNER) end
    h.parts[#h.parts + 1] = t
    return t
  end
  -- corner pieces (a square corner is a plain rectangle in the same place)
  h.tl, h.tr, h.bl, h.br = tex(cn.tl), tex(cn.tr), tex(cn.bl), tex(cn.br)
  if cn.tl then h.tl:SetTexCoord(0, CT, 0, CT) end
  if cn.tr then h.tr:SetTexCoord(CT, 0, 0, CT) end
  if cn.bl then h.bl:SetTexCoord(0, CT, CT, 0) end
  if cn.br then h.br:SetTexCoord(CT, 0, CT, 0) end
  h.top, h.mid, h.bot = tex(false), tex(false), tex(false)
  local function paint(t, round, y0, y1, H)
    local r1, g1, b1, a1 = mix(top, bot, H > 0 and y0 / H or 0)
    local r2, g2, b2, a2 = mix(top, bot, H > 0 and y1 / H or 1)
    if round then t:SetVertexColor(1, 1, 1, 1) else t:SetColorTexture(1, 1, 1, 1) end
    if t.SetGradient and CreateColor then
      t:SetGradient("VERTICAL", CreateColor(r2, g2, b2, a2), CreateColor(r1, g1, b1, a1))
    else
      if round then t:SetVertexColor(r1, g1, b1, a1) else t:SetColorTexture(r1, g1, b1, a1) end
    end
  end
  function h:Place(x, y, w, hh)
    local r = math.min(R, math.floor(math.min(w, hh) / 2))
    local function at(t, tx, ty, tw, th)
      t:ClearAllPoints(); t:SetPoint("TOPLEFT", host, "TOPLEFT", tx, -ty); t:SetSize(math.max(0.01, tw), math.max(0.01, th))
    end
    at(self.tl, x, y, r, r);                 at(self.tr, x + w - r, y, r, r)
    at(self.bl, x, y + hh - r, r, r);        at(self.br, x + w - r, y + hh - r, r, r)
    at(self.top, x + r, y, w - 2 * r, r);    at(self.bot, x + r, y + hh - r, w - 2 * r, r)
    at(self.mid, x, y + r, w, hh - 2 * r)
    paint(self.tl, cn.tl, 0, r, hh); paint(self.tr, cn.tr, 0, r, hh); paint(self.top, false, 0, r, hh)
    paint(self.mid, false, r, hh - r, hh)
    paint(self.bl, cn.bl, hh - r, hh, hh); paint(self.br, cn.br, hh - r, hh, hh); paint(self.bot, false, hh - r, hh, hh)
  end
  function h:SetShown(on) for _, t in ipairs(self.parts) do t:SetShown(on) end end
  return h
end

-- The close disc (the mocks' "Close Button"): lime, 16, the X cut out of it.
function UI.gCloseDisc(parent, onClick)
  local b = CreateFrame("Button", nil, parent); b:SetSize(16, 16)
  local t = b:CreateTexture(nil, "ARTWORK"); t:SetTexture(UI.G_CLOSE); t:SetTexCoord(0, 23 / 32, 0, 23 / 32)
  t:SetPoint("TOPLEFT", 0.67, -0.67); t:SetSize(13.9, 13.9); UI.tint(t, COLOR.lime)
  b:SetScript("OnEnter", function() t:SetVertexColor(1, 1, 1, 1) end)
  b:SetScript("OnLeave", function() UI.tint(t, COLOR.lime) end)
  if onClick then b:SetScript("OnClick", onClick) end
  b.icon = t
  return b
end

-- UI.gSectionHead(parent, title, opts) — a section's header row in a settings
-- window: the lime triangle (▸ closed, ▾ open), 6 on the title in Sansation 14,
-- 6 on the lime POP-OUT icon (7.5). In a popped-out window (`popped`) there is
-- no triangle and the POP-IN icon sits first, at the left. 14 tall.
--   opts = { popped, onToggle(), onPop() } → Button with :SetOpen(on), .title, .pop
function UI.gSectionHead(parent, title, opts)
  opts = opts or {}
  local b = CreateFrame("Button", nil, parent); b:SetHeight(14)
  b.title = UI.newText(b, FONT.sa, 14, COLOR.paper, "LEFT"); b.title:SetText(title or ""); b.title:SetWordWrap(false)
  local pop = CreateFrame("Button", nil, b); pop:SetSize(11, 11)
  local pt = pop:CreateTexture(nil, "ARTWORK"); pt:SetSize(8.5, 8.5); pt:SetPoint("CENTER", 0, 0)
  pt:SetTexture(opts.popped and UI.G_POPIN or UI.G_POPOUT); pt:SetTexCoord(0, 34 / 64, 0, 34 / 64); UI.tint(pt, COLOR.lime)
  pop:SetScript("OnEnter", function() pt:SetVertexColor(1, 1, 1, 1) end)
  pop:SetScript("OnLeave", function() UI.tint(pt, COLOR.lime) end)
  pop:SetScript("OnClick", function() if opts.onPop then opts.onPop() end end)
  UI.attachTip(pop, opts.popped and "Put back" or "Pop out", opts.popped
    and "Returns this section to the main settings window."
    or "Opens this section in a window of its own, so you can keep it beside the others.")
  b.pop = pop
  local tw = math.ceil(b.title:GetStringWidth())
  if opts.popped then
    pop:SetPoint("LEFT", -1.75, 0)
    b.title:SetPoint("LEFT", 13.5, 0)
    b:SetWidth(13.5 + tw)
  else
    b.tri = b:CreateTexture(nil, "ARTWORK"); b.tri:SetTexture(UI.G_TRI); b.tri:SetSize(7, 6); UI.tint(b.tri, COLOR.lime)
    b.tri:SetPoint("CENTER", b, "LEFT", 4, 0)
    b.title:SetPoint("LEFT", 14, 0)
    pop:SetPoint("LEFT", 14 + tw + 6 - 1.75, 0)
    b:SetWidth(14 + tw)
    b:SetScript("OnClick", function() if opts.onToggle then opts.onToggle() end end)
  end
  function b:SetOpen(on) if self.tri then self.tri:SetRotation(on and 0 or (math.pi / 2)) end end
  -- a title that changes (Unit Frames' "Global Player / Target Settings")
  function b:SetTitle(t)
    self.title:SetText(t or "")
    local w2 = math.ceil(self.title:GetStringWidth())
    pop:ClearAllPoints()
    if opts.popped then pop:SetPoint("LEFT", -1.75, 0); self:SetWidth(13.5 + w2)
    else pop:SetPoint("LEFT", 14 + w2 + 6 - 1.75, 0); self:SetWidth(14 + w2) end
  end
  b:SetOpen(false)
  return b
end

-- UI.gScrollArea(parent, opts) — the settings windows' scrolling body: a clip
-- the size of `parent` (a window's body, W wide), a content frame W wide, the
-- mocks' FADES (the top 86 black → clear, the bottom 86 clear → the body's
-- color, each with the body's round corners) shown only while there is more
-- to see that way, and the SCROLLBAR — a 3-wide round track (black 50%) at
-- x W - 8, from 34 under the top to 46 over the bottom, its thumb violet 30% —
-- only while the content overflows. Whole-unit offsets (whole pixels).
--   → { frame, child, SetContentHeight(h), ScrollTo(y), GetScroll(), Update() }
function UI.gScrollArea(parent, opts)
  opts = opts or {}
  local sa = {}
  local sf = CreateFrame("ScrollFrame", nil, parent)
  sf:SetAllPoints(parent); sf:EnableMouseWheel(true)
  if sf.SetClipsChildren then sf:SetClipsChildren(true) end
  local child = CreateFrame("Frame", nil, sf); child:SetSize(parent:GetWidth(), 10)
  sf:SetScrollChild(child)
  sa.frame, sa.child = sf, child
  local over = CreateFrame("Frame", nil, parent); over:SetAllPoints(parent)
  over:SetFrameLevel(sf:GetFrameLevel() + 20)
  local bodyBottom = opts.bottomColor or { COLOR.panel.r, COLOR.panel.g, COLOR.panel.b }
  local topFade = UI.gRounded(over, { layer = "OVERLAY", sub = -2, corners = { tl = true, tr = true },
    top = { 0, 0, 0, 1 }, bottom = { 0, 0, 0, 0 } })
  local botFade = UI.gRounded(over, { layer = "OVERLAY", sub = -2, corners = { bl = true, br = true },
    top = { bodyBottom[1], bodyBottom[2], bodyBottom[3], 0 }, bottom = { bodyBottom[1], bodyBottom[2], bodyBottom[3], 1 } })
  local track = CreateFrame("Frame", nil, over); track:SetWidth(3)
  local tr = UI.gRounded(track, { radius = 1.5, color = { 0, 0, 0, 0.5 } })
  local thumb = CreateFrame("Button", nil, track); thumb:SetWidth(3)
  local th = UI.gRounded(thumb, { radius = 1.5, color = { COLOR.violet.r, COLOR.violet.g, COLOR.violet.b, 0.3 }, layer = "ARTWORK" })
  local contentH, off = 10, 0
  local FADE = 86
  local function viewH() return parent:GetHeight() or 0 end
  local function maxOff() return math.max(0, math.floor(contentH - viewH() + 0.5)) end
  function sa:Update()
    local H, W = viewH(), parent:GetWidth() or 0
    child:SetWidth(W)
    local mo = maxOff()
    off = math.max(0, math.min(mo, math.floor(off + 0.5)))
    sf:SetVerticalScroll(off)
    local fh = math.min(FADE, math.floor(H / 2))
    topFade:Place(0, 0, W, fh); topFade:SetShown(off > 0)
    botFade:Place(0, H - fh, W, fh); botFade:SetShown(off < mo)
    if mo > 0 then
      local tTop, tLen = 34, math.max(20, H - 34 - 46)
      track:ClearAllPoints(); track:SetPoint("TOPLEFT", parent, "TOPLEFT", W - 9.5, -tTop); track:SetHeight(tLen)
      tr:Place(0, 0, 3, tLen)
      local thLen = math.max(24, math.floor(tLen * H / contentH + 0.5))
      thumb:SetHeight(thLen)
      thumb:ClearAllPoints(); thumb:SetPoint("TOPLEFT", 0, -math.floor((tLen - thLen) * off / mo + 0.5))
      th:Place(0, 0, 3, thLen)
      track:Show()
    else
      track:Hide()
    end
    if opts.onScroll then opts.onScroll(off) end
  end
  function sa:SetContentHeight(h) contentH = math.max(1, h); child:SetHeight(contentH); self:Update() end
  function sa:ScrollTo(y) off = y or 0; self:Update() end
  function sa:GetScroll() return off end
  sf:SetScript("OnMouseWheel", function(_, d) off = off - d * 40; sa:Update() end)
  parent:HookScript("OnSizeChanged", function() sa:Update() end)
  -- the thumb drags; a click on the track pages
  local dragging, y0, o0 = false, 0, 0
  thumb:SetScript("OnMouseDown", function(self)
    dragging = true; o0 = off
    local _, cy = GetCursorPosition(); y0 = cy / self:GetEffectiveScale()
  end)
  thumb:SetScript("OnMouseUp", function() dragging = false end)
  thumb:SetScript("OnUpdate", function(self)
    if not dragging then return end
    if not IsMouseButtonDown("LeftButton") then dragging = false; return end
    local range = track:GetHeight() - self:GetHeight()
    if range <= 0 then return end
    local _, cy = GetCursorPosition()
    off = o0 + (y0 - cy / self:GetEffectiveScale()) / range * maxOff()
    sa:Update()
  end)
  track:EnableMouse(true)
  track:SetScript("OnMouseDown", function()
    local _, cy = GetCursorPosition(); cy = cy / track:GetEffectiveScale()
    local mid = ((thumb:GetTop() or 0) + (thumb:GetBottom() or 0)) / 2
    off = off + ((cy > mid) and -1 or 1) * (viewH() - 40)
    sa:Update()
  end)
  sa.track, sa.thumb, sa.over = track, thumb, over
  sa:Update()
  return sa
end

-- UI.gWindow(opts) — one of the Suite's windows (the mocks' "Rectangle 272/279"):
-- `w` wide, a body with 20-unit round corners shaded black at the top to the
-- panel color at the bottom; the lime CLOSE disc floating 20 above its top-right
-- corner; the
-- lime RESIZE bar (159 × 4, round-ended) centered 5 under it, which drags the
-- window's HEIGHT; an optional TAB behind it (the aura's name / the preset),
-- #0f051d at 90% with round top corners, standing 28 above the body. The window
-- MOVES by dragging any empty part of the body or the tab (its words and
-- buttons keep their own clicks). Its corner snaps to the screen's pixels.
--   opts = { parent, w, h, minH, maxH, tabW, onClose(), onMoved(), onResized(), onFocus(win) }
--   → the window frame (the BODY's rect) with .content (the body's frame),
--     .tab (or nil), .close, .grip, :Snap(), :SetBodyHeight(h)
local function pxPerUnitOf(f)
  local _, ph = GetPhysicalScreenSize()
  return ((ph and ph > 0) and (ph / 768) or 1) * f:GetEffectiveScale()
end
function UI.gSnap(f)
  local l, t = f:GetLeft(), f:GetTop()
  if not (l and t) then return end
  local k = pxPerUnitOf(f)
  if k <= 0 then return end
  f:ClearAllPoints()
  f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", math.floor(l * k + 0.5) / k, math.floor(t * k + 0.5) / k)
end
function UI.gWindow(opts)
  local W, H = opts.w or 400, opts.h or 650
  local win = CreateFrame("Frame", opts.name, opts.parent or UIParent)
  win:SetSize(W, H)
  win:SetFrameStrata("DIALOG"); win:SetToplevel(false)
  win._gWin = true   -- the Tab ring's boundary (UI.tabbable)
  win:SetMovable(true); win:SetResizable(true); win:SetClampedToScreen(true)
  win:SetClampRectInsets(0, 0, opts.tabW and 28 or 20, -10)
  win:EnableMouse(true); win:RegisterForDrag("LeftButton")
  -- ★ Bringing a window forward is the OWNER's job (Windows.lua keeps every
  -- window in its own band of frame levels, so overlapping windows never mix);
  -- `onFocus` is how it hears about it. Alone, a window just raises itself.
  function win:Focus() if opts.onFocus then opts.onFocus(self) else self:Raise() end end
  win:HookScript("OnMouseDown", function(self) self:Focus() end)
  local minH, maxH = opts.minH or 160, opts.maxH or 2000
  -- the tab, behind the body
  if opts.tabW then
    local tab = CreateFrame("Frame", nil, win)
    tab:SetFrameLevel(win:GetFrameLevel() + 1)
    tab:SetPoint("BOTTOMLEFT", win, "TOPLEFT", 0, -24); tab:SetSize(opts.tabW, 52)
    local tp = UI.gRounded(tab, { color = { COLOR.panel.r, COLOR.panel.g, COLOR.panel.b, 0.9 }, corners = { tl = true, tr = true } })
    tp:Place(0, 0, opts.tabW, 52)
    tab:EnableMouse(true); tab:RegisterForDrag("LeftButton")
    tab:SetScript("OnDragStart", function() win:StartMoving() end)
    tab:SetScript("OnDragStop", function() win:StopMovingOrSizing(); UI.gSnap(win); if opts.onMoved then opts.onMoved() end end)
    tab:HookScript("OnMouseDown", function() win:Focus() end)
    win.tab = tab
    function win:SetTabWidth(tw) tab:SetWidth(tw); tp:Place(0, 0, tw, 52) end
  end
  local body = CreateFrame("Frame", nil, win)
  body:SetAllPoints(win); body:SetFrameLevel(win:GetFrameLevel() + 3)
  local bg = UI.gRounded(body, { top = { 0, 0, 0, 1 }, bottom = { COLOR.panel.r, COLOR.panel.g, COLOR.panel.b, 1 }, layer = "BACKGROUND", sub = -8 })
  win.content = body
  local function repaint() bg:Place(0, 0, W, win:GetHeight() or H) end
  win:HookScript("OnSizeChanged", repaint)
  repaint()
  win:SetScript("OnDragStart", function(self) self:StartMoving() end)
  win:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); UI.gSnap(self); if opts.onMoved then opts.onMoved() end end)
  -- close
  local close = UI.gCloseDisc(win, function() if opts.onClose then opts.onClose() else win:Hide() end end)
  close:SetFrameLevel(body:GetFrameLevel() + 40)
  -- floating 20 above the body's top-right corner, beside the tab when there is
  -- one (the owner moved them all up 20, 2026-09-27)
  close:SetPoint("BOTTOMRIGHT", win, "TOPRIGHT", 0, 4)
  win.close = close
  -- the resize bar
  local grip = CreateFrame("Button", nil, win); grip:SetSize(200, 14)
  grip:SetPoint("CENTER", win, "BOTTOM", 0, -5)
  grip:SetFrameLevel(body:GetFrameLevel() + 40)
  local gv = CreateFrame("Frame", nil, grip); gv:SetSize(159, 4); gv:SetPoint("CENTER", 0, 0)
  UI.gRounded(gv, { radius = 2, color = { COLOR.lime.r, COLOR.lime.g, COLOR.lime.b, 1 }, layer = "ARTWORK" }):Place(0, 0, 159, 4)
  grip:SetScript("OnEnter", function() gv:SetAlpha(0.8) end)
  grip:SetScript("OnLeave", function() gv:SetAlpha(1) end)
  UI.attachTip(grip, "Height", "Drag up or down to make this window shorter or taller.")
  local sizing
  grip:SetScript("OnMouseDown", function(self)
    local _, cy = GetCursorPosition()
    sizing = { y = cy / win:GetEffectiveScale(), h = win:GetHeight() }
    win:Focus()
  end)
  local function stopSizing()
    if not sizing then return end
    sizing = nil
    UI.gSnap(win)
    if opts.onResized then opts.onResized() end
  end
  grip:SetScript("OnMouseUp", stopSizing)
  grip:SetScript("OnUpdate", function()
    if not sizing then return end
    if not IsMouseButtonDown("LeftButton") then stopSizing(); return end
    local _, cy = GetCursorPosition()
    local nh = sizing.h + (sizing.y - cy / win:GetEffectiveScale())
    nh = math.floor(math.max(minH, math.min(maxH, nh)) + 0.5)
    if nh ~= win:GetHeight() then win:SetHeight(nh) end
  end)
  win.grip = grip
  function win:Snap() UI.gSnap(self) end
  function win:SetLimits(lo, hi) minH, maxH = lo or minH, hi or maxH end
  return win
end

-- UI.gProfileBlock(parent, api, title, w) — Global Settings' profile control
-- for one tool (the mocks' Frame 543): "<title>" (Sansation 10), 4 under it the
-- active profile as a dropdown stretched to `w`, and 10 under that New · Copy ·
-- Rename · Delete, 6 apart (16 tall, 10 each side). Same api, dialogs and delete
-- gate as every profile control in the suite. 57 tall. Returns { frame, refresh, note }.
function UI.gProfileBlock(parent, api, title, w)
  local st = {}
  local f = CreateFrame("Frame", nil, parent); f:SetSize(w, 57)
  st.frame = f
  UI.gLabel(f, title):SetPoint("TOPLEFT", 0, 0)
  local note = UI.newText(f, FONT.sa, 10, COLOR.coral, "LEFT")
  note:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -1)
  function st:note(text) note:SetText(text or "") end
  local dd
  local function after(ok, err)
    if ok then st:note(""); dd:refresh(); if api.onChange then api.onChange() end
    else st:note(err or "") end
  end
  dd = UI.gDrop(f, w, function() return api.active() end,
    function()
      local out = {}
      for _, name in ipairs(api.names() or {}) do out[#out + 1] = { value = name, label = name } end
      return out
    end,
    function() return api.active() end,
    function(val) st:note(""); api.switch(val); if api.onChange then api.onChange() end end)
  dd:SetPoint("TOPLEFT", 0, -15)
  local act = profileActions(api, after)
  local prev
  local function btn(label, handler, danger)
    local b = UI.gButton(f, label, { onClick = handler, danger = danger, h = 16, pad = 10 })
    if prev then b:SetPoint("LEFT", prev, "RIGHT", 6, 0) else b:SetPoint("TOPLEFT", 0, -41) end
    prev = b
    return b
  end
  local bNew = btn("New", act.new)
  local bCopy = (type(api.copy) == "function") and btn("Copy", act.copy) or nil
  local bRen = btn("Rename", act.rename)
  local bDel = btn("Delete", act.delete, true)
  profileTips(api, dd, bNew, bCopy, bRen, bDel)
  function st:refresh() dd:refresh() end
  dd:refresh()
  return st
end

end   -- if lib

-- ------------------------------------------------------------
-- Hub-side aliases — the names the Hub's own files use. These
-- always point at the LIVE lib (whichever copy won LibStub's
-- newest-wins), not necessarily the tables built above.
-- ------------------------------------------------------------
local Skin = LibStub(MAJOR)
GloomsHub.COLOR = Skin.COLOR
GloomsHub.FONT  = Skin.FONT
GloomsHub.UI    = Skin.UI
GloomsHub.MEDIA = Skin.MEDIA
