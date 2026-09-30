-- ============================================================
-- Windows.lua — Gloom's Hub
-- ★ THE TWO-WINDOW SUITE (2026-09-27, the owner's Figma page "GloomSuite UI 3").
-- A tool that registers `windows = true` no longer lives in the one big Suite
-- window. It gets:
--   the SELECTOR window (240 wide): "gloom" + the tool's name in lime and ▸
--     (the tool switcher), the close disc, and whatever the tool draws — Auras'
--     groups and auras, Bars' preview;
--   the SETTINGS window (400 wide): the tool's TAB standing above it (the aura
--     being edited, the preset), and the tool's SECTIONS as headers — ONE open
--     at a time, its controls under it — then GLOBAL SETTINGS (the Hub's: every
--     tool's profile, the tool's own global switches, the Addon UI Scale);
--   a POP-OUT window per section on demand (the header's pop-out icon): just
--     that section, with the tab; its pop-in icon or its close disc puts the
--     section back into the settings window, collapsed.
-- Every window: drag any empty part (or the tab) to move it; drag the lime bar
-- under it to change its HEIGHT (width is fixed); its content scrolls, with the
-- fades and the bar only while there is more to see. Position and height are
-- remembered per tool and per window across sessions, and so are the open
-- section and which sections are popped out. Closing the selector or the
-- settings window (or Escape) closes the whole tool; closing a pop-out only
-- puts its section back.
-- Tools that are NOT rebuilt yet keep the old big window (Shell.lua); the tool
-- switcher moves between the two kinds.
--
-- THE CONTRACT (CONTRACTS §2, the two-window block) — a tool registers:
--   windows  = true,
--   selector = { build = function(content, api) end, h = 480 }, -- 240 wide, content below y 52; h = its starting height
--   tab      = { w = 360, build = function(tab) return { refresh = fn } end },   -- once per window with a tab
--   sections = { { id, title (a string, or a function), build = function(parent) return frame end,  -- 360 wide, its own height
--                  hidden = fn (optional; true = not listed), dim = fn (optional; true = its header at 30%),
--                  locked = fn (optional; true = header at 30% AND shut: it can't be opened or
--                    popped out, and closes / goes back in if it was — Auras' Bar Fill on a
--                    non-bar aura, the owner 2026-09-27),
--                  footer = function(parent) return frame end (optional; pinned to the window's foot),
--                  onShow = fn (optional) }, … },
--   globals  = { { label, choices, get, set, tip } … }   -- switches in Global Settings (optional)
--   onOpen / onClose / refresh (optional)
-- and calls GloomsHub:RefreshWindows(id) when what the tabs show changes.
-- ============================================================

local Hub = GloomsHub
local UI, COLOR, FONT = Hub.UI, Hub.COLOR, Hub.FONT
local V = {}
Hub.V3 = V

local SEL_W, SET_W, CONTENT_W = 240, 400, 360
local SEL_H, SET_H = 480, 650
local HEAD_Y, HEAD_PITCH, HEAD_TO_CONTENT, CONTENT_TO_HEAD = 20, 25, 34, 40   -- the mocks: 24-26 between headers
local POP_HEAD_Y = 24

local root              -- the parent of every window: its scale is the Addon UI Scale
local cur               -- the tool on screen
local W = {}            -- per tool: { sel, set, tabs = {}, built = {}, pops = {}, heads = {} }

local function db(id)
  GloomsHubDB = GloomsHubDB or {}
  GloomsHubDB.win = GloomsHubDB.win or {}
  GloomsHubDB.win[id] = GloomsHubDB.win[id] or { pops = {} }
  local d = GloomsHubDB.win[id]
  d.pops = d.pops or {}
  return d
end

-- ------------------------------------------------------------
-- The Addon UI Scale — the same whole-pixel ladder as the big window's
-- (Shell.lua, FINDINGS §22) and the SAME saved choice (GloomsHubDB.uiPx, in
-- screen pixels per unit), but sized for these windows: a step is offered when
-- the settings window's full height fits the screen. 100% = the sharp size
-- closest to the rest of the player's UI (the owner, 2026-09-26).
-- ------------------------------------------------------------
local SCALES, PXS, ANCHOR = { 1 }, { 1 }, nil
local function pxPerUnit()
  local _, ph = GetPhysicalScreenSize()
  return (ph and ph > 0) and (ph / 768) or 1
end
local function buildLadder()
  local pw, ph = GetPhysicalScreenSize()
  local base = pxPerUnit() * UIParent:GetEffectiveScale()
  SCALES, PXS = {}, {}
  for _, n in ipairs({ 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 3, 4 }) do
    if (SET_H + 60) * n <= (ph or 0) and (SEL_W + SET_W + 40) * n <= (pw or 0) then
      SCALES[#SCALES + 1] = n / base; PXS[#PXS + 1] = n
    end
  end
  if #SCALES == 0 then SCALES[1] = 1; PXS[1] = 0 end
  local best
  for _, n in ipairs(PXS) do
    if n > 0 and n == math.floor(n) and (not best or math.abs(n - base) < math.abs(best - base)
      or (math.abs(n - base) == math.abs(best - base) and n > best)) then best = n end
  end
  ANCHOR = best
end
local function clampIdx(i) return math.max(1, math.min(#SCALES, math.floor((tonumber(i) or 1) + 0.5))) end
local function scaleIndex()
  local want = GloomsHubDB and GloomsHubDB.uiPx
  local best, bestD = 1, math.huge
  for i, n in ipairs(PXS) do
    if want and n == want then return i end
    local d = math.abs(n - (want or ANCHOR or 1))
    if d < bestD then best, bestD = i, d end
  end
  return best
end
local function scaleLabel(i)
  i = clampIdx(i)
  if ANCHOR and PXS[i] and PXS[i] > 0 then return math.floor(PXS[i] / ANCHOR * 100 + 0.5) .. "%" end
  return math.floor(SCALES[i] * 100 + 0.5) .. "%"
end

-- A window's place is kept in SCREEN PIXELS (its top-left), so a scale change
-- never throws it off the screen or across it.
-- ★ ONE PLACE FOR EVERY TOOL (2026-09-30, the owner: switching tools made
-- the windows "bounce all over the place"). The selector and the settings
-- window keep ONE position and height, shared by every tool: switching puts
-- the next tool's windows exactly where the last one's were. The shared record
-- starts from the first tool opened after the change (its own old place, so
-- nothing jumps); the per-tool records are no longer read. Pop-outs stay per
-- tool. Heights still honour each window's minimum (the selector's is its
-- tool rail).
local function place(which, id)
  GloomsHubDB = GloomsHubDB or {}
  GloomsHubDB.winPlace = GloomsHubDB.winPlace or {}
  local rec = GloomsHubDB.winPlace[which]
  if not rec then
    local old = id and db(id)[which]
    rec = {}
    if old then rec.l, rec.t, rec.h = old.l, old.t, old.h end
    GloomsHubDB.winPlace[which] = rec
  end
  return rec
end
local SEL_MIN = 340   -- the tool rail's height: 30 + five tabs + gaps + 20 (the window's round corner)

local function savePlace(win, rec)
  local l, t = win:GetLeft(), win:GetTop()
  if not (l and t) then return end
  local k = pxPerUnit() * win:GetEffectiveScale()
  rec.l, rec.t, rec.h = math.floor(l * k + 0.5), math.floor(t * k + 0.5), math.floor((win:GetHeight() or 0) + 0.5)
end
local function restorePlace(win, rec, dl, dt, dh, minH)
  local k = pxPerUnit() * win:GetEffectiveScale()
  if k <= 0 then k = 1 end
  win:SetHeight(math.max(minH or 0, rec.h or dh))
  win:ClearAllPoints()
  if rec.l and rec.t then
    win:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", rec.l / k, rec.t / k)
  else
    win:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", dl / k, dt / k)
  end
  UI.gSnap(win)
end

function V:ApplyScale()
  if not root then return end
  local i = scaleIndex()
  local s = SCALES[i]
  root:SetScale(s)
  for id, st in pairs(W) do
    local d = db(id)
    local ps, pt = place("sel", id), place("set", id)
    if st.sel and ps.l then restorePlace(st.sel, ps, 0, 0, st.selH or SEL_H, SEL_MIN) end
    if st.set and pt.l then restorePlace(st.set, pt, 0, 0, SET_H) end
    for sid, pw in pairs(st.pops or {}) do
      local rec = d.pops[sid]
      if pw:IsShown() and rec and rec.l then restorePlace(pw, rec, 0, 0, SET_H) end
    end
  end
  if UI.gHairRefresh then UI.gHairRefresh() end
end

local hookWorldTooltip   -- defined with the stacking code below
local function ensureRoot()
  if root then return end
  root = CreateFrame("Frame", "GloomsSuiteWindows", UIParent)
  root:SetAllPoints(UIParent); root:SetFrameStrata("DIALOG"); root:Hide()
  root:SetScript("OnHide", function() V:Closed(); if Hub.UndoEnd then Hub:UndoEnd() end end)
  -- the suite's one UNDO history lives while the windows are open (Undo.lua)
  root:HookScript("OnShow", function() if Hub.UndoBegin then Hub:UndoBegin() end end)
  if Hub.UndoKeys then Hub:UndoKeys(root) end
  tinsert(UISpecialFrames, "GloomsSuiteWindows")   -- Escape closes every window
  buildLadder()
  hookWorldTooltip()
  root:SetScale(SCALES[scaleIndex()])
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("UI_SCALE_CHANGED"); ev:RegisterEvent("DISPLAY_SIZE_CHANGED")
  ev:SetScript("OnEvent", function() buildLadder(); if root:IsShown() then V:ApplyScale() end end)
end

-- ------------------------------------------------------------
-- STACKING (2026-09-27, the owner's screenshot: two windows overlapping mixed —
-- the one behind showed its footer buttons and resize bar through the one in
-- front). Every window lives in the same strata and its pieces sit at assorted
-- levels above it, so two windows' levels interleaved. Now each window gets a
-- BAND of levels of its own, the bands stacked in focus order, and a click
-- anywhere in a window (its controls included — GLOBAL_MOUSE_DOWN) brings its
-- whole band to the top. Levels are reassigned parent-first, each piece keeping
-- its own offset above its parent.
-- ------------------------------------------------------------
local order = {}        -- managed windows, bottom → top
local function relevel(win, base)
  local recs = {}
  local function walk(fr)
    for _, ch in ipairs({ fr:GetChildren() }) do
      recs[#recs + 1] = { ch, fr, math.max(1, (ch:GetFrameLevel() or 0) - (fr:GetFrameLevel() or 0)) }
      walk(ch)
    end
  end
  walk(win)
  win:SetFrameLevel(base)
  local top = base
  for _, r in ipairs(recs) do
    local lv = (r[2]:GetFrameLevel() or base) + r[3]
    r[1]:SetFrameLevel(lv)
    if lv > top then top = lv end
  end
  return top
end
local function restack()
  local base = 10
  for _, w in ipairs(order) do
    if w:IsShown() then base = relevel(w, base) + 5 end
  end
end
local function front(win)
  for i = #order, 1, -1 do if order[i] == win then table.remove(order, i) end end
  order[#order + 1] = win
  restack()
end
V.Front = function(_, win) front(win) end
-- A tool's own extra window (Auras' group Load Conditions) joins the stack.
function Hub:SuiteManage(win) front(win) end
local mouseWatch
local function watchClicks()
  if mouseWatch then return end
  mouseWatch = CreateFrame("Frame")
  mouseWatch:RegisterEvent("GLOBAL_MOUSE_DOWN")
  mouseWatch:SetScript("OnEvent", function()
    if not (root and root:IsShown()) then return end
    for i = #order, 1, -1 do
      local w = order[i]
      if w:IsShown() and (w:IsMouseOver() or (w.tab and w.tab:IsMouseOver()) or (w.grip and w.grip:IsMouseOver())) then
        if i ~= #order then front(w) end
        return
      end
    end
  end)
end

-- ------------------------------------------------------------
-- WORLD TOOLTIPS stay off the windows (the owner, 2026-09-27: people walking
-- under the cursor pop the game's tooltip ON TOP of the settings being
-- adjusted). The tooltip strata is above every window, so it cannot be put
-- behind them; instead, while the Suite is open, a WORLD tooltip (owned by
-- UIParent or WorldFrame: a unit or object under the cursor) that would overlap
-- any of our windows is hidden. Tooltips on buttons, bags and our own controls
-- have other owners and are untouched. Our own hook on the shared tooltip; no
-- other addon is modified, and it runs after whatever positioned the tooltip.
-- ------------------------------------------------------------
local function screenRect(fr)
  local l, b, w, h = fr:GetRect(); if not l then return nil end
  local s = fr:GetEffectiveScale()
  return l * s, b * s, (l + w) * s, (b + h) * s
end
local function overlaps(a1, b1, c1, d1, a2, b2, c2, d2)
  return a1 < c2 and a2 < c1 and b1 < d2 and b2 < d1
end
local function tipCoversWindow(tip)
  if not (root and root:IsShown()) then return false end
  local owner = tip:GetOwner()
  if owner ~= UIParent and owner ~= WorldFrame then return false end
  local l, b, r, t = screenRect(tip); if not l then return false end
  for _, w in ipairs(order) do
    if w:IsShown() then
      for _, fr in ipairs({ w, w.tab }) do
        if fr and fr:IsShown() then
          local l2, b2, r2, t2 = screenRect(fr)
          if l2 and overlaps(l, b, r, t, l2, b2, r2, t2) then return true end
        end
      end
    end
  end
  return false
end
local tipHooked
hookWorldTooltip = function()
  if tipHooked or not GameTooltip then return end
  tipHooked = true
  local function check(tip) if tipCoversWindow(tip) then tip:Hide() end end
  GameTooltip:HookScript("OnShow", check)
  GameTooltip:HookScript("OnUpdate", check)    -- a cursor-anchored tooltip moves after it shows
end

-- ------------------------------------------------------------
-- The settings window's layout: headers, the open section, Global Settings.
-- ------------------------------------------------------------
local function tabsRefresh(id)
  local st = W[id]; if not st then return end
  for _, t in ipairs(st.tabs) do if t.refresh then t:refresh() end end
end
function Hub:RefreshWindows(id)
  id = id or cur
  tabsRefresh(id)
  local st = W[id]
  if st then
    local g = st.built.__global
    if g and g.frame.refresh then g.frame:refresh() end
    if st.layout then st.layout() end
  end
end
-- A tool's own windows: which = "sel" | "set".
function Hub:SuiteWindow(id, which) local st = W[id]; return st and st[which] end
-- The parent every Suite window hangs from (a tool's own floating windows use it
-- too, so they scale and close with the rest).
function Hub:SuiteRoot() return root end

local function sectionList(def)
  local out = {}
  for _, s in ipairs(def.sections or {}) do out[#out + 1] = s end
  out[#out + 1] = def._global
  return out
end

-- Build a section's content once; it moves between the settings window and its
-- pop-out after that.
local function builtSection(def, sec, parent)
  local st = W[def.id]
  local b = st.built[sec.id]
  if not b then
    -- a section that resizes itself while it is first built asks for a layout;
    -- that layout must not build it a second time
    st.building = st.building or {}
    if st.building[sec.id] then return nil end
    st.building[sec.id] = true
    local frame = sec.build(parent)
    st.building[sec.id] = nil
    frame:SetWidth(CONTENT_W)
    b = { frame = frame }
    frame:HookScript("OnSizeChanged", function() if st.layout then st.layout() end; if b.popLayout then b.popLayout() end end)
    st.built[sec.id] = b
  end
  if b.frame:GetParent() ~= parent then b.frame:SetParent(parent) end
  return b
end

local function footerFor(def, sec, parent)
  if not sec.footer then return nil end
  local st = W[def.id]
  st.footers = st.footers or {}
  local f = st.footers[sec.id]
  if not f then f = sec.footer(parent); st.footers[sec.id] = f end
  if f:GetParent() ~= parent then f:SetParent(parent) end
  f:SetFrameLevel(parent:GetFrameLevel() + 30)
  return f
end

local function popOut(def, sid) end   -- (forward)
local function popIn(def, sid) end

-- A section's title may be a function (it changes: "Global Player Settings").
local function secTitle(sec) if type(sec.title) == "function" then return sec.title() end return sec.title end
local function layoutSettings(def)
  local st = W[def.id]; local win = st.set
  if not (win and win:IsShown()) then return end
  if st.inLayout then st.again = true; return end
  st.inLayout = true
  local putBack = {}   -- popped-out sections that just locked: put back after the layout
  local ok, err = pcall(function()
  local d = db(def.id)
  local sa = st.scroll
  local child = sa.child
  local y = HEAD_Y
  local footer
  for _, h in pairs(st.heads) do h:Hide() end
  for sid, b in pairs(st.built) do if not d.pops[sid] and b.frame:GetParent() == child then b.frame:Hide() end end
  for _, f in pairs(st.footers or {}) do if f:GetParent() == win.content then f:Hide() end end
  for _, sec in ipairs(sectionList(def)) do
    local hidden = sec.hidden and sec.hidden()
    if hidden and d.open == sec.id then d.open = nil end
    local locked = sec.locked and sec.locked()
    if locked and d.open == sec.id then d.open = nil end
    if locked and d.pops[sec.id] then putBack[#putBack + 1] = sec.id end
    if not d.pops[sec.id] and not hidden then
      local h = st.heads[sec.id]
      if not h then
        h = UI.gSectionHead(child, secTitle(sec), {
          onToggle = function()
            d.open = (d.open ~= sec.id) and sec.id or nil
            layoutSettings(def)
            if d.open then
              local b2 = st.built[sec.id]; if b2 and sec.onShow then sec.onShow() end
            end
          end,
          onPop = function() popOut(def, sec.id) end,
        })
        st.heads[sec.id] = h
      end
      h:ClearAllPoints(); h:SetPoint("TOPLEFT", child, "TOPLEFT", 20, -y); h:Show()
      if type(sec.title) == "function" then h:SetTitle(secTitle(sec)) end
      h:SetAlpha((locked or (sec.dim and sec.dim())) and UI.G_DIM or 1)
      h:EnableMouse(not locked); h.pop:EnableMouse(not locked)
      local open = (d.open == sec.id)
      h:SetOpen(open)
      local b = open and builtSection(def, sec, child)
      if b then
        b.frame:ClearAllPoints(); b.frame:SetPoint("TOPLEFT", child, "TOPLEFT", 20, -(y + HEAD_TO_CONTENT))
        b.frame:Show()
        y = y + HEAD_TO_CONTENT + math.ceil(b.frame:GetHeight() or 0) + CONTENT_TO_HEAD
        footer = footerFor(def, sec, win.content)
      else
        y = y + HEAD_PITCH
      end
    end
  end
  y = y - HEAD_PITCH + 14 + 30
  if footer then
    footer:ClearAllPoints(); footer:SetPoint("BOTTOMLEFT", win.content, "BOTTOMLEFT", 20, 20); footer:Show()
    y = y + (footer:GetHeight() or 15) + 20
  end
  sa:SetContentHeight(y)
  end)
  st.inLayout = false
  if not ok then geterrorhandler()(err) end
  restack()   -- pieces built during the layout take their place in the window's band
  if st.again then st.again = false; layoutSettings(def) end
  for _, sid in ipairs(putBack) do popIn(def, sid) end   -- a popped-out section that just locked
end

-- ------------------------------------------------------------
-- Pop-outs
-- ------------------------------------------------------------
local function makeTab(def, win)
  local t = def.tab and def.tab.build and def.tab.build(win.tab)
  if t then W[def.id].tabs[#W[def.id].tabs + 1] = t; if t.refresh then t:refresh() end end
end

local function findSection(def, sid)
  for _, s in ipairs(sectionList(def)) do if s.id == sid then return s end end
end

popOut = function(def, sid)
  local st = W[def.id]; local d = db(def.id)
  local sec = findSection(def, sid); if not sec then return end
  if sec.locked and sec.locked() then return end
  d.pops[sid] = d.pops[sid] or (d.popPlaces and d.popPlaces[sid]) or {}
  d.pops[sid].shown = true
  if d.open == sid then d.open = nil end
  local pw = st.pops[sid]
  if not pw then
    pw = UI.gWindow({ parent = root, w = SET_W, h = 300, tabW = def.tab and (def.tab.w or 360) or nil, minH = 120,
      onFocus = front,
      onClose = function() popIn(def, sid) end,
      onMoved = function() if d.pops[sid] then savePlace(pw, d.pops[sid]) end end,
      onResized = function() if d.pops[sid] then savePlace(pw, d.pops[sid]) end end })
    if pw.tab then makeTab(def, pw) end
    local head = UI.gSectionHead(pw.content, secTitle(sec), { popped = true, onPop = function() popIn(def, sid) end })
    head:SetPoint("TOPLEFT", pw.content, "TOPLEFT", 20, -POP_HEAD_Y)
    head:SetFrameLevel(pw.content:GetFrameLevel() + 25)
    local sa = UI.gScrollArea(pw.content)
    head:SetParent(sa.child); head:ClearAllPoints(); head:SetPoint("TOPLEFT", sa.child, "TOPLEFT", 20, -POP_HEAD_Y)
    pw.scroll, pw.head = sa, head
    st.pops[sid] = pw
  end
  local b = builtSection(def, sec, pw.scroll.child)
  if not b then return end
  local function popLayout()
    if b.frame:GetParent() ~= pw.scroll.child then return end
    b.frame:ClearAllPoints(); b.frame:SetPoint("TOPLEFT", pw.scroll.child, "TOPLEFT", 20, -(POP_HEAD_Y + HEAD_TO_CONTENT))
    b.frame:Show()
    local y = POP_HEAD_Y + HEAD_TO_CONTENT + math.ceil(b.frame:GetHeight() or 0) + 30
    local f = footerFor(def, sec, pw.content)
    if f then f:ClearAllPoints(); f:SetPoint("BOTTOMLEFT", pw.content, "BOTTOMLEFT", 20, 20); f:Show(); y = y + (f:GetHeight() or 15) + 20 end
    pw.scroll:SetContentHeight(y)
    restack()
    return y
  end
  b.popLayout = popLayout
  local need = popLayout()
  -- first time out: as tall as it needs (at most the settings window's height),
  -- beside the settings window
  local rec = d.pops[sid]
  if not rec.l then
    local set = st.set
    local k = pxPerUnit() * root:GetEffectiveScale()
    local l = set and set:GetRight() and (set:GetRight() * k + 20 * k) or 400
    local t = set and set:GetTop() and (set:GetTop() * k) or 700
    rec.l, rec.t, rec.h = math.floor(l + 0.5), math.floor(t + 0.5), math.min(SET_H, need)
  end
  pw:Show()
  restorePlace(pw, rec, rec.l, rec.t, math.min(SET_H, need))
  front(pw)
  if sec.onShow then sec.onShow() end
  layoutSettings(def)
end

popIn = function(def, sid)
  local st = W[def.id]; local d = db(def.id)
  local pw = st.pops[sid]
  if pw then savePlace(pw, d.pops[sid] or {}); pw:Hide() end
  if d.pops[sid] then d.pops[sid].shown = nil end
  -- keep its place for next time, but it is no longer out
  local keep = d.pops[sid]
  d.pops[sid] = nil
  d.popPlaces = d.popPlaces or {}
  d.popPlaces[sid] = keep
  local b = st.built[sid]
  if b then b.popLayout = nil; b.frame:SetParent(st.scroll.child); b.frame:Hide() end
  if st.footers and st.footers[sid] then st.footers[sid]:Hide() end
  layoutSettings(def)
end

-- ------------------------------------------------------------
-- Global Settings (the Hub's section, last in every tool's list)
-- ------------------------------------------------------------
local TAB_ORDER = { auras = 10, bars = 20, unitframes = 30, portraits = 40, overlays = 50, media = 90 }
local function productName(def)
  if def.product then return def.product end
  local t = tostring(def.title or def.id):lower():gsub("(%a)([%w]*)", function(a, b) return a:upper() .. b end):gsub("%s", "")
  return "Gloom" .. t
end
local function buildGlobal(parent)
  local f = CreateFrame("Frame", nil, parent); f:SetWidth(CONTENT_W)
  local y = 0
  local list = {}
  for _, d in pairs(Hub._tabs or {}) do if d.profile then list[#list + 1] = d end end
  table.sort(list, function(a, b) return (TAB_ORDER[a.id] or a.order or 99) < (TAB_ORDER[b.id] or b.order or 99) end)
  f.blocks = {}
  for _, d in ipairs(list) do
    local blk = UI.gProfileBlock(f, d.profile, productName(d) .. " Profile", CONTENT_W)
    blk.frame:SetPoint("TOPLEFT", 0, -y)
    f.blocks[#f.blocks + 1] = blk
    y = y + 57 + 30
  end
  -- the tools' own global switches, then the Addon UI Scale, two to a row
  local cells = {}
  for _, d in ipairs(list) do for _, g in ipairs(d.globals or {}) do cells[#cells + 1] = g end end
  for _, d in pairs(Hub._tabs or {}) do
    if not d.profile then for _, g in ipairs(d.globals or {}) do cells[#cells + 1] = g end end
  end
  local col = 0
  f.switches = {}
  for _, g in ipairs(cells) do
    local x = (col == 0) and 0 or 190
    UI.gLabel(f, g.label):SetPoint("TOPLEFT", x, -y)
    local sw = UI.gSwitch(f, g.choices, g.get, g.set, { w = 170 })
    sw:SetPoint("TOPLEFT", x, -(y + 15))
    if g.tip then UI.attachTip(sw, g.label, g.tip) end
    f.switches[#f.switches + 1] = sw
    col = col + 1
    if col == 2 then col = 0; y = y + 31 + 10 end
  end
  local x = (col == 0) and 0 or 190
  local dial
  dial = UI.gDial(f, {
    label = "Addon UI Scale", w = 170, min = 1, max = math.max(2, #SCALES), step = 1, dragPx = 300,
    fmt = scaleLabel, get = scaleIndex,
    set = function(v)
      local i = clampIdx(v)
      GloomsHubDB = GloomsHubDB or {}
      GloomsHubDB.uiPx = PXS[i]
      if dial and dial.strip and dial.strip._drag then dial._pending = true else V:ApplyScale() end
    end,
  })
  dial:SetPoint("TOPLEFT", x, -y)
  dial.box:EnableMouse(false); dial.box:EnableKeyboard(false)
  dial.strip:HookScript("OnUpdate", function(self)
    if dial._pending and not self._drag then dial._pending = false; V:ApplyScale() end
  end)
  UI.attachTip(dial.strip, "Addon UI Scale", function()
    local n = PXS[scaleIndex()] or 0
    local sharp = (n > 0 and n == math.floor(n))
    return (sharp and "A sharp size: every line lands on whole screen pixels. 100% is the sharp size nearest the rest of your UI."
      or "Between the sharp sizes: outlines stay one pixel and text is drawn at its size; an edge may sit half a pixel off.")
      .. " Pull along the ticks; the windows resize when you let go."
  end)
  f.dial = dial
  y = y + 31
  f:SetHeight(y)
  function f:refresh()
    for _, b in ipairs(self.blocks) do b:refresh() end
    for _, s in ipairs(self.switches) do s:refresh() end
    self.dial:refresh()
  end
  f:HookScript("OnShow", function(self) self:refresh() end)
  return f
end

-- ------------------------------------------------------------
-- Building a tool's windows
-- ------------------------------------------------------------
local function buildTool(def)
  local st = { tabs = {}, built = {}, pops = {}, heads = {} }
  W[def.id] = st
  local d = db(def.id)
  def._global = def._global or { id = "__global", title = "Global Settings", build = buildGlobal }
  local function closeAll() root:Hide() end

  -- THE SELECTOR
  local selH = (def.selector and def.selector.h) or SEL_H
  st.selH = selH
  local sel = UI.gWindow({ parent = root, w = SEL_W, h = math.max(selH, SEL_MIN), minH = SEL_MIN, onFocus = front,
    onClose = closeAll,
    onMoved = function() savePlace(st.sel, place("sel", def.id)) end,
    onResized = function() savePlace(st.sel, place("sel", def.id)) end })
  st.sel = sel
  local sw = CreateFrame("Button", nil, sel.content); sw:SetHeight(16)
  sw:SetPoint("TOPLEFT", 20, -17)
  sw:SetFrameLevel(sel.content:GetFrameLevel() + 20)
  local mark = UI.newText(sw, FONT.sa, 14, COLOR.paper, "LEFT"); mark:SetPoint("LEFT", 0, 0)
  mark:SetText(("gloom|cff%s%s|r"):format(("%02x%02x%02x"):format(COLOR.lime.r * 255, COLOR.lime.g * 255, COLOR.lime.b * 255), def.wordmark or (def.title or def.id):upper()))
  local tri = sw:CreateTexture(nil, "ARTWORK"); tri:SetTexture(UI.G_TRI); tri:SetSize(6, 7); tri:SetRotation(math.pi / 2)
  UI.tint(tri, COLOR.lime); tri:SetPoint("LEFT", mark, "RIGHT", 6, 0)
  sw:SetWidth(math.ceil(mark:GetStringWidth()) + 16)
  sw:SetScript("OnClick", function(self)
    local list = {}
    for _, t in ipairs(Hub._ordered or {}) do list[#list + 1] = { value = t.id, label = t.title or t.id } end
    UI.gList(self, list, def.id, function(v) Hub:FocusTab(v) end, { minW = 160 })
  end)
  UI.attachTip(sw, "Gloom Suite", function() return Hub:VersionLine() end)
  -- Undo · Redo at the title row's right (Undo.lua)
  if Hub.UndoButtons then Hub:UndoButtons(sel.content) end
  -- ★ THE TOOL RAIL (2026-09-30, the owner's Figma "Frame 614": "too
  -- cumbersome to switch between modules"). A column of small vertical tabs
  -- outside the selector's LEFT edge — 18 wide, FLUSH with it (the mock's 2 gap
  -- was a slip — the owner, 2026-09-30), the first 30
  -- below its top, 4 apart — one per tool in switcher order: violet with white
  -- capitals, the open tool lime with dark purple (#0f051d). Sansation 9 can't be
  -- turned in WoW, so each tab is art (tools/gen-rail-art.py: rail-<id>-bg /
  -- -text, tinted here). Gloom's UI keeps its OVERLAYS tab (the owner). A tool
  -- with no art gets no tab. The window's clamp grows 20 to the left to keep
  -- the rail on the screen.
  do
    local RAIL_H = { auras = 47, bars = 40, unitframes = 76, overlays = 64, media = 46 }
    local VIOLET_TAB = { r = 0x6c / 255, g = 0x2f / 255, b = 0xe6 / 255 }
    local DARK = { r = 0x0f / 255, g = 0x05 / 255, b = 0x1d / 255 }
    local y = 30
    for _, t in ipairs(Hub._ordered or {}) do
      local h = RAIL_H[t.id]
      if h and t.windows then
        local b = CreateFrame("Button", nil, sel)
        b:SetSize(18, h); b:SetPoint("TOPRIGHT", sel, "TOPLEFT", 0, -y)
        local bg = b:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetTexture("Interface\\AddOns\\GloomsHub\\Media\\ui\\rail-" .. t.id .. "-bg.png")
        local tx = b:CreateTexture(nil, "ARTWORK"); tx:SetAllPoints(); tx:SetTexture("Interface\\AddOns\\GloomsHub\\Media\\ui\\rail-" .. t.id .. "-text.png")
        local on = t.id == def.id
        UI.tint(bg, on and COLOR.lime or VIOLET_TAB)
        UI.tint(tx, on and DARK or COLOR.paper)
        if not on then
          b:SetScript("OnEnter", function() bg:SetVertexColor(VIOLET_TAB.r * 1.25, VIOLET_TAB.g * 1.25, VIOLET_TAB.b * 1.15) end)
          b:SetScript("OnLeave", function() UI.tint(bg, VIOLET_TAB) end)
          b:SetScript("OnClick", function() Hub:FocusTab(t.id) end)
        end
        y = y + h + 4
      end
    end
    sel:SetClampRectInsets(-20, 0, 20, -10)
  end
  if def.selector and def.selector.build then def.selector.build(sel.content, { window = sel }) end
  st.pendingSet = true

  -- THE SETTINGS WINDOW
  local set = UI.gWindow({ parent = root, w = SET_W, h = SET_H, tabW = def.tab and (def.tab.w or 360) or nil, minH = 160, onFocus = front,
    onClose = closeAll,
    onMoved = function() savePlace(st.set, place("set", def.id)) end,
    onResized = function() savePlace(st.set, place("set", def.id)) end })
  st.set = set
  if set.tab then makeTab(def, set) end
  st.scroll = UI.gScrollArea(set.content)
  st.layout = function() layoutSettings(def) end
  set:HookScript("OnShow", function() layoutSettings(def) end)
  if def.onBuilt then def.onBuilt(sel, set) end
end

local function placeDefaults(def)
  local st, d = W[def.id], db(def.id)
  local pw, ph = GetPhysicalScreenSize()
  local k = pxPerUnit() * root:GetEffectiveScale()
  local total = (SEL_W + 20 + SET_W) * k
  local l = math.floor(((pw or 1920) - total) / 2)
  local t = math.floor(((ph or 1080) + SET_H * k) / 2)
  restorePlace(st.sel, place("sel", def.id), l, t, st.selH or SEL_H, SEL_MIN)
  restorePlace(st.set, place("set", def.id), l + (SEL_W + 20) * k, t, SET_H)
end

-- ------------------------------------------------------------
-- Opening, switching, closing
-- ------------------------------------------------------------
function V:IsOpen() return root and root:IsShown() or false end
function V:Current() return cur end

function V:Open(def, sectionId)
  ensureRoot()
  -- Already on screen: just go to the section (a "Styled in:" link, /gb, a slash).
  if root:IsShown() and cur == def.id and W[def.id] then
    local st, d = W[def.id], db(def.id)
    if sectionId then
      if d.pops[sectionId] then local pw = st.pops[sectionId]; if pw then front(pw) end
      else
        d.open = sectionId
        layoutSettings(def)
        local sec = findSection(def, sectionId)
        if sec and sec.onShow then sec.onShow() end
      end
    end
    front(st.set)
    return
  end
  if cur and cur ~= def.id and W[cur] then V:HideTool(cur) end
  root:Show()
  local first = not W[def.id]
  if first then buildTool(def) end
  cur = def.id
  if GloomsHubDB then GloomsHubDB.lastTab = def.id end
  local st, d = W[def.id], db(def.id)
  st.sel:Show(); st.set:Show()
  placeDefaults(def)
  watchClicks()
  front(st.sel); front(st.set)
  if sectionId then
    if d.pops[sectionId] then local pw = st.pops[sectionId]; if pw then front(pw) end
    else d.open = sectionId end
  end
  -- sections that were out stay out
  for sid, rec in pairs(d.pops) do
    if rec.shown then popOut(def, sid) end
  end
  tabsRefresh(def.id)
  layoutSettings(def)
  if def.onOpen then def.onOpen() end
  if def.refresh then def.refresh() end
end

function V:HideTool(id)
  local st = W[id]; if not st then return end
  local def = Hub._tabs and Hub._tabs[id]
  st.sel:Hide(); st.set:Hide()
  for _, pw in pairs(st.pops) do pw:Hide() end
  if def and def.onClose then def.onClose() end
end

-- The root hid (a close disc, Escape, or the switcher leaving for an old-style
-- tool): every window of the tool goes, positions already saved.
function V:Closed()
  if cur then V:HideTool(cur) end
  UI.gListClose()
end

function V:Close() if root then root:Hide() end end
