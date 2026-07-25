-- ============================================================
-- Shell.lua — Gloom's Hub
-- The ONE Suite window: tab registry + chrome. Implements
-- CONTRACTS §2 exactly: GloomsHub:RegisterTab / :Open /
-- :FocusTab (+ :ToggleWindow for the slash semantics).
-- Tabs' build(container) runs ONCE, lazily, on first show —
-- never at login. Chrome is the family language, lifted from
-- GB Config.lua's BuildPanel.
-- ============================================================

local Hub = GloomsHub
local UI, COLOR, FONT = Hub.UI, Hub.COLOR, Hub.FONT

-- Sized to host GB's three-pane layout (820 wide) inside the
-- content area come Phase C, plus the tab strip row.
local SHELL_W, SHELL_H = 860, 680
local TITLE_DIV_Y = -48          -- title bar divider (family constant)
local TAB_STRIP_H = 34
local FOOTER_H = 30
local WHITE = "Interface\\Buttons\\WHITE8X8"

local tabs = {}       -- id → def
local ordered = {}    -- defs sorted by order
local panel, tabStrip
local current         -- id of the focused tab

function Hub:Version()
  local v = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("GloomsHub", "Version")
  if type(v) ~= "string" or v == "" or v:find("@") then return "dev" end
  return v
end

-- ------------------------------------------------------------
-- Tab strip
-- ------------------------------------------------------------

local function RebuildTabStrip()
  if not tabStrip then return end
  local prev
  for _, def in ipairs(ordered) do
    local b = def._tabBtn
    if not b then
      b = UI.flatButton(tabStrip, 70, 24, COLOR.purple, def.title or def.id:upper(), 13)
      b:SetBase(0.35)
      b:SetWidth(math.max(70, b.text:GetStringWidth() + 28))
      b:SetScript("OnClick", function() Hub:FocusTab(def.id) end)
      def._tabBtn = b
    end
    b:ClearAllPoints()
    if prev then b:SetPoint("LEFT", prev, "RIGHT", 6, 0)
    else b:SetPoint("LEFT", tabStrip, "LEFT", 16, 0) end
    b:SetActive(def.id == current)
    prev = b
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
  -- would pin us permanently above GB/GA (they aren't toplevel, so they could
  -- never raise back). Their own click-to-raise arrives when they mount as
  -- tabs (Phases C/D) and the standalone windows disappear.
  panel:HookScript("OnShow", function(self) self:Raise() end)
  panel:HookScript("OnMouseDown", function(self) self:Raise() end)
  UI.skinPlate(panel)
  -- Signature warm bottom glow: orange gradient fading up over the lower ~55%.
  local glow = panel:CreateTexture(nil, "BORDER")
  glow:SetTexture(WHITE)
  glow:SetPoint("BOTTOMLEFT", 1, 1); glow:SetPoint("BOTTOMRIGHT", -1, 1); glow:SetHeight(SHELL_H * 0.55)
  glow:SetGradient("VERTICAL",
    CreateColor(COLOR.orange.r, COLOR.orange.g, COLOR.orange.b, 0.11),
    CreateColor(COLOR.orange.r, COLOR.orange.g, COLOR.orange.b, 0))
  UI.addEdges(panel, COLOR.rim, 1)

  -- Title bar: the GS monogram (Media/ui/logo.png — the owner's Gloom Suite logo,
  -- 2026-07-24; 197×295 art shown at native aspect) left of the wordmark.
  local logo = panel:CreateTexture(nil, "ARTWORK")
  logo:SetTexture(Hub.MEDIA .. "ui\\logo.png")
  logo:SetSize(19, 28)
  logo:SetPoint("TOPLEFT", 14, -10)
  local mark = UI.newText(panel, FONT.title, 21, { r = 1, g = 1, b = 1 }, "LEFT")
  mark:SetPoint("LEFT", logo, "RIGHT", 9, 0); mark:SetText("GLOOM SUITE")
  local close = UI.flatButton(panel, 22, 20, COLOR.heroic, "X", 12)
  close:SetPoint("TOPRIGHT", -8, -13); close:SetScript("OnClick", function() panel:Hide() end)
  local tdiv = UI.hLine(panel)
  tdiv:SetPoint("TOPLEFT", 0, TITLE_DIV_Y); tdiv:SetPoint("TOPRIGHT", 0, TITLE_DIV_Y)

  -- Drag strip (title bar)
  local drag = CreateFrame("Frame", nil, panel)
  drag:SetPoint("TOPLEFT", 2, -2); drag:SetPoint("TOPRIGHT", -34, -2); drag:SetHeight(44)
  drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
  drag:SetScript("OnDragStart", function() if panel:IsMovable() then panel:StartMoving() end end)
  drag:SetScript("OnDragStop", function() panel:StopMovingOrSizing() end)

  -- Tab strip row under the title bar, its own divider beneath.
  tabStrip = CreateFrame("Frame", nil, panel)
  tabStrip:SetPoint("TOPLEFT", 0, TITLE_DIV_Y)
  tabStrip:SetPoint("TOPRIGHT", 0, TITLE_DIV_Y)
  tabStrip:SetHeight(TAB_STRIP_H)
  local sdiv = UI.hLine(panel)
  sdiv:SetPoint("TOPLEFT", 0, TITLE_DIV_Y - TAB_STRIP_H)
  sdiv:SetPoint("TOPRIGHT", 0, TITLE_DIV_Y - TAB_STRIP_H)

  -- Footer: divider + version (generic by design — see SUITE-PLAN §6).
  local fdiv = UI.hLine(panel)
  fdiv:SetPoint("BOTTOMLEFT", 0, FOOTER_H); fdiv:SetPoint("BOTTOMRIGHT", 0, FOOTER_H)
  local ver = UI.newText(panel, FONT.body, 10.5, COLOR.mute, "LEFT")
  ver:SetPoint("BOTTOMLEFT", 16, 10); ver:SetText("Gloom Suite — GloomsHub " .. Hub:Version())

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
  table.sort(ordered, function(a, b) return (a.order or 50) < (b.order or 50) end)
  if panel then RebuildTabStrip() end
end

local function EnsureContainer(def)
  if def._container then return def._container end
  local c = CreateFrame("Frame", nil, panel)
  c:SetPoint("TOPLEFT", 0, TITLE_DIV_Y - TAB_STRIP_H - 1)
  c:SetPoint("BOTTOMRIGHT", 0, FOOTER_H + 1)
  c:Hide()
  def._container = c
  def.build(c)   -- ONCE, lazily, on first show
  return c
end

function Hub:FocusTab(id)
  local def = tabs[id]
  if not def or not panel then return end
  if current and tabs[current] and tabs[current]._container then
    tabs[current]._container:Hide()
  end
  local c = EnsureContainer(def)
  c:Show()
  current = id
  if GloomsHubDB then GloomsHubDB.lastTab = id end
  for _, d in ipairs(ordered) do
    if d._tabBtn then d._tabBtn:SetActive(d.id == id) end
  end
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
