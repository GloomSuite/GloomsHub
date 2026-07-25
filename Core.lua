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
}

function GloomsHub:Print(msg)
    print("|cff936bffGloom's Hub|r: " .. msg)
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
-- Back-compat shim (transition — see CONTRACTS §3)
-- Lets VibeOverlay keep resolving graphics once StoneTweaks is
-- gone. While ST is still installed its real function is already
-- defined by the time PLAYER_LOGIN fires, so the shim stays
-- dormant — exactly what Phase A wants.
-- ============================================================

local function InstallCompatShim()
    if not _G.StoneTweaks_ResolveAssetPath then
        _G.StoneTweaks_ResolveAssetPath = function(n) return GloomsHub:ResolveAssetPath(n) end
    end
end

-- ============================================================
-- Events
-- Media registration happens at PLAYER_ENTERING_WORLD (same
-- point StoneTweaks used — LSM is fully up by then).
-- ============================================================

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if not GloomsHubDB then
            GloomsHubDB = CopyTable(DB_DEFAULTS)
        end
        if not GloomsHubDB.fonts    then GloomsHubDB.fonts    = {} end
        if not GloomsHubDB.textures then GloomsHubDB.textures = {} end
        if not GloomsHubDB.graphics then GloomsHubDB.graphics = {} end
        MigrateFromStoneTweaks()
        InstallCompatShim()
        GloomsHub:InitMinimapButton()   -- the ONE suite launcher (MinimapButton.lua)

    elseif event == "PLAYER_ENTERING_WORLD" then
        GloomsHub.Media:RegisterAll()
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
    GloomsHub:Print(("Catalog: %d fonts, %d textures, %d graphics. migratedFromST = %s.")
        :format(#GloomsHubDB.fonts, #GloomsHubDB.textures, #GloomsHubDB.graphics,
                tostring(GloomsHubDB.migratedFromST or false)))
end
