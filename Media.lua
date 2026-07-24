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

-- ============================================================
-- Register all saved entries (fired at PLAYER_ENTERING_WORLD)
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

    -- Graphics are intentionally NOT registered into LSM.

    local parts = {}
    if fontCount > 0 then
        parts[#parts+1] = fontCount .. " font" .. (fontCount == 1 and "" or "s")
    end
    if texCount > 0 then
        parts[#parts+1] = texCount .. " texture" .. (texCount == 1 and "" or "s")
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
