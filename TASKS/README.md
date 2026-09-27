# LauncherOS Tasks

Tasks are execution contracts, not general feature ideas.

## Priority

- P0 — blocking
- P1 — current milestone
- P2 — required dependency
- P3 — optimization
- P4 — optional

## Milestones

- M01 — HOME
- M02 — DOCK
- M03 — FOLDER
- M04 — APP_LIBRARY
- M05 — SEARCH
- M06 — MOTION
- M07 — WIDGET
- M08 — EDIT_MODE
- M09 — PERFORMANCE
- M10 — RELEASE

## Task selection

A scheduler or Director selects only a task whose dependencies are satisfied and whose decision/conflict gates are clear.

Do not invent a new task merely because an improvement is noticed.

## Task file contract

Each task file must contain:

- objective;
- risk;
- current state;
- allowed scope;
- do-not-touch;
- dependencies;
- relevant context;
- acceptance criteria;
- test requirement;
- budget;
- stop conditions;
- expected output.

Detailed task files are added only when the corresponding milestone is ready to execute.
