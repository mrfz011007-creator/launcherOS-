# LauncherOS Execution Engine — V3.2

## Purpose

Define the deterministic lifecycle used by the execution adapter. The engine is a protocol specification; the existing bridge remains the initial implementation adapter.

## Lifecycle

```
READY
  ↓
PRECHECK
  ↓
IMPLEMENTING
  ↓
TESTING
  ↓
VERIFYING
  ↓
CHECKPOINT
  ↓
VERIFIED
  ↓
DONE
```

Failure path:

```
TESTING
  ↓
FAILED
  ↓
DIAGNOSE
  ↓
DETERMINISTIC?
  ├─ yes → REPAIR → TESTING
  └─ no  → DECISION_REQUIRED
```

## PRECHECK

Verify:

- task exists and follows TASK_SCHEMA.md;
- dependencies are satisfied;
- no unresolved conflict exists;
- no pending decision blocks the task;
- scope is explicit;
- acceptance criteria are observable;
- test requirement exists;
- budget exists;
- execution environment is available;
- working tree is clean.

Failure of a precheck is a stop condition.

## Context loading

Load only what is required:

1. AI_MEMORY.md
2. AI_PROTOCOL.md
3. PROJECT_STATE.md
4. relevant DECISIONS.md entries
5. relevant PROJECT_ARCHITECTURE.md sections
6. current task
7. required source files

## Execution Packet

The runner receives:

- RUN_ID
- TASK_ID
- CURRENT_STATE
- OBJECTIVE
- ALLOWED_SCOPE
- DO_NOT_TOUCH
- RELEVANT_CONTEXT
- ACCEPTANCE_CRITERIA
- TEST_REQUIREMENT
- BUDGET
- STOP_CONDITIONS

## Runner authority

Codex may:

- inspect;
- implement;
- test;
- diagnose deterministic failures;
- repair deterministic failures;
- commit;
- report.

Codex may not:

- expand scope;
- change strategic decisions;
- resolve conflicts by assumption;
- invent requirements;
- modify protected files without authorization;
- release or sign builds autonomously;
- declare human acceptance.

## Verification

Verification must inspect:

- Git diff;
- test/build results;
- acceptance criteria;
- repository state;
- execution report.

Technical verification and product verification are separate.

## Checkpoint

A verified milestone may be committed and pushed to a task branch and represented by a PR.

VERIFIED does not mean MERGED.

## Stop conditions

Stop on:

- DECISION_REQUIRED
- CONFLICT
- BLOCKED
- BUDGET_EXHAUSTED
- TARGET_COMPLETE
- SCOPE_VIOLATION
- SECURITY_CONCERN
- DIRTY_WORKTREE
- UNVERIFIABLE_ACCEPTANCE

## Handoff

Before stopping:

1. update PROJECT_STATE.md;
2. write/update the task execution record;
3. preserve Git checkpoint when applicable;
4. state the exact next position.

## Resource principle

Do not keep a Codespace alive waiting for future work. A session should execute a bounded unit and stop.
