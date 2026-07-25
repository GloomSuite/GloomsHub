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
    GloomsHub.UI.WarmFonts(warm)

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
end

-- One-open accordion (the family convention; all start closed).
local function toggleSection(target)
    for _, s in ipairs(sections) do
        s.open = (s == target) and (not s.open) or false
    end
    relayout()
end

local function makeSection(title, buildBody)
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
            row.fileText:SetText(entry.file)
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
}

local function BuildMediaTab(container)
    statusText = UI.newText(container, FONTS.body, 11, COLOR.mute, "LEFT")
    statusText:SetPoint("BOTTOMLEFT", 16, 10); statusText:SetPoint("BOTTOMRIGHT", -16, 10)

    scrollFrame = CreateFrame("ScrollFrame", nil, container)
    scrollFrame:SetPoint("TOPLEFT", 0, -6)
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
        b:SetPoint("TOPRIGHT", -4, -8); b:SetPoint("BOTTOMRIGHT", -4, 32)
    end)

    for _, spec in ipairs(SPECS) do
        makeSection(spec.title, function(body) buildCatalogSection(body, spec) end)
    end
    relayout()
    setStatus("The suite's shared media catalog — fonts, statusbar textures, and overlay graphics.")
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
