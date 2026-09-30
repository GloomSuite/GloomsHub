-- Open a two-window tool on one section and dump its windows (Windows.lua):
--   luajit shoot-v3.lua <tool> <section> [popout]
--   → dump-v3-<tool>-sel.jsonl, dump-v3-<tool>-<section>.jsonl (then render.py)
ADDONS = { "GloomsHub", "GloomsAuras", "GloomsBars", "GloomsUnitFrames", "GloomsOverlays" }
dofile("run.lua"); dofile("dump.lua")
local tool, sec = arg[1] or "auras", arg[2] or "triggers"
GloomsHub:Open(tool)
GloomsHub:ShowPage(tool, sec)
GloomsHub:RefreshWindows(tool)
__DUMP(GloomsHub:SuiteWindow(tool, "sel"), "dump-v3-" .. tool .. "-sel.jsonl")
__DUMP(GloomsHub:SuiteWindow(tool, "set"), "dump-v3-" .. tool .. "-" .. sec .. ".jsonl")
