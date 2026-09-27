# Human Acceptance Gate — V3.2

Product acceptance is a Project Owner decision. It must never be inferred from Codex success, build success, technical verification, or Director Review.

## State transition

```
VERIFIED
  ↓
codex-accepted  (explicit Project Owner action)
  ↓
DONE
```

## Required evidence

The execution must already have:

- execution report;
- implementation evidence;
- technical-test evidence;
- product-acceptance evidence with `STATUS: PENDING`;
- Git checkpoint evidence;
- state-transition evidence.

## Acceptance trigger

The Project Owner explicitly applies the GitHub issue labels:

- `codex-verified`
- `codex-accepted`

The bridge then records:

- `STATUS: PASS`;
- acceptance timestamp;
- authority: Project Owner;
- transition `VERIFIED → DONE`.

The bridge does not accept a task merely because `codex-verified` exists.

## Safety

If the acceptance record is missing or is not pending, the bridge does not complete the task.

Acceptance must not change task scope, architecture, release/signing, credentials, or other Level-2 decisions. Those remain subject to the Decision Gate.

## Product acceptance remains human

The bridge records the explicit decision; it does not make the product decision.
