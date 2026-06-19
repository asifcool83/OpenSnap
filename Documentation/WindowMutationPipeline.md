# Window Mutation Pipeline

The mutation pipeline applies one requested frame to one already-acquired window and verifies the observed result. It does not acquire targets, select displays, calculate layouts, or retry operations.

## Sequence

For a valid requested frame, the pipeline:

1. Sets the window size.
2. Sets the window position.
3. Reads the frame back from the same `AccessibilityWindowAccessing` instance.
4. Compares every position and size component with the request.

The pipeline never calls a focused-window provider. Target acquisition happens once before the pipeline begins, and the acquired adapter is retained through mutation and verification.

## Results

`WindowMutationResult` has three outcomes:

- **Success:** the observed frame matches the requested frame within tolerance.
- **Constrained:** the observed frame is valid but differs materially from the request, such as when an application enforces minimum size or placement constraints.
- **Failure:** validation, resize, position, or read-back could not produce a reliable observed result.

Success and constrained results include the requested frame, observed frame, and accepted tolerance. Failures include the requested frame, an optional observed frame, the failed stage, and a typed reason with system-error context when available.

## Tolerance

The default tolerance is one logical point per frame component. A frame is successful only when the absolute difference in `x`, `y`, `width`, and `height` is individually within that tolerance.

Tolerance absorbs harmless Accessibility rounding without hiding material application constraints. It is expressed in logical points and does not depend on display scale.

## Failure Semantics

The pipeline stops further writes at the first failed stage. It does not attempt position after resize failure. After a write failure, it makes one best-effort read from the same window so a partial resulting frame can be included in the failure; failure to perform that supplementary read does not replace the original error. The pipeline never reports success without a valid verification read-back. Invalid requested frames are rejected before any write.

Mutation failures are returned as values so app orchestration, future Smart Snap behavior, and diagnostics can make explicit decisions. Permission, application acquisition, target acquisition, display selection, and layout calculation errors remain outside the mutation result because they occur before mutation begins.
