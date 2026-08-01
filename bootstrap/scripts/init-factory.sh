#!/usr/bin/env bash
# Factory bootstrap initialization (Linux/macOS bash peer of init-factory.ps1)
# Usage:
#   bash bootstrap/scripts/init-factory.sh
#   bash bootstrap/scripts/init-factory.sh --force
#   bash bootstrap/scripts/init-factory.sh -f

set -euo pipefail

FORCE=0
for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=1 ;;
    -h|--help)
      cat <<'HELP'
Factory bootstrap initialization

Usage:
  init-factory.sh [--force|-f]

Creates the minimum .factory/ runtime workspace (and optional portable agent docs).
Non-destructive by default; use --force to overwrite meaningful existing files.
HELP
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Use --help for usage." >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$BOOTSTRAP_ROOT/.." && pwd)"
FACTORY_ROOT="$REPO_ROOT/.factory"
PORTABLE_PACK_ROOT="$BOOTSTRAP_ROOT/portable-agent-pack"
PORTABLE_AGENTS_SRC="$PORTABLE_PACK_ROOT/AGENTS.md"
PORTABLE_DOCS_SRC="$PORTABLE_PACK_ROOT/docs"
PORTABLE_SKILLS_SRC="$PORTABLE_DOCS_SRC/factory/skills"
DOCS_ROOT="$REPO_ROOT/docs"
FACTORY_DOCS_ROOT="$DOCS_ROOT/factory"
FACTORY_SKILL_DOCS_ROOT="$FACTORY_DOCS_ROOT/skills"
AGENTS_FILE_PATH="$REPO_ROOT/AGENTS.md"

ensure_dir() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    mkdir -p "$path"
    echo "Created directory: $path"
  else
    echo "Directory exists: $path"
  fi
}

has_meaningful_content() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    return 1
  fi
  if grep -q '[^[:space:]]' "$path" 2>/dev/null; then
    return 0
  fi
  return 1
}

write_factory_file() {
  local path="$1"
  local content="$2"
  local exists=0
  local meaningful=0

  if [[ -f "$path" ]]; then
    exists=1
    if has_meaningful_content "$path"; then
      meaningful=1
    fi
  fi

  if [[ "$exists" -eq 1 && "$meaningful" -eq 1 && "$FORCE" -eq 0 ]]; then
    echo "Preserved existing file: $path"
    return 0
  fi

  local parent
  parent="$(dirname "$path")"
  if [[ ! -d "$parent" ]]; then
    mkdir -p "$parent"
  fi

  printf '%s' "$content" > "$path"
  if [[ -s "$path" ]]; then
    local last
    last="$(tail -c1 "$path" | od -An -t u1 | tr -d ' \n')"
    if [[ "$last" != "10" ]]; then
      printf '\n' >> "$path"
    fi
  fi

  if [[ "$exists" -eq 1 && "$FORCE" -eq 1 ]]; then
    echo "Overwrote file: $path"
  elif [[ "$exists" -eq 1 ]]; then
    echo "Filled empty file: $path"
  else
    echo "Created file: $path"
  fi
}

write_from_source() {
  local source_path="$1"
  local dest_path="$2"
  if [[ ! -f "$source_path" ]]; then
    echo "Warning: Template source missing: $source_path" >&2
    return 0
  fi
  local content
  content="$(cat "$source_path")"
  write_factory_file "$dest_path" "$content"
}

initContract=$(cat <<'EOF_initContract'

# Factory Bootstrap Initialization Contract

## Purpose

This document defines the canonical bootstrap initialization contract for **The Factory**.

It answers:

- what `"init factory"` means in a target repository
- what the bootstrap script must create in a target repository
- which bootstrap artifacts are required at minimum
- how initialization should behave when files already exist
- how initialization should seed initial runtime state

This file is the source of truth for target-repository bootstrap behavior.

The broader framework-level contract for The Factory is defined in this repository at `framework/spec/factory-spec.md`.

In the Factory framework repo, checked-in `.factory/` artifacts may appear as richer reference scaffolds. This document defines the minimum target-repository runtime bootstrap bundle plus the currently supported optional local reference outputs for humans and generic agents.

## Bootstrap Goal

Initialization creates the minimum durable **`.factory/` runtime workspace** required for Factory-driven product work in a target repository.

It creates bootstrap structure only and seeds safe placeholders, including brownfield reverse-engineering artifacts for Cartographer.

## Supported Invocation Styles

- Agent command in a target repository: `init factory`
- Canonical framework-repository bootstrap scripts:
  - `bootstrap/scripts/init-factory.ps1` (Windows PowerShell)
  - `bootstrap/scripts/init-factory.sh` (Linux/macOS bash)

In the current script-driven workflow, users may:

1. copy the `bootstrap/` folder into the target repository
2. run `bootstrap/scripts/init-factory.ps1` (Windows) or `bootstrap/scripts/init-factory.sh` (Linux/macOS)
3. verify the emitted `/.factory/` runtime workspace and any local reference docs
4. delete the copied `bootstrap/` folder if it is no longer needed

## Canonical Bootstrap Structure

### Required bootstrap root artifacts

- `/.factory/prd.md`
- `/.factory/state.md`
- `/.factory/init.md`

### Required bootstrap subdirectories and artifacts

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
- `/.factory/planner/work-orders.md`
- `/.factory/planner/validation-plan.md`
- `/.factory/assembler/execution-log.md`
- `/.factory/assembler/change-summary.md`
- `/.factory/validator/verification-report.md`
- `/.factory/controller/report.md`

### Portable local reference artifacts

When `bootstrap/portable-agent-pack/` is present, initialization should also emit:

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

## Rules

- non-destructive by default
- idempotent on repeated runs
- template-only seeding
- no overwriting of meaningful existing content unless explicitly forced
- runtime-only scope with no dependency on out-of-band storage
- optional local reference docs must not redefine the active runtime plane

`/AGENTS.md` may be used as the root agent operating guide when emitted, but it is not the runtime system of record; active project truth still lives under `/.factory/`.

## Initial Runtime State Guidance

When first created in a target repository, `/.factory/state.md` should indicate:

- Current Phase: Initialization
- Active Skill: None
- Current Status: Factory workspace initialized
- Current Work Order: None
- Next Expected Action: populate `/.factory/prd.md` or invoke Refinery

## One-Line Definition

**Factory bootstrap initialization creates the minimum canonical `.factory/` runtime workspace safely, repeatably, and without overwriting meaningful existing project artifacts by default.**
EOF_initContract
)

prdTemplate=$(cat <<'EOF_prdTemplate'

# Product Requirements Document

## Status
Draft

## Purpose
This is the canonical starting product request for this repository inside **The Factory**.

## Product Request
> TODO: Replace this placeholder with the actual product request or project idea.

## Notes
- Refinery should trace product specifications back to this document.
- Foundry, Planner, Assembler, and Validator should preserve traceability to this source request.
EOF_prdTemplate
)

stateTemplate=$(cat <<'EOF_stateTemplate'

# Factory State

## Purpose
This file is the canonical anti-drift control record for **The Factory** within the target repository.

## Current Phase
Initialization

## Active Skill
None

## Current Status
Factory workspace initialized

## Canonical Inputs
- `/.factory/prd.md`
- `/.factory/init.md`

## Canonical Outputs
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
- `/.factory/planner/work-orders.md`
- `/.factory/planner/validation-plan.md`
- `/.factory/assembler/execution-log.md`
- `/.factory/assembler/change-summary.md`
- `/.factory/validator/verification-report.md`
- `/.factory/controller/report.md`

## Last Completed Step
Initialized the minimum `.factory/` runtime workspace

## Active Artifact
`/.factory/state.md`

## Current Work Order
None

## Blockers
- `/.factory/prd.md` may still contain placeholder content
- Cartographer artifacts may still need legacy-system analysis
- downstream artifacts may not yet contain project-specific content

## Open Questions
- What is the actual initial product request?

## Next Expected Action
Populate `/.factory/prd.md` or invoke Refinery
EOF_stateTemplate
)

cartographerSystemSpecTemplate=$(cat <<'EOF_cartographerSystemSpecTemplate'

# Cartographer System Specification

## Status
Not started

## Purpose
Canonical **narrative index** and structural skeleton for as-built legacy truth. Detail lives in ID ledgers:
- behaviors → `behavior-catalog.md` (`OBS-*`)
- business rules → `behavior-catalog.md` (`BR-*`)
- integrations → `integration-map.md` (`INT-*`)
- parity risks → `parity-risks.md` (`PAR-*`)

Run the Cartographer analysis ladder before filling catalogs: evidence inventory → surface → capability tree → processes → BR/state/data → integrations → OBS/BR/INT/PAR → quality self-check.
Default pass mode is **bounded-deep** unless the operator explicitly requests orientation.

## Pass Mode
- Mode: orientation | bounded-deep | targeted | parity-forensic
- Objective:
- Rationale:

## Scope of Study
- Included paths / services:
- Entry points in scope:
- Integrations in scope:
- Explicit exclusions:
- Time / branch boundary:

## Evidence Inventory
| Source class | What was used | Gaps |
| --- | --- | --- |
| Code | | |
| Tests | | |
| Config / schema | | |
| Jobs / scripts | | |
| Docs / runbooks | | |
| Logs / data | | |

## System Summary
- Purpose:
- Major actors:
- Operational context:

## Surface Inventory
- Entry points:
- Packages / modules:
- Jobs / batch:
- Persistence boundaries:
- Outbound I/O:

## Capability Tree (CAP-*)
| ID | Capability | Parent | Primary OBS / process | Confidence |
| --- | --- | --- | --- | --- |
| | | | | |

## Process Index
| Process | CAP | Happy path | Exceptions | Related OBS |
| --- | --- | --- | --- | --- |
| | | | | |

## Data and State Model
- Important entities and meanings:
- Source of truth:
- State transitions:
- Persistence boundaries:
- Known data traps (overloaded fields, sentinels, batch-only fields):

## Operational Notes
- Batch / delayed paths:
- Reconciliation:
- Workarounds (evidence-backed only):

## Recovered Intent Notes (Inferred only — not requirements)
- None yet.

## Open Questions
- None identified for this scope. *(replace when applicable)*

## Quality Self-Check
- Mode checked:
- Result: ready | not-ready | not-started
- Failed or deferred gates:
- Notes for Controller / operator:

## Ledger Pointers
- Next free CAP: CAP-001
- Next free OBS: OBS-001
- Next free BR: BR-001
- Next free INT: INT-001
- Next free PAR: PAR-001

## Notes
Cartographer should replace placeholders with an evidence-backed description of what the legacy system actually does. Do not dump full catalog rows here—link by ID. Stay as-built only; no target architecture or product requirements. End every pass with Quality Self-Check.
EOF_cartographerSystemSpecTemplate
)

cartographerBehaviorCatalogTemplate=$(cat <<'EOF_cartographerBehaviorCatalogTemplate'

# Cartographer Behavior Catalog

## Status
Not started

## Purpose
Cumulative ledger of observable legacy behaviors (`OBS-NNN`) and enforced business rules (`BR-NNN`).
Append new IDs; preserve historical bodies. See Cartographer skill for field rules.

## Active sequence
- Highest OBS: *(none)*
- Next free OBS: OBS-001
- Highest BR: *(none)*
- Next free BR: BR-001

## Ledger

### OBS-001 *(template — replace or remove when writing real entries)*
- Status: active
- Capability: CAP-…
- Process:
- Trigger:
- Preconditions:
- Inputs:
- Decision Points:
- Outputs:
- Postconditions:
- State Changes:
- Side Effects:
- Error / Exception Paths:
- Controls / Overrides:
- Related Rules: BR-… (or none)
- Confidence: Observed | Inferred | Unverified | Contradicted
- Evidence Type: code | test | config | schema | doc | log | ops | inferred
- Evidence: `path/to/file:L..`
- Notes:

### BR-001 *(template — replace or remove when writing real entries)*
- Status: active
- Name:
- Category: eligibility | calculation | validation | authorization | classification | timing | routing | retention | compliance | exception | other
- Condition:
- Outcome:
- Capability: CAP-…
- Enforced By: OBS-… and/or `path:L..`
- Exceptions / Precedence:
- Confidence: Observed | Inferred | Unverified | Contradicted
- Evidence Type: code | test | config | schema | doc | log | ops | inferred
- Evidence: `path/to/file:L..`
- Notes:
EOF_cartographerBehaviorCatalogTemplate
)

cartographerIntegrationMapTemplate=$(cat <<'EOF_cartographerIntegrationMapTemplate'

# Cartographer Integration Map

## Status
Not started

## Purpose
Cumulative ledger of external integrations and dependencies (`INT-NNN`).
Append new IDs; preserve historical bodies. See Cartographer skill for field rules.

## Active sequence
- Highest INT: *(none)*
- Next free ID: INT-001

## Ledger

### INT-001 *(template — replace or remove when writing real entries)*
- Status: active
- Integration:
- Business Purpose:
- Direction: inbound | outbound | bidirectional
- Trigger / Frequency:
- Protocol / Contract:
- Data Exchanged:
- Auth / Trust Boundary:
- Ordering / Idempotency:
- Failure Behavior:
- Retry / Timeout / Permanent Failure:
- Reconciliation:
- Calling Components:
- Confidence: Observed | Inferred | Unverified | Contradicted
- Evidence Type: code | test | config | schema | doc | log | ops | inferred
- Evidence: `path/to/file:L..`
EOF_cartographerIntegrationMapTemplate
)

cartographerParityRisksTemplate=$(cat <<'EOF_cartographerParityRisksTemplate'

# Cartographer Parity Risks

## Status
Not started

## Purpose
Cumulative ledger of parity risks, quirks, contradictions, and evidence gaps (`PAR-NNN`).
Append new IDs; preserve historical bodies. See Cartographer skill for field rules.

## Active sequence
- Highest PAR: *(none)*
- Next free ID: PAR-001

## Ledger

### PAR-001 *(template — replace or remove when writing real entries)*
- Status: active
- Risk:
- Affected Behavior: OBS-… / CAP-… / narrative
- Why It Matters:
- Confidence: Observed | Inferred | Unverified | Contradicted
- Evidence Gap:
- Recommended Investigation:
- Evidence: `path/to/file:L..`
EOF_cartographerParityRisksTemplate
)

refinerySpecTemplate=$(cat <<'EOF_refinerySpecTemplate'

# Refinery Specification

## Status
Not started

## Purpose
This is the canonical product-intent specification artifact for Refinery.

## Canonical Inputs
- `/.factory/prd.md`
- `/.factory/state.md`

## Notes
Refinery should replace this placeholder with a product specification focused on intent, scope, users, scenarios, and acceptance criteria.
EOF_refinerySpecTemplate
)

foundryDesignTemplate=$(cat <<'EOF_foundryDesignTemplate'

# Foundry Design

## Status
Not started

## Purpose
This is the canonical Foundry summary and architectural narrative.

## Supporting Foundry Artifacts
- `/.factory/foundry/system-context.md`
- `/.factory/foundry/container-view.md`
- `/.factory/foundry/component-views.md`
- `/.factory/foundry/adr/index.md`

## Technical Intent
> TODO: State what the technical design must enable.

## Traceability to Refinery
- Source specification: `/.factory/refinery/spec.md`
- TODO: List the key scenarios, goals, and constraints this design must satisfy.

## Architectural Overview
> TODO: Summarize the overall solution shape and how the supporting Foundry artifacts fit together.

## Foundry Artifact Map
- `system-context.md` — C4 Level 1 system context view
- `container-view.md` — C4 Level 2 container view
- `component-views.md` — selective C4 Level 3 views
- `adr/index.md` — architectural decision register and ADR index

## System Boundaries
- Inside scope:
- Outside scope:

## Cross-Cutting Constraints
- TODO: Capture security, data, platform, compliance, and operational constraints.

## Quality Attributes
- Reliability:
- Performance:
- Security:
- Maintainability:
- Observability:

## Risks and Tradeoffs
- Risk:
- Tradeoff:

## ADR Summary
- TODO: Summarize current material architectural decisions and point to ADRs when present.

## Implementation Guardrails
- TODO: Capture constraints that Planner and Assembler must preserve.

## Canonical Inputs
- `/.factory/prd.md`
- `/.factory/refinery/spec.md`
- `/.factory/state.md`

## Notes
Foundry should replace this placeholder with the technical intent, architecture narrative, traceability to supporting Mermaid-based C4 views, decisions, constraints, and implementation guardrails.
EOF_foundryDesignTemplate
)

foundrySystemContextTemplate=$(cat <<'EOF_foundrySystemContextTemplate'

# Foundry System Context

## Status
Not started

## Purpose
This is the canonical C4 Level 1 system context view for Foundry.

## Canonical Inputs
- `/.factory/prd.md`
- `/.factory/refinery/spec.md`
- `/.factory/state.md`

## Scope Statement
> TODO: State what system or capability is in scope and why.

## Primary Actors
| Actor | Role | Key Concern |
| --- | --- | --- |
| TODO | TODO | TODO |

## External Systems
| System | Relationship | Why It Matters |
| --- | --- | --- |
| TODO | TODO | TODO |

## Relationship Notes
- TODO: Summarize the most important actor and external-system interactions.

## Mermaid Diagram
```mermaid
flowchart LR
    %% TODO: Replace placeholders with the canonical C4 Level 1 system context.
    User["User: Primary Actor"]
    System["System: Capability in Scope"]
    External["External System: Example Dependency"]

    User -->|Submits request| System
    System -->|Calls API| External
```

## Traceability to Refinery
- TODO: List the Refinery scenarios and constraints this context view supports.

## Notes
Foundry should keep this artifact stakeholder-readable, Mermaid-based, and limited to C4 Level 1 context rather than internal container detail.
EOF_foundrySystemContextTemplate
)

foundryContainerViewTemplate=$(cat <<'EOF_foundryContainerViewTemplate'

# Foundry Container View

## Status
Not started

## Purpose
This is the canonical C4 Level 2 container view for Foundry.

## Canonical Inputs
- `/.factory/prd.md`
- `/.factory/refinery/spec.md`
- `/.factory/state.md`

## System-in-Scope Summary
> TODO: Summarize the system being decomposed into containers.

## Container Inventory
| Container | Technology / Runtime | Responsibility |
| --- | --- | --- |
| TODO | TODO | TODO |

## Responsibilities by Container
- TODO: Describe each container's primary responsibility and ownership boundary.

## Key Interactions
| Source | Target | Interaction | Protocol / Mechanism |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

## Data Flow Notes
- TODO: Summarize important data flows, ownership transitions, and contract boundaries.

## Mermaid Diagram
```mermaid
flowchart LR
    %% TODO: Replace placeholders with the canonical C4 Level 2 container view.
    User["User: Primary Actor"]
    Web["Container: Web App"]
    Api["Container: API Service"]
    Db["Container: Primary Database"]
    External["External System: Example Dependency"]

    User -->|Uses| Web
    Web -->|Calls API| Api
    Api -->|Reads/Writes| Db
    Api -->|Calls API| External
```

## Constraints Affecting Container Boundaries
- TODO: Capture constraints that drive container separation or interaction rules.

## Notes
Foundry should keep this artifact Mermaid-based, C4 Level 2 focused, and explicit about responsibilities, interactions, and boundaries.
EOF_foundryContainerViewTemplate
)

foundryComponentViewsTemplate=$(cat <<'EOF_foundryComponentViewsTemplate'

# Foundry Component Views

## Status
Not started

## Purpose
This is the canonical C4 Level 3 component-view artifact for Foundry.

## Canonical Inputs
- `/.factory/prd.md`
- `/.factory/refinery/spec.md`
- `/.factory/state.md`

## When Component Views Are Needed
- Use this artifact only for architecturally significant containers or subsystems.
- Skip trivial or low-value decomposition.

## Container / Subsystem: `<name>`

### Purpose
> TODO: Explain why this container or subsystem needs a component-level view.

### Component Inventory
| Component | Responsibility | Key Interfaces |
| --- | --- | --- |
| TODO | TODO | TODO |

### Interaction Notes
- TODO: Describe important interactions, dependencies, and ownership boundaries.

### Mermaid Diagram
```mermaid
flowchart LR
    %% TODO: Replace placeholders with the canonical C4 Level 3 component view.
    Entry["Component: Entry / Interface Layer"]
    Service["Component: Application / Domain Service"]
    Store["Component: Persistence / Gateway"]

    Entry -->|Invokes| Service
    Service -->|Reads/Writes| Store
```

### Related ADRs
- TODO: Link relevant ADRs from `/.factory/foundry/adr/`.

## Notes
Foundry should keep this artifact Mermaid-based, selective, and focused on meaningful internal decomposition rather than implementation minutiae.
EOF_foundryComponentViewsTemplate
)

foundryAdrIndexTemplate=$(cat <<'EOF_foundryAdrIndexTemplate'

# Foundry ADR Index

## Status
Not started

## Purpose
This is the canonical architectural decision register and index for Foundry ADRs.

## Canonical Inputs
- `/.factory/prd.md`
- `/.factory/refinery/spec.md`
- `/.factory/foundry/design.md`
- `/.factory/state.md`

## Decision Register
| ADR | Title | Status | Related View(s) | Notes |
| --- | --- | --- | --- | --- |
| TODO | TODO | proposed | TODO | TODO |

## Status Definitions
- `proposed` — decision identified but not yet accepted
- `accepted` — decision approved and active
- `superseded` — replaced by a later ADR

## Authoring Notes
- Create `ADR-XXX-<title>.md` files under `/.factory/foundry/adr/` when decisions need durable records.
- Link each ADR to the affected Foundry C4 views where useful.

## Notes
Foundry should use this artifact as the scannable index for architectural decisions while keeping durable decision bodies in individual ADR files when needed.
EOF_foundryAdrIndexTemplate
)

workOrdersTemplate=$(cat <<'EOF_workOrdersTemplate'

# Planner Work Orders

## Status
Not started

## Purpose
This is the **cumulative Work Order ledger** for the project lifetime.
Planner appends new `WO-NNN` entries over time. Do **not** replace this file with only the latest increment, and do not collapse completed Work Orders to id-ranges without retaining full bodies.

## Active sequence
- Current increment:
- Active or newly planned WO IDs:
- Next free ID: WO-001

## Ledger

## Work Order Template

### WO-XXX
- Status: planned
- Objective:
- Prerequisites:
- Files Affected:
- Concrete Changes Required:
- Completion Condition:
- Validation Method:
EOF_workOrdersTemplate
)

validationPlanTemplate=$(cat <<'EOF_validationPlanTemplate'

# Planner Validation Plan

## Status
Not started

## Purpose
This is the **cumulative** validation planning ledger, including acceptance test definition proposals.
Planner appends new `TEST-NNN` entries over time. Do **not** replace this file with only the latest increment's tests.

## Acceptance Test Template

### TEST-XXX
- Purpose:
- Source Scenario / Constraint:
- Setup Context:
- Action:
- Expected Outcome:
- Notes for Assembler:
EOF_validationPlanTemplate
)

executionLogTemplate=$(cat <<'EOF_executionLogTemplate'

# Assembler Execution Log

## Status
Not started

## Purpose
This is the canonical execution log for completed work-order activity.

## Execution Entry Template

### WO-XXX
- Start Time:
- End Time:
- Objective:
- Files Changed:
- Validation Run:
- Result:
- Notes:
EOF_executionLogTemplate
)

changeSummaryTemplate=$(cat <<'EOF_changeSummaryTemplate'

# Assembler Change Summary

## Status
Not started

## Purpose
This is the canonical implementation summary artifact for repository changes.

## Summary Template
- Completed Work Orders:
- Files Changed:
- Dependency Changes:
- Tests Added or Updated:
- Outstanding Issues:
EOF_changeSummaryTemplate
)

verificationReportTemplate=$(cat <<'EOF_verificationReportTemplate'

# Validator Verification Report

## Status
Not started

## Purpose
This is the canonical criteria-traceable verification artifact.

## Verification Template
- Validation Target:
- Source Acceptance Criteria:
- Automated Checks Run:
- Acceptance Criteria Coverage:
- Defects / Deviations:
- Final Verification Status:
EOF_verificationReportTemplate
)

controllerReportTemplate=$(cat <<'EOF_controllerReportTemplate'

# Controller Report

## Status
Not started

## Purpose
This is the canonical process-integrity and operator-guidance artifact for **The Factory**.

Controller observes the runtime harness, records findings (`FIND-NNN`), and recommends the next skilled action. It does not implement product work or rewrite other skills' artifacts.

## Template
- Last review:
- Mode: Review | Brief | Preflight
- Open blocks / warns:
- Recommended next skill:
- Operator brief:
- Findings (FIND-NNN):
EOF_controllerReportTemplate
)


ensure_dir "$FACTORY_ROOT"
ensure_dir "$FACTORY_ROOT/cartographer"
ensure_dir "$FACTORY_ROOT/refinery"
ensure_dir "$FACTORY_ROOT/foundry"
ensure_dir "$FACTORY_ROOT/foundry/adr"
ensure_dir "$FACTORY_ROOT/planner"
ensure_dir "$FACTORY_ROOT/assembler"
ensure_dir "$FACTORY_ROOT/validator"
ensure_dir "$FACTORY_ROOT/controller"

if [[ -d "$PORTABLE_DOCS_SRC" || -d "$PORTABLE_SKILLS_SRC" || -f "$PORTABLE_AGENTS_SRC" ]]; then
  ensure_dir "$DOCS_ROOT"
  ensure_dir "$FACTORY_DOCS_ROOT"
  ensure_dir "$FACTORY_SKILL_DOCS_ROOT"
fi

write_factory_file "$FACTORY_ROOT/init.md" "$initContract"
write_factory_file "$FACTORY_ROOT/prd.md" "$prdTemplate"
write_factory_file "$FACTORY_ROOT/state.md" "$stateTemplate"
write_factory_file "$FACTORY_ROOT/cartographer/system-spec.md" "$cartographerSystemSpecTemplate"
write_factory_file "$FACTORY_ROOT/cartographer/behavior-catalog.md" "$cartographerBehaviorCatalogTemplate"
write_factory_file "$FACTORY_ROOT/cartographer/integration-map.md" "$cartographerIntegrationMapTemplate"
write_factory_file "$FACTORY_ROOT/cartographer/parity-risks.md" "$cartographerParityRisksTemplate"
write_factory_file "$FACTORY_ROOT/refinery/spec.md" "$refinerySpecTemplate"
write_factory_file "$FACTORY_ROOT/foundry/design.md" "$foundryDesignTemplate"
write_factory_file "$FACTORY_ROOT/foundry/system-context.md" "$foundrySystemContextTemplate"
write_factory_file "$FACTORY_ROOT/foundry/container-view.md" "$foundryContainerViewTemplate"
write_factory_file "$FACTORY_ROOT/foundry/component-views.md" "$foundryComponentViewsTemplate"
write_factory_file "$FACTORY_ROOT/foundry/adr/index.md" "$foundryAdrIndexTemplate"
write_factory_file "$FACTORY_ROOT/planner/work-orders.md" "$workOrdersTemplate"
write_factory_file "$FACTORY_ROOT/planner/validation-plan.md" "$validationPlanTemplate"
write_factory_file "$FACTORY_ROOT/assembler/execution-log.md" "$executionLogTemplate"
write_factory_file "$FACTORY_ROOT/assembler/change-summary.md" "$changeSummaryTemplate"
write_factory_file "$FACTORY_ROOT/validator/verification-report.md" "$verificationReportTemplate"
write_factory_file "$FACTORY_ROOT/controller/report.md" "$controllerReportTemplate"

if [[ -d "$PORTABLE_DOCS_SRC" || -d "$PORTABLE_SKILLS_SRC" || -f "$PORTABLE_AGENTS_SRC" ]]; then
  write_from_source "$PORTABLE_AGENTS_SRC" "$AGENTS_FILE_PATH"
  # Pack layout: docs/operating-model.md, docs/foundry-c4-authoring-standard.md, docs/factory/skills/*.md
  write_from_source "$PORTABLE_DOCS_SRC/operating-model.md" "$FACTORY_DOCS_ROOT/operating-model.md"
  write_from_source "$PORTABLE_DOCS_SRC/foundry-c4-authoring-standard.md" "$FACTORY_DOCS_ROOT/foundry-c4-authoring-standard.md"

  for skillName in Cartographer Refinery Foundry Planner Assembler Validator Controller; do
    write_from_source "$PORTABLE_SKILLS_SRC/${skillName}.md" "$FACTORY_SKILL_DOCS_ROOT/${skillName}.md"
  done

  echo "Portable Factory agent reference docs emitted under docs/factory/."
else
  echo "Portable Factory agent pack not found; skipped docs/factory/ emission."
fi

echo ""
echo "Factory initialization completed."
if [[ "$FORCE" -eq 1 ]]; then
  echo "Mode: force overwrite enabled for existing meaningful files."
else
  echo "Mode: non-destructive; existing meaningful files were preserved."
fi
