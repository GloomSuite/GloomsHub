-- ============================================================
-- MinimapButton.lua — Gloom's Hub
-- The ONE suite launcher (Phase C QA follow-up, the owner's call
-- 2026-07-24): a GS-icon minimap button via LibDBIcon (a
-- LibDataBroker launcher), so minimap-button collectors treat
-- it as a first-class citizen. Left-click = /gloom semantics
-- (toggle the Suite window on the last-used tab). The per-tool
-- buttons retire as their tools mount tabs — GB's is gone with
-- this change; GA's goes at Phase D. Same LibDBIcon + self-
-- contained-fallback pattern as the family's old buttons.
-- Placement/visibility live in GloomsHubDB.minimap.
-- ============================================================

local ADDON = ...
local Hub = GloomsHub

local LDB     = LibStub and LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)

local ICON = Hub.MEDIA .. "ui\\minimap.png"

-- Shared behavior ----------------------------------------------------------

local function onClick()
  Hub:ToggleWindow()   -- neutral: last-used tab (the /gloom semantics)
end

local function fillTooltip(tt)
  tt:SetText("Gloom Suite", 0.576, 0.42, 1)  -- 936bff purple
  tt:AddLine("Left-click: open the Suite window (last-used tab)", 0.8, 0.8, 0.8)
end

-- LibDBIcon writes hide + minimapPos into GloomsHubDB.minimap (account-wide,
-- so the button placement/visibility is shared across characters).
local function ensureDB()
  if not GloomsHubDB then return false end
  GloomsHubDB.minimap = GloomsHubDB.minimap or {}
  return true
end

-- LibDBIcon path -----------------------------------------------------------

local dataObject

local function registerBroker()
  dataObject = LDB:NewDataObject(ADDON, {
    type = "launcher",
    label = "Gloom Suite",
    icon = ICON,
    OnClick = onClick,
    OnTooltipShow = fillTooltip,
  })
  LDBIcon:Register(ADDON, dataObject, GloomsHubDB.minimap)
end

-- Self-contained fallback (used only if the libs are ever missing) ----------

local btn

local function position(angle)
  local rad = math.rad(angle)
  local r = (Minimap:GetWidth() / 2) + 5
  btn:ClearAllPoints()
  btn:SetPoint("CENTER", Minimap, "CENTER", math.cos(rad) * r, math.sin(rad) * r)
end

local function onDragUpdate()
  local mx, my = Minimap:GetCenter()
  local scale = Minimap:GetEffectiveScale()
  local px, py = GetCursorPosition()
  px, py = px / scale, py / scale
  local angle = math.deg(math.atan2(py - my, px - mx))
  position(angle)
  GloomsHubDB.minimap.minimapPos = angle
end

local function buildFallback()
  btn = CreateFrame("Button", "GloomsHubMinimapButton", Minimap)
  btn:SetFrameStrata("MEDIUM")
  btn:SetFrameLevel(8)
  btn:SetSize(31, 31)
  btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  btn:RegisterForDrag("LeftButton")

  local icon = btn:CreateTexture(nil, "ARTWORK")
  icon:SetTexture(ICON)
  icon:SetSize(20, 20)
  icon:SetPoint("CENTER", 0, 1)

  local border = btn:CreateTexture(nil, "OVERLAY")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetSize(53, 53)
  border:SetPoint("TOPLEFT")

  btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  btn:SetScript("OnClick", onClick)
  btn:SetScript("OnDragStart", function() btn:SetScript("OnUpdate", onDragUpdate) end)
  btn:SetScript("OnDragStop", function() btn:SetScript("OnUpdate", nil) end)

  btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    fillTooltip(GameTooltip)
    GameTooltip:AddLine("Drag: move around the minimap", 0.55, 0.55, 0.55)
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

  position(GloomsHubDB.minimap.minimapPos or 200)
end

-- Public API ---------------------------------------------------------------

local function useLib()
  return LDB and LDBIcon
end

-- Create the button at login unless the user has hidden it.
function Hub:InitMinimapButton()
  if not ensureDB() then return end
  if useLib() then
    if not dataObject then registerBroker() end
    if GloomsHubDB.minimap.hide then LDBIcon:Hide(ADDON) else LDBIcon:Show(ADDON) end
  else
    if btn then return end
    if not GloomsHubDB.minimap.hide then buildFallback() end
  end
end

-- Toggle the button on/off (persisted). Returns shown state. No slash command
-- — wire this to a Suite-window control if the owner ever wants to hide it.
function Hub:ToggleMinimapButton()
  if not ensureDB() then return end
  GloomsHubDB.minimap.hide = not GloomsHubDB.minimap.hide
  if useLib() then
    if not dataObject then registerBroker() end
    if GloomsHubDB.minimap.hide then LDBIcon:Hide(ADDON) else LDBIcon:Show(ADDON) end
  else
    if GloomsHubDB.minimap.hide then
      if btn then btn:Hide() end
    elseif btn then
      btn:Show()
    else
      buildFallback()
    end
  end
  return not GloomsHubDB.minimap.hide
end
