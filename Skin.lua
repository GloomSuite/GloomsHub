-- ============================================================
-- Skin.lua — Gloom's Hub
-- The shared design tokens + widget toolkit for the whole
-- suite, lifted verbatim from GloomsBars Core.lua/Config.lua
-- (which mirrors GloomsAuras — the family language). This is
-- now the ONE copy (CONTRACTS §1); GB/GA swap to consuming it
-- in Phases C/D, when this body also becomes LibGloomSkin-1.0.
-- ============================================================

local Hub = GloomsHub

-- ------------------------------------------------------------
-- Tokens
-- ------------------------------------------------------------

local function color(hex)
  local r = tonumber(hex:sub(1, 2), 16) / 255
  local g = tonumber(hex:sub(3, 4), 16) / 255
  local b = tonumber(hex:sub(5, 6), 16) / 255
  return { r = r, g = g, b = b, hex = hex }
end

Hub.COLOR = {
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

Hub.MEDIA = "Interface\\AddOns\\GloomsHub\\Media\\"
local FONT_DIR = Hub.MEDIA .. "fonts\\"

Hub.FONT = {
  title = FONT_DIR .. "Khand-SemiBold.ttf",
  head  = FONT_DIR .. "Khand-Medium.ttf",
  body  = FONT_DIR .. "GeneralSans-Regular.ttf",
  bodyM = FONT_DIR .. "GeneralSans-Medium.ttf",
  label = FONT_DIR .. "GeneralSans-Semibold.ttf",
}

local COLOR, FONT = Hub.COLOR, Hub.FONT
local DEFAULT_FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"

-- ------------------------------------------------------------
-- Widget toolkit
-- ------------------------------------------------------------

local UI = {}
Hub.UI = UI

UI.CARET = Hub.MEDIA .. "ui\\caret.png"   -- right-pointing source art
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

-- Four 1px edge textures forming a squared border.
function UI.addEdges(f, cc, thick)
  thick = thick or 1
  local function edge(p1, p2, w, h)
    local t = f:CreateTexture(nil, "OVERLAY")
    t:SetColorTexture(cc.r, cc.g, cc.b, cc.a or 1)
    t:SetPoint(p1); t:SetPoint(p2)
    if w then t:SetWidth(w) end
    if h then t:SetHeight(h) end
    return t
  end
  edge("TOPLEFT", "TOPRIGHT", nil, thick)
  edge("BOTTOMLEFT", "BOTTOMRIGHT", nil, thick)
  edge("TOPLEFT", "BOTTOMLEFT", thick, nil)
  edge("TOPRIGHT", "BOTTOMRIGHT", thick, nil)
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

-- Font pre-warmer. WoW rasterizes a (font file, size) pair the first time it is
-- DRAWN in a client session — and the first draw of a cold pair can render
-- blank text (QA'd 2026-07-24: cold start → blank catalog names; /reload in the
-- same session → fine, because the pairs were warm by then; next cold start →
-- blank again). So right after login we draw every pair the Hub UI uses once,
-- imperceptibly (1px frame, alpha 0.01, bottom-left, 2 seconds), so the real
-- UI — built lazily later — only ever touches warm pairs.
local WARM = {
  { "title", { 21 } },
  { "head",  { 16 } },
  { "body",  { 10.5, 11, 12, 13 } },
  { "bodyM", { 11, 12, 13 } },
}
local warmer
function UI.WarmFonts(extraPairs)
  if warmer then return end
  warmer = CreateFrame("Frame", nil, UIParent)
  warmer:SetPoint("BOTTOMLEFT", 0, 0); warmer:SetSize(1, 1)
  warmer:SetFrameStrata("BACKGROUND")
  warmer:SetAlpha(0.01)
  local function warm(path, size)
    local fs = warmer:CreateFontString(nil, "OVERLAY")
    UI.setFont(fs, path, size)
    fs:SetPoint("BOTTOMLEFT", 0, 0)
    fs:SetText("Ag")
  end
  for _, entry in ipairs(WARM) do
    for _, size in ipairs(entry[2]) do warm(FONT[entry[1]], size) end
  end
  for _, pair in ipairs(extraPairs or {}) do warm(pair[1], pair[2]) end
  warmer:Show()
  C_Timer.After(2, function() warmer:Hide() end)
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
