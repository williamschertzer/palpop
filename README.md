# PalPop Defense

A tower defense game in the style of Bloons TD, made in the [Godot](https://godotengine.org) game engine. A poacher gang called **the Snatchers** is rolling capture orbs down the trail toward the sanctuary's **Nest Egg**. Line the path with critters and pop every orb before it gets there.

Every critter, orb and map is an original design, drawn with code. There are no sprites or names from any other game.

## Play

- **In your browser:** https://williamschertzer.github.io/palpop/ (once GitHub Pages is turned on, see below). It can be installed as an app and works offline after the first visit: on Android/Chrome/Edge use **Install app**; on iPhone/iPad open the page in Safari, tap **Share**, then **Add to Home Screen**.
- **Mac, Windows, Linux or Android:** go to the **[latest release](https://github.com/williamschertzer/palpop/releases/latest)** and download the file for your device. These are rebuilt automatically every time something is merged into `main`.
  - **Windows:** unzip `PalPop-Windows.zip` and double-click `PalPop.exe`. If Windows warns about an unknown publisher, click **More info → Run anyway**.
  - **Mac:** unzip `PalPop-macOS.zip`. The first time, Apple blocks it because it isn't signed by a paid developer account: try to open it, then go to **System Settings → Privacy & Security** and click **Open Anyway**.
  - **Linux:** unzip `PalPop-Linux.zip` and run `PalPop.x86_64`.
  - **Android:** copy `PalPop-Android.apk` to your phone, tap it, and allow "install unknown apps" when Android asks. It is a test build signed with a debug key, which is fine for your own phones.

Builds of a pull request that isn't merged yet are on its **Build game** run in the **Actions** tab, under **Artifacts** at the bottom of the page.

### Turning on the website (one time)

In the repo on GitHub, open **Settings → Pages** and set **Source** to **GitHub Actions**. The next merge into `main` publishes the game.

## How to play

The title screen has **Continue** (your last game), **New game** (the map picker), the **Field Guide** (every critter, orb and type matchup) and **Settings** (volume, asking before you release a critter, and a switch to unlock every critter right away).

Pick a difficulty and a map, then drag a critter from the Party onto the map (or click it, or press keys 1 to 9 and 0, then click the map). Press **Start wave** (or **Space**). Click a critter on the field to open its upgrades: one path makes it **grow** into a bigger form, ending in an **Ascended** form, and the other teaches it new moves. **F** changes speed, **P** pauses, and **Esc** cancels or opens the pause menu.

- **19 critters.** Zapkit, Cindermole, Spoutling, Thornhog, Lanternwisp, Coinpie, Wobblob and Astralion are ready from the start. The rest unlock as you play on Normal or Hard: Puddlesnail, Galefinch, Pebbit, Knuckaroo, Hootling, Frostray, Slumbear, Wyrmlet, Prismkit (it grows into your choice of Tidefox, Sparkfox or Blazefox), Mimoth (copies the critter next to it) and Bunbalm (heals the Nest).
- **Orbs** get tougher as the waves go on: Red, Blue, Gold, Dart, Clock, Mesh, Mending, Shade (hidden, only some critters can see them), Iron (armoured, ignores Electric) and Titan Orbs, and at wave 40 the Snatcher Blimp.
- **Items** in the side panel: a Tonic (+25 Nest HP), Sticky Mist (every orb slows down for 5 seconds) and a Gold Acorn (30% off your next upgrade).
- **8 maps:** Mossy Meadow, Whisperwood, Hollow Hill, Glowcap Caves, Driftwood Pier, Pitch Mine, Rime Isles and Summit Pass, each on Easy, Normal or Hard.
- **Clearing the way:** rocks, trees, boulders, ice and a sleeping Slumbear take up good spots. Tap one to see which critter can clear it and what it costs. Only Spoutling, Puddlesnail and Frostray can stand in water.

**Phones** get their own landscape layout (Settings → Screen layout picks Automatic, Computer or Phone). Drag a critter out of the Party, or tap it to read about it first, then tap the map twice to place it.

The game saves itself between waves, so you can close it and choose **Continue** later.

## Open the game in Godot

1. Download **Godot 4.3** (or newer) from https://godotengine.org/download. Pick the normal version, not the ".NET" one. Unzip it and double-click it.
2. In the Project Manager, click **Import**, choose this repo's `project.godot`, and click **Import & Edit**.
3. Press **▶ Play** at the top right (or **F5**).

To make your own builds: **Editor → Manage Export Templates… → Download and Install** (once, about 1 GB), then **Project → Export…**, pick one of the five presets (Web, Android, Windows, macOS, Linux) and click **Export Project…**. Android also needs [Android Studio](https://developer.android.com/studio) for its SDK and Java; set both paths under **Editor → Editor Settings → Export → Android**.

## For developers

- `scripts/main.gd` builds all the menus and panels in code, `scripts/stage.gd` draws the field, `scripts/game.gd` runs the rules, and `scripts/data.gd` holds every critter, upgrade, orb, map and wave.
- `scripts/mons.gd` draws the critters, `scripts/art.gd` the orbs and the blimp, and `scripts/mapart.gd` the maps, all through `scripts/pen.gd`, a small canvas-style drawing helper.
- `tests/check_upgrades.gd` checks every upgrade path; CI runs it on every pull request.
- `tools/sprite_sheet.gd` renders every critter and orb into one picture and `tools/make_icon.gd` redraws `icon.png`. Both need a display, for example `xvfb-run godot --path . -s tools/sprite_sheet.gd -- sheet.png`.
