-- ============================================================
-- Shell.lua — Gloom's Hub
-- The ONE Suite window: tab registry + chrome. Implements
-- CONTRACTS §2 exactly: GloomsHub:RegisterTab / :Open /
-- :FocusTab / :ShowPage (+ :ToggleWindow for the slash semantics).
-- Tabs' build(container) runs ONCE, lazily, on first show —
-- never at login.
--
-- ★ REDESIGNED A THIRD TIME 2026-09-25 — "Glass" (13 screens on the Figma page
-- "GloomSuite UI 2", named "Glass Auras, …" / "Glass Bars, …"). The second
-- design's sidebar and per-tool accent are RETIRED. Now, on a 1060 × 740 window:
--   a 50-tall TOP BAR — at the left (273 wide, violet 20%) the TOOL SWITCHER,
--     "gloom" + the tool's name in lime + a white ▾, which opens the list of
--     tools; to its right (black 50%) the tool's PROFILE row (UI.gProfileBar)
--     and, at the far right, the CLOSE disc. A 1px violet rule under it.
--     The bar's blank space is the drag handle.
--   the tool's PAGES as a stack of 250 × 24 buttons at (30, 80), 6 apart: the
--     chosen one violet 50% with a lime ▸, the rest violet 20% with a white 40%
--     ▸, the name in Saira 12 right-aligned.
--   the page's GLASS: the owner's own export of the page's background with its
--     glass panels composited in (WoW has no backdrop blur, and the panels never
--     move, so baking them is exact). A tool names one per page (`bg`).
--   UI SCALE at the bottom right, 30% until the mouse is on it.
-- A tool that registers `pages` is a GLASS tool: its container is the WHOLE
-- window (1060 × 740 at 0,0), so it places everything at the mocks' own window
-- coordinates. A tool without pages (not rebuilt yet — a LEGACY tool) keeps
-- its old layout, unscaled, on the old light plate under the top bar.
-- ============================================================

local Hub = GloomsHub
local UI, COLOR, FONT = Hub.UI, Hub.COLOR, Hub.FONT

local SHELL_W, SHELL_H = 1060, 740
local TOP_H    = 50                     -- the top bar
local SWITCH_W = 273                    -- the tool switcher's block
local PROF_X   = 303                    -- the profile row (the mocks' Frame 414 + 30)
local NAV_X, NAV_Y, NAV_W, NAV_H, NAV_GAP = 30, 80, 250, 24, 6
-- UI Scale: the mocks' "Group 9" row (y 713), now with the dial's value box, so
-- the whole control (ticks + box, 164 wide) ends at the panels' right edge, 1030.
local SCALE_X, SCALE_Y = 866, 714.5
-- A page's glass is the owner's 2120 × 1480 export (2 × the window), NOT
-- resampled: cut into four power-of-two tiles (tools/gen-glass-art.py bg) that
-- lie edge to edge here. { suffix, x, y, w, h (window units), u, v (texcoords) }.
local GLASS_TILES = {
  { "a", 0,    0,   1024, 512, 1,        1 },
  { "b", 1024, 0,   36,   512, 72 / 128, 1 },
  { "c", 0,    512, 1024, 228, 1,        456 / 512 },
  { "d", 1024, 512, 36,   228, 72 / 128, 456 / 512 },
}
-- A LEGACY tool's container keeps the size it was pinned to (CONTRACTS §2): with
-- a profile 1060 × 585, without one 860 × 650 — both fit under the top bar.
local LEGACY_PROFILE_W, LEGACY_PROFILE_H = 1060, 585
local LEGACY_W, LEGACY_H = 860, 650

-- The switcher's order is the MOCKS' (Auras · Bars · Unit Frames · Portraits ·
-- Overlays · Media), fixed here so no tool's registration can reorder it;
-- an unknown id falls back to its own `order`.
local TAB_ORDER = { auras = 10, bars = 20, unitframes = 30, portraits = 40, overlays = 50, media = 90 }

local tabs = {}       -- id → def
local ordered = {}    -- defs sorted by order
local panel, top, switcher, nav, legacyPlate, scaleHolder
local glassBg = {}    -- the four tiles of a page's glass
local current         -- id of the focused tab

-- The suite's addons, in tab order. ★ Gloom's Build Barn is deliberately
-- NOT here — it is not a suite member (a locked decision; it mounts no tab).
local SUITE = {
  { addon = "GloomsHub",        short = "Hub" },
  { addon = "GloomsAuras",      short = "Auras" },
  { addon = "GloomsBars",       short = "Bars" },
  { addon = "GloomsUnitFrames", short = "Unit Frames" },
  { addon = "GloomsPortraits",  short = "Portraits" },
  { addon = "GloomsOverlays",   short = "Overlays" },
}

-- Version of any suite addon. nil = NOT INSTALLED (so the line can omit it);
-- "dev" = the TOC still holds the packager's literal @project-version@, i.e. a
-- dev checkout / symlink rather than a packaged build.
function Hub:Version(addon)
  local v = C_AddOns and C_AddOns.GetAddOnMetadata
        and C_AddOns.GetAddOnMetadata(addon or "GloomsHub", "Version")
  if type(v) ~= "string" or v == "" then return nil end
  if v:find("@") then return "dev" end
  return v
end

-- ★ EVERY installed suite addon's version (the owner, 2026-07-25: "the
-- individual addon version isn't shown anywhere in GH"). The addons version
-- INDEPENDENTLY, so one number could never describe the install, and this is
-- the first question in any support exchange. The mocks have no version line,
-- so it is the hover-help of the sidebar's top (the wordmark and the drag handle).
function Hub:VersionLine()
  local parts = {}
  for _, e in ipairs(SUITE) do
    local v = Hub:Version(e.addon)
    if v then parts[#parts + 1] = e.short .. " " .. v end
  end
  if #parts == 0 then return "Gloom Suite" end
  return table.concat(parts, "\n")
end

-- ------------------------------------------------------------
-- ★ TEMPORARY (2026-09-22) — THE UI-SCALE DIAL
-- The backlog has wanted a UI-scale control since stage 5 was scoped
-- ("the Suite SETTINGS tab with the UI-scale control"); the owner wants it
-- NOW, unlabelled, in the window's lower right, to judge the redesigned pages
-- at other sizes before deciding whether the design continues at all.
--
-- ★ WHOLE PIXELS ONLY (2026-09-26). The glass pages looked razor-sharp in Figma
-- and soft in the game. Measured with /gloom px on the owner's 4K screen: one UI
-- unit was 1.828 screen pixels at his game-wide UI scale, so every 1-unit line
-- straddled two pixels and every texture was resampled. The dial therefore
-- offers ONLY the window scales at which one unit is a WHOLE number of screen
-- pixels (1, 2, 3 …), worked out LIVE from this screen and the game's own UI
-- scale (his screen: 1 px = 55% · 2 px = 109%), and the window's position is
-- snapped to the pixel grid after every drag and rescale. What is stored is the
-- PIXELS PER UNIT, not a percentage, so the same choice stays sharp on another
-- screen or after a UI-scale change. The owner's glass exports are 2x, so at
-- 2 px per unit they land on the screen pixel for pixel.
-- ★ IN-BETWEEN STEPS (the owner, 2026-09-26: "only huge or tiny"): on his 4K
-- screen only 1 and 2 px fit, so the ladder also offers 1.25 · 1.5 · 1.75 px a
-- unit. Measured the same day (/gloom texttest): WoW redraws scaled TEXT
-- crisply at any scale, so these cost only the 1-unit outlines (drawn 1 or 2 px
-- wide, a little uneven) and the glass (resampled, a little soft). The tooltip
-- says which kind of step is chosen.
--
-- ⚠ The dial is a CHILD OF THE WINDOW and scales with it, like everything
-- else in the window. The window therefore resizes only when the drag is
-- RELEASED (the owner, 2026-09-22: "it's fine if the window resize doesn't
-- happen until after the drag is released"). That is not a shortcut — it is
-- what makes a dial inside its own subject work at all: UI.dial captures its
-- drag origin in its own effective-scale units, so rescaling mid-drag would
-- leave the origin on a stale ruler and the value would run away.
--
-- ⚠ Do NOT assume the screen's size. The ladder keeps only the sizes whose
-- window fits the screen, so the dial cannot push its own corner off it.
--
-- If the redesign survives, this becomes a real control on the Settings tab.
-- ------------------------------------------------------------

local SCALES, PXS = { 1 }, { 1 }   -- window scale and pixels-per-unit, per step (built by buildLadder)
local scaleDial
local pendingScale = false   -- a value picked mid-drag, applied on release

-- Screen pixels per UI unit for a frame at effective scale 1.
local function pxPerUnit()
  local _, ph = GetPhysicalScreenSize()
  return (ph and ph > 0) and (ph / 768) or 1
end

local function clampIdx(i)
  i = math.floor((tonumber(i) or 1) + 0.5)
  return math.max(1, math.min(#SCALES, i))
end

local function scaleLabel(i) return math.floor(SCALES[clampIdx(i)] * 100 + 0.5) .. "%" end

-- The step for the SAVED pixels-per-unit (GloomsHubDB.uiPx); a window saved by
-- the old percentage ladder takes the step nearest its old size.
local function scaleIndex()
  local want = GloomsHubDB and GloomsHubDB.uiPx
  if want then
    for i, n in ipairs(PXS) do if n == want then return i end end
  end
  local old = (GloomsHubDB and GloomsHubDB.uiScale) or 1.0
  local best, bestD = 1, math.huge
  for i, v in ipairs(SCALES) do
    local d = math.abs(v - old)
    if d < bestD then best, bestD = i, d end
  end
  return best
end

-- The whole-pixel steps that fit this screen, at the game's current UI scale.
local function buildLadder()
  local pw, ph = GetPhysicalScreenSize()
  local base = pxPerUnit() * UIParent:GetEffectiveScale()   -- px per unit at window scale 1
  SCALES, PXS = {}, {}
  for _, n in ipairs({ 1, 1.25, 1.5, 1.75, 2, 3, 4 }) do
    if SHELL_W * n <= (pw or 0) and SHELL_H * n <= (ph or 0) then
      SCALES[#SCALES + 1] = n / base; PXS[#PXS + 1] = n
    end
  end
  if #SCALES == 0 then   -- a screen smaller than the window at 1 px a unit: the largest size that fits
    SCALES[1] = math.min((pw or 1) / SHELL_W, (ph or 1) / SHELL_H) / base; PXS[1] = 0
  end
end

-- Everything the kit floats OUTSIDE the window is a UIParent child and does
-- not inherit the window's scale. Pull the ones the lib exposes along with it;
-- the popover, the scrim and the tooltip are private to Skin.lua and stay at
-- 100% until this control becomes real (that needs a lib API + a MINOR bump).
local function scaleDetached(s)
  local fly = UI.flyout and UI.flyout()
  if fly then fly:SetScale(s) end
  for _, name in ipairs({ "GloomSkinColorPicker", "GloomSkinConfirm", "GloomSkinNameDialog" }) do
    local f = _G[name]
    if f then f:SetScale(s) end
  end
end

-- Put the window's top-left corner on a whole screen pixel: at a whole-pixel
-- scale everything inside it then lands on the grid too. SetPoint offsets and
-- GetLeft/GetTop are in the window's own units; × effective scale × pixels per
-- unit gives screen pixels.
local function snapPosition()
  if not panel then return end
  local l, t = panel:GetLeft(), panel:GetTop()
  if not (l and t) then return end
  local k = panel:GetEffectiveScale() * pxPerUnit()
  if k <= 0 then return end
  local pl, pt = math.floor(l * k + 0.5), math.floor(t * k + 0.5)
  panel:ClearAllPoints()
  panel:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", pl / k, pt / k)
end

-- Scale about the window's CENTRE: SetPoint offsets resolve in the anchored
-- frame's own effective scale, so the screen-space centre has to be recomputed
-- into the new units. Without this the window walks across the screen.
local function applyScale()
  if not panel then return end
  local i = scaleIndex()
  local s = SCALES[i]
  if GloomsHubDB then GloomsHubDB.uiPx = PXS[i] end
  local x, y = panel:GetCenter()
  local old = panel:GetEffectiveScale()
  panel:SetScale(s)
  local new = panel:GetEffectiveScale()
  if x and y and new > 0 then
    local k = old / new
    panel:ClearAllPoints()
    panel:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x * k, y * k)
  end
  snapPosition()
  scaleDetached(s)
end

-- ------------------------------------------------------------
-- The page buttons (a glass tool's `pages`)
-- ------------------------------------------------------------
local navRows = {}

local function navRow(i)
  local r = navRows[i]
  if r then return r end
  r = CreateFrame("Button", nil, nav)
  r:SetSize(NAV_W, NAV_H)
  r.fill = UI.roundFill(r, "BACKGROUND")
  r.text = UI.newText(r, FONT.sa, 12, COLOR.paper, "RIGHT")
  r.text:SetPoint("RIGHT", r, "RIGHT", -26, -UI.G_NUDGE)   -- text in a box sits low: see UI.G_NUDGE
  r.tri = r:CreateTexture(nil, "ARTWORK"); r.tri:SetTexture(UI.G_TRI); r.tri:SetSize(9, 8)
  r.tri:SetRotation(math.pi / 2)           -- tri.png points down; +90° = right
  r.tri:SetPoint("CENTER", r, "RIGHT", -15, 0)
  function r:paint()
    local a = self._on and 0.5 or (self._hot and 0.35 or 0.2)
    UI.tint(self.fill, COLOR.violet, a)
    if self._on then UI.tint(self.tri, COLOR.lime) else self.tri:SetVertexColor(1, 1, 1, 0.4) end
  end
  r:SetScript("OnEnter", function(self) self._hot = true; self:paint() end)
  r:SetScript("OnLeave", function(self) self._hot = false; self:paint() end)
  navRows[i] = r
  return r
end

local function paintNav(def)
  local pages = (def and def.pages) or {}
  for i, pg in ipairs(pages) do
    local r = navRow(i)
    r:ClearAllPoints(); r:SetPoint("TOPLEFT", 0, -(i - 1) * (NAV_H + NAV_GAP))
    r._on = (pg.id == def._page)
    r.text:SetText(pg.title or pg.id)
    r:SetScript("OnClick", function() Hub:ShowPage(def.id, pg.id) end)
    r:paint(); r:Show()
  end
  for i = #pages + 1, #navRows do navRows[i]:Hide() end
end

-- The page's glass, or none. `bg` names the tiles' common prefix
-- ("…\\glass\\triggers" → triggers-a.png … -d.png).
local function paintGlass(def)
  local pg
  for _, p in ipairs((def and def.pages) or {}) do if p.id == def._page then pg = p end end
  for i, t in ipairs(glassBg) do
    if pg and pg.bg then t:SetTexture(pg.bg .. "-" .. GLASS_TILES[i][1] .. ".png"); t:Show()
    else t:Hide() end
  end
end

-- ------------------------------------------------------------
-- Window chrome
-- ------------------------------------------------------------

local function BuildPanel()
  panel = CreateFrame("Frame", "GloomsSuiteWindow", UIParent)
  panel:SetSize(SHELL_W, SHELL_H)
  panel:SetPoint("CENTER")
  panel:SetFrameStrata("DIALOG")
  panel:EnableMouse(true)
  panel:SetMovable(true); panel:SetClampedToScreen(true)
  -- Come to the front when opened or clicked, WITHOUT SetToplevel — toplevel
  -- would pin us permanently above anything that is not.
  panel:HookScript("OnShow", function(self) self:Raise() end)
  panel:HookScript("OnMouseDown", function(self) self:Raise() end)
  local bg = panel:CreateTexture(nil, "BACKGROUND", nil, -8)
  bg:SetAllPoints(); bg:SetColorTexture(COLOR.void.r, COLOR.void.g, COLOR.void.b, 1)
  for i, g in ipairs(GLASS_TILES) do
    local t = panel:CreateTexture(nil, "BACKGROUND", nil, -7)
    t:SetPoint("TOPLEFT", g[2], -g[3]); t:SetSize(g[4], g[5]); t:SetTexCoord(0, g[6], 0, g[7])
    t:Hide()
    glassBg[i] = t
  end

  -- The light plate a LEGACY tool still draws on (the first redesign's
  -- transition theme needs it: its text is dark), under the top bar.
  legacyPlate = panel:CreateTexture(nil, "BACKGROUND", nil, -6)
  legacyPlate:SetPoint("TOPLEFT", 0, -TOP_H); legacyPlate:SetPoint("BOTTOMRIGHT", 0, 0)
  legacyPlate:SetColorTexture(COLOR.plate.r, COLOR.plate.g, COLOR.plate.b, 1)
  legacyPlate:Hide()

  -- THE TOP BAR — above every tool's container.
  top = CreateFrame("Frame", nil, panel)
  top:SetPoint("TOPLEFT", 0, 0); top:SetSize(SHELL_W, TOP_H)
  top:SetFrameLevel(panel:GetFrameLevel() + 40)
  local lf = top:CreateTexture(nil, "BACKGROUND"); lf:SetPoint("TOPLEFT", 0, 0); lf:SetSize(SWITCH_W, TOP_H)
  lf:SetColorTexture(COLOR.violet.r, COLOR.violet.g, COLOR.violet.b, 0.2)
  local rf = top:CreateTexture(nil, "BACKGROUND"); rf:SetPoint("TOPLEFT", SWITCH_W, 0); rf:SetPoint("BOTTOMRIGHT", 0, 0)
  rf:SetColorTexture(0, 0, 0, 0.5)
  local rule = top:CreateTexture(nil, "BORDER"); rule:SetHeight(1)
  rule:SetPoint("TOPLEFT", 0, -TOP_H); rule:SetPoint("TOPRIGHT", 0, -TOP_H)
  rule:SetColorTexture(COLOR.violet.r, COLOR.violet.g, COLOR.violet.b, 1)

  -- The drag handle: the whole bar, under its controls (★ the owner, 2026-09-24:
  -- "the entire top blank area … should be an area that you can click and drag").
  local drag = CreateFrame("Frame", nil, top)
  drag:SetAllPoints(); drag:SetFrameLevel(top:GetFrameLevel() + 1)
  drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
  drag:SetScript("OnDragStart", function() if panel:IsMovable() then panel:StartMoving() end end)
  drag:SetScript("OnDragStop", function() panel:StopMovingOrSizing(); snapPosition() end)

  -- THE TOOL SWITCHER (the mocks' Frame 59): "gloom" white + the tool in lime,
  -- Michroma 14, 30 in; a white ▾ 6 after it. Click → the list of tools. It
  -- carries the version line as its hover-help, as the old wordmark did.
  switcher = CreateFrame("Button", nil, top)
  switcher:SetPoint("TOPLEFT", 0, 0); switcher:SetSize(SWITCH_W, TOP_H)
  switcher:SetFrameLevel(top:GetFrameLevel() + 5)
  switcher.hot = switcher:CreateTexture(nil, "BACKGROUND"); switcher.hot:SetAllPoints()
  switcher.hot:SetColorTexture(1, 1, 1, 0.05); switcher.hot:Hide()
  switcher.mark = UI.wordmark(switcher, "", 14, { prefixColor = COLOR.paper, suffixColor = COLOR.lime })
  switcher.mark:SetPoint("LEFT", 30, 0)
  switcher.caret = switcher:CreateTexture(nil, "ARTWORK"); switcher.caret:SetTexture(UI.G_TRI)
  switcher.caret:SetSize(9, 8); switcher.caret:SetPoint("LEFT", switcher.mark, "RIGHT", 6, 0)
  switcher:SetScript("OnEnter", function(self) self.hot:Show() end)
  switcher:SetScript("OnLeave", function(self) self.hot:Hide() end)
  switcher:SetScript("OnClick", function(self)
    local list = {}
    for _, d in ipairs(ordered) do list[#list + 1] = { value = d.id, label = d.title or d.id } end
    UI.gList(self.mark, list, current, function(v) Hub:FocusTab(v) end, { minW = 180 })
  end)
  UI.attachTip(switcher, "Gloom Suite", function() return Hub:VersionLine() end)

  -- THE CLOSE DISC (the mocks' "cross 1"), 10 in from the right.
  local close = CreateFrame("Button", nil, top); close:SetSize(23, 23)
  close:SetFrameLevel(top:GetFrameLevel() + 5)
  close:SetPoint("RIGHT", top, "RIGHT", -10, 0)
  local ci = close:CreateTexture(nil, "ARTWORK"); ci:SetTexture(UI.G_CLOSE); ci:SetTexCoord(0, 23 / 32, 0, 23 / 32)
  ci:SetAllPoints(); UI.tint(ci, COLOR.violet)
  close:SetScript("OnEnter", function() UI.tint(ci, COLOR.lilac) end)
  close:SetScript("OnLeave", function() UI.tint(ci, COLOR.violet) end)
  close:SetScript("OnClick", function() panel:Hide() end)

  -- THE PAGE BUTTONS
  nav = CreateFrame("Frame", nil, panel)
  nav:SetPoint("TOPLEFT", NAV_X, -NAV_Y); nav:SetSize(NAV_W, 10)
  nav:SetFrameLevel(panel:GetFrameLevel() + 30)

  -- UI SCALE (the mocks' "Group 9"): the word, then the dial with its value box,
  -- as every glass dial shows it (the owner, 2026-09-26: show the current value).
  -- The whole control rests at 30%, the mock's opacity — persistent but rarely
  -- used, so it must not pull the eye (the owner, 2026-09-26: "it's
  -- distracting") — and comes up to full only while the mouse is on it or it
  -- is being dragged, so the value can be read as it changes.
  -- ★ Still the TEMPORARY dial of 2026-09-22 in behaviour (see above).
  buildLadder()
  scaleHolder = CreateFrame("Frame", nil, panel)
  scaleHolder:SetPoint("TOPLEFT", SCALE_X, -SCALE_Y); scaleHolder:SetSize(164, 18)
  scaleHolder:SetFrameLevel(panel:GetFrameLevel() + 30)
  local sl = UI.gLabel(scaleHolder, "UI Scale", 12)
  sl:SetPoint("RIGHT", scaleHolder, "TOPLEFT", -10, -8)
  scaleDial = UI.gDial(scaleHolder, {
    bare = true, label = "UI Scale",
    min = 1, max = #SCALES, step = 1,
    dragPx = 300,                      -- large grain: a long pull across the steps
    fmt = scaleLabel,
    get = scaleIndex,
    set = function(v)
      local i = clampIdx(v)
      if GloomsHubDB then GloomsHubDB.uiPx = PXS[i]; GloomsHubDB.uiScale = SCALES[i] end
      -- Mid-drag the value is banked, not applied; the wheel has no drag and
      -- so lands at once.
      local st = scaleDial and scaleDial.strip
      if st and st._drag then pendingScale = true else applyScale() end
    end,
  })
  scaleDial:SetPoint("TOPLEFT", scaleHolder, "TOPLEFT", 0, 0)
  -- The box READS the size; typing a percentage into it would mean nothing to a
  -- ladder of steps, so it takes no clicks (the ticks and the wheel set it).
  scaleDial.box:EnableMouse(false); scaleDial.box:EnableKeyboard(false)
  -- (hooked after the dial's own tooltip, so this one is what shows)
  UI.attachTip(scaleDial.strip, "UI Scale", function()
    local n = PXS[scaleIndex()] or 0
    local sharp = (n > 0 and n == math.floor(n))
    return (sharp and "A sharp size: every line lands on whole screen pixels."
      or "Between the sharp sizes: text stays sharp; thin outlines and the glass are a little soft.")
      .. " Pull along the ticks; the window resizes when you let go."
  end)
  -- The release. NOT OnMouseUp: UI.dial also ends a drag from its OnUpdate
  -- when the button comes up away from the strip, and that path fires no
  -- mouse-up here. Watching `_drag` clear catches every way a drag can end.
  local function dim()
    local on = scaleHolder:IsMouseOver() or (scaleDial.strip._drag ~= nil)
    scaleHolder:SetAlpha(on and 1 or 0.3)
    sl:SetAlpha(1)   -- (the label is the holder's child: it dims with it)
  end
  scaleDial.strip:HookScript("OnUpdate", function(self)
    if pendingScale and not self._drag then
      pendingScale = false
      applyScale()
    end
    dim()
  end)
  scaleDial.strip:HookScript("OnEnter", dim); scaleDial.strip:HookScript("OnLeave", dim)
  scaleHolder:SetAlpha(0.3)
  applyScale()

  tinsert(UISpecialFrames, "GloomsSuiteWindow")   -- Escape closes it

  -- The screen or the game's UI scale changed: the whole-pixel sizes moved with it.
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("UI_SCALE_CHANGED"); ev:RegisterEvent("DISPLAY_SIZE_CHANGED")
  ev:SetScript("OnEvent", function()
    buildLadder()
    if scaleDial then scaleDial:refresh() end
    applyScale()
  end)
  panel:HookScript("OnShow", snapPosition)
end

-- ------------------------------------------------------------
-- Registry + focus (CONTRACTS §2)
-- ------------------------------------------------------------

function Hub:RegisterTab(def)
  if type(def) ~= "table" or type(def.id) ~= "string" or def.id == "" then
    error("GloomsHub:RegisterTab — def.id (string) is required")
  end
  if type(def.build) ~= "function" then
    error("GloomsHub:RegisterTab — def.build (function) is required (tab '" .. def.id .. "')")
  end
  if tabs[def.id] then
    error("GloomsHub:RegisterTab — duplicate tab id '" .. def.id .. "'")
  end
  tabs[def.id] = def
  ordered[#ordered + 1] = def
  table.sort(ordered, function(a, b) return (TAB_ORDER[a.id] or a.order or 50) < (TAB_ORDER[b.id] or b.order or 50) end)
end

local function EnsureContainer(def)
  if def._container then return def._container end
  local c = CreateFrame("Frame", nil, panel)
  if def.pages then
    -- GLASS: the whole window, so a tool places things at the mocks' own
    -- window coordinates. Under the top bar and the page buttons.
    c:SetPoint("TOPLEFT", 0, 0); c:SetSize(SHELL_W, SHELL_H)
    c:SetFrameLevel(panel:GetFrameLevel() + 2)
  else
    -- LEGACY: the size it was pinned to, unscaled, centred under the top bar.
    local w, h = LEGACY_W, LEGACY_H
    if def.profile then w, h = LEGACY_PROFILE_W, LEGACY_PROFILE_H end
    c:SetSize(w, h)
    c:SetPoint("TOP", panel, "TOP", 0, -TOP_H - math.floor((SHELL_H - TOP_H - h) / 2))
  end
  c:Hide()
  def._container = c
  def.build(c)   -- ONCE, lazily, on first show
  return c
end

-- The top bar's profile row, built once per tab that supplies `profile`.
local function EnsureProfile(def)
  if def._profileBar or not def.profile then return def._profileBar end
  local st = UI.gProfileBar(top, def.profile, def.wordmark or def.title or "")
  st.frame:SetPoint("LEFT", top, "LEFT", PROF_X, 0)
  st.frame:SetFrameLevel(top:GetFrameLevel() + 5)
  def._profileBar = st
  return st
end

function Hub:FocusTab(id)
  local def = tabs[id]
  if not def or not panel then return end
  if current and tabs[current] then
    local old = tabs[current]
    if old._container then old._container:Hide() end
    if old._profileBar then old._profileBar.frame:Hide() end
  end
  current = id
  if GloomsHubDB then GloomsHubDB.lastTab = id end
  legacyPlate:SetShown(not def.pages)
  switcher.mark:SetMark(def.wordmark or def.title or def.id:upper())
  local c = EnsureContainer(def)
  -- A glass tool opens on the page it was last on, else its first.
  if def.pages and #def.pages > 0 then
    local want = def._page or (GloomsHubDB and GloomsHubDB.lastPage and GloomsHubDB.lastPage[id])
    def._page = def.pages[1].id
    for _, pg in ipairs(def.pages) do if pg.id == want then def._page = want end end
  end
  paintNav(def)
  paintGlass(def)
  c:Show()
  local st = EnsureProfile(def)
  if st then st.frame:Show(); st:refresh() end
  if def.pages then Hub:ShowPage(id, def._page) end
  if def.refresh then def.refresh() end
end

-- Show one page of a glass tool: its glass, its button, and the tool's own
-- `showPage(pageId)`. Focuses the tool first if it is not in front.
function Hub:ShowPage(id, pageId)
  local def = tabs[id]
  if not (def and def.pages and panel) then return end
  local page
  for _, pg in ipairs(def.pages) do if pg.id == pageId then page = pg end end
  if not page then return end
  if current ~= id then
    def._page = pageId
    if not panel:IsShown() then panel:Show() end
    return Hub:FocusTab(id)
  end
  def._page = pageId
  if GloomsHubDB then
    GloomsHubDB.lastPage = GloomsHubDB.lastPage or {}
    GloomsHubDB.lastPage[id] = pageId
  end
  paintNav(def)
  paintGlass(def)
  if def.showPage then def.showPage(pageId) end
end

function Hub:Open(id)
  if not panel then BuildPanel() end
  panel:Show()
  local target = id
  if not (target and tabs[target]) then
    target = GloomsHubDB and GloomsHubDB.lastTab
  end
  if not (target and tabs[target]) then
    target = ordered[1] and ordered[1].id
  end
  if target then Hub:FocusTab(target) end
end

-- Slash toggle semantics (SUITE-PLAN §3.3): while open on that tab (or with
-- no target tab) the slash closes; while open on a DIFFERENT tab it switches.
function Hub:ToggleWindow(id)
  if panel and panel:IsShown() then
    if not id or id == current then panel:Hide()
    else Hub:FocusTab(id) end
  else
    Hub:Open(id)
  end
end

-- ------------------------------------------------------------
-- /gloom — the neutral Suite slash (last-used tab)
-- ------------------------------------------------------------

-- /gloom px — the PIXEL GRID probe (2026-09-26). The glass pages look soft in
-- the game and razor-sharp in Figma; the suspicion (from Config.wtf, not yet
-- measured) is that one UI unit is a FRACTION of a screen pixel (~2.16 on the
-- owner's display), so every 1-unit line and every texture is resampled. This
-- prints the measured ratio and the Suite-window scales that would make it a
-- whole number. A slash subcommand, not a /run line (LESSONS: the 255-char chat limit).
local function pixelProbe()
  local pw, ph = GetPhysicalScreenSize()
  local uiH = UIParent:GetHeight()
  local ues = UIParent:GetEffectiveScale()
  local unit = ph / 768                    -- screen pixels per unit at effective scale 1
  Hub:Print(("screen %d x %d px · UIParent %.1f x %.1f units · uiScale %s (use %s)"):format(
    pw, ph, UIParent:GetWidth(), uiH, tostring(GetCVar("uiScale")), tostring(GetCVar("useUiScale"))))
  Hub:Print(("UIParent: 1 unit = %.3f px"):format(unit * ues))
  if panel then
    local es = panel:GetEffectiveScale()
    Hub:Print(("Suite window (scale %.2f): 1 unit = %.3f px · the window is %.0f x %.0f px"):format(
      panel:GetScale(), unit * es, SHELL_W * unit * es, SHELL_H * unit * es))
  else
    Hub:Print("Suite window: not built yet — open it once with /gloom, then run /gloom px again.")
  end
  local fits = {}
  for n = 1, 4 do
    local s = n / (unit * ues)             -- the window scale that makes 1 unit = n px
    if SHELL_W * n <= pw and SHELL_H * n <= ph then fits[#fits + 1] = ("%d px = %d%%"):format(n, math.floor(s * 100 + 0.5)) end
  end
  Hub:Print("Whole-pixel window scales on this screen: " .. (#fits > 0 and table.concat(fits, " · ") or "none"))
end

-- /gloom texttest — SCALED vs NATIVE text (2026-09-26). The window reaches whole
-- pixels by SetScale (~1.09 × the game's UI on the owner's 4K screen). If WoW
-- rasterises a scaled frame's text at the UNSCALED size and stretches it, all
-- our text is a little soft however sharp the lines are. This draws the same
-- words at the same final size two ways, side by side: LEFT inside a frame
-- scaled like the Suite window (2 px a unit), RIGHT in an unscaled frame with
-- the font size itself raised to match. Every text sits on a whole screen pixel
-- in both, so the only difference is the scaling. Run it again to close it.
local textTest
local function textTestToggle()
  if textTest then textTest:SetShown(not textTest:IsShown()); return end
  local ppu = pxPerUnit()
  local ue = UIParent:GetEffectiveScale()
  local sA = 2 / (ppu * ue)                       -- the Suite window's 2-px scale
  local W, H = 1100, 520                          -- the panel, in SCREEN PIXELS
  local f = CreateFrame("Frame", nil, UIParent)
  f:SetFrameStrata("TOOLTIP")
  local kP = ppu * ue                             -- px per unit of an unscaled child of UIParent
  f:SetSize(W / kP, H / kP)
  local pw, ph = GetPhysicalScreenSize()
  f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", math.floor((pw - W) / 2) / kP, math.floor((ph + H) / 2) / kP)
  local bg = f:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetColorTexture(0.06, 0.03, 0.12, 1)
  f:EnableMouse(true); f:SetScript("OnMouseDown", function(self) self:Hide() end)
  -- a column: a child frame at `scale`, its texts placed at whole screen pixels
  local function column(xpx, scale, native, title)
    local c = CreateFrame("Frame", nil, f)
    c:SetScale(scale)
    local k = kP * scale                          -- px per unit inside this column
    c:SetSize(520 / k, (H - 20) / k)
    c:SetPoint("TOPLEFT", f, "TOPLEFT", xpx / k, -10 / k)
    local y = 20
    local function line(font, size, text, gap, c1)
      local fs = c:CreateFontString(nil, "OVERLAY")
      local sz = native and size * sA or size    -- the unscaled side raises the font size instead
      UI.setFont(fs, font, sz)
      fs:SetTextColor((c1 or COLOR.paper).r, (c1 or COLOR.paper).g, (c1 or COLOR.paper).b)
      fs:SetPoint("TOPLEFT", c, "TOPLEFT", 20 / k, -y / k)
      fs:SetText(text)
      y = y + (gap or (size * 2 * 1.6))
      return fs
    end
    line(FONT.sa, 12, title, 40, COLOR.lime)
    line(FONT.mark, 18, "Appearance")
    line(FONT.sa, 14, "Haunt Progress Bar")
    line(FONT.sa, 12, "Horizontal Offset   Vertical Offset   Rotation")
    line(FONT.saM, 10, "NEW   COPY   RENAME   DELETE   CHOOSE", nil, COLOR.lilac)
    line(FONT.sa, 11, "OFF   ON   80px   100%   -265px", nil)
    line(FONT.saB, 11, "Garrote   Rupture   Envenom")
    line(FONT.sa, 11, "Unstable Affliction Bar   Corruption/Wither Missing")
  end
  column(20, sA, false, "LEFT — scaled frame (like the Suite window)")
  column(560, 1, true, "RIGHT — unscaled frame, bigger font")
  local mid = f:CreateTexture(nil, "ARTWORK"); mid:SetColorTexture(COLOR.violet.r, COLOR.violet.g, COLOR.violet.b, 1)
  mid:SetPoint("TOPLEFT", f, "TOPLEFT", 550 / kP, -20 / kP); mid:SetSize(2 / kP, (H - 40) / kP)
  textTest = f
  Hub:Print(("Text test: LEFT is scaled ×%.3f, RIGHT is unscaled with the font ×%.3f. Click the panel (or /gloom texttest) to close."):format(sA, sA))
end

SLASH_GLOOMSUITE1 = "/gloom"
SlashCmdList["GLOOMSUITE"] = function(msg)
  msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if msg == "px" then return pixelProbe() end
  if msg == "texttest" then return textTestToggle() end
  Hub:ToggleWindow()
end
