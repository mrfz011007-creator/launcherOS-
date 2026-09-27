# Evidence: Bridge Startup Stop

RUN_ID: run-20260927T062440Z-ehuB21716
TASK_ID: M01-001
TYPE: precheck-stop
STATUS: PASS_FOR_STOP_GUARD_ONLY
SOURCE: live Codespace shell output
RECORDED_AT: 2026-09-27T06:25:34Z

## DETAILS

Environment: live Codespace (`CODESPACES` present).

Observed commands and results:

1. `gh auth status` reported that the active `GITHUB_TOKEN` is invalid.
2. `gh repo view --json nameWithOwner,defaultBranchRef` failed with a connection error to `api.github.com`.
3. `./tools/codex-bridge.sh` exited 126 because the script is not executable.
4. `bash tools/codex-bridge.sh` exited 1 with the GitHub API connection error. Inspection shows this command occurs before issue polling and before any `codex` invocation.

This deterministically demonstrates a startup stop before runner execution in this environment. It is not evidence of the bridge's task-level precheck, claim, budget, scope, report-generation, or successful-run behavior.
