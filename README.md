# OpenSnap

OpenSnap is a completely free, open-source, native macOS window manager.

The project is designed to be lightweight, fast, privacy-respecting, keyboard-first, and pleasant enough to feel at home on macOS.

## Goals

- Native Swift 6 and SwiftUI
- AppKit and Accessibility APIs for window control
- No ads, analytics, telemetry, accounts, subscriptions, cloud sync, Electron, or closed-source components
- Offline by default
- Testable layout and window geometry logic

## Version 1.0 Scope

- Accessibility permissions
- Detect active window
- Move and resize the active window
- Left 60%
- Right 40%
- Left half
- Right half
- Thirds
- Maximize
- Center
- Keyboard shortcuts
- Multiple monitor support
- Smart Snap

## Smart Snap

Smart Snap cycles through useful widths when the same side shortcut is pressed repeatedly.

Left Smart Snap:

```text
60% -> 50% -> 33% -> 25% -> 60%
```

Right Smart Snap follows the same cycle while anchoring the window to the right edge.

## Development

Build and test with Swift Package Manager:

```sh
swift build
swift test
```

OpenSnap targets macOS 27 or newer.

## Project Structure

```text
OpenSnap/
  App/
  Accessibility/
  WindowEngine/
  LayoutEngine/
  ShortcutEngine/
  Settings/
  Utilities/
  Resources/
Tests/
Documentation/
```

Each folder has a single responsibility, and layout algorithms are intentionally separated from AppKit so they can be tested without launching the UI.
