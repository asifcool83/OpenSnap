# Global Hotkeys

M1.6 provides two fixed global shortcuts:

- Shift+1 snaps the window under the mouse to the left 60% of its screen.
- Shift+2 snaps the window under the mouse to the right 40% of its screen.

The shortcuts are active while OpenSnap is running, do not require focus, and require macOS Input Monitoring permission. M2.0 presents them in onboarding, the menu, and Settings. They remain fixed and have no shortcut preference persistence.

## Dispatch Path

`GlobalHotkeyService` receives matching key-down events from the existing event monitor. It accepts only the two milestone layout commands and then calls `MouseWindowResolver`.

`MouseWindowResolver` performs one Accessibility hit-test at the current cursor location, walks from the hit element to its window ancestor, and verifies that the window's position and size attributes are settable. It does not poll or track the cursor.

The service reads the resolved window frame, converts AppKit visible-screen frames into Accessibility coordinates, selects the matching screen through `ScreenFrameResolver`, and obtains the requested frame from `LayoutCalculator`. The already-acquired window and requested frame are passed directly to `WindowMutationPipeline`.

The pipeline's existing typed result is returned unchanged:

- `success` when read-back matches the requested frame within tolerance.
- `constrained` when the app applies a valid but materially different frame.
- `failure` when validation, resize, positioning, or read-back fails.

Window-resolution and screen-selection errors occur before mutation and remain thrown errors, matching the existing window-engine boundary.

If macOS cannot provide the current cursor location, dispatch fails before hit-testing instead of silently targeting the top-left corner of the desktop.
