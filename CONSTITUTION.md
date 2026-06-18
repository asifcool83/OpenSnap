# OpenSnap Constitution

This constitution is the permanent guiding document for OpenSnap.

OpenSnap is a long-term native macOS product and open-source project. Every product, engineering, design, and governance decision should protect the user's trust and keep the project maintainable.

## Core Principles

### Native macOS First

OpenSnap should feel like it belongs on macOS. Prefer Swift, SwiftUI, AppKit, Accessibility APIs, SF Symbols, system colors, system typography, and platform conventions before custom UI or third-party abstractions.

### Free And Open Source Forever

OpenSnap is free and open source forever under the MIT License.

The project must not add:

- ads
- telemetry
- analytics
- subscriptions
- accounts
- cloud dependency for core behavior
- closed-source product components

### Privacy First

OpenSnap should work offline. It should not collect user behavior, workspace data, app usage, window titles, or shortcut history.

### Reliability Before Features

A small reliable feature set is better than a large unpredictable one. Features must earn their place by improving the core window-management experience.

### Simplicity Before Cleverness

Code and UX should be straightforward. Future contributors should understand why something exists, not merely what it does.

### Accessibility Is Mandatory

Accessibility is part of quality. OpenSnap should support keyboard navigation, readable contrast, clear permission guidance, and VoiceOver where practical.

### Performance Is A Feature

Window operations should feel instant. OpenSnap should remain lightweight, fast, and responsive.

### Consistency Matters

OpenSnap's interaction model, visual language, documentation, and code structure should feel coherent.

### Long-Term Maintainability

Prefer clear architecture, testable logic, small modules, explicit decisions, and boring code that ages well.

### Decisions Are Documented

Major architecture decisions belong in `DECISIONS.md`. Major design decisions belong in `DESIGN/`. Contributors should understand the reasoning behind the project.

## Product Identity

OpenSnap's identity is anchored by the 60% / 40% split:

- 60% Focus
- 40% Context
- Native macOS
- Simplicity
- Precision
- Balance
- Minimalism

Future refinements should polish this identity, not replace it.
