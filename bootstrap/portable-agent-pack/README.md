# Portable Agent Pack

This directory contains **bootstrap-local source material** for optional-but-practical
Factory reference docs that can be emitted into a target repository during
initialization.

## Purpose

This pack exists for environments where the target repository must remain usable by:

- humans who only have the initialized repo
- generic agents that do not already know The Factory skill contracts
- teams following a copy-run-delete bootstrap workflow

## Expected Workflow

1. Copy the entire `bootstrap/` folder into the target repository.
2. Run the platform bootstrap script from that target repo:
   - **Windows:** `bootstrap/scripts/init-factory.ps1`
   - **Linux/macOS:** `bash bootstrap/scripts/init-factory.sh`
3. The script creates:
   - the agent operating manual at `/AGENTS.md`
   - the canonical runtime workspace under `/.factory/`
   - local Factory reference docs under `/docs/factory/`
4. Verify the emitted artifacts.
5. Optionally delete the copied `bootstrap/` folder.

## Output Shape

When present, this pack is emitted into the target repository as:

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

## Important Boundary

`/AGENTS.md` is the agent operating manual.

`/docs/factory/*` are local reference materials.

These files are not part of the canonical active runtime plane. The runtime operating surface remains:

- `/.factory/*`

The source of truth for the full framework remains in the Factory framework repo.
