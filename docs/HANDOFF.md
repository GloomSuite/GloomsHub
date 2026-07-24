# Gloom's Hub — Session Handoff

**Last updated: 2026-07-24 — GloomsHub SCAFFOLDED (no code yet).**

## What exists
- `~/GloomsHub` — new git repo, symlinked into `…/Interface/AddOns/GloomsHub` (matches the
  GB/GA convention; remote will be `HandofDevastation/GloomsHub`).
- Docs (the home of record for the whole suite):
  - [SUITE-STATE.md](SUITE-STATE.md) — the phase ledger. **Read first for any suite work.**
  - [SUITE-PLAN.md](SUITE-PLAN.md) — architecture + 7-phase plan + locked decisions.
  - [CONTRACTS.md](CONTRACTS.md) — shared runtime contracts (tokens, tab API, resolver, LibGloomSkin).
- `GloomsHub.toc` — scaffold manifest, no Lua files listed yet.
- `CLAUDE.md` — this repo's guide; explains the home-of-record / anti-drift rule.
- GB & GA `CLAUDE.md` now carry a one-line "part of the Gloom Suite → GloomsHub" pointer.

## What does NOT exist yet
No Lua, no `Media/`, no `Libs/`, no runtime behavior. **Installing GloomsHub today does nothing
in-game.** That's expected — construction starts at Phase A.

## Next step
**Phase A** (see SUITE-PLAN §5): stand up GloomsHub media-only — font/graphic/texture
registration into LSM, `ResolveAssetPath`, the one-time non-destructive copy-migration from
`StoneTweaksDB` → `GloomsHubDB`, the `StoneTweaks_ResolveAssetPath` compat shim, and copy the
`Fonts/Textures/Graphics/` folders in. Touch nothing else. QA gate: `/reload`; GA's picker still
shows the media; `GloomsHubDB` has the registered fonts (DrukMedium et al.); Overlays still
render their graphics. Nothing removed.

## Reminders
- The owner QA's one copy-paste step at a time; verify before claiming; BugSack text first.
- New files/assets need a FULL CLIENT RESTART, not /reload.
- StoneTweaks stays installed until Phase F (its DB is the migration source; delete it LAST).
- **Gloom's Build Barn is OUT of the suite** — do not fold it in (cron/WarcraftLogs pipeline).
- Update [SUITE-STATE.md](SUITE-STATE.md) at the end of any session that moves the suite.
