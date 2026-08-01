# Factory Bootstrap Initialization Contract

## Purpose

This document defines the canonical bootstrap initialization contract for **The Factory**.

It answers:

- what `init factory` means in a target repository
- what the bootstrap script must create in a target repository
- which bootstrap artifacts are required at minimum
- how initialization should behave when files already exist
- how initialization should seed initial runtime state

This file is the source of truth for target-repository bootstrap behavior.

The broader framework-level contract for The Factory is defined in this repository at `framework/spec/factory-spec.md`.

In the Factory framework repo, checked-in `.factory/` artifacts may appear as richer reference scaffolds. This document defines the minimum target-repository **runtime bootstrap bundle**, plus the currently supported optional local reference outputs used to make initialized repos more self-describing for humans and generic agents.

---

## Bootstrap Goal

Initialization creates the minimum durable **`.factory/` runtime workspace** required for Factory-driven product work in a target repository.

After a successful initialization, the target repository should contain a canonical non-code runtime workspace that supports:

- product request capture
- legacy system reverse-engineering
- lifecycle state tracking
- product specification output
- technical design output
- work-order planning
- execution logging
- verification reporting
- process-integrity reporting (Controller)

Initialization must create bootstrap structure only. It must not invent project-specific content beyond safe placeholders and templates.

---

## Supported Invocation Styles

Factory bootstrap initialization may be triggered in either of these ways:

### 1. Agent command in a target repository
`init factory`

Meaning:

- ensure the minimum `.factory/` runtime structure exists
- create missing canonical files
- seed placeholder content where needed
- avoid overwriting meaningful existing content by default
- initialize lifecycle state for Factory use

### 2. Bootstrap script
Canonical framework-repository implementation:

`bootstrap/scripts/init-factory.ps1`

The script must implement the same target-repository bootstrap contract described in this document.

In the current script-driven workflow, users may:

1. copy the `bootstrap/` folder into the target repository
2. run `bootstrap/scripts/init-factory.ps1`
3. verify the emitted `/.factory/` runtime workspace and any local reference docs
4. delete the copied `bootstrap/` folder if it is no longer needed

---

## Canonical Bootstrap Structure

Initialization must ensure the following bootstrap paths exist in the target repository.

### Required bootstrap root artifacts

- `/.factory/prd.md`
- `/.factory/state.md`
- `/.factory/init.md`

### Required bootstrap subdirectories and artifacts

#### Cartographer
- `/.factory/cartographer/system-spec.md`
- `/.factory/cartographer/behavior-catalog.md`
- `/.factory/cartographer/integration-map.md`
- `/.factory/cartographer/parity-risks.md`

#### Refinery
- `/.factory/refinery/spec.md`

#### Foundry
- `/.factory/foundry/design.md`
- `/.factory/foundry/system-context.md`
- `/.factory/foundry/container-view.md`
- `/.factory/foundry/component-views.md`
- `/.factory/foundry/adr/index.md`

#### Planner
- `/.factory/planner/work-orders.md`
- `/.factory/planner/validation-plan.md`

#### Assembler
- `/.factory/assembler/execution-log.md`
- `/.factory/assembler/change-summary.md`

#### Validator
- `/.factory/validator/verification-report.md`

#### Controller
- `/.factory/controller/report.md`

### Portable local reference artifacts

When the bootstrap distribution includes `bootstrap/portable-agent-pack/`, initialization should also emit the following local reference docs into the target repository:

- `/AGENTS.md`
- `/docs/factory/operating-model.md`
- `/docs/factory/foundry-c4-authoring-standard.md`
- `/docs/factory/skills/Cartographer.md`
- `/docs/factory/skills/Refinery.md`
- `/docs/factory/skills/Foundry.md`
- `/docs/factory/skills/Planner.md`
- `/docs/factory/skills/Assembler.md`
- `/docs/factory/skills/Validator.md`
- `/docs/factory/skills/Controller.md`

These documents are intended to make the initialized repository easier to operate for humans and generic agents that do not already know the Factory skill contracts.

They are **not** part of the active `/.factory/` runtime plane and must not redefine the canonical runtime artifact locations.

`/AGENTS.md` should act as the root agent operating manual and configuration layer for AI agents, while `/.factory/` remains the runtime system of record.

---

## Bootstrap Artifact Responsibilities

### `/.factory/prd.md`
Canonical starting product request artifact for the target repository.

### `/.factory/state.md`
Current target-project Factory lifecycle state used to reduce drift.

### `/.factory/init.md`
Canonical bootstrap contract materialized inside the target repository.

### `/.factory/cartographer/system-spec.md`
Canonical as-built narrative index and structural skeleton (pass mode, scope, evidence inventory, surface inventory, capability tree, process index, data/state model, operational notes, open questions, **quality self-check**). Detail lives in ID ledgers.

### `/.factory/cartographer/behavior-catalog.md`
Cumulative ledger of observed legacy behaviors (`OBS-NNN`) and first-class business rules (`BR-NNN`, condition→outcome), including decisions, exceptions, and controls on behaviors.

### `/.factory/cartographer/integration-map.md`
Cumulative ledger of external integrations and system boundaries (`INT-NNN`), including failure, retry, and reconciliation notes when known.

### `/.factory/cartographer/parity-risks.md`
Cumulative ledger of brownfield parity risks, quirks, and evidence gaps (`PAR-NNN`).

### `/.factory/refinery/spec.md`
Canonical product-intent specification output.

### `/.factory/foundry/design.md`
Canonical Foundry summary and architectural narrative.

### `/.factory/foundry/system-context.md`
Canonical C4 Level 1 system context view.

### `/.factory/foundry/container-view.md`
Canonical C4 Level 2 container view.

### `/.factory/foundry/component-views.md`
Canonical C4 Level 3 component views for significant containers and subsystems.

### `/.factory/foundry/adr/index.md`
Canonical architectural decision register and ADR index.

### `/.factory/planner/work-orders.md`
Canonical ordered implementation work plan.

### `/.factory/planner/validation-plan.md`
Canonical validation and acceptance test proposal plan.

### `/.factory/assembler/execution-log.md`
Canonical record of work-order execution.

### `/.factory/assembler/change-summary.md`
Canonical implementation summary and repository transition record.

### `/.factory/validator/verification-report.md`
Canonical criteria-traceable verification record.

### `/.factory/controller/report.md`
Canonical process-integrity assessment, cumulative findings register (`FIND-NNN`), and operator brief. Bootstrap seeds a lightweight placeholder only; Controller fills it when invoked.

---

## Bootstrap Rules

### 1. Non-destructive by default
Bootstrap initialization must be safe by default.

It must:

- create missing files and folders
- preserve existing files when they already exist
- avoid replacing non-empty project artifacts unless explicitly forced

It must not:

- overwrite a populated PRD
- reset state for an active project
- destroy prior Factory outputs without explicit intent

### 2. Idempotent behavior
Bootstrap initialization should be repeatable.

Running it multiple times should:

- leave valid existing files intact
- create only what is missing
- avoid duplicating content
- keep the repository in a stable initialized state

### 3. Template-only seeding
When creating files, initialization should add minimal bootstrap placeholder content only.

It should not:

- fabricate project requirements
- infer architecture
- generate work orders
- create implementation decisions
- claim validation success

### 4. Runtime-only scope
Initialization creates the runtime operating workspace in a target repository.

It does not perform the actual work of:

- Cartographer
- Refinery
- Foundry
- Planner
- Assembler
- Validator
- Controller

It also does not introduce runtime dependencies on out-of-band storage.

Bootstrap may also emit **local reference material outside `/.factory/`** when included in the copied bootstrap distribution, provided that:

- the canonical runtime plane remains `/.factory/`
- the additional docs are non-destructive and idempotent
- the additional docs do not invent alternate active artifact locations
- the additional docs are treated as reference/supporting material rather than runtime state
- `/AGENTS.md` is treated as an agent operating layer, not as active runtime state

---

## Required Initial Runtime State

When `/.factory/state.md` is created for the first time in a target repository, it should represent bootstrap status similar to:

- Current Phase: Initialization
- Active Skill: None
- Current Status: Factory workspace initialized
- Current Work Order: None
- Next Expected Action: populate `/.factory/prd.md` or invoke Refinery

If `state.md` already exists, initialization should not replace meaningful project state unless explicitly forced.

---

## Required Bootstrap Placeholder Behavior

When created for the first time, bootstrap artifacts should contain enough structure to be understandable and usable.

Examples:

- `prd.md` should clearly indicate that the target repository's actual product request still needs to be filled in
- downstream skill artifacts should indicate status such as `Not started`
- runtime artifact placeholders should identify their intended role in the Factory flow
- emitted local reference docs should clearly distinguish the active runtime plane from supporting skill guidance
- emitted `AGENTS.md` should direct AI agents to `/.factory/` as the runtime system of record

---

## Relationship to Skills

All Factory skills should assume that initialization has already happened in the target repository.

If the required `/.factory/` runtime workspace is missing in a target repository, the correct recovery action is:

- run the bootstrap script, or
- issue the instruction: `init factory`

---

## Success Criteria

Bootstrap initialization is complete when:

1. the `.factory/` directory exists in the target repository
2. the required runtime root artifacts exist
3. the required per-skill runtime artifacts exist
4. initialization has preserved meaningful existing files unless explicitly forced
5. `state.md` reflects an initialized runtime state or preserves a valid existing one
6. the repository is ready for Refinery or Cartographer as the next correct skill
7. if the bootstrap distribution included the portable agent pack, `/AGENTS.md` and the local `/docs/factory/` references exist or valid existing ones were preserved

---

## Recommended Bootstrap Script Location

The bootstrap script should live outside `.factory/`:

- `bootstrap/scripts/init-factory.ps1`

Rationale:

- `.factory/` is the target project runtime artifact workspace
- the script is framework/distribution tooling
- the initializer must still be available even when `.factory/` is absent

---

## Future Extension Points

Bootstrap initialization may later support:

- force overwrite mode
- repair mode for missing artifacts only
- language or framework templates
- migration of older `.factory/` layouts
- alternate artifact profiles

Those are optional extensions and are not required for minimum initialization.

---

## One-Line Definition

**Factory bootstrap initialization creates the minimum canonical `.factory/` workspace safely, repeatably, and without overwriting meaningful existing project artifacts by default.**