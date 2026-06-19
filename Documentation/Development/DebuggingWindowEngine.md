# OpenSnap Inspector

OpenSnap Inspector is available in Debug and Beta builds as a lightweight support utility. It is not telemetry: all information remains local until the user explicitly copies or exports it.

## Opening Inspector

Open the OpenSnap menu bar item and choose **OpenSnap Inspector**, or use **Open Inspector** in About OpenSnap.

The single-window interface shows:

- Status: app version, build, Accessibility, keyboard hook, and Window Engine
- Last Action: shortcut, timestamp, target application/window, and result
- Current Window: title, bundle identifier, window ID, and current/target/actual frames
- Diagnostics: last error and the most recent 100 structured events

Each event has a timestamp, severity, category, and message. Routine Inspector refreshes do not create events.

## Support Reports

**Copy Diagnostics** writes a human-readable report to the clipboard. **Export Report** uses the native Save panel to create a ZIP containing:

- `report.json`
- `logs.txt`
- `system.json`
- `version.json`

Each report has a unique Report ID. Reports may include window titles and application identifiers, so testers should review them before sharing.

## Multi-Monitor Debugging

When debugging display issues, compare the current, target, and actual frames. OpenSnap chooses the screen with the largest overlap with the focused window, falling back to the nearest screen if the saved window frame no longer intersects any display.
