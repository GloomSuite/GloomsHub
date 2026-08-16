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

## ★★ "Impossible" is a claim about your search, not about the world

**2026-08-03 cost most of a session to this, in front of the owner, repeatedly.** The shape:

> A sweep tested one *family* of things exhaustively, concluded a capability was impossible, and
> stated it flatly. A competing addon was visibly doing the thing on the same client at the time.

Concretely: every sink in the `Cooldown` widget family was tested against a secret value, with a
proper plain-number control, and all refused. That produced *"aura timers are impossible on 12.1."*
**`StatusBar:SetValue` had never been tried. It accepts secrets, and it is the whole answer.**

**The rules that follow, in order of how much they would have saved:**

1. **If something demonstrably works elsewhere, your impossibility proof is wrong. Full stop.** The
   owner said "ArcUI does this." That is a counter-example, and a counter-example beats any amount
   of reasoning. **Go find the actual API call in its code — not the first plausible mechanism.**
2. **Read to the CALL, not to a candidate.** Three separate wrong theories about ArcUI were produced
   by grepping, finding *a* mechanism that could explain the behaviour, and stopping: a
   `customDuration` stopwatch (the owner had **zero** configured), a `barFrame.Bar` mirror (his
   Tracked Bars was **empty**), and a `GetAuraDurationRemaining` read (the function **doesn't exist**
   on this build). Each was checkable in one command and none was checked before being asserted.
3. **Check the addon's own SavedVariables before theorising about its behaviour.** `grep -c` on its
   config would have killed theories 1 and 2 in seconds.
4. **Prefer the target's own diagnostic.** ArcUI ships `/arcsec`, which reports whether it reads
   aura data at all. One command; it was available from the first minute and used near the last.
5. **A table that tests one axis reads as exhaustive and is not.** FINDINGS §1's escape-route table
   asked "can we READ it?" for five channels. Nobody noticed for a week that "will a SINK take it?"
   was never asked. **When you write a table like that, name the axis in the heading.**

## ★★ Label inference and measurement differently, in every sentence

Same session, same root cause as the near-miss this whole evidence-tag system exists for — except
in conversation rather than in a document, where no tag was there to force the distinction.

Wrong calls stated in the same flat voice as measured results, in one evening: that the owner's
displays would appear (**his group was switched off**); that he should disable `EnhanceQoL` (**it
owns media files GA points at**); that he could stand out of combat with a DoT ticking (**he can't**);
that a sticky-value bug would appear (**it didn't**); that timers were impossible (**they aren't**);
that Tracked Bars was required (**it isn't**).

**The fix that worked, once adopted:** state the basis before the claim — *"grounded in measurement:
X"* / *"inference only: Y"* — and, for anything predictive, **write the prediction down before the
test and let the result stand against it.** The owner explicitly asked for this. It is cheap, it
makes being wrong harmless, and it is the difference between a session that converges and one that
burns an evening. **When he says he doesn't remember it that way, treat that as data, not as a
memory lapse to correct** — on 2026-08-03 he was right about the record being overstated, twice.

**And do not suggest asking an addon author for help.** They are unpaid and it is not their addon's
problem. Read the code.

---

## ★★ When two things draw in the same rectangle, prove WHICH one you're seeing

**2026-08-12 cost three wrong theories to this.** GA's bar and the 12.1 duration engine's borrowed
`AuraButton` occupy the identical screen space. "The texture I picked does nothing" produced, in
order: *the engine overwrites our texture* · *the paint happens before the attach wipes it* · *the
region is forbidden*. All three were about mechanism. The actual answer was that the visible pixels
belonged to the **other widget** — the editor preview forces GA's bar empty, and out of combat there
is no aura for the engine to draw, so a correctly-applied texture had nothing to appear on.

Earlier the same day, the same mistake in mirror image: a working drain looked frozen because GA's
own full bar sat underneath it **in the same colour**.

**The rule: before asking why a visual is wrong, establish which widget owns those pixels.**

- **Tint one of them a colour nothing else uses.** Bright green settled the frozen-drain question in
  a single test, after a paragraph of speculation had settled nothing.
- **Read the value back.** `GetStatusBarTexture():GetTexture()` immediately before each overwrite
  proved our writes were sticking and killed the "engine overwrites it" theory outright.
- **Ask what is DIFFERENT about the case that works.** "It appears if I nudge a slider" was the whole
  answer in plain sight: the slider fires one extra refresh *after* the code that blanks the bar.
- **Overlapping widgets need a frame-level story, not a draw-layer one.** A `FontString` can never
  out-draw a higher frame level whatever its layer — the readouts needed their own frame.

## ★★ A comment in someone else's addon is not evidence

Reference implementations are for reading CODE, not for inheriting CLAIMS. Both of these were taken
on faith from ArcUI and both were wrong or unverified:

- **Its file header documents a two-slot design the code abandoned** — it creates one slot. The most
  authoritative-looking block in the file was stale. Read the function, not the banner.
- **"In-combat container creation is a hard Lua error"** was copied into our own FINDINGS as fact and
  then used to justify deferring — which, after a mid-fight reload, meant no duration bars for the
  rest of the fight. **Nobody had ever tried it.** A `pcall`'d attempt costs nothing and answers it.

**If a borrowed claim is load-bearing, test it before building a limitation around it.** Related:
FINDINGS §1 itself carried "AuraContainer follows target swaps by itself", written from reading, and
the reference implementation's own workaround disproved it.

---

## ★★ Saved is not applied — find the LOAD call site, not just the SAVE

GB's per-character profiles stored correctly, showed the right name in the dropdown, and survived
reloads — and never applied. There was a `SavePreset` on logout and **no `LoadPreset` at login**, so
every character rendered the last-played character's look and then overwrote its own saved copy with
it. It looked like a working feature for months (FINDINGS §11).

**The trap:** persistence bugs hide behind a *round trip that happens to be symmetrical*. Reloading
on one character looked perfect, because logout saved the live look and login loaded that same
preset back — an identity operation that proves nothing. The bug only shows when the thing you load
should DIFFER from what you last saved.

- **When state is per-something (character, profile, spec), grep for the load call site by name.**
  Its absence is a static fact you can establish in one command — far stronger than any amount of
  in-game poking.
- **Design the test so the expected value differs from the current one.** "It still looks right
  after a reload" is the persistence equivalent of a clean BugSack: consistent with working, equally
  consistent with nothing happening at all. See "silence is not evidence" above.
- **A shared account-wide db plus a per-character pointer is the shape that breeds this.** The
  pointer being right is not the feature; the load is.

## ★★ When the owner says a UI is confusing, read the code before agreeing OR reassuring

He asked what GB's profile buttons actually did. Answering from the docs would have produced a
confident, wrong answer twice over: the tooltip said New "starts from the current look" (true, and
the reason it was confusing), and there is no auto-created "Default" **profile** in the code — but
his live saved data had one, because he had made it himself.

**Read the implementation, then read his actual SavedVariables.** The second one is cheap (`lua -e`
over the file in `WTF/Account/<ACCOUNT>/SavedVariables/`), it is ground truth, and on 2026-08-15 it
turned a UI-wording question into a real bug fix. **His confusion was a correct signal about the
design, not a gap in his understanding** — the naming genuinely lied.

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
- **★ N-for-N on a handful of samples is a coincidence, not a mechanism.** Chasing a taint bug on
  2026-07-30, a scan showed the three addons that triggered it all used Blizzard's shared ScrollBox
  API and the one that didn't scored zero — five for five, including a negative control. It was
  presented as the explanation, complete with a table. The owner's next test produced a trigger
  scoring **zero**. **Before publishing a rule from a correlation, go looking for the counterexample
  yourself** — and if the sample is under about ten, say "consistent with" rather than "the cause".
- **★ Before declaring a question OPEN, read the existing `TESTED` table in the finding you are
  updating.** On 2026-07-30 a 12.1 API digest produced an exciting "the whole item hinges on this
  untested question" — and FINDINGS §1 already contained a table showing three of the four channels
  had been probed a week earlier and all returned nil. The genuinely untested piece was one sibling
  function, with a low prior. **A doc system only stops confidence laundering if you read the part
  that contradicts you before you write.**
- **★ Ruling something out as the CAUSE does not rule it out as a DEFECT.** On 2026-07-26 the gold
  Quick Keybind square was correctly shown not to block the binding — and then written into FINDINGS
  as *"the gold overlay is innocent"* and waved off three times running. It was in fact the one
  button-state texture GB's skin had never adopted, drawing unmasked and oversized on every shaped
  icon. **The owner had to raise it a fourth time** — *"I've mentioned it several times, and you
  don't say anything about it"* — before anyone looked. It was the only real bug the whole session
  produced. **When he keeps returning to the same detail, that is data. Go and look at the thing
  instead of re-explaining why it isn't the culprit.**

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
  ⚠ **This was already written here — twice — and it happened AGAIN on 2026-07-26**: a 268-character
  probe went to the owner and failed on his first paste. Knowing the rule did not stop it, so the
  rule needs a mechanical step, not more prose: **before sending any `/run` line, count it**
  (`printf '%s' '<line>' | wc -c`) and shorten until it fits. A lesson that only fires when you
  happen to remember it is not doing its job.
- **macOS `sed` has no `\b`.** Verify identifier renames with a token count, and `luac -p` every
  touched file.
- **macOS ships bash 3.2, so `mapfile`/`readarray` do not exist.** A `.command` script using them
  dies with `command not found` the moment the owner double-clicks it. Read-loop into an array
  instead, and `bash -n` is not enough to catch it — run the thing.
- **★ A helper that takes a SUB-OBJECT cannot carry its owner's context.** GB resolves per-bar preset
  values through a `presetCtx` that is set from a *button*. `applyTexCoord(icon)` takes the icon, so
  it can never be wrapped by `withPresetCtx` and depends **entirely** on whatever context its caller
  happens to have. Three top-level loops had none, and every bar silently re-cropped at the working
  copy's zoom instead of its own preset's — the owner saw one slider move every bar on screen.
  **This class has now bitten twice in the same file**: `Skin.lua:1408`'s comment records the earlier
  round, where icon *size* did the same thing. **When a live setter or refresh path loops over
  buttons, enter the per-button context — do not assume the helper can fetch it.** The audit worth
  repeating: list every `ForEachButton` loop and check each one supplies context. Ten loops, eight
  already correct, two wrong.
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
- **★ `/fstack` answers "what is DRAWN on top here?", never "what has MOUSE FOCUS?"** Its `-->` arrow
  marks the topmost frame under the cursor whether or not that frame is mouse-enabled. On 2026-07-26
  two sessions' worth of diagnosis — a named culprit, a table of frame levels, a proposed one-line
  fix — rested on reading that arrow as focus, and GB was one step from being changed to fix a bug it
  never had. The tell was in the same screenshot: the arrow marked a GB decor frame that `grep`
  proved was never `EnableMouse`d. **Mouse focus is `GetMouseFoci()` and nothing else.**
- **A button's optional textures may not EXIST yet when you skin it.** Blizzard creates
  `QuickKeybindHighlightTexture` only when Quick Keybind Mode first opens, so
  `if btn.QuickKeybindHighlightTexture then …` inside the skin's one-time setup was never true. It
  raised nothing, logged nothing, and read as handled. **A nil-guard around a lazily-created widget
  is a silent no-op** — do the work where the thing is guaranteed to exist (an event, a mode opening,
  a hook that fires after Blizzard built it), not where it is convenient.

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

- **★ Never frame a bug by WHICH SESSION introduced it.** On 2026-07-26 a regression report was
  answered twice with "not from today's changes, here's the diff". The owner's reply: *"I don't care
  if it happened today or in a previous session — you're the only one coding, so it's ultimately your
  responsibility, so don't be defensive. This is ALL your project."* He has one codebase and one
  coder; provenance is a distinction that serves the assistant, not him. **Establishing that a change
  is unrelated is useful once, to narrow the search — as a framing for the answer it reads as excuse
  making.** Say what is broken, say what fixes it, fix it.
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
