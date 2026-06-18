# Color Palette

OpenSnap should use native macOS semantic colors wherever practical. Custom colors are reserved for brand identity and moments where semantic colors cannot communicate the product clearly.

## Brand Colors

| Role | Recommended Value | Use |
| --- | --- | --- |
| Primary | System Blue | Brand mark, focused actions, selection, emphasis |
| Secondary | System Gray / Neutral Ink | Secondary pane, text, quiet UI structure |
| Accent | System Blue | Keyboard focus, selected states, links |

## Semantic Colors

Use platform semantic colors first:

| Role | macOS Preference | Use |
| --- | --- | --- |
| Background | `Color(nsColor: .windowBackgroundColor)` | Main windows and settings |
| Surface | `Color(nsColor: .controlBackgroundColor)` | Panels and grouped controls |
| Separator | `Color(nsColor: .separatorColor)` | Dividers |
| Label | `Color(nsColor: .labelColor)` | Primary text |
| Secondary Label | `Color(nsColor: .secondaryLabelColor)` | Secondary text |
| Success | System Green | Confirmed state when feedback is necessary |
| Warning | System Orange / Yellow | Recoverable issues |
| Error | System Red | Failed operations and permission problems |

## Rules

- Prefer semantic colors for adaptive light and dark mode behavior.
- Keep blue meaningful. Do not turn the whole app blue.
- Avoid decorative gradients in UI.
- Use contrast to clarify state, not to decorate.
- Never depend on color alone for accessibility.
