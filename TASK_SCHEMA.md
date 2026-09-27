# LauncherOS Task Schema — V3.2

Every executable task must follow this contract.

## Required fields

- TASK_ID
- RUN_ID
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

## State values

- TODO
- IMPLEMENTING
- TESTING
- VERIFYING
- DONE
- FAILED
- BLOCKED
- CONFLICT
- DECISION_REQUIRED
- BUDGET_EXHAUSTED

## Risk

- A: routine, reversible, deterministic technical work.
- B: controlled internal change with explicit acceptance.
- C: architecture, scope, major dependency, orchestration, business/product decision, or irreversible action.

Level C requires the Decision Gate.

## Scope rules

ALLOWED_SCOPE defines what the task may change.

DO_NOT_TOUCH defines protected areas.

A discovery outside scope is not permission to expand scope. Report it and stop or continue only if the task contract explicitly permits it.

## Acceptance

Acceptance criteria must be observable. Avoid criteria such as "looks better" unless accompanied by a concrete reference comparison method.

## Budget

Example:

```yaml
budget:
  max_steps: 20
  max_tool_calls: 40
  max_retries: 2
  max_runtime_minutes: 30
```

A budget is a safety boundary, not a progress target.

## Stop conditions

Every task must state conditions that force the runner to stop, including decision, conflict, budget, scope, and security conditions where applicable.

## Expected output

A completed run must produce an execution report, verification evidence, Git state, and a clear next position.
