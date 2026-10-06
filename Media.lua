-- ============================================================
-- Media.lua — Gloom's Hub
-- Salvaged from StoneTweaks. Registers custom TTF fonts and
-- statusbar textures into LibSharedMedia-3.0 so they appear in
-- any LSM-aware addon, and manages Graphics — decorative assets
-- (overlays etc.) that are NOT registered into LSM.
--
-- Drop files into:
--   Interface\AddOns\GloomsHub\Fonts\      (.ttf only)
--   Interface\AddOns\GloomsHub\Textures\   (.blp, .tga, or .png)
--   Interface\AddOns\GloomsHub\Graphics\   (.png or .tga)
-- ============================================================

local FONT_PATH    = "Interface\\AddOns\\GloomsHub\\Fonts\\"
local TEXTURE_PATH = "Interface\\AddOns\\GloomsHub\\Textures\\"
local GRAPHIC_PATH = "Interface\\AddOns\\GloomsHub\\Graphics\\"
local SOUND_PATH   = "Interface\\AddOns\\GloomsHub\\Sounds\\"

local Media = {}
GloomsHub.Media = Media

-- ============================================================
-- LSM access
-- ============================================================

local function GetLSM()
    if LibStub then
        local ok, lsm = pcall(LibStub, "LibSharedMedia-3.0")
        if ok and lsm then return lsm end
    end
    return nil
end

-- ============================================================
-- Register helpers
-- ============================================================

local function RegisterFont(entry)
    local lsm = GetLSM()
    if not lsm then
        return false, "LibSharedMedia-3.0 not found."
    end
    local path = FONT_PATH .. entry.file
    local ok = lsm:Register("font", entry.name, path)
    if ok == false then
        return false, "A font named \"" .. entry.name .. "\" is already registered (possibly by another addon)."
    end
    return true
end

local function RegisterTexture(entry)
    local lsm = GetLSM()
    if not lsm then
        return false, "LibSharedMedia-3.0 not found."
    end
    local path = TEXTURE_PATH .. entry.file
    local ok = lsm:Register("statusbar", entry.name, path)
    if ok == false then
        return false, "A texture named \"" .. entry.name .. "\" is already registered (possibly by another addon)."
    end
    return true
end

-- ★ TWO DIFFERENT ID NAMESPACES — do not confuse them (verified 2026-08-24):
--   * FileDataID  → PlaySoundFile(id)   — every audio file in the game.
--   * SoundKitID  → PlaySound(id)       — the 865 named SOUNDKIT.* constants.
-- They are NOT interchangeable. The same "raid warning" sound is FileDataID
-- 567397 and SoundKitID 8959. LibSharedMedia's sound table is FileDataID/path
-- ONLY: every consumer Fetches a value and hands it straight to PlaySoundFile
-- (BigWigs_Plugins/Sound.lua:134 is the reference implementation, and GA's
-- CDM:PlaySound does the same). Registering a SoundKitID into LSM would
-- therefore play the wrong file — or nothing — in every addon that reads it.
-- Sounds:Play below is the only place that is allowed to know the difference.
local function RegisterSound(entry)
    local lsm = GetLSM()
    if not lsm then
        return false, "LibSharedMedia-3.0 not found."
    end
    -- entry.file is a FileDataID (number) or a full Interface\ path (string).
    local ok = lsm:Register("sound", entry.name, entry.file)
    if ok == false then
        return false, "A sound named \"" .. entry.name .. "\" is already registered (possibly by another addon)."
    end
    return true
end

-- ============================================================
-- The font load-check — fired at PLAYER_ENTERING_WORLD (see RegisterAll)
-- ============================================================

function Media:VerifyFonts()
    -- Pre-warm the UI's font/size pairs plus each catalog font at every size
    -- the suite draws it: 13 = the Media tab's preview rows, 11 / 14 = the
    -- tools' font pickers (dropdown label / flyout rows — GB's, and GA's come
    -- Phase D). Lazily-built text must never draw a cold pair blank (see
    -- Skin.lua's WarmFonts).
    local warm = {}
    for _, entry in ipairs(GloomsHubDB.fonts) do
        for _, size in ipairs({ 11, 13, 14 }) do
            warm[#warm + 1] = { FONT_PATH .. entry.file, size }
        end
    end
    -- Warming runs AFTER registration now (it used to run just before it, in the
    -- same function; the two were split 2026-09-19) and reports which faces would not
    -- load — the only existence check the client permits (there is no
    -- filesystem API). A catalog entry can outlive its file: AddFont validates
    -- the extension but cannot confirm the .ttf is actually there, so a typo'd
    -- filename or a deleted font sits in SavedVariables forever.
    --
    -- ⚠ This is a WARNING ONLY — registration below is deliberately NOT made
    -- conditional on it. WoW indexes fonts at launch, so a font added this
    -- session (file present, restart pending) may well fail the probe while
    -- being perfectly valid. Skipping registration on that signal would
    -- silently drop a good font, which is worse than the problem being fixed.
    --
    -- ★ THE VERDICT IS NOW THE SECOND DRAW, NOT THE FIRST (2026-09-08, lib
    -- MINOR 8). The first draw of a COLD font reliably fails — that is the very
    -- thing warming exists to fix — so the old synchronous result accused every
    -- drop-in catalog font of being missing on every cold client start, and
    -- never on /reload. Owner-reported and confirmed by prediction; FINDINGS §5.
    -- The callback fires ~2s later with only what still fails, which is the
    -- answer worth printing. A truly missing file fails both passes.
    GloomsHub.UI.WarmFonts(warm, function(stillDead)
        if not stillDead then return end
        for _, entry in ipairs(GloomsHubDB.fonts) do
            if stillDead[FONT_PATH .. entry.file] then
                GloomsHub:Print("|cffff9900Font \"" .. entry.name .. "\" did not load|r — GloomsHub\\Fonts\\"
                    .. entry.file .. " is missing or misnamed. Check the filename, or remove it in the Media tab. "
                    .. "(If you only just added it, restart WoW first — fonts load at launch.)")
            end
        end
    end)
end

-- ============================================================
-- Register all saved entries — fired at the Hub's own ADDON_LOADED
-- (the earliest moment GloomsHubDB exists), NOT at PLAYER_ENTERING_WORLD.
--
-- ★ WHY SO EARLY (2026-09-19, owner-confirmed by prediction). Addons load
-- alphabetically, so every "EllesmereUI…" module starts before the Hub and
-- asks LibSharedMedia for the owner's font before it is registered. LSM's
-- Fetch answers an UNKNOWN name with its DEFAULT — Friz Quadrata — and EUI's
-- unit-frame module caches that answer privately, refreshing it only when its
-- frames are rebuilt. EUI's core does listen for late registrations, so the
-- one moment that matters is: register BEFORE PLAYER_LOGIN, when EUI builds
-- its unit frames. ADDON_LOADED is; PLAYER_ENTERING_WORLD was not, and the
-- live player/target frames rendered in Friz while EUI's own preview (built
-- later, from the corrected cache) showed the right font.
-- The old timing was inherited from StoneTweaks, not chosen; LSM is usable
-- from file load. Registration is additive — earlier can only be seen by
-- more consumers — so nothing in the suite depends on it being late.
--
-- The load-check (WarmFonts, in Media:VerifyFonts above) deliberately STAYS
-- at PLAYER_ENTERING_WORLD, where its two-pass timing was proven (FINDINGS §5).
-- ============================================================

function Media:RegisterAll()
    local lsm = GetLSM()
    if not lsm then
        GloomsHub:Print("|cffff9900LibSharedMedia-3.0 not found.|r Fonts and textures won't appear in other addons.")
        return
    end

    local fontCount, texCount = 0, 0

    for _, entry in ipairs(GloomsHubDB.fonts) do
        local ok, err = RegisterFont(entry)
        if ok then
            fontCount = fontCount + 1
        else
            GloomsHub:Print("|cffff4444Font skipped — " .. entry.name .. ": " .. (err or "unknown") .. "|r")
        end
    end

    for _, entry in ipairs(GloomsHubDB.textures) do
        local ok, err = RegisterTexture(entry)
        if ok then
            texCount = texCount + 1
        else
            GloomsHub:Print("|cffff4444Texture skipped — " .. entry.name .. ": " .. (err or "unknown") .. "|r")
        end
    end

    -- Sounds come from TWO places, both ending in the same LSM table:
    --   1. SoundsManifest.lua — everything sitting in GloomsHub\\Sounds\\,
    --      indexed by tools/build-sound-manifest.sh because WoW cannot list a
    --      folder. This is the bulk route: drop files in, run the script.
    --   2. GloomsHubDB.sounds — the Media tab's hand-added entries, which may
    --      be FileDataIDs or paths into anywhere, so they are stored whole.
    local soundCount = 0
    for _, entry in ipairs(GloomsHub.SOUND_MANIFEST or {}) do
        local ok, err = RegisterSound({ name = entry.name, file = SOUND_PATH .. entry.file })
        if ok then
            soundCount = soundCount + 1
        else
            GloomsHub:Print("|cffff4444Sound skipped — " .. entry.name .. ": " .. (err or "unknown") .. "|r")
        end
    end
    for _, entry in ipairs(GloomsHubDB.sounds) do
        local ok, err = RegisterSound(entry)
        if ok then
            soundCount = soundCount + 1
        else
            GloomsHub:Print("|cffff4444Sound skipped — " .. entry.name .. ": " .. (err or "unknown") .. "|r")
        end
    end

    -- Graphics are intentionally NOT registered into LSM.

    local parts = {}
    if fontCount > 0 then
        parts[#parts+1] = fontCount .. " font" .. (fontCount == 1 and "" or "s")
    end
    if texCount > 0 then
        parts[#parts+1] = texCount .. " texture" .. (texCount == 1 and "" or "s")
    end
    if soundCount > 0 then
        parts[#parts+1] = soundCount .. " sound" .. (soundCount == 1 and "" or "s")
    end
    if #parts > 0 then
        GloomsHub:Print("Registered " .. table.concat(parts, " and ") .. " into LibSharedMedia.")
    end
end

-- ============================================================
-- Public API — Asset resolution (CONTRACTS §3)
-- Resolves a display name to a full path. Checks Textures
-- first, then Graphics.
-- ============================================================

function GloomsHub:ResolveAssetPath(name)
    if not name or name == "" then return nil end
    local db = GloomsHubDB
    if not db then return nil end
    for _, entry in ipairs(db.textures or {}) do
        if entry.name == name then
            return TEXTURE_PATH .. entry.file
        end
    end
    for _, entry in ipairs(db.graphics or {}) do
        if entry.name == name then
            return GRAPHIC_PATH .. entry.file
        end
    end
    return nil
end

-- kind "textures"|"graphics" → { {name=, tex=path}, … }
function GloomsHub:ListMedia(kind)
    local out = {}
    local db = GloomsHubDB
    if not db then return out end
    if kind == "textures" then
        for _, entry in ipairs(db.textures or {}) do
            out[#out+1] = { name = entry.name, tex = TEXTURE_PATH .. entry.file }
        end
    elseif kind == "graphics" then
        for _, entry in ipairs(db.graphics or {}) do
            out[#out+1] = { name = entry.name, tex = GRAPHIC_PATH .. entry.file }
        end
    end
    return out
end

-- ============================================================
-- Public API — Fonts
-- ============================================================

function Media:AddFont(displayName, fileName)
    displayName = displayName:match("^%s*(.-)%s*$")
    fileName    = fileName:match("^%s*(.-)%s*$")

    if displayName == "" then return false, "Display name cannot be empty." end
    if fileName    == "" then return false, "Filename cannot be empty." end

    local lower = fileName:lower()
    if not lower:match("%.ttf$") then
        if lower:match("%.otf$") then
            return false, "OTF fonts are not supported by WoW. Please convert to TTF first."
        end
        return false, "Filename must end in .ttf"
    end

    for _, entry in ipairs(GloomsHubDB.fonts) do
        if entry.name:lower() == displayName:lower() then
            return false, "A font named \"" .. displayName .. "\" is already saved."
        end
    end

    local entry = { name = displayName, file = fileName }
    local ok, err = RegisterFont(entry)
    if not ok then
        GloomsHub:Print("|cffff9900Note:|r " .. (err or ""))
    end

    table.insert(GloomsHubDB.fonts, entry)
    return true, "Font \"" .. displayName .. "\" saved. Restart WoW to render it correctly."
end

function Media:RemoveFont(index)
    if GloomsHubDB.fonts[index] then
        local name = GloomsHubDB.fonts[index].name
        table.remove(GloomsHubDB.fonts, index)
        return true, "\"" .. name .. "\" removed. It will disappear from other addons after a full WoW restart."
    end
    return false, "Invalid index."
end

-- ============================================================
-- Public API — Textures
-- ============================================================

function Media:AddTexture(displayName, fileName)
    displayName = displayName:match("^%s*(.-)%s*$")
    fileName    = fileName:match("^%s*(.-)%s*$")

    if displayName == "" then return false, "Display name cannot be empty." end
    if fileName    == "" then return false, "Filename cannot be empty." end

    local lower = fileName:lower()
    if not lower:match("%.blp$") and not lower:match("%.tga$") and not lower:match("%.png$") then
        return false, "Filename must end in .blp, .tga, or .png"
    end

    for _, entry in ipairs(GloomsHubDB.textures) do
        if entry.name:lower() == displayName:lower() then
            return false, "A texture named \"" .. displayName .. "\" is already saved."
        end
    end

    local entry = { name = displayName, file = fileName }
    local ok, err = RegisterTexture(entry)
    if not ok then
        GloomsHub:Print("|cffff9900Note:|r " .. (err or ""))
    end

    table.insert(GloomsHubDB.textures, entry)
    return true, "Texture \"" .. displayName .. "\" saved and registered. A /reload is enough to use it."
end

function Media:RemoveTexture(index)
    if GloomsHubDB.textures[index] then
        local name = GloomsHubDB.textures[index].name
        table.remove(GloomsHubDB.textures, index)
        return true, "\"" .. name .. "\" removed. It will disappear from other addons after a /reload."
    end
    return false, "Invalid index."
end

-- ============================================================
-- Public API — Graphics
-- Not registered into LibSharedMedia. Resolved by name via
-- GloomsHub:ResolveAssetPath (overlays use these).
-- ============================================================

function Media:AddGraphic(displayName, fileName)
    displayName = displayName:match("^%s*(.-)%s*$")
    fileName    = fileName:match("^%s*(.-)%s*$")

    if displayName == "" then return false, "Display name cannot be empty." end
    if fileName    == "" then return false, "Filename cannot be empty." end

    local lower = fileName:lower()
    if not lower:match("%.png$") and not lower:match("%.tga$") then
        return false, "Filename must end in .png or .tga"
    end

    -- Check for name conflicts across both textures and graphics
    for _, entry in ipairs(GloomsHubDB.textures) do
        if entry.name:lower() == displayName:lower() then
            return false, "A texture named \"" .. displayName .. "\" already exists. Use a different name."
        end
    end
    for _, entry in ipairs(GloomsHubDB.graphics) do
        if entry.name:lower() == displayName:lower() then
            return false, "A graphic named \"" .. displayName .. "\" is already saved."
        end
    end

    table.insert(GloomsHubDB.graphics, { name = displayName, file = fileName })
    return true, "Graphic \"" .. displayName .. "\" saved. Use this name in an overlay's texture field."
end

function Media:RemoveGraphic(index)
    if GloomsHubDB.graphics[index] then
        local name = GloomsHubDB.graphics[index].name
        table.remove(GloomsHubDB.graphics, index)
        return true, "\"" .. name .. "\" removed."
    end
    return false, "Invalid index."
end

-- ============================================================
-- Public API — Sounds
--
-- Accepts EITHER a FileDataID (a bare number, the form wago.tools
-- gives you) OR a filename dropped into GloomsHub\Sounds\. Both end
-- up in LibSharedMedia's "sound" table, which is what makes them
-- appear in GA's sound picker (and BigWigs', and everyone else's).
-- ============================================================

-- Normalize whatever the user typed into the value LSM stores, or nil + why.
-- A bare number is a FileDataID and is passed through untouched; anything
-- else is treated as a filename in GloomsHub\Sounds\.
local function CoerceSoundRef(ref)
    ref = tostring(ref or ""):match("^%s*(.-)%s*$")
    if ref == "" then return nil, "Enter a FileDataID or a filename." end

    local id = tonumber(ref)
    if id then
        if id <= 0 or id ~= math.floor(id) then
            return nil, "A FileDataID must be a whole number above zero."
        end
        return id
    end

    local lower = ref:lower()
    if not (lower:match("%.ogg$") or lower:match("%.mp3$")) then
        return nil, "WoW only plays .ogg and .mp3 — or paste a numeric FileDataID."
    end
    -- Already a full Interface\ path? Take it as given; otherwise it's ours.
    if lower:match("^interface\\") then return ref end
    return SOUND_PATH .. ref
end

-- Both play calls hand back a sound HANDLE as their second return; StopSound
-- takes that handle. We keep only the most recent one — auditioning is a
-- one-at-a-time activity, and some of the game's sounds run for many seconds.
local playingHandle

-- Silence whatever Media:Play last started. Safe to call when nothing is
-- playing, and safe to call on a handle whose sound already finished on its
-- own (there is no "sound ended" event, so that is the normal case).
function Media:Stop()
    if not playingHandle then return false end
    pcall(StopSound, playingHandle)
    playingHandle = nil
    return true
end

-- The ONE place that knows FileDataID from SoundKitID. `kind` is "kit" only
-- for rows that came out of the SOUNDKIT browser; everything else is a
-- FileDataID or a path and goes to PlaySoundFile. Returns true if it played.
function Media:Play(ref, kind)
    if not ref then return false end
    self:Stop()   -- a new pick always cuts off the last one
    local ok, played, handle
    if kind == "kit" then
        ok, played, handle = pcall(PlaySound, ref, "Master")
    else
        -- PlaySoundFile returns false (it does not raise) for a dead ID or path.
        ok, played, handle = pcall(PlaySoundFile, ref, "Master")
    end
    if not ok then return false end
    playingHandle = handle
    return played ~= false
end

-- Does this number appear in SOUNDKIT? Used only to write a BETTER error
-- message, never as the gate — the two namespaces overlap numerically, so a
-- legitimate low FileDataID could match a kit by coincidence. The play test
-- below is what actually decides.
local function SoundKitNamed(id)
    for _, item in ipairs(Media:SoundKits()) do
        if item.id == id then return item.name end
    end
end

function Media:AddSound(displayName, ref)
    displayName = (displayName or ""):match("^%s*(.-)%s*$")
    if displayName == "" then return false, "Display name cannot be empty." end

    local value, err = CoerceSoundRef(ref)
    if not value then return false, err end

    for _, entry in ipairs(GloomsHubDB.sounds) do
        if entry.name:lower() == displayName:lower() then
            return false, "A sound named \"" .. displayName .. "\" is already saved."
        end
    end

    -- ★ VERIFY BEFORE SAVING (added 2026-08-24, after a SoundKit ID was pasted
    -- in from the browser below, registered happily, and then played nothing).
    -- PlaySoundFile returns willPlay=false for an ID or path the client cannot
    -- resolve, which is the only existence check available to us — there is no
    -- filesystem API. Saving an unplayable sound is strictly worse than
    -- refusing it: it reaches GA's picker looking perfectly valid and then
    -- fails silently on the aura, which is the hardest kind of bug to trace.
    if not self:Play(value) then
        local kit = type(value) == "number" and SoundKitNamed(value)
        if kit then
            return false, kit .. " is a SoundKit ID from the browser below, not a FileDataID — "
                .. "the two are different numbering systems. Look the sound up on wago.tools "
                .. "and paste the FileDataID it gives you."
        end
        if type(value) == "number" then
            return false, "Nothing plays for FileDataID " .. value .. " — check the number on wago.tools."
        end
        return false, "Nothing plays for that file. Check it is in GloomsHub\\Sounds\\ and is a real .ogg or .mp3."
    end

    local entry = { name = displayName, file = value }
    local ok, rerr = RegisterSound(entry)
    if not ok then
        GloomsHub:Print("|cffff9900Note:|r " .. (rerr or ""))
    end

    table.insert(GloomsHubDB.sounds, entry)
    -- Unlike fonts, a sound is live immediately — nothing is cached at launch.
    -- It is playing right now: the verification above IS the preview.
    return true, "Sound \"" .. displayName .. "\" saved — that is what it sounds like."
end

function Media:RemoveSound(index)
    if GloomsHubDB.sounds[index] then
        local name = GloomsHubDB.sounds[index].name
        table.remove(GloomsHubDB.sounds, index)
        return true, "\"" .. name .. "\" removed. It leaves other addons' lists after a /reload."
    end
    return false, "Invalid index."
end

-- The game's 865 named sound kits, sorted. Built once and cached: SOUNDKIT is
-- a static FrameXML table, so it cannot change during a session.
local soundKitCache
function Media:SoundKits()
    if soundKitCache then return soundKitCache end
    soundKitCache = {}
    if type(SOUNDKIT) == "table" then
        for name, id in pairs(SOUNDKIT) do
            if type(name) == "string" and type(id) == "number" then
                soundKitCache[#soundKitCache + 1] = { name = name, id = id }
            end
        end
        table.sort(soundKitCache, function(a, b) return a.name < b.name end)
    end
    return soundKitCache
end

-- ============================================================
-- The MEDIA windows — ★ THE TWO-WINDOW DESIGN (2026-09-27). Media was never
-- mocked: it is built from the other tools' pages (the owner, 2026-09-27:
-- "there's already a lot of source material"), over the API above. The Hub's
-- Windows.lua owns the windows; this draws:
--   the SELECTOR — the five catalogs as a list with their counts (a click
--     opens that section), the one open violet 30%;
--   the TAB — "gloomMEDIA:" and what the catalog is;
--   six SECTIONS — Fonts · Textures · Graphics · Sounds (each: Display Name
--     | File Name, Add, what the catalog is for, then its entries with a
--     preview and a remove X) · Game Sounds (search, click to hear) · Game
--     Textures (the texture browser, 2026-09-29 — see below).
-- The numbers are the family's: a labelled control is 31 tall, rows 41
-- apart, columns 170 at 0 / 190.
-- ============================================================

local UI, COLOR, FONTS = GloomsHub.UI, GloomsHub.COLOR, GloomsHub.FONT
local LIME, LILAC, VIOLET, CORAL = COLOR.lime, COLOR.lilac, COLOR.violet, COLOR.coral
local DIM = UI.G_DIM or 0.3
local MP = { secs = {} }

local function refreshAll()
    for _, s in ipairs(MP.secs) do if s.refresh then s.refresh() end end
    if MP.renderSelector then MP.renderSelector() end
end

local function note(parent, text, w, size)
    local n = UI.newText(parent, FONTS.sa, size or 10, LILAC, "LEFT")
    n:SetWidth(w or 360); n:SetJustifyH("LEFT"); n:SetWordWrap(true); n:SetText(text or "")
    return n
end
-- A status line: lime for done, coral for a problem, lilac for news.
local function status(fs, msg, ok)
    local c = (ok == nil and LILAC) or (ok and LIME) or CORAL
    fs:SetTextColor(c.r, c.g, c.b); fs:SetText(msg or "")
end

-- ------------------------------------------------------------
-- A CATALOG section (Fonts / Textures / Graphics / Sounds): Display Name |
-- File Name, the Add button and its status, the note, then one row per entry
-- (the name, the file under it in lilac, the preview at 190, the X), 30 apart.
-- ------------------------------------------------------------
local ROW_H = 30
-- ★ A FILE'S PIXEL SIZE (2026-09-30, TESTED in game by the owner: a texture
-- given a file and NO size of its own reports the file's size — darkset-main.png
-- read 3041 652, its true size). WoW has no API for it; this is that trick: one
-- unanchored probe texture per file, polled until the file has loaded (up to 3 s),
-- the answer cached. TextureSize(src, onReady) → w, h now, or nil and onReady(w, h)
-- later. src = a path or a file ID. (The harness can't measure — sizes stay blank.)
-- ★ ONE WAITER PER `key` (2026-09-30: the owner's client locked up for a minute —
-- "insecure scripts exceeded execution limit"). Each answer repainted the grid,
-- each repaint queued ANOTHER callback for every file still loading, and each of
-- those repainted again: doubling without end. Waiters are now keyed (a grid
-- cell, a catalog row, the preview) so asking again only replaces the last ask,
-- and the grid folds its repaints into one per frame. Don't make it a list again.
local sizes, waiting = {}, {}
local function TextureSize(src, onReady, key)
    if not src or src == "" then return nil end
    local known = sizes[src]
    if known then return known[1], known[2] end
    if known == false then return nil end
    local pending = waiting[src]
    if pending then
        if onReady then pending[key or onReady] = onReady end
        return nil
    end
    waiting[src] = {}
    if onReady then waiting[src][key or onReady] = onReady end
    local t = UIParent:CreateTexture(nil, "BACKGROUND")
    t:SetTexture(src)
    local tries = 0
    local function check()
        local w, h = t:GetSize()
        tries = tries + 1
        if w and h and w > 0 and h > 0 then
            sizes[src] = { math.floor(w + 0.5), math.floor(h + 0.5) }
            t:SetTexture(nil)
            local cbs = waiting[src]; waiting[src] = nil
            for _, cb in pairs(cbs or {}) do cb(sizes[src][1], sizes[src][2]) end
        elseif tries < 30 then
            C_Timer.After(0.1, check)
        else
            t:SetTexture(nil); waiting[src] = nil; sizes[src] = false   -- never answered: stop asking
        end
    end
    check()
    local k = sizes[src]
    if k then return k[1], k[2] end
    return nil
end
Media.TextureSize = TextureSize

local function buildCatalog(parent, spec)
    local f = CreateFrame("Frame", nil, parent); f:SetSize(360, 200)
    local s = { frame = f }
    MP.secs[#MP.secs + 1] = s
    local nameL = UI.gLabel(f, "Display Name"); nameL:SetPoint("TOPLEFT", 0, 0)
    local nameBox = UI.gField(f, 170, { placeholder = spec.namePh })
    nameBox:SetPoint("TOPLEFT", 0, -15)
    local fileL = UI.gLabel(f, spec.fileLabel or "File Name"); fileL:SetPoint("TOPLEFT", 190, 0)
    local fileBox = UI.gField(f, 170, { placeholder = spec.filePh })
    fileBox:SetPoint("TOPLEFT", 190, -15)
    UI.attachTip(fileBox, spec.fileLabel or "File name", spec.hint)
    local add = UI.gButton(f, spec.addLabel, { h = 16, pad = 10 })
    add:SetPoint("TOPLEFT", 0, -41)
    local lastBtn = add
    if spec.stop then
        local stop = UI.gButton(f, "Stop", { h = 16, pad = 10, onClick = function() Media:Stop() end })
        stop:SetPoint("LEFT", add, "RIGHT", 6, 0)
        UI.attachTip(stop, "Stop", "Stops the sound that is playing.")
        lastBtn = stop
    end
    local st = UI.newText(f, FONTS.sa, 10, LILAC, "LEFT")
    st:SetPoint("LEFT", lastBtn, "RIGHT", 10, 0); st:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    st:SetWordWrap(false)
    s.status = st
    local nt = note(f, spec.note)
    nt:SetPoint("TOPLEFT", 0, -69)
    local empty = note(f, spec.empty)
    local pool = {}

    local function submit()
        local ok, msg = spec.add(nameBox:GetText() or "", fileBox:GetText() or "")
        status(st, msg, ok)
        if ok then
            nameBox:SetText(""); fileBox:SetText(""); nameBox:ClearFocus(); fileBox:ClearFocus()
            refreshAll()
        end
    end
    add:SetScript("OnClick", submit)
    nameBox:SetScript("OnEnterPressed", function() fileBox:SetFocus() end)
    fileBox:SetScript("OnEnterPressed", submit)

    s.refresh = function()
        local entries = spec.getEntries() or {}
        local y = 69 + math.ceil(nt:GetStringHeight()) + 20
        for i, entry in ipairs(entries) do
            local row = pool[i]
            if not row then
                row = CreateFrame("Frame", nil, f); row:SetSize(360, ROW_H - 4)
                row.name = UI.newText(row, FONTS.sa, 10, COLOR.paper, "LEFT")
                row.name:SetPoint("TOPLEFT", 0, -1); row.name:SetWidth(180); row.name:SetWordWrap(false)
                row.file = UI.newText(row, FONTS.sa, 9, LILAC, "LEFT")
                row.file:SetPoint("TOPLEFT", 0, -14); row.file:SetWidth(180); row.file:SetWordWrap(false)
                row.preview = spec.buildPreview(row)
                row.x = UI.gX(row); row.x:SetPoint("RIGHT", 6, 0)
                pool[i] = row
            end
            row:ClearAllPoints(); row:SetPoint("TOPLEFT", 0, -y); row:Show()
            row.name:SetText(entry.name)
            row.file:SetText(spec.fileText and spec.fileText(entry) or entry.file)
            if spec.path then
                -- the file's pixel size, right of the preview
                if not row.dims then
                    row.dims = UI.newText(row, FONTS.sa, 9, LILAC, "RIGHT"); row.dims:SetPoint("RIGHT", -20, 0)
                end
                row.entry = entry
                row.dims:SetText("")
                local function withSize(w, h)
                    if row.entry == entry then row.dims:SetText(("%d x %d"):format(w, h)) end
                end
                local w, h = TextureSize(spec.path .. entry.file, withSize, row)
                if w then withSize(w, h) end
            end
            if row.preview then row.preview(row, entry) end
            row.x:SetScript("OnClick", function()
                UI.confirm(("Remove \"%s\" from the catalog? The file itself stays where it is."):format(entry.name), function()
                    local ok, msg = spec.remove(i)
                    status(st, msg, ok)
                    refreshAll()
                end, "Remove")
            end)
            UI.attachTip(row.x, "Remove", "Takes this entry out of the catalog. The file stays in its folder. Asks first.")
            y = y + ROW_H
        end
        for i = #entries + 1, #pool do pool[i]:Hide() end
        empty:ClearAllPoints(); empty:SetPoint("TOPLEFT", 0, -y); empty:SetShown(#entries == 0)
        if #entries == 0 then y = y + math.ceil(empty:GetStringHeight()) + 4 else y = y - 4 end
        if math.abs((f:GetHeight() or 0) - y) > 0.5 then f:SetHeight(y) end
    end
    f:HookScript("OnShow", s.refresh)
    s.refresh()
    return f
end

-- ------------------------------------------------------------
-- GAME SOUNDS — the game's own interface sounds by name. Click a line to hear
-- it; type to filter by name or ID. 14 lines of 18; the list scrolls by 3.
-- ★ WHY THERE IS NO "ADD" HERE: SoundKit ids cannot go into LibSharedMedia
-- (see RegisterSound). This lets the owner HEAR the game's sounds; using one
-- in Gloom's Auras still means finding its FileDataID on wago.tools and adding
-- that under Sounds. Do not "fix" this by registering item.id.
-- ------------------------------------------------------------
local BROWSE_ROWS, BROWSE_ROW_H = 14, 18
local function buildBrowser(parent)
    local f = CreateFrame("Frame", nil, parent); f:SetSize(360, 100)
    local s = { frame = f }
    MP.secs[#MP.secs + 1] = s
    UI.gLabel(f, "Search"):SetPoint("TOPLEFT", 0, 0)
    local search = UI.gField(f, 294, { placeholder = "A name or an ID" })
    search:SetPoint("TOPLEFT", 0, -15)
    local stop = UI.gButton(f, "Stop", { w = 60, h = 16, size = 10, onClick = function() Media:Stop() end })
    stop:SetPoint("TOPLEFT", 300, -15)
    UI.attachTip(stop, "Stop", "Stops the sound that is playing. (The game never says when a sound ends, so this is always on.)")
    local counter = UI.newText(f, FONTS.sa, 10, LILAC, "LEFT"); counter:SetPoint("TOPLEFT", 0, -41)
    local st = UI.newText(f, FONTS.sa, 10, LIME, "RIGHT"); st:SetPoint("TOPRIGHT", 0, -41); st:SetWidth(240); st:SetWordWrap(false)
    local nt = note(f, "Every sound the game's interface uses. Click one to hear it. These are SoundKit IDs, which other addons can't read — to use one in Gloom's Auras, look its file up on wago.tools and add that FileDataID under Sounds.")
    nt:SetPoint("TOPLEFT", 0, -61)
    local list = CreateFrame("Frame", nil, f)
    list:SetSize(360, BROWSE_ROWS * BROWSE_ROW_H)
    list:EnableMouseWheel(true)
    local filtered, offset, rows = {}, 0, {}
    local function paint()
        local maxOff = math.max(0, #filtered - BROWSE_ROWS)
        offset = math.max(0, math.min(maxOff, offset))
        for i = 1, BROWSE_ROWS do
            local row, item = rows[i], filtered[i + offset]
            row.item = item
            if item then row.name:SetText(item.name); row.id:SetText(item.id); row:Show() else row:Hide() end
        end
        if #filtered == 0 then counter:SetText("No matches")
        elseif #filtered <= BROWSE_ROWS then counter:SetText(#filtered .. (#filtered == 1 and " sound" or " sounds"))
        else counter:SetText(("%d–%d of %d"):format(offset + 1, math.min(offset + BROWSE_ROWS, #filtered), #filtered)) end
    end
    for i = 1, BROWSE_ROWS do
        local row = CreateFrame("Button", nil, list); row:SetSize(360, BROWSE_ROW_H)
        row:SetPoint("TOPLEFT", 0, -(i - 1) * BROWSE_ROW_H)
        local hl = row:CreateTexture(nil, "BACKGROUND"); hl:SetPoint("TOPLEFT", -20, 0); hl:SetPoint("BOTTOMRIGHT", 20, 0)
        hl:SetColorTexture(VIOLET.r, VIOLET.g, VIOLET.b, 0.15); hl:Hide()
        row:SetScript("OnEnter", function() hl:Show() end)
        row:SetScript("OnLeave", function() hl:Hide() end)
        row.name = UI.newText(row, FONTS.sa, 10, COLOR.paper, "LEFT"); row.name:SetPoint("LEFT", 0, 0)
        row.name:SetWidth(300); row.name:SetWordWrap(false)
        row.id = UI.newText(row, FONTS.sa, 9, LILAC, "RIGHT"); row.id:SetPoint("RIGHT", 0, 0)
        row:SetScript("OnClick", function(self)
            if not self.item then return end
            Media:Play(self.item.id, "kit")   -- "kit": the ONLY caller that passes it. See Media:Play.
            status(st, self.item.name .. "  ·  SoundKit " .. self.item.id, true)
        end)
        rows[i] = row
    end
    list:SetScript("OnMouseWheel", function(_, delta) offset = offset - delta * 3; paint() end)
    local function applyFilter()
        local q = (search:GetText() or ""):lower():match("^%s*(.-)%s*$")
        wipe(filtered)
        for _, item in ipairs(Media:SoundKits()) do
            if q == "" or item.name:lower():find(q, 1, true) or tostring(item.id):find(q, 1, true) then
                filtered[#filtered + 1] = item
            end
        end
        offset = 0
        paint()
    end
    search:HookScript("OnTextChanged", applyFilter)
    search:SetScript("OnEscapePressed", function(self) self:SetText(""); self:ClearFocus() end)
    s.refresh = function()
        local top = 61 + math.ceil(nt:GetStringHeight()) + 14
        list:ClearAllPoints(); list:SetPoint("TOPLEFT", 0, -top)
        local h = top + BROWSE_ROWS * BROWSE_ROW_H
        if math.abs((f:GetHeight() or 0) - h) > 0.5 then f:SetHeight(h) end
    end
    applyFilter()
    s.refresh()
    return f
end

-- ------------------------------------------------------------
-- ★ THE TEXTURE BROWSER (2026-09-29, the owner: "I'd VERY MUCH expect to see
-- it in the gloomMEDIA module"). Moved here from Gloom's Overlays' asset
-- browser (the first design's drawer, which could dock off the screen and not
-- be dragged back — the owner, the same day). One builder, two homes:
--   · Media's GAME TEXTURES section — look a texture up, play it, keep favorites;
--   · the TEXTURE BROWSER window, GloomsHub:PickTexture(opts), which any tool's
--     texture field opens beside its settings window: its buttons hand the
--     texture (and its spritesheet grid) back to that field.
-- A texture is a Suite media name, an atlas, a file ID or an Interface\ path;
-- more than one column or row plays it as a spritesheet (GloomsHub:SheetFor).
-- Favorites live in GloomsHubDB.textureFavorites — COPIED once from
-- Overlays' VibeOverlayDB.favorites (never moved; the old list stays as it was).
-- ------------------------------------------------------------

-- A spritesheet for a texture: { fileID, cols, rows, frames, fps, uLeft,
-- uRight, vTop, vBottom } — what Gloom's Overlays plays — or nil for a still
-- texture (a 1 x 1 grid). `fileID` is whatever SetTexture takes: the media
-- path, the file ID, an atlas's file (its cut as the u / v bounds) or the path.
-- `dir` (2026-10-06, the owner): nil / "fwd" = forward, "rev" = backward,
-- "pong" = forward then back, EASED at each end (GloomsHub:SheetFrame).
function GloomsHub:SheetFor(texture, cols, rows, frames, fps, dir)
    cols, rows = math.max(1, math.floor(cols or 1)), math.max(1, math.floor(rows or 1))
    if cols * rows <= 1 then return nil end
    local t = (texture or ""):match("^%s*(.-)%s*$")
    local sh = { cols = cols, rows = rows, fps = math.max(1, math.floor(fps or 15)),
        dir = (dir == "rev" or dir == "pong") and dir or nil,
        frames = math.max(1, math.min(cols * rows, math.floor(frames or cols * rows))),
        uLeft = 0, uRight = 1, vTop = 0, vBottom = 1 }
    local path = GloomsHub:ResolveAssetPath(t)
    local info = (not path) and t ~= "" and C_Texture and C_Texture.GetAtlasInfo(t)
    if path then sh.fileID = path
    elseif tonumber(t) then sh.fileID = tonumber(t)
    elseif info then
        sh.fileID = info.file
        sh.uLeft, sh.uRight, sh.vTop, sh.vBottom = info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord
    elseif t ~= "" then sh.fileID = t end
    return sh
end

-- ★ WHICH FRAME a flipbook shows `t` seconds after it started (0-based) — the ONE
-- timing every player uses (Auras, Gloom's UI, the browser's preview), so they
-- all play alike. Forward and Reverse step at `fps`. PING-PONG (2026-10-06, the
-- owner: "hard ping pongs always look jarring") runs a cosine over the frames —
-- slow out of each end, fastest in the middle — at the same average speed. The
-- game can't draw between frames, so easing HOLDS the end frames longer; with
-- few frames it reads as a pause at each end.
function GloomsHub:SheetFrame(sh, t)
    local total = math.max(1, math.min(sh.frames or (sh.cols or 1) * (sh.rows or 1), (sh.cols or 1) * (sh.rows or 1)))
    if total <= 1 then return 0 end
    local fps = math.max(1, sh.fps or 15)
    if sh.dir == "pong" then
        local span = total - 1
        local period = 2 * span / fps
        local ph = (t % period) / period
        local pos = (1 - math.cos(2 * math.pi * ph)) / 2 * span
        return math.floor(pos + 0.5)
    end
    local i = math.floor(t * fps) % total
    if sh.dir == "rev" then return total - 1 - i end
    return i
end

-- The pixel size of ANY texture the suite takes — a Suite media name, an atlas,
-- a file ID or a path: w, h now, or nil and onReady(w, h) once the game has
-- loaded the file (TextureSize above). An atlas answers at once. (Gloom's UI
-- starts a new overlay at its image's size with this — the owner, 2026-09-30.)
function GloomsHub:TextureSize(texture, onReady)
    local t = type(texture) == "string" and texture:match("^%s*(.-)%s*$") or texture
    if not t or t == "" then return nil end
    local path = type(t) == "string" and GloomsHub:ResolveAssetPath(t)
    if path then return TextureSize(path, onReady) end
    local info = type(t) == "string" and not tonumber(t) and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(t)
    if info and (info.width or 0) > 0 then return info.width, info.height end
    return TextureSize(tonumber(t) or t, onReady)
end

local function TextureFavorites()
    if not GloomsHubDB then return {} end
    if not GloomsHubDB.textureFavorites then
        GloomsHubDB.textureFavorites = {}
        local old = type(VibeOverlayDB) == "table" and VibeOverlayDB.favorites
        if type(old) == "table" then
            for _, fav in ipairs(old) do
                local name = fav.texture or fav.name
                if name then
                    table.insert(GloomsHubDB.textureFavorites, { name = name, cols = fav.cols or 1, rows = fav.rows or 1,
                        fps = fav.fps or 15, frames = fav.frames })
                end
            end
        end
    end
    return GloomsHubDB.textureFavorites
end

-- The browser, 360 wide: Texture + Load · the preview · its status · Columns |
-- Rows · Frames | Speed · Play, Stop, Add to Favorites · the host's buttons
-- (two to a row) · Favorites (8 lines, the wheel scrolls; click one to load it,
-- its X removes it). Returns the frame; frame.api = { load(text, sheet),
-- setActions({ { label, fn(text, sheet), tip } … }), refresh() }.
-- ★ A LIST'S SCROLLBAR CAN BE GRABBED (2026-09-30, the owner: "I can't click it
-- and drag it down to move quickly"). The bar stays 3 wide; an invisible strip 6
-- either side takes the mouse. Press on the thumb and drag; press elsewhere on the
-- bar and the thumb jumps there (centred) and keeps following until release.
-- getOff() / getMax() / setOff(o) are the list's own row offset.
local function DragBar(track, thumb, getOff, getMax, setOff)
    local hit = CreateFrame("Frame", nil, track)
    hit:SetPoint("TOPLEFT", -6, 0); hit:SetPoint("BOTTOMRIGHT", 6, 0); hit:EnableMouse(true)
    local grab = 0
    local function follow()
        local _, cy = GetCursorPosition(); cy = cy / track:GetEffectiveScale()
        local top, view, thH, maxOff = track:GetTop(), track:GetHeight() or 0, thumb:GetHeight() or 0, getMax()
        if not top or maxOff <= 0 then return end
        local frac = (top - cy - grab) / math.max(1, view - thH)
        local o = math.floor(math.max(0, math.min(1, frac)) * maxOff + 0.5)
        if o ~= getOff() then setOff(o) end
    end
    hit:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        local _, cy = GetCursorPosition(); cy = cy / track:GetEffectiveScale()
        local tTop, tBot = thumb:GetTop(), thumb:GetBottom()
        grab = (tTop and tBot and cy <= tTop and cy >= tBot) and (tTop - cy) or (thumb:GetHeight() or 0) / 2
        follow()
        self:SetScript("OnUpdate", function(me)
            if not IsMouseButtonDown("LeftButton") then me:SetScript("OnUpdate", nil); return end
            follow()
        end)
    end)
    hit:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
    hit:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)
    return hit
end

local TB_PREVIEW_H, TB_FAV_ROWS = 180, 6   -- 6 (was 8): the Direction row took two (2026-10-06)
local function buildTextureBrowser(parent)
    local f = CreateFrame("Frame", nil, parent); f:SetSize(360, 500)
    local st = { text = "", cols = 1, rows = 1, frames = 1, fps = 15, playing = false }
    local api = {}
    f.api = api
    UI.gLabel(f, "Texture"):SetPoint("TOPLEFT", 0, 0)
    local field = UI.gField(f, 294, { placeholder = "A media name, atlas, file ID or path",
        commit = function(text) if (text or "") ~= st.text then api.load(text) end end,
        revert = function(self) self:SetText(st.text or "") end })
    field:SetPoint("TOPLEFT", 0, -15)
    UI.attachTip(field, "Texture", "A Suite media name (the Media catalog), an atlas name, a file ID, or an Interface\\ path. Enter or clicking away loads it.")
    local loadB = UI.gButton(f, "Load", { w = 60, h = 16, size = 10, onClick = function() api.load(field:GetText()) end })
    loadB:SetPoint("TOPLEFT", 300, -15)
    -- the preview
    local box = CreateFrame("Frame", nil, f); box:SetSize(360, TB_PREVIEW_H); box:SetPoint("TOPLEFT", 0, -41)
    local bg = box:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetColorTexture(VIOLET.r, VIOLET.g, VIOLET.b, 0.08)
    local pv = box:CreateTexture(nil, "ARTWORK"); pv:SetPoint("CENTER")
    local stLine = UI.newText(f, FONTS.sa, 10, LILAC, "LEFT")
    stLine:SetPoint("TOPLEFT", 0, -(41 + TB_PREVIEW_H + 6)); stLine:SetWidth(360); stLine:SetWordWrap(false)
    local y0 = 41 + TB_PREVIEW_H + 26
    local base = { u0 = 0, u1 = 1, v0 = 0, v1 = 1 }   -- the texture's own cut (an atlas's) before the grid
    local function frameCoords(i)
        local cw, rh = (base.u1 - base.u0) / st.cols, (base.v1 - base.v0) / st.rows
        local col, row = i % st.cols, math.floor(i / st.cols)
        return base.u0 + col * cw, base.u0 + (col + 1) * cw, base.v0 + row * rh, base.v0 + (row + 1) * rh
    end
    -- ★ STOPPED = THE WHOLE SHEET (2026-09-30, the owner: stopping "just stops on
    -- what it thinks is one frame, rather than showing the entire asset"). Not
    -- playing, the preview shows the whole texture with the grid's cuts drawn
    -- over it, so Columns / Rows can be matched to the art by eye; Play shows one
    -- cell at a time. Changing the grid stops it, back to the lines.
    local natW, natH = 1, 1
    local lines = {}
    local function drawLines()
        local n = 0
        if not st.playing and st.cols * st.rows > 1 then
            local w, h = pv:GetWidth() or 0, pv:GetHeight() or 0
            local function line(x1, y1, x2, y2)
                n = n + 1
                local l = lines[n]
                if not l then l = box:CreateTexture(nil, "OVERLAY"); lines[n] = l end
                l:SetColorTexture(LIME.r, LIME.g, LIME.b, 0.7)
                l:ClearAllPoints(); l:SetPoint("TOPLEFT", pv, "TOPLEFT", x1, -y1)
                l:SetSize(math.max(1, x2 - x1), math.max(1, y2 - y1)); l:Show()
            end
            for c = 1, st.cols - 1 do local x = math.floor(w * c / st.cols + 0.5); line(x, 0, x + 1, h) end
            for r = 1, st.rows - 1 do local y = math.floor(h * r / st.rows + 0.5); line(0, y, w, y + 1) end
        end
        for i = n + 1, #lines do lines[i]:Hide() end
    end
    -- the preview's size: the whole file (stopped) or one cell (playing), fitted into the box
    local function fit()
        local w, h = natW, natH
        if st.playing then w, h = natW / st.cols, natH / st.rows end
        local k = math.min((360 - 20) / math.max(1, w), (TB_PREVIEW_H - 20) / math.max(1, h), 4)
        pv:SetSize(math.max(1, w * k), math.max(1, h * k))
        drawLines()
    end
    local function stop()
        st.playing = false
        box:SetScript("OnUpdate", nil)
        pv:SetTexCoord(base.u0, base.u1, base.v0, base.v1)
        fit()
    end
    local function play()
        if st.cols * st.rows <= 1 then return end
        st.playing = true
        local sh = { cols = st.cols, rows = st.rows, frames = st.frames, fps = st.fps, dir = st.dir }
        local t, shown = 0, GloomsHub:SheetFrame(sh, 0)
        fit()
        pv:SetTexCoord(frameCoords(shown))
        box:SetScript("OnUpdate", function(_, dt)
            t = t + dt
            local i = GloomsHub:SheetFrame(sh, t)
            if i ~= shown then shown = i; pv:SetTexCoord(frameCoords(i)) end
        end)
    end
    local function regrid(key)
        -- a new grid: back to the whole sheet and its lines; Frames / Speed keep playing
        if (key == "cols" or key == "rows") or not st.playing then stop()
        else stop(); play() end
    end
    -- ★ A GRID SET BY HAND IS REMEMBERED (2026-09-30, the owner) — by the
    -- texture's name, in GloomsHubDB.textureGrids, so loading it again (from any
    -- tool, any source) starts on that grid, playing. Set back to 1 x 1 = forgotten.
    -- A grid handed in by the caller (an overlay's own, a favorite's) wins.
    local function remember()
        if not GloomsHubDB or (st.text or "") == "" then return end
        GloomsHubDB.textureGrids = GloomsHubDB.textureGrids or {}
        if st.cols * st.rows > 1 then
            GloomsHubDB.textureGrids[st.text] = { cols = st.cols, rows = st.rows, frames = st.frames, fps = st.fps, dir = st.dir }
        else
            GloomsHubDB.textureGrids[st.text] = nil
        end
    end
    local function dial(label, key, min, max, x, y, onSet, tip)
        local d = UI.gDial(f, { w = 170, label = label, min = min, max = max, step = 1, dragPx = 400,
            get = function() return st[key] end,
            set = function(v) st[key] = v; if onSet then onSet() end; regrid(key); remember(); api.refresh() end })
        d:SetPoint("TOPLEFT", x, -y)
        if tip then UI.attachTip(d.strip, label, tip) end
        return d
    end
    local dCols = dial("Columns", "cols", 1, 64, 0, y0, function() st.frames = st.cols * st.rows end,
        "How many frames across. More than one column or row plays the texture as an animation — left to right, then row by row. 1 x 1 = a still texture. The game never says how a flipbook is cut: set Columns and Rows until the green lines fall between the frames, then Play.")
    local dRows = dial("Rows", "rows", 1, 64, 190, y0, function() st.frames = st.cols * st.rows end)
    local dFrames = dial("Frames", "frames", 1, 4096, 0, y0 + 41, nil, "How many cells to play — fewer than Columns x Rows when the last row isn't full.")
    local dFps = dial("Speed (frames per second)", "fps", 1, 60, 190, y0 + 41)
    -- DIRECTION (2026-10-06): Forward | Reverse | Ping-Pong (eased at each end)
    local dirL = UI.gLabel(f, "Direction"); dirL:SetPoint("TOPLEFT", 0, -(y0 + 82))
    local dDir = UI.gSwitch(f, { { "fwd", "Forward" }, { "rev", "Reverse" }, { "pong", "Ping-Pong" } },
        function() return st.dir or "fwd" end,
        function(v) st.dir = (v ~= "fwd") and v or nil; regrid("dir"); remember(); api.refresh() end, { w = 360 })
    dDir:SetPoint("TOPLEFT", 0, -(y0 + 97))
    UI.attachTip(dDir, "Direction", "Forward plays the frames in order; Reverse plays them backward; Ping-Pong plays forward, then back — slowing into each end and easing out of it, so the turn isn't a jolt.")
    local bY = y0 + 123
    local playB = UI.gButton(f, "Play", { w = 60, h = 16, size = 10, onClick = function() play(); api.refresh() end })
    playB:SetPoint("TOPLEFT", 0, -bY)
    local stopB = UI.gButton(f, "Stop", { w = 60, h = 16, size = 10, onClick = function() stop(); api.refresh() end })
    stopB:SetPoint("TOPLEFT", 66, -bY)
    local favB = UI.gButton(f, "Add to Favorites", { h = 16, size = 10, pad = 10 })
    favB:SetPoint("TOPRIGHT", 0, -bY)
    local function say(msg, ok) status(stLine, msg, ok) end
    favB:SetScript("OnClick", function()
        if (st.text or "") == "" then say("Load a texture first.", false); return end
        local favs = TextureFavorites()
        for _, fav in ipairs(favs) do
            if fav.name == st.text and fav.cols == st.cols and fav.rows == st.rows and (fav.frames or fav.cols * fav.rows) == st.frames then
                say("Already a favorite with these settings."); return
            end
        end
        table.insert(favs, { name = st.text, cols = st.cols, rows = st.rows, fps = st.fps, frames = st.frames, dir = st.dir })
        say("Added to favorites.", true)
        api.refresh()
        if MP.renderSelector then MP.renderSelector() end
    end)
    -- the host's buttons
    local actBtns, actions = {}, {}
    local aY = bY + 30
    function api.setActions(list)
        actions = list or {}
        for i, a in ipairs(actions) do
            local b = actBtns[i]
            if not b then b = UI.gButton(f, "", { w = 170, h = 16, size = 10 }); actBtns[i] = b end
            b.text:SetText(a.label)
            b:ClearAllPoints(); b:SetPoint("TOPLEFT", ((i - 1) % 2) * 190, -(aY + math.floor((i - 1) / 2) * 24))
            b:SetScript("OnClick", function()
                if (st.text or "") == "" then say("Load a texture first.", false); return end
                a.fn(st.text, GloomsHub:SheetFor(st.text, st.cols, st.rows, st.frames, st.fps, st.dir))
            end)
            b:Show()
            if a.tip then UI.attachTip(b, a.label, a.tip) end
        end
        for i = #actions + 1, #actBtns do actBtns[i]:Hide() end
        api.refresh()
    end
    -- favorites
    local favHead = UI.gLabel(f, "Favorites")
    local favEmpty = note(f, "No favorites yet — load a texture and click Add to Favorites.")
    local favList = CreateFrame("Frame", nil, f); favList:SetSize(360, TB_FAV_ROWS * 18)
    favList:EnableMouseWheel(true)
    local favRows, favOff = {}, 0
    for i = 1, TB_FAV_ROWS do
        local r = CreateFrame("Button", nil, favList); r:SetSize(360, 18); r:SetPoint("TOPLEFT", 0, -(i - 1) * 18)
        local hl = r:CreateTexture(nil, "BACKGROUND"); hl:SetPoint("TOPLEFT", -4, 0); hl:SetPoint("BOTTOMRIGHT", 4, 0)
        hl:SetColorTexture(VIOLET.r, VIOLET.g, VIOLET.b, 0.15); hl:Hide()
        r:SetScript("OnEnter", function() hl:Show() end)
        r:SetScript("OnLeave", function() hl:Hide() end)
        r.name = UI.newText(r, FONTS.sa, 10, COLOR.paper, "LEFT"); r.name:SetPoint("LEFT", 0, 0); r.name:SetWidth(210); r.name:SetWordWrap(false)
        r.meta = UI.newText(r, FONTS.sa, 9, LILAC, "RIGHT"); r.meta:SetPoint("RIGHT", -20, 0)
        r.x = UI.gX(r); r.x:SetPoint("RIGHT", 4, 0)
        r:SetScript("OnClick", function(self)
            local fav = self.fav; if not fav then return end
            api.load(fav.name, { cols = fav.cols or 1, rows = fav.rows or 1, frames = fav.frames, fps = fav.fps or 15, dir = fav.dir })
        end)
        r.x:SetScript("OnClick", function()
            local favs = TextureFavorites()
            for k, fav in ipairs(favs) do if fav == r.fav then table.remove(favs, k); break end end
            api.refresh()
            if MP.renderSelector then MP.renderSelector() end
        end)
        UI.attachTip(r.x, "Remove", "Takes this texture off your favorites.")
        favRows[i] = r
    end
    favList:SetScript("OnMouseWheel", function(_, d) favOff = favOff - d * 2; api.refresh() end)
    -- the scrollbar, in the margin right of the list, only while it overflows
    -- (the gloomUI / Auras lists' bar: 3 wide, black 50%, a violet 50% thumb)
    local track = CreateFrame("Frame", nil, favList); track:SetWidth(3)
    track:SetPoint("TOPLEFT", favList, "TOPLEFT", 370.5, 0); track:SetPoint("BOTTOMLEFT", favList, "BOTTOMLEFT", 370.5, 0)
    local tt = track:CreateTexture(nil, "BACKGROUND"); tt:SetAllPoints(); tt:SetColorTexture(0, 0, 0, 0.5)
    local thumb = CreateFrame("Frame", nil, track); thumb:SetWidth(3)
    local th = thumb:CreateTexture(nil, "ARTWORK"); th:SetAllPoints(); th:SetColorTexture(VIOLET.r, VIOLET.g, VIOLET.b, 0.5)
    track:Hide()
    DragBar(track, thumb, function() return favOff end,
        function() return math.max(0, #TextureFavorites() - TB_FAV_ROWS) end,
        function(o) favOff = o; api.refresh() end)

    function api.load(text, sheet)
        text = (text or ""):match("^%s*(.-)%s*$")
        st.text = text
        field:SetText(text)
        stop()
        base.u0, base.u1, base.v0, base.v1 = 0, 1, 0, 1
        natW, natH = 256, 256
        pv:SetTexCoord(0, 1, 0, 1)
        st.cols, st.rows, st.frames, st.fps, st.dir = 1, 1, 1, st.fps or 15, nil
        if text == "" then pv:SetTexture(nil); say("Enter a Suite media name, an atlas, a file ID or an Interface\\ path."); api.refresh(); return end
        local path = GloomsHub:ResolveAssetPath(text)
        local info = (not path) and C_Texture and C_Texture.GetAtlasInfo(text)
        -- a file's real size, when the game has it (the whole-sheet view and its
        -- grid lines need the true shape; 256 x 256 until then)
        local function sized(src, msg)
            local function apply(w, h)
                if st.text ~= text then return end
                natW, natH = w, h
                say(("%s — %d x %d"):format(msg, w, h), true)
                if st.playing then fit() else stop() end
            end
            local w, h = TextureSize(src, apply, f)
            if w then apply(w, h) end
        end
        if path then
            pv:SetTexture(path); say(("Suite media \"%s\"."):format(text), true)
            sized(path, ("Suite media \"%s\""):format(text))
        elseif tonumber(text) then
            pv:SetTexture(tonumber(text)); say(("File ID %s."):format(text), true)
            sized(tonumber(text), ("File ID %s"):format(text))
        elseif info then
            pv:SetTexture(info.file)
            base.u0, base.u1, base.v0, base.v1 = info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord
            natW, natH = info.width or 256, info.height or 256
            -- ★ NO GRID GUESS (2026-09-30). This used to take 1 / the atlas's share
            -- of its FILE as Columns x Rows — which is how big the atlas is, not
            -- how many frames it has: every still atlas played, and no flipbook
            -- came out right. The game doesn't expose a flipbook's cut, so it
            -- loads as a still and the owner sets the grid against the lines.
            local isFlip = text:lower():find("flipbook", 1, true) or text:lower():find("-flip", 1, true)
            say(("Atlas \"%s\" — %d x %d%s"):format(text, natW, natH,
                isFlip and " · a flipbook: set its grid" or ""), true)
        else
            pv:SetTexture(text); say(("\"%s\" isn't a media name or an atlas — shown as a path."):format(text))
            sized(text, ("Path \"%s\""):format(text))
        end
        local mine = GloomsHubDB and GloomsHubDB.textureGrids and GloomsHubDB.textureGrids[text]
        if not (sheet and (sheet.cols or 1) * (sheet.rows or 1) > 1) and mine then
            sheet = mine
            stLine:SetText(stLine:GetText() .. "  · your grid")
        end
        if sheet then
            st.cols, st.rows = sheet.cols or 1, sheet.rows or 1
            st.frames = sheet.frames or st.cols * st.rows
            st.fps = sheet.fps or 15
            st.dir = sheet.dir
        end
        stop()
        if sheet and st.cols * st.rows > 1 then play() end
        api.refresh()
    end

    function api.refresh()
        for _, d in ipairs({ dCols, dRows, dFrames, dFps, dDir }) do d:refresh() end
        local anim = st.cols * st.rows > 1
        dFrames:setEnabled(anim); dFps:setEnabled(anim); dDir:setEnabled(anim); dirL:SetAlpha(anim and 1 or UI.G_DIM)
        playB:SetEnabled(anim and not st.playing); stopB:SetEnabled(st.playing)
        local rowsN = math.ceil(#actions / 2)
        local fy = (#actions > 0) and (aY + rowsN * 24 + 10) or (bY + 36)
        favHead:ClearAllPoints(); favHead:SetPoint("TOPLEFT", 0, -fy)
        local favs = TextureFavorites()
        local maxOff = math.max(0, #favs - TB_FAV_ROWS)
        favOff = math.max(0, math.min(maxOff, favOff))
        favList:ClearAllPoints(); favList:SetPoint("TOPLEFT", 0, -(fy + 18))
        favEmpty:ClearAllPoints(); favEmpty:SetPoint("TOPLEFT", 0, -(fy + 18)); favEmpty:SetShown(#favs == 0)
        for i = 1, TB_FAV_ROWS do
            local r, fav = favRows[i], favs[i + favOff]
            r.fav = fav
            if fav then
                r.name:SetText(fav.name)
                local total = (fav.cols or 1) * (fav.rows or 1)
                r.meta:SetText(total > 1 and ("%d x %d · %d fps"):format(fav.cols, fav.rows, fav.fps or 15) or "still")
                r:Show()
            else r:Hide() end
        end
        if maxOff > 0 then
            local view = TB_FAV_ROWS * 18
            local thH = math.max(18, math.floor(view * TB_FAV_ROWS / #favs + 0.5))
            thumb:SetHeight(thH)
            thumb:ClearAllPoints(); thumb:SetPoint("TOP", track, "TOP", 0, -math.floor((view - thH) * (favOff / maxOff) + 0.5))
            track:Show()
        else
            track:Hide()
        end
        local h = fy + 18 + ((#favs > 0) and (math.min(#favs, TB_FAV_ROWS) * 18) or math.ceil(favEmpty:GetStringHeight()))
        if math.abs((f:GetHeight() or 0) - h) > 0.5 then f:SetHeight(h) end
    end
    f:HookScript("OnHide", function() stop() end)
    api.load("")
    return f
end

-- ------------------------------------------------------------
-- ★ THE ART LIST (2026-09-30, the owner: "Browse Assets suggests I'd be able to
-- browse all assets … I'm actually NOT able to browse much of anything"). The
-- loader above can only show what you already know the name of; this is what
-- you FIND it with. Three sources, one grid of thumbnails, one search:
--   · Game Art — every atlas in the client, from C_Texture.GetAtlasElements()
--     (the same call Texture Atlas Viewer builds its list from — TAV itself is
--     NOT needed; it only adds a file-name table to group atlases by sheet,
--     which the owner may still want if the flat list proves too big);
--   · My Media — the Textures and Graphics catalogs. Only what was ADDED there:
--     WoW cannot list a folder, so a file merely dropped in is invisible;
--   · Favorites — the browser's favorites, with their spritesheet grids.
-- Search: every word must appear in the name (so "fire flip" finds
-- "…fire…flipbook"). Flipbooks Only keeps names with "flipbook" / "-flip".
-- Loose game FILES that are not atlases can't be listed by anyone — those
-- still go in by file ID in the loader's field.
-- 360 wide: the source switch · Search · Flipbooks Only and the count · 5 x 5
-- thumbnails at a pitch of 72 (the wheel scrolls a row) · the hovered name.
-- onPick(name, sheet) hands a click to the loader.
-- ------------------------------------------------------------
local AL_COLS, AL_ROWS, AL_PITCH, AL_CELL = 5, 5, 72, 64
local AL_GRID_Y = 93
local AL_H = AL_GRID_Y + AL_ROWS * AL_PITCH - 8 + 24
local gameArt   -- { {name, low}, … } sorted — built once, on first use
local function GameArt()
    if gameArt then return gameArt end
    local out = {}
    local names = C_Texture and C_Texture.GetAtlasElements and C_Texture.GetAtlasElements()
    if type(names) == "table" then
        for i, n in ipairs(names) do out[i] = { name = n, low = n:lower() } end
        table.sort(out, function(a, b) return a.low < b.low end)
    end
    if #out > 0 then gameArt = out end   -- an empty answer is asked again next time
    return out
end
local function MyArt()
    local out = {}
    for _, kind in ipairs({ "textures", "graphics" }) do
        for _, e in ipairs(GloomsHub:ListMedia(kind)) do
            out[#out + 1] = { name = e.name, low = e.name:lower(), tex = e.tex,
                meta = (kind == "textures") and "Texture" or "Graphic" }
        end
    end
    table.sort(out, function(a, b) return a.low < b.low end)
    return out
end
local function FavArt()
    local out = {}
    for _, fav in ipairs(TextureFavorites()) do
        local total = (fav.cols or 1) * (fav.rows or 1)
        out[#out + 1] = { name = fav.name, low = fav.name:lower(),
            sheet = { cols = fav.cols or 1, rows = fav.rows or 1, frames = fav.frames, fps = fav.fps or 15, dir = fav.dir },
            meta = total > 1 and ("%d x %d · %d fps"):format(fav.cols, fav.rows, fav.fps or 15) or "still" }
    end
    return out
end
local function IsFlipbook(low) return low:find("flipbook", 1, true) or low:find("-flip", 1, true) end

-- ★ SHEETS (2026-09-30, the owner, comparing with Texture Atlas Viewer: TAV lists
-- the image FILES and shows each whole, with its pieces on it; Game Art lists
-- the pieces). Built from the game's own grouping — every atlas's info.file is
-- the file it's cut from — so no TAV. One item per file: the whole image, its
-- pieces (the Game Art items), its size worked out from any piece (piece width
-- / its share of the file), and a NAME: the game won't give a file's name, so
-- it's what the pieces' names have in common ("RecruitAFriend"), else the first
-- piece's name. Search matches a sheet when ANY of its pieces would (`low` is
-- all their names), so a piece not named after its sheet still finds it.
local sheetArt
local function SheetArt()
    if sheetArt then return sheetArt end
    local byFile, out = {}, {}
    for _, item in ipairs(GameArt()) do
        local info = C_Texture.GetAtlasInfo(item.name)
        if info and info.file then
            local sh = byFile[info.file]
            if not sh then
                sh = { sheetFile = info.file, pieces = {} }
                byFile[info.file] = sh; out[#out + 1] = sh
            end
            sh.pieces[#sh.pieces + 1] = item
            local du, dv = (info.rightTexCoord or 1) - (info.leftTexCoord or 0), (info.bottomTexCoord or 1) - (info.topTexCoord or 0)
            if not sh.w and du > 0 and dv > 0 and (info.width or 0) > 0 then
                sh.w, sh.h = math.floor(info.width / du + 0.5), math.floor(info.height / dv + 0.5)
            end
        end
    end
    for _, sh in ipairs(out) do
        local first = sh.pieces[1].name
        local pre = first:lower()
        for i = 2, #sh.pieces do
            local o, n = sh.pieces[i].low, 0
            while n < #pre and n < #o and pre:byte(n + 1) == o:byte(n + 1) do n = n + 1 end
            pre = pre:sub(1, n)
            if n == 0 then break end
        end
        local name = first:sub(1, #pre):gsub("[%-_%s]+$", "")
        sh.name = (#sh.pieces > 1 and #name >= 4) and name or first
        local lows = {}
        for i, pc in ipairs(sh.pieces) do lows[i] = pc.low end
        sh.low = table.concat(lows, " ")
        sh.key = "sheet:" .. tostring(sh.sheetFile)
        sh.meta = #sh.pieces == 1 and "1 piece" or (#sh.pieces .. " pieces")
        sh.badge = sh.meta
    end
    table.sort(out, function(a, b) return a.name:lower() < b.name:lower() end)
    if #out > 0 then sheetArt = out end
    return out
end

-- Draw `item` into a thumbnail texture, fitted into AL_CELL - 4 keeping its shape.
local function PaintThumb(t, item, onSized, key)
    local box = AL_CELL - 4
    local w, h = box, box
    local info = (not item.tex) and (not item.sheetFile) and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(item.name)
    if item.sheetFile then
        -- a whole sheet: its file, uncut
        t:SetTexture(item.sheetFile); t:SetTexCoord(0, 1, 0, 1)
        if item.w then
            local k = math.min(box / item.w, box / item.h)
            w, h = math.max(1, item.w * k), math.max(1, item.h * k)
            info = { width = item.w, height = item.h }
        end
    elseif item.tex then
        t:SetTexture(item.tex); t:SetTexCoord(0, 1, 0, 1)
        local iw, ih = TextureSize(item.tex, onSized, key)
        if iw then
            local k = math.min(box / iw, box / ih)
            w, h = math.max(1, iw * k), math.max(1, ih * k)
            info = { width = iw, height = ih }
        end
    elseif info then
        t:SetTexture(nil); t:SetAtlas(item.name, false)   -- (the name is known good: `info`)
        local iw, ih = info.width or box, info.height or box
        if iw > 0 and ih > 0 then
            local k = math.min(box / iw, box / ih)
            w, h = math.max(1, iw * k), math.max(1, ih * k)
        end
    else
        local path = GloomsHub:ResolveAssetPath(item.name)
        t:SetTexture(path or tonumber(item.name) or item.name); t:SetTexCoord(0, 1, 0, 1)
    end
    t:SetSize(w, h)
    return info
end

local function buildArtList(parent, onPick)
    local f = CreateFrame("Frame", nil, parent); f:SetSize(360, AL_H)
    local prefs = GloomsHubDB and GloomsHubDB.textureBrowse
    if GloomsHubDB and not prefs then prefs = { src = "game", flip = false }; GloomsHubDB.textureBrowse = prefs end
    prefs = prefs or { src = "game", flip = false }
    local items, filtered, offset, selected = {}, {}, 0, nil
    local openSheet, sheetQuery   -- the sheet whose pieces are showing, and the search it was found with
    local api = {}
    f.api = api

    local switch = UI.gSwitch(f, { { "game", "Game Art" }, { "sheets", "Sheets" }, { "mine", "My Media" }, { "favs", "Favorites" } },
        function() return prefs.src end,
        function(v) prefs.src = v; openSheet = nil; api.reload() end, { w = 360, size = 10 })
    switch:SetPoint("TOPLEFT", 0, 0)
    UI.attachTip(switch.segs[1], "Game Art", "Every atlas in the game — the same list Texture Atlas Viewer shows.")
    UI.attachTip(switch.segs[2], "Sheets", "The game's art by image file — each whole sheet, the way Texture Atlas Viewer shows it. Click one to see it whole and open its pieces.")
    UI.attachTip(switch.segs[3], "My Media", "Your own files — the ones added under Textures and Graphics in gloomMEDIA.")
    UI.attachTip(switch.segs[4], "Favorites", "The textures you've added to favorites, with their spritesheet settings.")

    UI.gLabel(f, "Search"):SetPoint("TOPLEFT", 0, -26)
    local search = UI.gField(f, 360, { placeholder = "Words in the name — swirl, glow, fire flip…" })
    search:SetPoint("TOPLEFT", 0, -41)
    UI.attachTip(search, "Search", "Shows the art whose name has every word you type, in any order. Escape clears it.")

    local flip = UI.gCheck(f, "Flipbooks Only", function() return prefs.flip end,
        function(v) prefs.flip = v and true or false; api.filter() end)
    flip:SetPoint("TOPLEFT", 0, -67)
    UI.attachTip(flip, "Flipbooks Only", "Only animations — names with \"flipbook\" or \"-flip\" in them, the game's own spritesheets.")
    -- inside a sheet: the way back, where Flipbooks Only was
    local back = UI.gButton(f, "‹ All Sheets", { h = 16, size = 10, pad = 10, onClick = function()
        openSheet = nil
        search:SetText(sheetQuery or "")
        api.reload()
    end })
    back:SetPoint("TOPLEFT", 0, -67); back:Hide()
    UI.attachTip(back, "All Sheets", "Back to the list of sheets, and the search you found this one with.")
    local counter = UI.newText(f, FONTS.sa, 10, LILAC, "RIGHT"); counter:SetPoint("TOPRIGHT", 0, -70)
    f.counter = counter

    -- the grid
    local grid = CreateFrame("Frame", nil, f)
    grid:SetSize(360, AL_ROWS * AL_PITCH - 8); grid:SetPoint("TOPLEFT", 0, -AL_GRID_Y)
    grid:EnableMouseWheel(true)
    local empty = note(grid, "", 340)
    f.empty = empty
    empty:SetPoint("TOPLEFT", 0, 0)
    local hoverName = UI.newText(f, FONTS.sa, 10, COLOR.paper, "LEFT")
    hoverName:SetPoint("TOPLEFT", 0, -(AL_GRID_Y + AL_ROWS * AL_PITCH - 8 + 8)); hoverName:SetWidth(270); hoverName:SetWordWrap(false)
    local hoverMeta = UI.newText(f, FONTS.sa, 9, LILAC, "RIGHT")
    hoverMeta:SetPoint("TOPRIGHT", 0, -(AL_GRID_Y + AL_ROWS * AL_PITCH - 8 + 9))
    local function showName(item, info)
        if not item then
            hoverName:SetText(openSheet and (openSheet.name .. "  ·  " .. openSheet.meta) or (selected and not selected:find("^sheet:") and selected) or "")
            hoverMeta:SetText(""); return
        end
        hoverName:SetText(item.name)
        local size = info and info.width and ("%d x %d"):format(info.width, info.height)
        if size and item.meta then hoverMeta:SetText(item.meta .. "  ·  " .. size)
        else hoverMeta:SetText(size or item.meta or "") end
    end
    local cells = {}
    for i = 1, AL_COLS * AL_ROWS do
        local c = CreateFrame("Button", nil, grid); c:SetSize(AL_CELL, AL_CELL)
        c:SetPoint("TOPLEFT", ((i - 1) % AL_COLS) * AL_PITCH, -math.floor((i - 1) / AL_COLS) * AL_PITCH)
        c.bg = c:CreateTexture(nil, "BACKGROUND"); c.bg:SetAllPoints()
        c.tex = c:CreateTexture(nil, "ARTWORK"); c.tex:SetPoint("CENTER")
        -- My Media's cells carry their pixel size along the bottom
        c.sizeBg = c:CreateTexture(nil, "OVERLAY"); c.sizeBg:SetPoint("BOTTOMLEFT"); c.sizeBg:SetPoint("BOTTOMRIGHT")
        c.sizeBg:SetHeight(12); c.sizeBg:SetColorTexture(0, 0, 0, 0.6); c.sizeBg:Hide()
        c.size = UI.newText(c, FONTS.sa, 8, COLOR.paper, "CENTER"); c.size:SetDrawLayer("OVERLAY", 1)
        c.size:SetPoint("BOTTOM", 0, 2); c.size:Hide()
        c:SetScript("OnEnter", function(self) self.hot = true; api.paintCell(self); showName(self.item, self.info) end)
        c:SetScript("OnLeave", function(self) self.hot = nil; api.paintCell(self); showName(nil) end)
        c:SetScript("OnClick", function(self)
            if not self.item then return end
            local item = self.item
            selected = item.key or item.name
            for _, o in ipairs(cells) do api.paintCell(o) end
            if item.pieces then
                -- a sheet: show it whole, and open its pieces
                onPick(tostring(item.sheetFile))
                sheetQuery = search:GetText()
                openSheet = item
                search:SetText("")
                api.reload()
            else
                onPick(item.name, item.sheet)
            end
        end)
        cells[i] = c
    end
    -- the scrollbar (the favorites' bar), in the margin, only while it overflows
    local track = CreateFrame("Frame", nil, grid); track:SetWidth(3)
    track:SetPoint("TOPLEFT", grid, "TOPLEFT", 370.5, 0); track:SetPoint("BOTTOMLEFT", grid, "BOTTOMLEFT", 370.5, 0)
    local tt = track:CreateTexture(nil, "BACKGROUND"); tt:SetAllPoints(); tt:SetColorTexture(0, 0, 0, 0.5)
    local thumb = CreateFrame("Frame", nil, track); thumb:SetWidth(3)
    local th = thumb:CreateTexture(nil, "ARTWORK"); th:SetAllPoints(); th:SetColorTexture(VIOLET.r, VIOLET.g, VIOLET.b, 0.5)
    track:Hide()
    local function maxRows() return math.max(0, math.ceil(#filtered / AL_COLS) - AL_ROWS) end
    DragBar(track, thumb, function() return offset end, maxRows, function(o) offset = o; api.paint() end)

    function api.paintCell(c)
        local a, col = 0.08, VIOLET
        if c.item and (c.item.key or c.item.name) == selected then a, col = 0.3, LIME
        elseif c.hot and c.item then a = 0.25 end
        c.bg:SetColorTexture(col.r, col.g, col.b, a)
    end
    local function fmtN(n)
        local s = tostring(n)
        while true do local k; s, k = s:gsub("^(%d+)(%d%d%d)", "%1,%2"); if k == 0 then break end end
        return s
    end
    -- sizes arriving (many at once) repaint the grid ONCE, on the next frame
    local repaintQueued
    function api.repaintSoon()
        if repaintQueued then return end
        repaintQueued = true
        C_Timer.After(0, function() repaintQueued = nil; if f:IsVisible() then api.paint() end end)
    end
    function api.paint()
        local total = #filtered
        local maxOff = math.max(0, math.ceil(total / AL_COLS) - AL_ROWS)
        offset = math.max(0, math.min(maxOff, offset))
        for i, c in ipairs(cells) do
            local item = filtered[offset * AL_COLS + i]
            c.item = item
            if item then
                c.info = PaintThumb(c.tex, item, function() if c.item == item then api.repaintSoon() end end, c)
                -- the badge: My Media's pixel size, a sheet's piece count
                local badge = item.badge or (item.tex and c.info and ("%d x %d"):format(c.info.width, c.info.height))
                c.size:SetShown(badge ~= nil); c.sizeBg:SetShown(badge ~= nil)
                if badge then c.size:SetText(badge) end
                c:Show()
            else c.info = nil; c:Hide() end
            api.paintCell(c)
        end
        -- what's empty, said plainly
        local msg
        if total == 0 then
            if #items == 0 then
                msg = (prefs.src == "mine") and "Nothing here yet. Put a file into GloomsHub\\Textures\\ or GloomsHub\\Graphics\\, then add it under Textures or Graphics in gloomMEDIA — WoW can't look inside a folder, so only files added there show up."
                    or (prefs.src == "favs") and "No favorites yet — pick something and click Add to Favorites."
                or (prefs.src == "sheets") and "The game didn't hand over its sheets."
                    or "The game didn't hand over its list of art."
            else
                msg = "Nothing matches."
            end
        end
        empty:SetText(msg or ""); empty:SetShown(msg ~= nil)
        local one, many = "item", "items"
        if prefs.src == "game" or openSheet then one, many = "atlas", "atlases"
        elseif prefs.src == "sheets" then one, many = "sheet", "sheets" end
        if total == 0 then counter:SetText("")
        elseif total <= AL_COLS * AL_ROWS then
            counter:SetText(fmtN(total) .. " " .. (total == 1 and one or many))
        else
            counter:SetText(("%s–%s of %s"):format(fmtN(offset * AL_COLS + 1),
                fmtN(math.min(total, (offset + AL_ROWS) * AL_COLS)), fmtN(total)))
        end
        if maxOff > 0 then
            local view = AL_ROWS * AL_PITCH - 8
            local thH = math.max(18, math.floor(view * AL_ROWS / (maxOff + AL_ROWS) + 0.5))
            thumb:SetHeight(thH)
            thumb:ClearAllPoints(); thumb:SetPoint("TOP", track, "TOP", 0, -math.floor((view - thH) * (offset / maxOff) + 0.5))
            track:Show()
        else
            track:Hide()
        end
        showName(nil)
    end
    function api.filter()
        local words = {}
        for w in (search:GetText() or ""):lower():gmatch("%S+") do words[#words + 1] = w end
        wipe(filtered)
        for _, item in ipairs(items) do
            local ok = openSheet or not prefs.flip or IsFlipbook(item.low)
            if ok then
                for _, w in ipairs(words) do
                    if not item.low:find(w, 1, true) then ok = false; break end
                end
            end
            if ok then filtered[#filtered + 1] = item end
        end
        offset = 0
        api.paint()
    end
    function api.reload()
        if prefs.src == "mine" then items = MyArt()
        elseif prefs.src == "favs" then items = FavArt()
        elseif prefs.src == "sheets" then items = openSheet and openSheet.pieces or SheetArt()
        else items = GameArt() end
        switch:refresh(); flip:refresh()
        flip:SetShown(not openSheet); back:SetShown(openSheet ~= nil)
        api.filter()
    end
    function api.select(name) selected = (name ~= "" and name) or nil; for _, c in ipairs(cells) do api.paintCell(c) end; showName(nil) end

    -- typing filters after a breath (the game list is tens of thousands long)
    local pending
    search:HookScript("OnTextChanged", function(_, user)
        if not user then api.filter(); return end
        if pending then return end
        pending = true
        C_Timer.After(0.15, function() pending = nil; api.filter() end)
    end)
    search:SetScript("OnEscapePressed", function(self) self:SetText(""); self:ClearFocus(); api.filter() end)
    grid:SetScript("OnMouseWheel", function(_, d) offset = offset - d; api.paint() end)
    f:HookScript("OnShow", function() api.reload() end)
    api.reload()
    return f
end

-- Media's GAME TEXTURES section: the art list, then the browser under it, and —
-- with Gloom's UI loaded — its button to make a new overlay from what is shown.
local function buildGameTextures(parent)
    local f = CreateFrame("Frame", nil, parent); f:SetSize(360, 600)
    local b = buildTextureBrowser(f)
    local list = buildArtList(f, function(name, sheet) b.api.load(name, sheet) end)
    list:SetPoint("TOPLEFT", 0, 0)
    b:SetPoint("TOPLEFT", 0, -(AL_H + 20))
    local function fitH()
        local h = AL_H + 20 + (b:GetHeight() or 0)
        if math.abs((f:GetHeight() or 0) - h) > 0.5 then f:SetHeight(h) end
    end
    b:HookScript("OnSizeChanged", fitH); fitH()
    local s = { frame = f, refresh = function() b.api.refresh(); fitH() end }
    MP.secs[#MP.secs + 1] = s
    local function actions()
        if GloomsOverlays_SaveFromPreview then
            return { { label = "Save as New Overlay", fn = function(t, sh) GloomsOverlays_SaveFromPreview(t, sh) end,
                tip = "Makes a new texture overlay in Gloom's UI from this texture — spritesheet settings included — and opens it there." } }
        end
        return {}
    end
    b:HookScript("OnShow", function() b.api.setActions(actions()) end)
    b.api.setActions(actions())
    return f
end

-- THE TEXTURE BROWSER window. opts = { tool = the calling tool's id (the
-- window opens beside its settings window), text, sheet (to start from),
-- actions = { { label, fn(text, sheet), tip } … } }. Moves like every Suite
-- window, stays on the screen, closes with the tool. Two columns since
-- 2026-09-30: the art list (find it) | the browser (load, grid, use it).
local picker
local PICKER_W = 780
function GloomsHub:PickTexture(opts)
    opts = opts or {}
    local root = GloomsHub:SuiteRoot()
    if not root then return end
    if not picker then
        picker = UI.gWindow({ parent = root, w = PICKER_W, h = 640, minH = 640, maxH = 640,
            onFocus = function(self) GloomsHub:SuiteManage(self) end })
        if picker.grip then picker.grip:Hide() end
        local title = UI.newText(picker.content, FONTS.sa, 14, COLOR.paper, "LEFT")
        title:SetPoint("TOPLEFT", 20, -20); title:SetText("Texture Browser")
        -- the art list on the left, the browser on the right
        picker.browser = buildTextureBrowser(picker.content)
        picker.browser:SetPoint("TOPLEFT", 400, -50)
        picker.list = buildArtList(picker.content, function(name, sheet) picker.browser.api.load(name, sheet) end)
        picker.list:SetPoint("TOPLEFT", 20, -50)
        picker.openBeside = function() end   -- (the harness drives windows that carry this)
        picker:Hide()
    end
    picker.browser.api.setActions(opts.actions)
    picker.browser.api.load(opts.text, opts.sheet)
    picker.list.api.select(opts.text or "")
    -- beside the tool's settings window, else left of its selector, else centred
    local set = opts.tool and GloomsHub:SuiteWindow(opts.tool, "set")
    local sel = opts.tool and GloomsHub:SuiteWindow(opts.tool, "sel")
    local sw = root:GetWidth() or 0
    picker:ClearAllPoints()
    if set and set:GetRight() and set:GetRight() + 20 + PICKER_W <= sw then
        picker:SetPoint("TOPLEFT", set, "TOPRIGHT", 20, 0)
    elseif sel and sel:GetLeft() and sel:GetLeft() - 20 - PICKER_W >= 0 then
        picker:SetPoint("TOPRIGHT", sel, "TOPLEFT", -20, 0)
    else
        picker:SetPoint("CENTER", root, "CENTER")
    end
    picker:Show()
    UI.gSnap(picker)
    GloomsHub:SuiteManage(picker)
end
function GloomsHub:ClosePicker() if picker then picker:Hide() end end
function GloomsHub:PickerShown() return picker ~= nil and picker:IsShown() end

-- ★ WoW MISREADS AN IMAGE EXACTLY 6 TIMES AS WIDE AS IT IS TALL (TESTED
-- 2026-09-30 in game: a 480 x 80 PNG loaded as an 80 x 80 scramble — after a
-- full restart, and re-encoded without Figma's metadata; padded copies at
-- 481 x 80, 512 x 80 and 480 x 128 all read true; the owner's 500 x 80 re-export
-- works). Almost certainly read as a cube map's six faces. The addon CAN'T flag
-- a bad file — the game reports it as a square — so the catalogs say it up front.
-- (Only the wide case was tested; a 1 x 6 strip is unproven either way.)
local SIX_TO_ONE = "|cffff9966Avoid an image exactly 6 times as wide as it is tall (480 x 80, say) — WoW loads it scrambled. A pixel wider fixes it.|r"

local SPECS = {
    {
        id = "fonts", title = "Fonts", addLabel = "Add Font",
        namePh = "My Font", filePh = "MyFont.ttf",
        hint = "The file's name in GloomsHub\\Fonts\\ — .ttf only (WoW can't use .otf).",
        note = "Registered into LibSharedMedia, so every addon that lists fonts can use them. Put the .ttf into GloomsHub\\Fonts\\ first. A new font needs a full restart of the game — WoW loads fonts at launch, so /reload isn't enough.",
        empty = "No fonts yet — add one above.",
        getEntries = function() return GloomsHubDB and GloomsHubDB.fonts or {} end,
        add = function(n, f) return Media:AddFont(n, f) end,
        remove = function(i) return Media:RemoveFont(i) end,
        buildPreview = function(row)
            local fs = UI.newText(row, FONTS.sa, 12, COLOR.paper, "LEFT")
            fs:SetPoint("LEFT", 190, 0); fs:SetWidth(140); fs:SetWordWrap(false)
            return function(_, entry) UI.setFont(fs, FONT_PATH .. entry.file, 12); fs:SetText("AaBbCc 123") end
        end,
    },
    {
        id = "textures", title = "Textures", addLabel = "Add Texture",
        namePh = "My Bar", filePh = "MyBar.tga",
        hint = "The file's name in GloomsHub\\Textures\\ — .tga, .blp or .png.",
        note = "Registered into LibSharedMedia as bar textures, so every addon that lists them can use them. Put the file into GloomsHub\\Textures\\ first; a /reload is enough. " .. SIX_TO_ONE,
        empty = "No textures yet — add one above.",
        getEntries = function() return GloomsHubDB and GloomsHubDB.textures or {} end,
        add = function(n, f) return Media:AddTexture(n, f) end,
        remove = function(i) return Media:RemoveTexture(i) end,
        path = TEXTURE_PATH,
        buildPreview = function(row)
            local tex = row:CreateTexture(nil, "ARTWORK"); tex:SetSize(130, 12); tex:SetPoint("LEFT", 190, 0)
            return function(_, entry) tex:SetTexture(TEXTURE_PATH .. entry.file) end
        end,
    },
    {
        id = "graphics", title = "Graphics", addLabel = "Add Graphic",
        namePh = "Gold Swirl", filePh = "GoldSwirl.png",
        hint = "The file's name in GloomsHub\\Graphics\\ — .png or .tga.",
        note = "Decorative art for Gloom's UI, found by its display name. Not in LibSharedMedia. Put the file into GloomsHub\\Graphics\\ first; a /reload is enough. " .. SIX_TO_ONE,
        empty = "No graphics yet — add one above.",
        getEntries = function() return GloomsHubDB and GloomsHubDB.graphics or {} end,
        add = function(n, f) return Media:AddGraphic(n, f) end,
        remove = function(i) return Media:RemoveGraphic(i) end,
        path = GRAPHIC_PATH,
        buildPreview = function(row)
            local tex = row:CreateTexture(nil, "ARTWORK"); tex:SetSize(24, 24); tex:SetPoint("LEFT", 190, 0)
            return function(_, entry) tex:SetTexture(GRAPHIC_PATH .. entry.file) end
        end,
    },
    {
        id = "sounds", title = "Sounds", addLabel = "Add Sound", stop = true,
        fileLabel = "FileDataID or File Name",
        namePh = "My Sound", filePh = "567397 or MySound.ogg",
        hint = "A FileDataID from wago.tools (e.g. 567397), or the name of an .ogg / .mp3 in GloomsHub\\Sounds\\.",
        note = "Registered into LibSharedMedia — this is what puts them in Gloom's Auras' sound list, and every other addon that lists sounds. Paste a FileDataID from wago.tools, or put an .ogg / .mp3 into GloomsHub\\Sounds\\ and type its name. Hear the game's own sounds under Game Sounds.",
        empty = "No sounds yet — find one under Game Sounds, or paste a FileDataID above.",
        getEntries = function() return GloomsHubDB and GloomsHubDB.sounds or {} end,
        add = function(n, f) return Media:AddSound(n, f) end,
        remove = function(i) return Media:RemoveSound(i) end,
        fileText = function(entry)
            if type(entry.file) == "number" then return "FileDataID " .. entry.file end
            return (tostring(entry.file):gsub("^Interface\\AddOns\\GloomsHub\\Sounds\\", ""))
        end,
        buildPreview = function(row)
            local b = UI.gButton(row, "Play", { w = 60, h = 16, size = 10 })
            b:SetPoint("LEFT", 190, 0)
            return function(r, entry)
                b:SetScript("OnClick", function()
                    local sec
                    for _, x in ipairs(MP.secs) do if x.id == "sounds" then sec = x end end
                    if not Media:Play(entry.file) and sec then
                        status(sec.status, "\"" .. entry.name .. "\" didn't play — the ID or file may be wrong.", false)
                    end
                end)
            end
        end,
    },
}

-- ------------------------------------------------------------
-- THE SELECTOR — the catalogs from y 52, 18 to a line: the name in
-- Sansation 10, its count right-aligned in lilac; the open one violet 30%
-- across the window. A click opens that section. Under them, what this is.
-- ------------------------------------------------------------
local CATALOGS = {
    { id = "fonts", label = "Fonts", count = function() return #(GloomsHubDB and GloomsHubDB.fonts or {}) end },
    { id = "textures", label = "Textures", count = function() return #(GloomsHubDB and GloomsHubDB.textures or {}) end },
    { id = "graphics", label = "Graphics", count = function() return #(GloomsHubDB and GloomsHubDB.graphics or {}) end },
    { id = "sounds", label = "Sounds", count = function() return #(GloomsHubDB and GloomsHubDB.sounds or {}) end },
    { id = "browse", label = "Game Sounds", count = function() return #Media:SoundKits() end },
    { id = "gametex", label = "Game Textures", count = function() return #TextureFavorites() end },
}
local function openSection()
    local d = GloomsHubDB and GloomsHubDB.win and GloomsHubDB.win.media
    return d and d.open
end
local function buildSelector(c)
    local rows = {}
    for i, cat in ipairs(CATALOGS) do
        local r = CreateFrame("Button", nil, c); r:SetSize(200, 18)
        r:SetPoint("TOPLEFT", 20, -(52 + (i - 1) * 18))
        r.hl = r:CreateTexture(nil, "BACKGROUND"); r.hl:SetPoint("TOPLEFT", -20, 1); r.hl:SetPoint("BOTTOMRIGHT", 20, -1); r.hl:Hide()
        r.name = UI.newText(r, FONTS.sa, 10, COLOR.paper, "LEFT"); r.name:SetPoint("LEFT", 0, 0); r.name:SetText(cat.label)
        r.count = UI.newText(r, FONTS.sa, 10, LILAC, "RIGHT"); r.count:SetPoint("RIGHT", 0, 0)
        r:SetScript("OnEnter", function(self) if openSection() ~= cat.id then self.hl:SetColorTexture(VIOLET.r, VIOLET.g, VIOLET.b, 0.15); self.hl:Show() end end)
        r:SetScript("OnLeave", function() MP.renderSelector() end)
        r:SetScript("OnClick", function() GloomsHub:ShowPage("media", cat.id); MP.renderSelector() end)
        rows[i] = r
    end
    local about = note(c, "The suite's shared media: fonts, bar textures and sounds every addon can use, and the art Gloom's Overlays draws.", 200)
    about:SetPoint("TOPLEFT", 20, -(52 + #CATALOGS * 18 + 20))
    function MP.renderSelector()
        local open = openSection()
        for i, cat in ipairs(CATALOGS) do
            local r = rows[i]
            r.count:SetText(tostring(cat.count() or 0))
            if open == cat.id then r.hl:SetColorTexture(VIOLET.r, VIOLET.g, VIOLET.b, 0.3); r.hl:Show() else r.hl:Hide() end
        end
    end
    MP.renderSelector()
end

-- THE TAB — "gloomMEDIA:" lime, then white.
local function buildTab(tab)
    local lead = UI.newText(tab, FONTS.sa, 10, LIME, "LEFT"); lead:SetPoint("TOPLEFT", 20, -9)
    lead:SetText("gloomMEDIA: ")
    local name = UI.newText(tab, FONTS.sa, 10, COLOR.paper, "LEFT"); name:SetPoint("LEFT", lead, "RIGHT", 0, 0)
    name:SetText("Suite Media Catalog")
    return { refresh = function() end }
end

local sections = {}
for _, spec in ipairs(SPECS) do
    sections[#sections + 1] = { id = spec.id, title = spec.title, build = function(p)
        local f = buildCatalog(p, spec)
        MP.secs[#MP.secs].id = spec.id
        return f
    end, onShow = function() if MP.renderSelector then MP.renderSelector() end end }
end
sections[#sections + 1] = { id = "browse", title = "Game Sounds", build = buildBrowser,
    onShow = function() if MP.renderSelector then MP.renderSelector() end end }
sections[#sections + 1] = { id = "gametex", title = "Game Textures", build = buildGameTextures,
    onShow = function() if MP.renderSelector then MP.renderSelector() end end }

GloomsHub:RegisterTab{
    id       = "media",
    title    = "Media",
    order    = 90,
    wordmark = "MEDIA",
    windows  = true,
    selector = { build = buildSelector, h = 240 },
    tab      = { w = 360, build = buildTab },
    sections = sections,
    onOpen   = function() refreshAll() end,
    refresh  = function() refreshAll() end,
}
