# Changelog

All notable changes to OpenSnap will be documented in this file.

## Unreleased

- Created the initial Swift 6 macOS project scaffold.
- Split the package into `OpenSnapCore` for pure logic and `OpenSnap` for app/system integration.
- Added a native SwiftUI menu-bar app with Accessibility status, local diagnostics, About, and Quit.
- Added Accessibility permission checks and window control.
- Hardened the Window Engine with injectable frontmost-app and screen providers, focused-window frame reads, move/resize operations, richer failures, and tested multi-monitor screen resolution.
- Added layout calculations for halves, thirds, center, maximize, left 60%, right 40%, and Smart Snap.
- Added non-polling global shortcuts for snapping the window under the mouse left 60% or right 40%.
- Added local structured diagnostics and a plain-text clipboard report.
- Corrected AppKit-to-Accessibility screen-coordinate conversion for menu bars and multi-monitor layouts.
- Added optimized, source-identified macOS Beta artifacts to GitHub Actions.
- Removed dormant updater, diagnostics-window, ZIP-export, and logging code from the shipped app.
- Added unit tests for layout calculation, Smart Snap, hotkey dispatch, target-window boundaries, coordinate conversion, diagnostics, and menu behavior.
