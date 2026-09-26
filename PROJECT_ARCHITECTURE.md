# LauncherOS Project Architecture

## Product

Android launcher for TECNO SPARK Go 2024 / BG6, Android 13, 4 GB physical RAM.

## Runtime architecture

- Android application built with Kotlin/Compose.
- Launcher entry point requests HOME role where supported.
- App discovery uses Android PackageManager.
- Wallpaper is the primary visual layer.
- Shared translucent surfaces provide glass treatment.
- App icons are not individually boxed.
- Future widget support should use Android AppWidgetHost.
- Performance favors bounded bitmaps, caching, lazy collections, and limited graphics layers.

## Execution architecture

Human -> ChatGPT Director -> Codex Runner -> Codespaces workspace -> GitHub source of truth -> evidence -> Director.

The execution bridge is intentionally simple: GitHub Issues act as the task transport. A Codespace-local bridge polls codex-task issues and invokes Codex non-interactively.

Do not add agents, queues, databases, webhook infrastructure, or other orchestration components unless a measurable requirement emerges.
