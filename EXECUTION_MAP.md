# LauncherOS Execution Map — V3.2

## Goal

Move LauncherOS to a stable, reference-fidelity launcher with a verified installable APK for the target BG6 device.

## Control-plane milestones

1. M01 — Control plane foundation
2. M02 — Bridge integration
3. M03 — First bounded LauncherOS execution

## Product milestones

4. M04 — Launcher stability
5. M05 — Reference Phase 1
6. M06 — Verification
7. M07 — Dock/folders
8. M08 — App Library/search
9. M09 — Motion/widgets/edit/performance
10. M10 — Release

## Dependency rule

A task unlocks only when its dependencies are satisfied and no decision or conflict gate blocks it.

## Current position

- V3.2 control-plane documents: IMPLEMENTED.
- Bridge integration: TODO.
- First executable task contract: TODO.
- Launcher product execution: LOCKED until the control-plane smoke test passes.

## Resource strategy

Use GitHub for planning, documentation, state, task creation, review, and history.

Use Codespace only for shell, build, test, and debugging work.

Prefer one bounded Codespace session per execution unit.

## Completion rule

A milestone is not complete because code compiles. Applicable acceptance evidence must exist.
