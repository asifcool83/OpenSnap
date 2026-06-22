# First User Experience

M2.0 is designed to take a new user from launch to a successful snap in under 30 seconds without introducing a permanent main window or a general-purpose preferences surface.

## Journey

1. On first launch, OpenSnap presents one compact native welcome window and activates it above the current workspace.
2. The window explains the pointer-targeting model in one sentence.
3. Accessibility and Input Monitoring appear as separate rows with plain-language reasons, explicit **Allow** buttons, live status, and direct **Open Settings** recovery links.
4. Permission status refreshes when OpenSnap becomes active and through **Check Again**. Merely opening OpenSnap never triggers a permission prompt.
5. The same window presents the complete shortcut set: Shift–1 for left 60% and Shift–2 for right 40%.
6. **Start Using OpenSnap** becomes available only when both permissions are granted. Completion persists as one local Boolean.
7. The user points to a movable, resizable window and presses a shortcut. The window movement is the primary success feedback.

If setup is incomplete or a permission is later revoked, the menu changes from **OpenSnap is Ready** to **Finish Setting Up OpenSnap** and provides a direct route back to the welcome window. Settings keeps permission recovery and shortcut reference available afterward.

## Design Decisions

- The welcome window uses system typography, colors, controls, materials, SF Symbols, default-button behavior, and content-sized windows.
- Permission rows never rely on color alone; iconography, labels, values, and buttons remain available to VoiceOver.
- OpenSnap does not show a success notification after every snap because the moved window already provides immediate feedback.
- Technical Accessibility errors are translated into short recovery guidance in the menu; the exact error remains available in the copied diagnostic report.
- A rare clipboard write failure produces a focused native alert instead of failing silently.
- Settings has no tabs or empty categories. It contains only permissions and the two currently supported shortcuts.
- No third-party dependency, telemetry, analytics, update framework, or new layout behavior was introduced.

## Manual QA

- Fresh launch with neither permission granted.
- Grant each permission in both possible orders and return from System Settings.
- Deny each request, then recover through **Open Settings**.
- Close onboarding before completion and confirm it returns next launch.
- Complete onboarding and confirm future launches remain menu-bar-only.
- Revoke either permission and confirm menu and Settings status recover correctly.
- Verify keyboard navigation, default-button behavior, VoiceOver labels, increased contrast, light/dark appearance, and reduced-motion behavior.
- Perform the first snap in a native app and a cross-platform app.

## Intentionally Deferred to M3

- Shortcut customization, conflict detection, and its preference model.
- Launch-at-login controls.
- Localization and dedicated UI automation for the onboarding window.
- Any optional success overlay or notification; these must prove they add clarity without making a tiny utility noisy.
