---
name: gudaspec
description: OpenSpec-driven RPI workflow for Codex. Use when the user wants a staged Research-Plan-Implementation process, wants to convert requirements into constraint sets, refine an OpenSpec proposal into a zero-decision plan, or implement an approved proposal with a main-agent-plus-subagents workflow where subagents return unified diff patches, the main agent rewrites and lands the code, and each completed task is reviewed before downstream verification.
---

# GudaSpec

Use this skill to run a pure-Codex version of the GudaSpec workflow. Keep the process phase-based, minimize drift, and make each phase produce artifacts that the next phase can execute mechanically.

## Core Rules

- Treat the workflow as `Research -> Plan -> Implementation`.
- Keep changes scoped to the requested outcome; do not widen the task.
- Base decisions on repository evidence and current documentation, not memory.
- When a dependency, framework, or API is likely to have changed, browse primary sources before coding.
- Prefer concise specs and code. Avoid documentation churn.
- Ask the user directly when ambiguity would materially change architecture, data shape, API behavior, or rollout risk.
- During `research`, use exploration subagents by default for actual search and evidence gathering so the main agent context stays focused on orchestration, aggregation, and user interaction. If runtime policy blocks delegation, keep local exploration as narrow as possible.
- During `implementation`, use multiple agents by default. Only fall back to a single-agent path when the task is trivial enough that coordination would add no value. Split by codebase boundary or task ownership, not by abstract role labels.
- Subagents must not modify the main working tree directly. Their final deliverable is a reviewed `unified diff patch` plus touched files, task-local checks or observations, and assumptions.
- Never apply a subagent patch directly. The main agent must review, remove redundancy, align naming and structure with the project style, and then implement the final version in the repository.
- After the main agent completes a task, send the resulting code to an independent subagent for review before running downstream test-and-closeout work. Only continue when that review is clear or its findings have been addressed.

## Phase Selection

Choose the phase that matches the user request.

- For project bootstrap or missing `openspec/`: read [references/init.md](references/init.md).
- For requirement analysis and proposal drafting: read [references/research.md](references/research.md).
- For proposal hardening and task planning: read [references/plan.md](references/plan.md).
- For code changes against an approved proposal: read [references/implementation.md](references/implementation.md).

If the user does not name a phase, infer the earliest missing phase and say which one you are running.

## Operating Pattern

1. Inspect the repo and confirm whether `openspec/` already exists.
2. Load only the phase reference you need.
3. Produce the phase artifact before moving forward.
4. Validate the artifact or code change before concluding.

## Output Expectations By Phase

- `init`: a ready-to-use OpenSpec workspace plus a short status report.
- `research`: a constraint set, open questions, and a proposal draft path or ID.
- `plan`: a zero-decision execution plan with explicit invariants and validation.
- `implementation`: working code, review results, downstream verification results, and any residual risks.
