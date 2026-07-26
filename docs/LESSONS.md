# Gloom Suite — LESSONS (durable traps, learned the hard way)

> **Curated, not appended.** These were extracted from a year of session records because they kept
> being re-learned. Every one cost real time at least once.
>
> **Read the section that matches what you're about to do** — not the whole file. If you add one,
> make it general enough to apply next time, and delete any entry that stops being true.

---

## ★ The one that generalizes: silence is not evidence

**When a subsystem is designed to degrade quietly, its silence is not a pass — go read the registry
directly.** Four separate incidents, all the same shape:

| What was silent | Why | The real test |
|---|---|---|
| `LSM:Fetch("font", name)` | Returns WoW's **default font** for a missing name | `LibStub("LibSharedMedia-3.0"):HashTable("font").<Name>` |
| A missing `LibCustomGlow` | Loaded with `LibStub(…, true)` (silent) and every call `pcall`-guarded → no glow, **no error** | `/dump LibStub("LibCustomGlow-1.0", true) ~= nil` |
| GA's 12.1 secret-value throws | Inside `pcall`s → **BugSack stayed completely clean while every display failed** | Probe and log the throw explicitly |
| An over-long `/run` command | WoW's chat box truncates at **255 chars** and `!BugGrabber` swallows the syntax error → the command appears to do **nothing at all** | Measure the command; prefer several short `/dump`s |

**Corollaries:**
- **A clean BugSack is not a pass.** Say what you expect to *see*, then check for it.
- **Absence of a slash command IS positive proof.** `/st` going dead proved StoneTweaks' code never
  loaded — stronger than the absence of its login print, and far stronger than mere silence.
- **Check the PREFIX on login lines, not the wording.** The Hub's "… skipped — already registered"
  is word-for-word identical to StoneTweaks'; ArcUI prints its own alarming-looking `SKIPPED` lines
  about something unrelated.
- **QA by forcing FAILURE, not by assuming success.** The version gate was proven by temporarily
  setting `SKIN_NEEDS = 99` and watching the tab vanish with the engine still running.

---

## Verification & evidence

- **Check what a tag POINTS AT, not just that it exists.** GB's published `v0.2.0` looked current
  and sat on a pre-Phase-C commit three phases stale.
- **A cross-cutting fact restated in a second repo WILL go stale.** Release state was copied into
  GB's `CLAUDE.md` + handoff and GA's handoff; all three were wrong within a day. **Point at the
  home of record; never copy the fact.**
- **Price a deferred item before you schedule it, not after you start it.** A backlog entry
  describes what someone once intended, not what it costs today. GB's modifier symbols read as
  "fiddly but approved" across three handoffs and hid a hard prerequisite (a bundled font
  containing the glyphs) that closed it in one exchange. **Being carried is itself a signal.**
- **A claim about how a NEW field behaves for EXISTING saved data is a claim about migration.**
  GB `v1.1.0` shipped a preset field that appeared to apply globally, because presets saved before
  it existed were silent on it and the renderer fell back to the working copy. The read path was
  right; the migration it implied was missing — and "it works for free" reached a handoff, a commit
  message and a release untested.

---

## Lua & tooling

- **`luac -p` does NOT catch an orphaned global.** Delete a block, leave a module-local that another
  function still calls, and it becomes a nil global — valid Lua, passes the syntax check, throws at
  runtime. After **any block deletion or rename**:
  ```
  luac -l F.lua | grep -oE '_ENV "[A-Za-z_][A-Za-z0-9_]*"' | sort -u
  ```
  Diff against a known-good revision; orphans appear as NEW globals.
  ⚠ **Only ADDED entries are signal.** Past ~255 constants the same read compiles to a different
  opcode form and the grep stops matching, producing false REMOVALS on large files.
- **A tab that throws during `build()` takes the WHOLE tab down, silently.** The shell builds a tab
  before showing it, so an error anywhere leaves the window open, the content blank and no tab
  highlighted. It looks like the addon is dead, not like one broken section.
- **macOS `sed` has no `\b`.** Verify identifier renames with a token count, and `luac -p` every
  touched file.
- **zsh does NOT word-split unquoted variables.** `for f in $files` passes the entire newline-
  separated list to the command as ONE filename — and prints a cheerful success line for every file
  while changing nothing. Use `while IFS= read -r f`. **Never trust a loop's own success echo;
  verify the content.**

---

## WoW client behaviour

- **`/reload` is enough, including for NEW files.** The old "new files → full client restart" rule
  is **RETIRED**; it cost the owner restarts he never needed.
- **★ ONE EXCEPTION — FONTS.** WoW loads font files at LAUNCH, so a new `.ttf` genuinely needs a
  full restart. The Media tab's Fonts warning is CORRECT — do not "fix" it.
- **Textures are NOT an exception** — verified 2026-07-25 by replacing two in place; a bare
  `/reload` picked up the new art, which is the harder case than a brand-new file.
- **SavedVariables are written on logout, disconnect, quit AND `/reload`.** `/reload` is a genuine
  save point, so it is never a reason to restart.
- **Hand-editing a SavedVariables file needs the client fully closed** — the in-memory copy
  overwrites the file at every save point. This is the one case that truly requires an exit.
- **WoW never reclaims a frame.** Pool and reuse them. A 3-second slider drag on a 19-overlay
  profile once parked ~3,400 dead frames for the session.
  ⚠ **A recycled frame arrives wearing its last occupant's settings** — reset everything applied
  *conditionally* at the top of the build, and show with `SetShown`, not `Hide`. **A hidden frame
  never runs its `OnUpdate`**, so a recycled slot can come back frozen.
- **Cold-start blank text:** WoW draws a cold (font file, size) pair blank the first time each
  session. `Skin.lua`'s `UI.WarmFonts` pre-warmer fixes it — **extend its pair list whenever a new
  UI font size appears.**
- **`/fstack`'s `<N>` prefix IS the frame level** — that's how you find the number to beat.

---

## Git, GitHub & packaging

- **★★ NEVER write an absolute home path into a tracked file.** `/Users/<account>/…` carries the
  macOS account name, which on this machine **is the owner's real first and last name** — the exact
  thing the identity scrub existed to remove. Use `$HOME` or `~`. This happened on 2026-07-26 in a
  `.claude/settings.json` hook command, reached a public repo, and cost a full delete-and-recreate
  to purge. **Grep `/Users/` before committing anything that touches tooling config, scripts or
  hooks** — those are the files where an absolute path looks harmless.
- **★★ A force-push does NOT purge — it only unlinks.** Old commits stay on GitHub and are served
  the instant the repo is public. The only reliable purge is **delete the repo and recreate it**.
  Re-proven 2026-07-26: after delete-and-recreate the offending SHA returned **422** while the repo
  was verifiably **public** (`"private": false`) and current commits returned **200** — that
  combination is the proof, because a 422 from a repo you have not confirmed is public proves
  nothing.
- **Never validate a purge from a private repo.** That endpoint 404s for *any* SHA while private, so
  a 404 proves nothing. Verify **unauthenticated against the PUBLIC repo** and expect **422**.
- **Published release ZIPs are a separate surface** a force-push cannot reach. After any history
  rewrite, download and grep the assets.
- **`git fetch --all --tags` before rewriting any repo that has automation writing to it.** Build
  Barn's cron commits and tags directly on GitHub; its remote was a fortnight ahead of the local
  clone, and force-pushing the stale copy rolled `main` back.
- **Recreating or pushing releases out of order breaks `latest`** — which is what WoWup installs.
  Always finish by checking `/releases/latest` **anonymously**; that endpoint caches, so re-read a
  stale answer before chasing it. Fix with
  `gh api -X PATCH repos/<owner>/<repo>/releases/<id> -f make_latest=true`.
- **Tags pushed in the same breath as an initial branch push can land before the workflow registers
  and silently trigger nothing.** Push the branch, confirm the workflow is `active`, then push tags.
- **The repo-transfer API is ASYNC and its response echoes the OLD `full_name`.** That is not a
  failure — verify by fetching the new path.
- **Never rename an org that has published releases.** A rename vacates the old name for anyone to
  claim, and a squatter inherits every redirect *and* the URLs already in people's WoWup installs.
  Create a second org and transfer.
- **Probe every external URL before a repo's first release.** GA's `LibCustomGlow` external was dead
  (the wowace SVN path 404s) and its first packaged build would have failed outright. The wowace
  front-end returns **301** for a project that exists and **404** for one that doesn't.

---

## Design & working with the owner

- **Group controls by what they DO to the thing, not by which engine function they call.** GB's icon
  tint first shipped beside the availability tints it shares an engine funnel with; the owner
  rejected it on sight — *"this belongs in Decoration Layers."* **Grouping by shared plumbing is the
  engine's logic leaking into the UI.** Worth auditing any tab that grew around its engine.
- **★ The owner's mock files render at ~2.5× the game's pixels.** When he gives a px number, convert
  it — or better, **ask for the RULE** (*"the stub should be about as tall as the label"*). A
  relationship survives a resize; a magic number doesn't.
- **He compares tabs by tabbing between them**, so cross-tab alignment beats internal alignment.
- **A half-width slider needs a half-width PARENT.** `UI.sliderRow` always spans its parent, so lay
  out column *frames*, not x offsets. *"So much horizontal width available, no point in stacking
  everything."*
- **Adding a slider is a NEW performance surface.** A typed box applies once on Enter; a slider
  applies ~60×/second while dragged. **Look at what a control's setter does per change before
  converting it.**
- **No self-arming "click twice" confirms.** Destructive actions use `UI.confirm`, which has a
  Cancel and an ESC.
- **Modals hide via `HookScript("OnHide")`, never from the button handlers** — that is the only path
  that catches the `UISpecialFrames` ESC close, which never runs our own code.
- **Bump `SKIN_NEEDS` in the SAME commit that first calls a newer LibGloomSkin widget.** Forgetting
  is the only way to defeat the version gate.
- **US spelling** in user-visible text ("Favorites", "color").
