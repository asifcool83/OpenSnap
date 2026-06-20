# Menu Bar App

M1.7 runs OpenSnap as a native macOS menu bar application. `LSUIElement` is enabled, so OpenSnap has no Dock icon. The app declares only a `MenuBarExtra` scene: there is no main window, Settings scene, preferences, or onboarding.

## Menu

The menu contains:

- Accessibility status, refreshed whenever the menu opens.
- **Copy Diagnostic Report**, which writes a plain-text report to the system clipboard.
- **About OpenSnap**, which opens the native macOS About panel.
- **Quit OpenSnap**.

The About panel shows the app version and build number. When source metadata is embedded at build time, it also shows the Git commit.

## Architecture

`OpenSnapApp` creates `MenuBarController`. The controller owns menu actions and delegates report content to `OpenSnapDiagnosticsService`.

`OpenSnapDiagnosticsService` reads the live Accessibility permission state and reuses the existing Inspector snapshot, events, `BuildInfo`, and `InspectorReport` formatter. The report remains local until the user explicitly copies it.

The menu layer does not know about layouts, windows, screens, or mutation operations. Global hotkeys continue through their existing independent service path.
