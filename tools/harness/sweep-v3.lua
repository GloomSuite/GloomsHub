-- Drive the TWO-WINDOW tools (Windows.lua) outside the game: for Auras (every
-- aura in the profile) and Bars, open every section and click every control in
-- the selector, the tab and the settings window, pick every option of every
-- list, step every dial, commit every field, accept every color and name dialog
-- (confirms are skipped, so nothing is deleted); pop every section out and back
-- in, resize and scroll the windows, open the right-click menus. Prints counts
-- and the distinct errors.
--   cd tools/harness && luajit sweep-v3.lua
ADDONS = { "GloomsHub", "GloomsAuras", "GloomsBars" }
dofile("run.lua")
local W = __W
local errs, seen, counts = {}, {}, {}
local function try(label, f, ...)
  local ok, e = xpcall(f, debug.traceback, ...)
  if not ok then
    local key = (e:match("^[^\n]+") or e)
    if not seen[key] then seen[key] = true; errs[#errs + 1] = "[" .. label .. "] " .. e end
  end
  return ok
end
local function bump(k) counts[k] = (counts[k] or 0) + 1 end
local UI = GloomsHub.UI
local lastList
local realG = UI.gList
UI.gList = function(anchor, options, current, onPick, o) lastList = { options = options, onPick = onPick }; return realG(anchor, options, current, onPick, o) end
UI.colorPicker = function(o) bump("color"); if o.onChange then o.onChange({ 0.5, 0.2, 0.1 }) end end
UI.confirm = function() bump("confirm-skipped") end
UI.nameDialog = function(title, init, cb) bump("name"); cb("Renamed Thing") end
local function descendants(root)
  local out, stack = {}, { root }
  while #stack > 0 do
    local o = table.remove(stack)
    for _, ch in ipairs(rawget(o, "_children") or {}) do out[#out + 1] = ch; stack[#stack + 1] = ch end
  end
  return out
end
local SKIP = {}   -- the close discs: they would close the tool mid-sweep
local function drive(tool, root, label)
  for _, o in ipairs(descendants(root)) do
    if o:IsVisible() and not SKIP[o] then
      if o._scripts.OnClick then
        lastList = nil
        local lbl = (rawget(o, "text") and o.text._text) or o._text or "?"
        try(label .. " click " .. lbl, function() W.fire(o, "OnClick", "LeftButton") end)
        bump("click")
        if lastList then
          for _, opt in ipairs(lastList.options) do
            if not opt.disabled and opt.value ~= "delete" and opt.danger ~= true then
              bump("pick"); try(label .. " pick " .. tostring(opt.label), function() lastList.onPick(opt.value) end)
            end
          end
        end
        if not GloomsHub.V3:IsOpen() then GloomsHub:Open(tool) end
      end
      if rawget(o, "strip") and rawget(o, "box") and o.strip._scripts.OnMouseWheel then
        bump("dial"); try(label .. " dial", function() W.fire(o.strip, "OnMouseWheel", 1); W.fire(o.strip, "OnMouseWheel", -1) end)
      end
      if o._kind == "EditBox" and o._scripts.OnEditFocusLost then
        bump("field"); try(label .. " field", function() o._text = "12"; W.fire(o, "OnEditFocusLost"); o._text = ""; W.fire(o, "OnEditFocusLost") end)
      end
    end
  end
end

local SECTIONS = {
  auras = { "triggers", "appearance", "bar", "text", "effects", "load", "__global" },
  bars  = { "shape", "deco", "text", "glows", "casts", "cooldowns", "layout", "__global" },
}
local function sweepTool(tool)
  try("open " .. tool, function() GloomsHub:Open(tool) end)
  local sel, set = GloomsHub:SuiteWindow(tool, "sel"), GloomsHub:SuiteWindow(tool, "set")
  SKIP[sel.close] = true; SKIP[set.close] = true
  for _, sid in ipairs(SECTIONS[tool]) do
    try(tool .. " section " .. sid, function() GloomsHub:ShowPage(tool, sid) end)
    drive(tool, set, tool .. "/" .. sid)
    bump("section")
  end
  drive(tool, sel, tool .. "/selector")
  -- pop every section out, drive it there, put it back
  for _, sid in ipairs(SECTIONS[tool]) do
    try(tool .. " popout " .. sid, function()
      GloomsHub:ShowPage(tool, sid)
      local head
      for _, o in ipairs(descendants(set)) do
        if o:IsVisible() and rawget(o, "pop") and rawget(o, "title") and o.title._text and rawget(o, "tri") and o.tri._rot == 0 then head = o end
      end
      if head then W.fire(head.pop, "OnClick"); bump("popout") end
    end)
  end
  local root = GloomsHub:SuiteRoot()
  for _, w in ipairs(descendants(root)) do
    if rawget(w, "grip") and w ~= sel and w ~= set and w:IsShown() then
      SKIP[w.close] = true
      drive(tool, w, tool .. "/popout")
      try("popout resize", function() W.fire(w.grip, "OnMouseDown"); W.fire(w.grip, "OnUpdate"); W.fire(w.grip, "OnMouseUp") end)
      try("popout close", function() W.fire(w.close, "OnClick") end)
      bump("popin")
    end
  end
  -- resize, move and scroll the two main windows
  for _, w in ipairs({ sel, set }) do
    try("resize", function() W.fire(w.grip, "OnMouseDown"); W.fire(w.grip, "OnUpdate"); W.fire(w.grip, "OnMouseUp") end)
    try("move", function() W.fire(w, "OnDragStart"); W.fire(w, "OnDragStop") end)
  end
  for _, o in ipairs(descendants(set)) do
    if o._kind == "ScrollFrame" and o._scripts.OnMouseWheel then
      try("scroll", function() W.fire(o, "OnMouseWheel", -1); W.fire(o, "OnMouseWheel", 1) end); bump("scroll")
    end
  end
  -- the tab: left and right click on everything clickable
  if set.tab then
    for _, o in ipairs(descendants(set.tab)) do
      if o:IsVisible() and o._scripts.OnClick then
        for _, b in ipairs({ "LeftButton", "RightButton" }) do
          lastList = nil
          try(tool .. " tab " .. b, function() W.fire(o, "OnClick", b) end)
          if lastList then
            for _, opt in ipairs(lastList.options) do
              if not opt.disabled and opt.value ~= "delete" and opt.danger ~= true then bump("tab pick"); try("tab pick", function() lastList.onPick(opt.value) end) end
            end
          end
        end
      end
    end
  end
end

-- AURAS: every aura
try("open auras", function() GloomsHub:Open("auras") end)
local C = GloomsAuras.Config; local X = C.X; local P = C.P
X.OpenNameDialog = function(title, init, cb) bump("name"); cb("Renamed Thing") end
local ids = {}; for id in pairs(X.DB() or {}) do ids[#ids + 1] = id end
table.sort(ids, function(a, b) return tostring(a) < tostring(b) end)
for i, id in ipairs(ids) do
  if i <= 6 then
    try("select", function() X.SetSelected(id) end)
    sweepTool("auras")
  end
end
-- triggers: add, group, drag in and out, dissolve
try("trig", function()
  X.SetSelected(ids[1]); GloomsHub:ShowPage("auras", "triggers")
  C:TrigAddLeaf({ spellID = 703, state = "buff_active", k = "debuff" }, nil)
  C:TrigAddGroup()
  local TR = P.TR
  local row = TR.rows[1]; P.trigDragStart(row)
  local g = TR.groups[1]; g.IsMouseOver = function() return true end
  P.trigDragStop(row); g.IsMouseOver = nil
  P.dissolveGroup(TR.groups[1]._ti)
end)
-- a group's menu and its load window
if #X.GroupList() == 0 then try("make a group", function() X.CreateGroup("Harness Group"); X.RefreshList() end) end
for _, gid in ipairs(X.GroupList()) do
  try("group menu", function()
    lastList = nil; P.groupContext(gid, P.listClip)
    for _, opt in ipairs(lastList.options) do if opt.value ~= "delete" then bump("group menu"); lastList.onPick(opt.value) end end
  end)
  if P.groupLoad then drive("auras", P.groupLoad, "group load"); P.groupLoad:Hide() end
end
try("aura menu", function()
  X.SetSelected(X.DisplayList()[1]); lastList = nil; P.auraContext(P.listClip)
  if not lastList then return end
  for _, opt in ipairs(lastList.options) do if opt.value ~= "delete" then bump("aura menu"); lastList.onPick(opt.value) end end
end)
-- BARS
sweepTool("bars")
-- switching: to an old-style tool (if loaded) and back, Escape, reopen
try("switch", function() GloomsHub:FocusTab("auras"); GloomsHub:FocusTab("bars") end)
try("escape", function() GloomsHub:SuiteRoot():Hide(); GloomsHub:ToggleWindow("bars"); GloomsHub:ToggleWindow("bars") end)

local keys = {}; for k in pairs(counts) do keys[#keys + 1] = k end; table.sort(keys)
for _, k in ipairs(keys) do print(k, counts[k]) end
print(#errs .. " distinct errors")
for _, e in ipairs(errs) do print(e); print("----") end
