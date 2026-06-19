# OpenSnap Architecture

OpenSnap keeps window management behavior split into small, testable areas.

## Targets

`OpenSnapCore` contains pure logic and app-independent service models. It must not import SwiftUI, AppKit, or Accessibility frameworks.

`OpenSnap` contains the executable app, SwiftUI views, AppKit integration, Accessibility API integration, and other macOS wiring. It depends on `OpenSnapCore`.

`OpenSnap.xcodeproj` owns the native macOS application target used for development, beta distribution, and releases. The Swift package remains the source layout and test harness; it is not the distribution artifact.

## App

The app layer owns SwiftUI views, app lifecycle, and service wiring.

## Accessibility

The accessibility layer checks and requests macOS Accessibility permission. No window layout decisions live here.

System permission checks and focused-window access are exposed through injected protocols. The production adapters own `AXUIElement` creation, attribute conversion, and raw Accessibility reads and writes; orchestration depends only on app-level window geometry and operations. This boundary keeps Accessibility behavior mockable without leaking platform types into `OpenSnapCore`.

## WindowEngine

The core window engine defines app-independent operations. The app window engine translates those operations into Accessibility API calls against the focused window.

The app window engine is responsible for frontmost-application detection, focused-window lookup, frame reads, movement, resizing, and graceful Accessibility failure reporting.

`AccessibilityWindowController` orchestrates these responsibilities through permission, application, focused-window, and screen providers. It preserves operation ordering and validation while leaving direct Accessibility API interaction to the concrete adapters.

Focused-window selection follows the deterministic policy in [Focused Window Acquisition](FocusedWindowAcquisition.md).

Frame changes pass through the [Window Mutation Pipeline](WindowMutationPipeline.md), which applies and verifies a requested frame against the same acquired window.

Monitor selection is platform-independent. `OpenSnapCore` chooses the screen with the largest overlap with the current window, falling back to the nearest screen when a stale window frame no longer intersects any display.

## LayoutEngine

The layout engine is pure Swift. It accepts screen geometry and returns window geometry. This is where Smart Snap and all layout algorithms belong.

## ShortcutEngine

The core shortcut engine defines semantic shortcut commands. The app shortcut engine maps keyboard input to those commands.

## Settings

Settings stores user-configurable preferences and default shortcuts.

## Utilities

Shared, dependency-free helpers live here.

## Build Identity and Updates

`BuildInfo` is the single runtime source for app version, build number, optional source revision metadata, and system identity. The native app target owns Sparkle because update delivery is a distribution concern, not core or package behavior.

Sparkle checks the repository-hosted appcast and downloads signed archives from GitHub Releases. Publishing conventions are documented in [`Updates/README.md`](../Updates/README.md).

## Inspector

Diagnostic UI lives in the app target. OpenSnap Inspector ships in Debug and Beta builds to support external testing. Production Release builds may later reduce or disable advanced diagnostics.
