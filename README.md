# CleanPaste

A small macOS menu-bar app that:

- **Strips formatting on copy/cut** — when "Clean Up Clipboard" is on, anything you copy is flattened to plain text (fonts, colors, links gone). Pure file/image copies are left alone.
- **Keeps the last 5 copies** — click the clipboard icon in the menu bar to see them; pick one to put it back on the clipboard exactly as it was copied.
- Toggles on/off from the menu; the setting is remembered across launches.

Requires macOS 13 Ventura or newer. Runs natively on Apple Silicon and Intel (universal binary).

## Build

Requires Xcode (command line tools). No other dependencies.

```sh
./scripts/build-dmg.sh
```

This produces `dist/CleanPaste-universal.dmg` containing a universal (arm64 + x86_64) `CleanPaste.app`.

For a quick local run without packaging:

```sh
swift run
```

## Install

1. Open the DMG and drag **CleanPaste** to **Applications**.
2. The app is ad-hoc signed (not notarized with Apple), so on first launch **right-click the app → Open → Open** to approve it in Gatekeeper. After that it launches normally.

## Usage

- Click the clipboard icon in the menu bar (top-right).
- **Clean Up Clipboard** — checkmark = cleanup is on.
- **Recent Clips** — the last 5 things you copied; click one to restore it to the clipboard.
- **Launch at Login** — the app registers itself to start at login on first launch (macOS shows a one-time notification); toggle it here or in System Settings → General → Login Items.
- **Quit CleanPaste** (⌘Q) to exit.

To remove the login item without launching the app (e.g. when uninstalling):

```sh
/Applications/CleanPaste.app/Contents/MacOS/CleanPaste --remove-login-item
```
