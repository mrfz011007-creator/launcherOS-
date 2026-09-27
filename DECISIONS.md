# LauncherOS Decisions

## D-006 — Decision hierarchy

Decision: Explicit Project Owner decisions and DECISIONS.md outrank operational memory, architecture, protocol, state, task files, source code, and AI assumptions.

## D-007 — Bounded task execution

Decision: V3.2 uses explicit task contracts, budgets, stop conditions, execution reports, and evidence before considering a task verified.

## D-008 — Codespace as temporary worker

Decision: Codespace is not the project source of truth and should be used only for bounded shell/build/test/debug execution.

## D-009 — Build is not product acceptance

Decision: Technical build/test success and product verification are separate evidence states.

## D-010 — No premature orchestration

Decision: Do not add persistent schedulers, databases, webhooks, additional agents, or dashboards until a measurable bottleneck requires them and the Project Owner approves the scope.
