# Project

OpenSnap is a free and open-source native macOS window manager.

## Product Promise

OpenSnap helps users align, flow, and focus.

It should be fast enough to disappear, clear enough to understand immediately, and trustworthy enough to run every day.

## Product Direction

- Native macOS look and feel
- Minimal, elegant, and extremely fast
- Simplicity over feature count
- Reliability over cleverness
- Privacy-first by default
- Open source forever

## Non-Goals

OpenSnap will not become:

- a subscription product
- an analytics product
- an account-based service
- a cloud workspace
- a bloated productivity suite
- an Electron app

## Project Culture

Quality matters more than speed. Simplicity matters more than feature count. Reliability matters more than cleverness.

## Continuous Integration Artifacts

GitHub Actions preserves existing build and test gates in one sequential **Build** workflow. A run must successfully build the Swift package and native macOS app, pass the complete test suite, and verify the generated `OpenSnap.app` before packaging or upload begins.

Successful runs package the application as `OpenSnap-macOS.zip` and expose it in the workflow run's **Artifacts** section for 30 days. Anyone with access to the Actions run can download the artifact without Xcode.

The artifact is currently unsigned. The workflow keeps verification, packaging, and upload as separate stages so code signing, Hardened Runtime, notarization, DMG packaging, and GitHub Releases can be added later without restructuring the build and test gates.
