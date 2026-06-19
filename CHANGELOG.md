# Changelog

All notable changes to OpenSnap will be documented in this file.

## Unreleased

- Created the initial Swift 6 macOS project scaffold.
- Split the package into `OpenSnapCore` for pure logic and `OpenSnap` for app/system integration.
- Added a native SwiftUI menu-bar app shell.
- Added Accessibility permission checks and active-window control.
- Hardened the Window Engine with injectable frontmost-app and screen providers, focused-window frame reads, move/resize operations, richer failures, and tested multi-monitor screen resolution.
- Added layout calculations for halves, thirds, center, maximize, left 60%, right 40%, and Smart Snap.
- Added keyboard shortcut monitoring.
- Added OpenSnap Inspector to Debug and Beta builds with structured events, clipboard diagnostics, and ZIP report export.
- Added unit tests for layout calculations and Smart Snap cycling.
