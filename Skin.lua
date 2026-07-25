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

local MAJOR, MINOR = "LibGloomSkin-1.0", 4   -- MINOR 4 (2026-07-25): + tabHeader (the shared per-tab mark + wordmark)
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
  rim    = { r = 1, g = 1, b = 1, a = 0.10 },
  -- Promoted from GB Config.lua locals (TEXT/MUTE) — now tokens.
  text   = { r = 0.90, g = 0.92, b = 0.96 },   -- body text
  mute   = { r = 0.55, g = 0.57, b = 0.63 },   -- hints / secondary
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

function UI.setFont(fs, path, size, flags)
  if not fs:SetFont(path, size, flags or "") then fs:SetFont(DEFAULT_FONT, size, flags or "") end
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

-- Flat dark fill (renders #060714 on screen; the pre-compensated token above).
function UI.skinPlate(f)
  local base = f:CreateTexture(nil, "BACKGROUND")
  base:SetAllPoints()
  base:SetColorTexture(COLOR.dark.r, COLOR.dark.g, COLOR.dark.b, COLOR.dark.a or 1)
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
  end
  b:SetScript("OnEnter", function(self) if self:IsEnabled() and not self._active then self.fill:SetAlpha(math.min(1, self._base + 0.25)) end end)
  b:SetScript("OnLeave", function(self) paint() end)
  b:SetScript("OnDisable", function(self) self.fill:SetAlpha(0.2); self.text:SetTextColor(0.5, 0.5, 0.5) end)
  b:SetScript("OnEnable", function(self) paint(); self.text:SetTextColor(1, 1, 1) end)
  function b:SetActive(a) self._active = a and true or false; paint() end
  function b:SetBase(a) self._base = a; paint() end
  return b
end

-- Sliding on/off toggle — 40x20, white-10% track, square purple knob that snaps
-- flush-left (off) / flush-right (on). Position is the only state signal.
function UI.makeToggle(parent, get, set)
  local t = CreateFrame("Button", nil, parent)
  t:SetSize(40, 20)
  local track = t:CreateTexture(nil, "BACKGROUND"); track:SetAllPoints(); track:SetColorTexture(1, 1, 1, 0.10)
  local knob = t:CreateTexture(nil, "ARTWORK"); knob:SetSize(20, 20)
  knob:SetColorTexture(COLOR.purple.r, COLOR.purple.g, COLOR.purple.b, 1)
  function t:refresh() knob:ClearAllPoints(); knob:SetPoint(get() and "RIGHT" or "LEFT", 0, 0) end
  t:SetScript("OnClick", function() set(not get()); t:refresh() end)
  t:refresh()
  return t
end

-- Flat text input (the family pattern): no Blizzard template, faint purple
-- fill + brighter fill on focus, no border.
function UI.flatEditBox(parent, w, h)
  local e = CreateFrame("EditBox", nil, parent)
  e:SetSize(w, h); e:SetAutoFocus(false)
  UI.setFont(e, FONT.body, 12); e:SetTextColor(COLOR.text.r, COLOR.text.g, COLOR.text.b)
  e:SetTextInsets(6, 6, 0, 0)
  local bg = e:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints()
  bg:SetColorTexture(COLOR.purple.r, COLOR.purple.g, COLOR.purple.b, 0.10)
  e:SetScript("OnEditFocusGained", function() bg:SetColorTexture(COLOR.purple.r, COLOR.purple.g, COLOR.purple.b, 0.22) end)
  e:SetScript("OnEditFocusLost",  function() bg:SetColorTexture(COLOR.purple.r, COLOR.purple.g, COLOR.purple.b, 0.10) end)
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

-- Color swatch — a solid button that opens the game ColorPickerFrame (modern
-- SetupColorPickerAndShow API, with a fallback). get() → {r,g,b[,a]} array;
-- set(c) writes it. Returns { swatch, refresh }. Lifted verbatim from GB.
function UI.colorSwatch(parent, get, set, withAlpha)
  local sw = CreateFrame("Button", nil, parent); sw:SetSize(28, 20)
  local tex = sw:CreateTexture(nil, "ARTWORK"); tex:SetAllPoints()
  UI.addEdges(sw, COLOR.rim, 1)
  -- The swatch shows the hue at full opacity (its alpha lives on the target, e.g.
  -- the border) so a near-transparent colour stays visible/clickable here.
  local function update() local c = get() or { 1, 1, 1 }; tex:SetColorTexture(c[1] or 1, c[2] or 1, c[3] or 1, 1) end
  sw:SetScript("OnClick", function()
    local c = get() or { 1, 1, 1 }
    local function apply()
      local r, g, b = ColorPickerFrame:GetColorRGB()
      if withAlpha then
        local a = ColorPickerFrame.GetColorAlpha and ColorPickerFrame:GetColorAlpha() or 1
        set({ r, g, b, a })
      else
        set({ r, g, b })
      end
      update()
    end
    local info = { hasOpacity = withAlpha or false, opacity = withAlpha and (c[4] or 1) or nil,
      r = c[1], g = c[2], b = c[3], swatchFunc = apply, opacityFunc = apply }
    if ColorPickerFrame.SetupColorPickerAndShow then ColorPickerFrame:SetupColorPickerAndShow(info)
    else ColorPickerFrame.func = apply; ColorPickerFrame:SetColorRGB(c[1], c[2], c[3]); ColorPickerFrame:Show() end
  end)
  update()
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
function UI.makeScrollbar(parent, scroll, place)
  local sb = CreateFrame("Frame", nil, parent)
  place(sb); sb:SetWidth(4)
  local track = sb:CreateTexture(nil, "BACKGROUND"); track:SetAllPoints(); track:SetColorTexture(1, 1, 1, 0.06)
  local thumb = CreateFrame("Button", nil, sb); thumb:SetWidth(4); thumb:SetPoint("TOP", 0, 0)
  local thumbTex = thumb:CreateTexture(nil, "ARTWORK"); thumbTex:SetAllPoints()
  local ALPHA = 0.85
  thumbTex:SetColorTexture(COLOR.orange.r, COLOR.orange.g, COLOR.orange.b, ALPHA)
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
        row.hl:SetColorTexture(1, 1, 1, 0.07); row.hl:Hide()
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
      else row.text:SetTextColor(1, 1, 1) end
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
local nameDlg, confirmDlg

-- The scrim behind them (the owner, 2026-07-25). Both dialogs are plates in the
-- same near-black navy as the panel they open over, so without this they read as
-- part of the tab rather than on top of it. One scrim serves both: it dims
-- everything below and eats the clicks, which is what makes them actually modal.
-- Clicking it does NOT dismiss — the family answer is always an explicit choice
-- (OK / Cancel / ESC), never a click-somewhere-else that silently drops the edit.
local scrim

local function scrimShow(dlg)
  if not scrim then
    scrim = CreateFrame("Frame", nil, UIParent)
    scrim:SetAllPoints(UIParent)
    scrim:SetFrameStrata("FULLSCREEN_DIALOG")
    scrim:EnableMouse(true)
    local t = scrim:CreateTexture(nil, "BACKGROUND")
    t:SetAllPoints(scrim)
    t:SetColorTexture(0, 0, 0, 0.72)
    scrim:Hide()
  end
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

-- Text entry. onAccept(name) fires on OK / Enter; Cancel and ESC drop it.
function UI.nameDialog(titleText, initial, onAccept)
  if not nameDlg then
    local W, H = 300, 132
    local f = CreateFrame("Frame", "GloomSkinNameDialog", UIParent)
    f:SetSize(W, H); f:SetPoint("CENTER"); f:SetFrameStrata("FULLSCREEN_DIALOG"); f:EnableMouse(true)
    UI.skinPlate(f)
    f.title = UI.newText(f, FONT.title, 17, COLOR.purple, "CENTER")
    f.title:SetPoint("TOP", 0, -14)
    f.box = UI.flatEditBox(f, W - 48, 24); f.box:SetPoint("TOP", 0, -50)
    local okB = UI.flatButton(f, 100, 26, COLOR.purple, "OK", 13); okB:SetPoint("BOTTOMLEFT", 26, 16)
    local noB = UI.flatButton(f, 100, 26, COLOR.heroic, "Cancel", 13); noB:SetPoint("BOTTOMRIGHT", -26, 16)
    local function accept()
      local name = f.box:GetText()
      local cb = f.onAccept; f.onAccept = nil
      f:Hide()
      if cb then cb(name) end
    end
    local function cancel() f.onAccept = nil; f:Hide() end
    okB:SetScript("OnClick", accept)
    noB:SetScript("OnClick", cancel)
    f.box:SetScript("OnEnterPressed", accept)
    f.box:SetScript("OnEscapePressed", cancel)
    tinsert(UISpecialFrames, "GloomSkinNameDialog")   -- ESC closes it
    f:HookScript("OnHide", scrimHide)
    f:Hide()
    nameDlg = f
  end
  nameDlg.onAccept = onAccept
  nameDlg.title:SetText(titleText or "Name")
  nameDlg.box:SetText(initial or ""); nameDlg.box:SetCursorPosition(0)
  nameDlg:Show(); nameDlg:Raise(); scrimShow(nameDlg)
  nameDlg.box:SetFocus(); nameDlg.box:HighlightText()
  return nameDlg
end

-- Yes/no confirm for destructive actions. ALWAYS used for deletes: a
-- self-arming "click twice" button has no way to back out once armed
-- (the owner 2026-07-24) — this does, via Cancel or ESC.
function UI.confirm(bodyText, onYes, acceptLabel, titleText)
  if not confirmDlg then
    local W, H = 330, 144
    local f = CreateFrame("Frame", "GloomSkinConfirm", UIParent)
    f:SetSize(W, H); f:SetPoint("CENTER"); f:SetFrameStrata("FULLSCREEN_DIALOG"); f:EnableMouse(true)
    UI.skinPlate(f)
    f.title = UI.newText(f, FONT.title, 17, COLOR.orange, "CENTER")
    f.title:SetPoint("TOP", 0, -14)
    f.body = UI.newText(f, FONT.body, 12, COLOR.text, "CENTER")
    f.body:SetPoint("TOP", 0, -46); f.body:SetWidth(W - 36)
    f.yes = UI.flatButton(f, 124, 26, COLOR.orange, "Delete", 13); f.yes:SetPoint("BOTTOMLEFT", 26, 16)
    local noB = UI.flatButton(f, 124, 26, COLOR.heroic, "Cancel", 13); noB:SetPoint("BOTTOMRIGHT", -26, 16)
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
  confirmDlg.yes.text:SetText(acceptLabel or "Delete")
  confirmDlg:Show(); confirmDlg:Raise(); scrimShow(confirmDlg)
  return confirmDlg
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
--   api.tips      { dropdown=, new=, copy=, rename=, delete= }
--                                        -- OPTIONAL; per-tool hover-help bodies
-- `err` is shown verbatim in the inline note line; ok=false with no err is silent.
-- Returns { frame, refresh, note, height }.
-- ------------------------------------------------------------
function UI.profileBlock(parent, w, api)
  local noun = api.noun or "profile"
  local Noun = noun:sub(1, 1):upper() .. noun:sub(2)
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

  local function btn(x, y, bw, label)
    local b = UI.flatButton(f, bw, 20, COLOR.heroic, label, 11)
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

  bNew:SetScript("OnClick", function()
    UI.nameDialog("New " .. noun, "", function(name)
      if not name or name == "" then return end
      after(api.create(name))
    end)
  end)
  if bCopy then
    bCopy:SetScript("OnClick", function()
      UI.nameDialog("Copy " .. noun, (api.active() or "") .. " copy", function(name)
        if not name or name == "" then return end
        after(api.copy(name))
      end)
    end)
  end
  bRen:SetScript("OnClick", function()
    UI.nameDialog("Rename " .. noun, api.active() or "", function(name)
      if not name or name == "" then return end
      after(api.rename(name))
    end)
  end)
  bDel:SetScript("OnClick", function()
    local active = api.active()
    if not active then return end
    UI.confirm(("Delete the %s \"%s\"?  This can't be undone."):format(noun, active),
      function() after(api.delete()) end)
  end)

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
-- ------------------------------------------------------------
local WARM = {   -- the Hub's own pairs (Shell + Media tab + the lib's own widgets)
  { "title", { 17, 21 } },          -- 17: nameDialog / confirm titles (MINOR 3)
  { "head",  { 12, 16 } },          -- 12: profileBlock header (MINOR 3)
  { "body",  { 10.5, 11, 12, 13 } },
  { "bodyM", { 11, 12, 13 } },
}
local warmer, warmRan
local pendingPairs = {}   -- registered before the PEW batch
local warmedKeys = {}     -- "(path)@(size)" → true; never draw a pair twice

local function drawPair(path, size)
  if not path or not size then return end
  local key = tostring(path) .. "@" .. tostring(size)
  if warmedKeys[key] then return end
  warmedKeys[key] = true
  local fs = warmer:CreateFontString(nil, "OVERLAY")
  UI.setFont(fs, path, size)
  fs:SetPoint("BOTTOMLEFT", 0, 0)
  fs:SetText("Ag")
end

local function warmBatch(pairs)
  if not warmer then
    warmer = CreateFrame("Frame", nil, UIParent)
    warmer:SetPoint("BOTTOMLEFT", 0, 0); warmer:SetSize(1, 1)
    warmer:SetFrameStrata("BACKGROUND")
    warmer:SetAlpha(0.01)
  end
  for _, pair in ipairs(pairs or {}) do drawPair(pair[1], pair[2]) end
  warmer:Show()
  C_Timer.After(2, function() warmer:Hide() end)   -- 2s on screen = safely rasterized
end

function UI.RegisterWarmPairs(list)
  if warmRan then
    warmBatch(list)
  else
    for _, pair in ipairs(list or {}) do pendingPairs[#pendingPairs + 1] = pair end
  end
end

function UI.WarmFonts(extraPairs)
  warmRan = true
  local all = {}
  for _, entry in ipairs(WARM) do
    for _, size in ipairs(entry[2]) do all[#all + 1] = { FONT[entry[1]], size } end
  end
  for _, pair in ipairs(pendingPairs) do all[#all + 1] = pair end
  for _, pair in ipairs(extraPairs or {}) do all[#all + 1] = pair end
  warmBatch(all)
end

-- Family-styled hover tooltip (dark plate, purple title, GeneralSans body).
-- One shared frame; attachTip(frame, title, body) wires OnEnter/OnLeave via
-- HookScript so it coexists with existing hover scripts.
local tipFrame, tipTitle, tipBody
local function showTip(owner, title, body)
  if not tipFrame then
    tipFrame = CreateFrame("Frame", nil, UIParent)
    tipFrame:SetFrameStrata("TOOLTIP")
    UI.skinPlate(tipFrame)
    tipTitle = UI.newText(tipFrame, FONT.bodyM, 12, COLOR.purple, "LEFT")
    tipTitle:SetPoint("TOPLEFT", 10, -8)
    tipBody = UI.newText(tipFrame, FONT.body, 11, COLOR.text, "LEFT")
    tipBody:SetPoint("TOPLEFT", 10, -26); tipBody:SetWidth(220); tipBody:SetJustifyH("LEFT")
  end
  tipTitle:SetText(title or "")
  tipBody:SetText(body or "")
  tipFrame:ClearAllPoints()
  tipFrame:SetPoint("BOTTOMRIGHT", owner, "TOPRIGHT", 0, 4)
  tipFrame:SetSize(240, 34 + tipBody:GetStringHeight())
  tipFrame:Show()
end
function UI.attachTip(f, title, body)
  f:HookScript("OnEnter", function() showTip(f, title, body) end)
  f:HookScript("OnLeave", function() if tipFrame then tipFrame:Hide() end end)
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

  h.text = UI.newText(parent, FONT.title, opts.fontSize or 17, { r = 1, g = 1, b = 1 }, "LEFT")
  h.text:SetPoint("LEFT", h.logo, "RIGHT", opts.gap or 9, 0)
  h.text:SetText(opts.label or "")

  h.divider = UI.hLine(parent)
  h.divider:SetPoint("TOPLEFT", x, divY)
  h.divider:SetPoint("TOPRIGHT", -(opts.rightInset or x), divY)

  h.bottom = divY
  return h
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
