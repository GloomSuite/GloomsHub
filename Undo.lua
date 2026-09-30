-- ============================================================
-- Undo.lua — Gloom's Hub
-- ★ UNDO / REDO (2026-09-30, the owner: "if I had a dollar for every time I
-- moved something on accident…"). ONE history for the whole suite — the owner
-- builds one UI across the tools, so Undo takes back the most recent change
-- wherever it was made; a change in another tool switches the windows to it.
-- It lasts while the windows are open (switching tools keeps it) and ends when
-- they close; 200 steps at most, for memory.
--
-- HOW: a tool that registers `undo` hands over its live settings as data:
--   undo = { snapshot = fn() → a deep COPY of what the user edits,
--            restore  = fn(snap) → put that back (GloomsHub:UndoPatch keeps the
--                        live tables' identities) and redraw,
--            token    = fn() → which profile / preset is live (a change of
--                        token is a SWITCH, never a step) }
-- After every mouse release (GLOBAL_MOUSE_UP) and every committed edit box
-- (UI.afterEdit, LibGloomSkin), each tool's snapshot is compared with its last;
-- whatever changed is one step. So one dial drag, one drag on screen, one click
-- or one typed value = one step, whatever control made it.
-- Keys: Ctrl+Z / Ctrl+Shift+Z (Cmd on a Mac) while no edit box has the cursor
-- (a focused box keeps its own Ctrl+Z). Buttons: two curved-arrow icons at the
-- right of every tool's selector title row (Windows.lua buildTool) — the owner
-- chose the tab strip first, but its right end is taken in Auras (the aura's
-- type) and Bars (New / Delete); the title row is free in every tool.
-- Media is left out: adding a font or sound registers it with LibSharedMedia,
-- which can't be taken back.
-- ============================================================

local Hub = GloomsHub
local UI = Hub.UI
local MAX = 200

local past, future, base = {}, {}, {}
local active = false
local buttons = {}      -- { undo, redo } per tab strip

local function copy(v)
  if type(v) ~= "table" then return v end
  local t = {}
  for k, x in pairs(v) do t[k] = copy(x) end
  return t
end
Hub.UndoCopy = copy   -- a plain deep copy, for the tools' snapshot()

local function equal(a, b)
  if a == b then return true end
  if type(a) ~= "table" or type(b) ~= "table" then return false end
  for k, x in pairs(a) do if not equal(x, b[k]) then return false end end
  for k in pairs(b) do if a[k] == nil then return false end end
  return true
end
-- Make `dst` equal to `src`, keeping every nested table that exists in both
-- (so a window still holding "the selected overlay" keeps holding it).
function Hub:UndoPatch(dst, src)
  for k in pairs(dst) do if src[k] == nil then dst[k] = nil end end
  for k, v in pairs(src) do
    if type(v) == "table" and type(dst[k]) == "table" then Hub:UndoPatch(dst[k], v)
    else dst[k] = copy(v) end
  end
end

local function tools()
  local out = {}
  for id, def in pairs(Hub._tabs or {}) do if def.undo then out[id] = def end end
  return out
end
local function title(id) local d = Hub._tabs and Hub._tabs[id]; return d and (d.railLabel or d.title) or id end

function Hub:UndoRefresh()
  local nu, nr = #past, #future
  for _, b in ipairs(buttons) do
    b.undo:SetEnabled(active and nu > 0); b.undo:SetAlpha((active and nu > 0) and 1 or UI.G_DIM)
    b.redo:SetEnabled(active and nr > 0); b.redo:SetAlpha((active and nr > 0) and 1 or UI.G_DIM)
  end
end

-- Baselines only: what every tool looks like now.
local function rebase()
  for id, def in pairs(tools()) do
    local ok, snap = pcall(def.undo.snapshot)
    local okT, tok = pcall(def.undo.token)
    if ok and okT then base[id] = { token = tok, snap = snap } end
  end
end

local function check()
  if not active then return end
  local changes
  for id, def in pairs(tools()) do
    local ok, snap = pcall(def.undo.snapshot)
    local okT, tok = pcall(def.undo.token)
    if ok and okT then
      local b = base[id]
      if not b or b.token ~= tok then
        base[id] = { token = tok, snap = snap }
      elseif not equal(b.snap, snap) then
        changes = changes or {}
        changes[#changes + 1] = { tool = id, token = tok, before = b.snap, after = snap }
        base[id] = { token = tok, snap = snap }
      end
    end
  end
  if changes then
    past[#past + 1] = changes
    if #past > MAX then table.remove(past, 1) end
    wipe(future)
    Hub:UndoRefresh()
  end
end
Hub.UndoCheckNow = check   -- the harness (its C_Timer never fires)
local pending = false
function Hub:UndoCheckSoon()
  if not active or pending then return end
  pending = true
  C_Timer.After(0.05, function() pending = false; check() end)
end

local function replay(step, which)
  local shown
  for i = (which == "before" and #step or 1), (which == "before" and 1 or #step), (which == "before" and -1 or 1) do
    local c = step[i]
    local def = Hub._tabs and Hub._tabs[c.tool]
    if def and def.undo then
      local okT, tok = pcall(def.undo.token)
      if okT and tok == c.token then
        local ok, err = pcall(def.undo.restore, copy(c[which]))
        if not ok then geterrorhandler()(err) end
        base[c.tool] = { token = tok, snap = copy(c[which]) }
        shown = c.tool
      else
        print(("|cff936bffGloom's Hub:|r that change was made in another %s profile — switch back to it to undo it."):format(title(c.tool)))
      end
    end
  end
  -- show where it happened
  if shown and Hub.V3 and Hub.V3:Current() ~= shown then Hub:FocusTab(shown) end
  if Hub.RefreshWindows then Hub:RefreshWindows(shown) end
end

function Hub:Undo()
  if not active then return end
  check()                               -- anything not yet recorded is the newest step
  local step = table.remove(past); if not step then return end
  replay(step, "before")
  future[#future + 1] = step
  Hub:UndoRefresh()
end
function Hub:Redo()
  if not active then return end
  local step = table.remove(future); if not step then return end
  replay(step, "after")
  past[#past + 1] = step
  Hub:UndoRefresh()
end
function Hub:UndoCounts() return #past, #future end

-- The windows opened / closed (Windows.lua).
function Hub:UndoBegin()
  if active then return end
  active = true
  wipe(past); wipe(future); wipe(base)
  rebase()
  Hub:UndoRefresh()
end
function Hub:UndoEnd()
  active = false
  wipe(past); wipe(future); wipe(base)
  Hub:UndoRefresh()
end

-- Undo · Redo: two 16 icons (media/ui/g-undo, g-redo — tools/gen-undo-art.py),
-- lilac, lime under the mouse, 30% with nothing to do; 8 apart, 20 in from the
-- right, level with the wordmark. Windows.lua calls this for every selector.
local ICON = "Interface\\AddOns\\GloomsHub\\Media\\ui\\"
local function icon(parent, file, onClick)
  local b = CreateFrame("Button", nil, parent); b:SetSize(16, 16)
  local t = b:CreateTexture(nil, "ARTWORK"); t:SetAllPoints(); t:SetTexture(ICON .. file)
  UI.tint(t, UI.COLOR and UI.COLOR.lilac or Hub.COLOR.lilac)
  b:SetScript("OnEnter", function(self) if self:IsEnabled() then UI.tint(t, Hub.COLOR.lime) end end)
  b:SetScript("OnLeave", function() UI.tint(t, Hub.COLOR.lilac) end)
  b:SetScript("OnClick", onClick)
  return b
end
function Hub:UndoButtons(parent)
  local redo = icon(parent, "g-redo.png", function() Hub:Redo() end)
  redo:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -20, -17)
  local undo = icon(parent, "g-undo.png", function() Hub:Undo() end)
  undo:SetPoint("RIGHT", redo, "LEFT", -8, 0)
  UI.attachTip(undo, "Undo", function()
    local s = past[#past]
    local where = s and title(s[#s].tool) or nil
    return "Takes back your last change" .. (where and (" (in " .. where .. ")") or "") .. " — any tool's, newest first. Ctrl+Z (Cmd+Z on a Mac). The history lasts until you close these windows."
  end)
  UI.attachTip(redo, "Redo", "Puts back what Undo took back. Ctrl+Shift+Z (Cmd+Shift+Z on a Mac).")
  buttons[#buttons + 1] = { undo = undo, redo = redo }
  Hub:UndoRefresh()
end

-- Triggers
local ev = CreateFrame("Frame")
ev:RegisterEvent("GLOBAL_MOUSE_UP")
ev:RegisterEvent("PLAYER_TARGET_CHANGED")
ev:RegisterEvent("PLAYER_REGEN_DISABLED")
ev:SetScript("OnEvent", function(_, event)
  if event == "GLOBAL_MOUSE_UP" then Hub:UndoCheckSoon()
  elseif event == "PLAYER_TARGET_CHANGED" then
    -- some settings follow the target on their own (an overlay's target class
    -- color): that is not the user's change — take it as the new baseline
    if active then C_Timer.After(0.1, function() if active then rebase() end end) end
  elseif event == "PLAYER_REGEN_DISABLED" then
    -- never enter combat holding the keyboard (see the key frame below)
    if Hub._undoKeys and not InCombatLockdown() then Hub._undoKeys:SetPropagateKeyboardInput(true) end
  end
end)
UI.afterEdit = function() Hub:UndoCheckSoon() end

-- ★ ARROW-KEY NUDGES (2026-09-30, the owner: "single pixel nudges with the
-- arrow keys … a 10px move while holding shift", for groups AND single pieces).
-- While the windows are open, the tool on screen says what the arrows move
-- right now — `nudge = fn(dx, dy, isOpen) → true if it moved something`, where
-- isOpen(sectionId) says whether that section is open (in the settings window
-- or popped out). A tool moves a thing only while its POSITION section is open
-- (gloomUI: Size & Position / Group; Unit Frames: the open piece, or the unit
-- from Global); otherwise the arrows walk as ever. A run of presses is ONE undo
-- step (recorded 0.6 s after the last).
local NUDGE = { UP = { 0, 1 }, DOWN = { 0, -1 }, LEFT = { -1, 0 }, RIGHT = { 1, 0 } }
local nudgeTimer
function Hub:Nudge(dx, dy)
  local cur = Hub.V3 and Hub.V3:IsOpen() and Hub.V3:Current()
  local def = cur and Hub._tabs and Hub._tabs[cur]
  if not (def and def.nudge) then return false end
  local d = GloomsHubDB and GloomsHubDB.win and GloomsHubDB.win[cur]
  local function isOpen(sid)
    if not d then return false end
    if d.open == sid then return true end
    local p = d.pops and d.pops[sid]
    return p and p.shown and true or false
  end
  local step = IsShiftKeyDown() and 10 or 1
  local ok, moved = pcall(def.nudge, dx * step, dy * step, isOpen)
  if not ok then geterrorhandler()(moved); return false end
  if moved then
    if nudgeTimer then nudgeTimer:Cancel() end
    nudgeTimer = C_Timer.NewTimer(0.6, function() nudgeTimer = nil; Hub:UndoCheckSoon() end)
    if Hub.RefreshWindows then Hub:RefreshWindows(cur) end
  end
  return moved and true or false
end

-- The keys: a keyboard-listening frame that lets every key through except
-- Ctrl/Cmd+Z. ⚠ SetPropagateKeyboardInput is protected in combat: never call it
-- then, and always hand the keyboard back (key up; entering combat above).
function Hub:UndoKeys(parent)
  if Hub._undoKeys then return end
  local kb = CreateFrame("Frame", nil, parent)
  kb:EnableKeyboard(true)
  if not InCombatLockdown() then kb:SetPropagateKeyboardInput(true) end
  kb:SetScript("OnKeyDown", function(self, key)
    if InCombatLockdown() then return end
    local mod = IsControlKeyDown() or (IsMetaKeyDown and IsMetaKeyDown())
    if key == "Z" and mod then
      self:SetPropagateKeyboardInput(false)
      if IsShiftKeyDown() then Hub:Redo() else Hub:Undo() end
    elseif NUDGE[key] and not mod and Hub:Nudge(NUDGE[key][1], NUDGE[key][2]) then
      self:SetPropagateKeyboardInput(false)
    else
      self:SetPropagateKeyboardInput(true)
    end
  end)
  kb:SetScript("OnKeyUp", function(self) if not InCombatLockdown() then self:SetPropagateKeyboardInput(true) end end)
  Hub._undoKeys = kb
end
