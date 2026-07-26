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
- **★ READ THE ADDON LIST BEFORE YOU INSTRUMENT THE CLIENT.** On 2026-07-26 a session wrote a whole
  throwaway trap addon to find who was un-hiding GA's Cooldown Manager viewers; the answer was
  visible in an `ls` of the AddOns folder, and the trap never fired. **A test client's addon set
  drifts, and a fresh install of a modular UI suite enables every module** — the owner runs most of
  `EllesmereUI` off on retail, and the PTR copy came up with all ~20 modules on, including one that
  owns the exact frames we were debugging. **Check what else is installed before attributing a
  symptom to the game version.** Two of three symptoms that session had a competing addon sitting in
  the folder as the simpler explanation.
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
- **★ WoW's chat box truncates input at 255 characters — silently.** A `/run` one-liner longer than
  that arrives at the parser as a fragment and fails with a syntax error (`')' expected near '<eof>'`)
  that looks like YOUR bug, not a length limit. The tell is the `msg=` local in the error: it shows
  the string cut off mid-token. **Keep in-client one-liners well under 255**, and when a diagnostic
  genuinely needs more, write a throwaway addon instead of golfing the line down.
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
- **★ DISABLING an addon does not make its media missing.** Unchecking it in the addon list stops
  its Lua from loading; **the files stay on disk**, and WoW loads fonts, textures and sounds **by
  file path**, with no idea which addon they came from. A font inside a disabled addon resolves
  perfectly. **To test a missing-media path you must move or rename the FOLDER** — and then, for
  fonts, restart (see the exception above). Cost a wasted full client restart on 2026-07-26 when
  "disable NiceDamage and reload" was handed over as a repro step for a bug it could never trigger.
- **★ `SetFont` RAISES on a missing asset — it does not return false**, despite reading like it
  does (`Invalid font asset (…): file not found`, live 12.0.7, 2026-07-26). `if not
  fs:SetFont(path, …) then <fallback> end` is therefore **backwards**: the fallback never runs and
  the *enclosing function aborts mid-way*, skipping everything after it. Guard media setters with
  `pcall` and treat both a raise and an explicit `false` as failure.
  ⚠ **Storing a NAME instead of a PATH helps, but it does NOT make the dead-asset case go away —
  corrected 2026-07-26, having been written here as if it did.** Saving the LSM name is still the
  right call: an addon that was never installed never registered, so the lookup misses and the
  bundled fallback is a valid file. **But `lsm:Fetch(name, true)`'s silent-nil rescue only fires
  when the lookup MISSES.** Anything that registers a name for a file it never verified — including
  the Hub's own Media tab, which cannot verify, because WoW exposes no filesystem API — makes the
  lookup *succeed* and hand back a dead path. **The shape that actually predicts exposure is
  "builds a path out of saved data", and the catalog owner always does.** Guard the setter; don't
  rely on the resolver. See FINDINGS §5's `KILLED` list.
- **SavedVariables are written on logout, disconnect, quit AND `/reload`.** `/reload` is a genuine
  save point, so it is never a reason to restart.
- **★★ SECRECY PROPAGATES THROUGH STRING FORMATTING, AND SECRET VALUES VANISH ON SAVE.** On 12.1
  `UnitName("target")` is secret in combat. Format that name into a string and **the resulting
  string is secret too** — and the SavedVariables writer stores it as `["key"] = nil --[[ secret
  value ]]`, with no error and no warning. Proven 2026-07-26: GA's probe wrote 14 captures, and the
  header line of every in-combat one was simply *absent* from the file because it embedded the
  target's name. A grep keyed on that header counted 8 entries instead of 14 and produced a
  confident, wrong "your data didn't save."
  **Two rules follow:** never build a stored string out of anything that might be secret — store the
  parts separately and `issecret`-guard each; and **never conclude a table is missing from
  SavedVariables by grepping for one line inside it** — count the entries structurally.
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
- **`SetGradient` needs a real TEXTURE under it.** The pairing proven live in this client (12.0.7)
  is `SetTexture("Interface\\BUTTONS\\WHITE8X8")` **then** `SetGradient(dir, CreateColor(…),
  CreateColor(…))` — alpha in the colours is honoured, and `"VERTICAL"` runs **min at the BOTTOM**.
  ⚠ `SetColorTexture` + `SetGradient` was **NOT tested** — it was written that way first and swapped
  for the pattern other installed addons demonstrably use, rather than assuming. If you ever need to
  know, test it; don't infer it from this line.
- **Finding the proven pattern is a grep away.** `grep -rn "SetGradient(" --include="*.lua"` over
  `_retail_/Interface/AddOns` answered "what is this API's real signature on THIS client" in one
  command. **Other people's installed addons are a live reference for current API shapes** — better
  than memory, and current by definition.

---

## Git, GitHub & packaging

- **★★ NEVER write an absolute home path into a tracked file.** `/Users/<account>/…` carries the
  macOS account name, which on this machine **is the owner's real first and last name** — the exact
  thing the identity scrub existed to remove. Use `$HOME` or `~`. This happened on 2026-07-26 in a
  `.claude/settings.json` hook command, reached a public repo, and cost a full delete-and-recreate
  to purge. **Grep `/Users/` before committing anything that touches tooling config, scripts or
  hooks** — those are the files where an absolute path looks harmless.
- **★★ A scrub that greps file CONTENTS but not FILENAMES is not a scrub.** 2026-07-26: the identity
  scrub was recorded in CLAUDE.md as "✅ DONE and verified on fresh clones" — and it was, for text
  *inside* files and for commit metadata. Nobody ever listed the *paths*. A texture named after the
  owner's real first name sat in a public repo and inside every release zip from the repo's first
  commit, and the "verified" label is precisely what stopped anyone looking again. **Scan all four
  surfaces every time: file contents, file PATHS, commit metadata, and release assets.** One command
  does the paths: `git rev-list --objects --all | grep -i <term>`.
- **★ Assets a USER drops in must be gitignored on the day the directory is created.** The Hub's
  `Fonts/`, `Textures/` and `Graphics/` are drop-in directories for the user's own media; they were
  tracked instead, which shipped 65 personal files (~5 MB) — including a paid commercial font and
  the filename above — to anyone installing. **They were also useless to every recipient**, because
  the shipped catalog (`DB_DEFAULTS`) is empty, so nothing registered them. A directory whose
  contents are supplied by the user is never product.
- **★ A settled-sounding comment can weld a true rule to a false one, and then defend both.** The
  `.pkgmeta` note said "DO NOT add Fonts/, Textures/, Graphics/ or Media/ here — the committed assets
  ARE the product." That was true of `Media/` and false of the other three, and because it read as a
  decided matter, every later session honoured it. **When you write a "do not change this", name the
  ONE thing it protects and why** — a rule covering four things will be obeyed for the three it
  should never have covered.
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
  ⚠ **The same trap bites anything hooked to a REFRESH, not just to a setter.** The palette
  harvested colours from `colorSwatch`'s refresh — and consumers refresh their swatch on every live
  change, so one drag across the picker would have poured ~60 intermediate colours a second into a
  12-slot list and buried every real one inside a fifth of a second. **Before recording, counting or
  PERSISTING anything from a refresh path, ask what fires it during a drag.**
- **★ Provenance must be DERIVED, not stored.** "Where is this colour used?" looked like a field to
  save next to the value. It isn't: a harvest only ever learns what something IS, never what it
  stopped being, so a colour you moved away from keeps claiming its old element forever. Recomputing
  from live getters on demand cannot go stale. **Generally: if a fact is a VIEW of current state,
  compute it — the moment you cache it you own an invalidation problem nobody will remember.**
- **★ A getter bound to an editor control reports only the SELECTION.** One Recolor swatch that
  re-points at the selected aura can never describe the other thirty-nine. A tool owning many
  elements of one kind must expose an **enumerator over its own config**, which only it can write.
  Ask "is there one of these, or one per element?" before wiring a per-control getter — the answer
  differed between GA/Overlays (per element) and GB (per PROFILE, `GB.db.styleData`), and guessing
  it wrong sent a whole explanation the wrong way this session.
- **No self-arming "click twice" confirms.** Destructive actions use `UI.confirm`, which has a
  Cancel and an ESC.
- **★ A control that CHANGES THE SCREEN while it is open must not be modal.** The colour picker was
  first built like `nameDialog`/`confirm` — scrim, centred, fixed. The owner rejected it on sight
  (2026-07-26): dimming hides the very thing you are judging, and a fixed centre panel lands on top
  of it. **Three things follow, and they are a package:** no scrim · draggable · and it must close
  when its owner does, because non-modal is what makes an orphaned panel reachable at all.
  ⚠ **The scrim was also doing a SECOND job** — separating the panel from the tab beneath it, both
  being the same near-black navy. Remove it and you owe that job to something else (a rim).
- **★ Not every destructive action earns `UI.confirm`.** Right-click-to-remove on a palette swatch
  loses nothing and is undone by picking the colour again. A modal there would be worse than the
  mistake it prevents. The rule is for actions that **destroy work**, not for every removal.
- **Modals hide via `HookScript("OnHide")`, never from the button handlers** — that is the only path
  that catches the `UISpecialFrames` ESC close, which never runs our own code.
- **Bump `SKIN_NEEDS` in the SAME commit that first calls a newer LibGloomSkin widget.** Forgetting
  is the only way to defeat the version gate.
- **US spelling** in user-visible text ("Favorites", "color").
