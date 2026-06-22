# Release Readiness

M1.9 reviewed source structure, native integration, tests, CI, diagnostics, ownership, concurrency, Accessibility use, and distribution behavior for the first public beta.

## Completed in M1.9

- Corrected visible-screen conversion from AppKit coordinates to Accessibility coordinates, including menu-bar insets and displays above or below the primary display.
- Made unavailable cursor location a typed pre-mutation error instead of falling back to desktop coordinate `(0, 0)`.
- Preserved the originating hotkey through result reporting so copied diagnostics identify the action that ran.
- Removed unused updater, update-feed, diagnostics-window, ZIP-export, debug-configuration, and logging code.
- Removed the dormant Sparkle dependency and feed credentials from the native target, reducing dependency resolution, launch work, and binary contents.
- Switched CI distribution output from Debug to the optimized Beta configuration.
- Pinned CI to macOS 15 and Xcode 16.4, injected source revision and workflow build number, treated native build warnings as errors, and verified the executable, embedded identity, and ZIP integrity.
- Aligned product, architecture, update, build, and platform-support documentation with the shipped application.

The app remains a menu-bar-only process. Global input is callback-driven rather than polled. UI and Accessibility-owned services are main-actor isolated, monitor callbacks capture their owner weakly, diagnostic history is bounded, and no telemetry or network work occurs at startup.

## Verification Gate

Every candidate must pass:

```sh
swift build -c release
swift test
xcodebuild -project OpenSnap.xcodeproj -scheme OpenSnap -configuration Beta build
```

CI additionally validates the app bundle identity and packaged archive. A release candidate should also complete the manual QA matrix below on both Apple silicon and Intel where supported.

## Remaining Before Public Beta

- Sign and notarize the app, validate Hardened Runtime entitlements, and publish through an immutable release process.
- Run manual Accessibility and window-mutation QA across common native and cross-platform apps, multiple displays, Spaces, full-screen windows, minimized windows, sheets, and nonstandard Accessibility trees.
- Measure cold launch and idle memory on representative hardware and record budgets; unit/build inspection cannot substitute for Instruments and real-device measurements.
- Confirm the long-term global-shortcut API before adding configurable shortcuts. The current event monitor is intentionally small and correct for two fixed shortcuts.
- Decide and test automatic-update delivery only after signing and notarization are operational.

## Assessment

The codebase and CI artifact are ready for controlled beta testing. The project is not yet ready for a broad public beta because unsigned, unnotarized artifacts create a poor and untrustworthy installation path, and the manual macOS compatibility matrix is not yet complete.
