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

## Global Shortcuts

- Shift+1: snap the window under the mouse to the left 60%.
- Shift+2: snap the window under the mouse to the right 40%.

The target window must be movable and resizable. See [`Documentation/GlobalHotkeys.md`](Documentation/GlobalHotkeys.md) for the dispatch architecture and failure boundaries.

## Menu Bar App

OpenSnap runs without a Dock icon or main window. Its native menu bar menu shows Accessibility status and provides Copy Diagnostic Report, About, and Quit. See [`Documentation/MenuBarApp.md`](Documentation/MenuBarApp.md).

## Development

Build and test with Swift Package Manager:

```sh
swift build
swift test
```

Build the native application target used for beta distribution and releases:

```sh
xcodebuild -project OpenSnap.xcodeproj -scheme OpenSnap -configuration Debug build
```

The native app owns bundle identity, About, and Sparkle updates. See [`Updates/README.md`](Updates/README.md) for release publishing.

OpenSnap targets macOS 27 or newer.

## Project Structure

```text
OpenSnapCore/
  LayoutEngine/
  ShortcutEngine/
  WindowEngine/
OpenSnap/
  App/
  Accessibility/
  ShortcutEngine/
  WindowEngine/
  Utilities/
  Resources/
Tests/
Documentation/
```

`OpenSnapCore` contains pure logic and app-independent models. `OpenSnap` contains the menu bar app, AppKit, Accessibility, and other macOS integration wiring.

Each folder has a single responsibility, and layout algorithms are intentionally separated from AppKit so they can be tested without launching the UI.
