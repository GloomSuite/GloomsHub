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

local MAJOR, MINOR = "LibGloomSkin-1.0", 6   -- MINOR 6 (2026-07-26): UI.colorPicker — the suite's own color picker; colorSwatch drives it instead of ColorPickerFrame
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
local nameDlg, confirmDlg, pickerDlg

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

local PICK_W, SV_W, SV_H = 330, 186, 140
local PICK_X, HUE_X, PRV_X, PRV_W = 22, 216, 246, 62
local PICK_H_PLAIN, PICK_H_ALPHA = 328, 380

function UI.colorPicker(opts)
  opts = opts or {}

  if not pickerDlg then
    local f = CreateFrame("Frame", "GloomSkinColorPicker", UIParent)
    f:SetSize(PICK_W, PICK_H_PLAIN); f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG"); f:EnableMouse(true)
    UI.skinPlate(f)
    -- Standing in for the scrim: with nothing dimmed behind it, this rim is the
    -- only thing telling the panel apart from the tab it floats over.
    UI.addEdges(f, { r = COLOR.purple.r, g = COLOR.purple.g, b = COLOR.purple.b, a = 0.55 }, 1)

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

    f.title = UI.newText(f, FONT.title, 17, COLOR.purple, "CENTER")
    f.title:SetPoint("TOP", 0, -14)

    -- ---- saturation / value field --------------------------------------
    -- Solid hue underneath, white→clear left-to-right for SATURATION, then
    -- clear→black top-to-bottom for VALUE. (WoW's "VERTICAL" gradient runs
    -- min at the BOTTOM, max at the top.)
    local sv = CreateFrame("Frame", nil, f)
    sv:SetSize(SV_W, SV_H); sv:SetPoint("TOPLEFT", PICK_X, -46); sv:EnableMouse(true)
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
    hue:SetSize(18, SV_H); hue:SetPoint("TOPLEFT", HUE_X, -46); hue:EnableMouse(true)
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
    prv:SetSize(PRV_W, SV_H); prv:SetPoint("TOPLEFT", PRV_X, -46)
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
    local hexLab = UI.newText(f, FONT.head, 12, COLOR.mute, "LEFT")
    hexLab:SetPoint("TOPLEFT", PICK_X, -198); hexLab:SetText("HEX")
    f.hex = UI.flatEditBox(f, 96, 22)
    f.hex:SetPoint("TOPLEFT", PICK_X + 36, -194)
    f.hex:SetMaxLetters(9)

    -- ---- palette ----------------------------------------------------------
    -- A fixed pool, repainted on every open — its contents change as the user's
    -- own UI does, so it cannot be built once like the rest of the dialog.
    f.palLab = UI.newText(f, FONT.head, 12, COLOR.mute, "LEFT")
    f.palLab:SetPoint("TOPLEFT", PICK_X, -230); f.palLab:SetText("IN USE")
    f.palBtns = {}
    for i = 1, PALETTE_MAX do
      local b = CreateFrame("Button", nil, f)
      b:SetSize(20, 20); b:SetPoint("TOPLEFT", PICK_X + (i - 1) * 24, -250)
      b.tex = b:CreateTexture(nil, "ARTWORK"); b.tex:SetAllPoints()
      UI.addEdges(b, COLOR.rim, 1)
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
    -- Its own sub-frame because UI.sliderRow always spans its PARENT (insetting
    -- 18 a side) — laying out a frame is the family way to size a slider.
    f.alphaBlock = CreateFrame("Frame", nil, f)
    f.alphaBlock:SetPoint("TOPLEFT", 4, -282); f.alphaBlock:SetSize(PICK_W - 8, 44)
    f.alphaRow = UI.sliderRow(f.alphaBlock, 0, "Opacity", 0, 100, 1,
      function() return math.floor((f.a or 1) * 100 + 0.5) end,
      function(v) f.a = math.floor(v + 0.5) / 100; f:Emit() end,
      function(v) return string.format("%d%%", math.floor(v + 0.5)) end)

    -- ---- buttons ----------------------------------------------------------
    f.ok = UI.flatButton(f, 124, 26, COLOR.purple, "OK", 13)
    f.ok:SetPoint("BOTTOMLEFT", 26, 16)
    f.cancel = UI.flatButton(f, 124, 26, COLOR.heroic, "Cancel", 13)
    f.cancel:SetPoint("BOTTOMRIGHT", -26, 16)

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
      f.onChange, f.onAccept, f.onCancel, f.accepted = nil, nil, nil, false
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
  f.onChange, f.onAccept, f.onCancel = opts.onChange, opts.onAccept, opts.onCancel
  f.accepted = false
  f.title:SetText(opts.title or "COLOR")
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

local function warmBatch(pairs)
  if not warmer then
    warmer = CreateFrame("Frame", nil, UIParent)
    warmer:SetPoint("BOTTOMLEFT", 0, 0); warmer:SetSize(1, 1)
    warmer:SetFrameStrata("BACKGROUND")
    warmer:SetAlpha(0.01)
  end
  local dead   -- path → true, for every pair whose face would not apply
  for _, pair in ipairs(pairs or {}) do
    if not drawPair(pair[1], pair[2]) then
      dead = dead or {}
      dead[pair[1]] = true
    end
  end
  warmer:Show()
  C_Timer.After(2, function() warmer:Hide() end)   -- 2s on screen = safely rasterized
  return dead
end

function UI.RegisterWarmPairs(list)
  if warmRan then
    return warmBatch(list)
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
  return warmBatch(all)   -- path → true for anything that would not load; Media.lua names them
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
-- title/body may be FUNCTIONS, resolved at hover time — for a widget whose
-- content changes under a tip that can only be hooked once (colorPicker's
-- palette pool). Plain strings behave exactly as before.
function UI.attachTip(f, title, body)
  f:HookScript("OnEnter", function()
    showTip(f, type(title) == "function" and title() or title,
               type(body)  == "function" and body()  or body)
  end)
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
