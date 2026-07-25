# Gloom's Hub — project guide

> **▶ NEW SESSION: read [docs/HANDOFF.md](docs/HANDOFF.md) FIRST, then
> [docs/SUITE-STATE.md](docs/SUITE-STATE.md)** (where the whole suite effort stands right now).
> The design/architecture is in [docs/SUITE-PLAN.md](docs/SUITE-PLAN.md); the shared runtime
> contracts (tokens, resolver signature, tab API) are in [docs/CONTRACTS.md](docs/CONTRACTS.md).

## What GloomsHub is
The **shared base addon** for the Gloom suite. It owns three things nothing else may own:
1. **The one Suite window** — a tabbed shell. Gloom's Auras / Bars / Overlays each register a
   tab; the Hub also hosts the **Media** tab (custom fonts + graphics/textures).
2. **The shared design toolkit + tokens** (`GloomsHub.COLOR/.FONT/.UI`, and the embedded
   `LibGloomSkin-1.0` library). This is the ONE copy — GB/GA must stop hand-maintaining their
   own duplicate toolkits and consume this.
3. **The media plumbing** — custom font/graphic/texture registration into LibSharedMedia +
   `GloomsHub:ResolveAssetPath(name)` (salvaged from the retired StoneTweaks).

**Construction is underway** — the phase ledger in [docs/SUITE-STATE.md](docs/SUITE-STATE.md)
is the sole source of truth for what's built and QA'd; do not trust any other file's claim
about phase status (including this one).

## GloomsHub is the HOME OF RECORD for the whole suite ★ (anti-drift)
The suite spans separate repos (`~/GloomsAuras`, `~/GloomsBars`, `~/GloomsOverlays`), each
symlinked into `…/Interface/AddOns/`. Disparate repos drift. The rule that prevents it:

> **Every cross-cutting fact has exactly ONE home, here in `GloomsHub/docs/`. Other repos
> POINT at it; they never keep their own copy.**

- **[docs/SUITE-STATE.md](docs/SUITE-STATE.md)** — the phase ledger. "Where are we?" Read it
  FIRST for any suite work; UPDATE it at the end of any session that moves the suite.
- **[docs/SUITE-PLAN.md](docs/SUITE-PLAN.md)** — the architecture + 7-phase plan + locked
  decisions. Do not relitigate locked decisions.
- **[docs/CONTRACTS.md](docs/CONTRACTS.md)** — the shared runtime contracts (design tokens,
  the `RegisterTab` API, `ResolveAssetPath`, `LibGloomSkin` surface). If you change a shared
  contract, change it HERE and update every consumer in the same session.
- GB's, GA's and Overlays' `CLAUDE.md` carry a "part of the Gloom Suite" pointer back here.

## The family (and what's IN vs OUT of the suite)
- **IN:** Gloom's Auras (`~/GloomsAuras`), Gloom's Bars (`~/GloomsBars`), Gloom's Overlays
  (`~/GloomsOverlays` — the renamed VibeOverlay; repo created + symlinked in Phase E gate A,
  2026-07-24, reskin still owed). Each mounts a tab.
- **RETIRED:** StoneTweaks (its useful half — media registration — is absorbed here). StoneCast
  (already deleted).
- **OUT — do NOT fold in:** **Gloom's Build Barn.** It's a data-fed pipeline (a weekly cron on
  hodguild.com pulls WarcraftLogs talent builds via API into the addon), NOT a config-UI tool
  that would mount a tab. The owner explicitly excluded it (2026-07-24). Do not treat it as a suite
  member or future tab consumer.

## Conventions (inherited from the family — see SUITE-PLAN / CONTRACTS)
- Namespace `GloomsHub` → `_G.GloomsHub`; SavedVariables `GloomsHubDB`.
- Plain frames, plain SavedVariables, no Ace3. Libraries embedded under `Libs/` + pulled by the
  BigWigs packager via `.pkgmeta` externals; `Libs/` git-ignored.
- **Design language = the shared Gloom language** (bright purple `#936bff` on near-black navy,
  Khand titles + GeneralSans body, sliding switches, no native Blizzard chrome). GloomsHub is
  where those tokens now LIVE for the whole suite.
- Slash: `/gloom` opens the Suite window (neutral, last-used tab). Each tool keeps its own slash
  (`/gb`, `/ga`, `/go`) to open the window focused on its tab.

## Testing / release
Symlinked into the client at `…/Interface/AddOns/GloomsHub`. QA by the owner (non-dev): ONE
copy-paste step at a time, verify before claiming, BugSack error text first. New files/assets
need a full client RESTART (not /reload). Ships via BigWigs packager → GitHub Releases (repo
`HandofDevastation/GloomsHub`), WoWup installs/updates. GB/GA/Overlays will hard-depend on it
(`## Dependencies: GloomsHub`) once wired.

> The owner works structured & catalog-first; NEVER "v1"/"later phase" framing; GUI over slash for
> user controls; never rush toward closing a session. (Same working style as the sibling repos.)
