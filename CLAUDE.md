# Gloom's Hub — the Gloom Suite's home of record

**This is the ONLY project folder the owner opens.** All four suite repos are already in this
session's working directories — `~/GloomsBars`, `~/GloomsAuras`, `~/GloomsOverlays` and this one.
Work on any of them from here. **Never tell him to close this project and open another one.**

---

## ★★ SESSION START — do this before anything else

**Read [docs/BACKLOG.md](docs/BACKLOG.md) and offer him the list.** Do not read anything else yet.
That is the entire cold start: this file loads automatically, the backlog is short, and together
they are enough to route any request.

Open the session roughly like this — items, repo, size, then the question:

```
Gloom Suite — N open items

  1. <title>          <repo>   <size / status>
  2. <title>          <repo>   <size / status>

Which one — or is there something else you'd rather do?
```

**Then, and only then, read that item's "Read first" list.** Every backlog entry names its repo and
its reading list precisely so you never have to load all four repos' documentation to find out what
a job needs. **Loading less is what keeps the things you do load in focus.**

If he raises something that isn't on the list, route it (below), read that repo's `CLAUDE.md`, and
get on with it. Add it to the backlog only if it survives the session unfinished.

---

## ★★ "DO THE HANDOFF RITUAL" — the closing sequence

**When the owner says "do the handoff ritual", he is closing the session.** It is an explicit,
standing instruction: run the whole checklist without asking permission for any step, including the
commit and the push. **"Do the handoff ritual and release"** adds the release cut.

The checklist lives in [.claude/skills/handoff-ritual/SKILL.md](.claude/skills/handoff-ritual/SKILL.md).
Invoke that skill; do not improvise from memory. In short it is: update the backlog · update
SUITE-STATE if settled state moved · update FINDINGS with evidence tags and strike anything
disproved · add durable traps to LESSONS · archive what closed · update the owning repo's own docs ·
commit and push every repo touched · then tell him in plain language what changed and where.

**He should never have to know which documents exist or what needs updating. That is your job.**

**You may also propose it.** If he swerves to something unrelated mid-session, say so plainly —
*"that's a different job; let's do the handoff ritual and start fresh"* — so the suggestion always
comes from you and he never has to sense when a session is full.

### ★★★ PROPOSING IT IS NOT PERMISSION TO RUN IT. WAIT FOR HIM TO SAY IT.

**Propose, then STOP and wait for an actual answer.** Only an explicit "do the handoff ritual" — or
an unmistakable equivalent — starts the checklist. **Silence is not agreement. Him continuing to
answer your questions is not agreement. Him not objecting to your plan is not agreement.** Do not
pre-commit to running it later ("after this step, we'll do the handoff") and then treat your own
announcement as the go-ahead.

⚠ **This rule exists because it was broken on 2026-07-26.** A session said "after this step,
whatever it says, we do the handoff ritual", got no objection, and ran all eight steps — **including
committing and pushing three public repos** — on inferred consent. The owner had not agreed and did
not want the session closed. Public commits are not cleanly undoable, and unwinding them means a
force-push, which the privacy section explains does not truly purge anything.

**The same goes for anything that closes or publishes on his behalf: commits, pushes, tags,
releases.** Editing docs mid-session is fine and often required — *committing* them is not, absent
the ritual or a direct ask. **Deciding the work is finished is his call, not a step you can
schedule.**

---

## ★★ ROUTE THE REQUEST — name the repo, don't switch projects

**Before any change, decide which repo OWNS it and say so. Then get his go-ahead and do it from
here.** The goal is that no cross-repo edit ever happens silently. It is **not** to make him move.

> "If I make a request for a change while working in one project that is better suited for one of
> the others, actually tell me." — the owner, 2026-07-25

**Naming the repo is the whole obligation.** Say it in one line, up front — not buried at the end of
a long reply — and wait for his answer rather than answering for him. The four-repo split exists so
**friends can install and update the tools independently**; it was never meant to dictate how he
works.

| The change is about… | It belongs in |
|---|---|
| Action-bar skin, shapes/catalog, glows, layout, presets, the Bars tab | `~/GloomsBars` |
| Cooldown-Manager auras, displays, the Auras tab | `~/GloomsAuras` |
| The overlay engine, conditions, spritesheets, the Overlays tab | `~/GloomsOverlays` |
| The Suite window + tab API · `LibGloomSkin` (tokens, widgets, `UI.*`) · media registration/resolver + the Media tab · the ONE minimap launcher · the suite docs | **`~/GloomsHub`** (here) |
| Gloom's Build Barn | `~/Desktop/glooms-build-barn` — **NOT a suite member. See the absolute rule below.** |

### ★★★ GLOOM'S BUILD BARN IS NEVER INCLUDED IN ANYTHING. EVER.

**GBB is never in scope. Not for sweeps, not for "all the addons", not for suite-wide changes, not
for cross-repo tidy-ups, not for release cuts — never.** It is a separate guild project under a
different org with its own release scheme and its own cadence. **Do not commit to it, do not tag it,
do not release it, do not add files to it, do not include it in any batch.** The only thing that
puts you in that repo is the owner *explicitly naming Build Barn* as the thing he wants worked on.

**"All the addons" means the four suite addons. It has never meant GBB.**

⚠ **This rule exists because it was broken on 2026-07-26.** A session doing a suite-wide font-licence
pass reasoned that because GBB bundles the same two font families, it "obviously" needed the same
licence files — and then, told to release "all of them", tagged and released it too. The routing
table already said GBB was not a suite member. **The reasoning was plausible and it was still wrong:
a shared *fact* about GBB is never a licence to act on it.** If GBB genuinely looks like it needs
something, **say so and stop** — do not do it.

**Rough test:** changes how ONE tool looks or behaves → that tool's repo. Changes something all
three share, or the window they live in → here.

**★ Before you WRITE to a sibling repo, read its `CLAUDE.md` first.** This is the one real cost of
working from a single project: that repo's conventions and frozen decisions do not load
automatically, and they are exactly the walls that stop you relitigating something settled. For a
substantial job, read its handoff too — the backlog entry tells you which.

**No permission needed for:** updating the suite docs here from any session (that's required, just
say you're doing it) · a shared-contract change plus its consumers in one pass (say which repos up
front) · any read-only cross-repo grepping. **Ambiguous ownership?** Say so and recommend — don't
guess silently, don't stall.

**A separate session is worth it for exactly one shape:** deep design work inside ONE tool that
leans on that tool's own frozen decisions. The Auras `AuraContainer` migration is the example.
Swapping art, adding a TOC line or changing a shared widget is not that.

---

## The document set — read only what the job needs

| File | What it answers | When to read it |
|---|---|---|
| [docs/BACKLOG.md](docs/BACKLOG.md) | What's open? | **Every session, first.** |
| [docs/SUITE-STATE.md](docs/SUITE-STATE.md) | Where do things stand? Settled facts only. | Before changing anything structural. |
| [docs/FINDINGS.md](docs/FINDINGS.md) | What's suspected but unproven? | Any bug or 12.1 work. |
| [docs/LESSONS.md](docs/LESSONS.md) | What traps have already cost us? | The section matching the task. |
| [docs/CONTRACTS.md](docs/CONTRACTS.md) | The shared runtime contracts. | Touching `LibGloomSkin`, the tab API or the resolver. |
| [docs/SUITE-PLAN.md](docs/SUITE-PLAN.md) | The architecture and why. | Rarely — the plan is complete. |
| [docs/ARCHIVE.md](docs/ARCHIVE.md) | How did we get here? | Almost never. Only for the reasoning behind a settled decision. |

**Every cross-cutting fact has exactly ONE home, here in `docs/`. Other repos POINT at it; they
never keep their own copy.** A restated fact goes stale — release state was copied into three
sibling docs and all three were wrong within a day.

**★ Evidence tags are mandatory in FINDINGS:** `TESTED` (says how and when) · `OBSERVED` (symptom
seen, cause unproven) · `SUSPECTED` (reasoning only) · `KILLED` (disproved, struck by name, never
deleted). **You may not build a fix on an `OBSERVED` or `SUSPECTED` claim without establishing it
first.** On 2026-07-26 a session came within one step of fixing a bug that did not exist, because
the ledger recorded two suspicions in the same confident voice as its measurements.

---

## Working agreements

1. **QA as you go. Do NOT build a mountain and hand it over.** Design check-ins are not
   verification. Get something on screen early, then iterate.
2. **QA is ONE copy-paste step at a time**; verify before claiming; **ask for BugSack text first**.
   The owner is not a developer.
3. **★ A clean BugSack is not a pass.** Say what you expect to *see*, then check for it. See the
   "silence is not evidence" section of [docs/LESSONS.md](docs/LESSONS.md) — it has cost real time
   four separate times.
4. **★ `/reload` is enough, including for NEW files.** The old "new files → full client restart"
   rule is RETIRED; it cost him restarts he never needed. **The one exception is FONTS** — WoW loads
   them at launch, so a new `.ttf` needs a real restart. Textures do not. SavedVariables are written
   on `/reload`, so they are never a reason to restart either.
5. **GB is the UI reference for the suite, not GA.**
6. **US spelling** in user-visible text ("Favorites", "color").
7. **Never rush toward closing a session.** He works structured and catalog-first.

---

## Conventions

- Namespace `GloomsHub` → `_G.GloomsHub`; SavedVariables `GloomsHubDB`.
- Plain frames, plain SavedVariables, **no Ace3**. Libraries embedded under `Libs/` and pulled by
  the BigWigs packager via `.pkgmeta` externals; `Libs/` is git-ignored.
- **Design language:** bright purple `#936bff` on near-black navy, Khand titles + GeneralSans body,
  sliding switches, no native Blizzard chrome. The tokens LIVE here, in `Skin.lua`.
- Slash: `/gloom` opens the Suite window on the last-used tab. Each tool keeps its own (`/gb`,
  `/ga`, `/go`) to open focused on its tab.
- Symlinked into the client at `…/Interface/AddOns/GloomsHub`. Ships via the BigWigs packager →
  GitHub Releases → WoWup.

---

## ⚠ PRIVACY — no real-world identity in any repo

**The owner ships under GitHub orgs only, never a personal account. Neither his real name nor his
personal GitHub handle may appear anywhere** — not in file content, not in commit messages, not in
commit metadata.

**Two orgs — know which is which:**
- **`GloomSuite`** owns the four suite repos. This is the suite's home and the org friends install
  from.
- **`HandofDevastation`** is the GUILD's org: the guild website + `GloomsBuildBarn`.

The suite is his work, not the guild's, and guild membership may not be permanent — so publishing it
under the guild's name would age badly. Build Barn genuinely IS a guild project, so it stayed.
**Both orgs have PRIVATE membership, and that is what keeps the personal account unlinked. It must
stay that way on both.**

- **Never write his first or last name** in docs, comments or commit messages. Say "the owner" or
  just state the decision. Attributing decisions by first name is a RETIRED convention — it put
  300+ mentions across two then-public repos.
- **Never write his personal GitHub handle either.** That account necessarily owns and pushes the
  repos, but must never appear as a commit author, in a noreply email, or in any file. **Do not
  "helpfully" set a git identity to a `…@users.noreply.github.com` address — those embed the
  handle.**
- Git identity is global: `Gloom <gloom@handofdevastation.invalid>` — a reserved-TLD address that is
  undeliverable by design and links to no account. **Do not override it per-repo.**
- All five repos are **PUBLIC**, which is what makes the WoWup path work. The identity scrub is
  ✅ **DONE** and verified on fresh clones. **The scrub backups were deleted, so there is no undo —
  any future rewrite must take fresh backups first.**
- **★ A force-push does NOT purge old commits from GitHub — it only unlinks them.** The only
  reliable purge is delete-and-recreate. Verify **unauthenticated against the PUBLIC repo** and
  expect **422**; a 404 from a private repo proves nothing.
