# OpenSnap Diagnostics

OpenSnap keeps a lightweight local diagnostic snapshot for support. It is not telemetry: all information remains local until the user explicitly copies it.

## Copying a Report

Open the OpenSnap menu bar item and choose **Copy Diagnostic Report**. A human-readable plain-text report is written to the clipboard.

The report includes:

- Status: app version, build, Accessibility, keyboard hook, and Window Engine
- Last Action: shortcut, timestamp, target application/window, and result
- Current Window: title, bundle identifier, window ID, and current/target/actual frames
- Diagnostics: last error and the most recent 100 structured events

Each event has a timestamp, severity, category, and message. Each report has a unique Report ID. Reports may include window titles and application identifiers, so testers should review them before sharing.

## Multi-Monitor Debugging

When debugging display issues, compare the current, target, and actual frames in the copied report. OpenSnap chooses the screen with the largest overlap with the focused window, falling back to the nearest screen if the saved window frame no longer intersects any display.
