# Decisions

This file starts the OpenSnap Architectural Decision Record.

## ADR-0001: OpenSnap Is Native macOS Software

Status: Accepted

OpenSnap will use Swift, SwiftUI, AppKit, Accessibility APIs, and Foundation. It will not use Electron or web technologies for the app.

Reason: Native APIs support performance, accessibility, system integration, and the desired Apple-like product feel.

## ADR-0002: Privacy Is Non-Negotiable

Status: Accepted

OpenSnap will not include telemetry, analytics, ads, accounts, subscriptions, or cloud dependency for core behavior.

Reason: Trust is a core product value and an open-source differentiator.

## ADR-0003: MIT License

Status: Accepted

OpenSnap will be open source forever under the MIT License.

Reason: The project should be easy to adopt, fork, study, and contribute to.

## ADR-0004: GitHub Is The Source Of Truth

Status: Accepted

All milestone development should happen through GitHub branches and Pull Requests.

Reason: GitHub provides review history, coordination with the product architect, and a durable public project record.

## ADR-0005: Split Core Logic From App Integration

Status: Accepted

Platform-independent logic belongs in `OpenSnapCore`. SwiftUI, AppKit, and Accessibility integration belong in `OpenSnap`.

Reason: This keeps layout and geometry logic testable and prevents system APIs from leaking into pure logic.

## ADR-0006: 60/40 Is The Design Anchor

Status: Accepted

The 60% / 40% split is the foundation of the OpenSnap visual identity and product philosophy.

Reason: It communicates balance, focus, context, simplicity, precision, and instant understanding.

## ADR-0007: Debug Tooling Must Not Ship As Product UI

Status: Accepted

Developer diagnostics and debug logging should be compiled only in Debug builds.

Reason: Diagnostics improve engineering quality, but Release builds should stay minimal and user-focused.
