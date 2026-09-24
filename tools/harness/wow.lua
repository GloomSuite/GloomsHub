-- A stand-in for the WoW client API: enough to LOAD and DRIVE the suite's UI
-- code outside the game and catch runtime errors (nil calls, bad fields). It
-- does not render. Unknown CamelCase methods are no-ops returning nil.
local noop = function() end
local frames, eventFrames, allObjs = {}, {}, {}
local R = {}
local meta = {}
meta.__index = function(t, k)
  local m = R[k]; if m ~= nil then return m end
  if type(k) == "string" and k:match("^%u") then return noop end
  return nil
end
local function new(kind, parent, name)
  local o = setmetatable({ _kind = kind, _parent = parent, _w = 0, _h = 0, _shown = true, _scripts = {}, _hooks = {},
                            _text = "", _enabled = true, _level = parent and ((rawget(parent, "_level") or 0) + 1) or 0,
                            _scale = 1, _vscroll = 0, _alpha = 1, _children = {} }, meta)
  if parent and rawget(parent, "_children") then table.insert(parent._children, o) end
  if name then _G[name] = o end
  allObjs[#allObjs + 1] = o
  return o
end
_G.__W = { frames = frames, eventFrames = eventFrames, all = allObjs, new = new }

function R:GetObjectType() return self._kind end
function R:IsObjectType(t) return self._kind == t end
function R:SetSize(w, h) self._w, self._h = w or 0, h or 0 end
function R:SetWidth(w) self._w = w or 0 end
function R:SetHeight(h) self._h = h or 0 end
function R:GetWidth() return self._w end
function R:GetHeight() return self._h end
function R:GetSize() return self._w, self._h end
function R:SetPoint(p, a, b, c, d)
  self._points = self._points or {}
  local rel, rp, x, y
  if type(a) == "table" then rel, rp, x, y = a, b, c, d
    if type(rp) == "number" then rel, rp, x, y = a, p, b, c end
  elseif type(a) == "string" and _G[a] then rel, rp, x, y = _G[a], b, c, d
  else rel, rp, x, y = self._parent, p, a, b end
  for i = #self._points, 1, -1 do if self._points[i][1] == p then table.remove(self._points, i) end end
  table.insert(self._points, { p, rel or self._parent, rp or p, x or 0, y or 0 })
end
function R:ClearAllPoints() self._points = {} end
function R:SetAllPoints() end
function R:GetParent() return self._parent end
function R:SetParent(p) self._parent = p end
function R:GetChildren() return unpack(self._children or {}) end
function R:GetNumChildren() return #(self._children or {}) end
local function fire(o, ev, ...)
  local s = o._scripts[ev]; if s then s(o, ...) end
  for _, h in ipairs(o._hooks[ev] or {}) do h(o, ...) end
end
_G.__W.fire = fire
function R:SetScript(ev, fn) self._scripts[ev] = fn; self._hooks[ev] = nil end
function R:GetScript(ev) return self._scripts[ev] end
function R:HookScript(ev, fn) self._hooks[ev] = self._hooks[ev] or {}; table.insert(self._hooks[ev], fn) end
function R:HasScript() return true end
function R:Show() if not self._shown then self._shown = true; fire(self, "OnShow") end end
function R:Hide() if self._shown then self._shown = false; fire(self, "OnHide") end end
function R:SetShown(v) if v then self:Show() else self:Hide() end end
function R:IsShown() return self._shown end
function R:IsVisible()
  local o = self
  while o do if not o._shown then return false end; o = o._parent end
  return true
end
function R:SetText(t) self._text = t == nil and "" or tostring(t) end
function R:GetText() return self._text end
function R:SetFormattedText(f, ...) self._text = string.format(f, ...) end
function R:GetStringWidth()
  local t = (self._text or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
  local f = rawget(self, "_font"); local sz = f and f[2] or 12
  return #t * sz * 0.54
end
function R:GetStringHeight() return 12 end
function R:GetNumber() return tonumber(self._text) or 0 end
function R:SetFont() return true end
function R:GetFont() return "font", 12, "" end
function R:SetEnabled(v) self._enabled = v and true or false; fire(self, v and "OnEnable" or "OnDisable") end
function R:Enable() self:SetEnabled(true) end
function R:Disable() self:SetEnabled(false) end
function R:IsEnabled() return self._enabled end
function R:GetEffectiveScale() return 1 end
function R:SetScale(s) self._scale = s end
function R:GetScale() return self._scale end
function R:SetAlpha(a) self._alpha = a end
function R:GetAlpha() return self._alpha end
function R:SetFrameLevel(l) self._level = l end
function R:GetFrameLevel() return self._level end
function R:GetFrameStrata() return "MEDIUM" end
function R:GetCenter() return 500, 400 end
function R:GetLeft() return 100 end
function R:GetRight() return 900 end
function R:GetTop() return 700 end
function R:GetBottom() return 100 end
function R:GetRect() return 100, 100, self._w, self._h end
function R:IsMouseOver() return false end
function R:GetVerticalScroll() return self._vscroll end
function R:SetVerticalScroll(v) self._vscroll = v end
function R:GetVerticalScrollRange() return 0 end
function R:SetScrollChild(c) self._child = c end
function R:GetScrollChild() return self._child end
function R:HasFocus() return false end
function R:ClearFocus() fire(self, "OnEditFocusLost") end
function R:SetFocus() fire(self, "OnEditFocusGained") end
function R:CreateTexture(name, layer, _, sub) local t = new("Texture", self, name); t._layer = layer or "ARTWORK"; t._sub = sub or 0; return t end
function R:CreateFontString(name, layer) local t = new("FontString", self, name); t._layer = layer or "OVERLAY"; t._sub = 0; return t end
function R:CreateMaskTexture(name) return new("MaskTexture", self, name) end
function R:CreateAnimationGroup() local g = new("AnimationGroup", self); function g:CreateAnimation() return new("Animation", g) end; return g end
function R:GetRegions() return end
function R:RegisterEvent(ev) self._events = self._events or {}; self._events[ev] = true; eventFrames[self] = true end
function R:UnregisterEvent(ev) if self._events then self._events[ev] = nil end end
function R:UnregisterAllEvents() self._events = {} end
function R:IsEventRegistered(ev) return self._events and self._events[ev] end
function R:RegisterUnitEvent(ev) self:RegisterEvent(ev) end
function R:GetTexture() return self._tex end
function R:SetTexture(t) self._tex = t; return true end
function R:GetName() return nil end
function R:GetID() return 0 end
function R:GetAttribute() return nil end
function R:IsForbidden() return false end
function R:IsProtected() return false end
function R:GetNumPoints() return #(self._points or {}) end
function R:GetPoint(i) local p = (self._points or {})[i or 1]; if p then return unpack(p) end end
function R:GetStatusBarTexture() self._sbt = self._sbt or new("Texture", self); return self._sbt end
function R:GetMinMaxValues() return 0, 1 end
function R:GetValue() return 0 end
function R:IsMouseEnabled() return true end
function R:GetCursorPosition() return 0 end
function R:IsPlaying() return false end

function CreateFrame(kind, name, parent, template)
  local f = new(kind or "Frame", parent, name)
  frames[#frames + 1] = f
  return f
end
UIParent = new("Frame", nil); UIParent._w, UIParent._h = 1920, 1080
WorldFrame = new("Frame", nil)
Minimap = new("Frame", UIParent)
GameTooltip = new("GameTooltip", UIParent)
UISpecialFrames = {}
SlashCmdList = {}
STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
Enum = setmetatable({ UITextureSliceMode = { Stretched = 0, Tiled = 1 }, PowerType = setmetatable({}, { __index = function() return 0 end }) },
  { __index = function() return setmetatable({}, { __index = function() return 0 end }) end })
function CreateColor(r, g, b, a) return { r = r, g = g, b = b, a = a, GetRGBA = function(s) return s.r, s.g, s.b, s.a end } end
function GetCursorPosition() return 0, 0 end
function IsMouseButtonDown() return false end
function IsShiftKeyDown() return false end
function IsControlKeyDown() return false end
function IsAltKeyDown() return false end
function InCombatLockdown() return false end
function UnitExists() return true end
function UnitName() return "Gloombound" end
function GetRealmName() return "Stormrage" end
function GetNormalizedRealmName() return "Stormrage" end
function UnitClass() return "Rogue", "ROGUE", 4 end
function UnitGUID() return "Player-1-0000" end
function UnitIsDeadOrGhost() return false end
function UnitCastingInfo() return nil end
function UnitChannelInfo() return nil end
function UnitInVehicle() return false end
function UnitPower() return 3 end
function UnitPowerType() return 3 end
function UnitAffectingCombat() return false end
function IsMounted() return false end
function IsInInstance() return false end
function IsEncounterInProgress() return false end
function IsResting() return false end
function IsStealthed() return false end
function IsInGroup() return false end
function IsInRaid() return false end
function IsSpellKnown() return true end
function IsPlayerSpell() return true end
function GetSpecialization() return 1 end
function GetNumSpecializations() return 3 end
local specs = { { 259, "Assassination" }, { 260, "Outlaw" }, { 261, "Subtlety" } }
function GetSpecializationInfo(i) local s = specs[i]; if s then return s[1], s[2], "", 134400 end end
function GetLocale() return "enUS" end
function GetTime() return 1000 end
function GetBuildInfo() return "12.1.0", "00000", "Sep 1 2026", 120100 end
function PlaySoundFile() return true end
function PlaySound() return true end
function hooksecurefunc(a, b, c) end
function issecretvalue() return false end
function wipe(t) for k in pairs(t) do t[k] = nil end; return t end
tinsert, tremove = table.insert, table.remove
strsplit = function(sep, s) local out = {}; for p in string.gmatch(s, "([^" .. sep .. "]+)") do out[#out + 1] = p end; return unpack(out) end
strtrim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
format = string.format
debugstack = function() return "" end
geterrorhandler = function() return function(e) print("ERRHANDLER: " .. tostring(e)) end end
securecall = function(f, ...) return f(...) end
CopyTable = function(t) local o = {}; for k, v in pairs(t) do o[k] = type(v) == "table" and CopyTable(v) or v end; return o end
Mixin = function(o, ...) for i = 1, select("#", ...) do for k, v in pairs((select(i, ...))) do o[k] = v end end; return o end
C_Timer = { After = function(s, f) end, NewTicker = function() return { Cancel = noop } end, NewTimer = function() return { Cancel = noop } end }
C_AddOns = { GetAddOnMetadata = function() return "@project-version@" end, IsAddOnLoaded = function() return true end }
C_Spell = {
  GetSpellName = function(id) return "Spell" .. tostring(id) end,
  GetSpellTexture = function() return 134400 end,
  GetSpellInfo = function(id) return { name = "Spell" .. tostring(id), iconID = 134400, spellID = id } end,
  IsSpellUsable = function() return true end,
  GetSpellCooldown = function() return { startTime = 0, duration = 0 } end,
}
C_PvP = { IsWarModeActive = function() return false end }
C_CooldownViewer = setmetatable({}, { __index = function() return function() return nil end end })
C_UnitAuras = setmetatable({}, { __index = function() return function() return nil end end })
C_CurveUtil = setmetatable({}, { __index = function() return function() return new("Curve") end end })
C_DurationUtil = setmetatable({}, { __index = function() return function() return nil end end })
C_Texture = setmetatable({}, { __index = function() return function() return nil end end })
C_ClassColor = { GetClassColor = function() return CreateColor(1, 1, 1, 1) end }
RAID_CLASS_COLORS = setmetatable({}, { __index = function() return { r = 1, g = 1, b = 1, colorStr = "ffffffff" } end })
EssentialCooldownViewer = new("Frame", UIParent)
UtilityCooldownViewer = new("Frame", UIParent)
BuffIconCooldownViewer = new("Frame", UIParent)
BuffBarCooldownViewer = new("Frame", UIParent)
CooldownViewerSettings = new("Frame", UIParent)
ChatFontNormal = new("Font", nil)
GameFontNormal = new("Font", nil)
function CreateFont() return new("Font", nil) end
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) print("CHAT: " .. tostring(m)) end }

function __W.event(ev, ...)
  for f in pairs(eventFrames) do
    if f._events and f._events[ev] then fire(f, "OnEvent", ev, ...) end
  end
end
strmatch, strfind, strsub, strlower, strupper, strlen, strrep, strbyte, strchar, strjoin =
  string.match, string.find, string.sub, string.lower, string.upper, string.len, string.rep, string.byte, string.char,
  function(sep, ...) return table.concat({ ... }, sep) end
gsub, gmatch, strformat = string.gsub, string.gmatch, string.format
floor, ceil, abs, max, min, sqrt, random = math.floor, math.ceil, math.abs, math.max, math.min, math.sqrt, math.random
sort, getn = table.sort, table.getn
local function pool(kind)
  local p = { active = {} }
  function p:Acquire() local o = __W.new(kind, UIParent); self.active[o] = true; return o, true end
  function p:Release(o) self.active[o] = nil end
  function p:ReleaseAll() self.active = {} end
  function p:EnumerateActive() return pairs(self.active) end
  function p:GetNumActive() local n = 0; for _ in pairs(self.active) do n = n + 1 end; return n end
  return p
end
function CreateTexturePool() return pool("Texture") end
function CreateFramePool() return pool("Frame") end
function CreateObjectPool() return pool("Frame") end
-- ---- recording what gets drawn (for dump.lua → render.py) ----
local R2 = {}
local oldIndex = getmetatable(__W.new("x")).__index
local function rec(name, fn) R2[name] = fn end
for k, v in pairs({
  SetColorTexture = function(self, r, g, b, a) self._fill = { r, g, b, a or 1 }; self._tex = nil end,
  SetTexture = function(self, t) self._tex = t; if type(t) == "string" or type(t) == "number" then self._fill = nil end; return true end,
  SetVertexColor = function(self, r, g, b, a) self._vc = { r, g, b, a or 1 } end,
  SetTexCoord = function(self, ...) self._tc = { ... } end,
  SetRotation = function(self, r) self._rot = r end,
  SetGradient = function(self, o, a, b) self._grad = { o, { a.r, a.g, a.b, a.a or 1 }, { b.r, b.g, b.b, b.a or 1 } } end,
  SetTextColor = function(self, r, g, b, a) self._tcolor = { r, g, b, a or 1 } end,
  SetFont = function(self, path, size) self._font = { path, size }; return true end,
  SetJustifyH = function(self, j) self._jh = j end,
  SetDrawLayer = function(self, l, s) self._layer = l; self._sub = s end,
  SetAllPoints = function(self, rel) self._points = { { "TOPLEFT", rel or self._parent, "TOPLEFT", 0, 0 }, { "BOTTOMRIGHT", rel or self._parent, "BOTTOMRIGHT", 0, 0 } } end,
  SetTextInsets = function(self, l, r) self._insets = { l, r } end,
}) do rec(k, v) end
local base = getmetatable(__W.new("x"))
local prev = base.__index
base.__index = function(t, k) local m = R2[k]; if m then return m end; return prev(t, k) end
-- remember the layer a region was created on
local oldCT, oldFS = CreateFrame("Frame").CreateTexture, CreateFrame("Frame").CreateFontString
local proto = getmetatable(__W.new("x")).__index
