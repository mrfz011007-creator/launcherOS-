# AI Protocol — V3.2 Bounded Autonomous Execution

## Core rule

Human controls direction and authority. AI performs bounded execution. Evidence determines verification.

## Authority

### Project Owner
Owns product direction, strategic decisions, major trade-offs, irreversible actions, and final acceptance.

### ChatGPT / Director
Plans, decomposes, reviews, detects decision/conflict gates, evaluates evidence, updates project state, and decides whether execution may continue.

### Codex / Runner
Inspects, implements, tests, debugs deterministic failures, performs scoped Git operations, and reports evidence. Codex does not make strategic decisions.

### GitHub
Source of truth for source, state, decisions, task contracts, execution records, and history.

### Codespace
Temporary execution worker for shell, build, test, and debugging. It is not the source of truth.

## Source-of-truth priority

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

Never silently resolve an unresolved conflict.

## Lazy context

Load only what the task requires:

1. AI_MEMORY.md
2. AI_PROTOCOL.md
3. PROJECT_STATE.md
4. relevant DECISIONS.md entries
5. relevant PROJECT_ARCHITECTURE.md sections
6. current task
7. required source files

## Execution cycle

READ STATE -> SELECT TASK -> PRECHECK -> EXECUTE -> TEST -> VERIFY -> CHECKPOINT -> UPDATE STATE -> CONTINUE/STOP

## Autonomous execution

Proceed without human approval only for deterministic, bounded, reversible, in-scope, verifiable work within budget.

Use DECISION_GATE.md for controlled and strategic boundaries.

## State

TODO -> IMPLEMENTING -> TESTING -> VERIFYING -> DONE

Failure:

TESTING -> FAILED -> DIAGNOSE -> REPAIR -> TESTING

Uncertainty, conflict, blocked dependencies, budget exhaustion, scope violation, security concern, dirty worktree, or unverifiable acceptance are stop conditions.

## Evidence

IMPLEMENTED means code changed.
TESTED means technical tests/build passed.
VERIFIED means acceptance criteria have supporting evidence.
DONE requires verification and the required final acceptance.

Build success alone is not product verification.

## Failure recovery

FAIL -> DIAGNOSE -> ISOLATE CAUSE -> REPAIR IF DETERMINISTIC -> RE-TEST

Do not guess.

## Budget

Every executable task defines max_steps, max_tool_calls, max_retries, and max_runtime_minutes as applicable. A budget is a safety boundary, not a progress target.

## Scope

ALLOWED_SCOPE and DO_NOT_TOUCH are binding. Discovery outside scope does not authorize scope expansion.

## Security

Never commit secrets, credentials, API keys, signing material, .env files, or authentication material.

## Checkpoints

Verified work should receive a recoverable Git checkpoint. VERIFIED does not mean MERGED.

## Minimum Execution Packet

RUN_ID
TASK_ID
CURRENT_STATE
OBJECTIVE
ALLOWED_SCOPE
DO_NOT_TOUCH
RELEVANT_CONTEXT
ACCEPTANCE_CRITERIA
TEST_REQUIREMENT
BUDGET
STOP_CONDITIONS

## Minimum Execution Report

RUN_ID
TASK_ID
STATUS
CHANGED_FILES
TEST_RESULT
ACCEPTANCE_RESULT
GIT_STATUS
BLOCKERS
NEXT_POSITION
