# UX

OpenSnap should be understandable immediately.

## Keyboard-First

Core window actions should be fast from the keyboard. Shortcuts should be memorable, reliable, and configurable over time.

## Mouse-Friendly

Keyboard-first does not mean keyboard-only. Menus and settings should let users discover and recover without memorizing everything.

## Zero Learning Curve

The best OpenSnap action is one the user can predict before trying it.

## Progressive Disclosure

Simple actions should be visible first. Advanced behavior should not crowd the core experience.

## Predictability

The same command should produce the same result. Cycles such as Smart Snap must be easy to understand and reset predictably.

## Instant Feedback

Window changes should feel immediate. Feedback should be visible only when it helps the user understand state or recover from failure.

## Accessibility

OpenSnap should support keyboard navigation, VoiceOver where practical, sufficient contrast, and clear permission guidance.

## First Run

The first launch should answer three questions in one compact window:

1. What does OpenSnap do?
2. Why does macOS require these permissions?
3. What keys produce the first result?

Permission requests must follow explicit user actions. A denied or revoked permission must always have a visible recovery route. Onboarding completion may be remembered locally, but permission truth must always come from macOS.

The moved window is the normal success feedback. OpenSnap should reserve additional messaging for setup state, constraints, and failures where guidance helps the user recover.
