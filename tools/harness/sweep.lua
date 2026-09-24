-- Drive every control of every Auras page for every aura in the profile: click it,
-- pick every option of every list, step every dial, commit every field, accept every
-- colour and name dialog (confirms are skipped, so nothing is deleted), then the
-- trigger drag-and-drop and the group pane. Prints the distinct errors.
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
-- capture lists, auto-accept colour picks and name dialogs (not confirms: no deleting here)
local lastList
local realOpen = UI.openList
UI.openList = function(anchor, options, current, onPick) lastList = { options = options, onPick = onPick }; return realOpen(anchor, options, current, onPick) end
UI.colorPicker = function(o) bump("color"); if o.onChange then o.onChange({ 0.5, 0.2, 0.1 }) end end
UI.confirm = function() bump("confirm-skipped") end
try("open", function() GloomsHub:Open("auras") end)
local C = GloomsAuras.Config; local X = C.X; local P = C.P
X.OpenNameDialog = function(title, init, cb) bump("name"); cb("Renamed Thing") end
local function descendants(root)
  local out, stack = {}, { root }
  while #stack > 0 do
    local o = table.remove(stack)
    for _, ch in ipairs(rawget(o, "_children") or {}) do out[#out + 1] = ch; stack[#stack + 1] = ch end
  end
  return out
end
local ids = {}; for id in pairs(X.DB() or {}) do ids[#ids + 1] = id end
table.sort(ids, function(a, b) return tostring(a) < tostring(b) end)
for _, id in ipairs(ids) do
  try("select", function() X.SetSelected(id) end)
  for _, pid in ipairs({ "appearance", "bar", "text", "effects", "load", "triggers" }) do
    try("page " .. pid, function() GloomsHub:ShowPage("auras", pid) end)
    for _, o in ipairs(descendants(P.pages[pid])) do
      if o:IsVisible() then
        -- lists: open, then pick every enabled option
        if o._scripts.OnClick then
          lastList = nil
          local lbl = (rawget(o, "text") and o.text._text) or o._text or "?"
          try(pid .. " click " .. lbl, function() W.fire(o, "OnClick", "LeftButton") end)
          if lastList then
            for _, opt in ipairs(lastList.options) do
              if not opt.disabled then bump("pick"); try(pid .. " pick " .. tostring(opt.label), function() lastList.onPick(opt.value) end) end
            end
          end
        end
        -- dials: wheel both ways
        if rawget(o, "strip") and rawget(o, "box") and o.strip._scripts.OnMouseWheel then
          bump("dial"); try(pid .. " dial", function() W.fire(o.strip, "OnMouseWheel", 1); W.fire(o.strip, "OnMouseWheel", -1) end)
        end
        -- fields: type and commit
        if o._kind == "EditBox" and o._scripts.OnEditFocusLost then
          bump("field"); try(pid .. " field", function() o._text = "12"; W.fire(o, "OnEditFocusLost"); o._text = ""; W.fire(o, "OnEditFocusLost") end)
        end
      end
    end
  end
end
-- triggers: add, group, drag in and out, dissolve, cycle
local cfgId = ids[1]
try("trig select", function() X.SetSelected(cfgId); GloomsHub:ShowPage("auras", "triggers") end)
try("trig add leaf", function() C:TrigAddLeaf({ spellID = 703, state = "buff_active", k = "debuff" }, nil) end)
try("trig add leaf2", function() C:TrigAddLeaf({ spellID = 1943, state = "cd_ready" }, nil) end)
try("trig add group", function() C:TrigAddGroup() end)
local TR = P.TR
try("drag into group", function()
  local row = TR.rows[1]; P.trigDragStart(row)
  local g = TR.groups[1]; g.IsMouseOver = function() return true end
  P.trigDragStop(row); g.IsMouseOver = nil
end)
local t = C:TrigTree()
print("after drag-in: top-level items " .. #t.conditions .. ", group holds " .. #((function() for _, n in ipairs(t.conditions) do if n.conditions then return n.conditions end end return {} end)()))
try("drag out of group", function()
  local g = TR.groups[1]; local row = g.rows[1]; P.trigDragStart(row)
  TR.page.IsMouseOver = function() return true end
  P.trigDragStop(row); TR.page.IsMouseOver = nil
end)
print("after drag-out: top-level items " .. #t.conditions)
try("group match", function() W.fire(TR.groups[1].match[3], "OnClick") end)
try("dissolve", function() P.dissolveGroup(TR.groups[1]._ti) end)
try("cycle", function() W.fire(TR.rows[1].pill, "OnClick") end)
try("remove", function() W.fire(TR.rows[1].x, "OnClick") end)
-- list: groups, fold, add-to-group, eye
for _, gid in ipairs(X.GroupList()) do
  try("select group " .. gid, function() C:SelectGroup(gid) end)
  for _, o in ipairs(descendants(P.groupPage)) do
    if o:IsVisible() and o._scripts.OnClick then
      lastList = nil
      try("group click", function() W.fire(o, "OnClick", "LeftButton") end)
      if lastList then for _, opt in ipairs(lastList.options) do try("group pick", function() lastList.onPick(opt.value) end) end end
    end
  end
  try("header rename group", function() W.fire(P.header.dup, "OnClick") end)
end
try("list clicks", function()
  for _, r in ipairs(descendants(P.list)) do
    if r:IsVisible() and r._scripts.OnClick and r._kind == "Button" then
      lastList = nil
      W.fire(r, "OnClick", "LeftButton")
      if lastList then lastList.onPick(lastList.options[1].value) end
    end
  end
end)
try("new aura via menu", function() P.newAuraMenu(P.list, nil); lastList.onPick("bar") end)
try("header group menu", function() X.SetSelected(ids[2]); P.groupMenu(P.header); lastList.onPick(lastList.options[#lastList.options].value) end)
try("duplicate", function() X.SetSelected(ids[2]); W.fire(P.header.dup, "OnClick") end)
-- the Suite window: switch to the other (legacy) tab and back, the tool list
try("focus media", function() GloomsHub:FocusTab("media") end)
try("focus auras", function() GloomsHub:FocusTab("auras") end)
for k, v in pairs(counts) do print(k, v) end
print(#errs .. " distinct errors")
for _, e in ipairs(errs) do print("----\n" .. e) end
