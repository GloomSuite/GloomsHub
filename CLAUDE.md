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

## ★★ ROUTE THE REQUEST BEFORE YOU DO THE WORK (the owner, 2026-07-25)
**The suite is ONE product at runtime but FOUR repos on disk, and every repo is in the session's
working directories — so a request aimed at the wrong repo can be silently fulfilled from the
wrong place. Do not let that happen. Route first, then work.**

> **THE RULE: before starting any change, decide which repo OWNS it. If that is not the repo this
> session is in, STOP and say so BEFORE editing anything. Name the repo the work belongs in, say
> in one line what it would touch, and let the owner decide whether to switch. Do not "just do it
> from here", do not make a partial edit first, and do not quietly edit across repos.**

The owner's words: *"if I make a request for a change/addition while working in one project that is
better suited for one of the other projects, actually tell me, so I can switch over and make the
request in the proper place."*

**Who owns what:**
| The change is about… | It belongs in |
|---|---|
| Action-bar skin, shapes/catalog, glows, layout, presets, GB's tab contents | `~/GloomsBars` |
| Cooldown-Manager auras, displays, GA's tab contents | `~/GloomsAuras` |
| Overlays engine, conditions, spritesheets, GO's tab contents | `~/GloomsOverlays` |
| The Suite window/shell + tab API · the shared toolkit `LibGloomSkin` (tokens, widgets, `UI.*`) · media registration/catalog/resolver + the Media tab · the ONE minimap launcher · the suite docs + phase ledger | **`~/GloomsHub`** (here) |
| Gloom's Build Barn | `~/Desktop/glooms-build-barn` — **NOT a suite member**, see below |

**Rough test:** *does it change how ONE tool looks or behaves?* → that tool's repo. *Does it change
something all three share, or the window they live in?* → here.

**Three carve-outs — these are correct, not violations:**
1. **Suite docs/ledger updates in `GloomsHub` from any suite session.** Required, in fact: any
   session that moves the suite updates SUITE-STATE here. Say you're doing it; don't ask permission.
2. **A shared-contract change and its consumers, in the same session.** If a `LibGloomSkin` or tab-API
   change lands, every consumer must be updated with it (see CONTRACTS) — multi-repo is the *point*.
   Still say up front which repos it will touch.
3. **Read-only cross-repo work** — grepping siblings for consumers, verifying a symbol, comparing a
   pattern. Look freely; the rule is about WRITING.

**If ownership is genuinely ambiguous** (e.g. a tool needs a widget that arguably belongs in the
shared toolkit), say so and give a recommendation — don't guess silently and don't stall.

## The family (and what's IN vs OUT of the suite)
- **IN:** Gloom's Auras (`~/GloomsAuras`), Gloom's Bars (`~/GloomsBars`), Gloom's Overlays
  (`~/GloomsOverlays` — the renamed VibeOverlay; migrated + reskinned in Phase E, 2026-07-24).
  Each mounts a tab; all three are live.
- **RETIRED:** StoneTweaks — **fully retired in Phase F, 2026-07-24**: disabled and its folder moved
  out of AddOns to `~/Desktop/StoneTweaks-retired-2026-07-24` (not deleted; `StoneTweaksDB` left in
  WTF, so rollback is moving it back). Its useful half — media registration — lives here now, and the
  Hub is the suite's only media registrar. `StoneTweaks_ResolveAssetPath` survives as a **permanent**
  one-line compat shim in `Core.lua` (CONTRACTS §3) — do not "clean it up". StoneCast (already deleted).
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
`HandofDevastation/GloomsHub`), WoWup installs/updates. GB/GA/Overlays all hard-depend on it
(`## Dependencies: GloomsHub`) as of Phase E.

## ⚠ PRIVACY — no real-world identity in any repo (2026-07-24)
The owner ships under the `HandofDevastation` org only. Neither his real name nor his personal
GitHub account handle may appear anywhere: not in file content, not in commit messages, not in
commit metadata.

- **Never write the owner's first/last name in docs, comments or commit messages.** Say "the
  owner", "the author", or just state the decision. The old convention of attributing decisions
  by first name is RETIRED — it put 300+ mentions across two then-public repos.
- **Never write his personal GitHub handle either.** The org is the public face; the account
  behind it is not. That account is what `gh` authenticates with, so it necessarily OWNS and
  PUSHES the repos — but it must never appear as a commit author, in a noreply email, or in any
  file. (Do not "helpfully" set the identity to a GitHub `…@users.noreply.github.com` address:
  those embed the handle.)
- Git identity is set globally to `Gloom <gloom@handofdevastation.invalid>` — matching the
  addons' `## Author: Gloom`, and a reserved-TLD address that is undeliverable by design and
  links to no account. Do not override it per-repo.
- **All five repos are PUBLIC as of 2026-07-24**, after the scrub finished — that is what makes
  the WoWup install/update path work. They were private only during the scrub. Changing any repo's
  visibility is still the owner's call, not a routine action.
- **The scrub is ✅ DONE (2026-07-24).** All five repos had history rewritten with
  `git-filter-repo` — file content, commit messages AND author/committer metadata — and were
  verified clean on fresh clones pulled back from GitHub. Full record + the two traps it hit
  (published release ZIPs are a separate surface; a repo whose cron writes to GitHub can be AHEAD
  of your local clone) are in [docs/HANDOFF.md](docs/HANDOFF.md) under TASK 0.
- **★ A force-push does NOT purge old commits from GitHub — it only unlinks them.** GloomsBars,
  GloomsAuras and GloomsBuildBarn had to be **deleted and recreated** to truly remove them; that is
  the only reliable purge. Verify a purge **unauthenticated against the PUBLIC repo** (expect
  **422**); a 404 from a private repo proves nothing. Full account in docs/HANDOFF.md.
- **The scrub backups were DELETED on 2026-07-24** at the owner's instruction, once all five repos
  were confirmed public, clean and in sync. No copy of the old identity remains on disk. There is
  therefore **no undo** for the history rewrite — which is fine, the rewrite is verified — but any
  future rewrite must take fresh backups first.

> The owner works structured & catalog-first; NEVER "v1"/"later phase" framing; GUI over slash
> for user controls; never rush toward closing a session. **QA as you go — do not build a large
> change across multiple addons and hand it over unverified.** (Same working style as the
> sibling repos.)
