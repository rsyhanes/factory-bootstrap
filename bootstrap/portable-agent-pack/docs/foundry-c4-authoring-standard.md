# Foundry C4 Authoring Standard

## Purpose

This document defines the standard way **Foundry** should author and maintain C4 architecture views in **The Factory**.

The goal is to keep architecture communication:

- consistent across repositories
- easy for humans and agents to read
- aligned with Foundry's technical narrative
- portable in Markdown-first workflows

## Scope

This standard applies to the Foundry artifact set under `/.factory/foundry/`, especially:

- `design.md`
- `system-context.md`
- `container-view.md`
- `component-views.md`
- `adr/index.md`

## Ownership Model

- **Foundry owns the architectural meaning.**
- This standard defines **how that architecture is expressed**, not what the architecture must be.
- Downstream skills such as Planner and Validator may rely on these artifacts, but they must not redefine them.

## Canonical Diagram Language

**Mermaid** is the canonical diagram language for Foundry C4 views.

### Required defaults

- use Mermaid code blocks for canonical diagrams
- prefer `flowchart LR` by default
- use `flowchart TD` only when vertical layout is materially clearer
- keep one **canonical Mermaid diagram block** per major view section
- split diagrams when readability degrades instead of overloading one block

## Artifact-Level Standard

### `design.md`

`design.md` is the canonical Foundry summary and architectural narrative.

It should contain:

- technical intent
- traceability to Refinery
- architectural overview
- system boundaries
- cross-cutting constraints
- quality attributes
- risks and tradeoffs
- implementation guardrails
- links to supporting C4 and ADR artifacts

`design.md` may contain a small overview diagram if useful, but it should not become the dumping ground for all architectural diagrams.

### `system-context.md`

This is the canonical **C4 Level 1** artifact.

It should contain:

- scope statement
- primary actors table
- external systems table
- relationship notes
- Mermaid diagram
- traceability to Refinery scenarios

### `container-view.md`

This is the canonical **C4 Level 2** artifact.

It should contain:

- system-in-scope summary
- container inventory table
- responsibilities by container
- key interactions table
- data flow notes
- Mermaid diagram
- constraints affecting container boundaries

### `component-views.md`

This is the canonical **C4 Level 3** artifact and should be used **selectively**.

It should contain one section per significant container or subsystem that needs deeper decomposition, with:

- container/subsystem purpose
- component inventory table
- interfaces and interactions
- Mermaid diagram
- related ADRs

Do not create exhaustive component diagrams for trivial or low-value structures.

### `adr/index.md`

This is the canonical architectural decision register.

It should contain:

- decision register table
- decision status (`proposed`, `accepted`, `superseded`)
- links to ADR files
- links to related Foundry views where useful

## Mermaid Conventions

### Node naming

Use consistent, human-readable labels.

- people / actors: `User: <role>`
- external systems: `External System: <name>`
- system in scope: `System: <name>`
- containers: `Container: <name>`
- components: `Component: <name>`

Technology details may be included in labels when they clarify the architecture, especially for containers.

### Relationship labels

Use **verb-first, meaningful relationship labels**, such as:

- `Submits request`
- `Reads work orders`
- `Calls API`
- `Publishes events`
- `Stores artifacts in`

Avoid vague labels like:

- `uses`
- `talks to`
- `connects`

### Boundary clarity

Each view should make inside/outside boundaries obvious.

Where useful, use Mermaid `subgraph` blocks to distinguish:

- the system in scope
- internal containers
- external dependencies

### Complexity rule

If a single diagram becomes crowded:

- split it into focused diagrams
- retain one canonical primary view
- add secondary focused diagrams only when they increase clarity

## Level-of-Detail Rules

### System Context

- emphasize users, external systems, and system purpose
- do **not** show internal container decomposition here

### Container View

- emphasize application/runtime containers and their responsibilities
- do not collapse distinct containers into vague boxes

### Component Views

- only decompose architecturally significant containers
- do not turn implementation minutiae into architecture diagrams

## Traceability Rules

Each Foundry C4 artifact should remain traceable to upstream and related artifacts.

At minimum:

- C4 views should map back to relevant Refinery scenarios and constraints
- important structural choices should link to ADRs when applicable
- `design.md` should act as the narrative index into the Foundry artifact set

## Review Checklist

Before considering Foundry C4 artifacts complete, check that:

- required sections exist
- the required Mermaid diagram block exists
- terminology is consistent across Foundry artifacts
- diagram labels are meaningful and readable
- diagrams do not contradict the Foundry narrative
- relevant ADR links are present where major decisions are involved
- component views exist only where they add architectural value

## One-Line Rule

**Foundry owns the architecture, and Mermaid is the canonical language for expressing its C4 views consistently across Factory repositories.**