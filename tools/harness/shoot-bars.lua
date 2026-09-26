-- Open a page of the Bars tab and dump the window:
--   luajit shoot-bars.lua <page>  →  dump-bars-<page>.jsonl  (then render.py)
ADDONS = { "GloomsHub", "GloomsBars" }
dofile("run.lua"); dofile("dump.lua")
local page = arg[1] or "shape"
GloomsHub:Open("bars")
GloomsHub:ShowPage("bars", page)
__DUMP(GloomsSuiteWindow, "dump-bars-" .. page .. ".jsonl")
