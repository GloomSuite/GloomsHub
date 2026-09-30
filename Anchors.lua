-- ============================================================
-- Anchors.lua — Gloom's Hub
-- ★ ANCHORS (2026-09-30, the owner: Unit Frames and gloomUI "are often
-- working together to form a unit in the UI"). A tool OFFERS frames other
-- tools may attach to; another tool LISTS them and pins its own things to one.
-- Neither needs the other installed: an offer that never came, or whose frame
-- is gone, is simply not there (the attaching tool falls back to the screen).
--   GloomsHub:RegisterAnchor(id, { label = "Player Frame", frame = fn() → frame })
--   GloomsHub:Anchors() → { { id, label }, … } in registration order
--   GloomsHub:AnchorFrame(id) → the frame, or nil
--   GloomsHub:AnchorLabel(id) → its label, or nil
-- Offered today: Unit Frames' "uf:player" (Player Frame) and "uf:target"
-- (Target Frame) — each frame's CENTRE is the unit's saved position, so editing
-- its rings never moves what is attached. Taken by gloomUI's groups.
-- ============================================================

local Hub = GloomsHub
local anchors, order = {}, {}

function Hub:RegisterAnchor(id, spec)
  if not anchors[id] then order[#order + 1] = id end
  anchors[id] = spec
end
function Hub:Anchors()
  local out = {}
  for _, id in ipairs(order) do out[#out + 1] = { id = id, label = anchors[id].label or id } end
  return out
end
function Hub:AnchorFrame(id)
  local a = id and anchors[id]
  if not a then return nil end
  local ok, f = pcall(a.frame)
  return ok and f or nil
end
function Hub:AnchorLabel(id) local a = id and anchors[id]; return a and a.label or nil end

-- ★ READINESS (2026-09-30, the owner: an attached group sat in the wrong place
-- right after a /reload until gloomUI was opened). An offering tool may build
-- its frames AFTER a taker has placed things — addons load alphabetically, and
-- Overlays comes before Unit Frames — so a taker found no frame and fell back
-- to the screen. The offering tool calls AnchorsChanged() once its frames
-- exist; takers listen with OnAnchorsChanged(fn) and place their things again.
local listeners = {}
function Hub:OnAnchorsChanged(fn) listeners[#listeners + 1] = fn end
function Hub:AnchorsChanged()
  for _, fn in ipairs(listeners) do local ok, err = pcall(fn); if not ok then geterrorhandler()(err) end end
end
