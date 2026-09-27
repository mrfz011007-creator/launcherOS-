# LauncherOS Execution Schema — V3.2

An execution record describes one bounded attempt to execute one task.

## Required fields

- RUN_ID
- TASK_ID
- STARTED_AT
- FINISHED_AT
- RUNNER
- INITIAL_STATE
- FINAL_STATE
- CHANGED_FILES
- CREATED_FILES
- DELETED_FILES
- TESTS
- ACCEPTANCE
- FAILURES
- GIT
- RESOURCE_USAGE
- BLOCKERS
- DECISION_REQUIRED
- NEXT_POSITION
- RUNNER_NOTES
- DIRECTOR_REVIEW

## Final state

Use one of the task state values defined by TASK_SCHEMA.md or one of:

- VERIFIED
- TARGET_COMPLETE

## Evidence rules

A report must distinguish:

1. implementation evidence;
2. technical test evidence;
3. product acceptance evidence.

Do not convert a Codex statement into verification without supporting evidence.

## Git record

Record:

- task branch;
- commit SHA;
- PR number/URL when created;
- clean/dirty status;
- whether the checkpoint is verified.

## Resource record

Record available information for:

- runtime;
- retries;
- tool calls;
- build duration;
- other relevant constrained resources.

## Next position

Every non-terminal execution must state exactly what should happen next.

Examples:

- RETRY_AFTER_DIAGNOSIS
- DECISION_REQUIRED
- BLOCKED_EXTERNAL_DEPENDENCY
- NEXT_TASK:M03_FOLDER
- VERIFY_DEVICE
- TARGET_COMPLETE
