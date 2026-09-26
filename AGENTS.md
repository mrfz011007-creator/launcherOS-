# LauncherOS — Codex Agent Instructions

## Project goal

LauncherOS is an Android launcher designed for the TECNO SPARK Go 2024 / BG6
(UMS9230/T606, Android 13, 4 GB physical RAM).

The visual source of truth is the LauncherOS reference specification in the
project history. Do not invent a generic launcher design.

## Reference-fidelity rules

- Wallpaper is the primary visual layer.
- UI surfaces sit above the wallpaper and remain translucent.
- Glass is for shared containers/surfaces, not individual app icons.
- Do not put a glass card behind every icon.
- Prefer one shared dock surface over many icon surfaces.
- Folders use one shared glass container.
- App Library uses a vertical alphabetical list with search and an alphabet index.
- Search is an interaction layer: search -> keyboard -> filtering -> results.
- Home prioritizes wallpaper and widgets over a full app grid.
- Motion should use restrained fade/scale/expand/collapse transitions.
- Avoid decorative blob backgrounds and opaque full-screen panels.
- Avoid expensive blur/shadow layers on individual elements.

## Performance rules

- Target low-memory Android hardware.
- Cache application icons.
- Bound bitmap sizes.
- Prefer LazyColumn/LazyGrid where appropriate.
- Avoid per-icon blur, shadow, or graphics layers.
- Do not introduce a dependency solely for a visual effect unless necessary.

## Automation rules

When invoked by the Jalur B bridge:

1. Inspect current code before changing it.
2. Implement the requested task rather than only explaining it.
3. Keep changes scoped to the issue.
4. Run the relevant Gradle build/tests.
5. Report exact verification results.
6. Do not edit credentials, secrets, or unrelated repositories.
7. If a product/design decision is genuinely ambiguous, use the reference
   rules above and choose the smallest reversible implementation.

## Build

GitHub Actions currently uses Gradle 8.9. Java/Kotlin 17 is required.

Do not declare success solely because compilation succeeds when the task is
visual or behavioral. State what was actually verified.
