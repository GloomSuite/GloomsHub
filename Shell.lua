-- ============================================================
-- Shell.lua — Gloom's Hub
-- The ONE Suite window: tab registry + chrome. Implements
-- CONTRACTS §2 exactly: GloomsHub:RegisterTab / :Open /
-- :FocusTab (+ :ToggleWindow for the slash semantics).
-- Tabs' build(container) runs ONCE, lazily, on first show —
-- never at login.
--
-- ★ REDESIGNED 2026-09-21 (BACKLOG 16, stage 1) from the owner's Figma mocks:
-- a 1060 × 740 light-grey window in three bands —
--   HEADER  (54)  "gloomSUITE" wordmark left · the tab buttons + X right
--   BANNER  (36)  a 250px violet block carrying the TOOL's wordmark, the rest dim
--   FOOTER  (65)  a line, then the tool's PROFILE row (label · picker · buttons)
-- The content area is what is left: 1060 × 585 for a tab that supplies a
-- `profile` api (the footer is drawn for it), 1060 × 650 for one that does not
-- (no footer; the pre-redesign tabs keep their pinned 860 × 626 this way).
-- ============================================================

local Hub = GloomsHub
local UI, COLOR, FONT = Hub.UI, Hub.COLOR, Hub.FONT

local SHELL_W, SHELL_H = 1060, 740
local HEAD_H   = 54
local BANNER_H = 36
local BANNER_W = 250          -- the violet block
local FOOT_H   = 65           -- the line sits at 740 - 65 = 675
local CONTENT_Y = -(HEAD_H + BANNER_H)   -- -90

-- The strip's order is the MOCKS' (Auras · Bars · Unit Frames · Portraits ·
-- Overlays · Media), fixed here so no tool's registration can reorder it;
-- an unknown id falls back to its own `order`.
local TAB_ORDER = { auras = 10, bars = 20, unitframes = 30, portraits = 40, overlays = 50, media = 90 }

local tabs = {}       -- id → def
local ordered = {}    -- defs sorted by order
local panel, header, banner, footer
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
-- the first question in any support exchange. The mocks have no footer version
-- line, so since the redesign it is the hover-help of the window's wordmark.
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
-- Tab strip — right-aligned, the X last, in tab order left to right
-- ------------------------------------------------------------

local function RebuildTabStrip()
  if not header then return end
  local right = header.close
  for i = #ordered, 1, -1 do
    local def = ordered[i]
    local b = def._tabBtn
    if not b then
      b = UI.button(header, def.title or def.id:upper(), { kind = "action", onClick = function() Hub:FocusTab(def.id) end })
      def._tabBtn = b
    end
    b:ClearAllPoints()
    b:SetPoint("RIGHT", right, "LEFT", -6, 0)
    b:SetActive(def.id == current)
    right = b
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
  local plate = panel:CreateTexture(nil, "BACKGROUND")
  plate:SetAllPoints(); plate:SetColorTexture(COLOR.plate.r, COLOR.plate.g, COLOR.plate.b, 1)

  -- HEADER: the wordmark, the tab strip, the X.
  header = CreateFrame("Frame", nil, panel)
  header:SetPoint("TOPLEFT", 0, 0); header:SetPoint("TOPRIGHT", 0, 0); header:SetHeight(HEAD_H)
  local mark = UI.wordmark(header, "SUITE", 22)
  mark:SetPoint("TOPLEFT", 20, -7)
  local markHit = CreateFrame("Frame", nil, header)   -- a FontString cannot take a hover
  markHit:SetPoint("TOPLEFT", mark, "TOPLEFT", 0, 0); markHit:SetPoint("BOTTOMRIGHT", mark, "BOTTOMRIGHT", 0, 0)
  UI.attachTip(markHit, "Gloom Suite", function() return Hub:VersionLine() end)
  header.close = UI.button(header, "X", { kind = "quiet", padX = 8, onClick = function() panel:Hide() end })
  header.close:SetPoint("TOPRIGHT", -20, -15)

  -- Drag strip: the header band, minus the buttons (they sit above it).
  local drag = CreateFrame("Frame", nil, panel)
  drag:SetPoint("TOPLEFT", 0, 0); drag:SetPoint("TOPRIGHT", 0, 0); drag:SetHeight(HEAD_H)
  drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
  drag:SetScript("OnDragStart", function() if panel:IsMovable() then panel:StartMoving() end end)
  drag:SetScript("OnDragStop", function() panel:StopMovingOrSizing() end)
  drag:SetFrameLevel(header:GetFrameLevel())
  header:SetFrameLevel(drag:GetFrameLevel() + 1)

  -- BANNER: the tool's wordmark on violet, the rest of the row dim.
  banner = CreateFrame("Frame", nil, panel)
  banner:SetPoint("TOPLEFT", 0, -HEAD_H); banner:SetPoint("TOPRIGHT", 0, -HEAD_H); banner:SetHeight(BANNER_H)
  local block = banner:CreateTexture(nil, "BACKGROUND")
  block:SetPoint("TOPLEFT"); block:SetPoint("BOTTOMLEFT"); block:SetWidth(BANNER_W)
  block:SetColorTexture(COLOR.violet.r, COLOR.violet.g, COLOR.violet.b, 1)
  local rest = banner:CreateTexture(nil, "BACKGROUND")
  rest:SetPoint("TOPLEFT", BANNER_W, 0); rest:SetPoint("BOTTOMRIGHT")
  rest:SetColorTexture(COLOR.dim.r, COLOR.dim.g, COLOR.dim.b, COLOR.dim.a)
  banner.mark = UI.wordmark(banner, "", 14, { prefixColor = COLOR.paper, suffixColor = COLOR.paper, justify = "RIGHT" })
  banner.mark:SetPoint("RIGHT", banner, "LEFT", BANNER_W - 20, 0)

  -- FOOTER: the line and the slot the focused tab's profile row sits in.
  footer = CreateFrame("Frame", nil, panel)
  footer:SetPoint("BOTTOMLEFT", 0, 0); footer:SetPoint("BOTTOMRIGHT", 0, 0); footer:SetHeight(FOOT_H)
  local line = footer:CreateTexture(nil, "ARTWORK")
  line:SetPoint("TOPLEFT", 0, 0); line:SetPoint("TOPRIGHT", 0, 0); line:SetHeight(1)
  line:SetColorTexture(COLOR.ink.r, COLOR.ink.g, COLOR.ink.b, 1)
  footer:Hide()

  tinsert(UISpecialFrames, "GloomsSuiteWindow")   -- Escape closes it
  RebuildTabStrip()
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
  if panel then RebuildTabStrip() end
end

local function EnsureContainer(def)
  if def._container then return def._container end
  local c = CreateFrame("Frame", nil, panel)
  c:SetPoint("TOPLEFT", 0, CONTENT_Y)
  -- A tab with a profile api gets the footer and stops above it; one without
  -- runs to the bottom of the window (the pre-redesign tabs' 626 fits there).
  c:SetPoint("BOTTOMRIGHT", 0, def.profile and FOOT_H or 0)
  c:Hide()
  def._container = c
  def.build(c)   -- ONCE, lazily, on first show
  return c
end

-- The footer row is built once per tab that supplies `profile`, on first focus.
local function EnsureProfileRow(def)
  if def._profileRow or not def.profile then return def._profileRow end
  local row = UI.profileRow(footer, def.profile, def.wordmark or def.title or "")
  row.frame:SetPoint("TOPLEFT", 53, -20); row.frame:SetPoint("TOPRIGHT", -20, -20)
  def._profileRow = row
  return row
end

function Hub:FocusTab(id)
  local def = tabs[id]
  if not def or not panel then return end
  if current and tabs[current] then
    local old = tabs[current]
    if old._container then old._container:Hide() end
    if old._profileRow then old._profileRow.frame:Hide() end
  end
  local c = EnsureContainer(def)
  c:Show()
  current = id
  if GloomsHubDB then GloomsHubDB.lastTab = id end
  for _, d in ipairs(ordered) do
    if d._tabBtn then d._tabBtn:SetActive(d.id == id) end
  end
  banner.mark:SetMark(def.wordmark or def.title or def.id:upper())
  local row = EnsureProfileRow(def)
  footer:SetShown(row ~= nil)
  if row then row.frame:Show(); row:refresh() end
  if def.refresh then def.refresh() end
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
