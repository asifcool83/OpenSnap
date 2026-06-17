# OpenSnap Architecture

OpenSnap keeps window management behavior split into small, testable areas.

## App

The app layer owns SwiftUI views, app lifecycle, and service wiring.

## Accessibility

The accessibility layer checks and requests macOS Accessibility permission. No window layout decisions live here.

## WindowEngine

The window engine translates OpenSnap operations into Accessibility API calls against the focused window.

## LayoutEngine

The layout engine is pure Swift. It accepts screen geometry and returns window geometry. This is where Smart Snap and all layout algorithms belong.

## ShortcutEngine

The shortcut engine maps keyboard input to semantic window commands.

## Settings

Settings stores user-configurable preferences and default shortcuts.

## Utilities

Shared, dependency-free helpers live here.
