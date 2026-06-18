# Contributing

Thank you for considering a contribution to OpenSnap.

OpenSnap is a native macOS product and open-source project. Contributions should protect simplicity, reliability, privacy, accessibility, and maintainability.

## Repository Workflow

GitHub is the source of truth.

1. Start from the latest `main`.
2. Create a focused feature branch.
3. Make the smallest change that fully solves the problem.
4. Add or update tests when behavior changes.
5. Update documentation when architecture, product behavior, or design direction changes.
6. Open a Pull Request.
7. Wait for architecture, design, and owner review before merge.

## Branches

Use clear branch names:

```text
feature/window-engine
feature/project-governance
fix/screen-frame-resolution
docs/design-system
```

## Pull Requests

PRs should include:

- Summary
- Testing performed
- Architecture decisions
- Design decisions when applicable
- Technical debt
- Future milestones or follow-up work

## Architecture Review

Architecture changes should explain:

- why the change is needed
- trade-offs
- alternatives considered
- testability impact
- long-term maintenance impact

## Design Review

UI and UX changes should align with the OpenSnap Design System.

Before adding UI, ask:

- Does it feel native to macOS?
- Is it simpler than before?
- Is it visually balanced?
- Does it support the 60/40 identity?
- Does it preserve consistency?
- Does it scale into future releases?

## Coding Standards

- Swift 6
- SwiftUI for UI
- AppKit and Accessibility APIs for macOS integration
- Prefer Apple frameworks
- Avoid unnecessary dependencies
- No force unwraps unless mathematically impossible to fail
- Keep functions small
- Prefer straightforward code over clever code
- Keep `OpenSnapCore` platform-independent where practical

## Testing Expectations

- Run the complete test suite before opening a PR.
- Add unit tests for layout algorithms.
- Keep window calculations testable without launching the UI.
- Document manual QA for Accessibility and macOS integration work.

## Documentation Expectations

Update docs when changing:

- architecture
- design system
- contributor workflow
- product behavior
- roadmap
- major decisions

## Privacy

Do not add telemetry, analytics, ads, accounts, subscriptions, cloud sync for core behavior, or closed-source product components.
