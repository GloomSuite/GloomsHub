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
-- ★ The FIRST name, always: in Forever UnitName("player") is "First" alone,
-- and a key must not depend on which spelling it got.
local function firstName()
    local name = UnitName("player")
    return name and name:match("^%S+") or name
end
-- The FULL name. Retail: UnitName. Forever (TESTED 2026-11-20, the owner's
-- probe on a cold login): UnitName and UnitFullName give "Gloomriven" only;
-- GetUnitName(unit, true) and UnitPVPName give "Gloomriven Candlewick".
local function fullName()
    if not GloomsHub.IS_FOREVER then return UnitName("player") end
    local name = (GetUnitName and GetUnitName("player", true)) or (UnitPVPName and UnitPVPName("player"))
    if name and name ~= "" then return name end
    return UnitName("player")
end
GloomsHub.CharacterFullName = fullName
function GloomsHub.CharacterKeyName()
    if not GloomsHub.IS_FOREVER then return UnitName("player") end
    local name = firstName()
    if not name then return nil end
    -- The character's own ID (the GUID's tail) tells alts apart; it never changes.
    local guid = UnitGUID and UnitGUID("player")
    local tail = guid and guid:match("%-(%x+)$")
    return tail and (name .. " #" .. tail:sub(-4):upper()) or name
end
-- What a key built before 2026-11-16 used for the name (the first name alone
-- in Forever; identical to CharacterKeyName in retail). A tool that finds a
-- binding under the old key and none under the new adopts it ONCE — the first
-- character to log in — and drops the old key, so a later alt starts fresh.
function GloomsHub.LegacyCharacterKeyName()
    if not GloomsHub.IS_FOREVER then return UnitName("player") end
    return firstName()
end
-- The realm half of a character key. Retail: GetRealmName(). Forever: the realm
-- ID inside the player GUID ("Player-6921-03EC9540" → "6921"), because
-- GetRealmName() is "" for the WHOLE of a cold-login session there (TESTED
-- 2026-11-20: a 60 s wait for it never ended; a /reload has it at once) and a
-- key must be the same on both. The GUID is there at PLAYER_LOGIN in either.
function GloomsHub.CharacterRealm()
    local realm = GetRealmName()
    if not GloomsHub.IS_FOREVER then return realm end
    local guid = UnitGUID and UnitGUID("player")
    local id = guid and guid:match("^Player%-(%d+)%-")
    return id or ((realm ~= nil and realm ~= "") and realm or nil)
end
-- Bind this character once, under its current key, in a tool's binding table
-- (`tbl[key] = profileName`), adopting what older keys hold:
--   · the pre-2026-11-16 key (first name, no ID), and
--   · in Forever, any key with this character's name + ID but another realm
--     spelling — the realm NAME of a /reload session, or the EMPTY realm of a
--     cold login (both 2026-11-20) — preferring the one whose profile `valid`
--     accepts and, among those, the longest key (a named realm over an empty one).
-- The old keys are dropped. Returns the key. Retail: the legacy key IS the key,
-- the scan is Forever-only, so this is a no-op there.
function GloomsHub.AdoptCharacterBinding(tbl, sep, valid)
    local name, realm = GloomsHub.CharacterKeyName(), GloomsHub.CharacterRealm()
    local key = (name or "?") .. sep .. (realm or "?")
    if type(tbl) ~= "table" then return key end
    local best, bestKey
    local function consider(k)
        if k == key or tbl[k] == nil then return end
        local ok = (not valid) or valid(tbl[k])
        if ok and (not bestKey or #k > #bestKey) then best, bestKey = tbl[k], k end
    end
    consider(((GloomsHub.LegacyCharacterKeyName() or "?") .. sep .. (GetRealmName() or "?")))
    if GloomsHub.IS_FOREVER and name then
        local prefix = name .. sep
        for k in pairs(tbl) do
            if type(k) == "string" and k ~= key and k:sub(1, #prefix) == prefix then consider(k) end
        end
    end
    if bestKey then
        if tbl[key] == nil or not ((not valid) or valid(tbl[key])) then tbl[key] = best end
        -- drop every old spelling of this character
        tbl[bestKey] = nil
        if GloomsHub.IS_FOREVER and name then
            local prefix = name .. sep
            for k in pairs(tbl) do
                if type(k) == "string" and k ~= key and k:sub(1, #prefix) == prefix then tbl[k] = nil end
            end
        end
    end
    return key
end
-- The name a tool gives the profile it CREATES for a new character. Retail:
-- "Name - Realm", the convention since Auras. Forever: the full "First Last" —
-- one realm, so the realm says nothing, and the ID is bookkeeping for the key.
function GloomsHub.DefaultProfileName()
    local name = fullName()
    if not name then return nil end
    if GloomsHub.IS_FOREVER then return name end
    return name .. " - " .. (GetRealmName() or "?")
end
-- Forever: a profile a tool auto-named for this character before 2026-11-20
-- ("First - Realm", "First #ID - Realm", "First #ID - " or "First") is renamed
-- to the full "First Last" the first time that name is known (the owner: "I
-- just want it to be the character name"). Returns the new name when `cur` is
-- such a name and nothing else is called that yet, else nil. Retail: nil.
function GloomsHub.FullNameFor(cur, exists)
    if not GloomsHub.IS_FOREVER or type(cur) ~= "string" then return nil end
    local full = fullName()
    if not (full and full:find(" ", 1, true)) or cur == full or (exists and exists(full)) then return nil end
    local first, keyed = GloomsHub.LegacyCharacterKeyName(), GloomsHub.CharacterKeyName()
    if not (first and keyed) then return nil end
    if cur == first or cur:sub(1, #first + 3) == first .. " - " or cur:sub(1, #keyed + 3) == keyed .. " - " then return full end
    return nil
end
-- Is the full name known yet? Retail: always. Forever: fullName() above, which
-- may lag PLAYER_LOGIN by a moment, so a tool waits at most 10 s and then goes
-- on; only the NAME of a brand-new profile (or the rename of an auto-named one)
-- depends on it — the key never does (see CharacterRealm).
function GloomsHub.CharacterKeyReady()
    if not GloomsHub.IS_FOREVER then return true end
    local name = fullName()
    return name ~= nil and name:find(" ", 1, true) ~= nil and UnitGUID("player") ~= nil
end
function GloomsHub.WhenCharacterKeyReady(fn)
    if GloomsHub.CharacterKeyReady() then fn() return end
    local ticks, ticker = 0, nil
    ticker = C_Timer.NewTicker(0.2, function()
        ticks = ticks + 1
        if GloomsHub.CharacterKeyReady() or ticks >= 50 then ticker:Cancel(); fn() end
    end)
end

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
