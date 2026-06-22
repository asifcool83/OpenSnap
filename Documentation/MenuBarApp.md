# Menu Bar App

OpenSnap runs as a native macOS menu bar application. `LSUIElement` is enabled, so OpenSnap has no Dock icon or permanent main window. M2.0 adds a first-run welcome window and a focused Settings window.

## Menu

The menu contains:

- A clear Ready or Finish Setup status, refreshed whenever the menu opens.
- A direct setup recovery action when either required permission is missing.
- The fixed Shift–1 and Shift–2 shortcut reference.
- A concise result or recovery message for the latest snap.
- **Getting Started** and **Settings**.
- **Copy Diagnostic Report**, which writes a plain-text report to the system clipboard.
- **About OpenSnap**, which opens the native macOS About panel.
- **Quit OpenSnap**.

The About panel shows the app version and build number. When source metadata is embedded at build time, it also shows the Git commit.

## Architecture

`OpenSnapApp` creates `MenuBarController`. The controller owns menu actions and delegates report content to `OpenSnapDiagnosticsService`.

`OpenSnapDiagnosticsService` reads live Accessibility and Input Monitoring permission state and reuses the existing diagnostic snapshot, events, `BuildInfo`, and report formatter. The report remains local until the user explicitly copies it.

The menu layer does not know about layouts, windows, screens, or mutation operations. Global hotkeys continue through their existing independent service path.
