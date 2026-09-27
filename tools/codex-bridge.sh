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
MAX_RETRIES="${CODEX_MAX_RETRIES:-1}"
BASE_BRANCH="${CODEX_BASE_BRANCH:-main}"
TASKS_ROOT="${CODEX_TASKS_ROOT:-TASKS}"
TASK_LABEL="codex-task"
RUNNING_LABEL="codex-running"
DONE_LABEL="codex-done"
VERIFIED_LABEL="codex-verified"
ACCEPTED_LABEL="codex-accepted"
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
require_cmd jq
require_cmd awk
require_cmd grep
require_cmd sed
require_cmd find

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

echo "LauncherOS Codex bridge V3.2"
echo "Repository : $REPO"
echo "Sandbox    : $SANDBOX"
echo "Polling    : ${POLL_SECONDS}s"
echo "Task root  : $TASKS_ROOT"
echo "Waiting for issues labelled '$TASK_LABEL'..."


frontmatter_value() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '
    BEGIN { started=0 }
    /^---[[:space:]]*$/ {
      if (started == 0) { started=1; next }
      exit
    }
    started == 1 && $0 ~ ("^" key ":[[:space:]]*") {
      sub("^" key ":[[:space:]]*", "", $0)
      print $0
      exit
    }
  ' "$file"
}

frontmatter_has_key() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '
    BEGIN { started=0; found=0 }
    /^---[[:space:]]*$/ {
      if (started == 0) { started=1; next }
      exit
    }
    started == 1 && $0 ~ ("^" key ":[[:space:]]*") {
      found=1
      exit
    }
    END { exit(found ? 0 : 1) }
  ' "$file"
}

budget_value() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '
    BEGIN { started=0; in_budget=0 }
    /^---[[:space:]]*$/ {
      if (started == 0) { started=1; next }
      exit
    }
    started == 1 {
      if ($0 ~ /^BUDGET:[[:space:]]*$/) { in_budget=1; next }
      if (in_budget && $0 ~ /^[A-Z][A-Z0-9_]*:/) { exit }
      if (in_budget && $0 ~ ("^[[:space:]]+" key ":[[:space:]]*[0-9]+[[:space:]]*$")) {
        line=$0
        sub("^[[:space:]]*" key ":[[:space:]]*", "", line)
        print line
        exit
      }
    }
  ' "$file"
}

find_task_file() {
  local task_id="$1"
  local count=0
  local match=""
  while IFS= read -r candidate; do
    count=$((count + 1))
    match="$candidate"
  done < <(find "$TASKS_ROOT" -type f -name "$task_id-*.md" -print)

  if [[ "$count" -eq 0 ]]; then
    echo "No task contract found for TASK_ID=$task_id" >&2
    return 1
  fi
  if [[ "$count" -gt 1 ]]; then
    echo "Multiple task contracts found for TASK_ID=$task_id" >&2
    return 1
  fi
  printf '%s\n' "$match"
}

validate_task_contract() {
  local file="$1"
  [[ -s "$file" ]] || { echo "Task contract is empty: $file" >&2; return 1; }
  [[ "$(head -n 1 "$file")" == "---" ]] || { echo "Task contract needs YAML front matter: $file" >&2; return 1; }

  local markers
  markers="$(awk '/^---[[:space:]]*$/{count++} END{print count+0}' "$file")"
  [[ "$markers" -ge 2 ]] || { echo "Task contract is missing closing front matter: $file" >&2; return 1; }

  local key
  local required="TASK_ID TITLE OBJECTIVE RISK CURRENT_STATE ALLOWED_SCOPE DO_NOT_TOUCH DEPENDENCIES RELEVANT_CONTEXT ACCEPTANCE_CRITERIA TEST_REQUIREMENT BUDGET STOP_CONDITIONS EXPECTED_OUTPUT"
  for key in $required; do
    frontmatter_has_key "$file" "$key" || { echo "Missing task field: $key" >&2; return 1; }
  done

  local task_id state risk
  task_id="$(frontmatter_value "$file" TASK_ID)"
  state="$(frontmatter_value "$file" CURRENT_STATE)"
  risk="$(frontmatter_value "$file" RISK)"

  [[ "$task_id" =~ ^M[0-9]{2}-[0-9]{3}$ ]] || { echo "Invalid TASK_ID: $task_id" >&2; return 1; }

  case "$state" in
    TODO|FAILED) ;;
    *) echo "Task state is not executable: $state" >&2; return 1 ;;
  esac

  case "$risk" in
    A|B) ;;
    C) echo "Risk C requires an explicit Decision Gate." >&2; return 2 ;;
    *) echo "Invalid task risk: $risk" >&2; return 1 ;;
  esac

  local value
  for key in max_steps max_tool_calls max_retries max_runtime_minutes; do
    value="$(budget_value "$file" "$key")"
    [[ "$value" =~ ^[0-9]+$ ]] || { echo "Invalid or missing budget: $key" >&2; return 1; }
  done

  if [[ "$(budget_value "$file" max_steps)" -le 0 ||
        "$(budget_value "$file" max_tool_calls)" -le 0 ||
        "$(budget_value "$file" max_runtime_minutes)" -le 0 ]]; then
    echo "Budget limits must be greater than zero." >&2
    return 1
  fi
}

check_task_dependencies() {
  local file="$1"
  local dep dep_file dep_state
  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue
    if [[ "$dep" =~ ^M[0-9]{2}-[0-9]{3}$ ]]; then
      dep_file="$(find_task_file "$dep")" || return 1
      dep_state="$(frontmatter_value "$dep_file" CURRENT_STATE)"
      case "$dep_state" in
        VERIFIED|DONE) ;;
        *) echo "Dependency $dep is not complete: $dep_state" >&2; return 1 ;;
      esac
    elif [[ "$dep" == *.md || "$dep" == */* ]]; then
      [[ -e "$dep" ]] || { echo "Dependency path does not exist: $dep" >&2; return 1; }
    fi
  done < <(awk -v key="DEPENDENCIES" '
    BEGIN { started=0; in_key=0 }
    /^---[[:space:]]*$/ {
      if (started == 0) { started=1; next }
      exit
    }
    started == 1 {
      if ($0 ~ ("^" key ":[[:space:]]*$")) { in_key=1; next }
      if (in_key && $0 ~ /^[A-Z][A-Z0-9_]*:/) { exit }
      if (in_key && $0 ~ /^[[:space:]]*-[[:space:]]+/) {
        sub(/^[[:space:]]*-[[:space:]]+/, "", $0)
        print $0
      }
    }
  ' "$file")
}

precheck_task() {
  local file="$1"
  echo "== PRECHECK =="
  echo "Task file: $file"

  [[ -z "$(git status --porcelain)" ]] || { echo "Working tree is not clean." >&2; return 3; }
  validate_task_contract "$file" || return $?
  check_task_dependencies "$file" || return 1

  [[ -f "$ROOT/PROJECT_STATE.md" ]] || { echo "PROJECT_STATE.md is missing." >&2; return 1; }
  if grep -Eq '^[[:space:]]*-[[:space:]]*(DECISION_REQUIRED|CONFLICT|SECURITY)(:|[[:space:]]|$)' "$ROOT/PROJECT_STATE.md"; then
    echo "PROJECT_STATE contains an active blocking gate." >&2
    return 2
  fi

  echo "Repository: PASS"
  echo "Task contract: PASS"
  echo "Dependencies: PASS"
  echo "Decision/conflict/security gate: PASS"
  echo "Working tree: PASS"
  echo "Budget schema: PASS"
  echo "Precheck: PASS"
}

stop_issue() {
  local number="$1"
  local reason="$2"
  local details="$3"
  gh issue comment "$number" --body "## V3.2 STOP\n\n**Reason:** $reason\n\n$details" >/dev/null || true
  gh issue edit "$number" --add-label "$FAILED_LABEL" --remove-label "$TASK_LABEL" --remove-label "$RUNNING_LABEL" >/dev/null || true
}

claim_task() {
  local task_id="$1"
  local run_id="$2"
  local claim_dir="${CODEX_CLAIM_ROOT:-${TMPDIR:-/tmp}/launcheros-claims}"
  local claim_file="$claim_dir/$task_id.claim"
  mkdir -p "$claim_dir"
  if [[ -e "$claim_file" ]]; then
    local existing_pid existing_run
    existing_pid="$(sed -n 's/^PID=//p' "$claim_file" | head -n 1)"
    existing_run="$(sed -n 's/^RUN_ID=//p' "$claim_file" | head -n 1)"
    if [[ -n "$existing_pid" ]] && kill -0 "$existing_pid" 2>/dev/null; then
      echo "Task $task_id is already claimed by PID=$existing_pid RUN_ID=$existing_run" >&2
      return 1
    fi
    rm -f "$claim_file"
  fi
  ( set -o noclobber; printf 'RUN_ID=%s\nTASK_ID=%s\nPID=%s\nCLAIMED_AT=%s\n' "$run_id" "$task_id" "$BASHPID" "$(date -Is)" > "$claim_file" ) 2>/dev/null || { echo "Could not acquire task claim: $task_id" >&2; return 1; }
  printf '%s\n' "$claim_file"
}

release_task_claim() {
  local claim_file="$1"
  [[ -f "$claim_file" ]] || return 0
  rm -f "$claim_file"
}

ensure_label "$VERIFIED_LABEL" "Execution verified; awaiting product acceptance"
ensure_label "$ACCEPTED_LABEL" "Explicit Project Owner product acceptance"

human_acceptance() {
  local number="$1"
  local task_id="$2"
  local run_id="$3"
  local report_file="EXECUTIONS/$task_id/$run_id.md"
  local acceptance_file="EVIDENCE/$task_id/$run_id/product-acceptance.md"

  [[ -f "$report_file" && -f "$acceptance_file" ]] || {
    echo "HUMAN_ACCEPTANCE: BLOCKED_MISSING_RECORD"
    return 1
  }

  if ! grep -q '^STATUS: PENDING' "$acceptance_file"; then
    echo "HUMAN_ACCEPTANCE: NOT_PENDING"
    return 1
  fi

  cat >>"$acceptance_file" <<EOF

## Project Owner Acceptance

STATUS: PASS
ACCEPTED_AT: $(date -u +%Y-%m-%dT%H:%M:%SZ)
AUTHORITY: Project Owner
TRIGGER: explicit codex-accepted label
EOF

  cat >>"$report_file" <<EOF

## Human Acceptance

STATUS: PASS
ACCEPTED_AT: $(date -u +%Y-%m-%dT%H:%M:%SZ)
AUTHORITY: Project Owner
TRIGGER: explicit codex-accepted label
EOF

  if ! transition_state "VERIFIED" "DONE" >>"$acceptance_file" 2>&1; then
    echo "HUMAN_ACCEPTANCE: INVALID_STATE_TRANSITION"
    return 1
  fi

  git add "$acceptance_file" "$report_file"
  git commit -m "chore: record human acceptance $run_id" >/dev/null
  git push >/dev/null

  echo "HUMAN_ACCEPTANCE: PASS task=$task_id run=$run_id"
  return 0
}

director_review() {
  local task_id="$1"
  local run_id="$2"
  local report_file="EXECUTIONS/$task_id/$run_id.md"
  local evidence_dir="EVIDENCE/$task_id/$run_id"
  local required=(
    "$report_file"
    "$evidence_dir/implementation.md"
    "$evidence_dir/technical-test.md"
    "$evidence_dir/product-acceptance.md"
    "$evidence_dir/git-checkpoint.md"
    "$evidence_dir/state-transition.md"
  )
  local missing=()
  local item
  for item in "${required[@]}"; do
    [[ -f "$item" ]] || missing+=("$item")
  done

  if (( ${#missing[@]} > 0 )); then
    echo "DIRECTOR_REVIEW: BLOCKED_MISSING_EVIDENCE"
    printf 'DIRECTOR_REVIEW_MISSING: %s\n' "${missing[@]}"
    return 1
  fi

  local acceptance_status
  acceptance_status="$(awk -F': ' '/^ACCEPTANCE:/ {print $2; exit}' "$report_file" || true)"
  if [[ "$acceptance_status" == *"PENDING"* ]] || grep -q '^STATUS: PENDING' "$evidence_dir/product-acceptance.md" 2>/dev/null; then
    echo "DIRECTOR_REVIEW: READY_FOR_HUMAN_ACCEPTANCE"
    return 0
  fi

  echo "DIRECTOR_REVIEW: READY"
  return 0
}

transition_state() {
  local current="$1"
  local next="$2"
  case "$current:$next" in
    TODO:IMPLEMENTING|IMPLEMENTING:TESTING|TESTING:VERIFYING|VERIFYING:VERIFIED|IMPLEMENTING:FAILED|TESTING:FAILED|VERIFYING:FAILED|TESTING:BUDGET_EXHAUSTED|IMPLEMENTING:BLOCKED|TESTING:BLOCKED|VERIFYING:DECISION_REQUIRED)
      echo "STATE_TRANSITION: $current -> $next"
      return 0
      ;;
    "$next:$next")
      echo "STATE_TRANSITION: $current -> $next"
      return 0
      ;;
    *)
      echo "STATE_TRANSITION_INVALID: $current -> $next"
      return 1
      ;;
  esac
}

verify_git_checkpoint() {
  local expected_branch="$1"
  local expected_remote="$2"
  local status
  status="$(git status --porcelain)"
  [[ -z "$status" ]] || { echo "GIT_VERIFICATION: DIRTY_WORKTREE"; return 1; }
  [[ "$(git branch --show-current)" == "$expected_branch" ]] || { echo "GIT_VERIFICATION: WRONG_BRANCH"; return 1; }
  git fetch origin "$expected_branch" >/dev/null 2>&1 || { echo "GIT_VERIFICATION: FETCH_FAILED"; return 1; }
  local local_sha remote_sha
  local_sha="$(git rev-parse HEAD)"
  remote_sha="$(git rev-parse "origin/$expected_branch")"
  [[ "$local_sha" == "$remote_sha" ]] || { echo "GIT_VERIFICATION: REMOTE_MISMATCH local=$local_sha remote=$remote_sha"; return 1; }
  if [[ -n "$expected_remote" && "$local_sha" != "$expected_remote" ]]; then
    echo "GIT_VERIFICATION: EXPECTED_SHA_MISMATCH expected=$expected_remote actual=$local_sha"
    return 1
  fi
  echo "GIT_VERIFICATION: PASS branch=$expected_branch sha=$local_sha worktree=clean remote=matches"
}

write_evidence_record() {
  local task_id="$1"
  local run_id="$2"
  local evidence_type="$3"
  local status="$4"
  local source="$5"
  local details="$6"
  local dir="$ROOT/EVIDENCE/$task_id/$run_id"
  local file="$dir/$evidence_type.md"
  mkdir -p "$dir"
  {
    echo "# Evidence: $evidence_type"
    echo
    echo "RUN_ID: $run_id"
    echo "TASK_ID: $task_id"
    echo "TYPE: $evidence_type"
    echo "STATUS: $status"
    echo "SOURCE: $source"
    echo "RECORDED_AT: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "## DETAILS"
    printf '%s\n' "$details"
  } >"$file"
  printf '%s\n' "$file"
}

write_execution_report() {
  local report_dir="$ROOT/EXECUTIONS/$1"
  local report_file="$report_dir/$2.md"
  local final_state="$3"
  local changed_files="$4"
  local tests="$5"
  local acceptance="$6"
  local failures="$7"
  local blockers="$8"
  local decision_required="$9"
  local next_position="${10}"
  local runner_notes="${11}"
  local director_review="${12}"
  local finished_at
  finished_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  mkdir -p "$report_dir"
  {
    echo "# Execution Report"
    echo
    echo "RUN_ID: $2"
    echo "TASK_ID: $1"
    echo "STARTED_AT: $started_at"
    echo "FINISHED_AT: $finished_at"
    echo "RUNNER: Codex via tools/codex-bridge.sh"
    echo "INITIAL_STATE: TODO"
    echo "FINAL_STATE: $final_state"
    echo
    echo "## CHANGED_FILES"
    printf "%s\n" "$changed_files"
    echo
    echo "## CREATED_FILES"
    echo "See CHANGED_FILES and Git diff."
    echo
    echo "## DELETED_FILES"
    echo "See Git diff."
    echo
    echo "## TESTS"
    printf "%s\n" "$tests"
    echo
    echo "## ACCEPTANCE"
    printf "%s\n" "$acceptance"
    echo
    echo "## FAILURES"
    printf "%s\n" "$failures"
    echo
    echo "## GIT"
    echo "- BASE_BRANCH: $BASE_BRANCH"
    echo "- TASK_BRANCH: ${task_branch:-unknown}"
    echo "- CHECKPOINT_VERIFIED: $([[ "$final_state" == "VERIFIED" || "$final_state" == "TARGET_COMPLETE" ]] && echo true || echo false)"
    echo
    echo "## RESOURCE_USAGE"
    grep "^RESOURCE_USAGE:" "$output_file" 2>/dev/null || true
    echo
    echo "## BLOCKERS"
    printf "%s\n" "$blockers"
    echo
    echo "## DECISION_REQUIRED"
    printf "%s\n" "$decision_required"
    echo
    echo "## NEXT_POSITION"
    printf "%s\n" "$next_position"
    echo
    echo "## RUNNER_NOTES"
    printf "%s\n" "$runner_notes"
    echo
    echo "## DIRECTOR_REVIEW"
    printf "%s\n" "$director_review"
  } >"$report_file"
  printf "%s\n" "$report_file"
}
run_task() {
  local number="$1"
  local title="$2"
  local body="$3"
  local task_id task_file task_contract
  local prompt_file output_file

  task_id="$(printf '%s\n%s\n' "$body" "$title" | sed -n 's/^[[:space:]]*TASK_ID:[[:space:]]*//p' | head -n 1 | tr -d '\r')"
  if [[ -z "$task_id" ]]; then
    task_id="$(printf '%s\n' "$title" | grep -oE 'M[0-9]{2}-[0-9]{3}' | head -n 1 || true)"
  fi

  [[ -n "$task_id" ]] || { stop_issue "$number" "PRECHECK_FAILED" "Issue #$number does not identify a TASK_ID."; return 0; }

  if ! task_file="$(find_task_file "$task_id")"; then
    stop_issue "$number" "PRECHECK_FAILED" "TASK_ID=$task_id has no unique task contract under $TASKS_ROOT/."
    return 0
  fi

  local precheck_code=0
  precheck_task "$task_file" || precheck_code=$?

  case "$precheck_code" in
    0) ;;
    2) stop_issue "$number" "DECISION_REQUIRED" "Task $task_id requires a Decision Gate or an active blocking gate."; return 0 ;;
    3) stop_issue "$number" "BLOCKED" "Working tree must be clean before execution."; return 0 ;;
    *) stop_issue "$number" "PRECHECK_FAILED" "Task contract or dependency validation failed."; return 0 ;;
  esac

  task_contract="$(cat "$task_file")"

  local task_max_steps task_max_tool_calls task_max_retries task_max_runtime_minutes
  task_max_steps="$(budget_value "$task_file" max_steps)"
  task_max_tool_calls="$(budget_value "$task_file" max_tool_calls)"
  task_max_retries="$(budget_value "$task_file" max_retries)"
  task_max_runtime_minutes="$(budget_value "$task_file" max_runtime_minutes)"

  local run_id
  run_id="run-$(date -u +%Y%m%dT%H%M%SZ)-$-$RANDOM"
  local claim_file
  if ! claim_file="$(claim_task "$task_id" "$run_id")"; then
    stop_issue "$number" "CONFLICT" "Task $task_id is already claimed by another active bridge worker."
    return 0
  fi
  trap "release_task_claim \"$claim_file\"" RETURN
  local started_at
  started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "RUN_ID: $run_id"
  echo "TASK_ID: $task_id"
  echo "CLAIM: $claim_file"

  prompt_file="$(mktemp)"
  output_file="$(mktemp)"
  trap 'rm -f "$prompt_file" "$output_file"' RETURN

  cat >"$prompt_file" <<EOF
You are the implementation agent for LauncherOS operating under Bridge V3.2.

The GitHub Issue is only the execution trigger.
The Task Contract below is authoritative.

Before acting, read PROJECT_STATE.md, the relevant EXECUTION_MAP.md section, AI_PROTOCOL.md, and only the source files needed for the task.

Repository: $REPO
GitHub issue: #$number
Issue title: $title
RUN_ID: $run_id
TASK_ID: $task_id

TASK CONTRACT:
$task_contract

AUTOMATION RULES:
1. Work directly in the current repository.
2. Inspect the existing implementation before editing.
3. Follow AGENTS.md and the LauncherOS reference-fidelity rules.
4. Make the smallest coherent implementation that solves the Task Contract.
5. Run relevant tests/build checks before finishing.
6. Do not treat the GitHub Issue body as authority when it conflicts with the Task Contract.
7. Do not merely describe code changes: actually implement them.
8. Do not modify secrets, authentication files, release/signing configuration, or unrelated projects.
9. Do not expand scope beyond ALLOWED_SCOPE or modify DO_NOT_TOUCH paths.
10. Do not make strategic architecture/scope changes; stop with DECISION_REQUIRED if they are necessary.
11. If blocked, explain the exact blocker instead of inventing a result.
12. Update PROJECT_STATE.md only when the Task Contract permits it.
13. If verified, commit the changes on the task branch with a clear message. Do not push secrets.
14. Your final response must contain:
   - STATUS: DONE or BLOCKED
   - SUMMARY: concise changes
   - VERIFICATION: commands/tests and results
   - NOTES: remaining issues, if any
EOF

  gh issue edit "$number" --add-label "$RUNNING_LABEL" --remove-label "$TASK_LABEL" >/dev/null

  git fetch origin "$BASE_BRANCH" >/dev/null 2>&1
  local task_branch="codex/issue-$number"
  git switch -C "$task_branch" "origin/$BASE_BRANCH" >/dev/null 2>&1

  local -a codex_args
  codex_args=(exec --sandbox "$SANDBOX")
  if [[ -n "$MODEL" ]]; then
    codex_args+=(--model "$MODEL")
  fi
  codex_args+=("$(cat "$prompt_file")")

  local effective_timeout_seconds="$MAX_TASK_SECONDS"
  local task_timeout_seconds=$((task_max_runtime_minutes * 60))
  if [[ "$task_timeout_seconds" -lt "$effective_timeout_seconds" ]]; then
    effective_timeout_seconds="$task_timeout_seconds"
  fi

  local max_attempts="$task_max_retries"
  if [[ "$MAX_RETRIES" -lt "$max_attempts" ]]; then
    max_attempts="$MAX_RETRIES"
  fi
  if [[ "$task_max_steps" -lt 1 ]]; then
    stop_issue "$number" "BUDGET_EXHAUSTED" "Task max_steps must be at least 1."
    return 0
  fi
  if [[ "$max_attempts" -gt "$((task_max_steps - 1))" ]]; then
    max_attempts="$((task_max_steps - 1))"
  fi

  echo "[$(date -Is)] Starting Codex for issue #$number"
  echo "Budget: steps=$task_max_steps tool_calls=$task_max_tool_calls retries=$max_attempts runtime=${effective_timeout_seconds}s"

  local exit_code=124
  local attempt=0
  while (( attempt <= max_attempts )); do
    attempt=$((attempt + 1))
    : >"$output_file"

    local -a budget_codex_args
    budget_codex_args=(exec --json --sandbox "$SANDBOX")
    if [[ -n "$MODEL" ]]; then budget_codex_args+=(--model "$MODEL"); fi
    budget_codex_args+=("$(cat "$prompt_file")")

    exit_code=0
    timeout --signal=TERM --kill-after=30s "$effective_timeout_seconds" \
      codex "${budget_codex_args[@]}" >"$output_file" 2>&1 || exit_code=$?

    if [[ "$exit_code" -eq 0 ]]; then
      break
    fi
    if (( attempt <= max_attempts )); then
      echo "[$(date -Is)] Deterministic runner retry $attempt/$max_attempts"
      sleep 1
    fi
  done

  local observed_tool_calls
  observed_tool_calls="$(jq -s '[.[] | select(.type == "item.completed") | .item? | select(.type == "command_execution" or .type == "function_call")] | length' "$output_file" 2>/dev/null || printf '0')"

  local budget_status="PASS"
  if [[ "$observed_tool_calls" -gt "$task_max_tool_calls" ]]; then
    budget_status="BUDGET_EXHAUSTED"
  fi
  if [[ "$exit_code" -eq 124 ]]; then
    budget_status="BUDGET_EXHAUSTED"
  fi
  echo "RESOURCE_USAGE: attempts=$attempt max_attempts=$max_attempts observed_tool_calls=$observed_tool_calls max_tool_calls=$task_max_tool_calls runtime_limit_seconds=$effective_timeout_seconds budget_status=$budget_status" >>"$output_file"
  # Independent scope verification happens before any commit/push.
  # Compare the task branch against the fetched base, not Codex's self-report.
  local scope_status="PASS"
  local changed_files
  changed_files="$({ git diff --name-only "origin/$BASE_BRANCH"...HEAD; git diff --name-only; git diff --cached --name-only; } | sort -u)"

  local allowed_scope do_not_touch
  allowed_scope="$(awk '
    BEGIN { started=0; in_key=0 }
    /^---[[:space:]]*$/ { if (started == 0) { started=1; next } exit }
    started == 1 {
      if ($0 ~ /^ALLOWED_SCOPE:[[:space:]]*$/) { in_key=1; next }
      if (in_key && $0 ~ /^[A-Z][A-Z0-9_]*:/) { exit }
      if (in_key && $0 ~ /^[[:space:]]*-[[:space:]]+/) { sub(/^[[:space:]]*-[[:space:]]+/, "", $0); print }
    }
  ' "$task_file")"
  do_not_touch="$(awk '
    BEGIN { started=0; in_key=0 }
    /^---[[:space:]]*$/ { if (started == 0) { started=1; next } exit }
    started == 1 {
      if ($0 ~ /^DO_NOT_TOUCH:[[:space:]]*$/) { in_key=1; next }
      if (in_key && $0 ~ /^[A-Z][A-Z0-9_]*:/) { exit }
      if (in_key && $0 ~ /^[[:space:]]*-[[:space:]]+/) { sub(/^[[:space:]]*-[[:space:]]+/, "", $0); print }
    }
  ' "$task_file")"

  path_allowed() {
    local path="$1"
    local prefix
    while IFS= read -r prefix; do
      [[ -z "$prefix" ]] && continue
      prefix="${prefix#./}"
      if [[ "$path" == "$prefix" || "$path" == "$prefix/"* ]]; then return 0; fi
    done <<< "$allowed_scope"
    return 1
  }

  path_forbidden() {
    local path="$1"
    local prefix
    while IFS= read -r prefix; do
      [[ -z "$prefix" ]] && continue
      prefix="${prefix#./}"
      if [[ "$path" == "$prefix" || "$path" == "$prefix/"* ]]; then return 0; fi
    done <<< "$do_not_touch"
    return 1
  }

  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    if ! path_allowed "$path" || path_forbidden "$path"; then
      scope_status="OUT_OF_SCOPE"
      echo "SCOPE_VIOLATION: $path" >>"$output_file"
    fi
  done <<< "$changed_files"

  echo "SCOPE_VERIFICATION: status=$scope_status" >>"$output_file"
  if [[ "$scope_status" != "PASS" ]]; then
    stop_issue "$number" "OUT_OF_SCOPE" "Changed files violated ALLOWED_SCOPE or DO_NOT_TOUCH. Review the execution output for the exact paths."
    local scope_result
    scope_result="$(tail -c 12000 "$output_file")"
    gh issue comment "$number" --body-file <(printf '%s\\n\\n%s' "## Scope verification failed" "$scope_result") >/dev/null || true
    cd "$ROOT"
    git switch "$BASE_BRANCH" >/dev/null 2>&1 || true
    return 0
  fi

  if [[ "$exit_code" -eq 0 && "$budget_status" == "PASS" ]]; then
    git status --short >"${output_file}.gitstatus" || true
    if ! git diff --quiet; then git add -A; fi
    if ! git diff --cached --quiet; then git commit -m "codex: complete issue #$number" >>"$output_file" 2>&1 || exit_code=$?; fi
    local changed_after_commit
    changed_after_commit="$(git diff --name-only "origin/$BASE_BRANCH"...HEAD || true)"
    local implementation_evidence technical_evidence acceptance_evidence
    implementation_evidence="$(write_evidence_record "$task_id" "$run_id" "implementation" "PASS" "git diff" "Codex execution completed and scope verification passed. Changed files are recorded in the execution report.")"
    technical_evidence="$(write_evidence_record "$task_id" "$run_id" "technical-test" "PASS" "bridge execution" "Codex exited successfully and the bounded bridge checks passed. This record does not claim device/runtime acceptance.")"
    acceptance_evidence="$(write_evidence_record "$task_id" "$run_id" "product-acceptance" "PENDING" "Project Owner" "No automatic product acceptance is asserted. Acceptance remains a separate human/product verification gate.")"
    echo "EVIDENCE: implementation=$implementation_evidence technical=$technical_evidence acceptance=$acceptance_evidence" >>"$output_file"

    local report_file
    report_file="$(write_execution_report "$task_id" "$run_id" "VERIFIED" "$changed_after_commit" "Codex exit=$exit_code; scope verification PASS; budget status=$budget_status." "Implementation evidence and technical-test evidence recorded. Product acceptance evidence is PENDING." "None" "None" "None" "DIRECTOR_REVIEW" "$(tail -c 4000 "$output_file")" "Pending Director/human review.")"
    git add "$report_file"
    git commit -m "chore: record execution $run_id" >>"$output_file" 2>&1 || exit_code=$?
    local checkpoint_sha=""
    if [[ "$exit_code" -eq 0 ]]; then
      git push -u origin "$task_branch" >>"$output_file" 2>&1 || exit_code=$?
      if [[ "$exit_code" -eq 0 ]]; then checkpoint_sha="$(git rev-parse HEAD)"; fi
    fi
    if [[ "$exit_code" -eq 0 ]]; then
      if ! verify_git_checkpoint "$task_branch" "$checkpoint_sha" >>"$output_file" 2>&1; then
        exit_code=126
      else
        local git_evidence
        git_evidence="$(write_evidence_record "$task_id" "$run_id" "git-checkpoint" "PASS" "git verification" "Branch=$task_branch; remote HEAD matches local HEAD=$checkpoint_sha; working tree clean.")"
        git add "$git_evidence"
        git commit -m "chore: record git checkpoint evidence $run_id" >>"$output_file" 2>&1 || exit_code=$?
        if [[ "$exit_code" -eq 0 ]]; then git push >>"$output_file" 2>&1 || exit_code=$?; fi
        if [[ "$exit_code" -eq 0 ]]; then verify_git_checkpoint "$task_branch" "" >>"$output_file" 2>&1 || exit_code=126; fi
      fi
    fi
    if [[ "$exit_code" -eq 0 ]]; then gh pr create --base "$BASE_BRANCH" --head "$task_branch" --title "Codex: #$number $title" --body "Automated V3.2 execution. Report: EXECUTIONS/$task_id/$run_id.md" >>"$output_file" 2>&1 || true; fi
    if [[ "$exit_code" -ne 0 ]]; then
      gh issue comment "$number" --body-file <(printf '%s\\n\\nExit code: %s\\n\\n%s' "## Git verification failed" "$exit_code" "$(tail -c 12000 "$output_file")") >/dev/null
      gh issue edit "$number" --add-label "$FAILED_LABEL" --remove-label "$RUNNING_LABEL" >/dev/null
      cd "$ROOT"
      git switch "$BASE_BRANCH" >/dev/null 2>&1 || true
      return 0
    fi
    if ! transition_state "VERIFYING" "VERIFIED" >>"$output_file" 2>&1; then
      gh issue comment "$number" --body "## State transition failed\n\nThe execution passed technical checks but the state transition to VERIFIED was rejected. Human review is required." >/dev/null || true
      gh issue edit "$number" --add-label "$FAILED_LABEL" --remove-label "$RUNNING_LABEL" >/dev/null || true
      cd "$ROOT"
      git switch "$BASE_BRANCH" >/dev/null 2>&1 || true
      return 0
    fi
    local state_evidence
    state_evidence="$(write_evidence_record "$task_id" "$run_id" "state-transition" "PASS" "state transition engine" "VERIFIED reached only after scope, budget, evidence, and Git checkpoint checks passed. Product acceptance remains pending.")"
    git add "$state_evidence"
    git commit -m "chore: record state transition $run_id" >>"$output_file" 2>&1 || exit_code=$?
    if [[ "$exit_code" -eq 0 ]]; then git push >>"$output_file" 2>&1 || exit_code=$?; fi
    if [[ "$exit_code" -ne 0 ]]; then
      gh issue comment "$number" --body "## State transition evidence failed\n\nThe execution could not persist the VERIFIED transition evidence." >/dev/null || true
      gh issue edit "$number" --add-label "$FAILED_LABEL" --remove-label "$RUNNING_LABEL" >/dev/null || true
      cd "$ROOT"
      git switch "$BASE_BRANCH" >/dev/null 2>&1 || true
      return 0
    fi
    if ! director_review "$task_id" "$run_id" >>"$output_file" 2>&1; then
      gh issue comment "$number" --body-file <(printf "%s\n\n%s" "## Director review blocked" "$(tail -c 8000 "$output_file")") >/dev/null || true
      gh issue edit "$number" --add-label "$FAILED_LABEL" --remove-label "$RUNNING_LABEL" >/dev/null || true
      cd "$ROOT"
      git switch "$BASE_BRANCH" >/dev/null 2>&1 || true
      return 0
    fi
    local result
    result="$(tail -c 12000 "$output_file")"
    gh issue comment "$number" --body-file <(printf "%s\n\n%s" "## Codex result — VERIFIED / DIRECTOR REVIEW" "$result") >/dev/null
    gh issue edit "$number" --add-label "$VERIFIED_LABEL" --remove-label "$RUNNING_LABEL" >/dev/null
    # Director review is an evidence gate; it does not grant product acceptance.
    echo "[$(date -Is)] Issue #$number passed Director Review and is ready for human/product acceptance."
  else
    if [[ "$exit_code" -eq 0 && "$budget_status" == "BUDGET_EXHAUSTED" ]]; then
      exit_code=125
    fi
    local result
    result="$(tail -c 12000 "$output_file")"
    gh issue comment "$number" --body-file <(printf '%s\n\nExit code: %s\n\n%s' \
      "## Codex failed or timed out" "$exit_code" "$result") >/dev/null
    gh issue edit "$number" --add-label "$FAILED_LABEL" --remove-label "$RUNNING_LABEL" >/dev/null
    echo "[$(date -Is)] Issue #$number failed (exit $exit_code)."
  fi

  # Return to the repository root even if Codex changed directories.
  cd "$ROOT"
  git switch "$BASE_BRANCH" >/dev/null 2>&1 || true
}

while true; do
  accepted_tasks="$(gh issue list --repo "$REPO" --state open --label "$VERIFIED_LABEL" --label "$ACCEPTED_LABEL" --limit 10 --json number,title,body --jq '.[] | @base64')"
  if [[ -n "$accepted_tasks" ]]; then
    while IFS= read -r encoded; do
      [[ -z "$encoded" ]] && continue
      issue_json="$(printf '%s' "$encoded" | base64 --decode)"
      number="$(jq -r '.number' <<<"$issue_json")"
      body="$(jq -r '.body // ""' <<<"$issue_json")"
      task_id="$(printf '%s\n' "$body" | sed -n 's/^TASK_ID:[[:space:]]*//p' | head -n1)"
      run_id="$(printf '%s\n' "$body" | sed -n 's/^RUN_ID:[[:space:]]*//p' | head -n1)"
      [[ -n "$task_id" && -n "$run_id" ]] || continue
      if human_acceptance "$number" "$task_id" "$run_id"; then
        gh issue comment "$number" --body "## Human Acceptance — DONE

Project Owner acceptance was explicitly recorded through the `codex-accepted` gate. Product acceptance evidence is now PASS." >/dev/null
        gh issue edit "$number" --add-label "$DONE_LABEL" --remove-label "$VERIFIED_LABEL" --remove-label "$ACCEPTED_LABEL" >/dev/null
        gh issue close "$number" >/dev/null
      fi
    done <<<"$accepted_tasks"
  fi

  tasks="$(gh issue list --repo "$REPO" --state open --label "$TASK_LABEL" \
    --limit 10 --json number,title,body --jq '.[] | @base64')"

  if [[ -n "$tasks" ]]; then
    while IFS= read -r encoded; do
      [[ -z "$encoded" ]] && continue
      issue_json="$(printf '%s' "$encoded" | base64 --decode)"
      number="$(jq -r '.number' <<<"$issue_json")"
      title="$(jq -r '.title' <<<"$issue_json")"
      body="$(jq -r '.body // ""' <<<"$issue_json")"
      run_task "$number" "$title" "$body" || true
    done <<<"$tasks"
  fi

  sleep "$POLL_SECONDS"
done
