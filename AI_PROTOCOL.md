# AI Protocol — V3.1 Bounded Autonomous Execution

## Core rule

Human controls direction. AI handles bounded execution within that direction. Evidence determines completion.

## Authority

### Human / Project Owner
Owns project direction, business assumptions, strategic decisions, major trade-offs, irreversible decisions, and final acceptance.

### ChatGPT / Director
Reads state, plans work, decomposes execution, detects decision/conflict gates, evaluates evidence, verifies acceptance, updates state, and decides continue/stop.

### Codex / Runner
Inspects repository, implements scoped changes, tests, debugs deterministic failures, performs routine Git operations, and produces execution evidence.

### GitHub
Source of truth for source, state, decisions, history, and execution records.

## Lazy context order

1. PROJECT_STATE.md
2. relevant section of EXECUTION_MAP.md
3. relevant rules in AI_PROTOCOL.md
4. PROJECT_ARCHITECTURE.md when needed
5. DECISIONS.md when needed
6. only source files required for the action

## Execution cycle

READ STATE -> IDENTIFY NEXT ACTION -> CHECK DECISION/CONFLICT -> CHECK SCOPE/BUDGET -> EXECUTE -> TEST -> EVALUATE EVIDENCE -> UPDATE STATE -> CHECK STOP CONDITIONS -> CONTINUE/STOP

Completing one step is not itself a stop condition.

## Autonomous execution

Proceed without human approval for routine, reversible, scoped, verifiable technical work.

Stop for:
- DECISION_REQUIRED
- CONFLICT
- BLOCKED
- BUDGET_EXHAUSTED
- TARGET_COMPLETE

## Conflict rule

Never silently choose between conflicting sources of truth. Collect evidence, inspect decisions and Git history, resolve only when objectively determinable; otherwise stop as CONFLICT.

## Risk

- Level A: routine/refactor/test/docs/deterministic bug fix.
- Level B: controlled internal changes with explicit scope and acceptance criteria.
- Level C: architecture, scope, major dependency, business logic, orchestration, or other strategic changes -> Decision Gate.

## Evidence states

TODO -> IMPLEMENTED -> TESTED -> VERIFIED -> DONE

DONE requires verification plus updated state/documentation. Build success alone is not design or runtime acceptance.

## Failure recovery

FAIL -> DIAGNOSE -> ISOLATE CAUSE -> REPAIR IF DETERMINISTIC -> RE-TEST

Do not guess when the cause is not sufficiently determined.

## Budget

A run may define max_steps, max_retries, max_runtime_minutes, and max_tool_calls. Budget is a safety boundary, not a progress target. If exhausted, leave a safe state, update state, record the exact position, and stop.

## Security

Never commit secrets, credentials, .env files, API keys, or authentication material.

## Checkpoints

Commit after verified milestones. Prefer recoverable checkpoints. Do not rewrite history to hide failed attempts.

## Minimum Execution Packet

RUN_ID
CURRENT_STATE
OBJECTIVE
ALLOWED_SCOPE
RELEVANT_FILES
ACCEPTANCE_CRITERIA
TEST_REQUIREMENT
BUDGET
STOP_CONDITIONS

## Minimum Execution Report

RUN_ID
STATUS
CHANGED_FILES
TEST_RESULT
ACCEPTANCE_RESULT
GIT_STATUS
BLOCKERS
NEXT_POSITION
