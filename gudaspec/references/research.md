# Research Phase

Use this phase when the user provides a requirement but the repository does not yet have a clear, implementable proposal.

## Goal

Transform a user request into:

- a constraint set that narrows the solution space
- a set of verifiable success criteria
- a proposal draft or proposal update in OpenSpec

Research is not a brainstorming dump. Its job is to reduce uncertainty without prematurely locking implementation details that belong in Plan.

## Core Philosophy

- Produce constraints, not trivia.
- Each constraint must reduce future decision surface.
- Distinguish clearly between what the repository already enforces and what the user still needs to decide.
- Prefer repository evidence over assumptions.
- Surface ambiguity early. Do not silently resolve product or architecture choices that materially affect implementation.
- Keep the result readable by the next Codex session with minimal extra context.
- When working on an OpenSpec-structured project, strictly follow OpenSpec rules and formatting requirements for all formal spec artifacts.
- Eliminate ambiguity through structured exploration and user interaction rather than guesswork.
- Use a unified structured output format so parallel exploration results can be aggregated reliably.
- Use exploration subagents by default for actual searching and evidence gathering so the main agent does not absorb unnecessary repository noise.

## Required Inputs

At the start of the phase, gather:

- the user's stated requirement
- the current repository structure
- existing conventions relevant to the touched area
- any existing OpenSpec artifacts related to the request

If `openspec/` does not exist, run the `init` phase first or tell the user that OpenSpec bootstrap is the missing prerequisite.

## Guardrails

- Do not make final architecture choices unless the repository already constrains them.
- Do not turn Plan work into Research work.
- Do not collect broad notes with no execution value.
- Do not summarize code blindly; identify only details that constrain implementation.
- If a framework, dependency, external API, or standard may have changed, verify current primary documentation before treating it as a constraint.
- All judgments must be grounded in project code and current primary sources. Do not infer from generic background knowledge.
- If ambiguity remains, ask the user instead of guessing. It is acceptable to state uncertainty explicitly.
- Split research by codebase boundary, not by abstract role. In Research, subagents are for exploration and search only, not for implementation work.
- Keep the main agent focused on orchestration, aggregation, and user interaction. Offload repository searching and evidence gathering to exploration subagents whenever delegation is available.
- If the current runtime blocks delegation, keep research local while preserving the same boundary split and structured outputs, and minimize local reads to avoid context pollution.

## Workflow

### 1. Assess Repository State

Inspect the codebase with targeted reads.

By default, perform repository search and evidence gathering through exploration subagents rather than the main agent. The main agent should keep enough local context to:

- understand the user requirement
- determine whether the task spans multiple context boundaries
- define exploration boundaries
- aggregate returned findings
- interact with the user about remaining ambiguity

Prefer `rg` (`ripgrep`) for fast local scanning when available. If `rg` is not installed, fall back to `grep`, `find`, or other local read-only inspection commands.

When useful for repository-scale assessment, inspect the codebase structure directly, for example with `ls -R` or an equivalent targeted directory walk.

Establish:

- whether the repository is effectively single-directory or multi-directory / multi-module
- whether the task truly spans multiple context boundaries
- whether the work is isolated or cross-cutting
- which modules, directories, or services are involved
- whether similar features already exist
- whether the request conflicts with existing patterns

Document the finding in concrete terms, for example:

- `single-task change in existing frontend module`
- `cross-module change touching API, persistence, and UI`
- `new capability with no existing precedent in repo`

If the task truly spans multiple context boundaries, record the assessment explicitly:

- `single-agent serial exploration is inefficient; use parallel exploration subagents by boundary; if runtime policy blocks delegation, keep the same boundary split locally`

### 2. Identify Natural Research Boundaries

Break the repository into context boundaries only if the task truly spans multiple areas.

Examples:

- user-facing UI surface
- backend service and domain logic
- persistence and schema layer
- configuration, deployment, or infra wiring

For each boundary, determine:

- key files or directories
- local conventions
- dependencies on adjacent areas
- risks introduced by changing it

This is a thinking structure first. When the task spans multiple boundaries, these boundaries define how to dispatch parallel exploration subagents. If runtime policy blocks delegation, use the same boundary split for local serial exploration.

### 3. Extract Constraint Candidates

For each relevant boundary, collect:

- existing structures already in use
- conventions the implementation must respect
- hard technical constraints
- soft constraints and preferences
- cross-module dependencies
- notable risks or blockers
- observable behaviors that would indicate success

Only keep findings that influence design, sequencing, validation, or scope.

### 4. Use a Unified Internal Aggregation Template

All exploration outputs, especially from subagents, must use the same JSON structure so later aggregation is consistent.

This JSON is an internal aggregation format for exploration only. It is not the final proposal format and does not replace OpenSpec.

Use this template:

```json
{
  "module_name": "string",
  "existing_structures": ["patterns already present in this boundary"],
  "existing_conventions": ["local conventions already in use"],
  "hard_constraints": ["requirements that cannot be violated"],
  "soft_constraints": ["preferred patterns or styles"],
  "dependencies": ["other modules, services, or rollout dependencies"],
  "risks": ["regression or implementation risks"],
  "open_questions": ["only blocking ambiguities that require user confirmation"],
  "success_criteria_hints": ["observable signs that the change works"]
}
```

If subagents are used, communicate this exact template to every exploration subagent.

### 5. Dispatch Parallel Exploration Subagents When Needed

If the repository assessment shows that the task truly spans multiple context boundaries, dispatch parallel exploration subagents by default.

If runtime policy blocks delegation, keep the same exploration boundaries locally instead of dispatching subagents.

These subagents are for exploration only. They should inspect assigned boundaries, gather evidence, and return structured findings. They should not implement code, rewrite specs, or take ownership of later execution work.

For each defined context boundary, provide:

- the assigned exploration scope and context boundary
- the required JSON output template
- a clear success criterion: complete analysis of the assigned boundary

Monitor execution and collect the structured reports.

If the task does not truly span multiple context boundaries, use a single exploration subagent by default for the search work. The goal is still to keep repository scanning out of the main agent context whenever possible.

### 6. Separate Constraint Types and Aggregate Findings

Normalize findings into these categories:

- `Hard constraints`
  Things the implementation cannot violate.
  Examples: existing database schema shape, required framework version, mandatory auth flow, public API compatibility.

- `Soft constraints`
  Preferred patterns that should be followed unless the user chooses otherwise.
  Examples: naming style, UI composition pattern, existing test style, folder conventions.

- `Dependencies`
  Modules, services, APIs, or rollout order constraints that affect implementation sequence.

- `Risks`
  Areas likely to regress, block, or require explicit mitigation.

- `Success criteria`
  Concrete observable outcomes that can later be validated.

Aggregate the findings into a unified constraint set regardless of whether the exploration was done locally or via parallel subagents.

If subagents were used:

- validate that every returned report conforms to the required template before aggregation
- collect all JSON outputs

Then, in all cases:

- merge all findings into a unified constraint set
- identify cross-module dependencies that affect implementation order
- identify the open questions that still require user clarification
- synthesize success-criteria hints across all explored boundaries

### 7. Resolve Ambiguity at the Right Level

Identify questions that materially affect implementation choices.

Ask the user only when the answer changes one of:

- product behavior
- data model or API contract
- architecture or storage choice
- user-visible UX semantics
- rollout or compatibility expectations

Do not ask questions whose answers can be discovered from the repository or current official docs.

When asking, prefer concise decision-oriented prompts such as:

- `Should this behavior replace the existing flow or coexist behind a flag?`
- `Should the new endpoint preserve the current response shape or introduce a versioned contract?`
- `Is this page expected to support mobile-first layout from the first release?`

When asking multiple questions, prefer a structured interactive flow:

- group related questions together
- provide the minimum necessary background for each question
- suggest a default answer when a sensible default exists

Record user answers as additional constraints and update the constraint set after decisions are confirmed.

### 8. Draft the OpenSpec Proposal

Create or update the proposal after the constraint set is coherent.

Only draft or update the proposal when the remaining ambiguity list does not change the proposal's core direction. If unresolved questions would still change architecture, API shape, storage model, or another core implementation direction, stop and present those questions first.

The proposal should:

- be written in proper OpenSpec form
- restate the user request accurately
- expand the user's requirements when needed, but never abbreviate them in a way that loses precision
- encode repository-backed constraints explicitly
- avoid vague phrases such as `optimize later`, `to be determined`, or `choose during implementation`
- reference concrete local paths, modules, or interfaces where relevant
- contain no unresolved ambiguity

When the user mentions concrete project files, modules, or local paths, preserve that specificity in the proposal instead of replacing it with vague summaries.

If the request is still too ambiguous after minimal clarification, stop with explicit open questions rather than drafting a misleading proposal.

## Internal Aggregation Notes

Reuse the JSON template from Step 4 for internal working notes, subagent outputs, and aggregation.

Do not treat this JSON as an OpenSpec document. Its purpose is internal consistency during exploration and synthesis.

The final formal output of Research is:

- a user-facing synthesized summary
- an OpenSpec-compliant proposal draft or proposal update

Do not present the raw JSON as the final user-facing result unless the user explicitly asks for it.

## Expected Output

The end of Research should produce a concise synthesis for the user. Prefer this shape:

```text
Constraints
Hard Constraints
- itemized hard constraints, or `None`

Soft Constraints
- itemized soft constraints, or `None`

Dependencies
- itemized dependencies, or `None`

Risks
- none / itemized risks

Open Questions
- none / itemized open questions

Success Criteria
- itemized observable outcomes

Proposal
- proposal path or proposal ID, or `None` if blocked by unresolved core questions
```

## Exit Criteria

Research is complete only when:

- the touched repository boundaries are understood well enough to avoid blind implementation
- the meaningful constraints are explicit
- the remaining ambiguity list is short and decision-relevant
- success criteria are observable
- a proposal draft or proposal update exists, or the exact blocker preventing it is stated
