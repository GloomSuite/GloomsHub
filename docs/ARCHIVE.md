# Gloom Suite — ARCHIVE

> **History. Not current state, and not a to-do list.**
>
> This file exists so that finished work can be *recorded in full* without bloating the documents
> that get read every session. Nothing here is authoritative about how things are today — if this
> file and [SUITE-STATE.md](SUITE-STATE.md) disagree, SUITE-STATE wins.
>
> **You almost never need to read this.** Come here only when you need the reasoning behind a
> settled decision, or the full detail of how something was verified. The durable, reusable traps
> have been extracted into [LESSONS.md](LESSONS.md) — read that instead.
>
> **Where the live documents are:**
> [BACKLOG.md](BACKLOG.md) (what's open) · [SUITE-STATE.md](SUITE-STATE.md) (where things stand) ·
> [FINDINGS.md](FINDINGS.md) (what's suspected) · [LESSONS.md](LESSONS.md) (traps) ·
> [CONTRACTS.md](CONTRACTS.md) · [SUITE-PLAN.md](SUITE-PLAN.md)
>
> Newest records first. Everything below was true when written.

---

# SESSION RECORD — 2026-07-26 evening (PII purge + the SetFont guard — backlog items 4 and 5, closed)

**Started as two small robustness items and turned up a privacy breach.** Both backlog items closed;
one release-blocking problem was found and fixed along the way.

## Item 4 — the false `SetFont` guard. It was NOT a tidy-up.
The backlog and FINDINGS §5 both said exposure was probably low, reasoning that GB and the Hub store
an **LSM name** rather than a path, so a miss falls back to a bundled file. **That reasoning was
wrong, and it was the entire basis for deferring the item.** It holds for the *tools* and fails for
the *Hub*, which is the catalog OWNER and therefore builds paths out of saved data. Three live
routes, all closed and owner-QA'd — full detail and the `KILLED` entry are in FINDINGS §5. The worst
of them: warming runs before registration inside `RegisterAll` and its PEW call site is not
`pcall`-ed, so **one bad catalog entry aborted the whole thing and neither fonts nor textures reached
LibSharedMedia**. Fixed by making `UI.setFont` `pcall` and return success (lib **MINOR 5**), adding
`GB.SetFontSafe`, and bumping GB's `SKIN_NEEDS` to 5 in the same commit.

QA that proved it: a deliberately broken catalog entry (`ZZ Broken Test` → a filename that does not
exist) produced the named warning **and** the `Registered 2 fonts and 6 textures` line, which before
the fix could not have appeared at all.

## Item 5 — the force-taint. Closed with no action.
Tested through the strongest path available: a dead LSM font applied to GB's keybind text, driving a
dead path through `SetFontSafe` across all 116 buttons, then combat on a dummy with keybinds and
stance swaps. **No blocked actions, no errors.** Recorded honestly in FINDINGS §6 — the taint was
never confirmed to have fired (that needs `taintLog`), so this is "no consequence demonstrated", not
"proven inert."

## ★★ The privacy breach — found while auditing what ships
A question about whether the addons ship baked-in presets or media exposed that the Hub's `Fonts/`,
`Textures/` and `Graphics/` — the user's **drop-in** directories — were tracked in git and shipped in
every release zip: **65 files, ~5 MB**, including a paid commercial font and **one texture whose
filename was the owner's real first name**, public since the repo's first commit.

**They were also inert for every recipient**, because `DB_DEFAULTS` ships an empty catalog, so
nothing registered them. A `.pkgmeta` comment had been instructing every session to keep shipping
them, on grounds that were true of `Media/` and false of the other three.

Purged with `git-filter-repo`, repo deleted and recreated, verified **unauthenticated**: old commit
**422**, blob **404**, raw path **404**, repo itself **200** (public, so the negatives mean
something). Backups first, at `~/Desktop/gloom-pii-backup-2026-07-26`. The files remain on the
owner's disk, gitignored, so his own catalog resolves normally. Both releases carrying the file died
with the repo. **The durable lesson — a scrub that greps contents but not FILENAMES is not a scrub —
is in LESSONS.**

Font licence files (`OFL.txt` + `FONT-LICENSES.md`) were added to all four repos that ship fonts.
All four suite addons were then squared up at **`v1.2.0`** at the owner's request — a one-time sync,
not a new rule.

---

# SESSION RECORD — 2026-07-26 (the GA font crash — backlog item 2, closed)

**One session, one backlog item, fixed and QA'd.** GA's `Displays.lua:379` guarded a font
assignment with `if not fs:SetFont(...) then <fallback> end`, which assumes `SetFont` returns false
on a bad asset. It raises. The fallback never ran and `ApplyConfig` aborted mid-function.

### What shipped
`GA.SetFontSafe(fs, path, size, flags)` in `Core.lua` — `pcall`s the set, treats a raise **or** an
explicit `false` as failure, returns a boolean. A `nil` return counts as success, so a working font
never triggers a pointless fallback. Applied at **three** sites carrying the same wrong guard:
`Displays.lua:379` (aura label), `Displays.lua:238` (bar value text), `Core.lua:66` (`PreloadFonts`).

### How it was verified, and how far that goes
In-client on live 12.0.7, via `/run`:
- `pcall(fs.SetFont, fs, "<dead path>", 14, "")` → `false — Invalid font asset (…): file not found`.
  **This is the proof that `SetFont` raises**, re-established today rather than carried from the
  PTR incident that first found it.
- `GA.SetFontSafe(...)` on the same path → `false`, no error escaping.
- The two-line fallback shape → `FONT: Fonts\FRIZQT__.TTF 20`, proving a usable font actually lands.
  This mattered structurally: both font strings are created bare via `CreateFontString(nil,
  "OVERLAY")` with **no template and so no inherited font**, meaning a failed fallback leaves the
  text fontless rather than merely ugly.

**Only the label path is `TESTED` end to end.** The bar value text and `PreloadFonts` use bundled
fonts that ship with the addon; nothing short of deleting our own media would exercise them, so they
are **fixed by inspection** and were recorded that way rather than folded into the tested claim.

### Two wrong beliefs killed on the way (both are in FINDINGS §2)
1. **"Three external addons trigger this."** Only one could. The SavedVariables has exactly one
   `["font"]` key; the other two references are `.ogg` **sounds**.
2. **"Disable NiceDamage and reload to reproduce."** Impossible — disabling an addon leaves its files
   on disk and WoW loads fonts by path. **This was handed to the owner as a QA step and cost him a
   full client restart for nothing.** Promoted to LESSONS.

### Left open, deliberately
The same false guard exists in `~/GloomsHub/Skin.lua:70` (`UI.setFont`, the shared toolkit) and in
GB — but both resolve fonts by **LSM name** with a bundled fallback, so their exposure is much lower
than GA's, which stored raw paths. Recorded as backlog item 4 rather than fixed silently in two
sibling repos. A `ForceTaint_Strong` seen alongside the font error became item 5, `OBSERVED` only.

---

# SESSION RECORD — 2026-07-26 (the working-process rebuild)

**The owner asked for the WORKING PROCESS to be reconsidered, not the architecture.** He was
explicit that the repo count is not the problem — *"I don't care how many repos there are, that's
not something I deal with."* Three things were: switching VS Code projects per repo, having to
remember which documents needed updating at the end of a session, and knowledge going stale between
repos. The trigger was the previous day's near-miss, where a confidently-recorded finding was wrong
and would have produced a fix for a bug that did not exist.

### What was true, and what was invented
**★ The per-repo session rule was never a technical constraint.** All four repos already listed each
other in `.claude/settings.json` `additionalDirectories`, so any session could always read AND write
all four. The rule was a convention that got written into four `CLAUDE.md` files and then treated as
a capability boundary. **The only thing switching projects ever bought was the right `CLAUDE.md`
loading automatically** — which is now handled by an explicit read-the-repo's-guide gate instead.

**★ The Hub's own CLAUDE.md already contained the correct rule and the wrong one, in that order.**
"ROUTE THE REQUEST" (stop and switch) sat directly above a block recording the owner's objection to
exactly that, which said *"'Just do it from here' is a valid answer EVERY time."* A model reading
top-to-bottom hit the STOP first. Merged into one rule: name the owning repo, get a go-ahead, work
from wherever you are.

### The doc restructure — split by how a document is USED
Cold start went from **~136 KB to ~15 KB**. The driver was not context capacity (the window is 1M)
but attention: a 573-line ledger is never re-read, and **a document nobody re-reads is a document
nobody corrects**. Two pieces of rot were sitting in plain sight — a "Packaging traps" section
carried twice, and the Overlays logo question listed as open on one line and closed seven lines later.

- **BACKLOG.md** — the four open items, each with its repo and an explicit "Read first" list. This
  is the whole cold start; the rest loads only once the owner picks.
- **FINDINGS.md** — diagnosis, separated from settled state, because a guess written beside a fact
  inherits the fact's authority. Tags: `TESTED` / `OBSERVED` / `SUSPECTED` / `KILLED`. **No fix may
  be built on an unproven claim without establishing it first.**
- **LESSONS.md** — durable traps curated out of the session records instead of buried in them.
- **SUITE-STATE.md** — 572 → 128 lines, settled facts only.
- **HANDOFF.md → ARCHIVE.md**, kept whole. GB's handoff split 1,689 → 343, GA's 1,100 → 521.

### ★★ TWO REAL FAILURES THIS SESSION, both worth keeping
1. **An absolute home path was written into `.claude/settings.json` and pushed to a public repo.**
   `/Users/<account>/…` carries the macOS account name, which **is the owner's real first and last
   name** — the exact thing TASK 0 existed to remove. Cost a full delete-and-recreate of GloomsHub,
   because a force-push only unlinks. **Grep `/Users/` before committing anything that touches
   tooling config, scripts or hooks.** Full rule in LESSONS.
   ★ A **full-history audit of all five repos** for both the name and the personal handle was run at
   the same time: the handle has **never** appeared anywhere, in any blob, message or metadata.
2. **`SUITE-STATE` was given the wrong version for GB — while being rewritten to prevent exactly
   that.** It said `v1.1.1`; GB had shipped `v1.1.2`. The number was carried forward from the
   previous file instead of checked. All four are now verified against `/releases/latest`
   anonymously. **The structure does not fix the habit; "verify, don't copy" has to come with it.**

### What was NOT done
- ~~**`UNVERIFIED`: the `SessionStart` hook has never been observed firing.**~~ **`TESTED`
  2026-07-26** — the owner opened a fresh session in this project, typed only "Hello, let's begin",
  and it opened with the four-item backlog and the "which one?" question. The greeting works on a
  cold start.
  ⚠ **Still `UNPROVEN`: WHICH mechanism produced it.** The hook and `CLAUDE.md`'s session-start
  section both instruct the same behaviour, and the two were not isolated. So the *outcome* is
  verified; the hook itself is not independently confirmed. This does not matter in practice — the
  redundancy is deliberate — but do not cite it as proof the hook fires. **If a session ever fails
  to open with the backlog, that ambiguity is where to start looking.**
- No VS Code multi-root workspace. Considered and dropped: it buys a file-explorer view the owner
  rarely needs, and plain `~/GloomsHub` already reaches all four repos.

# SESSION RECORD — 2026-07-25h (modifier symbols DROPPED · GB's icon tint · `GloomsBars v1.1.0` → `v1.1.1`)

**Two outcomes: the backlog was emptied, and a new GB feature shipped from a cold question.** All GB
work was done in `~/GloomsBars`, correctly routed; what lands HERE is the ledger tick, the release
fact and this record.

### The release — the suite's FIRST intentionally drifted version
**`GloomsBars v1.1.1`; the other three stay at `v1.0.1`.** That is the versions-may-drift decision
working as designed, not an oversight — only GB changed. **Nothing in the Hub changed: no new widget,
no MINOR bump (LibGloomSkin stays at 4), no consumer gate moved.**
⚠ **`v1.1.0` shipped the feature with a real bug** — a new preset field appeared to apply GLOBALLY
because presets saved before it existed are silent on it, and the renderer falls back to the working
copy. The owner caught it within minutes; `v1.1.1` backfills the field into every saved preset.
**The trap generalizes to every future preset field in any tool with snapshot-style presets — GB's
SESSION 17 PART C is the record.** ★ Lesson: *a claim about how a NEW field behaves for EXISTING saved
data is a claim about migration.* The read path was correct; the data migration it implied was missing,
and "it works for free" went into a handoff, a commit message and a release without being tested.

### The new feature (GB's repo owns the detail — see its SESSION 17)
**Config → Decoration layers → ICON TINT**: Off / Wash / Tint + colour + a 0–100% Strength slider.
Two things worth stealing for the other tools:
- ★ **Group controls by what they DO to the thing, not by which engine function they call.** The block
  first shipped under *Cooldown & availability*, beside the availability tints it shares an engine
  funnel with. The owner rejected it on sight — *"this belongs in Decoration Layers. What a weird
  choice."* He is right, and it generalizes: grouping by shared plumbing is the engine's logic leaking
  into the UI. **Worth a check in any tab that grew around its engine.**
- ★ **Two verified 12.0.7 client facts**, both read off Blizzard's source on disk rather than guessed:
  textures carry a **float** `SetDesaturation(0.5)` (not just the boolean `SetDesaturated`) — used by
  Blizzard in `Blizzard_RuneforgeModifierSlot.lua:150`, and **do not confuse it with the legacy global
  `SetDesaturation(tex, bool)` shim at `UIParent.lua:546`**; and WoW has exactly **five blend modes**
  (`DISABLE` · `BLEND` · `ALPHAKEY` · `ADD` · `MOD`, per `Blizzard_SharedXML/UI.xsd:43-51`), of which
  the client really only uses ADD, BLEND and a handful of MOD.

### Tooling caveat (for whoever codes next — not a project fact)
The `_ENV` global-read diff promoted by GA's and GO's sessions reports **false REMOVALS on large
files**: past ~255 constants the same global read compiles to a different opcode form and the grep
stops matching it. **Only ADDED entries are signal.** Still worth running — it is what proved the
moved UI block's helpers were in scope.

---

## The modifier symbols: reviewed, priced, DROPPED

**Suite to-do item 3 is CLOSED as WON'T DO, and with it the whole backlog.** No code changed for this
part; it was a decision, and the docs now record it. The owner asked for a read on the approach
*before* any coding — which is what surfaced the cost.

- **The owner's call:** *"Leave the glyphs untouched. It's a 'juice isn't worth the squeeze'
  situation. I can deal with no stroke/dropshadow on the glyphs."* **Do not re-propose this**, and do
  not quietly "fix" it while working on keybind text. Full reasoning is on **GB's handoff item (d)**,
  the home of record.
- ★ **The item had an unstated hard prerequisite that three sessions of handoff notes never priced.**
  It read as "fiddly but approved" — a second FontString in a glyph font. But that needs a bundled
  font *containing* U+2318/21E7/2303/2325; GB bundles Khand + GeneralSans, both Latin display faces
  that lack all four. So the "approved path" actually meant shipping a **new `.ttf`** — the suite's one
  genuine full-restart case — plus a licensing question, on top of duplicating the entire keybind
  styling and re-assert surface on a parallel FontString.
- ★★ **The transferable lesson: price a deferred item before you schedule it, not after you start it.**
  A backlog entry describes what someone once intended, not what it costs today. Reading the actual
  code first turned a planned session into a one-exchange close. **Worth doing for any item that has
  been carried across more than a couple of handoffs** — carrying is itself a signal.
- **If it is ever reopened** (it shouldn't be, absent a new reason): the cheap route is the texture
  layer, not a FontString — bake outline variants + a black silhouette in GB's
  `tools/generate-modglyphs.py` and emit two inline textures per modifier via the escape's x/y offset
  args. No new font, no restart. Costs: an explicit height (losing `:0` auto-line-height) and a
  **shadow colour baked black**, since inline textures take no tint.

~~Overlays' sliders~~ — **✅ DONE + QA'd 2026-07-25**, and ticked off in
[SUITE-STATE.md](SUITE-STATE.md) (to-do item 2, where the full record lives). It landed with no
`SKIN_NEEDS` bump and no Hub change, exactly as this section predicted. Session record below.

# SESSION RECORD — 2026-07-25g (Overlays' sliders — done in `~/GloomsOverlays`)

**Suite to-do item 2 is CLOSED.** The work was GO's and was done in GO's repo, correctly routed;
what lands HERE is the ledger tick and this record. **Nothing in the Hub changed — no new widget,
no MINOR bump, no gate move.** Full detail is on the item in [SUITE-STATE.md](SUITE-STATE.md);
what follows is what other tools should steal.

- **Slider + typed box, with no lib change.** `UI.sliderRow` parks a read-only value FontString at
  its TOPRIGHT; pass a `fmt` that returns `""` and drop a `flatEditBox` into that slot, and the box
  becomes both readout and input. Typed values clamp into the slider's range, so the two can never
  disagree about what is stored. **If GB or GA ever wants the same shape, copy this before
  proposing a `UI.numberRow`** — it costs nothing and needs no MINOR.
- **★ A half-width slider needs a half-width PARENT.** `sliderRow` always spans its parent (fixed
  18px insets), so lay out column FRAMES, not x offsets — anchored to the pane's `TOP` so they
  split whatever width the shell hands over. Same trick seats a button pair beside a slider
  instead of under it. The owner, 2026-07-25: *"so much horizontal width available, no point in
  stacking everything."* Worth remembering when a tab feels cramped: it usually isn't.
- **★★ ADDING A SLIDER CAN EXPOSE A PERFORMANCE BUG A TYPED BOX HID.** A box applies once, on
  Enter; a slider applies ~60×/second while dragged. Overlays' apply path rebuilt **every** live
  overlay frame per change, and **WoW never reclaims a frame** — a 3-second drag on a 19-overlay
  profile parked ~3,400 dead frames (each with a unique global name) for the rest of the session.
  Rotation and Alpha had been doing this since Phase E; nobody noticed because nobody profiled a
  drag. The owner's call was *"fix this right now… I don't want to squander any more overhead than
  is necessary"*. **Before converting a control to a slider anywhere in the suite, look at what its
  setter does per change.**
- ⚠ **The fix — a frame POOL — has one trap: a recycled frame arrives wearing the last occupant's
  settings.** Everything applied *conditionally* must be explicitly reset at the top of the build
  (the OnUpdate animation, the texture, its texcoord, its rotation), and the frame shown with
  `SetShown`, not `Hide` — a recycled slot can come back hidden, and **a hidden frame never runs
  its OnUpdate**, so a spinning overlay would sit frozen.
- **★ The `luac -l … _ENV` global-read diff caught a real defect this session**, exactly as the GA
  session promised it would. Renaming an engine function left one stale call in another file;
  `luac -p` passed it happily (an undefined global is valid Lua) and it would have thrown the
  moment the owner clicked a nudge arrow. **Run the diff after any rename or block deletion**, not
  just after deletions.
- **Also landed, unplanned:** the owner asked whether WoW's 7 stratas were a Blizzard limit. They
  are — the list is fixed and cannot be extended — but **frame LEVEL is a numeric z-index within
  a strata**, and Overlays exposed none of it (every overlay drew at the same level, so strata was
  the only separation it had). The tab now offers **all NINE** stratas (`WORLD` and
  `FULLSCREEN_DIALOG` were missing; the latter is referenced 5× more often than `FULLSCREEN` across
  the client's other addons) plus a Level row. ★ **`/fstack`'s `<N>` prefix IS the frame level** —
  that is how you find the number to beat; corroborated in the owner's own screenshot, where
  `UIParent` reads `<0>` and a live overlay reads `<1>`.

# SESSION RECORD — 2026-07-25f (the modal scrim + the housekeeping sweep)

**A small, entirely in-repo session. Everything below is DONE and QA'd by the owner.** The polish
backlog is now down to **two items, both in sibling repos** — Overlays' sliders and GB's modifier
symbols. Nothing is in flight here.

### The modal scrim (`Skin.lua`) — the item left open by the Auras session
Both dialogs are plates in the **same near-black navy as the panel they open over**, so they read as
part of the tab rather than on top of it. One shared scrim now serves both: full-screen black on
`FULLSCREEN_DIALOG` at the dialog's own level **−5**, so it dims the shell (which sits on `DIALOG`)
and never the dialog itself.

- ★ **It eats clicks, and that is the point** — `EnableMouse(true)` is what makes these genuinely
  modal rather than merely on top.
- ★ **Clicking the scrim does NOT dismiss.** Deliberate: the family answer is always an explicit
  OK / Cancel / ESC. A click-elsewhere that silently drops a typed name is the same class of trap as
  the self-arming "Sure?" button the suite already retired.
- ★ **Hidden via `HookScript("OnHide")` on both dialogs, NOT from the button handlers.** That is the
  only path that catches the **`UISpecialFrames` ESC close**, which never runs our own code — wire a
  scrim from the OK/Cancel handlers and ESC leaves it stuck on screen over a hidden dialog.
- **Alpha: 0.72.** The first pass shipped 0.55 and the owner asked for more.
- ★ **No MINOR bump** — internal behavior, no new API, so no consumer's `SKIN_NEEDS` moved. The lib
  stays at **MINOR 4**. Worth noting as the shape of a change that correctly does *not* touch the gate.

### Housekeeping — the backlog's whole small section, closed
- **`test-remove` graphic** — removed by the owner in the Media tab. The last StoneTweaks inheritance
  is out of the catalog.
- **`BoordensStreet.otf` — DROPPED** (the owner: *"OTF fonts don't work in game"*). Safe because
  **`BoordensStreet.ttf` sits beside it** in `Fonts/`, so no typeface was lost, and nothing in any
  repo referenced the file. `Fonts/` is now 7 files.
- **★ The repo-pages visibility question is CLOSED — ACCEPTED, and it is not to be raised again.**
  The owner: *"I don't care enough to go with any of the alternatives, so it's fine. You can stop
  mentioning it."* **Do not re-flag it and do not propose a fix.** Recorded so nobody re-derives it:
  **GitHub visibility is per-REPO, never per-PATH** — there is no setting, `.gitattributes` or
  equivalent that hides a tracked file from a public repo's web UI. The only real options were
  untracking the docs (costing SUITE-STATE, the home of record, its history and its only off-machine
  backup) or a separate private docs repo (a second clone to sync + every `CLAUDE.md` pointer
  rewritten). Both cost more than the problem — the files are identity-clean after TASK 0 and are
  already excluded from the packaged zips, so no installer or friend ever receives them.

# SESSION RECORD — 2026-07-25e (the Auras tab layout rework — done in `~/GloomsAuras`)

**Suite to-do item 1 is CLOSED.** The work itself was GA's and was done in GA's repo, correctly
routed; what lands HERE is the ledger, the contract table and this record.

**What changed for the SUITE, not just for GA:**
- **`GloomsAuras/Config.lua` now requires LibGloomSkin MINOR 4** (CONTRACTS §6 table updated). It
  adopted `UI.tabHeader`, bumping its gate in the same commit — the **second live exercise** of the
  gate, and it behaved exactly as designed. **No tab is without a header any more.**
- **GA's profile DRAWER is gone**; the shared `UI.profileBlock` sits permanently in a GB-style left
  rail. All three tools now put the same control in the same place, which is what promoting it to
  the lib was for. CONTRACTS §5's GA entry says so now.
- **Four of GA's docked drawers were deleted** (Manage Group, Visibility, Text, Glow). Only
  transient pickers remain. Nothing in the shell or the lib changed to allow this.

**Two findings worth carrying to the other tools:**
1. **★ A tab that throws during `build()` takes the WHOLE tab down, silently.** The shell calls
   `build(container)` before showing and focusing, so an error anywhere in a tab's build leaves the
   window open, the content blank and NO tab highlighted — it does not look like "one broken
   section", it looks like the addon is dead. GA hit this when a block deletion orphaned a
   module-local into a nil global. **`luac -p` cannot catch that** (an undefined global is valid
   Lua). The check that can, after any block deletion:
   ```
   luac -l F.lua | grep -oE '_ENV "[A-Za-z_][A-Za-z0-9_]*"' | sort -u
   ```
   Diff it against a known-good revision; anything orphaned shows up as a NEW global.
2. **★ The owner's mock files render at ~2.5× the game's pixels.** Two rounds of "make this read
   better" missed purely on units. When he gives a px number, convert it — or better, **ask for the
   RULE** ("the stub should be about as tall as the label"), which landed first try and is what got
   written into the code, since a relationship survives a resize and a magic number doesn't.

**Also settled here:** backlog item 7 — **texture files need only `/reload`**, proven by replacing
two in place (see that item). Fonts remain the sole restart exception.

**Left open, the owner's call:** dimming the background behind the shared `UI.nameDialog` /
`UI.confirm` modals. He raised it in GA's session — they blend into the panel behind them — and it
matters more now that every delete in the Auras tab routes through `UI.confirm`. **This is a HUB
change** (`Skin.lua`), it benefits all four tabs, and it is internal behaviour: no new API, so no
MINOR bump and no consumer gates move.

# SESSION RECORD — 2026-07-25d (logos, the shared tab header, footer + Media counts)

Same session as 25c, after Phase G closed. All of it done **from the GloomsHub session**, touching
GB and GO as well — the owner's explicit call, and the shared-contract carve-out.

### The new logo set (backlog 1, 3, 4 — DONE)
The owner redrew all five marks at **512×512, square, transparent, with the addon name removed**
from under the letters. At header size that text was a few pixels tall and read as an artifact.
The old art was PORTRAIT (197×295, 179×247, 115×128) and **every draw site hardcoded a matching
portrait size**, so the sizes moved with the art: shell title bar `19×28 → 28×28`, Overlays rail
`18×25 → 26×26`.

★ **GS and Gh are DIFFERENT MARKS for different things** — the owner drew both deliberately:
- **GS = the SUITE** → the Suite window title bar, the minimap launcher, the GitHub org avatar.
- **Gh = the HUB AS AN ADDON** → the Hub's TOC `IconTexture`, and the Media tab's header.

Also: Overlays had **no `## IconTexture` at all** and was showing a generic `?` in the addon list
(backlog 3, fixed); the Hub's `minimap.png` was 64×64 against its siblings' 256 (backlog 4, now 512);
and `GloomsBars/Media/ui/minimap.png` + `GloomsAuras/Media/minimap.png` were deleted as orphans of
the minimap buttons removed in Phases C and D.

⚠ **`GloomsAuras/Media/ga_logo_full.png` was deliberately NOT touched** — it is the landing-page
splash (monogram + wordmark at 197×248, where the wordmark IS legible), and that splash is being
retired in GA's own session.

### `UI.tabHeader` — LibGloomSkin MINOR 4 (backlog 2 — DONE except GA)
Overlays had built the mark + wordmark + divider header inline; the owner wanted it on every tab, so
the geometry was **promoted into the lib and Overlays now consumes it**. Bars gained a header it
never had (its rail opened straight onto PROFILE) and its rail contents shifted down 48px. The Media
tab gained one wearing **Gh**.

★ **Auras is deliberately excluded and its gate stays at MINOR 3** — its tab is getting a full
layout rework, and the splash being retired sits exactly where a header would go. Adding one now
means designing that space twice.

★ **The owner caught a 2px misalignment** — the Media header sat at `x = 16` (matching that tab's own
status line) while Bars and Overlays sat at 14. He compares these **by tabbing between them**, so
cross-tab alignment beats internal alignment. All three now pass 14 and take every other value from
the widget default. **The only thing that differed was the one value passed by hand** — which is the
argument for the shared widget in miniature.

★ **First live exercise of the version gate:** adding `UI.tabHeader` bumped the lib to MINOR 4, so
`SKIN_NEEDS` moved to 4 in the two files that call it **in the same commit**. The requirement table
in CONTRACTS §6 is now deliberately non-uniform (GB/GO editor at 4, GA + GO preview at 3) — each
file declares what IT uses. That is the gate working, not drift.

### Footer + Media counts (backlog 8, 9 — DONE)
- **The footer lists EVERY installed suite addon's version**, not just the Hub's — `Hub · Bars ·
  Auras · Overlays`, omitting any that aren't installed. `Hub:Version(addon)` now takes an addon and
  returns `nil` for not-installed / `"dev"` for a `@project-version@` TOC. **This closes the
  long-open "shared-footer contents" question.** Build Barn is deliberately not in the `SUITE` list.
- **The Media tab shows each category's count on the section header**, readable while COLLAPSED
  (which was the point). Counts update from `relayout()` — the one path that build, add, remove and
  the tab's refresh hook all funnel through.

### ★★ RESEARCHED, because two of us were guessing: reload vs restart vs relog
The owner asked for sources rather than reasoning. Findings (2026-07-25):
1. **SavedVariables are written on logout, disconnect, quit AND `/reload`** — `/reload` IS a genuine
   save point (Warcraft Wiki). So "the clear doesn't take until I log out" is a real observation with
   the wrong mechanism: a `/reload` would also have flushed it.
2. **New addons/files need only `/reload`** — installable and updatable without closing the client
   since October 2020 (Wowhead). The owner's correction stands.
3. **★ FONTS ARE A GENUINE EXCEPTION.** WoW loads font files at LAUNCH; `/reload` does not reload
   them, so a new `.ttf` needs a full restart. **The Media tab's Fonts warning is CORRECT — do not
   "fix" it.** The blanket retirement of the restart rule earlier in this session was too broad and
   has been corrected in all four repos. (Textures may be the same — UNVERIFIED, test before
   claiming.)
4. **Hand-editing a SavedVariables file needs the client fully closed** — the in-memory copy
   overwrites the file at every save point. This is the case that genuinely requires an exit.

# SESSION RECORD — 2026-07-25c (PHASE G QA — the plan is complete)

**Phase G is DONE and the 7-phase plan is finished.** The owner QA'd the full install and update
paths against a real client with the dev symlinks moved aside. Results are in SUITE-STATE's Phase G
row. All four addons publish **`v1.0.1`**.

### ★ The one lesson worth carrying: a SILENT library failure reads as a pass
GA loads LibCustomGlow with `LibStub("LibCustomGlow-1.0", true)` — the `true` means *silent*, so a
missing library yields `nil` — and **every glow call is `pcall`-guarded** (`Displays.lua` ~line 46).
So if the packaged zip had shipped without the library, there would be **no glow and NO BugSack
error**. A clean sack would have looked like success. This mattered because GA's external had been
dead (the wowace path 404'd) and was repointed at `Stanzilla/LibCustomGlow` — verified in the zip's
file listing, but never *loaded* by anything until now.

**The test, and it is short enough for WoW's 255-char chat limit:**
```
/dump LibStub("LibCustomGlow-1.0", true) ~= nil
```
→ **`[1]=true`**. Runtime-proven. **This is the same shape as the `LSM:Fetch` trap** (a missing font
silently returns WoW's default): *when a subsystem is designed to degrade quietly, its silence is
not evidence — go read the registry directly.*

### Other findings
- ★ **A WoWup update needs no full client restart — `/reload` is enough** (the owner). `v1.0.0` → `v1.0.1`
  changed no files — only TOC metadata — and applied without one. He then confirmed it holds generally:
  he installs new addons via WoWup and just `/reload`s. **The blanket restart rule is RETIRED —
  EXCEPT for fonts.** See the research note in the 2026-07-25d record.
- **The dev symlinks make the version string the load-source test.** A packaged install reads
  `v1.0.x`; a dev symlink reads the literal `@project-version@`. That single field tells you which
  copy the client actually loaded — worth checking first, since every later result depends on it.
- **`GloomsOverlays` shows a red `?` in the addon list** — the missing `## IconTexture`, seen in the
  wild. Backlog item 7; GO's repo owns it.
- **The shell footer shows only the HUB's version** (the owner: "the individual addon version isn't
  shown anywhere in GH"). Four addons version independently, and this session *demonstrated* the
  drift — Bars sat at `v1.0.1` while the others were `v1.0.0` with nothing in the UI saying so.
  **This answers the long-open "shared-footer contents" question.** Backlog item 12.

### ★★ Built after the QA: the SHARED-TOOLKIT VERSION GATE (CONTRACTS §6)
The owner asked whether letting the four addons' versions drift was "a problem I'm not aware of."
**It was, and it was live.** All three tools did a bare `LibStub("LibGloomSkin-1.0")` with **no
version check whatsoever**, and `## Dependencies: GloomsHub` only checks the Hub is PRESENT — WoW's
TOC dependency system has **no version constraint**. So a tool released ahead of the Hub would have
called a `nil` widget and buried a non-developer in Lua errors. Synchronized versioning had been
masking this by accident: the Hub and its tools always shipped together.

Every consumer now declares `SKIN_NEEDS` and returns early with one actionable line. **Gate the UI
file, never the engine** — `Config.lua` is last in GB's and GA's TOC, and `_Editor`/`_Preview` load
after `GloomsOverlays.lua`, so the chunk-level `return` costs the tab and nothing else.

**QA'd by forcing failure, not by assuming success** — GB's gate was temporarily set to require v99:
the message printed verbatim, the BARS tab disappeared, **`Gloom's Bars: skin ON — 116 buttons
styled.` still printed in the same session** (the engine ran while its config was refused — the
whole point), and BugSack stayed clean. Reverted to 3 after.

★ **The maintenance burden is one line:** bump `SKIN_NEEDS` in the SAME commit that first calls a
newer widget. That is the only way to defeat the gate.

### ⚠ Teardown order — the one destructive-mistake risk
**Uninstall in WoWup BEFORE restoring the symlinks.** WoWup's Remove deletes the folder it manages;
with a symlink in that slot it could follow the link into `~/GloomsHub` and delete live source.
Uninstall first and it can only ever delete folders it created. Also expect WoWup to keep tracking
those addon names afterwards and offer updates on the dev symlinks — a nuisance, not damage.

# SESSION RECORD — 2026-07-25b (the org move: HandofDevastation → GloomSuite)

**The four suite repos now live under a new GitHub org, `GloomSuite`.** `GloomsBuildBarn` and the
guild website stayed with `HandofDevastation`. Done mid-session, before the Phase G WoWup QA — on
purpose, so the QA tests the URLs friends will actually use rather than ones about to change.

**Why (the owner):** the guild is a guild; **"Gloom" is his own identity** — the prefix of all his
characters, and what people call him. The suite is his work, not the guild's, and **guild membership
may not be permanent**, so `HandofDevastation/GloomsHub` asserted something both wrong and fragile.
Build Barn genuinely IS a guild project (it's fed by the guild website's cron), so it stayed put.

**★ A second org, NOT a rename.** A rename would have dragged the guild site + Build Barn along and,
worse, **vacated the name `HandofDevastation` for anyone to claim** — GitHub does not reserve a
released org name, and a squatter would inherit every redirect *and* the URLs already in people's
WoWup installs. Creating a second org leaves the old one alive, so its redirects live forever.

### What was done, and what was verified
- Org `GloomSuite` created; **membership PRIVATE** — verified unauthenticated
  (`/orgs/GloomSuite/public_members` → `[]`, matching `HandofDevastation`).
- All four repos transferred via `gh api -X POST repos/<old>/<repo>/transfer -f new_owner=GloomSuite`.
  ⚠ **The transfer API is ASYNC and its response echoes the OLD `full_name`** — that is not a
  failure. Verify by fetching the new path.
- Verified after: new paths **200**; old paths **301** (redirects intact); `GloomsBuildBarn` still
  200 under the guild org; **`/releases/latest` → `v1.0.0` on all four, ANONYMOUS** (the TASK 0
  latest-pointer trap did not recur); all four `release.yml` workflows **`active`** on the new org;
  the Hub's release zip downloads with **zero credentials** (200, 4.3 MB, 109 files).
- Four git remotes re-pointed; every `HandofDevastation/Glooms{Hub,Bars,Auras,Overlays}` URL
  rewritten across TOCs (`## X-Website`), READMEs and docs; the three `release.yml` permission
  comments now name `GloomSuite`. **GA's README link to Build Barn deliberately still points at
  `HandofDevastation` — that one is correct.**
- The privacy block in [../CLAUDE.md](../CLAUDE.md) now documents BOTH orgs and which owns what.

### Traps hit / worth keeping
- ★ **zsh does NOT word-split unquoted variables.** `for f in $files` passed the entire newline-
  separated list to `sed` as ONE filename; it printed "updated …" for every file while changing
  **nothing**. Only the follow-up grep caught it. **Pipe into `while IFS= read -r f` instead** — and
  never trust a loop's own success echo, verify the content.
- The repo-transfer call is blocked by Claude Code's permission classifier in auto mode. The owner
  switched to manual mode to approve it; the alternative is the GitHub UI
  (repo → Settings → Danger Zone → Transfer ownership).
- **Renaming an org is the trap to avoid** — see above. If a suite repo ever needs to move again,
  transfer it; do not rename an org that has published releases.

### Still to do from this move
- **Org avatar:** the WoWup install dialog shows the **org's avatar** — WoWup's GitHub provider
  hardcodes `thumbnailUrl = repository.owner.avatar_url` and never reads the addon's TOC or zip.
  So per-addon art there is impossible; the org avatar is the only lever. The owner is making a GS
  mark for it. Background `#060714`, bottom glow `#ff7729` @ 11% (see below).

# SESSION RECORD — 2026-07-25 (Phase G build + a doc-truth sweep)

**Nothing is in flight. All four repos are clean, pushed, and in sync.** This session shipped Phase G
(its own record is at the bottom of this file) and then fixed the fallout it exposed.

### What happened, in order
1. **Built and shipped Phase G** — packaging for all four repos, `v1.0.0` released everywhere,
   every package downloaded and verified. Full detail in the Phase G section below.
2. **Swept the sibling repos for release facts the release had just falsified.** GB's `CLAUDE.md`
   still said "last shipped v0.2.0, a lot of unshipped work behind it"; its handoff carried the
   release tag as an *open owner decision* in two places, listed the shipped tags, and still said
   "next suite step is Phase A". GA's handoff described the LibCustomGlow URL as "flagged to confirm
   before first release" (it was dead) and listed libs dropped back in Phase D. **All corrected, and
   the spots now POINT at SUITE-STATE rather than restating.** Overlays was clean — its CLAUDE.md
   describes the release *mechanism* and never names a version, which is exactly the right pattern.
3. **Resolved two GB backlog items rather than carrying them:** embedding LibSharedMedia via
   `.pkgmeta` is settled **not-to-do** (the Hub embeds it, GB hard-depends on the Hub — a second copy
   is the drift the suite exists to prevent, same logic that dropped the LibGloomSkin embed); and the
   WoWup install test is now flagged as the suite's one open QA item with the symlink hazard.
4. **Added the routing rule** (working agreement 7) to all four `CLAUDE.md` files.
5. **Answered the distribution question and wrote it into [../README.md](../README.md)** — see below.

### ★ The owner's questions this session, and the answers (all recurring — reuse them)
- **"How do I update, say, GB's shape catalog? It feels like ONE addon."** Both models are right:
  **one product at runtime, four packages on disk.** The Hub owns the window frame + toolkit; each
  tool paints the inside of its own tab. **A shape is pure GB work in `~/GloomsBars`** — six PNGs in
  `Media/art/hand/` (`<key>-base/-inner/-outer/-rim/-line/-swipe.png`), one row in `HAND_DEF`
  (`Core.lua`), the key added to `GB.HAND_GROUPS`, then a `/reload`. **The Hub needs no
  change and no new release** — that is the part that IS automatic. Only shared things come here:
  the shell/tab API, `LibGloomSkin`, media plumbing, the one launcher, these docs.
- **"Is one GitHub link enough for friends?"** No — **four links, one per repo**, Hub first (WoWup's
  "Install from URL" is per-repo; there is no meta-package). A single-link bundle would mean
  collapsing four repos into one and losing independent versioning — not worth it, but the door
  exists.
- **"Do I have to give friends my GitHub personal access token?"** **NO — never.** Three reasons, and
  reason 2 is suite-specific: (1) a PAT is an account password; (2) **it is tied to the personal
  account whose handle TASK 0 exists to keep hidden — sharing it undoes the scrub**; (3) it is
  unnecessary. **Verified 2026-07-25 with zero credentials:** the release zip downloads anonymously
  (HTTP 200, 4.5 MB). WoWup's PAT field only raises GitHub's API rate limit (**60 req/hour**
  unauthenticated). It was only ever needed here while the repos were PRIVATE during the scrub.
  This is now written into README.md so the owner never has to field it.
- **"Is routing work to the right repo actually best practice?"** Yes — and the reason is **context,
  not file access.** Any repo can be edited from any session; what can't follow is that repo's
  `CLAUDE.md`, handoff, API-NOTES and frozen specs. See working agreement 7.

### Flagged for the owner, not acted on
- **The public repo PAGES expose `CLAUDE.md` + `docs/`** to anyone who clicks a shared link. They are
  **excluded from the packaged zips**, so no installer ever sees them, and they are identity-clean —
  so this is not a privacy problem, just working notes being visible. Raise it again if he decides
  to share more widely; the fix (a `docs` branch, or trimming) is a decision, not a defect.
- The owner considers the suite **still in active development and is NOT ready to share it yet**
  (2026-07-25). Don't push distribution work until he says so.

### Housekeeping done
- **`~` in `.claude/settings.json` `additionalDirectories` works** — the TASK 0 open question. Proven
  in practice this session: files in `~/GloomsBars`, `~/GloomsAuras` and `~/GloomsOverlays` were all
  read and written without a permission failure. **Consider that item closed.**
- File modes normalized to `644` on the new `.pkgmeta` / `release.yml` files (they were created `755`;
  GB's committed copies are `644`). Cosmetic only — the packager does not care.

---

# TASK 0 — THE IDENTITY SCRUB ✅ DONE (2026-07-24)

**What it was:** the owner's real name + personal email, *and* his personal GitHub handle, were
present across all five repos — in file content, in commit messages, and in author/committer
metadata. Flipping the repos PRIVATE on 2026-07-24 contained it; this rewrite removed it.

### How it was done
- **Backups first:** `git clone --mirror` of all five → `~/glooms-scrub-backups-2026-07-24/`
  (38 MB, later 71 MB), plus `GloomsBuildBarn-SERVER-TRUE.git` — which is what made trap 2
  recoverable. **These were DELETED on 2026-07-24** once every repo was public, verified clean and
  in sync, because they were the last copy of the old identity on disk. Take fresh backups before
  any future rewrite; there is no undo now.
- **Tool:** `git-filter-repo` 2.47.0 (`brew install git-filter-repo`).
- **Rules:** one replacements file used for BOTH `--replace-text` (blobs) and `--replace-message`
  (commit messages), plus a `--mailmap` mapping the old name/email **and** the handle's
  `…@users.noreply.github.com` address → `Gloom <gloom@handofdevastation.invalid>`.
- Attribution by first name → "the owner" / "the owner's"; `/Users/<handle>/` → `~/`; the personal
  handle → "the org admin account". Sentence-start forms were re-capitalized.

### Verified — every gate ZERO, on fresh mirror clones *from GitHub*

| Repo | commits | author/committer | messages | all-history blobs | HEAD files |
|---|---|---|---|---|---|
| GloomsHub | 17 | 0 | 0 | 0 | 0 |
| GloomsOverlays | 3 | 0 | 0 | 0 | 0 |
| GloomsBars | 124 | 0 | 0 | 0 | 0 |
| GloomsAuras | 44 | 0 | 0 | 0 | 0 |
| GloomsBuildBarn | 7 | 0 | 0 | 0 | 0 |

Every author *and* committer across all history is now `Gloom <gloom@handofdevastation.invalid>`
(plus `github-actions[bot]` on Build Barn's cron commits — correct, leave it). `StoneTweaks` /
`StoneCast` names and the `VibeOverlayDB` / `VibeOverlayDBChar` SavedVariables globals were NOT
touched; all 25 Lua files pass `luac -p`; no binary asset contained the identity.

### ★★ Two traps this hit — DO NOT REPEAT
1. **Release ZIPs are a SEPARATE surface a force-push cannot reach.** GloomsBars' three published
   release zips contained the name — in `Core.lua` and in a packager-generated `CHANGELOG.md`
   built from commit messages. Force-pushing the rewritten **tags** re-triggered the BigWigs
   packager, which rebuilt all three assets from scrubbed source (new asset IDs, re-verified 0
   hits). **After ANY history rewrite, download and grep the release assets.**
2. **★ Build Barn's REMOTE was AHEAD of the local clone.** Its cron commits `BuildData.lua` and
   tags a dated release *directly on GitHub*, so `~/Desktop/glooms-build-barn` was missing three
   "Weekly data refresh" commits and three tags. Scrubbing the stale local copy and force-pushing
   it rolled `main` back from 2026-07-21 to 2026-07-06. Recovered from the surviving tags, rebuilt
   from the true server history, re-pushed; `BuildData.lua` verified byte-identical to the
   pre-scrub published asset — nothing lost. **ALWAYS `git fetch --all --tags` before rewriting a
   repo that has automation writing to it.**

### ★★★ THE BIG LESSON — a force-push does NOT purge, and a private repo hides that from you
Rewriting history unlinks the old commits; it does **not** delete them from GitHub. Proven on
2026-07-24:
- While the repos were PRIVATE, `GET /repos/…/commits/<old-sha>` returned **404**, which looked
  like a purge. **It was not.** A private repo 404s that endpoint for *any* SHA, valid or not —
  the test is meaningless while private.
- The instant the repos were flipped PUBLIC, those same pre-rewrite SHAs returned **200, serving
  the old identity in the author, committer and message fields.** Everything was flipped straight
  back to private (~2 minutes exposed).

**Rules that follow — do not relearn these the hard way:**
1. Never treat a force-push as a purge. The only reliable purge is **delete the repo and recreate
   it** (needs `gh auth refresh -h github.com -s delete_repo`).
2. Never validate a purge from a private repo. Verify **unauthenticated**, against the **public**
   repo, and expect **422** ("no commit found for SHA") — *not* 404, which means repo-not-found.
3. A brand-new repo has no leftovers, which is why recreate-and-push is airtight.

### How it was finished (2026-07-24)
`GloomsBars`, `GloomsAuras` and `GloomsBuildBarn` were **deleted and recreated**, then the scrubbed
history + tags pushed. `GloomsHub` and `GloomsOverlays` needed no recreation — they were created
that same day and only ever received scrubbed history. Re-pushing the tags made the BigWigs
packager rebuild every release asset from clean source. **All five repos are now PUBLIC**, so the
WoWup install/update path works again. Verified unauthenticated: pre-rewrite SHAs → 422, current
commits → 200, zero identity in commit metadata, messages, all-history blobs or release zips, and
org membership still private.

### Still open / watch out for
- **Release ZIPs need re-checking after any rewrite** — see trap 1 above.
- **Actions on a recreated repo:** the org disables write permissions for workflows by default, so
  `default_workflow_permissions` is `read`. That is fine *because* both `release.yml` files declare
  `permissions: contents: write` themselves. A workflow without that block will fail to publish.
  Also, tags pushed in the same breath as the initial branch push may land before the workflow is
  registered and silently trigger nothing — re-push the tags if no run appears.
- **GBB's `weekly-data.yml` only releases when the data CHANGED**, so `workflow_dispatch` on
  unchanged data is a no-op. To force a release, re-push the tag (fires `release.yml`).
- **★ Recreating releases out of order breaks "latest" — which is what WoWup installs.** After the
  recreate, GBB's latest resolved to `v2026.07.06` and GB's to `v0.0.1`, because the older tags were
  re-pushed last. Fixed with
  `gh api -X PATCH repos/<owner>/<repo>/releases/<id> -f make_latest=true`. **Always finish by
  checking `/releases/latest` anonymously** — and note that endpoint caches, so a stale answer may
  just need a re-read before you go chasing it.
- These repos were PUBLIC with the identity until 2026-07-24, so third-party mirrors of public
  GitHub event data are outside anyone's control. This scrub is forward-looking.
- `.claude/settings.json` `additionalDirectories` now reads `~/GloomsBars` etc. — confirm `~`
  expands there, or put absolute paths back.
- ⚠ **Never write the real name or the personal handle into these docs, even to describe the leak.**
  That happened once while documenting this very task and had to be scrubbed again. Say "the old
  identity".

### Known-good facts (verified 2026-07-24 — don't re-litigate)
- Org membership IS private (`/orgs/<org>/public_members` → empty). Verified on
  `HandofDevastation` 2026-07-24 and on the new `GloomSuite` org 2026-07-25. **Re-check this on ANY
  org that ever holds a suite repo** — a one-member org with public membership points straight back
  at the personal account.
- Releases are authored by `github-actions[bot]`, not the owner's account.
- The leak path was git config → GitHub auto-linking commits by registered email. The org setup
  itself was fine; it simply never covered local commit metadata.
- WoWup's GitHub install path effectively needs a PUBLIC repo — private + PAT is reported broken.
  If public is ever unacceptable, the alternative is packaging to CurseForge/Wago instead.

---

# PHASE F — retire StoneTweaks ✅ STEPS 1–5 DONE (2026-07-24), one confirmation restart left

**Status:** steps 1–4 QA'd by the owner and step 5 executed. **StoneTweaks is disabled AND its folder
is out of AddOns** — moved to `~/Desktop/StoneTweaks-retired-2026-07-24` (73 files, count-verified).
**`StoneTweaksDB` in WTF was deliberately left in place**, so rollback is still just moving the folder
back and re-enabling. Outstanding: one full client restart with the folder physically gone (it was
removed mid-session, while ST was merely disabled), then step 6.

**Why it was unblocked:** Overlays was the suite's last StoneTweaks consumer, and Phase E gate A
moved it to `GloomsHub:ResolveAssetPath`. Nothing in the suite reads ST data any more.

1. ✅ **DONE + verified 2026-07-24.** Nothing references ST. The sweep covered all four suite repos
   **and the entire live AddOns folder** (105 addons): zero hits for `StoneTweaks_ResolveAssetPath`,
   `StoneTweaksDB`, `StoneTweaks_FrameDefs`, `CatStoneTweaks` outside ST's own three files. In the
   suite, the only *live-code* hits are the Hub's deliberate compat shim + copy-migration in
   `Core.lua` (CONTRACTS §3); every other hit is a comment or a doc line. Also verified offline:
   - `GloomsHubDB` and `StoneTweaksDB` hold **identical** catalogs (1 font / 6 textures / 36
     graphics, same name→file pairs) — ST registered nothing new since Phase A, so there is no
     second migration to run.
   - **All 43 catalog files exist under the Hub**, and `Fonts/` / `Textures/` / `Graphics/` are the
     **same file sets** in both addons — retiring ST loses no asset.
   - ST's ElvUI half is provably unused on this account (`frameTextures` empty, `suppressGlow`
     false), so disabling it kills nothing that was in service.
   - ⚠ Note for the Media tab: the catalog carries a leftover `test-remove` / `test-remove.png`
     graphic. It came from **ST** (it's in `StoneTweaksDB` too), not from Phase B QA. Harmless (the
     file exists), but it's clutter the owner may want to remove in the Media tab.
2. ✅ **DONE — QA'd by the owner 2026-07-24.** ST disabled + full client restart. Clean: BugSack empty,
   `Gloom's Hub: Registered 1 font and 6 textures into LibSharedMedia.` present and unchanged, **zero
   `StoneTweaks:` lines**, **zero Hub-prefixed "skipped" lines**.
   ★ **`/st` no longer does anything — and that is the positive proof, not mere silence.** `/st` was
   registered by ST's own code; with ST off that code never runs, so the command cannot exist. Same
   for ST's `StoneTweaks loaded. Type /st to open the panel.` login line, which is absent.
   ⚠ Don't misread other addons' output: **ArcUI prints its own `SKIPPED …` lines** (`ArcUI:` prefix,
   about CDMGroups) that have nothing to do with media registration. Check the prefix.
3. ✅ **DONE — QA'd by the owner 2026-07-24.** Off the Hub alone: `/gh` → 1 font / 6 textures / 36
   graphics, `migratedFromST = true`; **Goldset overlays render on Gloomthorn**; all four tabs
   (Bars/Auras/Overlays/Media) open; Media tab previews draw for fonts, textures and graphics.
4. ✅ **DONE — the compat shim is LIVE and proven, 2026-07-24.**
   `StoneTweaks_ResolveAssetPath("goldset-player-frame")` → `Interface\AddOns\GloomsHub\Graphics\goldset-player-frame.png`
   (a global only ST ever defined, now answered by Core.lua's shim). Both resolver branches verified
   (`goldset-texture` → `…\Textures\…`), and `LSM:HashTable("font").DrukMedium` → `…\GloomsHub\Fonts\DrukMedium.ttf`.
   ★ **Read the registered LSM table, never `LSM:Fetch`** — `Fetch` silently returns WoW's default
   font for a missing name, which reads as a false pass.
   ★★ **WoW's chat edit box truncates at 255 characters, and `!BugGrabber` swallows the resulting
   syntax error so the command appears to do NOTHING.** A 360-char `/run` one-liner was lost exactly
   this way during QA. Keep QA commands short — prefer several `/dump` one-liners (~50–90 chars) over
   one long `/run`.
   ★ **But check the PREFIX, not the wording** — the Hub's `Media.lua` prints a
   *word-for-word identical* "Font/Texture skipped — … is already registered" line (`GloomsHub:Print`,
   so it reads **`Gloom's Hub:`** instead of **`StoneTweaks:`**). Today the Hub loads first, wins the
   LSM names, and ST prints 7 skip lines. So the exact expectation after disabling ST is:
   - **`Gloom's Hub: Registered 1 font and 6 textures into LibSharedMedia.`** — unchanged, still there.
   - **Zero `StoneTweaks:` lines** (that's the retirement working).
   - **Zero `Gloom's Hub: … skipped` lines.** A Hub-prefixed skip line is NOT a leftover — it means a
     *third-party* addon claimed that LSM name first (`EnhanceQoLSharedMedia` and `EllesmereUI` are
     both installed). That would be a real collision to chase, not the transition artifact.
5. ✅ **DONE 2026-07-24 — moved, not deleted.** `…/AddOns/StoneTweaks` →
   `~/Desktop/StoneTweaks-retired-2026-07-24`, 73 files before and after. `StoneTweaksDB` left in WTF.
   **Still to do: one full client restart** to confirm the client is happy with the folder physically
   absent (it was moved while the client was running and ST merely disabled).
   ⚠ **`~/Desktop/VibeOverlay-retired-2026-07-24` is NOT a safe delete, and the owner chose to KEEP
   it (2026-07-24)** — despite what this file used to say. **Git never held the pre-rename
   originals:** GloomsOverlays' *first* commit (`5be4b1b`) already contains the renamed
   `GloomsOverlays*.lua` files, and no `Vibe`-named file appears anywhere in that repo's history.
   That Desktop folder is therefore the **only copy of the original VibeOverlay source** (96 KB).
   Leave it alone; it is not cleanup debt.
   (Both unscrubbed folders were identity-scanned and are clean: `## Author: You` and
   `## Author: StoneTweaks`, zero hits for the old identity. The "no copy of the old identity remains
   on disk" claim in TASK 0 still holds.)
6. ✅ **DONE — CLOSED by the owner 2026-07-24: KEEP THE SHIM PERMANENTLY.** One line, zero cost,
   proven working, and nothing in the suite calls it — pure insurance for anything stale outside the
   suite. Pinned in CONTRACTS §3 and commented in `Core.lua`. **Do not "clean it up" in Phase G.**

**Phase F is closed.** Nothing carries over from it. Phase G's briefing is at the bottom of this file.

### Two QA lessons from Phase F worth keeping
1. **★ WoW's chat edit box truncates at 255 characters, and `!BugGrabber` swallows the resulting Lua
   syntax error — so an over-long command appears to do NOTHING AT ALL.** A 360-char `/run` one-liner
   was lost exactly this way and read as "doesn't do anything." Keep QA commands short: prefer several
   `/dump` one-liners (~50–90 chars) over one long `/run`. Measure before sending.
2. **★ Never verify an LSM registration with `LSM:Fetch`** — it silently returns WoW's *default* font
   for a missing name, so a failure reads as a pass. Read the registered table instead:
   `LibStub("LibSharedMedia-3.0"):HashTable("font").<Name>`.
3. **Absence of a slash command is real proof.** `/st` going dead proved ST's code never loaded —
   stronger evidence than the absence of its login print, and much stronger than mere silence.
4. **Check the PREFIX on every login line.** ArcUI prints its own `SKIPPED …` lines about CDMGroups
   that look alarming and are unrelated. The Hub's own skip-line wording is word-for-word identical
   to StoneTweaks'.

---

## Where Phase E landed (do NOT redo any of this)
- **`~/GloomsOverlays`** — the `overlays` tab (order 30): a 240 left rail (GO mark + wordmark ·
  shared profile block · overlay list · Duplicate/Delete) beside a scrolling editor pane, plus an
  in-tab footer (Save & Apply + status). Asset browser is a 360-wide docked drawer opened from the
  Texture field's **Browse…**; "Use This Texture" returns the pick. Bare `/go` toggles the tab.
  Zero native chrome remains.
- **LibGloomSkin → MINOR 3**: `UI.dropdown` + `UI.flyout`, `UI.nameDialog`, `UI.confirm`,
  `UI.profileBlock`. GB's and GA's private copies are DELETED — GB's rail (profile + preset) and
  GA's profiles drawer both drive the shared block.
- ★ **`VibeOverlayDB` / `VibeOverlayDBChar` keep their names on purpose.** WoW keys SavedVariables
  off the addon FOLDER name; 23 files were copied in place at gate A and **12 characters ride
  non-Default profiles**. Renaming those globals silently resets it.

## Polish backlog — CLOSED. Nothing remains.
~~The Auras tab layout rework~~ (item 1) · ~~Overlays' Width/Height/X/Y sliders~~ (item 2) — both
**✅ DONE + QA'd 2026-07-25**. ~~GB's modifier symbols~~ (item 3) — **DROPPED by the owner
2026-07-25**, not to be re-proposed. See the session records at the top of this file; the ledger is
in SUITE-STATE.

## Other reminders
- ONE minimap launcher for the suite (the Hub's GS button) — never one per tool.
- Locked decisions (full list in SUITE-STATE): hard dependency, no fallback windows; Build Barn is
  OUT; never "v1"/"later phase" framing; GUI over slash.
- **macOS `sed` has no `\b`.** Verify identifier renames with a token count, and `luac -p` every
  touched Lua file.

---

# PHASE G — packaging / release ✅ BUILT 2026-07-24 · ONE QA TASK LEFT

**All four addons publish `v1.0.0`.** Everything verifiable outside the game client has been
verified. What remains is the owner's install check, below.

## ✅ QA DONE — 2026-07-25. The script below is kept as the RE-RUN recipe, not an open task.
Everything here passed. Results are in SUITE-STATE's Phase G row; the QA lessons are in the
2026-07-25c session record. Re-run this only if packaging changes.

1. In **WoWup → Get Addons → Install from URL**, install
   `https://github.com/GloomSuite/GloomsHub`.
2. Install one tool the same way, e.g. `https://github.com/GloomSuite/GloomsBars`.
3. **`/reload`** (a full client restart is NOT required — see working agreement 6).
4. Check: BugSack clean · the addon list shows both, with **no missing-dependency flag** ·
   `/gloom` opens the Suite window · the Media tab shows **1 font / 6 textures / 36 graphics** ·
   the installed tool's tab renders.
5. ★ **The version-string check:** the TOC now reads `## Version: v1.0.0`, not `@project-version@`.
   A literal `@project-version@` in the addon list means the folder is the dev symlink, not the
   WoWup-installed copy — expected locally, wrong for an installed one.
6. *Then an update cycle:* push a trivial commit + tag `v1.0.1` on one addon and confirm WoWup
   offers and applies the update.

⚠ **The dev symlinks and a WoWup install target the SAME folder names.** `…/AddOns/GloomsHub` is
currently a symlink to `~/GloomsHub`. Decide before installing whether to test on this client (move
the symlinks aside first, and put them back after) or on a clean/second WoW install. Do not let
WoWup write over the symlink target.

## What shipped
| Repo | `.pkgmeta` | `release.yml` | Releases |
|---|---|---|---|
| **GloomsHub** | ✅ **new** | ✅ **new** | ✅ `v1.0.0` |
| GloomsBars | ✅ | ✅ | ✅ `v1.0.0` (latest), v0.2.0, v0.1.0, v0.0.1 |
| GloomsAuras | ✅ *(external fixed)* | ✅ **new** | ✅ `v1.0.0` |
| GloomsOverlays | ✅ **new** | ✅ **new** | ✅ `v1.0.0` |

**Version scheme (the owner, 2026-07-24): all four synchronized at `v1.0.0`** — the suite is
feature-complete, and a friends/guild audience should have one answer to "what version are you on?"
GB jumped `v0.2.0` → `v1.0.0`.

**Verified on the published assets** (all four workflow runs succeeded first try):
- Hub zip: Fonts 8 / Textures 13 / Graphics 45 / Media 8, **all five libs fetched**, no
  docs/CLAUDE.md/.github/.pkgmeta.
- GA's zip fetched `LibCustomGlow-1.0`; **Overlays ships no `Libs/` at all** — correct, it loads none.
- Every TOC has `## Version: v1.0.0` substituted; all three tools declare `## Dependencies: GloomsHub`.
- **`/releases/latest` → `v1.0.0` on all four, checked ANONYMOUSLY.** The TASK 0 latest-pointer trap
  did not recur.
- Zero identity in any of the four packages. (The Hub's generated `CHANGELOG.md` matches the string
  `users.noreply.github.com` twice — that is commit-message *prose about the policy*, not an address.
  Don't re-flag it.)

## ★ Two real defects this phase caught — both fixed, both worth remembering
1. **The published `GloomsBars` v0.2.0 was STALE, not dependency-broken.** This file previously
   claimed it "installs BROKEN via WoWup: it demands a Hub that has no release." **Wrong.** That tag
   sat on a **2026-07-18, pre-Phase-C** commit shipping only `Core.lua` + `Skin.lua` — no config UI,
   and **no `## Dependencies: GloomsHub` line at all.** It installed a stale standalone GB three
   phases out of date. The `v1.0.0` re-cut is the actual fix. **Lesson: check what a tag POINTS AT,
   not just that it exists** — the scrub's tag force-push rebuilt those zips from old code.
2. **GA's `LibCustomGlow-1.0` external was dead.** `.pkgmeta` carried an unconfirmed NOTE on it, and
   the wowace SVN path `wow/libcustomglow-1-0/trunk` **404s** — the lib is not hosted there. GA's
   first packaged build would have failed outright. Repointed at `Stanzilla/LibCustomGlow`, whose
   repo root holds exactly what `Libs/LibCustomGlow-1.0` holds locally; the fetch is confirmed in
   the shipped zip. **Lesson: probe every external URL before a repo's first release.** The wowace
   front-end returns **301** (redirect to its SVN server) for a project that exists and **404** for
   one that doesn't — that difference is the test. Port 20003 is unreachable from here, so the
   redirect target itself can't be probed locally; the 301/404 split is what you have.

## ★★ DROPPED: the plan's "embed LibGloomSkin as an external per tool"
SUITE-PLAN §5.G said to embed `LibGloomSkin-1.0` in each tool via `.pkgmeta` externals. **It is now
struck out in the plan itself.** No tool ships or loads its own copy — all three call
`LibStub("LibGloomSkin-1.0")` and resolve to the Hub's `Skin.lua`, which IS the lib body. The hard
dependency guarantees the Hub is present, so there is nothing to insure against; embedding would
create N copies for LibStub to arbitrate by MINOR, **exactly the drift the suite exists to prevent**;
and there is no standalone LibGloomSkin repo to fetch anyway. Consume from the Hub. If a future
*non-suite* consumer ever needs it, publish it properly then.

## Also landed
- **[../README.md](../README.md)** — the public-facing install guide (Phase G item 5): what the four
  addons are, the one-time WoWup "Install from URL" steps with the Hub first, the missing-dependency
  explanation, and the slash commands. This is what a friend lands on at the repo URL.
- GA's `ignore:` tightened — `CLAUDE.md` and `docs/` were being packaged into its zip.
- `GloomsBars`' local `main` had **no upstream configured** (fallout from the delete-and-recreate);
  set to track `origin/main`.

## Packaging traps already learned the hard way (full detail under TASK 0)
- **Tags pushed in the same breath as the initial branch push can land before the workflow is
  registered and silently trigger nothing.** Avoided this time by pushing each branch first and
  confirming the workflow was `active` via
  `gh api repos/<owner>/<repo>/actions/workflows` before pushing the tag. Keep doing that.
- **Recreating/pushing releases out of order breaks `latest` — which is what WoWup installs.** Always
  finish by checking `/releases/latest` **anonymously**; that endpoint caches, so re-read a stale
  answer before chasing it. Fix with `gh api -X PATCH repos/<owner>/<repo>/releases/<id> -f make_latest=true`.
  (Checked this time: correct on all four, no fix needed.)
- **Published release ZIPs are a separate surface** from git history — after any rewrite, download and
  grep the assets.
- ⚠ **`.claude/settings.json` `additionalDirectories` uses `~`** — confirm it expands, or restore
  absolute paths.

---

# ═══ MOVED FROM SUITE-STATE, 2026-07-26 ═══

> The sections below were the *finished* half of the phase ledger. They were moved here whole so
> SUITE-STATE could become a short, re-readable statement of where things stand. Nothing was
> deleted. Open items now live in [BACKLOG.md](BACKLOG.md); diagnosis in [FINDINGS.md](FINDINGS.md).


## The completed to-do list (every item done or explicitly dropped)

**★★ THE 7-PHASE PLAN IS COMPLETE (Phase G QA'd 2026-07-25). No phase work remains.**
Everything below is polish. ✅ items are done and kept for the record.

**Each its own session, in the repo that owns it — route it there**
(items 1 and 2 are done; **only 3 remains**)
1. ~~**Auras tab LAYOUT REWORK** · `~/GloomsAuras`~~ — **✅ DONE, QA'd by the owner 2026-07-25.**
   Shipped in six owner-verified steps: splash retired · the editor's aura-name banner replaced by a
   rail Rename (+ double-click) through `UI.nameDialog` · buttons restyled to the suite's language ·
   a flush-left 240 rail carrying `UI.tabHeader` + the shared `UI.profileBlock` + the aura tree ·
   **groups made a first-class selection** (clicking a group's name fills the editor pane with its
   settings, retiring the ⚙ gear, the Manage Group drawer and the confusing green "Group:" button) ·
   the editor sections re-laid for the full-width pane · and the Trigger section rebuilt to the
   owner's mock as a bracketed tree. **GA's gate is now MINOR 4** (CONTRACTS §6) — no tab is without
   a header any more. **Four drawers were deleted** (Manage Group, Visibility, Text, Glow), leaving
   only the transient pickers. Two defects were caught by the owner along the way and fixed:
   **Delete Aura had no confirmation** (CONTRACTS §4 — it now uses the shared modal, as does every
   other delete in the tab), and the eye icons didn't reflect that a SELECTED aura is already drawn.
   ★ **A trap worth carrying suite-wide:** deleting a block orphaned a module-local that another
   function still called, which became a nil global — `luac -p` does NOT catch that, and because the
   shell builds a tab before showing it, the whole tab came up blank rather than just the broken
   section. Diff the file's global reads against a known-good revision after any block deletion:
   `luac -l F.lua | grep -oE '_ENV "[A-Za-z_][A-Za-z0-9_]*"' | sort -u`.
2. ~~**Overlays: Width / Height / X / Y → SLIDERS** · `~/GloomsOverlays`~~ — **✅ DONE, QA'd by the
   owner 2026-07-25.** Each is `UI.sliderRow` **plus a typed box** so exact values stay enterable;
   the nudge arrows stayed. **No `SKIN_NEEDS` bump**, exactly as predicted — the editor stays at
   MINOR 4 and nothing in the Hub was touched.
   ★ **The shape worth copying:** `UI.sliderRow` parks a read-only value FontString at its
   TOPRIGHT, so the tab passes a `fmt` that returns `""` and puts a `flatEditBox` in that slot —
   the box becomes the readout AND the input, with no lib change. Typed values clamp into the
   slider's range so the two can never disagree.
   ★ **A half-width slider means a half-width PARENT** — `sliderRow` always spans its parent with
   fixed 18px insets, so the tab lays out column frames (anchored to the pane's `TOP`, so they
   split whatever width the shell gives) rather than x offsets. Same trick puts the spin
   direction buttons beside the Spin slider instead of under it. The owner's steer, 2026-07-25:
   *"so much horizontal width available, no point in stacking everything."*
   ★ **A slider is a NEW performance surface, and it found a real bug.** `ApplyAll` rebuilt every
   live overlay frame on every value change — ~60×/second while dragging, and **WoW never reclaims
   a frame**, so a 3-second drag on a 19-overlay profile parked ~3,400 dead frames for the session
   (each with a unique global name). The owner asked for it fixed on the spot, citing general
   framerate concerns. Both halves landed: the engine now **reuses a pool of frames** (the Nth
   enabled overlay always draws through slot N; surplus slots are parked, not discarded), and
   size/position/strata/level re-apply **in place** via `GloomsOverlays_ApplyLayout` without any
   rebuild at all. ⚠ **A recycled frame carries its last occupant's settings** — everything set
   *conditionally* (the OnUpdate animation, texture, texcoord, rotation) must be reset explicitly
   at the top of the build, and shown with `SetShown`, not `Hide`.
   ★ **Also landed, unplanned (the owner asked whether 7 stratas was a Blizzard limit):** the tab
   now offers **all NINE** stratas — `WORLD` and `FULLSCREEN_DIALOG` were missing — plus a numeric
   **Level** row (0–1000) ordering overlays *within* a strata. Every overlay used to draw at the
   same level, so strata was the only separation there was. An overlay that has never set `level`
   still draws at WoW's natural default (read from a real frame, not assumed), so nothing moved.
3. ~~**Modifier symbols (⌘⇧⌃⌥) take no outline/shadow** · `~/GloomsBars`~~ — **✅ CLOSED 2026-07-25:
   DROPPED, WON'T DO** (the owner). *"Leave the glyphs untouched… juice isn't worth the squeeze. I can
   deal with no stroke/dropshadow on the glyphs."* **Do not re-propose it.** No code changed — the
   glyphs stay as unstyled inline PNGs. The full reasoning lives on **GB's handoff item (d)**, which is
   the home of record for it; in short: WoW can never style an inline `|T…|t` texture, and the approved
   fix (a second FontString in a glyph font) hid a **hard prerequisite nobody had written down** — a
   bundled font actually containing U+2318/21E7/2303/2325, which GB does not have, making it a new
   `.ttf` (the suite's one genuine restart case) plus a licensing question, on top of duplicating the
   entire keybind styling + re-assert surface. **No open GB bugs.**
   ★ **The lesson worth carrying:** the cost of a deferred item can be much higher than its handoff entry
   says. This one had read as "fiddly but approved" across three sessions; pricing it properly before
   coding is what closed it in one exchange instead of one session.

**Small / housekeeping**
4. ~~Remove the leftover **`test-remove`** graphic from the Media catalog~~ — **✅ DONE by the owner
   in the Media tab, 2026-07-25.** The StoneTweaks inheritance is out of the catalog.
5. ~~Open question: the stray **`BoordensStreet.otf`** — keep or drop?~~ — **✅ CLOSED: DROPPED**
   (the owner, 2026-07-25). *"OTF fonts don't work in game."* `Fonts/BoordensStreet.otf` deleted;
   **`BoordensStreet.ttf` sits beside it**, so no typeface was lost, and nothing referenced the file.
6. ~~The public repo PAGES expose `CLAUDE.md` + `docs/`~~ — **✅ CLOSED: ACCEPTED, and it is not to be
   raised again (the owner, 2026-07-25).** *"I don't care enough to go with any of the alternatives,
   so it's fine. You can stop mentioning it."* **Do not re-flag this, and do not propose a fix.**
   For the record, so nobody re-derives it: GitHub visibility is **per-repo, never per-path** — there
   is no setting, `.gitattributes` or equivalent that hides a tracked file from a public repo's web
   UI. The only real options were untracking the docs (which would cost SUITE-STATE, the home of
   record, its history and its only off-machine backup) or moving them to a separate private repo (a
   second clone to keep in sync + every `CLAUDE.md` pointer rewritten). Both cost more than the
   problem: the files are identity-clean after TASK 0 and are already excluded from the packaged
   zips, so no installer or friend ever receives them.
7. ~~**Unverified:** do TEXTURE files need a client restart the way new FONTS do?~~ — **ANSWERED
   2026-07-25, in the owner's client: `/reload` IS ENOUGH. The Media tab's Textures note is
   CORRECT — leave it.** Evidence: he re-exported `GloomsAuras/Media/hidden.png` +
   `unhidden.png` from purple to white **over the existing files**, and after a bare `/reload`
   the new art rendered and tinted correctly. That is the *harder* case than a brand-new file —
   the client already had those textures loaded, and it still picked up the replacements — so
   textures are genuinely unlike FONTS, which WoW loads at launch and `/reload` will not
   re-read (HANDOFF 2026-07-25d). Strictly, "a NEW texture file, never previously loaded" is
   still untested, but a cache-busting replacement working makes it a safe assumption.

**✅ Done 2026-07-25 (kept for the record)**
- ~~Dim the background behind `UI.nameDialog` / `UI.confirm`~~ — **DONE + QA'd by the owner
  2026-07-25.** Raised at the end of the Auras rework (the modals are plates in the same near-black
  navy as the panel they open over, so they read as part of the tab). One shared scrim in
  `Skin.lua` serves both: full-screen black, `FULLSCREEN_DIALOG` at the dialog's level −5, so it
  dims the shell (which sits on `DIALOG`) but never the dialog. **It also eats clicks — that is what
  makes the dialogs genuinely modal.** ★ Two calls worth keeping: clicking the scrim does **not**
  dismiss (the family answer is always an explicit OK / Cancel / ESC — a click-elsewhere that
  silently drops a typed name is the same trap as the retired self-arming "Sure?" button); and it
  hides via `HookScript("OnHide")` on both dialogs rather than from the button handlers, because
  that is **the only path that catches the `UISpecialFrames` ESC**, which never runs our own code.
  Alpha landed at **0.72** — 0.55 read as too subtle to the owner on the first pass.
  ★ **No MINOR bump:** internal behavior, no new API, so no consumer's `SKIN_NEEDS` gate moved.
- ~~Phase G QA — WoWup install + update cycle~~ — **DONE**, the plan is complete.
- ~~Redo all four logos, drop the baked-in name text~~ — **DONE.** 512×512 square set; every
  hardcoded portrait draw size moved with it. **GS = the suite, Gh = the Hub as an addon.**
- ~~Small mark beside every tab name~~ — **DONE as `UI.tabHeader` (LibGloomSkin MINOR 4)**, on ALL
  FOUR tabs. Bars, Overlays and Media took it 2026-07-25; **GA followed the same day** once its
  layout rework retired the splash that occupied the space (item 1).
- ~~Overlays has no `## IconTexture`~~ — **DONE.** No more `?` in the addon list.
- ~~Hub's `minimap.png` is only 64×64~~ — **DONE**, now 512.
- ~~Org avatar for `GloomSuite`~~ — **DONE**, the owner uploaded the GS mark.
- ~~Media tab: category counts on collapsed headers~~ — **DONE.**
- ~~Footer shows every addon's version~~ — **DONE**, which also closes the long-open
  **"shared-footer contents"** question.

**Not a task — context:** the owner considers the suite **still in active development and is NOT
ready to share it with friends/guildies yet** (2026-07-25). Don't push distribution work.
When he is ready, it's **four links, Hub first**, and **no access token** — see HANDOFF.
Phase E gate B also promoted the whole profile/preset
mechanism into LibGloomSkin (**MINOR 3**) and switched GB + GA onto it; all three addons were
QA'd in the same pass.

## Phase status — the full QA record for all seven phases

| Phase | What | Status |
|---|---|---|
| — | Scaffold GloomsHub repo + symlink + docs (home of record) | **DONE (not QA'd — no code yet)** |
| **A** | Stand up GloomsHub, media-only (registration + resolver + ST→Hub copy-migration + compat shim + asset folders). Touch nothing else. | **DONE — QA'd by the owner 2026-07-24** (clean BugSack; DrukMedium serves from the Hub; catalog 1 font / 6 textures / 36 graphics, `migratedFromST = true`; Overlays unaffected). Known transition artifact: ST prints "skipped — already registered" lines at login because the Hub (loads first) now wins the LSM names — harmless, ST's own code, gone at Phase F. |
| **B** | Empty tabbed shell + Media tab. Add `/gloom`. Old windows still work. | **DONE — QA'd by the owner 2026-07-24** (window/toggle/Escape/drag; catalog 1/6/36 with previews; accordion + orange scrollbar; add/remove incl. `.otf` rejection; old windows untouched; cold-start re-verified). Two findings baked in: (1) **cold-start blank-text quirk** — WoW draws a cold (font file, size) pair blank the first time each session (a /reload heals, next cold start re-breaks); fixed by Skin.lua's `UI.WarmFonts` login pre-warmer — EXTEND its pair list whenever new UI font sizes appear (Phase C!). (2) overlapping family windows interleave (same strata, pre-existing GB/GA quirk) — accepted by the owner; self-resolves as tools mount tabs (C–E). |
| **C** | Migrate Gloom's Bars as the proof (Bars tab, `/gb` reroute, toolkit → LibGloomSkin). | **DONE — QA'd by the owner 2026-07-24** (gate passed; the one first-pass gap — no suite launcher — was filled same day and verified: the Hub owns the ONE GS minimap button, GB's is deleted). Shipped: `LibGloomSkin-1.0` (surface pinned CONTRACTS §4, incl. `RegisterWarmPairs`); GB hard-deps the Hub; local toolkit + standalone window DELETED; editor mounts as the Bars tab with its own in-tab footer row; `/gb` → `ToggleWindow("bars")` (diagnostics untouched). GB's bar-ENGINE fonts deliberately stay on GB paths (CONTRACTS §1 note). **The container-mount pattern is PROVEN.** |
| **D** | Migrate Gloom's Auras (Auras tab; flip `CatStoneTweaks` → `GloomsHub:ListMedia`). | **DONE — QA'd by the owner 2026-07-24** ("works as it did before"). Shipped: GA hard-deps the Hub; local toolkit copy + standalone window DELETED; options UI mounts as the **Auras** tab (centered 620-wide column; docked drawers parent to the container); `/ga` → `ToggleWindow("auras")`; `/ga minimap` drives the Hub's button; GA's minimap button DELETED; `CatStoneTweaks` → `GloomsHub:ListMedia` ("Suite Graphics" — GA reads NO StoneTweaks data anymore). Shell grew to 860×740 (content 860×626 PINNED, CONTRACTS §2); lib at MINOR 2. Noted for polish at the time: the Auras landing page — **since resolved: the whole tab was reworked 2026-07-25 (to-do item 1), retiring the landing page, the centred 620 column and four drawers.** |
| **E** | Rename VibeOverlay → Gloom's Overlays; mount Overlays tab; **reskin in one go**. | **DONE — QA'd by the owner 2026-07-24. Split into two QA gates** (the handoff's own "QA the migration FIRST" instruction, so a reskin bug can never be mistaken for data loss). **Gate A DONE — QA'd by the owner 2026-07-24**: clean BugSack; addon list shows "Gloom's Overlays", VibeOverlay gone; overlays render identically; `/go list` correct; **Goldset renders on Gloomthorn** (the per-character proof); `/go overlays` + `/go preview` work (still native chrome); `/vibe` retired. **DONE — gate B QA'd by the owner 2026-07-24** (22 steps, all passed, incl. a cold client restart on Gloomthorn/`Goldset` and the GB + GA regression checks). Shipped: the `overlays` tab (order 30) laid out like GB's — a 240 left rail (GO mark + wordmark · the shared profile block · overlay list · Duplicate/Delete) beside a scrolling editor pane, with an in-tab footer (Save & Apply + status); ALL native chrome deleted (no `BackdropTemplate`, `UIDropDownMenu`, `StaticPopupDialogs`, `UIPanel*Template`, and the `MakeButton`/`MakeCheck`/`MakeEditBox`/`MakeSlider`/`SectionLabel` locals are gone); the asset browser is a 360-wide docked drawer opened from the Texture field's **Browse…** (returns the pick via "Use This Texture"); bare `/go` toggles the tab and the old `PLAYER_LOGIN` slash-wrapping in `_Preview.lua` is gone (one router in `GloomsOverlays.lua`); warm pairs registered. **Also, per the owner 2026-07-24 — the profile/preset mechanism is now ONE shared control across the suite** (see the lib row below). |
| **F** | Retire StoneTweaks (delete last, non-destructively). | **DONE — QA'd by the owner 2026-07-24** (all 6 steps; final restart confirmed "all is well" — Stone Tweaks gone from the addon list entirely, Hub registration line unchanged, no BugSack errors). ST is **disabled AND its folder is out of AddOns** (moved, not deleted, to `~/Desktop/StoneTweaks-retired-2026-07-24` — 73 files, count-verified). **`StoneTweaksDB` in WTF was deliberately left in place, so rollback is still just moving the folder back and re-enabling.** Owner-verified after a full client restart with ST off: no `StoneTweaks:` login lines and no `/st` command (ST's own code never loaded — the positive proof, not mere silence); `Gloom's Hub: Registered 1 font and 6 textures into LibSharedMedia.` unchanged; **zero Hub-prefixed "skipped" lines, so the Hub won all 7 LSM names with no third-party collision** (`EnhanceQoLSharedMedia` + `EllesmereUI` are installed and don't clash); `/gh` → 1 font / 6 textures / 36 graphics, `migratedFromST = true`; BugSack clean. **The compat shim is LIVE and proven** — `StoneTweaks_ResolveAssetPath("goldset-player-frame")` now returns the *Hub* path via Core.lua's shim. Both resolver branches (textures + graphics) resolve, DrukMedium serves from `GloomsHub\Fonts\`, **Goldset overlays render on Gloomthorn**, all four tabs open, and the Media tab previews draw. Step 1's offline sweep found: no consumer reads ST anywhere in the four repos **or the whole 105-addon client**; `GloomsHubDB` and `StoneTweaksDB` catalogs were **identical** (ST added nothing post-Phase A); all 43 catalog files exist under the Hub and the three asset folders were the **same file sets**; ST's ElvUI half was provably unused (`frameTextures` empty, `suppressGlow` false). Verified offline, nothing left to migrate: (a) **no consumer anywhere reads ST** — all four suite repos and the whole live AddOns folder grep clean for `StoneTweaks_ResolveAssetPath` / `StoneTweaksDB` / `CatStoneTweaks`; the only live-code hits are the Hub's deliberate compat shim + copy-migration in `Core.lua` (everything else is prose/comments). (b) **`GloomsHubDB` and `StoneTweaksDB` catalogs are IDENTICAL** — 1 font / 6 textures / 36 graphics, same name→file pairs, so ST registered nothing new after Phase A. (c) **All 43 catalog files exist under the Hub**, and `Fonts/`, `Textures/`, `Graphics/` are **byte-for-byte the same file sets** in both addons — retiring ST loses no asset. (d) ST's ElvUI half is provably unused (`frameTextures` empty, `suppressGlow` false), so nothing dies with it. |
| **G** | Packaging/release: `.pkgmeta`, `## Dependencies: GloomsHub`, WoWup. | **✅ DONE — QA'd by the owner 2026-07-25.** The install AND update paths are both proven end-to-end from the new `GloomSuite` org, against a client with the dev symlinks moved aside. **Install:** all four installed via WoWup "Install from URL"; addon list showed every addon with **no missing-dependency flag**; TOC versions read **`v1.0.0`**, not `@project-version@` (the proof the client was loading the packaged copy, not a symlink); BugSack clean; `/gloom` opened the Suite window; **all four tabs registered and rendered**; Media catalog still **1 font / 6 textures / 36 graphics**; **Goldset overlays rendered on Gloomthorn**; WoWup's Author column read **`GloomSuite`** on all four and `HandofDevastation` on Build Barn. ★ **`LibStub("LibCustomGlow-1.0", true) ~= nil` → `true`** — GA's repointed external is proven AT RUNTIME, which mattered because GA loads it silently and `pcall`-guards every glow call, so a missing library would have produced no glow and **no BugSack error**: a clean sack would have read as a pass. **Update:** `v1.0.1` tagged on GloomsBars → packager → GitHub release → WoWup detected and applied it → client showed `v1.0.1`; then the other three were tagged and all four brought back to `v1.0.1`, with `/releases/latest` verified **ANONYMOUSLY** on every repo (the TASK 0 latest-pointer trap did not recur). ★ **A WoWup update needs no full client restart — `/reload` is enough** (the owner, 2026-07-25). This held for `v1.0.0` → `v1.0.1`, and he confirmed it generally: he installs new addons via WoWup and `/reload`s. **The old "new files → FULL RESTART" rule is RETIRED.** **BUILT 2026-07-24 — the build record follows.** **All four addons now publish `v1.0.0`** and every package was verified after the fact. Shipped: `GloomsHub/.pkgmeta` + `release.yml` (the blocker — the Hub previously had neither and so could not publish at all); `GloomsOverlays/.pkgmeta` + `release.yml`; `GloomsAuras/release.yml` (GA had a `.pkgmeta` but nothing to run it). All four workflow runs succeeded first try. **Verified on the published assets:** the Hub zip carries Fonts 8 / Textures 13 / Graphics 45 / Media 8 with all five libs fetched and no docs/CLAUDE.md/.github; GA's zip fetched `LibCustomGlow-1.0`; Overlays ships **no `Libs/` at all** (correct — it loads none and takes everything from the Hub); every TOC has `## Version: v1.0.0` substituted and the three tools all declare `## Dependencies: GloomsHub`; **`/releases/latest` resolves to `v1.0.0` on all four checked ANONYMOUSLY** (the TASK 0 trap — it did not recur); zero identity in any of the four packages. ★ **Two real defects were caught by doing this, both now fixed:** (1) **the published `GloomsBars` v0.2.0 was NOT merely "broken for a missing dep" as the Phase F handoff claimed — it was tagged at a 2026-07-18 commit, PRE-Phase-C, shipping only `Core.lua` + `Skin.lua` with no config UI and NO `## Dependencies: GloomsHub` line at all.** It was stale by three phases, not dependency-broken; the v1.0.0 re-cut is what actually fixes it. (2) **GA's `LibCustomGlow-1.0` external was dead** — the wowace SVN path `wow/libcustomglow-1-0/trunk` 404s (the other five externals all resolve), so GA's very first packaged build would have failed. Repointed at the maintained upstream `Stanzilla/LibCustomGlow`, whose repo root holds exactly what `Libs/LibCustomGlow-1.0` holds locally; the fetch is confirmed working in the shipped zip. Also tightened GA's `ignore:` (CLAUDE.md + docs were being packaged into its zip). **Version scheme (the owner, 2026-07-24): all four at `v1.0.0`, synchronized** — the suite is feature-complete, and a friends/guild audience should have one answer to "what version are you on?" GB jumped `v0.2.0` → `v1.0.0`. Install instructions for the non-dev audience are in [../README.md](../README.md) (Phase G item 5). ★★ **SUITE-PLAN's "embed LibGloomSkin as an external per tool" was DROPPED** (struck out in the plan itself, 2026-07-24). No tool ships or loads its own copy; all three just call `LibStub("LibGloomSkin-1.0")` and resolve to the Hub's `Skin.lua`. The hard-dependency lock guarantees the Hub is present, so embedding would create N copies for LibStub to arbitrate — precisely the drift the suite exists to prevent — and there is no standalone repo to fetch as an external anyway. Its **prior** blocking prerequisite, the identity scrub, is ✅ **DONE (2026-07-24)** and **all five repos are PUBLIC again, so WoWup delivery is restored.** History was rewritten with `git-filter-repo` across all five (content + commit messages + author/committer metadata). `GloomsBars`, `GloomsAuras` and `GloomsBuildBarn` were then **DELETED AND RECREATED** — see the lesson below — while `GloomsHub` and `GloomsOverlays` were newly created that day and only ever received scrubbed history. Verified **unauthenticated against the public repos**: pre-rewrite SHAs return 422, current commits 200, and zero identity in commit metadata, messages, all-history blobs or release ZIPs. Org membership is still private; releases are authored by `github-actions[bot]`. ★★★ **THE LESSON: a force-push does NOT purge — it only unlinks.** Old commits stayed on GitHub and were served the instant the repos went public (~2 min exposure before revert). **A 404 while a repo is private proves nothing** — that endpoint 404s for any SHA. Only delete-and-recreate purges. Two further traps, both in HANDOFF.md: (1) **published release ZIPs are a separate surface a force-push cannot reach** — GB's assets carried the name and were rebuilt by re-pushing tags; (2) **Build Barn's remote was AHEAD of its local clone** (its cron writes commits and tags directly on GitHub), so an early push rolled its `main` back a fortnight before recovery from the surviving tags — nothing lost, `BuildData.lua` verified byte-identical. |

## Open questions, all since closed

Where the Overlays GO logo belongs inside the tab (NOT a splash — see the polish backlog).
(~~shared-footer contents~~ — CLOSED 2026-07-25: the footer lists every installed addon's version.
~~stray `BoordensStreet.otf`~~ — CLOSED 2026-07-25: **dropped**, see to-do 5.)
(~~compat-shim lifetime~~ — CLOSED Phase F step 6: **KEEP PERMANENTLY**, the owner 2026-07-24.
Pinned in CONTRACTS §3 + commented in Core.lua. Do not "clean up" the shim.)
(~~LibGloomSkin public surface~~ — CLOSED Phase C, pinned in CONTRACTS §4. ~~Hub logo~~ —
CLOSED, the owner delivered the GS monogram 2026-07-24. ~~Overlays slash name~~ — CLOSED Phase E
gate A: **`/go`, and `/vibe` is retired outright**, the owner 2026-07-24. ~~Overlays logo placement~~
— CLOSED Phase E gate B: a small GO mark + wordmark at the top of the tab's left rail, NOT a
splash. ~~Overlays profile picker~~ — CLOSED: the shared `UI.profileBlock`.)

## The suite polish backlog, all since closed

> **The first two Auras entries below are CLOSED by the 2026-07-25 layout rework** (to-do item 1).
> Kept for the reasoning that drove them.
- **Auras tab landing page (the owner, Phase D QA 2026-07-24):** ✅ **DONE — the splash is retired.** the old standalone window's
  splash/landing (big GA logo + "Add … Aura" buttons on every open) "doesn't really make
  sense in the context of the suite." Works as before for now — rethink after the
  migrations (e.g. open straight to the editor with a compact create row, logo retired or
  moved). GA-side change; coordinate the design with the family language here.
- ✅ **DONE 2026-07-25.** **The Auras tab needed a LAYOUT REWORK, not a tweak (the owner, Phase E gate B QA 2026-07-24):
  "we've got to get rid of the drawer, but the whole layout of this module is now very wrong."**
  Deferred to its own session by his call. Scope so far: kill the docked profile drawer in favour
  of a GB-style always-visible rail (gate B put the shared `UI.profileBlock` inside the existing
  drawer, so the mechanism matches GB/Overlays but is still hidden behind a footer button); the
  landing page above; and a general pass against GB's layout language now that GB is the
  reference. Treat the whole Auras tab as the unit of work — these all redraw the same surface.
- ✅ **DONE + QA'd 2026-07-25.** ~~**Overlays: Width / Height / X / Y should be SLIDERS, not typed
  boxes (the owner, Phase E gate B QA 2026-07-24).**~~ "It just needs to happen." Shipped as
  `UI.sliderRow` + a typed box in the row's value slot, in two columns, with the nudge arrows
  kept — full record in to-do item 2 above.
- **★ GB is the UI reference for the suite, not GA (the owner, 2026-07-24).** When a pattern
  exists in both, copy Gloom's Bars. The two backlog items above are why.

---

## Font redistribution terms — CLOSED by the owner, 2026-07-26

Backlog item 4 asked whether the **Fontshare** licence permits shipping the General Sans `.ttf`
files inside the addon zip, as distinct from *using* the typeface. It was never answered:
`https://fontshare.com/terms` is JS-rendered and no tool available in-session could retrieve it.

**The owner closed it without that answer.** What ships stays as it is — **Khand** under SIL OFL 1.1
with `Media/fonts/OFL.txt` beside it (which is what the OFL requires), and **General Sans** with the
credit its own `name` table asks for, carried in `Media/fonts/FONT-LICENSES.md`.

Recorded plainly so nobody re-opens it as diligence: the terms were **not read**, and the decision
was to proceed anyway. Both fonts are distributed free by their foundries. Re-raise only if a
foundry actually objects.

---

## The suite's own colour picker — SHIPPED and fully QA'd, 2026-07-26

`UI.colorPicker` (LibGloomSkin MINOR 6) replaced Blizzard's `ColorPickerFrame`, **the last native
frame anywhere in the suite**. Full contract in [CONTRACTS.md](CONTRACTS.md) §4; the locked design
decisions are in [SUITE-STATE.md](SUITE-STATE.md). Recorded here only as the QA record.

**Owner-QA'd in-client the same day, every path:**
- Gradient drag applying live · dragging the panel · nothing dimmed behind it.
- Right-click removal, surviving `/reload`, on a colour still live on an element.
- Drag-then-OK adding exactly ONE colour — the fix for the ~60-intermediate-colours-a-second flood.
- Re-picking a removed colour bringing it back.
- Per-aura provenance naming each aura.
- **The Opacity row**, live alpha on the element, and the panel growing DOWNWARD when it appears
  after a plain picker at the same dragged position.
- **GA's cancel-back-to-UNSET** — the case where the picker seeds white on a nil colour and a plain
  restore would have applied white to a control that was never set.
- **Closing the Suite window with the picker open** — picker closes AND the colour reverts.

**Two claims made and corrected mid-session, kept so they are not re-derived:**
- ~~"Roughly half of GB's swatches are selection-scoped, reading the selected bar."~~ **WRONG.**
  GB's colours are one per PROFILE (`GB.db.styleData`, `GB.db.triggers`), which is why GB needs no
  enumerator while GA and Overlays do.
- ~~"GA is the only selection-scoped tool."~~ **Overlays was too** — its Tint reads the selected
  overlay. Both got providers.

---

## MM Hunter auras on 12.1 — CLOSED, `TESTED` safe, 2026-07-26

Backlog item, opened 2026-07-25 with a deadline of Season 2 (~2026-08-19). **Closed by testing, and
its premise was disproved.** The entry assumed Precise Shots and Spotter's Mark might be
*duration*-driven and so land on FINDINGS §1's broken path, on the spec the owner actually plays.
They are not — every display in his MM Hunter group triggers on presence or cooldown readiness.

Proven on PTR 12.1.0.68914 across 14 `/ga capture` probes at a dummy, both structural classes
(`hasAura=false` and `hasAura=true`), read from `GloomsAurasDB.probeLog` on disk. The presence
signal sets *and* clears in combat, and the owner confirmed the display drew on screen. Full record
in [FINDINGS.md](FINDINGS.md) §7.

**Two things it cost, both now in [LESSONS.md](LESSONS.md):** the 255-character chat-input limit
that silently truncates a `/run` one-liner, and the discovery that secret values propagate through
string formatting and then vanish from SavedVariables without an error — which made 14 saved
captures look like 8 and produced a confident, wrong "your data didn't save."
