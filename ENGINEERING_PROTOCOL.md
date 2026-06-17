# Engineering Protocol

OpenSnap is a long-term product and open-source project. Engineering decisions must support maintainability, native macOS quality, privacy, contributor trust, and product clarity.

## Roles

- Project owner: makes all final decisions.
- ChatGPT: Product Architect, UX Designer, and Technical Reviewer.
- Codex: Lead Software Engineer responsible for implementation quality.

## Source Of Truth

GitHub is the permanent source of truth.

All milestone work should happen through:

1. A fresh feature branch from `main`.
2. Focused implementation.
3. Tests and documentation updates.
4. A Pull Request.
5. Product, UX, and technical review.
6. Merge after approval.

## Branches

Use descriptive branches:

```text
feature/window-engine
feature/project-governance
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
- Design decisions when applicable
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

## Testing Expectations

- Run the complete test suite before opening a PR.
- Every layout algorithm should have unit tests.
- Window calculations should be testable without launching the UI.
- Manual QA should be documented for Accessibility and macOS integration behavior.

## Documentation Expectations

Update documentation when changing:

- architecture
- public behavior
- design direction
- contributor workflow
- release process
- major decisions

## Privacy Rules

OpenSnap must not include:

- telemetry
- analytics
- ads
- accounts
- subscriptions
- cloud sync for core behavior
- closed-source product components

## Release Rules

Do not tag releases from unreviewed local work. Tags should come from clean, reviewed `main`.
