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
--   five SECTIONS — Fonts · Textures · Graphics · Sounds (each: Display Name
--     | File Name, Add, what the catalog is for, then its entries with a
--     preview and a remove X) · Game Sounds (search, click to hear).
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
        note = "Registered into LibSharedMedia as bar textures, so every addon that lists them can use them. Put the file into GloomsHub\\Textures\\ first; a /reload is enough.",
        empty = "No textures yet — add one above.",
        getEntries = function() return GloomsHubDB and GloomsHubDB.textures or {} end,
        add = function(n, f) return Media:AddTexture(n, f) end,
        remove = function(i) return Media:RemoveTexture(i) end,
        buildPreview = function(row)
            local tex = row:CreateTexture(nil, "ARTWORK"); tex:SetSize(130, 12); tex:SetPoint("LEFT", 190, 0)
            return function(_, entry) tex:SetTexture(TEXTURE_PATH .. entry.file) end
        end,
    },
    {
        id = "graphics", title = "Graphics", addLabel = "Add Graphic",
        namePh = "Gold Swirl", filePh = "GoldSwirl.png",
        hint = "The file's name in GloomsHub\\Graphics\\ — .png or .tga.",
        note = "Decorative art for Gloom's Overlays, found by its display name. Not in LibSharedMedia. Put the file into GloomsHub\\Graphics\\ first.",
        empty = "No graphics yet — add one above.",
        getEntries = function() return GloomsHubDB and GloomsHubDB.graphics or {} end,
        add = function(n, f) return Media:AddGraphic(n, f) end,
        remove = function(i) return Media:RemoveGraphic(i) end,
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
-- THE SELECTOR — the five catalogs from y 52, 18 to a line: the name in
-- Sansation 10, its count right-aligned in lilac; the open one violet 30%
-- across the window. A click opens that section. Under them, what this is.
-- ------------------------------------------------------------
local CATALOGS = {
    { id = "fonts", label = "Fonts", count = function() return #(GloomsHubDB and GloomsHubDB.fonts or {}) end },
    { id = "textures", label = "Textures", count = function() return #(GloomsHubDB and GloomsHubDB.textures or {}) end },
    { id = "graphics", label = "Graphics", count = function() return #(GloomsHubDB and GloomsHubDB.graphics or {}) end },
    { id = "sounds", label = "Sounds", count = function() return #(GloomsHubDB and GloomsHubDB.sounds or {}) end },
    { id = "browse", label = "Game Sounds", count = function() return #Media:SoundKits() end },
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
