# Plan Phase

Use this phase when a proposal already exists but still contains unresolved decisions, implicit assumptions, or vague implementation guidance.

## Goal

Turn the proposal into a zero-decision or near-zero-decision execution plan.

By the end of this phase, implementation should not need to invent product behavior, architecture, data contracts, sequencing rules, or validation logic on the fly.

## Core Philosophy

- Planning removes decision points from implementation.
- A good plan narrows execution into a mechanical sequence.
- Reject ambiguity that would otherwise be deferred to coding.
- Prefer explicit technical selections over comparative discussion.
- Capture invariants and falsification angles, not just happy-path examples.
- When constraints are still missing, escalate to the user instead of guessing.
- Use subagents for large audits, cross-module spec analysis, and invariant extraction when that reduces main-agent context pressure. The main agent remains responsible for synthesis, final decisions, and spec edits.
- Planning must produce formal artifacts that implementation can execute against, but it should stay at the design, task, and validation level rather than descending into code-level patch design.
- When listing tasks, each task should have a distinct outcome and be self-contained; one task should not implicitly embed other tasks.
## Required Inputs

Before planning, gather:

- the active OpenSpec proposal or proposal ID
- any related spec files already present
- the relevant repository modules touched by the proposal
- known user decisions captured during Research
- any dispatch or boundary hints that should influence later multi-agent implementation

If `openspec/` is missing, do not continue. Run `init` first.

## Guardrails

- Do not proceed to implementation while material ambiguity remains.
- Do not treat “we can decide during coding” as an acceptable plan.
- Do not leave technology choices, algorithm selection, API shape, storage model, or rollout semantics unspecified if they affect implementation.
- Prefer exact parameters over labels like `reasonable`, `fast`, `secure`, or `standard`.
- If the proposal introduces backend logic, state transitions, parsing, auth, billing, synchronization, or persistence behavior, derive invariant-style validation properties.
- Keep the main agent focused on synthesis, final decision closure, and spec updates. Offload high-noise audit or extraction work to subagents whenever that improves context control.
- Do not turn Plan into implementation design at the level of concrete file edits, line-by-line code changes, or patch content. Plan should define what must be built, in what order, under which constraints, and how success will be validated.

## Workflow

### 1. Inspect Active Changes

Run `openspec view` and identify which proposal is being refined.

Confirm:

- the proposal ID or path
- whether the proposal is still active
- whether related changes already exist in the repo or spec set

If multiple active proposals overlap, surface that conflict before planning further.

### 2. Audit Remaining Decision Points

Before doing a full audit, decide whether the proposal is large, spans multiple repository boundaries, or contains dense technical detail.

If so, use subagents by default for the audit work. Assign them bounded review scopes such as:

- API and contract surface
- persistence and migration implications
- auth, permissions, or state transitions
- frontend behavior and UX semantics

These subagents should analyze and report findings only. They should not rewrite the spec directly.

Then read the proposal critically and list:

- ambiguous product behavior
- hidden architectural assumptions
- unspecified interfaces or contracts
- unclear sequencing dependencies
- vague validation language
- implementation choices accidentally deferred to later

Look for anti-patterns such as:

- multiple possible technologies with no selection rule
- “to be decided during implementation”
- backend behavior described only by examples
- rollout or migration steps omitted despite existing data or API consumers

The result of this step is an explicit ambiguity inventory.

### 3. Resolve Ambiguity With Targeted Questions

Ask the user only the questions that close real execution gaps.

Typical decision classes:

- product behavior and UX semantics
- storage or state model
- API contract shape and compatibility
- migration or rollout behavior
- error handling policy
- performance or consistency tradeoffs

Ask in a decision-ready way. Good examples:

- `Should the new flow replace the existing endpoint behavior or ship behind a feature flag?`
- `Must the response remain backward compatible with current clients, or can we version the contract?`
- `Should failed retries be surfaced immediately to the user or queued for background recovery?`

If a question can be answered from repo evidence or official docs, answer it yourself instead of asking the user.

### 4. Rewrite the Proposal Into Explicit Constraints

After decisions are clear, update the spec so it contains:

- explicit technical choices
- concrete behavior rules
- clear sequencing and dependency order
- acceptance conditions that can be verified
- rollout or migration requirements when relevant

These updates should be formal design-level constraints inside the OpenSpec artifacts. They should guide implementation without prescribing low-level code edits.

Replace vague statements with implementable ones.

Bad:

- `Use secure authentication`
- `Optimize performance`
- `Handle failures gracefully`

Good:

- `Use existing session cookie auth middleware in <path>; do not introduce token-based auth`
- `Cache upstream weather responses for 60 seconds keyed by city`
- `Return HTTP 429 after 5 failed attempts within 10 minutes; lockout lasts 30 minutes`

### 5. Extract Properties and Invariants

For logic-heavy work, derive properties that the later implementation or tests can falsify.

If the proposal is broad or technically dense, use subagents to extract candidate properties and edge cases, then synthesize and normalize the final invariant set in the main agent.

These subagents should return candidate analyses only. They should not modify spec files directly. The main agent must deduplicate, normalize, and write the final invariant set into the formal OpenSpec artifacts.

Useful categories:

- idempotency
- round-trip integrity
- invariant preservation
- monotonicity
- bounds and rate limits
- ordering guarantees
- access-control invariants
- schema and contract stability

Write them in a concrete form. Examples:

- `Applying the same sync event twice does not duplicate records`
- `Serializing then parsing a stored settings object preserves semantically equivalent values`
- `A user without org membership can never read org-scoped resources`
- `Pagination never returns duplicate IDs across adjacent pages under stable ordering`

Where useful, include:

- the invariant
- the edge conditions
- how it could fail
- what later tests should try to falsify

### 6. Validate After Every Significant Edit

After each substantial spec update, run:

```bash
openspec validate <proposal_id> --strict
```

Do not batch many risky edits and validate only once at the end.

If validation fails:

- fix the spec immediately
- report the failure mode if it suggests a deeper issue in the proposal structure

### 7. Produce an Executable Task Flow

The final plan should break work into an order that implementation can follow with minimal judgment.

A strong task flow:

- has clear prerequisites
- respects dependency order
- isolates risky changes
- makes verification points explicit
- allows partial progress to be validated incrementally
- makes it obvious how later implementation tasks can be dispatched by ownership boundary
- identifies which tasks can run in parallel and which must remain sequential

The final plan must be written into formal OpenSpec artifacts. Do not leave task breakdown, dispatch guidance, or design constraints only in chat output.

If the existing OpenSpec structure or project rules already require a dedicated design artifact, create or update that design-level document within the OpenSpec-managed change set. Otherwise, record the same design information directly in the relevant OpenSpec proposal or spec files.

Keep the task flow at the level of:

- design decisions
- task boundaries
- dependency order
- dispatch guidance
- validation requirements

Do not descend into:

- concrete patch content
- line-by-line implementation instructions
- low-level refactor choreography that belongs to implementation

Do not optimize for impressive architecture prose. Optimize for execution reliability.

## Suggested Review Checklist

Before exiting Plan, check:

- Are all meaningful product and technical decisions explicit?
- Could a fresh Codex session implement this without inventing missing rules?
- Are migrations, compatibility constraints, and rollout behavior covered?
- Are acceptance conditions observable?
- Are property-style invariants present where the proposal needs them?
- Does `openspec validate <proposal_id> --strict` pass?

## Expected Output

The end of Plan should produce a concise user-facing summary in a shape like:

```text
Plan Status
- proposal ID / path
- validation status
- formal artifact locations updated during planning, or `None`

Resolved Decisions
- itemized resolved decisions, or `None`

Remaining Blockers
- itemized blockers, or `None`

Execution Order
1. first executable task
2. second executable task
3. next executable task

Dispatch Notes
- itemized task-to-boundary mapping, parallelizable tasks, or `None`

Properties / Invariants
- itemized properties or invariants, or `None`
```

## Exit Criteria

Plan is complete only when:

- all material ambiguities are resolved or explicitly blocked on user input
- the proposal no longer defers key decisions to implementation
- the execution order is clear
- the task breakdown, dispatch guidance, and design constraints are recorded in formal OpenSpec artifacts
- relevant invariants or properties are documented
- `openspec validate <proposal_id> --strict` passes
