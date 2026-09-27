# LauncherOS Bridge V3.2 Specification

Status: DESIGN-READY
Component: tools/codex-bridge.sh
Scope: bounded task execution from GitHub to Codex and back to verifiable GitHub evidence

## Purpose

Bridge V3.2 is an execution controller. It does not make product or architecture decisions.

The bridge must:

1. load an authoritative Task Contract from `TASKS/`;
2. perform deterministic precheck;
3. claim one task with a unique `RUN_ID`;
4. build an Execution Packet;
5. invoke Codex within the task budget;
6. verify scope, tests, evidence, and Git state;
7. attempt only deterministic repairs within the allowed retry budget;
8. stop on decision, conflict, security, scope, blocking, or budget conditions;
9. write an Execution Report and evidence;
10. create a Git checkpoint/PR when verification permits.

## Authority

The control hierarchy is:

1. Project Owner decisions
2. `DECISIONS.md`
3. `AI_MEMORY.md`
4. `PROJECT_ARCHITECTURE.md`
5. `AI_PROTOCOL.md`
6. `PROJECT_STATE.md`
7. `EXECUTION_MAP.md`
8. Task Contract in `TASKS/`
9. source code
10. runner assumptions

A GitHub Issue is a trigger, not the task contract. The issue should identify a `TASK_ID`; the bridge must load the corresponding task file from the repository.

## Task Contract

Each executable task must provide the fields defined by `TASK_SCHEMA.md`:

- TASK_ID
- TITLE
- OBJECTIVE
- RISK
- CURRENT_STATE
- ALLOWED_SCOPE
- DO_NOT_TOUCH
- DEPENDENCIES
- RELEVANT_CONTEXT
- ACCEPTANCE_CRITERIA
- TEST_REQUIREMENT
- BUDGET
- STOP_CONDITIONS
- EXPECTED_OUTPUT

`RUN_ID` belongs to the execution record and is generated at runtime.

## Execution lifecycle

```
CREATED
  ↓
PRECHECK
  ↓
CLAIMED
  ↓
RUNNING
  ↓
TESTING
  ├─ PASS → VERIFYING
  └─ FAIL → DIAGNOSE
                 ├─ deterministic → REPAIR → TESTING
                 └─ ambiguous/strategic → STOPPED
```

A successful verified run ends in `VERIFIED` or `TARGET_COMPLETE`. Human acceptance may still be required before a task reaches `DONE`.

## Precheck

The bridge must verify, in order:

1. repository is valid;
2. base branch exists;
3. working tree is clean;
4. task file exists and is parseable;
5. task state is executable;
6. dependencies are satisfied;
7. no unresolved decision or conflict gate blocks execution;
8. budget values are valid and bounded;
9. required commands/environment are available;
10. protected paths are known.

Any failed precheck stops the run before Codex is invoked.

## Task claim and concurrency

The bridge generates a unique `RUN_ID` and records:

- RUN_ID
- TASK_ID
- WORKER
- CLAIMED_AT

An active claim must prevent a second bridge instance from executing the same task concurrently.

A stale run may be recovered only under the task's recovery budget. Recovery must never create an unbounded execution loop.

## Execution Packet

The packet passed to Codex contains:

- RUN_ID
- TASK_ID
- OBJECTIVE
- ALLOWED_SCOPE
- DO_NOT_TOUCH
- DEPENDENCIES
- RELEVANT_CONTEXT
- ACCEPTANCE_CRITERIA
- TEST_REQUIREMENT
- BUDGET
- STOP_CONDITIONS

Codex should load context lazily: persistent memory/state first, then only relevant source files.

## Runner authority

Codex may:

- inspect;
- edit;
- run tests/builds;
- diagnose deterministic failures;
- repair deterministic failures;
- commit;
- report.

Codex must not:

- expand task scope;
- alter acceptance criteria;
- make strategic architecture decisions;
- resolve conflicts;
- invent requirements;
- modify secrets/authentication/signing unless explicitly allowed by a human-approved task;
- claim human acceptance.

## Budget

Every run has a hard budget. The initial schema supports:

```yaml
budget:
  max_steps: 20
  max_tool_calls: 40
  max_retries: 2
  max_recovery_attempts: 1
  max_runtime_minutes: 30
```

Budget is a safety boundary, not a progress target. The bridge must stop with `BUDGET_EXHAUSTED` rather than silently increasing a limit.

## Stop protocol

Stop conditions have priority:

1. SECURITY
2. CONFLICT
3. DECISION_REQUIRED
4. OUT_OF_SCOPE
5. BUDGET_EXHAUSTED
6. BLOCKED
7. TARGET_COMPLETE

Every stopped run must record `STOP_REASON` and enough detail to resume or request a decision.

## Verification

A Codex success result is not accepted without verification.

The bridge verifies:

- process result;
- changed files;
- allowed scope;
- protected paths;
- declared tests;
- available acceptance evidence;
- execution report;
- Git state.

If a file outside `ALLOWED_SCOPE` changed, the run stops as `OUT_OF_SCOPE`.

## Evidence model

Evidence is separated into:

1. implementation evidence;
2. technical test evidence;
3. product acceptance evidence.

A build passing proves a technical condition only. It does not prove visual fidelity, device behavior, or final product acceptance.

## Recovery

Deterministic failures may be retried up to `max_retries`.

Worker interruption may be recovered up to `max_recovery_attempts`.

Architectural ambiguity, reference ambiguity, conflicting requirements, security concerns, or protected-area changes must stop with `DECISION_REQUIRED`, `CONFLICT`, or `SECURITY` as appropriate.

## Git checkpoint

When technical verification succeeds:

```
codex/<task-id>
  ↓
commit
  ↓
push
  ↓
PR
```

A PR is a checkpoint and review surface. It is not equivalent to final product acceptance.

## Execution record

Each run must produce:

```
EXECUTIONS/<TASK_ID>/<RUN_ID>.md
```

The record must follow `EXECUTION_SCHEMA.md` and contain the exact next position.

## First task

The first implementation task is:

```
M01-001 — V3.2 Bridge Smoke Test
```

It intentionally does not modify Android source or build configuration.

## Non-goals

The first Bridge implementation must not introduce:

- a database;
- a queue service;
- a webhook server;
- a dashboard;
- external orchestration infrastructure;
- automatic release/signing behavior.

Add infrastructure only after a measured requirement and explicit approval.
