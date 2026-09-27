# LauncherOS Decision Gate — V3.2

## Purpose

Prevent autonomous execution from silently making strategic, ambiguous, conflicting, destructive, or irreversible decisions.

## Level 0 — Autonomous

Allowed when work is:

- deterministic;
- bounded;
- reversible;
- in scope;
- verifiable;
- within budget.

Examples: routine code change, test fix, documentation update, deterministic compile failure repair.

## Level 1 — Controlled

Allowed with explicit task scope, acceptance criteria, checkpoint, and bounded budget.

Examples: defined UI implementation, small internal refactor, controlled performance change.

## Level 2 — Human Decision

Stop and request the Project Owner when the task requires:

- architecture changes;
- product/scope changes;
- ambiguous reference interpretation;
- major dependency changes;
- new infrastructure;
- irreversible actions;
- release/signing decisions;
- authentication or secret changes;
- destructive operations.

## Conflict Gate

If two authoritative sources disagree:

1. identify the conflict;
2. inspect DECISIONS.md and relevant Git history;
3. resolve only if objectively determined;
4. otherwise set CONFLICT and stop.

## Ambiguity Gate

If acceptance or reference intent is insufficiently defined, set DECISION_REQUIRED. Do not invent requirements.

## Scope Gate

If execution requires changing DO_NOT_TOUCH or expanding ALLOWED_SCOPE, stop.

## Budget Gate

If any mandatory budget limit is exhausted, stop with BUDGET_EXHAUSTED.

## Failure Gate

A deterministic technical failure may be diagnosed and repaired.

An ambiguous or strategic failure requires a decision gate.

## Security Gate

Stop for secrets, credentials, authentication material, signing keys, destructive migration, or unsafe external actions.

## Decision request format

```text
DECISION_ID:
TASK_ID:
STATUS: DECISION_REQUIRED
QUESTION:
KNOWN_FACTS:
OPTIONS:
CURRENT_BLOCKER:
REQUIRED_DECISION:
```

A human resolution must be recorded in DECISIONS.md before the blocked task is treated as unlocked.
