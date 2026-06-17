# Debugging the Window Engine

Developer Diagnostics is available only in Debug builds.

## Opening Diagnostics

Run OpenSnap in a Debug build, open the menu bar item, and choose Developer Diagnostics.

The diagnostics window shows:

- frontmost application and bundle identifier
- focused window title and window ID when available
- current window frame
- selected visible screen frame
- screen dimensions
- Accessibility permission status
- whether the focused window appears movable or resizable
- current Smart Snap state
- last shortcut received
- last WindowEngine operation
- last error
- debug-only structured WindowEngine logs

## Logging

WindowEngine diagnostic logs are compiled only in Debug builds. Release builds do not include the diagnostics window or debug log recording.

Useful entries include:

```text
[INFO] Focused Safari
[INFO] Move Window
[INFO] Resize Window
[WARNING] Accessibility permission missing
[ERROR] Unable to obtain AXFocusedWindow
```

## Multi-Monitor Debugging

When debugging display issues, compare the current window frame with the visible frame and screen dimensions shown in diagnostics. OpenSnap chooses the screen with the largest overlap with the focused window, falling back to the nearest screen if the saved window frame no longer intersects any display.
