# LauncherOS AI Memory — V3.2

## Purpose

Persistent operational memory for the LauncherOS execution system. This file stores stable project context and operating invariants; it is not a substitute for current state, task contracts, or explicit decisions.

## Project identity

- Project: LauncherOS
- Repository: mrfz011007-creator/launcherOS-
- Platform: Android
- Target device: TECNO SPARK Go 2024 / BG6
- Android target context: Android 13
- Physical RAM: 4 GB
- Resolution: 720x1612
- Stack: Kotlin + Jetpack Compose
- Primary constraint: performance must remain acceptable on the target device.

## Source-of-truth priority

When sources disagree, use this order:

1. Project Owner explicit decision
2. DECISIONS.md
3. AI_MEMORY.md
4. PROJECT_ARCHITECTURE.md
5. AI_PROTOCOL.md
6. PROJECT_STATE.md
7. EXECUTION_MAP.md
8. TASKS/*
9. source code
10. AI/Codex assumptions

Do not silently resolve unresolved conflicts.

## Roles

### Project Owner

Controls product direction, strategic decisions, major trade-offs, irreversible actions, and final acceptance.

### ChatGPT / Director

Plans, decomposes, reviews, detects gates, evaluates evidence, updates project state, and decides whether execution may continue.

### Codex / Runner

Inspects, implements, tests, debugs deterministic failures, performs scoped Git operations, and reports evidence. Codex does not make strategic decisions.

### GitHub

Source of truth for repository state, decisions, task contracts, execution records, and history.

### Codespace

Temporary execution worker for shell, build, test, and debugging work. It is not the project source of truth.

## Product vision

LauncherOS must follow the supplied reference-first design:

- wallpaper remains visually dominant;
- UI feels layered over the wallpaper;
- glass is used for shared containers/surfaces;
- icons are not individually boxed;
- dock is a shared glass surface;
- folders use a shared glass container;
- app library uses a vertical alphabetical model;
- search is an interaction layer;
- motion is fast, subtle, and consistent;
- heavy blur and repeated graphics layers are avoided.

## Performance rules

Prefer:

- shared surfaces;
- bounded/cached bitmaps;
- lazy collections;
- limited graphics layers;
- minimal repeated rendering.

Avoid:

- per-icon blur;
- per-icon shadow;
- opaque full-screen panels;
- expensive recomposition;
- unnecessary background effects.

## Execution invariants

1. Autonomy applies to execution, not authority.
2. Every executable task has explicit scope and acceptance criteria.
3. Build success is not product verification.
4. Retry requires diagnosis.
5. Conflicts are not resolved by guessing.
6. Strategic or irreversible actions require a decision gate.
7. Resource budgets are safety boundaries.
8. Verified checkpoints must remain recoverable.

## Evidence states

TODO -> IMPLEMENTED -> TESTED -> VERIFIED -> DONE

DONE means the applicable acceptance evidence exists and the Project Owner has accepted the result where human acceptance is required.

## Stop conditions

- DECISION_REQUIRED
- CONFLICT
- BLOCKED
- BUDGET_EXHAUSTED
- TARGET_COMPLETE
- SCOPE_VIOLATION
- SECURITY_CONCERN
- DIRTY_WORKTREE
- UNVERIFIABLE_ACCEPTANCE

## Memory maintenance

Update this file only when stable operational context changes. Do not put temporary task status, transient logs, secrets, credentials, or speculative conclusions here.
