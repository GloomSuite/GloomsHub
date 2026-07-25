# Gloom Suite

Four World of Warcraft addons that share one window, one look, and one media library.

| Addon | What it does |
|---|---|
| **Gloom's Hub** | The shared base. Owns the Suite window, the design toolkit, and the custom fonts/graphics. **Required by all three tools.** |
| **Gloom's Bars** | Appearance layer for Blizzard's action bars — rounded icons, shape-matched proc glows, cooldown sweeps. |
| **Gloom's Auras** | Custom textures + sounds mirrored from the Blizzard Cooldown Manager. |
| **Gloom's Overlays** | Cosmetic overlays and buff-triggered effects. |

Everything is configured in one place: type **`/gloom`**, or click the **GS** button on your minimap.

---

## Installing (WoWup)

**Gloom's Hub is required.** The three tools have nothing to configure without it —
install the Hub first, then whichever tools you want.

This is a one-time setup per addon. WoWup handles updates automatically afterwards.

1. Open **WoWup**.
2. Go to the **Get Addons** tab.
3. Click **Install from URL** (top right).
4. Paste the address for the addon you want and click **Install**:

   | Addon | Address to paste |
   |---|---|
   | Gloom's Hub **(install this first)** | `https://github.com/GloomSuite/GloomsHub` |
   | Gloom's Bars | `https://github.com/GloomSuite/GloomsBars` |
   | Gloom's Auras | `https://github.com/GloomSuite/GloomsAuras` |
   | Gloom's Overlays | `https://github.com/GloomSuite/GloomsOverlays` |

5. Repeat step 3–4 for each addon you want.
6. **Fully quit and restart WoW** if it was running. New addons need a full restart,
   not a `/reload`.

Updates from then on are the normal WoWup flow — they show up in **My Addons** and
you click **Update**.

### You do NOT need a GitHub account or an access token

These repos are public, so WoWup installs and updates them with no sign-in and no
credentials of any kind.

If you see a **"personal access token"** field in WoWup's GitHub settings, leave it empty.
It only raises GitHub's API rate limit (60 requests/hour without one), which matters when
you track a lot of addons — it is not permission to install. If you ever do hit a rate
limit, generate your **own** free token in your **own** GitHub account.

⚠ **Never use someone else's token, and never share yours.** A token is a password for a
GitHub account, not a setting.

### If a tool says it's missing a dependency

The in-game addon list and WoWup will both flag `GloomsHub` as missing. That is the
intended, loud failure — install the Hub with the steps above and restart the client.
The tools have no fallback window on purpose, so that everyone gets the identical
experience through the one Suite window.

---

## Using it

- **`/gloom`** — open the Suite window on whichever tab you used last.
- **Minimap button (GS)** — the same thing. There is one button for the whole suite,
  not one per addon.
- **`/gb`**, **`/ga`**, **`/go`** — open the window focused on Bars, Auras or Overlays.
- The **Media** tab (in the Hub) is where custom fonts, graphics and textures are added
  and removed; everything registered there is available to the other tools.

---

## Reporting a problem

If something breaks, the useful thing is the error text from **BugSack** — open it,
copy the error, and send that along with which addon and what you were doing.
