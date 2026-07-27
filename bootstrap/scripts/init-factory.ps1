[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$bootstrapRoot = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent $bootstrapRoot
$factoryRoot = Join-Path $repoRoot '.factory'
$portableAgentPackRoot = Join-Path $bootstrapRoot 'portable-agent-pack'
$portableAgentRootInstructionSourcePath = Join-Path $portableAgentPackRoot 'AGENTS.md'
$portableAgentDocsSourceRoot = Join-Path $portableAgentPackRoot 'docs\factory'
$portableAgentSkillDocsSourceRoot = Join-Path $portableAgentDocsSourceRoot 'skills'
$docsRoot = Join-Path $repoRoot 'docs'
$factoryDocsRoot = Join-Path $docsRoot 'factory'
$factorySkillDocsRoot = Join-Path $factoryDocsRoot 'skills'
$agentsFilePath = Join-Path $repoRoot 'AGENTS.md'

function Ensure-Directory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "Created directory: $Path"
    }
    else {
        Write-Host "Directory exists: $Path"
    }
}

function Test-FileHasMeaningfulContent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    $content = Get-Content -LiteralPath $Path -Raw
    return -not [string]::IsNullOrWhiteSpace($content)
}

function Write-FactoryFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $exists = Test-Path -LiteralPath $Path
    $hasMeaningfulContent = $false

    if ($exists) {
        $hasMeaningfulContent = Test-FileHasMeaningfulContent -Path $Path
    }

    if ($exists -and $hasMeaningfulContent -and -not $Force) {
        Write-Host "Preserved existing file: $Path"
        return
    }

    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    [System.IO.File]::WriteAllText($Path, $Content.Replace("`n", [Environment]::NewLine))
    if ($exists -and $Force) {
        Write-Host "Overwrote file: $Path"
    }
    elseif ($exists) {
        Write-Host "Filled empty file: $Path"
    }
    else {
        Write-Host "Created file: $Path"
    }
}

function Write-TemplateFileFromSource {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    if (-not (Test-Path -LiteralPath $SourcePath)) {
        Write-Warning "Template source missing: $SourcePath"
        return
    }

    $content = Get-Content -LiteralPath $SourcePath -Raw
    Write-FactoryFile -Path $DestinationPath -Content $content
}

$initContract = @'
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
- Canonical framework-repository bootstrap script: `bootstrap/scripts/init-factory.ps1`

In the current script-driven workflow, users may:

1. copy the `bootstrap/` folder into the target repository
2. run `bootstrap/scripts/init-factory.ps1`
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
'@

$prdTemplate = @'
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
'@

$stateTemplate = @'
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
'@

$cartographerSystemSpecTemplate = @'
# Cartographer System Specification

## Status
Not started

## Purpose
Canonical **narrative index** for as-built legacy truth. Detail lives in ID ledgers:
- behaviors → `behavior-catalog.md` (`OBS-*`)
- integrations → `integration-map.md` (`INT-*`)
- parity risks → `parity-risks.md` (`PAR-*`)

## Scope of Study
- Included paths / services:
- Entry points in scope:
- Explicit exclusions:

## System Summary
- Purpose:
- Major actors:
- Major capabilities:

## Capability Index (optional CAP-*)
| ID | Capability | Primary OBS / notes |
| --- | --- | --- |
| | | |

## Data and State Model
- Important entities:
- State transitions:
- Persistence boundaries:

## User-Visible Flows (summary)
- Flow → related OBS-*:

## Open Questions
- None identified for this scope. *(replace when applicable)*

## Ledger Pointers
- Next free OBS: OBS-001
- Next free INT: INT-001
- Next free PAR: PAR-001

## Notes
Cartographer should replace placeholders with an evidence-backed description of what the legacy system actually does. Do not dump full catalog rows here—link by ID.
'@

$cartographerBehaviorCatalogTemplate = @'
# Cartographer Behavior Catalog

## Status
Not started

## Purpose
Cumulative ledger of observable legacy behaviors and enforced rules (`OBS-NNN`).
Append new IDs; preserve historical bodies. See Cartographer skill for field rules.

## Active sequence
- Highest OBS: *(none)*
- Next free ID: OBS-001

## Ledger

### OBS-001 *(template — replace or remove when writing real entries)*
- Status: active
- Capability:
- Trigger:
- Inputs:
- Outputs:
- State Changes:
- Side Effects:
- Error Behavior:
- Confidence: Observed | Inferred | Unverified | Contradicted
- Evidence: `path/to/file:L..`
- Notes:
'@

$cartographerIntegrationMapTemplate = @'
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
- Direction: inbound | outbound | bidirectional
- Trigger:
- Data Exchanged:
- Failure Behavior:
- Calling Components:
- Confidence: Observed | Inferred | Unverified | Contradicted
- Evidence: `path/to/file:L..`
'@

$cartographerParityRisksTemplate = @'
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
'@

$refinerySpecTemplate = @'
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
'@

$foundryDesignTemplate = @'
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
'@

$foundrySystemContextTemplate = @'
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
'@

$foundryContainerViewTemplate = @'
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
'@

$foundryComponentViewsTemplate = @'
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
'@

$foundryAdrIndexTemplate = @'
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
'@

$workOrdersTemplate = @'
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
'@

$validationPlanTemplate = @'
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
'@

$executionLogTemplate = @'
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
'@

$changeSummaryTemplate = @'
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
'@

$verificationReportTemplate = @'
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
'@

$controllerReportTemplate = @'
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
'@

Ensure-Directory -Path $factoryRoot
Ensure-Directory -Path (Join-Path $factoryRoot 'cartographer')
Ensure-Directory -Path (Join-Path $factoryRoot 'refinery')
Ensure-Directory -Path (Join-Path $factoryRoot 'foundry')
Ensure-Directory -Path (Join-Path $factoryRoot 'foundry\adr')
Ensure-Directory -Path (Join-Path $factoryRoot 'planner')
Ensure-Directory -Path (Join-Path $factoryRoot 'assembler')
Ensure-Directory -Path (Join-Path $factoryRoot 'validator')
Ensure-Directory -Path (Join-Path $factoryRoot 'controller')

if (Test-Path -LiteralPath $portableAgentDocsSourceRoot) {
    Ensure-Directory -Path $docsRoot
    Ensure-Directory -Path $factoryDocsRoot
    Ensure-Directory -Path $factorySkillDocsRoot
}

Write-FactoryFile -Path (Join-Path $factoryRoot 'init.md') -Content $initContract
Write-FactoryFile -Path (Join-Path $factoryRoot 'prd.md') -Content $prdTemplate

Write-FactoryFile -Path (Join-Path $factoryRoot 'state.md') -Content $stateTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'cartographer\system-spec.md') -Content $cartographerSystemSpecTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'cartographer\behavior-catalog.md') -Content $cartographerBehaviorCatalogTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'cartographer\integration-map.md') -Content $cartographerIntegrationMapTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'cartographer\parity-risks.md') -Content $cartographerParityRisksTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'refinery\spec.md') -Content $refinerySpecTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'foundry\design.md') -Content $foundryDesignTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'foundry\system-context.md') -Content $foundrySystemContextTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'foundry\container-view.md') -Content $foundryContainerViewTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'foundry\component-views.md') -Content $foundryComponentViewsTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'foundry\adr\index.md') -Content $foundryAdrIndexTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'planner\work-orders.md') -Content $workOrdersTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'planner\validation-plan.md') -Content $validationPlanTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'assembler\execution-log.md') -Content $executionLogTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'assembler\change-summary.md') -Content $changeSummaryTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'validator\verification-report.md') -Content $verificationReportTemplate
Write-FactoryFile -Path (Join-Path $factoryRoot 'controller\report.md') -Content $controllerReportTemplate

if (Test-Path -LiteralPath $portableAgentDocsSourceRoot) {
    Write-TemplateFileFromSource -SourcePath $portableAgentRootInstructionSourcePath -DestinationPath $agentsFilePath
    Write-TemplateFileFromSource -SourcePath (Join-Path $portableAgentDocsSourceRoot 'operating-model.md') -DestinationPath (Join-Path $factoryDocsRoot 'operating-model.md')
    Write-TemplateFileFromSource -SourcePath (Join-Path $portableAgentDocsSourceRoot 'foundry-c4-authoring-standard.md') -DestinationPath (Join-Path $factoryDocsRoot 'foundry-c4-authoring-standard.md')

    $portableAgentSkillNames = @(
        'Cartographer',
        'Refinery',
        'Foundry',
        'Planner',
        'Assembler',
        'Validator',
        'Controller'
    )

    foreach ($skillName in $portableAgentSkillNames) {
        Write-TemplateFileFromSource -SourcePath (Join-Path $portableAgentSkillDocsSourceRoot "$skillName.md") -DestinationPath (Join-Path $factorySkillDocsRoot "$skillName.md")
    }

    Write-Host 'Portable Factory agent reference docs emitted under docs/factory/.'
}
else {
    Write-Host 'Portable Factory agent pack not found; skipped docs/factory/ emission.'
}

Write-Host ''
Write-Host 'Factory initialization completed.'
if ($Force) {
    Write-Host 'Mode: force overwrite enabled for existing meaningful files.'
}
else {
    Write-Host 'Mode: non-destructive; existing meaningful files were preserved.'
}