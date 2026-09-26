# LauncherOS Execution Map

## Goal

Move LauncherOS from its current implementation to a stable, reference-fidelity launcher with a verified installable APK for the target BG6 device.

## Milestones

1. M1 — Execution infrastructure
   - GitHub source of truth
   - Codex CLI in Codespaces
   - Bounded bridge
   - State/evidence files
2. M2 — Launcher stability
   - No immediate startup crash
   - Safe app/icon loading
   - Safe wallpaper loading
3. M3 — Reference Phase 1
   - Wallpaper-dominant home
   - Shared glass surfaces
   - No per-icon glass
   - Widget-oriented hierarchy
4. M4 — Verification
   - Gradle build passes
   - APK artifact exists
   - APK is structurally installable
   - Human installs and performs final acceptance
5. M5 — Later phases
   - Dock/folders
   - App Library/search
   - Motion
   - Widgets
   - Edit/customization
   - Performance optimization

## Current position

M1 is implemented in repository.
M2-M4 remain execution targets.
