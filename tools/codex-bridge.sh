#!/usr/bin/env bash
set -euo pipefail

# LauncherOS Jalur B bridge:
# GitHub Issue (codex-task) -> Codex exec -> Git changes -> Issue result.
#
# Run this from the LauncherOS Codespace:
#   ./tools/codex-bridge.sh
#
# Environment:
#   CODEX_POLL_SECONDS=10
#   CODEX_SANDBOX=workspace-write   # or danger-full-access when builds need network
#   CODEX_MODEL=                   # optional
#   CODEX_MAX_TASK_SECONDS=1800

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

POLL_SECONDS="${CODEX_POLL_SECONDS:-10}"
SANDBOX="${CODEX_SANDBOX:-workspace-write}"
MODEL="${CODEX_MODEL:-}"
MAX_TASK_SECONDS="${CODEX_MAX_TASK_SECONDS:-1800}"
TASK_LABEL="codex-task"
RUNNING_LABEL="codex-running"
DONE_LABEL="codex-done"
FAILED_LABEL="codex-failed"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing command: $1" >&2
    exit 1
  }
}

require_cmd gh
require_cmd codex
require_cmd git
require_cmd timeout

REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"

ensure_label() {
  local name="$1"
  local description="$2"
  gh label create "$name" --description "$description" >/dev/null 2>&1 || true
}

ensure_label "$TASK_LABEL" "Task for the LauncherOS Codex bridge"
ensure_label "$RUNNING_LABEL" "Currently being processed by Codex"
ensure_label "$DONE_LABEL" "Completed by Codex"
ensure_label "$FAILED_LABEL" "Codex could not complete the task"

echo "LauncherOS Codex bridge"
echo "Repository : $REPO"
echo "Sandbox    : $SANDBOX"
echo "Polling    : ${POLL_SECONDS}s"
echo "Waiting for issues labelled '$TASK_LABEL'..."

run_task() {
  local number="$1"
  local title="$2"
  local body="$3"
  local prompt_file output_file

  prompt_file="$(mktemp)"
  output_file="$(mktemp)"
  trap 'rm -f "$prompt_file" "$output_file"' RETURN

  cat >"$prompt_file" <<EOF
You are the implementation agent for LauncherOS.

Repository: $REPO
GitHub issue: #$number
Issue title: $title

TASK:
$body

AUTOMATION RULES:
1. Work directly in the current repository.
2. Inspect the existing implementation before editing.
3. Follow AGENTS.md and the LauncherOS reference-fidelity rules.
4. Make the smallest coherent implementation that solves the task.
5. Run relevant tests/build checks before finishing.
6. Do not merely describe code changes: actually implement them.
7. Do not modify secrets, authentication files, or unrelated projects.
8. If blocked, explain the exact blocker instead of inventing a result.
9. Leave the working tree in a reviewable state.
10. Your final response must contain:
   - STATUS: DONE or BLOCKED
   - SUMMARY: concise changes
   - VERIFICATION: commands/tests and results
   - NOTES: remaining issues, if any
EOF

  gh issue edit "$number" --add-label "$RUNNING_LABEL" --remove-label "$TASK_LABEL" >/dev/null

  local -a codex_args
  codex_args=(exec --sandbox "$SANDBOX")
  if [[ -n "$MODEL" ]]; then
    codex_args+=(--model "$MODEL")
  fi
  codex_args+=("$(cat "$prompt_file")")

  echo "[$(date -Is)] Starting Codex for issue #$number"
  local exit_code=0
  timeout --signal=TERM --kill-after=30s "$MAX_TASK_SECONDS" \
    "${codex_args[@]}" >"$output_file" 2>&1 || exit_code=$?

  if [[ "$exit_code" -eq 0 ]]; then
    local result
    result="$(tail -c 12000 "$output_file")"
    gh issue comment "$number" --body-file <(printf '%s\n\n%s' \
      "## Codex result" "$result") >/dev/null
    gh issue edit "$number" --add-label "$DONE_LABEL" --remove-label "$RUNNING_LABEL" >/dev/null
    gh issue close "$number" >/dev/null
    echo "[$(date -Is)] Issue #$number completed."
  else
    local result
    result="$(tail -c 12000 "$output_file")"
    gh issue comment "$number" --body-file <(printf '%s\n\nExit code: %s\n\n%s' \
      "## Codex failed or timed out" "$exit_code" "$result") >/dev/null
    gh issue edit "$number" --add-label "$FAILED_LABEL" --remove-label "$RUNNING_LABEL" >/dev/null
    echo "[$(date -Is)] Issue #$number failed (exit $exit_code)."
  fi

  # Return to the repository root even if Codex changed directories.
  cd "$ROOT"
}

while true; do
  tasks="$(gh issue list --repo "$REPO" --state open --label "$TASK_LABEL" \
    --limit 10 --json number,title,body --jq '.[] | @base64')"

  if [[ -n "$tasks" ]]; then
    while IFS= read -r encoded; do
      [[ -z "$encoded" ]] && continue
      issue_json="$(printf '%s' "$encoded" | base64 --decode)"
      number="$(jq -r '.number' <<<"$issue_json")"
      title="$(jq -r '.title' <<<"$issue_json")"
      body="$(jq -r '.body // ""' <<<"$issue_json")"
      run_task "$number" "$title" "$body"
    done <<<"$tasks"
  fi

  sleep "$POLL_SECONDS"
done
