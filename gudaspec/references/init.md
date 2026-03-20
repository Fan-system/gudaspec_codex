# Init Phase

Use this phase when the repository does not yet have `openspec/`, when the user explicitly asks to bootstrap the workflow, or when the local OpenSpec setup appears incomplete or broken.

## Goal

Prepare the current repository for OpenSpec-based work inside Codex so that later `research`, `plan`, and `implementation` phases can run against a valid spec workspace.

## Core Philosophy

- Initialization is for preparing the workflow substrate, not for doing requirement work.
- Prefer the smallest safe setup that enables the next phase.
- Detect and report environment problems early instead of letting them leak into later phases.
- Respect existing repository state. Bootstrap should not overwrite user work casually.
- Leave the repository in a state where a fresh Codex session can immediately continue with `research`.

## Required Inputs

At the start of Init, confirm:

- the current repository root
- whether `openspec/` already exists
- whether `openspec` CLI is already available
- whether the current environment allows installation if needed

If the user asks to reinitialize an existing setup, treat that as a higher-risk operation and surface the current state before changing it.

## Guardrails

- Do not overwrite an existing `openspec/` tree unless the user explicitly asked for re-init or repair.
- Do not install globally without approval when approval is required.
- Do not assume which `openspec init` variant is supported; verify with the installed CLI behavior.
- Surface exact failures and the next corrective step.
- Keep the final summary concrete enough that the next session knows whether it can proceed.

## Workflow

### 1. Detect Repository and Platform Context

Confirm the current working repository and only detect the operating system when it changes the command strategy.

Record anything relevant to follow-up steps, such as:

- Linux / macOS shell path assumptions
- Windows PowerShell command differences
- whether the repo is already partially initialized

Do not turn this into a generic environment report. Capture only what affects OpenSpec bootstrap.

### 2. Check CLI Availability

Verify `openspec` availability with a direct command such as:

```bash
openspec --version
```

If not available, determine whether installation is feasible in the current environment.

When installation is needed:

- ask for approval before global installation when required
- prefer the canonical package and current version source
- report the exact command you used

If installation fails, report:

- the failing command
- the specific error surface
- the most likely remediation path

### 3. Check Existing OpenSpec State

After CLI availability is confirmed, inspect whether:

- `openspec/` already exists
- spec files appear intact
- `openspec view` works if the directory exists

Possible outcomes:

- `openspec/` missing and CLI available
- `openspec/` present and healthy
- `openspec/` present but incomplete or invalid

If the repo is already healthy, do not reinitialize. Report that Init is already satisfied and point to the next phase.

### 4. Initialize the Repository

Once the CLI is available, initialize the repository.

Preferred behavior:

- use the most direct OpenSpec bootstrap command supported by the installed CLI
- if `openspec init --tools codex` is supported, prefer it
- otherwise use the nearest supported initialization flow and state the exact command chosen

After initialization, verify that the expected directory structure exists and that the repository is recognizable by OpenSpec tooling.

### 5. Verify Post-Init Health

After bootstrap, check that:

- `openspec/` exists
- the generated structure is coherent
- `openspec view` runs successfully
- the repository is ready for a proposal-driven workflow

If health checks fail after initialization, do not pretend success. Report the partial state clearly.

### 6. Connect Init to the Next Phase

Before exiting, state what the next valid action is.

Typical outcomes:

- `Init complete; proceed to research`
- `OpenSpec installed, but repo init failed; fix this before research`
- `Repo already initialized; skip to plan or implementation if a proposal already exists`

This handoff matters because Init should reduce startup ambiguity for the next session.

## Failure Handling

When something goes wrong, classify it clearly:

- `CLI missing`
- `installation blocked by permissions`
- `network or package resolution failure`
- `partial or corrupted openspec state`
- `unsupported CLI flag or command variant`

For each failure, give the smallest practical next step instead of a generic warning.

Examples:

- `Install failed because npm could not reach the registry; retry with network access or configured proxy`
- `openspec/ already exists but openspec view fails; inspect existing spec files before reinitializing`
- `The installed CLI does not support --tools codex; rerun init with the supported base command`

## Expected Output

The end of Init should produce a short status summary in a shape like:

```text
Init Status
- repository path
- openspec CLI status
- openspec workspace status

Actions Taken
- itemized actions taken, or `None`

Next Step
- research / plan / implementation / manual fix
```

## Exit Criteria

Init is complete only when one of these is true:

- the repository already had a healthy OpenSpec setup and that state was verified
- OpenSpec CLI is available, the repo is initialized, and `openspec view` works
- initialization is blocked, and the blocker plus next corrective step are explicitly stated
