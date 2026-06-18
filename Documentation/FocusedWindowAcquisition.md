# Focused Window Acquisition

This document defines how the app-layer Accessibility adapter selects a window target. It does not define window mutation, layout, display selection, shortcuts, or Smart Snap behavior.

## Acquisition Policy

For the frontmost application selected by the existing application provider, OpenSnap evaluates candidates in this order:

1. Read `AXFocusedWindow`.
2. If that candidate cannot produce a valid `AXUIElement`, read `AXMainWindow`.
3. If neither candidate is usable, return one typed `FocusedWindowAcquisitionError` containing both failures.

OpenSnap stops after the first usable candidate. It does not enumerate other windows, infer a target from window order, or retry acquisition in this PR.

## Typed Failures

Each candidate can fail because:

- Accessibility returned an AX error code while reading the attribute.
- Accessibility reported success without a value.
- The returned value was not an `AXUIElement`.

`FocusedWindowAcquisitionError` preserves the separate `AXFocusedWindow` and `AXMainWindow` failure reasons. Its localized description remains the existing user-facing message: OpenSnap could not find the focused window.

## Ownership

`AXFocusedWindowProvider` owns candidate ordering and fallback policy. A narrow internal target-reader seam owns raw Accessibility attribute access and makes the policy deterministic in unit tests.

The returned `AccessibilityWindowAccessing` value hides `AXUIElement` from the controller. `AccessibilityWindowController` receives either a usable window adapter or the typed acquisition error and does not implement fallback behavior itself.

## Testing Boundary

Unit tests verify candidate order, early success, main-window fallback, and preservation of both failure reasons. Real Accessibility responses still require manual integration testing across macOS applications because process state and application AX implementations cannot be reproduced completely with unit mocks.
