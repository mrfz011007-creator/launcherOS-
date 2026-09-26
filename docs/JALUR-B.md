# Jalur B — ChatGPT → GitHub → Codex → LauncherOS

Jalur B removes the copy/paste handoff between ChatGPT and Codex.

## Architecture

```
ChatGPT
   │
   │ creates a GitHub Issue labelled codex-task
   ▼
GitHub Issues
   │
   │ polled by the Codespace bridge
   ▼
codex-bridge.sh
   │
   │ codex exec
   ▼
Codex
   │
   ├── inspect
   ├── edit
   ├── build/test
   └── report
   │
   ▼
GitHub Issue comment + commit changes
```

Codex officially provides a non-interactive `codex exec` mode, which is
intended for automated workflows. The repository also provides an
`exec-server` for programmatic process control, but the first implementation
of Jalur B uses `codex exec` because it is simpler and keeps the bridge inside
the existing Codespace.

## One-time Codespace setup

From the LauncherOS Codespace:

```bash
cd /workspaces/launcherOS-
chmod +x tools/codex-bridge.sh
gh auth status
codex --version
```

If GitHub CLI is not authenticated:

```bash
gh auth login
```

Codex must already be signed in, as established during the initial setup.

Start the bridge:

```bash
./tools/codex-bridge.sh
```

Keep that terminal/session alive while you want automatic processing.

## Sending a task

Create a GitHub Issue with label `codex-task`.

The issue body should contain the complete task. For example:

```text
Implement Phase 1 reference-accurate home screen.
Inspect the current implementation first.
Do not create glass cards around individual icons.
Build the APK and fix compilation errors.
Report the exact verification result.
```

The bridge claims the issue, runs Codex, posts the final Codex output back to
the issue, and closes successful tasks.

## Sandbox

Default:

```bash
CODEX_SANDBOX=workspace-write ./tools/codex-bridge.sh
```

If a build genuinely requires networked commands and the normal sandbox blocks
them, use a dedicated trusted Codespace:

```bash
CODEX_SANDBOX=danger-full-access ./tools/codex-bridge.sh
```

Do not expose a Codex server publicly. This bridge does not require a public
HTTP endpoint.

## Current limitation

The bridge must be running in the Codespace. If the Codespace is stopped or
suspended, tasks wait in GitHub Issues until the bridge is running again.

A later version can replace polling with a webhook or remote exec-server, but
the polling bridge is the smallest reliable Jalur B foundation.
