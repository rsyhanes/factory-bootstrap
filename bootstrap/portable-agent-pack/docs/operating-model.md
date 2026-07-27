# Factory Operating Model

## Purpose

This repository uses **The Factory** for structured software delivery.

The goal is to keep request, design, planning, implementation, and verification
traceable through durable artifacts so humans and agents can work from the same
state.

## Where Factory Operates

### Canonical runtime workspace

The active runtime surface is:

- `/.factory/`

This is where Factory runtime artifacts live and where skills must read/write their
canonical non-code outputs.

### Local reference docs

This repository may also contain:

- `/AGENTS.md`
- `/docs/factory/operating-model.md`
- `/docs/factory/foundry-c4-authoring-standard.md`
- `/docs/factory/skills/*.md`

These files exist to help humans and generic agents understand how to operate The
Factory in this repo.

`/AGENTS.md` should be treated as the **agent-first entry point**.

They are **reference material**, not a replacement runtime plane.

## The Seven Core Skills

- **Cartographer** — reverse-engineer an existing brownfield system into as-built truth
- **Refinery** — turn a raw request into a product-intent specification
- **Foundry** — turn product intent into technical design, C4 architecture views, and architectural decisions
- **Planner** — turn design into ordered implementation work on a **cumulative** Work Order and validation-plan ledger
- **Assembler** — execute the planned work orders in the codebase
- **Validator** — verify the implementation against requirements and evidence
- **Controller** — observe process integrity across runtime artifacts and coach the human operator (advisory only)

Detailed local references live in:

- `/docs/factory/foundry-c4-authoring-standard.md`
- `/docs/factory/skills/Cartographer.md`
- `/docs/factory/skills/Refinery.md`
- `/docs/factory/skills/Foundry.md`
- `/docs/factory/skills/Planner.md`
- `/docs/factory/skills/Assembler.md`
- `/docs/factory/skills/Validator.md`
- `/docs/factory/skills/Controller.md`

## Standard Skill Flows

### Greenfield

1. Initialization
2. Refinery
3. Foundry
4. Planner
5. Assembler
6. Validator

Optional **Controller** checkpoints (not required every micro-step) may run after major phase transitions—for example after Foundry before Planner, after Planner before Assembler, or when unsure what to run next.

### Brownfield

1. Initialization
2. Cartographer
3. Refinery *(when future-state product intent is needed)*
4. Foundry
5. Planner
6. Assembler
7. Validator

Optional **Controller** checkpoints apply the same way as greenfield.

## Canonical Runtime Artifacts

### Root artifacts

- `/.factory/init.md`
- `/.factory/prd.md`
- `/.factory/state.md`

### Per-skill artifacts

- `/.factory/cartographer/system-spec.md`
- `/.factory/cartographer/behavior-catalog.md`
- `/.factory/cartographer/integration-map.md`
- `/.factory/cartographer/parity-risks.md`
- `/.factory/refinery/spec.md`
- `/.factory/foundry/design.md`
- `/.factory/foundry/system-context.md`
- `/.factory/foundry/container-view.md`
- `/.factory/foundry/component-views.md`
- `/.factory/foundry/adr/index.md`
- `/.factory/foundry/adr/ADR-*.md`
- `/.factory/planner/work-orders.md`
- `/.factory/planner/validation-plan.md`
- `/.factory/assembler/execution-log.md`
- `/.factory/assembler/change-summary.md`
- `/.factory/validator/verification-report.md`
- `/.factory/controller/report.md`

## Invocation Pattern

Skills are currently triggered by **explicitly naming them in the instruction**.

Examples:

- `Use Cartographer to reverse-engineer this codebase into an as-built spec.`
- `Use Refinery to turn /.factory/prd.md into /.factory/refinery/spec.md.`
- `Use Foundry to produce /.factory/foundry/design.md plus system-context.md and container-view.md from /.factory/refinery/spec.md.`
- `Use Planner. Read Foundry and existing planner ledgers; append new WOs/tests to work-orders.md and validation-plan.md without wiping prior entries.`
- `Use Assembler to execute WO-003 only.`
- `Use Validator to verify the implementation against the PRD and acceptance criteria.`
- `Use Controller to review factory health.`

## Working Rules

1. Treat `/.factory/` as the canonical runtime home for Factory artifacts.
2. Read upstream skill outputs before producing downstream artifacts.
3. Update `/.factory/state.md` to reflect real progress and next expected action.
4. Do not invent alternate SDLC artifact locations when canonical paths exist.
5. Do not skip required upstream skills when their outputs are needed.
6. Keep work traceable from request through verification.
7. Treat `/.factory/planner/work-orders.md` and `validation-plan.md` as cumulative ledgers: append new `WO-NNN` / `TEST-NNN` entries; retain completed bodies; never replace the file with only the latest increment.

## Authority Hierarchy

When questions arise, prefer the following order:

1. active runtime artifacts in `/.factory/`
2. `/AGENTS.md`
3. local operating references in `/docs/factory/`
4. the bootstrap contract materialized in `/.factory/init.md`
5. the canonical Factory framework repo when available

## Bootstrap Workflow Note

If this repo was initialized by copying in a temporary `bootstrap/` folder, running the
init script, and then deleting that folder, the durable artifacts that should remain are:

- `/AGENTS.md`
- `/.factory/`
- `/docs/factory/`
