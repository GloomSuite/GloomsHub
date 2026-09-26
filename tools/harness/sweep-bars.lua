-- Drive every control of every Bars page: click it (every segment of every switch),
-- pick every option of every list, step every dial, commit every field, accept every
-- colour and name dialog (confirms are skipped, so nothing is deleted), and every
-- preview state. Prints the distinct errors.
ADDONS = { "GloomsHub", "GloomsBars" }
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
UI.nameDialog = function(title, init, cb) bump("name"); cb("Harness Preset") end
try("open", function() GloomsHub:Open("bars") end)
local C = GloomsBars.Config; local P = C.P
local function descendants(root)
  local out, stack = {}, { root }
  while #stack > 0 do
    local o = table.remove(stack)
    for _, ch in ipairs(rawget(o, "_children") or {}) do out[#out + 1] = ch; stack[#stack + 1] = ch end
  end
  return out
end
local function sweep(root, tag, depth)
  for _, o in ipairs(descendants(root)) do
    if o:IsVisible() then
      if o._scripts.OnClick then
        lastList = nil
        local lbl = (rawget(o, "text") and o.text._text) or o._text or "?"
        bump("click")
        try(tag .. " click " .. lbl, function() W.fire(o, "OnClick", "LeftButton") end)
        if lastList then
          for _, opt in ipairs(lastList.options) do
            if not opt.disabled then bump("pick"); try(tag .. " pick " .. tostring(opt.label), function() lastList.onPick(opt.value) end) end
          end
        end
      end
      if rawget(o, "strip") and rawget(o, "box") and o.strip._scripts.OnMouseWheel then
        bump("dial"); try(tag .. " dial", function() W.fire(o.strip, "OnMouseWheel", 1); W.fire(o.strip, "OnMouseWheel", -1) end)
      end
      if o._kind == "EditBox" and o._scripts.OnEditFocusLost then
        bump("field"); try(tag .. " field", function() o._text = "12"; W.fire(o, "OnEditFocusLost") end)
      end
    end
  end
end
for _, pid in ipairs({ "shape", "deco", "text", "glows", "casts", "cooldowns", "layout" }) do
  try("page " .. pid, function() GloomsHub:ShowPage("bars", pid) end)
  -- twice: the first pass flips switches, which can un-dim what the second pass then reaches
  sweep(P.pages[pid].frame, pid)
  sweep(P.pages[pid].frame, pid)
end
-- every text tab, every animation state and module, every bar
try("text tabs", function() GloomsHub:ShowPage("bars", "text") end)
for _, pid in ipairs({ "text", "glows", "layout" }) do
  GloomsHub:ShowPage("bars", pid)
  for _, o in ipairs(descendants(P.pages[pid].frame)) do
    if rawget(o, "segs") and o:IsVisible() then
      for _, s in ipairs(o.segs) do
        try(pid .. " seg", function() W.fire(s, "OnClick", "LeftButton") end)
        sweep(P.pages[pid].frame, pid .. "/seg")
      end
    end
  end
end
-- the whole-tab chrome: the preset row + the preview, from any page
try("chrome", function() sweep(GloomsSuiteWindow, "chrome") end)
try("refresh", function() C:Refresh() end)
try("links", function() for _, t in ipairs({ "Icon Size & Shape", "Decoration Layers", "Text", "Glows & Animations", "Casts & Channels", "Cooldowns & Availability" }) do C:OpenSection(t) end end)
try("focus auras-less", function() GloomsHub:FocusTab("bars") end)
for k, v in pairs(counts) do print(k, v) end
print(#errs .. " distinct errors")
for _, e in ipairs(errs) do print("----\n" .. e) end
