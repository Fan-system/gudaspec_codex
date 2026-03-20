# Implementation Phase

Use this phase when the proposal is approved, planning is complete, and the repository is ready for code changes.

## Goal

Execute the approved proposal task by task inside Codex until the requested outcome is implemented.

Implementation is not for deciding the product. It is for carrying an already-constrained plan through code, tests, and validation.

## Core Philosophy

- Use multiple agents by default during implementation. Only fall back to a single-agent path when the task is trivial enough that coordination would add no value.
- Split work by repository boundary and concrete task ownership, not by abstract roles like architect, frontend expert, or reviewer.
- Keep every change aligned with the approved spec.
- Subagent output is reference material, not final code.
- Production-quality code is the default target; do not ship prototype structure.
- Verification is part of implementation, not a separate afterthought.
- Prefer simple, explicit code over speculative abstraction.
- Stop and surface conflicts when the repository reality diverges from the spec.

## Required Inputs

Before coding, confirm:

- the active proposal ID or spec path
- the task sequence produced during Plan
- the repository areas each task touches
- the available verification commands for the repo

If Plan is still unresolved, do not start coding.

## Guardrails

- Do not begin from a vague or unvalidated proposal.
- Do not widen scope beyond the approved outcome.
- Do not introduce new architecture unless the spec requires it or the repository reality makes it unavoidable.
- Do not preserve broken patterns just because they already exist; keep compatibility, but improve local quality where the spec requires change.
- Do not skip verification silently.
- Do not divide subagents by vague roles. Divide them by disjoint ownership boundaries.
- Subagents must not modify the main working tree directly.
- Subagents must return `unified diff patch` output for their assigned task, plus touched files, task-local checks or observations, and assumptions.
- Do not directly apply or copy subagent patches into the repository without review and rewrite.
- After the main agent completes a task, require an additional review pass by a separate subagent before running downstream test-and-closeout work.

## Workflow

### 1. Confirm the Implementation Target

Run `openspec view` and identify the proposal being implemented.

Confirm:

- the exact change you are implementing
- whether there are overlapping active changes
- whether the codebase has drifted since Plan

If the repository has drifted in a way that invalidates the spec, pause and reconcile before editing more code.

### 2. Map Spec Tasks to Concrete Tasks

Translate the plan into concrete implementation tasks.

Good task shapes:

- add or modify one backend endpoint and its validation
- update one domain behavior plus the associated tests
- add one UI state transition plus the supporting API wiring
- perform one schema or config change with a focused verification step

Avoid tasks that are too broad to verify or too narrow to produce signal.

By default, assign these tasks to multiple subagents by ownership boundary. Only keep a task local to the main agent when it is trivial enough that dispatching a subagent would add no value. Examples:

- one subagent for a backend endpoint and its validation
- one subagent for a frontend surface and its state handling
- one subagent for persistence, schema, or configuration changes

Do not assign multiple subagents to the same write boundary unless coordination is explicitly required.

### 3. Implement Directly in Repository Style

Use subagents to prepare task-local candidate changes, but keep final repository edits under main-agent control.

Before editing, require each implementation subagent to return:

- a `unified diff patch`
- touched file paths
- a concise explanation of the change
- task-local checks or observations
- assumptions or unresolved risks

Read the local patterns before editing the actual repository.

Align with:

- naming conventions
- file layout
- error handling style
- test patterns
- typing and validation conventions

When integrating subagent work into the real repository, the main agent must:

- review the patch critically
- remove redundant code and unnecessary complexity
- ensure naming is clear and consistent
- keep structure simple and aligned with the project
- remove unnecessary comments while preserving comments that explain real constraints or non-obvious behavior
- rewrite or absorb the patch rather than applying it blindly

Write the final code directly for production use.

### 4. Review Each Completed Task Before Test Closeout

After the main agent implements a task in the repository, send the resulting code to an additional review subagent before doing the task's downstream test-and-closeout work.

That review subagent should check:

- functional correctness and regression risk
- redundant logic or unnecessary abstraction
- naming clarity
- structural simplicity
- code style alignment with the repository
- unnecessary comments
- missing validation or tests

If the review subagent finds issues:

- fix them first
- re-run the review if the fixes are substantial
- do not move on to downstream test-and-closeout work while the task still has unresolved review findings

Only after review findings are clear or resolved should the main agent proceed to targeted tests, linters, build steps, and other task-level closeout checks.

### 5. Verify Every Reviewed Task

After review is clear for the completed task:

- run targeted tests, linters, build steps, or local checks
- inspect the diff for unintended side effects
- compare the observed behavior against the spec

Treat this step as the task's formal downstream verification. Prefer narrow verification first, then broader checks when the task stabilizes.

Examples:

- run the unit tests covering the changed service
- run the component test or page-level UI check for the touched surface
- run a focused type-check or lint target
- run migration validation if schema changes are involved

### 6. Keep the Spec and Code Aligned

During implementation, watch for cases where:

- the spec omitted an edge case revealed by the code
- the repository has a hidden constraint not captured in Plan
- the planned sequence needs a minor reorder for technical reasons

When this happens:

- update the spec if the change is clarifying rather than changing scope
- ask the user if the new information changes a meaningful decision

Do not silently drift away from the plan.

### 7. Review for Side Effects

Before closing each task, check:

- did the change alter unrelated behavior?
- did new dependencies, config, or env requirements appear?
- did naming or structure become inconsistent with nearby code?
- did tests cover the changed behavior rather than only the happy path?

Treat side-effect review as mandatory for cross-module or user-visible changes.

### 8. Iterate Until the Proposal Work Is Complete

Repeat the cycle:

1. choose the next task
2. dispatch subagents on disjoint task boundaries
3. collect `unified diff patch` outputs
4. review and rewrite before touching the main repository
5. complete the task in the main repository
6. send the completed task for independent review
7. fix review findings until clear
8. verify
9. inspect for side effects
10. reconcile with spec

This loop continues until the approved scope is implemented.

When a task is completed, the corresponding task item must be checked to indicate progress.
## Verification Strategy

Choose the strongest verification the repo makes practical:

- focused unit or integration tests first
- repo-level type checks or lint where relevant
- end-to-end or smoke checks for user-visible flows
- manual reasoning only when automation is unavailable, and state that explicitly

If a command cannot run because of missing dependencies, environment mismatch, sandbox restrictions, or external service requirements, report the exact blocker.

## Expected Output

At the end of each implementation pass, report in a shape like:

```text
Implemented
- completed tasks

Reviewed
- review findings or explicit LGTM

Verified
- commands run
- behaviors confirmed

Not Verified
- checks that could not run
- exact blockers

Residual Risks
- none / itemized residual risks
```

## Exit Criteria

Implementation is complete only when:

- the approved spec scope is fully reflected in code
- meaningful verification has been run for the changed areas
- unintended side effects have been reviewed
- any unverifiable areas are explicitly called out
- remaining risks are small, understood, and communicated
