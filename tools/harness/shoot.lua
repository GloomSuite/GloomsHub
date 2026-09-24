-- Open a page of the Auras tab with one aura selected and dump the window:
--   luajit shoot.lua <page> <displayID>  →  dump-<page>.jsonl  (then render.py)
dofile("run.lua"); dofile("dump.lua")
local page, sel = arg[1] or "triggers", arg[2] or "d1"
GloomsHub:Open("auras")
local X = GloomsAuras.Config.X
X.SetSelected(sel)
GloomsHub:ShowPage("auras", page)
__DUMP(GloomsSuiteWindow, "dump-" .. page .. ".jsonl")
