# Typography

OpenSnap uses the system font stack. Typography should feel like macOS, not a custom brand exercise.

## Fonts

- Primary: SF Pro through SwiftUI and AppKit system fonts
- Monospaced: SF Mono for diagnostics, geometry, shortcuts, and logs

## Hierarchy

| Role | Guidance |
| --- | --- |
| Large title | Rare. Use only for first-run or major settings surfaces. |
| Title | Section identity and window-level context. |
| Headline | Group headings and important controls. |
| Body | Standard explanatory text. |
| Callout | Compact guidance and secondary settings text. |
| Caption | Diagnostics, metadata, and helper labels. |

## Sizes

Use platform text styles before fixed sizes. Fixed sizes should be rare and justified by layout constraints such as diagnostics tables.

## Spacing

Text should have enough breathing room to scan quickly. Avoid dense paragraphs inside the app. Documentation can be more detailed; UI should be spare.

## Accessibility

- Respect Dynamic Type where supported on macOS.
- Maintain contrast in light and dark mode.
- Do not encode meaning through color alone.
- Keep labels plain and explicit.
- Avoid truncating critical instructions.
