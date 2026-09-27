# LauncherOS Project Architecture — V3.2

## Product

Android launcher for TECNO SPARK Go 2024 / BG6, Android 13, 4 GB physical RAM.

## Runtime architecture

- Kotlin + Jetpack Compose.
- Launcher entry point requests HOME role where supported.
- App discovery uses Android PackageManager.
- Wallpaper is the primary visual layer.
- Shared translucent surfaces provide glass treatment.
- App icons are not individually boxed.
- Future widget support should use Android AppWidgetHost.
- Performance favors bounded bitmaps, caching, lazy collections, and limited graphics layers.

## Execution architecture

Project Owner
-> ChatGPT Director
-> GitHub source of truth
-> bounded task
-> Codex Runner
-> Codespace
-> build/test
-> evidence
-> Director verification
-> Project Owner acceptance when required

GitHub remains the source of truth. Codespace is a temporary worker.

## Control plane

- AI_MEMORY.md: stable operational memory.
- AI_PROTOCOL.md: operating rules.
- PROJECT_STATE.md: current project snapshot.
- PROJECT_ARCHITECTURE.md: technical map.
- DECISIONS.md: explicit decisions.
- EXECUTION_MAP.md: milestone/dependency map.
- TASK_SCHEMA.md: task contract.
- TASKS/: executable task definitions.
- EXECUTION_SCHEMA.md: execution report contract.
- EXECUTIONS/: bounded run records.
- EVIDENCE/: durable verification references.
- DECISION_GATE.md: authority and stop rules.
- EXECUTION_ENGINE.md: execution lifecycle specification.
- tools/codex-bridge.sh: initial execution adapter.

## Infrastructure constraint

Do not add agents, queues, databases, webhook infrastructure, or dashboards unless a measurable requirement emerges and the Project Owner approves the scope.
