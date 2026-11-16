-- ============================================================
-- Core.lua — Gloom's Hub
-- Namespace, saved variables, the one-time StoneTweaks
-- copy-migration, and event wiring. Media behavior (LSM
-- registration, resolver, public API) lives in Media.lua.
-- ============================================================

GloomsHub = GloomsHub or {}
_G.GloomsHub = GloomsHub

local DB_DEFAULTS = {
    fonts    = {},  -- { name = "...", file = "..." } — registered into LSM as "font"
    textures = {},  -- { name = "...", file = "..." } — registered into LSM as "statusbar"
    graphics = {},  -- { name = "...", file = "..." } — NOT registered into LSM (name→path only)
    sounds   = {},  -- { name = "...", file = <path string|FileDataID number> } — registered into LSM as "sound"
}

function GloomsHub:Print(msg)
    print("|cff936bffGloom's Hub|r: " .. msg)
end

-- ★ WHICH GAME, and WHO IS THIS CHARACTER (2026-11-16). WoW Forever (client
-- flavor "Camelot", Interface 16001) runs retail's UI code, and its characters
-- carry a first AND a last name — but at PLAYER_LOGIN, when the tools bind a
-- character, UnitName("player") hands back the FIRST name only (TESTED: the key
-- "Gloomriven-…" was written at login while, in the world minutes later, UnitName,
-- UnitFullName, GetUnitName and UnitPVPName ALL returned "Gloomriven Candlewick").
-- Bars, Auras and Unit Frames key every per-character binding on that name, so
-- two "Gloom …" on one realm (the owner has two) would silently share one profile
-- — and a key built from the full name would differ between a cold login and a
-- /reload. CharacterKeyName is the name those keys use: retail = UnitName,
-- unchanged; Forever = first name + the character's own ID, the same at any moment.
GloomsHub.IS_FOREVER = (WOW_PROJECT_ID ~= nil and WOW_PROJECT_CAMELOT ~= nil and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT)
function GloomsHub.CharacterKeyName()
    local name = UnitName("player")
    if not GloomsHub.IS_FOREVER or not name then return name end
    -- The character's own ID (the GUID's tail) tells alts apart; it never changes.
    local guid = UnitGUID and UnitGUID("player")
    local tail = guid and guid:match("%-(%x+)$")
    return tail and (name .. " #" .. tail:sub(-4):upper()) or name
end
-- What a key built before 2026-11-16 used for the name (the first name alone
-- in Forever; identical to CharacterKeyName in retail). A tool that finds a
-- binding under the old key and none under the new adopts it ONCE — the first
-- character to log in — and drops the old key, so a later alt starts fresh.
function GloomsHub.LegacyCharacterKeyName() return UnitName("player") end

-- ============================================================
-- One-time migration from StoneTweaks (NON-DESTRUCTIVE)
-- COPY — never move — so StoneTweaksDB stays untouched and
-- rollback is just re-enabling StoneTweaks. Entries are copied
-- verbatim, no cleaning. Runs once (migratedFromST flag).
-- ============================================================

local function MigrateFromStoneTweaks()
    if GloomsHubDB.migratedFromST then return end
    if #GloomsHubDB.fonts > 0 then return end
    local st = _G.StoneTweaksDB
    if not st then return end

    GloomsHubDB.fonts    = CopyTable(st.fonts    or {})
    GloomsHubDB.textures = CopyTable(st.textures or {})
    GloomsHubDB.graphics = CopyTable(st.graphics or {})
    GloomsHubDB.migratedFromST = true

    GloomsHub:Print(("Copied the StoneTweaks media catalog — %d font%s, %d texture%s, %d graphic%s. StoneTweaks' own data is untouched.")
        :format(#GloomsHubDB.fonts,    #GloomsHubDB.fonts    == 1 and "" or "s",
                #GloomsHubDB.textures, #GloomsHubDB.textures == 1 and "" or "s",
                #GloomsHubDB.graphics, #GloomsHubDB.graphics == 1 and "" or "s"))
end

-- ============================================================
-- Back-compat shim — PERMANENT (see CONTRACTS §3)
-- Forwards the old StoneTweaks global to the Hub's resolver.
-- Nothing in the suite calls this any more (Overlays moved to
-- GloomsHub:ResolveAssetPath in Phase E gate A), so it exists
-- purely as insurance for anything stale outside the suite.
-- ★ KEPT PERMANENTLY by the owner's decision, 2026-07-24 (Phase F
-- step 6): one line, zero cost, proven working. Do not "clean it
-- up" — that decision is closed.
-- The guard matters: if StoneTweaks is ever re-enabled it defines
-- the real function at file load, which is before PLAYER_LOGIN,
-- so ST wins and this stays dormant.
-- ============================================================

local function InstallCompatShim()
    if not _G.StoneTweaks_ResolveAssetPath then
        _G.StoneTweaks_ResolveAssetPath = function(n) return GloomsHub:ResolveAssetPath(n) end
    end
end

-- ============================================================
-- Events
-- Media REGISTRATION happens at the Hub's own ADDON_LOADED — as early
-- as the saved catalog exists — so addons that load before us (they
-- all do; "G" is late in the alphabet) see the fonts before they
-- build their frames at PLAYER_LOGIN. Why, and what went wrong at the
-- old PLAYER_ENTERING_WORLD timing: the note above Media:RegisterAll.
-- The font load-CHECK stays at PLAYER_ENTERING_WORLD (FINDINGS §5).
-- ============================================================

local function EnsureDB()
    if not GloomsHubDB then
        GloomsHubDB = CopyTable(DB_DEFAULTS)
    end
    if not GloomsHubDB.fonts    then GloomsHubDB.fonts    = {} end
    if not GloomsHubDB.textures then GloomsHubDB.textures = {} end
    if not GloomsHubDB.graphics then GloomsHubDB.graphics = {} end
    if not GloomsHubDB.sounds   then GloomsHubDB.sounds   = {} end
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= "GloomsHub" then return end
        self:UnregisterEvent("ADDON_LOADED")
        EnsureDB()
        GloomsHub.Media:RegisterAll()

    elseif event == "PLAYER_LOGIN" then
        EnsureDB()   -- harmless repeat; keeps this block self-sufficient
        MigrateFromStoneTweaks()
        InstallCompatShim()
        GloomsHub:InitMinimapButton()   -- the ONE suite launcher (MinimapButton.lua)

    elseif event == "PLAYER_ENTERING_WORLD" then
        GloomsHub.Media:VerifyFonts()
        self:UnregisterAllEvents()
    end
end)

-- ============================================================
-- /gh — QA probe (catalog counts + migration flag). The Suite
-- window slash (/gloom) arrives with the tabbed shell.
-- ============================================================

SLASH_GLOOMSHUB1 = "/gh"
SlashCmdList["GLOOMSHUB"] = function()
    if not GloomsHubDB then
        GloomsHub:Print("Not initialized yet (before PLAYER_LOGIN).")
        return
    end
    GloomsHub:Print(("Catalog: %d fonts, %d textures, %d graphics, %d sounds. migratedFromST = %s.")
        :format(#GloomsHubDB.fonts, #GloomsHubDB.textures, #GloomsHubDB.graphics,
                #GloomsHubDB.sounds, tostring(GloomsHubDB.migratedFromST or false)))
end
