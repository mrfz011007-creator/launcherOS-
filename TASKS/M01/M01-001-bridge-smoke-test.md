---
TASK_ID: M01-001
TITLE: V3.2 Bridge Smoke Test
MILESTONE: M01
RISK: A
CURRENT_STATE: TODO

OBJECTIVE: >
  Prove that the V3.2 execution bridge can load an authoritative task
  contract, execute one bounded runner action, enforce its budget, create
  an execution report/evidence, and produce a Git checkpoint without
  changing Android source or build configuration.

ALLOWED_SCOPE:
  - tools/
  - EXECUTIONS/
  - EVIDENCE/
  - PROJECT_STATE.md

DO_NOT_TOUCH:
  - app/
  - gradle/
  - build.gradle
  - build.gradle.kts
  - settings.gradle
  - settings.gradle.kts
  - gradle.properties
  - secrets
  - authentication configuration
  - signing configuration
  - release configuration

DEPENDENCIES:
  - V3.2 control-plane foundation
  - BRIDGE_V3.2_SPEC.md
  - TASK_SCHEMA.md
  - EXECUTION_SCHEMA.md
  - DECISION_GATE.md
  - EXECUTION_ENGINE.md

RELEVANT_CONTEXT:
  - AI_MEMORY.md
  - AI_PROTOCOL.md
  - PROJECT_STATE.md
  - EXECUTION_MAP.md
  - BRIDGE_V3.2_SPEC.md

ACCEPTANCE_CRITERIA:
  - Task Contract is loaded from TASKS/ rather than treated as free-form issue instructions.
  - Precheck executes before Codex.
  - A unique RUN_ID is generated.
  - An active task claim prevents duplicate execution.
  - An Execution Packet is constructed from the task contract.
  - Codex is invoked only within the configured task budget.
  - The bridge records the actual resource usage available to it.
  - The bridge verifies changed files against ALLOWED_SCOPE and DO_NOT_TOUCH.
  - An execution report is created under EXECUTIONS/.
  - Evidence is created under EVIDENCE/ when applicable.
  - Git checkpoint information is recorded.
  - No files under app/ or Gradle configuration are changed by this task.
  - The final state and next position are explicit.

TEST_REQUIREMENT:
  - Run the bridge smoke test in a live Codespace.
  - Exercise at least one successful bounded run.
  - Exercise at least one precheck/stop path or otherwise demonstrate the stop guard with deterministic evidence.

BUDGET:
  max_steps: 10
  max_tool_calls: 20
  max_retries: 1
  max_recovery_attempts: 1
  max_runtime_minutes: 10

STOP_CONDITIONS:
  - SECURITY
  - CONFLICT
  - DECISION_REQUIRED
  - OUT_OF_SCOPE
  - BLOCKED
  - BUDGET_EXHAUSTED
  - TARGET_COMPLETE

EXPECTED_OUTPUT:
  - Verified execution report
  - Evidence of the smoke test
  - Git checkpoint / PR
  - Explicit next position for M01-002
---

# M01-001 — V3.2 Bridge Smoke Test

## Purpose

This task validates the execution control path only. It is not a LauncherOS UI task.

## Required proof

The run must demonstrate that:

1. the task contract is authoritative;
2. precheck happens before runner execution;
3. claims and RUN_ID prevent duplicate execution;
4. budget limits are enforced;
5. scope violations are detected;
6. execution/evidence records are produced;
7. Android and release-related files remain untouched.

## Forbidden shortcut

A successful Codex message is not sufficient evidence of completion. The bridge must verify the observable repository and execution state.

## Completion boundary

This task reaches `VERIFIED` only after the smoke-test evidence satisfies the acceptance criteria. Human review remains the final gate for `DONE` when required by the control-plane policy.
