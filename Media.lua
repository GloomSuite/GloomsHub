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
-- Register all saved entries (fired at PLAYER_ENTERING_WORLD)
-- ============================================================

function Media:RegisterAll()
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
    -- Warming runs BEFORE registration and now reports which faces would not
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
-- The Media tab — the reskinned Fonts/Textures/Graphics manager
-- over the API above (functional port of StoneTweaks_UI's three
-- media pages, rebuilt in the Gloom language: one-open accordion,
-- flat inputs/buttons, orange scrollbar). Registered into the
-- shell; build(container) runs lazily on first show.
-- ============================================================

local UI, COLOR, FONTS = GloomsHub.UI, GloomsHub.COLOR, GloomsHub.FONT

local SECTION_HDR_H = 36
local ROW_H = 38

local sections, refreshers = {}, {}
local scrollFrame, scrollChild, scrollbar, statusText

local function setStatus(msg, ok)
    if not statusText then return end
    local c = (ok == nil and COLOR.mute) or (ok and COLOR.green) or COLOR.red
    statusText:SetTextColor(c.r, c.g, c.b)
    statusText:SetText(msg or "")
end

local function relayout()
    local y = 0
    for _, s in ipairs(sections) do
        s.header:ClearAllPoints()
        s.header:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -y)
        s.header:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -y)
        y = y + SECTION_HDR_H
        s.caret:SetRotation(s.open and UI.CARET_DOWN or 0)
        if s.open then
            s.body:ClearAllPoints()
            s.body:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -y)
            s.body:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -y)
            s.body:Show()
            y = y + s.body:GetHeight()
        else
            s.body:Hide()
        end
    end
    scrollChild:SetHeight(math.max(1, y))
    if scrollbar then scrollbar.Sync() end
    -- Counts live here because relayout() is the single path every mutation
    -- funnels through: initial build, add, remove, and the tab's refresh hook.
    for _, s in ipairs(sections) do
        if s.updateCount then s.updateCount() end
    end
end

-- One-open accordion (the family convention; all start closed).
local function toggleSection(target)
    for _, s in ipairs(sections) do
        s.open = (s == target) and (not s.open) or false
    end
    relayout()
end

-- countFn (optional) → a number shown right-aligned on the header. The owner,
-- 2026-07-25: "would be nice to show how many assets are in each of those
-- categories without having to expand the section." Kept on the HEADER so it
-- reads while the accordion is CLOSED, which is the whole point.
local function makeSection(title, buildBody, countFn)
    local s = { open = false }
    local header = CreateFrame("Button", nil, scrollChild)
    header:SetHeight(SECTION_HDR_H)
    local hover = header:CreateTexture(nil, "BACKGROUND"); hover:SetAllPoints(); hover:SetColorTexture(1, 1, 1, 0.05); hover:Hide()
    header:SetScript("OnEnter", function() hover:Show() end)
    header:SetScript("OnLeave", function() hover:Hide() end)
    local caret = header:CreateTexture(nil, "ARTWORK"); caret:SetTexture(UI.CARET)
    caret:SetVertexColor(COLOR.orange.r, COLOR.orange.g, COLOR.orange.b)
    caret:SetSize(9, 9); caret:SetPoint("LEFT", 18, 0)
    local h = UI.newText(header, FONTS.head, 16, COLOR.purple, "LEFT")
    h:SetPoint("LEFT", caret, "RIGHT", 11, -1); h:SetText(title:upper())
    if countFn then
        local cnt = UI.newText(header, FONTS.body, 12, COLOR.mute, "RIGHT")
        cnt:SetPoint("RIGHT", -18, -1)      -- -1 matches the title's optical baseline
        s.updateCount = function() cnt:SetText(tostring(countFn() or 0)) end
        s.updateCount()
    end
    local div = UI.hLine(header)
    div:SetPoint("BOTTOMLEFT", 0, 0); div:SetPoint("BOTTOMRIGHT", 0, 0)

    local body = CreateFrame("Frame", nil, scrollChild)
    body:SetHeight(10); body:Hide()

    s.header, s.caret, s.body = header, caret, body
    header:SetScript("OnClick", function() toggleSection(s) end)
    buildBody(body, s)
    sections[#sections + 1] = s
    return s
end

-- One catalog section (Fonts / Textures / Graphics): add form + note + row list.
local function buildCatalogSection(body, spec)
    local nameLbl = UI.newText(body, FONTS.body, 12, COLOR.text, "LEFT")
    nameLbl:SetPoint("TOPLEFT", 18, -14); nameLbl:SetText("Display name")
    local nameBox = UI.flatEditBox(body, 300, 22)
    nameBox:SetPoint("TOPLEFT", 150, -10)
    local fileLbl = UI.newText(body, FONTS.body, 12, COLOR.text, "LEFT")
    fileLbl:SetPoint("TOPLEFT", 18, -44); fileLbl:SetText("Filename")
    local fileBox = UI.flatEditBox(body, 300, 22)
    fileBox:SetPoint("TOPLEFT", 150, -40)
    local hint = UI.newText(body, FONTS.body, 10.5, COLOR.mute, "LEFT")
    hint:SetPoint("TOPLEFT", 150, -68); hint:SetText(spec.hint)
    local addBtn = UI.flatButton(body, 110, 24, COLOR.purple, spec.addLabel, 12)
    addBtn:SetBase(1)
    addBtn:SetPoint("TOPRIGHT", -18, -24)
    -- Optional per-section control tucked under Add (Sounds uses it for Stop).
    if spec.extraControl then spec.extraControl(body, addBtn) end

    local note = UI.newText(body, FONTS.body, 10.5, COLOR.mute, "LEFT")
    note:SetPoint("TOPLEFT", 18, -88); note:SetPoint("TOPRIGHT", -18, -88)
    note:SetText(spec.note)

    local LIST_TOP = 124   -- room for the note to wrap to two lines
    local pool = {}
    local emptyText = UI.newText(body, FONTS.body, 11, COLOR.mute, "LEFT")
    emptyText:SetPoint("TOPLEFT", 18, -(LIST_TOP + 12)); emptyText:SetText(spec.empty)

    local function refresh()
        local entries = spec.getEntries()
        local y = LIST_TOP
        for i, entry in ipairs(entries) do
            local row = pool[i]
            if not row then
                row = CreateFrame("Frame", nil, body)
                row:SetHeight(ROW_H)
                local bg = row:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints(); bg:SetColorTexture(1, 1, 1, i % 2 == 0 and 0.04 or 0)
                row.nameText = UI.newText(row, FONTS.bodyM, 12, COLOR.text, "LEFT")
                row.nameText:SetPoint("TOPLEFT", 18, -6); row.nameText:SetWidth(260)
                row.fileText = UI.newText(row, FONTS.body, 10.5, COLOR.mute, "LEFT")
                row.fileText:SetPoint("TOPLEFT", 18, -22); row.fileText:SetWidth(260)
                row.preview = spec.buildPreview(row)
                row.removeBtn = UI.flatButton(row, 72, 20, COLOR.heroic, "Remove", 11)
                row.removeBtn:SetPoint("RIGHT", -18, 0)
                pool[i] = row
            end
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, -y); row:SetPoint("TOPRIGHT", 0, -y)
            row:Show()
            row.nameText:SetText(entry.name)
            row.fileText:SetText(spec.fileLabel and spec.fileLabel(entry) or entry.file)
            if row.preview then row.preview(row, entry) end
            row.removeBtn:SetScript("OnClick", function()
                local ok, msg = spec.remove(i)
                setStatus(msg, ok)
                refresh(); relayout()
            end)
            y = y + ROW_H
        end
        for i = #entries + 1, #pool do pool[i]:Hide() end
        emptyText:SetShown(#entries == 0)
        if #entries == 0 then y = y + 36 end
        body:SetHeight(y + 10)
    end

    local function submit()
        local ok, msg = spec.add(nameBox:GetText(), fileBox:GetText())
        setStatus(msg, ok)
        if ok then
            nameBox:SetText(""); fileBox:SetText(""); nameBox:ClearFocus(); fileBox:ClearFocus()
            refresh(); relayout()
        end
    end
    addBtn:SetScript("OnClick", submit)
    nameBox:SetScript("OnEnterPressed", function() fileBox:SetFocus() end)
    fileBox:SetScript("OnEnterPressed", submit)
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    fileBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    refreshers[#refreshers + 1] = refresh
    refresh()
end

-- One catalog section (Fonts / Textures / Graphics / Sounds) is above. The
-- SOUND BROWSER below is a different shape and deliberately does not reuse it:
-- it is read-only, it is 865 rows long, and it is the one place in the suite
-- that plays SoundKitIDs rather than FileDataIDs.
--
-- ★ WHY THERE IS NO "ADD" BUTTON HERE. SOUNDKIT ids cannot go into
-- LibSharedMedia — see the RegisterSound comment. This section exists to let
-- the owner HEAR the game's sounds without leaving the client; getting one
-- into GA's picker still means finding its FileDataID on wago.tools and
-- pasting that into Sounds above. Do not "fix" this by registering item.id.
local BROWSE_ROWS  = 12
local BROWSE_ROW_H = 22

local function buildBrowserSection(body)
    local searchBox = UI.flatEditBox(body, 260, 22)
    searchBox:SetPoint("TOPLEFT", 18, -12)
    -- Always enabled: WoW fires no "sound ended" event, so we can never know
    -- whether there is something to stop. A no-op Stop is the honest default.
    local stopBtn = UI.flatButton(body, 62, 22, COLOR.heroic, "Stop", 11)
    stopBtn:SetPoint("LEFT", searchBox, "RIGHT", 10, 0)
    stopBtn:SetScript("OnClick", function()
        if Media:Stop() then setStatus("Stopped.") end
    end)
    local counter = UI.newText(body, FONTS.body, 11, COLOR.mute, "RIGHT")
    counter:SetPoint("TOPRIGHT", -18, -16)

    local note = UI.newText(body, FONTS.body, 10.5, COLOR.mute, "LEFT")
    note:SetPoint("TOPLEFT", 18, -44); note:SetPoint("TOPRIGHT", -18, -44)
    note:SetText("Every sound the game's interface uses, by name. Click a row to hear it; type to filter by name or ID. "
        .. "These are SoundKit IDs, which other addons cannot read — to use one in Gloom's Auras, look its file up on "
        .. "wago.tools and paste that FileDataID into Sounds above.")

    local LIST_TOP = 92
    local list = CreateFrame("Frame", nil, body)
    list:SetPoint("TOPLEFT", 0, -LIST_TOP)
    list:SetPoint("TOPRIGHT", 0, -LIST_TOP)
    list:SetHeight(BROWSE_ROWS * BROWSE_ROW_H)
    list:EnableMouseWheel(true)

    local filtered, offset, rows = {}, 0, {}

    local function paint()
        local maxOff = math.max(0, #filtered - BROWSE_ROWS)
        if offset > maxOff then offset = maxOff end
        if offset < 0 then offset = 0 end
        for i = 1, BROWSE_ROWS do
            local row, item = rows[i], filtered[i + offset]
            if item then
                row.nameText:SetText(item.name)
                row.idText:SetText(item.id)
                row.item = item
                row:Show()
            else
                row.item = nil
                row:Hide()
            end
        end
        if #filtered == 0 then
            counter:SetText("no matches")
        elseif #filtered <= BROWSE_ROWS then
            counter:SetText(#filtered .. (#filtered == 1 and " sound" or " sounds"))
        else
            counter:SetText(("%d–%d of %d"):format(offset + 1, math.min(offset + BROWSE_ROWS, #filtered), #filtered))
        end
    end

    for i = 1, BROWSE_ROWS do
        local row = CreateFrame("Button", nil, list)
        row:SetHeight(BROWSE_ROW_H)
        row:SetPoint("TOPLEFT", 0, -(i - 1) * BROWSE_ROW_H)
        row:SetPoint("TOPRIGHT", 0, -(i - 1) * BROWSE_ROW_H)
        local hover = row:CreateTexture(nil, "BACKGROUND")
        hover:SetAllPoints(); hover:SetColorTexture(1, 1, 1, 0.06); hover:Hide()
        row:SetScript("OnEnter", function() hover:Show() end)
        row:SetScript("OnLeave", function() hover:Hide() end)
        row.nameText = UI.newText(row, FONTS.body, 12, COLOR.text, "LEFT")
        row.nameText:SetPoint("LEFT", 18, 0); row.nameText:SetWidth(330)
        row.idText = UI.newText(row, FONTS.body, 11, COLOR.mute, "RIGHT")
        row.idText:SetPoint("RIGHT", -18, 0)
        row:SetScript("OnClick", function(self)
            if not self.item then return end
            -- "kit" — the ONLY caller that passes it. See Media:Play.
            Media:Play(self.item.id, "kit")
            setStatus(self.item.name .. "  ·  SoundKit " .. self.item.id)
        end)
        rows[i] = row
    end

    list:SetScript("OnMouseWheel", function(_, delta)
        offset = offset - delta * 3
        paint()
    end)

    local function applyFilter()
        local q = (searchBox:GetText() or ""):lower():match("^%s*(.-)%s*$")
        wipe(filtered)
        for _, item in ipairs(Media:SoundKits()) do
            if q == "" or item.name:lower():find(q, 1, true) or tostring(item.id):find(q, 1, true) then
                filtered[#filtered + 1] = item
            end
        end
        offset = 0
        paint()
    end

    searchBox:SetScript("OnTextChanged", applyFilter)
    searchBox:SetScript("OnEscapePressed", function(self) self:SetText(""); self:ClearFocus() end)
    searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    applyFilter()
    body:SetHeight(LIST_TOP + BROWSE_ROWS * BROWSE_ROW_H + 14)
end

local SPECS = {
    {
        title = "Fonts", addLabel = "Add Font",
        hint = "e.g.  MyFont.ttf  — TTF only (OTF is not supported by WoW)",
        note = "Registered into LibSharedMedia — visible to every LSM-aware addon. Drop .ttf files into GloomsHub\\Fonts\\ first. A new font needs a full WoW restart (not /reload) to render correctly.",
        empty = "No fonts yet — add one above.",
        getEntries = function() return GloomsHubDB and GloomsHubDB.fonts or {} end,
        add = function(n, f) return Media:AddFont(n, f) end,
        remove = function(i) return Media:RemoveFont(i) end,
        buildPreview = function(row)
            local fs = UI.newText(row, FONTS.body, 13, COLOR.text, "LEFT")
            fs:SetPoint("LEFT", 300, 0); fs:SetWidth(170)
            return function(_, entry)
                UI.setFont(fs, FONT_PATH .. entry.file, 13)
                fs:SetText("AaBbCc 123")
            end
        end,
    },
    {
        title = "Textures", addLabel = "Add Texture",
        hint = "e.g.  MyBar.tga  or  MyBar.blp  or  MyBar.png",
        note = "Registered into LibSharedMedia as statusbar textures — visible to every LSM-aware addon. Drop files into GloomsHub\\Textures\\ first; a /reload is enough to use a new one.",
        empty = "No textures yet — add one above.",
        getEntries = function() return GloomsHubDB and GloomsHubDB.textures or {} end,
        add = function(n, f) return Media:AddTexture(n, f) end,
        remove = function(i) return Media:RemoveTexture(i) end,
        buildPreview = function(row)
            local tex = row:CreateTexture(nil, "ARTWORK")
            tex:SetSize(120, 14); tex:SetPoint("LEFT", 300, 0)
            return function(_, entry) tex:SetTexture(TEXTURE_PATH .. entry.file) end
        end,
    },
    {
        title = "Graphics", addLabel = "Add Graphic",
        hint = "e.g.  GoldSwirl.png  or  GoldSwirl.tga",
        note = "NOT in LibSharedMedia — decorative assets resolved by display name (overlays use these). Drop .png or .tga files into GloomsHub\\Graphics\\ first.",
        empty = "No graphics yet — add one above.",
        getEntries = function() return GloomsHubDB and GloomsHubDB.graphics or {} end,
        add = function(n, f) return Media:AddGraphic(n, f) end,
        remove = function(i) return Media:RemoveGraphic(i) end,
        buildPreview = function(row)
            local tex = row:CreateTexture(nil, "ARTWORK")
            tex:SetSize(28, 28); tex:SetPoint("LEFT", 300, 0)
            return function(_, entry) tex:SetTexture(GRAPHIC_PATH .. entry.file) end
        end,
    },
    {
        title = "Sounds", addLabel = "Add Sound",
        hint = "a FileDataID from wago.tools  (e.g.  567397)  — or  MySound.ogg",
        note = "Registered into LibSharedMedia — this is what puts them in Gloom's Auras' sound picker, and every other LSM-aware addon. Paste a FileDataID from wago.tools, or drop an .ogg / .mp3 into GloomsHub\\Sounds\\ and type the filename. Browse the game's own sounds in the section below.",
        empty = "No sounds yet — browse below, or paste a FileDataID above.",
        getEntries = function() return GloomsHubDB and GloomsHubDB.sounds or {} end,
        add = function(n, f) return Media:AddSound(n, f) end,
        remove = function(i) return Media:RemoveSound(i) end,
        fileLabel = function(entry)
            if type(entry.file) == "number" then return "FileDataID " .. entry.file end
            return (tostring(entry.file):gsub("^Interface\\AddOns\\GloomsHub\\Sounds\\", ""))
        end,
        extraControl = function(body, addBtn)
            local stopBtn = UI.flatButton(body, 110, 22, COLOR.heroic, "Stop", 11)
            stopBtn:SetPoint("TOPRIGHT", addBtn, "BOTTOMRIGHT", 0, -6)
            stopBtn:SetScript("OnClick", function()
                if Media:Stop() then setStatus("Stopped.") end
            end)
        end,
        buildPreview = function(row)
            local btn = UI.flatButton(row, 62, 20, COLOR.purple, "Play", 11)
            btn:SetPoint("LEFT", 300, 0)
            return function(_, entry)
                btn:SetScript("OnClick", function()
                    if not Media:Play(entry.file) then
                        setStatus("\"" .. entry.name .. "\" did not play — the ID or file may be wrong.", false)
                    end
                end)
            end
        end,
    },
}

local function BuildMediaTab(container)
    statusText = UI.newText(container, FONTS.body, 11, COLOR.mute, "LEFT")
    statusText:SetPoint("BOTTOMLEFT", 16, 10); statusText:SetPoint("BOTTOMRIGHT", -16, 10)

    -- The Gh mark + wordmark (LibGloomSkin MINOR 4). ★ This tab wears Gh, the
    -- HUB-as-an-addon mark, not GS: GS belongs to the suite and is already on
    -- the window's title bar right above this. The Media tab is the Hub's own
    -- tab, so it names its owner the same way the other three name theirs.
    UI.tabHeader(container, {
        texture = GloomsHub.MEDIA .. "ui\\hub.png",
        label   = "GLOOM'S HUB",
        -- ★ x = 14 to match the Bars and Overlays rails EXACTLY, not 16 to match
        -- this tab's own status line. The owner, 2026-07-25: these headers are
        -- compared by TABBING BETWEEN THEM, so cross-tab alignment beats
        -- internal alignment. 14 is the family inset — keep all four identical.
        x       = 14,
    })

    scrollFrame = CreateFrame("ScrollFrame", nil, container)
    scrollFrame:SetPoint("TOPLEFT", 0, -54)   -- clears the header divider at -48
    scrollFrame:SetPoint("BOTTOMRIGHT", -12, 30)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local range = self:GetVerticalScrollRange()
        self:SetVerticalScroll(math.max(0, math.min(range, self:GetVerticalScroll() - delta * 42)))
    end)
    scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(math.max(1, container:GetWidth() - 16), 10)
    scrollFrame:SetScrollChild(scrollChild)
    scrollbar = UI.makeScrollbar(container, scrollFrame, function(b)
        b:SetPoint("TOPRIGHT", -4, -56); b:SetPoint("BOTTOMRIGHT", -4, 32)   -- below the header
    end)

    for _, spec in ipairs(SPECS) do
        makeSection(spec.title,
            function(body) buildCatalogSection(body, spec) end,
            function() return #(spec.getEntries() or {}) end)
    end
    makeSection("Browse Game Sounds", buildBrowserSection,
        function() return #Media:SoundKits() end)
    relayout()
    setStatus("The suite's shared media catalog — fonts, statusbar textures, overlay graphics, and sounds.")
end

GloomsHub:RegisterTab{
    id = "media",
    title = "MEDIA",
    order = 90,
    build = BuildMediaTab,
    refresh = function()
        for _, r in ipairs(refreshers) do r() end
        if scrollChild then relayout() end
    end,
}
