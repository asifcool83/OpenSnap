# AI Context

`AI_CONTEXT.md` is the authoritative entry point for AI contributors working on OpenSnap. Read this document before planning, reviewing, or changing the project. Follow its links when a task needs deeper product, engineering, architecture, or design context; do not assume this overview replaces those source documents.

## Project Overview

OpenSnap is a free, open-source, native macOS window manager. It helps people arrange windows quickly and precisely without accounts, subscriptions, analytics, telemetry, or cloud dependencies.

The product vision is to feel like a missing part of macOS: immediately understandable, fast enough to disappear into the workflow, reliable enough for daily use, and pleasant for contributors to maintain. OpenSnap is intentionally focused. It is not a general productivity suite, and more features do not automatically make it better.

The product philosophy is **align, flow, and focus**. The 60% / 40% split expresses that philosophy as 60% focus and 40% context. Product decisions should protect clarity, precision, balance, user trust, and long-term maintainability. See [PROJECT.md](PROJECT.md), [MISSION.md](MISSION.md), [VISION.md](VISION.md), and [CONSTITUTION.md](CONSTITUTION.md) for the durable product direction.

## Product Principles

- **Native macOS first.** Prefer Swift, SwiftUI, AppKit, Accessibility APIs, SF Symbols, and platform conventions. OpenSnap should look and behave as though it belongs on macOS.
- **Simplicity over feature count.** Keep the interaction model and implementation understandable. A smaller coherent product is better than a larger confusing one.
- **Reliability over cleverness.** Choose predictable behavior, explicit code, and tested foundations over novelty or fragile shortcuts.
- **Privacy first.** OpenSnap works locally and must not introduce telemetry, analytics, ads, accounts, subscriptions, or cloud requirements for core behavior.
- **Performance is a feature.** Window operations should feel immediate, and the app should remain lightweight and responsive.
- **Keyboard-first, mouse-friendly.** Core workflows should be efficient from the keyboard while remaining clear and accessible with pointer-based interaction.
- **Every feature must justify its existence.** New behavior must improve the core window-management experience enough to earn its product, UX, testing, and maintenance cost.
- **Apple-quality UX.** Favor native conventions, restraint, accessibility, visual balance, thoughtful copy, and polished edge cases.
- **GitHub is the source of truth.** Branches, Pull Requests, reviews, and repository documentation hold the durable project record. Do not leave important decisions only in an AI conversation.

The [OpenSnap Constitution](CONSTITUTION.md) is the permanent authority for these principles. Record accepted architectural decisions in [DECISIONS.md](DECISIONS.md) and design decisions under [DESIGN/](DESIGN/README.md).

## Architecture Overview

OpenSnap has two primary Swift targets:

- `OpenSnapCore` contains platform-independent logic and app-independent service models. It must remain testable without launching the application and must not import SwiftUI, AppKit, or Accessibility frameworks.
- `OpenSnap` is the executable macOS app. It owns SwiftUI views, AppKit and Accessibility integration, app lifecycle, settings wiring, diagnostics, and translation between macOS APIs and Core models.

This separation keeps layout, geometry, window-operation, Smart Snap, and shortcut semantics deterministic and unit-testable while isolating system APIs and UI concerns in the app layer. Preserve the boundary unless a documented architectural decision explicitly changes it.

Read [Documentation/Architecture.md](Documentation/Architecture.md) before architecture-sensitive work. Use the rest of [Documentation/](Documentation/) for subsystem contracts, development guidance, and behavior that needs more detail than belongs here.

## Engineering Workflow

OpenSnap work follows this sequence:

**Plan → Implement → Test → PR → Review → Merge**

Start from an up-to-date `main` branch. Define the responsibility and acceptance criteria before editing. Implement the smallest coherent change, test it in proportion to risk, update affected documentation, and open a focused Pull Request. Merge only after required review and checks pass.

Prefer small PRs with one responsibility. Separate unrelated refactors, behavior changes, documentation, and cleanup when they do not need to land together. Reliability and reviewability matter more than speed. Never trade away the architectural boundary, test coverage, user trust, or a clean repository history merely to finish sooner.

[ENGINEERING_PROTOCOL.md](ENGINEERING_PROTOCOL.md) defines the full contribution workflow, review gates, testing expectations, documentation rules, privacy requirements, and release rules.

## Repository Navigation

- [ENGINEERING_PROTOCOL.md](ENGINEERING_PROTOCOL.md): required workflow, review gates, testing, documentation, privacy, and release practices.
- [CONSTITUTION.md](CONSTITUTION.md): permanent product and engineering principles.
- [ROADMAP.md](ROADMAP.md): planned release progression and milestone direction.
- [PROJECT.md](PROJECT.md): product promise, direction, non-goals, and project culture.
- [DESIGN/](DESIGN/README.md): design system, brand, UX, UI, typography, color, spacing, motion, and assets.
- [Documentation/](Documentation/): architecture, subsystem contracts, and developer guidance.
- [DECISIONS.md](DECISIONS.md): accepted architectural decisions and their rationale.
- `OpenSnapCore/`: platform-independent logic.
- `OpenSnap/`: macOS application and system integration.
- `Tests/`: automated tests for Core behavior.

Read only the deeper documents relevant to the task, but follow every applicable rule they contain.

## Current Milestone

> **Update this section when the active milestone changes.**

- **Completed:** M0 — project foundation, design system, and repository governance.
- **Active:** M1 — Window Engine contracts and geometry.
- **Source of current scope:** the active milestone plan and PRs on GitHub, supported by [ROADMAP.md](ROADMAP.md).

Before starting milestone work, confirm that this section, the roadmap, and GitHub agree. If they conflict, do not silently choose one: identify the mismatch and ask the project owner which source should be updated.

## AI Contributor Rules

1. Read `AI_CONTEXT.md` first in every new session, then open the linked documents needed for the task.
2. Follow [ENGINEERING_PROTOCOL.md](ENGINEERING_PROTOCOL.md) and the [Constitution](CONSTITUTION.md).
3. Confirm the requested scope and avoid broadening it without a concrete, documented justification.
4. Prefer maintainable, explicit, testable solutions over clever or compressed implementations.
5. Preserve `OpenSnapCore` purity and keep platform frameworks in `OpenSnap`.
6. Avoid speculative abstractions, dependencies, settings, and extension points without a current requirement.
7. Ask for clarification when product behavior, UX intent, architecture, or acceptance criteria cannot be established from the repository and task.
8. Never silently change product behavior. Describe behavior changes, update tests and documentation, and surface trade-offs in the PR.
9. Keep privacy, accessibility, performance, and native macOS quality in scope for every relevant decision.
10. Leave durable knowledge in GitHub and repository documentation, not only in chat history.

## Handoff Expectations

Every completed task must provide a concise handoff with these headings:

- **Summary:** what was accomplished and why.
- **Files Changed:** the important files added, modified, or removed.
- **Tests:** automated and manual checks run, including results; state clearly when none apply.
- **Engineering Notes:** architectural decisions, behavior details, trade-offs, and review guidance.
- **Technical Debt:** known limitations or follow-up work; write `None identified` when appropriate.
- **Repository Status:** branch, commit or PR, CI state, and whether the working tree is clean.
- **Recommended Next Task:** the smallest logical follow-up, without silently beginning it.

The handoff should let the project owner or the next contributor understand the result without reconstructing the work from terminal output or conversation history.
