# OpenSnap Architecture

OpenSnap keeps window management behavior split into small, testable areas.

## Targets

`OpenSnapCore` contains pure logic and app-independent service models. It must not import SwiftUI, AppKit, or Accessibility frameworks.

`OpenSnap` contains the executable app, SwiftUI views, AppKit integration, Accessibility API integration, and other macOS wiring. It depends on `OpenSnapCore`.

`OpenSnap.xcodeproj` owns the native macOS application target used for development, beta distribution, and releases. The Swift package remains the source layout and test harness; it is not the distribution artifact.

## App

The app layer owns lifecycle and service wiring. `OpenSnapApp` exposes one native `MenuBarExtra` scene and starts background services; it defines no main window or Settings scene.

Menu actions flow through `MenuBarController`, which delegates status and report content to `OpenSnapDiagnosticsService`. Clipboard, native About-panel, and application-termination adapters are injected at the controller boundary. No window layout or snapping decisions live in the menu layer. See [Menu Bar App](MenuBarApp.md).

## Accessibility

The accessibility layer checks macOS Accessibility permission. No window layout decisions live here.

System permission checks, focused-window access, and mouse-window access are exposed through injected protocols. The production adapters own `AXUIElement` creation, attribute conversion, hit-testing, and raw Accessibility reads and writes; orchestration depends only on app-level window geometry and operations. This boundary keeps Accessibility behavior mockable without leaking platform types into `OpenSnapCore`.

## WindowEngine

The core window engine defines app-independent operations. The app window engine translates those operations into Accessibility API calls against the focused window.

The app window engine is responsible for frontmost-application detection, focused-window lookup, frame reads, movement, resizing, and graceful Accessibility failure reporting.

`AccessibilityWindowController` orchestrates these responsibilities through permission, application, focused-window, and screen providers. It preserves operation ordering and validation while leaving direct Accessibility API interaction to the concrete adapters.

Focused-window selection follows the deterministic policy in [Focused Window Acquisition](FocusedWindowAcquisition.md).

Frame changes pass through the [Window Mutation Pipeline](WindowMutationPipeline.md), which applies and verifies a requested frame against the same acquired window.

Monitor selection is platform-independent. The AppKit screen adapter first converts bottom-left-origin `NSScreen` frames into the top-left-origin coordinate space used by Accessibility. `OpenSnapCore` then chooses the screen with the largest overlap with the current window, falling back to the nearest screen when a stale window frame no longer intersects any display.

## LayoutEngine

The layout engine is pure Swift. It accepts screen geometry and returns window geometry. This is where Smart Snap and all layout algorithms belong.

## ShortcutEngine

The core shortcut engine defines semantic shortcut commands. The app shortcut engine maps keyboard input to those commands.

`GlobalHotkeyService` owns the event-to-command boundary. For M1.6 it registers Shift+1 and Shift+2 without polling, asks `MouseWindowResolver` for the movable and resizable window under the cursor, selects the window's screen, calculates the existing 60% or 40% layout, and passes that frame to `WindowMutationPipeline`. See [Global Hotkeys](GlobalHotkeys.md).

## Settings

Settings and preference persistence are intentionally deferred to v0.7.0-beta. M1.7 has no preferences or onboarding.

## Build Identity and Distribution

`BuildInfo` is the single runtime source for app version, build number, optional source revision metadata, and system identity. CI injects the workflow run number and checked-out source revision into the optimized Beta artifact and verifies both before packaging.

Automatic updating is not linked into the app. It remains deferred until the signed and notarized release process is defined; distribution constraints are documented in [`Updates/README.md`](../Updates/README.md).

## Diagnostics

Structured diagnostic state lives in the app target and remains local. `OpenSnapDiagnosticsService` reuses that state and the report formatter to produce the menu bar's plain-text clipboard report. There is no diagnostics window, background export, network transfer, or polling.
