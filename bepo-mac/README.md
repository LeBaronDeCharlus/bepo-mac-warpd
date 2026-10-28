# warpd on macOS with a bépo layout

A fork of [rvaiya/warpd](https://github.com/rvaiya/warpd) (master, `01650ea`) used daily on macOS (Apple Silicon) with a bépo keyboard layout and Karabiner-Elements.

## Changes from upstream

- **F1-F20 key names on macOS** (`src/platform/macos/input.m`): upstream gives every function key the same unprintable name, so they cannot be used in the config. They are now `f1` ... `f20`.
- **`codesign/sign.sh` keeps your keychain search list**: upstream replaces the user keychain search list with its temporary keychain and then deletes it, which leaves the login keychain out of the list. The fixed script appends the temporary keychain and restores the original list afterwards.

Arrow key names (`leftarrow`, `rightarrow`, `uparrow`, `downarrow`) are already in upstream master but not in the v1.3.5 release, which is why this builds from master.

## Install

```sh
xcode-select --install   # if needed
make
sudo cp bin/warpd /usr/local/bin/warpd
sudo cp files/com.warpd.warpd.plist /Library/LaunchAgents/
sudo chown root:wheel /Library/LaunchAgents/com.warpd.warpd.plist
mkdir -p ~/.config/warpd && cp bepo-mac/warpd.config ~/.config/warpd/config
launchctl bootstrap gui/$(id -u) /Library/LaunchAgents/com.warpd.warpd.plist
```

Grant `warpd` Accessibility access in System Settings > Privacy & Security > Accessibility. After a config change, restart it with:

```sh
launchctl kickstart -k gui/$(id -u)/com.warpd.warpd
```

## Config (`bepo-mac/warpd.config`)

Letter keys are the characters of the active layout (bépo here), not physical QWERTY positions.

| Key | Action |
|---|---|
| `C-A-M-c` | Start normal mode (Left Option + `c`, see Karabiner below) |
| Arrows | Move the cursor |
| Shift + arrows | Move slowly (120 px/s) |
| `h` / `,` / `f` | Left / middle / right click |
| `y` | Copy and exit |
| `c` | Cursor to the center of the screen |
| `g` / `G` | Cursor to the top / bottom of the screen |

Notes:

- warpd only checks the first key of a multi-key line whose base key matches (`left: leftarrow S-leftarrow` never matches `S-leftarrow`), so put each modified variant on its own line.
- macOS reserves Control + arrows for Mission Control, so Shift is used as the slow-down modifier.
- A bare modifier as activation key needs the modifier itself in the binding, e.g. `A-rightalt`.

### Karabiner

The activation key relies on a Karabiner rule that turns Left Option into Right Control + Right Command + Right Option (a hyper key for AeroSpace), and sends F17 when tapped alone. So Left Option + `c` reaches warpd as `C-A-M-c`, and a plain tap could be bound with `activation_key: f17`.

## Key recorder (`bepo-mac/keyrec.swift`)

A tiny window that logs every key event (keycode, characters, modifiers) for 4 seconds after the first press. Useful to see what a key really sends once Karabiner and the layout have processed it.

```sh
swiftc -O -o keyrec bepo-mac/keyrec.swift && ./keyrec
```

macOS keycode + 1 is the code warpd uses internally; run `warpd -l` to list the names it accepts.
