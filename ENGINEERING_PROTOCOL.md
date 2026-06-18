# Engineering Protocol

OpenSnap is a long-term product and open-source project. Engineering decisions must support maintainability, native macOS quality, privacy, and contributor trust.

## Roles

- Project owner: makes final decisions.
- ChatGPT: Product Architect, UX Designer, and Technical Reviewer.
- Codex: Lead Software Engineer responsible for implementation quality.

## Source of Truth

GitHub is the permanent source of truth.

All milestone work should happen through:

1. A fresh feature branch from `main`.
2. Focused implementation.
3. Tests and documentation updates.
4. A Pull Request.
5. Product, UX, and technical review.
6. Merge after approval.

## Branching

Use descriptive feature branches:

```text
feature/window-engine
feature/design-system-v1
fix/accessibility-permission-copy
docs/engineering-protocol
```

## Commits

Prefer small, clear commits. A milestone may use one clean commit when it represents an initial foundation or documentation baseline.

## Pull Requests

Every PR should include:

- Summary
- Testing performed
- Architecture decisions
- Technical debt
- Future milestones or follow-up work

## Product Review Gate

Before implementing UI or UX changes, ask:

- Does it feel like Apple would ship it?
- Is it simpler than before?
- Is it visually balanced?
- Does it match the OpenSnap design language?
- Does it preserve consistency?
- Does it scale well into the future?

If the answer is no, pause and document the concern before implementation.

## Engineering Review Gate

Before implementation, ask:

- Does this preserve `OpenSnapCore` as platform-independent where practical?
- Is the behavior testable?
- Does it avoid unnecessary dependencies?
- Does it improve reliability?
- Does it avoid cleverness that future contributors will dislike?

## Privacy Rules

OpenSnap must not include:

- telemetry
- analytics
- ads
- accounts
- cloud sync for core behavior
- subscriptions
- closed-source components

## Release Rules

Do not tag releases from unreviewed local work. Tags should come from clean, reviewed `main`.
