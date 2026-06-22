# OpenSnap Update Delivery

OpenSnap does not currently include an automatic-update framework. The earlier inactive Sparkle scaffold was removed during M1.9 so the app does not ship an unused framework, update key, or feed configuration.

Update delivery should be selected and implemented together with the signed release pipeline. Before enabling it, the project must have:

- stable code-signing identity and Hardened Runtime settings;
- notarized release archives produced from a documented workflow;
- immutable GitHub Releases with release notes and checksums;
- protected update-signing keys and a rotation/recovery procedure;
- automated feed/archive validation and a manual upgrade-path test.

This work belongs with the v0.8.0-beta distribution milestone. It should not be reintroduced as configuration-only scaffolding.
