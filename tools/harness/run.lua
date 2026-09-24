-- ============================================================
-- tools/harness — run the suite's UI code OUTSIDE the game.
-- Built 2026-09-23 to verify the second redesign's Auras pages without WoW:
-- it loads the real addon files in TOC order against a stand-in for the client
-- API (wow.lua), with the owner's real SavedVariables, fires the login events,
-- and lets a script drive the Suite window: open tabs, click every control,
-- pick every option. dump.lua + render.py then DRAW what was built, to compare
-- against the Figma mocks. It catches nil calls, wrong fields and layout slips;
-- it cannot show real fonts, combat, secret values or the engine's own frames.
--
--   cd tools/harness && luajit shoot.lua triggers d1   (then render.py)
--   cd tools/harness && luajit sweep.lua               (click/pick everything)
--
-- Needs luajit (Lua 5.1, what the client runs). Unknown CamelCase methods are
-- no-ops, so a MISSING stub fails quietly — when a load step prints an error
-- about a WoW global, it is this stand-in's gap, not the addon's.
-- ============================================================
dofile("wow.lua")
local W = __W
local HOME = os.getenv("HOME")
local function tocFiles(dir, toc)
  local out = {}
  for line in io.lines(dir .. "/" .. toc) do
    line = line:gsub("\r", "")
    if not line:match("^%s*#") and line:match("%S") then
      out[#out + 1] = (line:gsub("\\", "/"):gsub("^%s+", ""):gsub("%s+$", ""))
    end
  end
  return out
end
local SKIP = { ["Libs/LibDataBroker-1.1/LibDataBroker-1.1.lua"] = true, ["Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua"] = true,
               ["MinimapButton.lua"] = true }
local function loadAddon(name)
  local dir = HOME .. "/" .. name
  for _, f in ipairs(tocFiles(dir, name .. ".toc")) do
    if f:match("%.lua$") and not SKIP[f] then
      local chunk, err = loadfile(dir .. "/" .. f)
      if not chunk then print("LOAD ERROR " .. name .. "/" .. f .. ": " .. err)
      else
        local ok, e = xpcall(function() chunk(name, {}) end, debug.traceback)
        if not ok then print("RUN ERROR " .. name .. "/" .. f .. ": " .. e) end
      end
    end
  end
end
-- The client's SavedVariables: the first account folder that has them.
local WOW = "/Applications/World of Warcraft/_retail_/WTF/Account"
local SV
do
  local p = io.popen('ls "' .. WOW .. '" 2>/dev/null')
  for acct in p:lines() do
    local f = io.open(WOW .. "/" .. acct .. "/SavedVariables/GloomsHub.lua")
    if f then f:close(); SV = WOW .. "/" .. acct .. "/SavedVariables/"; break end
  end
  p:close()
end
ADDONS = ADDONS or { "GloomsHub", "GloomsAuras" }
for _, a in ipairs(ADDONS) do
  loadAddon(a)
  if a == "GloomsHub" then GloomsHub.InitMinimapButton = GloomsHub.InitMinimapButton or function() end end
end
if SV then
  for _, a in ipairs(ADDONS) do local chunk = loadfile(SV .. a .. ".lua"); if chunk then pcall(chunk) end end
else
  print("no SavedVariables found — running on fresh defaults")
end
local function ev(...) local ok, e = xpcall(W.event, debug.traceback, ...); if not ok then print("EVENT ERROR " .. tostring((...)) .. ": " .. e) end end
for _, a in ipairs(ADDONS) do ev("ADDON_LOADED", a) end
ev("PLAYER_LOGIN"); ev("PLAYER_ENTERING_WORLD", true, false)
