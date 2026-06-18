# Color Palette

OpenSnap should use native macOS semantic colors wherever practical. Custom colors are reserved for brand identity and moments where semantic colors cannot communicate clearly.

## Brand Colors

| Role | Recommendation | Use |
| --- | --- | --- |
| Primary | System Blue | Brand mark, focus, selected states, links |
| Secondary | System Gray / Neutral Ink | Context pane, quiet structure, secondary emphasis |
| Accent | System Blue | Keyboard focus, active controls, confirmation of selection |

## Semantic Colors

| Role | macOS Preference | Use |
| --- | --- | --- |
| Background | `windowBackgroundColor` | Main windows and settings |
| Surface | `controlBackgroundColor` | Panels and grouped controls |
| Separator | `separatorColor` | Dividers |
| Label | `labelColor` | Primary text |
| Secondary Label | `secondaryLabelColor` | Secondary text |
| Success | System Green | Confirmed state when feedback is necessary |
| Warning | System Orange / Yellow | Recoverable issues |
| Error | System Red | Failed operations and permission problems |

## Rules

- Prefer semantic colors for adaptive light and dark mode behavior.
- Keep blue meaningful. Do not turn the whole app blue.
- Avoid decorative gradients in product UI.
- Use contrast to clarify state, not to decorate.
- Never depend on color alone for accessibility.
