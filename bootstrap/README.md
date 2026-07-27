# Bootstrap Zone

This directory contains the **bootstrap layer** of The Factory:

- bootstrap contracts
- bootstrap implementation scripts
- portable agent-pack source files emitted into initialized target repositories

Use this zone when the question is **how a target repository gets initialized**.

For the current script-driven workflow:

1. copy the entire `bootstrap/` folder into the target repo
2. run `bootstrap/scripts/init-factory.ps1`
3. verify `AGENTS.md`, `/.factory/`, and any emitted `/docs/factory/` outputs
4. optionally delete the copied `bootstrap/` folder
