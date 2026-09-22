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

## ★★ A state mirror is not an event bus — judge the transition, not the source

**2026-08-24, GA. Two consecutive fixes failed on this.** `CDM.available` had always been a *state*
mirror: several writers keep it current, and a brief disagreement between them just re-settles. That
is fine — and it is exactly why it was NOT safe to hang sounds off every write to it.

- Making every writer sound-eligible **double-fired**: a polled reconciler and an event hook
  disagree by a second or two around a cooldown ending.
- The obvious correction, **"only real events may speak," was WRONG** and shipped a worse bug: the
  polled reconciler turned out to be the *only* witness to a genuine 60s cooldown completion, because
  `CooldownFrame_Clear` is not reliably fired. Silencing reconcilers silenced a real event.

**★ The rule: when converting a state variable into an event source, do not classify by WHO wrote
it. Judge the transition on its own merits.** A cooldown that lasted 60s is real whoever noticed; one
that "ended" 0.0s after it started is a flicker whatever fired it. A duration test is source-agnostic
and survives an unreliable signal; a source test hard-codes an assumption about which signal is
trustworthy, and that assumption is what breaks.

⚠ **Related, same session: a debounce is not free.** A 0.35s settle timer added to collapse the
double-fire went on to swallow real sounds — a spell came up and was cast 0.22s later, so the window
closed on the wrong value and said nothing. Prefer a test on the data over a timer on the clock.

---

## ★★ Scripts that read SavedVariables MUST be profile-aware

**2026-08-24 — this produced two confidently wrong diagnoses in one session.** `GloomsAurasDB` and
`GloomsBarsDB` hold **one profile per character**, and display/preset IDs restart inside each. The
owner has eleven characters, so `["d18"]` exists many times in one file.

A regex or scan that takes the **first** match reads a random character's config. That is how a
session twice told the owner his Warlock's Infernal aura had "leftover Hunter triggers" — it was
reading a Hunter alt's profile, and the advice was to break a display that was correctly configured.

**Resolve the active profile first** (`profileKeys[<char> - <realm>]` → `profiles[<key>]`), then read
inside it. If you cannot tell which profile is active, say so instead of guessing.

---

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

## ★★ A self-check routed through the mechanism it is checking will lie

If a diagnostic answers its question by performing the very operation known to be unreliable, its
first answer is not evidence — it is a sample of the unreliability.

The Hub warms fonts at login because **the first draw of a cold font misbehaves** — that fact was
measured and written down in 2026-07. The existence probe was then built on top of warming, and took
the result of that first draw as proof the FILE was missing. It therefore accused every drop-in font
on every cold start, and never on `/reload`, for six weeks. The refutation was already in the
comment directly above the code.

The tells, all present and all missed until 09-08:
- **It only fired on a cold start.** A fault that disappears once something has been touched once is
  a warm-up artefact, not a missing file.
- **It fired on 100% of one category** (user drop-ins) and 0% of another (bundled). Systemic, not
  per-file — so stop inspecting individual files.
- **The user said it works.** "It says X is broken but X works" usually means the CHECK is broken.
  Verify the claim, but do not open by assuming the reporter is wrong.

**Ask of any check: what does it do to find out, and is that thing reliable the first time?** If the
answer is no, the check needs a second pass before it is allowed to accuse anything.

## ★★ When you retire a broken approach, hunt every SIBLING that still uses it

Fixing the instance you were shown is not fixing the bug. If a mechanism turned out to be unsound,
every other place using that same mechanism is already broken — it just has not been reported yet.

On 2026-08-24 the empty-slot collapse was moved off "hide the container" onto an alpha treatment,
because Blizzard re-shows containers in combat where GB is gagged (FINDINGS §13). A comment was even
left saying *do not reinstate the hide here*. **The line immediately below it still hid containers**
— the per-bar button COUNT path — and stayed broken for twelve days until the owner hit it. Same
function, same file, same screen, one line apart.

The tell was there in the write-up: it named `ActionBarMixin:UpdateShownButtons` as re-showing "the
container of every in-range slot". Anything that hides a container was therefore already doomed, not
just the one being fixed. **A finding that explains WHY something is unsound has told you the blast
radius — go and grep for it.** `grep -n "SetShown" Layout.lua` would have found it in seconds.

Ask, every time a fix lands: *what else does this exact thing?* Then actually look.

## ★★ Pick the test that can FAIL LOUDLY, not the test that is typical

When you hand the owner one step to verify a change, choose the input where a working feature and a
broken one look **maximally different** — not the one you imagine he'd use.

On 2026-08-25 a new shape-mask feature was verified by asking him to apply `roundsq1` to an aura.
That shape crops **1.2%** of the icon rect, and the texture he had on it measured 0–30 alpha out of
255 in exactly the corners it removes. He reported "the texture didn't suppress or go away." The
mask had been working perfectly the whole time; `diamond` (50.1%) proved it in one click. The round
trip cost a reload and a chunk of his evening, and it very nearly triggered a hunt for a bug that
did not exist.

The same mistake in the other direction: the first rotation test suggested a texture that might have
been a **circle**, which spins invisibly. Caught before it was sent, but only just.

**The rule:** before asking him to look at something, ask *"if this were broken, would this test
look different?"* If the answer is "not much", it is the wrong test. Measure the extremes first —
`sips`, a pixel count, a quick decode — and pick from data, not intuition. **A test that cannot
fail visibly is not a test; it is a way to launder a guess into a confirmation.**

## ★★ When the owner says a UI is confusing, read the code before agreeing OR reassuring

He asked what GB's profile buttons actually did. Answering from the docs would have produced a
confident, wrong answer twice over: the tooltip said New "starts from the current look" (true, and
the reason it was confusing), and there is no auto-created "Default" **profile** in the code — but
his live saved data had one, because he had made it himself.

**Read the implementation, then read his actual SavedVariables.** The second one is cheap (`lua -e`
over the file in `WTF/Account/<ACCOUNT>/SavedVariables/`), it is ground truth, and on 2026-08-15 it
turned a UI-wording question into a real bug fix. **His confusion was a correct signal about the
design, not a gap in his understanding** — the naming genuinely lied.

## ★★ A filter that silently passes EVERYTHING looks exactly like a filter that works — on a quiet character

GU's "This spell" highlight was owner-QA'd on the Warlock with Burning Rush, and it looked right:
the icon appeared with the buff and vanished without it. The HARMFUL half of the same control had
never filtered anything — but the Warlock never had a debuff on himself in a city, so an unfiltered
slot showed nothing, which is what a correctly filtered one shows too. The DK's first login had a
permanent zone debuff on him and the broken half lit up at once (FINDINGS §20.6).

**When you verify a filter, verify it with something it must REJECT present.** "Shows the right
thing when the right thing is there" is half a test; the other half is "shows nothing when only
wrong things are there", and it needs a wrong thing on screen. Ask what the QA character could not
have had, and go get one — a different class, a zone effect, a mob's bleed.

## ★★ A settings box commits when you LEAVE it — Enter-only is a bug, not a style

GA's PLAYER POWER value box committed on Enter only. The owner typed 5, clicked away, and the box
kept reading 5 over a stored 1 — the aura fired at any combo point, and he found out in a fight.
There was no indication that Enter was required, and he reasonably assumed "type it and close the
window" was enough. Two more Enter-only setting boxes were found in the same sweep.

**Every box that stores a setting commits on focus-lost** — click, Tab, closing the window — so
what the box shows IS what is saved. Enter just clears focus. Escape restores the stored value
BEFORE it clears focus, so an abandoned edit does not commit. Boxes that feed a button (a name
dialog, an "add" form, a nudge step read at click time) are the only Enter-driven ones. The Hub's
`flatEditBox` (MINOR 10) gives every box Tab / Shift-Tab and Up / Down so the pattern has a home;
GU's `cNum` shows the live-stepping hook.

## Verification & evidence

- **★ `AuraData.spellId` — lower-case d.** A probe reading `d.spellID` printed `nil` for every aura
  on the player and was written up, for ten minutes, as "12.1 strips spell IDs from aura data". It
  does not. Print the field list before concluding a field is absent.
- **★ An accumulating diagnostic counter must say WHAT it counts.** `/ga auradur`'s
  `deferred=1628` read as "1,628 style changes waited for combat to end"; it was 1,628 feeds that
  had nothing to change and were logged before the change-check ran. A counter incremented before
  the cheap "is there anything to do" test measures call volume, not work — label it that way or
  move the test first.
- **★ "Owner-QA'd" means QA'd on the class he was playing. Say which paths that class cannot reach.**
  On 2026-09-20 three bugs in the cast ring's interrupt colouring surfaced in one evening — an
  evaluator argument out of range, a tint painted onto empty geometry, a recolour undoing the alpha
  gate — because the code had been "owner-QA'd" on a Warlock, who has no interrupt, so `KickExtras`
  had never executed. Each was a first-run bug, not a regression, and the owner read them as the seam
  work coming undone. When a feature is gated on class/spec/talent (an interrupt, a resource, a
  pet), the handoff must name it as `UNTESTED` until a character that has it has run it.
- **★ A control that "does nothing" is usually a callback that DIED.** The colour picker applies
  live through `set()`; `set()` re-lays the frame out; the layout was throwing on an unrelated nil
  (the shield arc refreshed before it existed) — so the swatch never got told to repaint and the
  owner reported "I cannot change the colour." Before diagnosing a UI control, ask for BugSack
  from the moment of the click: an error inside the apply path presents exactly like a dead control.
- **When a measurement is too fast to take by hand, make the addon take it.** A delve mob's cast is
  two seconds; `/gu debug target` could not be timed against it and the owner rightly gave up.
  A trace that prints on CHANGE (`/gu casttrace`: one chat line per route change) answered in one
  pull what three attempts at manual timing could not. Same family as "keep diagnostics in the
  addon, a `/run` over 255 chars does nothing" — the diagnostic must also fit the event's timescale.

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

- **★ `Skin.lua` ends the lib body with `end   -- if lib` — anything pasted AFTER that line is
  outside the lib.** On 2026-09-21 the whole kit (300 lines) landed after it: `UI` and `COLOR` were
  nil there, the first `UI.x = …` raised at load, `LibStub` never got the lib, and every consumer
  died with six unrelated-looking BugSack errors (`attempt to index field 'UI'`, `MEDIA` nil …).
  `luac -p` passes it. When adding to the lib, insert BEFORE the "Hub-side aliases" section and
  check with `grep -n '^end   -- if lib'` that the new code sits above that line. A stubbed WoW
  API smoke test (`scratchpad/stub.lua` that session — a `CreateFrame` returning tables whose
  unknown METHODS are no-ops and whose unknown DATA fields are nil) catches this class in a second.
- **The Claude desktop app's Figma connector can say "connected, 0 tools" while the server is
  fine.** Do not wait for it or tell the owner his Figma is closed: `curl` the server
  (`127.0.0.1:3845/mcp`) — if `initialize` answers, drive it with `~/GloomsHub/tools/figma.py`.

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
  ⚠ **And AGAIN on 2026-09-19 — a 271-character probe, and this time it produced NOTHING**, not
  even an error the owner could see, so it read as "the API is dead" for a round trip. The rule that
  finally stuck: **do not hand the owner a `/run` at all. Put the probe in the addon as a slash
  subcommand** (`/gp plates`, `/gp probe`) — no length limit, printable labels, and it stays for the
  next session. Count with `printf '%s' '…' | wc -c` if a one-liner is unavoidable.
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

- **★ An EditBox shows the TAIL of text that does not fit.** A 42px readout holding "-700px"
  displays "0px" — the cursor sits at the end after `SetText`, and the box scrolls to it. On
  2026-09-21 this read as "the value has no relation to reality" and cost three rounds before the
  logic (which was right) was suspected of the wrong thing. Size a readout to its WIDEST possible
  string (measure `fmt(min)`, `fmt(max)` with a hidden FontString) and `SetCursorPosition(0)` after
  each `SetText`. Also: an EditBox KEEPS keyboard focus when you click elsewhere — a control that
  shares a readout with a box must take the focus away itself (without committing) or its own
  updates get suppressed by the "don't overwrite while typing" guard.
- **`Texture:SetTextureSliceMargins` + `SetTextureSliceMode` work on 12.1** with a non-power-of-two
  16×16 PNG — that is how every 4px-cornered kit widget is drawn from ONE file (`Media/ui/round4.png`,
  margins 5). `SetVertexColor` tints a sliced texture normally. An 8×16 capsule sliced top/bottom
  only makes the scrollbar.

- **★★ NEVER TRUTH-TEST A SECRET; CARRY A PLAIN `ok` IN FRONT OF IT.** On 2026-09-19 the first
  draft of the class-color code did `cr and {cr, cg, cb} or default` on a channel that can be
  secret — a boolean test on a secret is a Lua error, and it only fires on the identity-restricted
  unit you were not testing on. EllesmereUI's shape is the right one: functions that may return a
  secret return `ok, r, g, b` with `ok` PLAIN, callers branch on `ok` and hand `r, g, b` straight to
  a setter. The same rule killed `host:IsVisible()` under an aura button (FINDINGS §20): the
  answer was a secret boolean, and the `if` threw.
- **★★ UNDER A BLIZZARD AURA BUTTON, YOUR FRAMES ARE DEAF.** A child frame you create inside
  `initializeFrame` never runs a script — not `OnShow`, not `OnHide`, not even `OnUpdate` (FINDINGS
  §20, measured at zero events). Your REGIONS stay writable. So anything that must happen "when
  the aura appears" cannot be triggered; it has to be set up at wiring time and simply live under
  the button, with the engine's show/hide doing the rest. The Hub's effects were reworked to verify
  their own mask bind for exactly this (a bind on a not-yet-drawn texture fails silently, so
  `GetNumMaskTextures` is the check and a 0.5 s retry the cure).
- **★ A SECRET ZERO IS IGNORED — WHICH MAKES A PRESENCE GATE.** The §18 trap ("alpha 0 from a secret
  keeps the last opacity") is also a tool: plain `SetAlpha(0)` then `SetAlpha(secretAmount)` shows
  a frame iff the amount is non-zero, with no number ever reaching Lua. The shield wash is built
  on it (FINDINGS §19). Test the OFF state with a secret that IS zero — a permanently shielded
  Warlock never sees it on the real ring.
- **★ THE SHAPE OF THE DOOR DECIDES THE FEATURE, NOT THE SECRECY OF THE VALUE.** A straight bar
  gets an absorb fill for free (`StatusBar` takes secrets and the engine sizes it); an arc needs an
  angle, and the only secret→angle door is a percent function evaluating a curve — which absorbs
  were never given (§19). Before promising a display, ask which SINK will draw it and whether the
  value has a road to that sink; "EUI shows it" only proves EUI's sink exists.
- **★★ A SETTER THAT ACCEPTS A SECRET MAY STILL DO NOTHING — the picture is the test, never
  `pcall`.** On 2026-09-19 (FINDINGS §18) three setters took a secret without complaint and ignored
  it: `SetPoint` (region lands at 0,0), `SetAlpha` on a texture carrying `SetGradient` (stays
  opaque), and `SetAlpha` with a secret that evaluates to exactly ZERO (keeps its last opacity — a
  secret is not allowed to decide visibility). Each cost an hour of chasing "geometry" that was
  right. When a secret sink is in doubt, render its value as TEXT next to the thing it drives
  (`SetFormattedText` takes secrets) and compare what the number says with what the pixels do.
- **★★ TWO ANTI-ALIASED EDGES ON ONE LINE ARE A SEAM, AND TWO LAYERS ON ONE SOFT EDGE LEAVE A
  RESIDUE.** 50% coverage over 50% coverage composites to 75%, not 100% — visible on an opaque
  fill, invisible on a translucent track, so the two want OPPOSITE fixes (overlap the fill, abut
  the track). And a soft edge drawn as base colour + a ramp layer leaves a line of the base colour
  along it wherever it lies over solid colour: the edge that overlaps must be HARD (binary mask,
  `NEAREST`). Sublevels did not settle draw order across masked textures; frame levels did.
  FINDINGS §18 has the whole rule set — read it before drawing anything with masks.
- **★ A texture takes at most THREE masks; masks only subtract; `v or default` is wrong for a
  boolean setting.** Three small ones from the same day: the mask cap is a hard error at login,
  so bake a shape into the art instead of masking it; a wedge wider than 180° needs two pieces,
  no mask arrangement gets round it; and `rc[field] or default` reads an OFF switch (`false`) as
  its default — test `== nil`. The toggle that "worked once and then stuck" was that.
- **`/reload` is enough, including for NEW files.** The old "new files → full client restart" rule
  is **RETIRED**; it cost the owner restarts he never needed.
- **★★ SECRECY IS PER TOKEN AND PER COMBAT STATE — test the exact token the code will use, in the
  state it will use it.** On 2026-09-19 (FINDINGS §17) the same hostile mob in the same delve was
  identifiable through `target` out of combat, secret through `target` in combat, and secret through
  its own `nameplateN` and through `mouseover` even OUT of combat — while `UnitIsUnit("target",
  "nameplateN")` stayed a plain boolean in combat. A single measurement generalised into "GUIDs are
  secret in instances" had been sitting in a comment for two weeks, wrong in both directions. One
  `/dump issecretvalue(...)` per (token, state) pair is cheap; write the table down, not the rule
  you inferred from one cell of it. And **a guarded `SetUnit` does NOT fail — it does nothing**, so
  "the model is still showing" is never evidence that the call worked.
- **★★ REGISTER SHARED MEDIA AS EARLY AS THE CATALOG EXISTS — and never trust an LSM `Fetch` that
  was not told `noDefault`.** Two facts that combined into a wrong font on 2026-09-19 (FINDINGS
  §16): (1) `LibSharedMedia:Fetch(type, name)` answers an UNKNOWN name with the type's DEFAULT
  (fonts: Friz Quadrata) — a real, truthy path that a consumer will happily cache; (2) addons load
  alphabetically and most build their frames at `PLAYER_LOGIN`, so anything a "G…" addon registers
  at `PLAYER_ENTERING_WORLD` arrives after every "A…F" addon has already asked and cached the wrong
  answer. **Register at your own `ADDON_LOADED`.** When *probing* whether a name is registered, pass
  `noDefault = true` (`Fetch("font", name, true)`) or the probe cannot fail. The "LSM is fully up by
  PLAYER_ENTERING_WORLD" comment was inherited, never true as a reason, and defended the bug.
- **★ A DoT REFRESH has no reliable CDM alert.** `OnAuraApplied` means a fresh aura *instance*; four
  of five refreshes measured on 2026-09-19 fired nothing at all (FINDINGS §15). The refresh signal
  is the player's own `UNIT_SPELLCAST_SUCCEEDED` for the spell, matched through the spell's
  override/linked ids. Do not key "the DoT was renewed" on any aura event.
- **★ AN ADDON CANNOT ENUMERATE A FOLDER.** WoW exposes no filesystem API: Lua cannot list a
  directory or test whether a file exists. **Dropping files into a drop-in folder does nothing on
  its own** — something outside the game must build an index. Both suite cases use the same shape: a
  shell script writes a generated `*Manifest.lua`, wrapped in a double-clickable `.command` for the
  owner, then `/reload`. GB's icons (`Rebuild Icons.command`) and the Hub's sounds
  (`Rebuild Sounds.command`).
  ⚠ **Say this out loud when telling him to drop files somewhere.** On 2026-08-24 he copied 41
  `.ogg` files into `GloomsHub\Sounds\`, restarted the client, saw nothing, and reasonably assumed
  it was broken — because the instruction to copy them in omitted that a rebuild step existed.
  ⚠ **A generated manifest ships EMPTY** (his media is git-ignored). Never commit a populated one.
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

- **★★ For a NEW interaction, describe what he should see AT THE EXTREMES before he touches it —
  and build one cheap round, then ask.** The scrub dial took FIVE rounds on 2026-09-21: a slider
  with ticks, a jog wheel, a hidden needle, a needle again, then the nearest-tick-turns-amber the
  owner actually meant. Every wrong model looked plausible at a value in the middle; each was
  exposed only at 0 / min / max. Two things would have cut it to two rounds: (1) asking, at the
  brief, what the mark does at zero and at the ends (his answer defined the whole widget in four
  sentences once asked); (2) the QA line saying "at 0 the mark is ON the thick centre tick; at the
  far left it IS the left post" instead of "try dragging it". "Did it work?" tells you nothing —
  he answered "the dial did drag" and it was wrong in three ways.
- **His frustration is information about the QA loop, not the code.** *"What the fuck do you want
  me to test"* came after four rounds of "reload and look" with nothing finished to look at. When
  a stage is a foundation (tokens, a shell, a kit), SAY that only one panel is on it and name the
  three things worth his eyes; do not send him hunting through un-migrated sections for widgets
  that are not there yet.

- **★ Report the CONCLUSION, not the evidence he cannot check.** He said it plainly on 2026-08-24:
  *"You do realize that I can't/don't read the SavedVariables files myself, right? I'm a human."* A
  session had spent the evening pasting saved-variable tables and Lua snippets at him as
  justification. Reading those files is the part of the job he delegated; quoting them back looks
  like rigour but is unverifiable to him, costs him reading time, and buries the finding in noise.
  **Say what you found in terms of things he can see or do in game** — aura names, tab and setting
  names, what to click, what he should hear. If a fact rests on file contents, say "I checked your
  saved settings" and give the answer.
  ⚠ Diagnostic output he PRODUCES on request (`/ga trace`, `/ga alertlog`, BugSack) is different —
  he pastes it deliberately. Summarise what it means; do not read it back to him.

- **★ Never frame a bug by WHICH SESSION introduced it.** On 2026-07-26 a regression report was
  answered twice with "not from today's changes, here's the diff". The owner's reply: *"I don't care
  if it happened today or in a previous session — you're the only one coding, so it's ultimately your
  responsibility, so don't be defensive. This is ALL your project."* He has one codebase and one
  coder; provenance is a distinction that serves the assistant, not him. **Establishing that a change
  is unrelated is useful once, to narrow the search — as a framing for the answer it reads as excuse
  making.** Say what is broken, say what fixes it, fix it.
- **★ Describe what HE can see, in his words — never name an artefact he hasn't named, and never
  re-send a command that is already in effect.** On 2026-09-21 a session called a rendering fault
  "the dark wedge on the pill", referred to it three times, and twice told the owner to run
  `/gu bar health rot 30` — which was already his setting. His reply: *"I've never seen a dark
  wedge on the pill. Are you hallucinating? … it doesn't do anything because it's ALREADY at that
  angle."* The fault was real (his earlier screenshots showed it) and already fixed; the framing
  was the failure. **Ask "does the pill look whole now?" — a question about the picture — and
  check the echoed settings line before sending a command.** The same session also wrote "Not for
  a Rectangle" on a control because the rectangle had no art, treating a gap as a limit until he
  asked why; a thing skipped for lack of art is a gap, and the tooltip should not dress it up.

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
