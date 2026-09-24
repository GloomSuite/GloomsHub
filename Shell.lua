-- ============================================================
-- Shell.lua — Gloom's Hub
-- The ONE Suite window: tab registry + chrome. Implements
-- CONTRACTS §2 exactly: GloomsHub:RegisterTab / :Open /
-- :FocusTab / :ShowPage (+ :ToggleWindow for the slash semantics).
-- Tabs' build(container) runs ONCE, lazily, on first show —
-- never at login.
--
-- ★ REDESIGNED AGAIN 2026-09-23 from the owner's Figma page "GloomSuite UI 2"
-- (Auras screens 722:130 …). The first redesign's light window with a tab strip,
-- a violet banner and a footer profile row (2026-09-21) is RETIRED. Now:
--   a near-black 1060 × 740 window; on the left a 250-wide SIDEBAR —
--     the "gloomSUITE" wordmark (art: its gradient is not a FontString thing)
--     the TOOL SWITCHER, a band in the tool's accent: "gloom<TOOL> ▾" opens the
--       list of tools (the tab strip's replacement)
--     the tool's PAGES, one row each, the chosen one in the accent with a ▸
--     the tool's PROFILE control at the foot (UI.profileStack)
--   and to the right the tool's CONTENT, 810 × 740, with the page's title in
--   Michroma over it at (290, 26).
-- A tool that registers `pages` + `accent` gets all of that (a PAGED tool). A
-- tool that has not been rebuilt yet (a LEGACY tool) keeps its old layout: it is
-- drawn on the old light plate, SCALED to fit the 810 it now has — so it stays
-- usable, just smaller, until its own stage. No legacy tool changed for this.
-- ============================================================

local Hub = GloomsHub
local UI, COLOR, FONT = Hub.UI, Hub.COLOR, Hub.FONT

local SHELL_W, SHELL_H = 1060, 740
local SIDE_W    = 250                   -- the sidebar
local CONTENT_W = SHELL_W - SIDE_W      -- 810: a tool's width now
local BAND_Y, BAND_H = 60, 36           -- the tool switcher
local NAV_Y     = 96                    -- the page list; the sidebar's gradient starts here too
local NAV_TEXT_R = 220                  -- every page name ends here (right-aligned)
local TITLE_X, TITLE_Y = 290, 26        -- the page title
local PROF_X, PROF_Y   = 20, 641        -- the profile control
-- The window wordmark is art (tools/gen-kit-art.py): 354 × 45 ink on a 512 × 64
-- canvas, drawn at half size — exactly the mock's 177-wide text box.
local WORDMARK = Hub.MEDIA .. "ui\\suite-wordmark.png"
local WM_W, WM_H, WM_U, WM_V = 177, 22.5, 354 / 512, 45 / 64
-- A LEGACY tool's container keeps the size it was pinned to (CONTRACTS §2): with
-- a profile row 1060 × 585, without one 860 × 650 (the 860 × 626 pin fits).
local LEGACY_PROFILE_W, LEGACY_PROFILE_H = 1060, 585
local LEGACY_W, LEGACY_H = 860, 650

-- The strip's order is the MOCKS' (Auras · Bars · Unit Frames · Portraits ·
-- Overlays · Media), fixed here so no tool's registration can reorder it;
-- an unknown id falls back to its own `order`.
local TAB_ORDER = { auras = 10, bars = 20, unitframes = 30, portraits = 40, overlays = 50, media = 90 }

local tabs = {}       -- id → def
local ordered = {}    -- defs sorted by order
local panel, side, band, nav, pageTitle, legacyPlate
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
-- The ladder is EUI's, from his own reference: a large-grain dial stepping
-- through presets rather than a continuous scrub, because at arbitrary
-- fractional scales the kit's 1px rules and the dial's 3px tick pitch
-- resample into mush and he would be judging blur, not size.
--
-- ⚠ The dial is a CHILD OF THE WINDOW and scales with it, like everything
-- else in the window. The window therefore resizes only when the drag is
-- RELEASED (the owner, 2026-09-22: "it's fine if the window resize doesn't
-- happen until after the drag is released"). That is not a shortcut — it is
-- what makes a dial inside its own subject work at all: UI.dial captures its
-- drag origin in its own effective-scale units, so rescaling mid-drag would
-- leave the origin on a stale ruler and the value would run away, and the
-- dial would slide out from under the cursor as it went. The ticks and the
-- read-out still follow the pull live; only the window waits.
--
-- ⚠ Do NOT assume the screen's size. UIParent's height in UI units is
-- 768 / uiScale, so it is 768 only at uiScale 1.0 and well past 1200 at the
-- low UI scales a high-res display wants — the owner's window is about a
-- QUARTER of his screen at 100%. The ladder is MEASURED against UIParent at
-- build and trimmed to the presets that fit, which is also why no escape
-- hatch is needed: the dial cannot push its own corner off the screen.
--
-- If the redesign survives, this becomes a real control on the Settings tab.
-- ------------------------------------------------------------

local ALL_SCALES = { 0.75, 0.90, 1.00, 1.10, 1.25, 1.50, 2.00 }
local SCALES = ALL_SCALES          -- trimmed to what fits, at build
local scaleDial
local pendingScale = false   -- a value picked mid-drag, applied on release

local function clampIdx(i)
  i = math.floor((tonumber(i) or 1) + 0.5)
  return math.max(1, math.min(#SCALES, i))
end

local function scaleLabel(i) return math.floor(SCALES[clampIdx(i)] * 100 + 0.5) .. "%" end

-- The index nearest the SAVED scale — the VALUE is stored, not the index, so
-- trimming the ladder can never move his window to a different size.
local function scaleIndex()
  local want = (GloomsHubDB and GloomsHubDB.uiScale) or 1.00
  local best, bestD = 1, math.huge
  for i, v in ipairs(SCALES) do
    local d = math.abs(v - want)
    if d < bestD then best, bestD = i, d end
  end
  return best
end

-- Keep only the presets this screen can hold. A window larger than the screen
-- cannot be clamped back into it — SetClampedToScreen pins a corner and the
-- rest, the dial included, goes where no mouse can reach.
local function trimLadder()
  local fit = math.min(UIParent:GetWidth() / SHELL_W, UIParent:GetHeight() / SHELL_H)
  local out = {}
  for _, v in ipairs(ALL_SCALES) do
    if v <= fit + 0.001 then out[#out + 1] = v end
  end
  if #out == 0 then out[1] = ALL_SCALES[1] end   -- a screen smaller than 75% of the window
  SCALES = out
  if #out < #ALL_SCALES then
    Hub:Print(("Scale dial: your screen fits the %d × %d window up to %d%%, so the ladder stops at %s.")
      :format(SHELL_W, SHELL_H, math.floor(fit * 100), scaleLabel(#out)))
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

-- Scale about the window's CENTRE: SetPoint offsets resolve in the anchored
-- frame's own effective scale, so the screen-space centre has to be recomputed
-- into the new units. Without this the window walks across the screen.
local function applyScale()
  if not panel then return end
  local s = SCALES[scaleIndex()]
  local x, y = panel:GetCenter()
  local old = panel:GetEffectiveScale()
  panel:SetScale(s)
  local new = panel:GetEffectiveScale()
  if x and y and new > 0 then
    local k = old / new
    panel:ClearAllPoints()
    panel:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x * k, y * k)
  end
  scaleDetached(s)
end

-- ------------------------------------------------------------
-- Accent — a tool's own colour; the suite blue for one without
-- ------------------------------------------------------------

local function accentOf(def) return (def and def.accent) or COLOR.sky end

-- ------------------------------------------------------------
-- The page list (a PAGED tool's `pages`)
-- ------------------------------------------------------------
-- The mock's rows (node 718:29): the first 33 tall, the rest 32, each with a 1px
-- rule in the accent along its foot except the last; the name in Saira 12,
-- right-aligned to x=220, white; the chosen page in the accent with a white ▸ at
-- x=240. A hovered row borrows the accent (not in the mock — the rows had to say
-- they are clickable somehow).
local navRows = {}

local function navRow(i)
  local r = navRows[i]
  if r then return r end
  r = CreateFrame("Button", nil, nav)
  r.text = UI.newText(r, FONT.sa, 12, COLOR.paper, "RIGHT")
  r.text:SetPoint("RIGHT", r, "TOPLEFT", NAV_TEXT_R, -16)
  r.rule = r:CreateTexture(nil, "ARTWORK"); r.rule:SetHeight(1)
  r.rule:SetPoint("BOTTOMLEFT", 0, 0); r.rule:SetPoint("BOTTOMRIGHT", 0, 0)
  r.tri = r:CreateTexture(nil, "ARTWORK"); r.tri:SetTexture(UI.TRI); r.tri:SetSize(10, 10)
  r.tri:SetRotation(math.pi / 2)           -- tri.png points down; +90° = right
  r.tri:SetPoint("CENTER", r, "TOPLEFT", 245, -16)
  r:SetScript("OnEnter", function(self) if not self._on then self.text:SetTextColor(self._ac.r, self._ac.g, self._ac.b) end end)
  r:SetScript("OnLeave", function(self) if not self._on then self.text:SetTextColor(1, 1, 1) end end)
  navRows[i] = r
  return r
end

local function paintNav(def)
  local pages = (def and def.pages) or {}
  local ac = accentOf(def)
  local top = 0
  for i, pg in ipairs(pages) do
    local r = navRow(i)
    local h = (i == 1) and 33 or 32
    r:ClearAllPoints(); r:SetPoint("TOPLEFT", 0, -top); r:SetSize(SIDE_W, h)
    r._ac, r._on = ac, (pg.id == def._page)
    r.text:SetText(pg.title or pg.id)
    if r._on then r.text:SetTextColor(ac.r, ac.g, ac.b) else r.text:SetTextColor(1, 1, 1) end
    r.tri:SetShown(r._on)
    r.rule:SetColorTexture(ac.r, ac.g, ac.b, 1); r.rule:SetShown(i < #pages)
    r:SetScript("OnClick", function() Hub:ShowPage(def.id, pg.id) end)
    r:Show()
    top = top + h
  end
  for i = #pages + 1, #navRows do navRows[i]:Hide() end
end

-- Everything in the sidebar that wears the focused tool's colour.
local function paintSide(def)
  local ac = accentOf(def)
  band.fill:SetColorTexture(ac.r, ac.g, ac.b, 1)
  band.mark:SetMark(def.wordmark or def.title or def.id:upper())
  -- The mock's sidebar (718:41): the accent at 10% at the top, the suite blue at
  -- 10% at the foot. SetGradient's first colour is the BOTTOM of a vertical one.
  side.grad:SetGradient("VERTICAL",
    CreateColor(COLOR.sky.r, COLOR.sky.g, COLOR.sky.b, 0.1),
    CreateColor(ac.r, ac.g, ac.b, 0.1))
  pageTitle:SetTextColor(ac.r, ac.g, ac.b)
  paintNav(def)
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

  -- The light plate a LEGACY tool still draws on (the first redesign's
  -- transition theme needs it: its text is dark), right of the sidebar.
  legacyPlate = panel:CreateTexture(nil, "BACKGROUND", nil, -7)
  legacyPlate:SetPoint("TOPLEFT", SIDE_W, 0); legacyPlate:SetPoint("BOTTOMRIGHT", 0, 0)
  legacyPlate:SetColorTexture(COLOR.plate.r, COLOR.plate.g, COLOR.plate.b, 1)
  legacyPlate:Hide()

  -- SIDEBAR
  side = CreateFrame("Frame", nil, panel)
  side:SetPoint("TOPLEFT", 0, 0); side:SetSize(SIDE_W, SHELL_H)
  side.grad = side:CreateTexture(nil, "BACKGROUND")
  side.grad:SetPoint("TOPLEFT", 0, -NAV_Y); side.grad:SetPoint("BOTTOMRIGHT", 0, 0)
  side.grad:SetColorTexture(1, 1, 1, 1)

  -- The wordmark (the mock's text box is 177 × 31 at 73,14; the art is the ink,
  -- centred on that box) and, over the sidebar's top, the drag handle — which
  -- also carries the version line as its hover-help, as the old wordmark did.
  local wm = side:CreateTexture(nil, "ARTWORK")
  wm:SetTexture(WORDMARK); wm:SetTexCoord(0, WM_U, 0, WM_V); wm:SetSize(WM_W, WM_H)
  wm:SetPoint("LEFT", side, "TOPLEFT", 73, -29.5)
  local drag = CreateFrame("Frame", nil, side)
  drag:SetPoint("TOPLEFT", 0, 0); drag:SetSize(SIDE_W, BAND_Y)
  drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
  drag:SetScript("OnDragStart", function() if panel:IsMovable() then panel:StartMoving() end end)
  drag:SetScript("OnDragStop", function() panel:StopMovingOrSizing() end)
  UI.attachTip(drag, "Gloom Suite", function() return Hub:VersionLine() end)

  -- The TOOL SWITCHER (node 691:14197): the band in the accent, "gloom" white +
  -- the tool in the window's near-black, Michroma 14, ending at x=224, then the
  -- white ▾ at x=230. Click → the list of tools.
  band = CreateFrame("Button", nil, side)
  band:SetPoint("TOPLEFT", 0, -BAND_Y); band:SetSize(SIDE_W, BAND_H)
  band.fill = band:CreateTexture(nil, "BACKGROUND"); band.fill:SetAllPoints()
  band.hot = band:CreateTexture(nil, "BORDER"); band.hot:SetAllPoints()
  band.hot:SetColorTexture(1, 1, 1, 0.08); band.hot:Hide()
  band.mark = UI.wordmark(band, "", 14, { prefixColor = COLOR.paper, suffixColor = COLOR.void, justify = "RIGHT" })
  band.mark:SetPoint("RIGHT", band, "LEFT", 224, 0)
  local caret = band:CreateTexture(nil, "ARTWORK"); caret:SetTexture(UI.TRI); caret:SetSize(10, 10)
  caret:SetPoint("LEFT", band, "LEFT", 230, 0)
  band:SetScript("OnEnter", function(self) self.hot:Show() end)
  band:SetScript("OnLeave", function(self) self.hot:Hide() end)
  band:SetScript("OnClick", function(self)
    local list = {}
    for _, d in ipairs(ordered) do list[#list + 1] = { value = d.id, label = d.title or d.id } end
    UI.openList(self, list, current, function(v) Hub:FocusTab(v) end)
  end)

  nav = CreateFrame("Frame", nil, side)
  nav:SetPoint("TOPLEFT", 0, -NAV_Y); nav:SetSize(SIDE_W, 10)

  -- The page's title, over the tool's content. Its own frame so it draws above
  -- the container (a region on `panel` would sit under every child frame).
  local titleHolder = CreateFrame("Frame", nil, panel)
  titleHolder:SetAllPoints(); titleHolder:SetFrameLevel(panel:GetFrameLevel() + 50)
  pageTitle = UI.newText(titleHolder, FONT.mark, 14, COLOR.sky, "LEFT")
  pageTitle:SetPoint("TOPLEFT", TITLE_X, -TITLE_Y)
  pageTitle:Hide()

  -- ★ TEMPORARY: the unlabelled scale dial. It lived in the old footer's lower
  -- right; the second redesign has no footer, and that corner is now the tool's
  -- content, so it moved into the SIDEBAR, above the profile control — dark,
  -- bare (ticks and a read-out, nothing else), on every tab.
  trimLadder()
  scaleDial = UI.dial(side, {
    dark = true, bare = true,
    min = 1, max = #SCALES, step = 1,
    dragPx = 300,                      -- large grain: ~50px of pull per preset
    fmt = scaleLabel,
    get = scaleIndex,
    set = function(v)
      local i = clampIdx(v)
      if GloomsHubDB then GloomsHubDB.uiScale = SCALES[i] end
      -- Mid-drag the value is banked, not applied; the wheel and a typed
      -- number have no drag and so land at once.
      local st = scaleDial and scaleDial.strip
      if st and st._drag then pendingScale = true else applyScale() end
    end,
  })
  -- The release. NOT OnMouseUp: UI.dial also ends a drag from its OnUpdate
  -- when the button comes up away from the strip, and that path fires no
  -- mouse-up here. Watching `_drag` clear catches every way a drag can end.
  scaleDial.strip:HookScript("OnUpdate", function(self)
    if pendingScale and not self._drag then
      pendingScale = false
      applyScale()
    end
  end)
  scaleDial:SetPoint("TOPLEFT", side, "TOPLEFT", PROF_X, -596)
  applyScale()

  tinsert(UISpecialFrames, "GloomsSuiteWindow")   -- Escape closes it
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
    -- PAGED: the 810 × 740 right of the sidebar, on the dark window. The accent
    -- rides on the container so every dark-kit widget inside finds it.
    c:SetPoint("TOPLEFT", SIDE_W, 0); c:SetSize(CONTENT_W, SHELL_H)
    c._gloomAccent = accentOf(def)
  else
    -- LEGACY: the size it was pinned to, scaled to the 810 it has now. ⚠ A
    -- scaled frame's SetPoint offsets are in its OWN units, hence SIDE_W / k.
    local w, h = LEGACY_W, LEGACY_H
    if def.profile then w, h = LEGACY_PROFILE_W, LEGACY_PROFILE_H end
    local k = CONTENT_W / w
    c:SetSize(w, h); c:SetScale(k)
    c:SetPoint("TOPLEFT", panel, "TOPLEFT", SIDE_W / k, 0)
  end
  c:Hide()
  def._container = c
  def.build(c)   -- ONCE, lazily, on first show
  return c
end

-- The sidebar's profile control, built once per tab that supplies `profile`.
local function EnsureProfile(def)
  if def._profileStack or not def.profile then return def._profileStack end
  local st = UI.profileStack(side, def.profile, def.wordmark or def.title or "", accentOf(def))
  st.frame:SetPoint("TOPLEFT", PROF_X, -PROF_Y)
  def._profileStack = st
  return st
end

function Hub:FocusTab(id)
  local def = tabs[id]
  if not def or not panel then return end
  if current and tabs[current] then
    local old = tabs[current]
    if old._container then old._container:Hide() end
    if old._profileStack then old._profileStack.frame:Hide() end
  end
  current = id
  if GloomsHubDB then GloomsHubDB.lastTab = id end
  legacyPlate:SetShown(not def.pages)
  local c = EnsureContainer(def)
  -- A paged tool opens on the page it was last on, else its first.
  if def.pages and #def.pages > 0 then
    local want = def._page or (GloomsHubDB and GloomsHubDB.lastPage and GloomsHubDB.lastPage[id])
    def._page = def.pages[1].id
    for _, pg in ipairs(def.pages) do if pg.id == want then def._page = want end end
  end
  paintSide(def)
  c:Show()
  local st = EnsureProfile(def)
  if st then st.frame:Show(); st:refresh() end
  if def.pages then Hub:ShowPage(id, def._page) else pageTitle:Hide() end
  if def.refresh then def.refresh() end
end

-- Show one page of a PAGED tool: its title, its row in the sidebar, and the
-- tool's own `showPage(pageId)`. Focuses the tool first if it is not in front.
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
  pageTitle:SetText(page.title or pageId); pageTitle:Show()
  paintNav(def)
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

SLASH_GLOOMSUITE1 = "/gloom"
SlashCmdList["GLOOMSUITE"] = function()
  Hub:ToggleWindow()
end
