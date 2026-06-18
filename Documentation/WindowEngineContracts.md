# Window Engine Contracts

This document defines the platform-independent behavior established for M1. macOS Accessibility targeting and frame mutation remain app-layer responsibilities.

## Supported Layouts

Layout calculations receive a display's usable `visibleFrame` and produce a requested window frame.

| Layout | Contract |
| --- | --- |
| Left 60% | Left-aligned, 60% of usable width, full usable height |
| Right 40% | Right-aligned, 40% of usable width, full usable height |
| Left Half | Left-aligned, 50% of usable width, full usable height |
| Right Half | Right-aligned, 50% of usable width, full usable height |
| Center | Centered, 60% of usable width and 72% of usable height |
| Maximize | Exactly equal to the usable frame |

Existing layouts outside this table are not certified by M1 PR #1.

## Geometry Inputs

`WindowFrame`, `WindowPoint`, and `WindowSize` use logical points represented by finite `Double` values. Layout callers must provide a usable frame with positive width and height.

Geometry models are immutable value types. A frame's minimum edges are inclusive and maximum edges are exclusive for point containment and deterministic display-boundary selection.

## Rounding

Proportional layouts round calculated edges to the nearest logical point, with halfway values rounded away from zero. Width and height are derived from the rounded edges rather than rounded independently.

This guarantees that complementary layouts such as Left 60% and Right 40% share one boundary without gaps or overflow, including odd-width and negative-origin displays.

Maximize preserves the supplied usable frame exactly.

## Coordinate Space

All frames participating in one calculation must use the same global coordinate space. `OpenSnapCore` does not assume an AppKit or Accessibility axis direction and does not convert between them.

The macOS adapter must normalize `NSScreen` and Accessibility frames before calling Core. That conversion belongs in a later M1 integration PR.

Negative horizontal or vertical origins are valid and represent displays positioned left of or below the coordinate-space origin.

## Display Geometry

`DisplayGeometry.frame` is the full display boundary used to determine which display owns a window. `DisplayGeometry.visibleFrame` excludes system-reserved areas such as the Dock and menu bar and is used for layout.

`scaleFactor` records backing pixels per logical point. Core geometry remains in logical points, so layout dimensions are not multiplied by this value.

Display selection follows this order:

1. Greatest overlap between the window and full display frame.
2. Display containing the window center.
3. Display whose center is nearest to the window center.
4. Original display order for an exact tie.

If a window does not overlap any display, the nearest display is selected. An empty display collection produces no result.

## Operation Outcomes

M1 uses three operation outcomes:

- **Success:** the observed frame matches the requested frame within the accepted tolerance.
- **Constrained:** the application moved or resized the window but imposed a materially different frame.
- **Failure:** OpenSnap cannot confirm a reliable completed operation.

The concrete outcome type is intentionally deferred until the mutation layer can supply the requested frame, observed frame, tolerance, and typed failure reason. Introducing a payload-free result in Core now would create an API without enough information to be useful.
