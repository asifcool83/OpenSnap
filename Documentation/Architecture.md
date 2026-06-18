# OpenSnap Architecture

OpenSnap keeps window management behavior split into small, testable areas.

## Targets

`OpenSnapCore` contains pure logic and app-independent service models. It must not import SwiftUI, AppKit, or Accessibility frameworks.

`OpenSnap` contains the executable app, SwiftUI views, AppKit integration, Accessibility API integration, and other macOS wiring. It depends on `OpenSnapCore`.

## App

The app layer owns SwiftUI views, app lifecycle, and service wiring.

## Accessibility

The accessibility layer checks and requests macOS Accessibility permission. No window layout decisions live here.

## WindowEngine

The core window engine defines app-independent operations. The app window engine translates those operations into Accessibility API calls against the focused window.

The app window engine is responsible for frontmost-application detection, focused-window lookup, frame reads, movement, resizing, and graceful Accessibility failure reporting.

Monitor selection is platform-independent. `OpenSnapCore` chooses the screen with the largest overlap with the current window, falling back to the nearest screen when a stale window frame no longer intersects any display.

Core geometry is expressed in logical points within one shared global coordinate space. AppKit and Accessibility adapters are responsible for converting platform coordinates before creating Core models. See [Window Engine Contracts](WindowEngineContracts.md).

## LayoutEngine

The layout engine is pure Swift. It accepts screen geometry and returns window geometry. This is where Smart Snap and all layout algorithms belong.

## ShortcutEngine

The core shortcut engine defines semantic shortcut commands. The app shortcut engine maps keyboard input to those commands.

## Settings

Settings stores user-configurable preferences and default shortcuts.

## Utilities

Shared, dependency-free helpers live here.

## Developer Diagnostics

Developer Diagnostics lives in the app target and is compiled only for Debug builds. It can inspect Accessibility/AppKit state, show a diagnostics window, and record structured debug logs without shipping those tools in Release builds.
